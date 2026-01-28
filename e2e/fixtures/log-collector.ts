/**
 * Log Collector Fixture
 * Extended fixtures for log correlation and error analysis
 */

import { test as baseTest } from './base';
import { LogEntry, LogCorrelation } from '../adapters/types';

/**
 * Extended test with log correlation capabilities
 */
export const test = baseTest.extend<{
  /** Correlate logs to a specific request path */
  correlateLogsToRequest: (path: string) => Promise<LogCorrelation | null>;
  /** Find errors near a specific timestamp */
  findErrorsNearTimestamp: (timestamp: Date, windowMs?: number) => Promise<LogEntry[]>;
  /** Find logs containing a search term */
  searchLogs: (term: string, options?: { level?: string; limit?: number }) => Promise<LogEntry[]>;
  /** Get request IDs captured during test */
  getRequestIds: () => string[];
  /** Wait for and collect logs with a specific pattern */
  waitForLog: (pattern: RegExp | string, timeout?: number) => Promise<LogEntry | null>;
}>({
  /**
   * Correlate logs to a specific request path
   */
  correlateLogsToRequest: async ({ testContext, collectLogs }, use) => {
    const correlate = async (path: string): Promise<LogCorrelation | null> => {
      const allLogs = await collectLogs();

      // Find logs related to this path
      const relevantLogs = allLogs.filter(log => {
        // Check path field
        if (log.path?.includes(path)) return true;

        // Check message for path
        if (log.message.includes(path)) return true;

        // Check URL in metadata
        const url = log.metadata?.url as string;
        if (url?.includes(path)) return true;

        return false;
      });

      if (relevantLogs.length === 0) return null;

      // Find request ID from the logs
      const logWithRequestId = relevantLogs.find(l => l.requestId);
      const requestId = logWithRequestId?.requestId ||
        Array.from(testContext.requestIds)[0] ||
        'unknown';

      // Separate errors
      const errors = relevantLogs.filter(l => l.level === 'error');

      // Calculate duration
      const timestamps = relevantLogs.map(l => l.timestamp.getTime());
      const duration = timestamps.length > 1
        ? Math.max(...timestamps) - Math.min(...timestamps)
        : 0;

      return {
        requestId,
        path,
        logs: relevantLogs,
        errors,
        duration
      };
    };

    await use(correlate);
  },

  /**
   * Find errors near a specific timestamp
   */
  findErrorsNearTimestamp: async ({ collectLogs }, use) => {
    const findErrors = async (
      timestamp: Date,
      windowMs = 5000
    ): Promise<LogEntry[]> => {
      const allLogs = await collectLogs();
      const targetTime = timestamp.getTime();

      return allLogs.filter(log =>
        log.level === 'error' &&
        Math.abs(log.timestamp.getTime() - targetTime) <= windowMs
      );
    };

    await use(findErrors);
  },

  /**
   * Search logs by term
   */
  searchLogs: async ({ collectLogs }, use) => {
    const search = async (
      term: string,
      options?: { level?: string; limit?: number }
    ): Promise<LogEntry[]> => {
      const allLogs = await collectLogs();
      const termLower = term.toLowerCase();

      let results = allLogs.filter(log => {
        // Search in message
        if (log.message.toLowerCase().includes(termLower)) return true;

        // Search in path
        if (log.path?.toLowerCase().includes(termLower)) return true;

        // Search in metadata
        const metadata = JSON.stringify(log.metadata || {}).toLowerCase();
        if (metadata.includes(termLower)) return true;

        return false;
      });

      // Filter by level if specified
      if (options?.level) {
        results = results.filter(log => log.level === options.level);
      }

      // Limit results
      if (options?.limit) {
        results = results.slice(0, options.limit);
      }

      return results;
    };

    await use(search);
  },

  /**
   * Get captured request IDs
   */
  getRequestIds: async ({ testContext }, use) => {
    const getIds = (): string[] => {
      return Array.from(testContext.requestIds);
    };

    await use(getIds);
  },

  /**
   * Wait for a log matching a pattern
   */
  waitForLog: async ({ testContext }, use) => {
    const waitFor = async (
      pattern: RegExp | string,
      timeout = 10000
    ): Promise<LogEntry | null> => {
      const startTime = Date.now();
      const regex = typeof pattern === 'string' ? new RegExp(pattern, 'i') : pattern;

      while (Date.now() - startTime < timeout) {
        // Check existing logs
        const match = testContext.collectedLogs.find(log =>
          regex.test(log.message)
        );

        if (match) return match;

        // Wait a bit before checking again
        await new Promise(resolve => setTimeout(resolve, 100));
      }

      return null;
    };

    await use(waitFor);
  }
});

export { expect } from '@playwright/test';

/**
 * Utility: Format logs for display
 */
export function formatLogs(logs: LogEntry[]): string {
  return logs.map(log => {
    const time = log.timestamp.toISOString().slice(11, 23); // HH:MM:SS.mmm
    const level = log.level.toUpperCase().padEnd(5);
    return `[${time}] ${level} ${log.message}`;
  }).join('\n');
}

/**
 * Utility: Group logs by request ID
 */
export function groupLogsByRequest(logs: LogEntry[]): Map<string, LogEntry[]> {
  const groups = new Map<string, LogEntry[]>();

  for (const log of logs) {
    const key = log.requestId || 'no-request-id';
    const group = groups.get(key) || [];
    group.push(log);
    groups.set(key, group);
  }

  return groups;
}

/**
 * Utility: Get error summary
 */
export function getErrorSummary(logs: LogEntry[]): {
  total: number;
  unique: number;
  messages: string[];
} {
  const errors = logs.filter(l => l.level === 'error');
  const uniqueMessages = [...new Set(errors.map(e => e.message))];

  return {
    total: errors.length,
    unique: uniqueMessages.length,
    messages: uniqueMessages
  };
}
