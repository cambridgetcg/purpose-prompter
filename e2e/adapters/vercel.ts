/**
 * Vercel Platform Adapter
 * Fetches logs from Vercel's Log Drains API
 */

import { PlatformAdapter, LogQueryOptions, LogEntry, DeploymentInfo } from './types';

interface VercelLogEntry {
  id: string;
  timestamp: number;
  message: string;
  level?: string;
  source?: string;
  requestId?: string;
  path?: string;
  deploymentId?: string;
  projectId?: string;
}

export class VercelAdapter implements PlatformAdapter {
  name = 'vercel';

  constructor(
    private teamId: string,
    private projectId: string,
    private token: string
  ) {}

  /**
   * Create adapter from environment variables
   */
  static fromEnv(): VercelAdapter | null {
    const teamId = process.env.VERCEL_TEAM_ID;
    const projectId = process.env.VERCEL_PROJECT_ID;
    const token = process.env.VERCEL_TOKEN;

    if (!teamId || !projectId || !token) {
      return null;
    }

    return new VercelAdapter(teamId, projectId, token);
  }

  async fetchLogs(options: LogQueryOptions): Promise<LogEntry[]> {
    const params = new URLSearchParams({
      teamId: this.teamId,
      since: options.startTime.getTime().toString(),
      until: options.endTime.getTime().toString(),
    });

    if (options.limit) {
      params.set('limit', String(Math.min(options.limit, 100)));
    }

    // Vercel API supports these query parameters
    if (options.level) {
      params.set('level', options.level);
    }

    try {
      const response = await fetch(
        `https://api.vercel.com/v2/projects/${this.projectId}/logs?${params}`,
        {
          headers: {
            Authorization: `Bearer ${this.token}`,
            'Content-Type': 'application/json'
          }
        }
      );

      if (!response.ok) {
        console.error(`[Vercel] API error: ${response.status} ${response.statusText}`);
        return [];
      }

      const data = await response.json();
      const logs = this.transformLogs(data.logs || []);

      // Apply client-side filters that API doesn't support
      return this.applyFilters(logs, options);
    } catch (error) {
      console.error('[Vercel] Failed to fetch logs:', error);
      return [];
    }
  }

  private transformLogs(logs: VercelLogEntry[]): LogEntry[] {
    return logs.map(log => ({
      timestamp: new Date(log.timestamp),
      level: log.level || 'info',
      message: log.message,
      requestId: log.requestId,
      path: log.path,
      metadata: {
        source: log.source || 'vercel',
        deploymentId: log.deploymentId,
        projectId: log.projectId,
        vercelLogId: log.id
      }
    }));
  }

  private applyFilters(logs: LogEntry[], options: LogQueryOptions): LogEntry[] {
    return logs.filter(log => {
      // Path filter
      if (options.path) {
        if (!log.path?.includes(options.path) && !log.message.includes(options.path)) {
          return false;
        }
      }

      // Request ID filter
      if (options.requestId && log.requestId !== options.requestId) {
        return false;
      }

      return true;
    });
  }

  async getDeploymentInfo(): Promise<DeploymentInfo> {
    // Try to get from environment first (faster)
    if (process.env.VERCEL_URL) {
      return {
        platform: 'vercel',
        environment: process.env.VERCEL_ENV || 'preview',
        version: process.env.VERCEL_GIT_COMMIT_SHA,
        url: `https://${process.env.VERCEL_URL}`
      };
    }

    // Fall back to API call
    try {
      const response = await fetch(
        `https://api.vercel.com/v9/projects/${this.projectId}?teamId=${this.teamId}`,
        {
          headers: { Authorization: `Bearer ${this.token}` }
        }
      );

      if (response.ok) {
        const project = await response.json();
        return {
          platform: 'vercel',
          environment: 'production',
          url: `https://${project.name}.vercel.app`,
          version: project.latestDeployments?.[0]?.meta?.githubCommitSha
        };
      }
    } catch (error) {
      console.error('[Vercel] Failed to get deployment info:', error);
    }

    return {
      platform: 'vercel',
      environment: 'unknown',
      url: ''
    };
  }

  async healthCheck(): Promise<boolean> {
    try {
      const response = await fetch(
        `https://api.vercel.com/v9/projects/${this.projectId}?teamId=${this.teamId}`,
        {
          headers: { Authorization: `Bearer ${this.token}` }
        }
      );
      return response.ok;
    } catch {
      return false;
    }
  }

  /**
   * Fetch logs for a specific request ID
   */
  async fetchLogsForRequest(requestId: string, windowMs = 60000): Promise<LogEntry[]> {
    const now = new Date();
    return this.fetchLogs({
      startTime: new Date(now.getTime() - windowMs),
      endTime: now,
      requestId,
      limit: 50
    });
  }
}
