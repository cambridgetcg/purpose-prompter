/**
 * Generic Platform Adapter
 * Fallback adapter that captures browser console logs
 * Use when no platform-specific adapter is available
 */

import { PlatformAdapter, LogQueryOptions, LogEntry, DeploymentInfo } from './types';

export class GenericAdapter implements PlatformAdapter {
  name = 'generic';
  private logs: LogEntry[] = [];

  constructor(private baseUrl: string) {}

  /**
   * Capture a log entry (called from Playwright page.on('console'))
   */
  captureLog(entry: LogEntry): void {
    this.logs.push(entry);
  }

  /**
   * Capture multiple log entries at once
   */
  captureLogs(entries: LogEntry[]): void {
    this.logs.push(...entries);
  }

  /**
   * Create a log entry from browser console message
   */
  static createLogEntry(
    level: string,
    message: string,
    metadata?: Record<string, unknown>
  ): LogEntry {
    return {
      timestamp: new Date(),
      level: level === 'log' ? 'info' : level,
      message,
      metadata: {
        source: 'browser-console',
        ...metadata
      }
    };
  }

  async fetchLogs(options: LogQueryOptions): Promise<LogEntry[]> {
    return this.logs.filter(log => {
      // Time window filter
      if (log.timestamp < options.startTime || log.timestamp > options.endTime) {
        return false;
      }

      // Level filter
      if (options.level && log.level !== options.level) {
        return false;
      }

      // Path filter (check message for path mentions)
      if (options.path && !log.message.includes(options.path)) {
        return false;
      }

      // Request ID filter
      if (options.requestId && log.requestId !== options.requestId) {
        return false;
      }

      return true;
    }).slice(0, options.limit || 100);
  }

  async getDeploymentInfo(): Promise<DeploymentInfo> {
    return {
      platform: 'generic',
      environment: process.env.NODE_ENV || 'test',
      url: this.baseUrl,
      version: process.env.GIT_COMMIT || undefined
    };
  }

  async healthCheck(): Promise<boolean> {
    try {
      const response = await fetch(this.baseUrl, { method: 'HEAD' });
      return response.ok;
    } catch {
      return false;
    }
  }

  /**
   * Clear collected logs (call between tests)
   */
  clear(): void {
    this.logs = [];
  }

  /**
   * Get all collected logs without filtering
   */
  getAllLogs(): LogEntry[] {
    return [...this.logs];
  }

  /**
   * Get error logs only
   */
  getErrors(): LogEntry[] {
    return this.logs.filter(log => log.level === 'error');
  }

  /**
   * Get warnings only
   */
  getWarnings(): LogEntry[] {
    return this.logs.filter(log => log.level === 'warn' || log.level === 'warning');
  }
}
