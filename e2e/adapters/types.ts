/**
 * E2E Testing Pipeline - Platform Adapter Types
 * Defines interfaces for platform-agnostic log collection and deployment info
 */

export interface PlatformAdapter {
  name: string;

  /** Fetch logs from the platform */
  fetchLogs(options: LogQueryOptions): Promise<LogEntry[]>;

  /** Get deployment information */
  getDeploymentInfo(): Promise<DeploymentInfo>;

  /** Check if platform is accessible */
  healthCheck(): Promise<boolean>;
}

export interface LogQueryOptions {
  /** Start of time window */
  startTime: Date;
  /** End of time window */
  endTime: Date;
  /** Filter by specific request ID */
  requestId?: string;
  /** Filter by URL path */
  path?: string;
  /** Filter by log level */
  level?: 'error' | 'warn' | 'info' | 'debug';
  /** Maximum number of entries to return */
  limit?: number;
}

export interface LogEntry {
  /** When the log was recorded */
  timestamp: Date;
  /** Log level (error, warn, info, debug, log) */
  level: string;
  /** Log message content */
  message: string;
  /** Request ID for correlation */
  requestId?: string;
  /** URL path if applicable */
  path?: string;
  /** Additional metadata */
  metadata?: Record<string, unknown>;
}

export interface DeploymentInfo {
  /** Platform name (vercel, aws, generic) */
  platform: string;
  /** Environment (production, preview, staging, development) */
  environment: string;
  /** Deployment version/commit SHA */
  version?: string;
  /** Base URL of the deployment */
  url: string;
}

/** Log correlation result */
export interface LogCorrelation {
  /** Request ID that was correlated */
  requestId: string;
  /** URL path that was matched */
  path: string;
  /** All logs related to this request */
  logs: LogEntry[];
  /** Error logs only */
  errors: LogEntry[];
  /** Duration from first to last log entry (ms) */
  duration: number;
}

/** Test context for Playwright fixtures */
export interface TestContext {
  /** Platform adapter for log collection */
  adapter: PlatformAdapter;
  /** When the test started */
  testStartTime: Date;
  /** Browser console logs collected during test */
  collectedLogs: LogEntry[];
  /** Request IDs captured from responses */
  requestIds: Set<string>;
}
