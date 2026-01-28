/**
 * Base Playwright Fixture with Log Collection
 * Extends Playwright test with automatic log capture from browser and server
 */

import { test as base } from '@playwright/test';
import { createAdapter, PlatformAdapter, LogEntry, TestContext } from '../adapters';
import { GenericAdapter } from '../adapters/generic';

/**
 * Extended test fixtures for E2E with log collection
 */
export const test = base.extend<{
  /** Test context with adapter and collected logs */
  testContext: TestContext;
  /** Function to collect all logs (browser + server) */
  collectLogs: () => Promise<LogEntry[]>;
  /** Function to get only error logs */
  getErrors: () => Promise<LogEntry[]>;
  /** Attach logs to test results */
  attachLogs: () => Promise<void>;
}>({
  /**
   * Test context fixture - sets up log collection
   */
  testContext: async ({ page }, use) => {
    const adapter = createAdapter();
    const testStartTime = new Date();
    const collectedLogs: LogEntry[] = [];
    const requestIds = new Set<string>();

    // Capture request IDs from response headers
    page.on('response', response => {
      const headers = response.headers();

      // Common request ID headers
      const requestId =
        headers['x-request-id'] ||
        headers['x-vercel-id'] ||
        headers['x-amz-request-id'] ||
        headers['x-correlation-id'] ||
        headers['cf-ray']; // Cloudflare

      if (requestId) {
        requestIds.add(requestId);
      }
    });

    // Capture browser console logs
    page.on('console', msg => {
      const level = msg.type();
      const entry: LogEntry = {
        timestamp: new Date(),
        level: level === 'log' ? 'info' : level,
        message: msg.text(),
        metadata: {
          source: 'browser-console',
          url: page.url(),
          location: msg.location()
        }
      };
      collectedLogs.push(entry);

      // Also capture in generic adapter if using it
      if (adapter instanceof GenericAdapter) {
        adapter.captureLog(entry);
      }
    });

    // Capture page errors
    page.on('pageerror', error => {
      const entry: LogEntry = {
        timestamp: new Date(),
        level: 'error',
        message: error.message,
        metadata: {
          source: 'page-error',
          stack: error.stack,
          url: page.url()
        }
      };
      collectedLogs.push(entry);

      if (adapter instanceof GenericAdapter) {
        adapter.captureLog(entry);
      }
    });

    // Capture request failures
    page.on('requestfailed', request => {
      const failure = request.failure();
      const entry: LogEntry = {
        timestamp: new Date(),
        level: 'error',
        message: `Request failed: ${request.url()} - ${failure?.errorText || 'unknown'}`,
        path: new URL(request.url()).pathname,
        metadata: {
          source: 'request-failed',
          url: request.url(),
          method: request.method(),
          error: failure?.errorText
        }
      };
      collectedLogs.push(entry);

      if (adapter instanceof GenericAdapter) {
        adapter.captureLog(entry);
      }
    });

    await use({ adapter, testStartTime, collectedLogs, requestIds });
  },

  /**
   * Collect all logs (browser + server)
   */
  collectLogs: async ({ testContext }, use) => {
    const collect = async (): Promise<LogEntry[]> => {
      const { adapter, testStartTime, collectedLogs } = testContext;

      // Fetch server logs from platform
      let serverLogs: LogEntry[] = [];
      try {
        serverLogs = await adapter.fetchLogs({
          startTime: testStartTime,
          endTime: new Date(),
          limit: 100
        });
      } catch (error) {
        console.warn('[E2E] Failed to fetch server logs:', error);
      }

      // Merge and deduplicate logs
      const allLogs = [...collectedLogs];

      // Add server logs that aren't duplicates (based on timestamp + message)
      const browserLogKeys = new Set(
        collectedLogs.map(l => `${l.timestamp.getTime()}-${l.message.slice(0, 50)}`)
      );

      for (const log of serverLogs) {
        const key = `${log.timestamp.getTime()}-${log.message.slice(0, 50)}`;
        if (!browserLogKeys.has(key)) {
          allLogs.push(log);
        }
      }

      // Sort by timestamp
      return allLogs.sort((a, b) => a.timestamp.getTime() - b.timestamp.getTime());
    };

    await use(collect);
  },

  /**
   * Get only error logs
   */
  getErrors: async ({ collectLogs }, use) => {
    const getErrors = async (): Promise<LogEntry[]> => {
      const allLogs = await collectLogs();
      return allLogs.filter(log => log.level === 'error');
    };

    await use(getErrors);
  },

  /**
   * Attach collected logs to test results
   */
  attachLogs: async ({ collectLogs }, use, testInfo) => {
    const attachLogs = async (): Promise<void> => {
      const logs = await collectLogs();

      if (logs.length === 0) return;

      // Format logs for attachment
      const formatted = logs.map(log => {
        const time = log.timestamp.toISOString();
        const level = log.level.toUpperCase().padEnd(5);
        const source = (log.metadata?.source as string) || 'unknown';
        return `[${time}] [${level}] [${source}] ${log.message}`;
      }).join('\n');

      await testInfo.attach('collected-logs', {
        body: formatted,
        contentType: 'text/plain'
      });

      // Also attach as JSON for programmatic access
      await testInfo.attach('collected-logs-json', {
        body: JSON.stringify(logs, null, 2),
        contentType: 'application/json'
      });
    };

    await use(attachLogs);

    // Auto-attach logs on test failure
    if (testInfo.status !== 'passed') {
      try {
        await attachLogs();
      } catch {
        // Ignore attachment errors
      }
    }
  }
});

export { expect } from '@playwright/test';

/**
 * Test fixture with automatic log attachment on failure
 */
export const testWithLogs = test.extend({
  // Auto-attach logs at the end of each test
  attachLogs: async ({ attachLogs }, use, testInfo) => {
    await use(attachLogs);

    // Always attach logs on failure
    if (testInfo.status !== 'passed') {
      await attachLogs();
    }
  }
});
