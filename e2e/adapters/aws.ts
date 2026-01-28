/**
 * AWS CloudWatch Logs Adapter
 * Fetches logs from AWS CloudWatch Logs
 */

import { PlatformAdapter, LogQueryOptions, LogEntry, DeploymentInfo } from './types';

// Minimal CloudWatch types to avoid full SDK dependency
interface CloudWatchEvent {
  timestamp?: number;
  message?: string;
  logStreamName?: string;
  eventId?: string;
}

interface FilterLogEventsResponse {
  events?: CloudWatchEvent[];
  nextToken?: string;
}

export class AWSAdapter implements PlatformAdapter {
  name = 'aws';
  private region: string;

  constructor(
    private logGroupName: string,
    region: string = 'us-west-2'
  ) {
    this.region = region;
  }

  /**
   * Create adapter from environment variables
   */
  static fromEnv(): AWSAdapter | null {
    const logGroup = process.env.AWS_LOG_GROUP;
    const region = process.env.AWS_REGION || 'us-west-2';

    if (!logGroup) {
      return null;
    }

    return new AWSAdapter(logGroup, region);
  }

  async fetchLogs(options: LogQueryOptions): Promise<LogEntry[]> {
    // Dynamic import to avoid requiring AWS SDK if not used
    let CloudWatchLogsClient: any;
    let FilterLogEventsCommand: any;

    try {
      const cloudwatchModule = await import('@aws-sdk/client-cloudwatch-logs');
      CloudWatchLogsClient = cloudwatchModule.CloudWatchLogsClient;
      FilterLogEventsCommand = cloudwatchModule.FilterLogEventsCommand;
    } catch {
      console.error('[AWS] @aws-sdk/client-cloudwatch-logs not installed');
      return [];
    }

    const client = new CloudWatchLogsClient({ region: this.region });

    // Build filter pattern
    let filterPattern: string | undefined;
    const patterns: string[] = [];

    if (options.level) {
      patterns.push(`[level=${options.level}]`);
    }
    if (options.requestId) {
      patterns.push(`"${options.requestId}"`);
    }
    if (options.path) {
      patterns.push(`"${options.path}"`);
    }

    if (patterns.length > 0) {
      filterPattern = patterns.join(' ');
    }

    try {
      const command = new FilterLogEventsCommand({
        logGroupName: this.logGroupName,
        startTime: options.startTime.getTime(),
        endTime: options.endTime.getTime(),
        filterPattern,
        limit: options.limit || 100
      });

      const response: FilterLogEventsResponse = await client.send(command);
      return this.transformLogs(response.events || []);
    } catch (error) {
      console.error('[AWS] Failed to fetch logs:', error);
      return [];
    }
  }

  private transformLogs(events: CloudWatchEvent[]): LogEntry[] {
    return events.map(event => {
      const parsed = this.parseLogMessage(event.message || '');
      return {
        timestamp: new Date(event.timestamp || Date.now()),
        level: parsed.level || 'info',
        message: parsed.message || event.message || '',
        requestId: parsed.requestId,
        path: parsed.path,
        metadata: {
          source: 'cloudwatch',
          logStreamName: event.logStreamName,
          eventId: event.eventId,
          ...parsed.metadata
        }
      };
    });
  }

  private parseLogMessage(message: string): {
    level?: string;
    message?: string;
    requestId?: string;
    path?: string;
    metadata?: Record<string, unknown>;
  } {
    // Try to parse as JSON (structured logging)
    try {
      const parsed = JSON.parse(message);
      return {
        level: parsed.level || parsed.severity,
        message: parsed.message || parsed.msg || message,
        requestId: parsed.requestId || parsed.request_id || parsed.traceId,
        path: parsed.path || parsed.url,
        metadata: parsed
      };
    } catch {
      // Not JSON, try to extract from common log formats
    }

    // Try Lambda log format: "TIMESTAMP REQUEST_ID LEVEL MESSAGE"
    const lambdaMatch = message.match(
      /^(\d{4}-\d{2}-\d{2}T[\d:.Z]+)\s+([a-f0-9-]+)\s+(INFO|ERROR|WARN|DEBUG)\s+(.*)$/i
    );
    if (lambdaMatch) {
      return {
        level: lambdaMatch[3].toLowerCase(),
        message: lambdaMatch[4],
        requestId: lambdaMatch[2]
      };
    }

    // Try simple level prefix: "[ERROR] message" or "ERROR: message"
    const levelMatch = message.match(/^\[?(ERROR|WARN|INFO|DEBUG)\]?:?\s*(.*)$/i);
    if (levelMatch) {
      return {
        level: levelMatch[1].toLowerCase(),
        message: levelMatch[2]
      };
    }

    // Return raw message
    return { message, level: 'info' };
  }

  async getDeploymentInfo(): Promise<DeploymentInfo> {
    return {
      platform: 'aws',
      environment: process.env.AWS_ENV || process.env.STAGE || 'staging',
      url: process.env.APP_URL || process.env.API_URL || '',
      version: process.env.GIT_COMMIT || process.env.CODEBUILD_RESOLVED_SOURCE_VERSION
    };
  }

  async healthCheck(): Promise<boolean> {
    try {
      // Dynamic import
      const { CloudWatchLogsClient, DescribeLogGroupsCommand } = await import(
        '@aws-sdk/client-cloudwatch-logs'
      );

      const client = new CloudWatchLogsClient({ region: this.region });
      const command = new DescribeLogGroupsCommand({
        logGroupNamePrefix: this.logGroupName,
        limit: 1
      });

      const response = await client.send(command);
      return (response.logGroups?.length || 0) > 0;
    } catch {
      return false;
    }
  }

  /**
   * Fetch logs with CloudWatch Insights query (more powerful)
   */
  async queryLogs(query: string, options: LogQueryOptions): Promise<LogEntry[]> {
    try {
      const {
        CloudWatchLogsClient,
        StartQueryCommand,
        GetQueryResultsCommand
      } = await import('@aws-sdk/client-cloudwatch-logs');

      const client = new CloudWatchLogsClient({ region: this.region });

      // Start the query
      const startCommand = new StartQueryCommand({
        logGroupName: this.logGroupName,
        startTime: Math.floor(options.startTime.getTime() / 1000),
        endTime: Math.floor(options.endTime.getTime() / 1000),
        queryString: query,
        limit: options.limit || 100
      });

      const { queryId } = await client.send(startCommand);
      if (!queryId) return [];

      // Poll for results
      let status = 'Running';
      let results: any[] = [];

      while (status === 'Running' || status === 'Scheduled') {
        await new Promise(resolve => setTimeout(resolve, 500));

        const getCommand = new GetQueryResultsCommand({ queryId });
        const response = await client.send(getCommand);

        status = response.status || 'Complete';
        results = response.results || [];
      }

      // Transform results
      return results.map(row => {
        const entry: Record<string, string> = {};
        for (const field of row) {
          if (field.field && field.value) {
            entry[field.field] = field.value;
          }
        }

        return {
          timestamp: new Date(entry['@timestamp'] || Date.now()),
          level: entry.level || 'info',
          message: entry['@message'] || entry.message || '',
          requestId: entry.requestId,
          path: entry.path,
          metadata: entry
        };
      });
    } catch (error) {
      console.error('[AWS] Query failed:', error);
      return [];
    }
  }
}
