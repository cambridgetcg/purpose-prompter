/**
 * CI/CD Adapter Types
 * Platform-agnostic interfaces for CI/CD monitoring
 */

// ============================================================================
// Core Types
// ============================================================================

export type WorkflowStatus = 'queued' | 'in_progress' | 'completed';
export type WorkflowConclusion = 'success' | 'failure' | 'cancelled' | 'skipped' | 'timed_out' | 'action_required';
export type JobStatus = 'queued' | 'in_progress' | 'completed';
export type StepStatus = 'pending' | 'in_progress' | 'completed' | 'skipped';

export type CIEventType = 'build_failure' | 'test_failure' | 'deploy_failure' | 'anomaly' | 'success';
export type AnomalyType = 'slow_build' | 'slow_step' | 'flaky_test' | 'timeout' | 'resource_exhaustion';
export type Severity = 'low' | 'medium' | 'high' | 'critical';

// PP Dimension mapping for CI events
export type PPDimension = 'truth' | 'understanding' | 'beauty' | 'justice' | 'creativity';

// ============================================================================
// Workflow & Job Types
// ============================================================================

export interface WorkflowRun {
  id: string;
  runNumber: number;
  name: string;
  status: WorkflowStatus;
  conclusion?: WorkflowConclusion;
  branch: string;
  commitSha: string;
  commitMessage?: string;
  actor?: string;
  event: string; // push, pull_request, workflow_dispatch, etc.
  createdAt: Date;
  updatedAt: Date;
  startedAt?: Date;
  completedAt?: Date;
  duration?: number; // milliseconds
  jobs: JobSummary[];
  url: string;
  logsUrl?: string;
  artifactsUrl?: string;
}

export interface JobSummary {
  id: string;
  name: string;
  status: JobStatus;
  conclusion?: WorkflowConclusion;
  startedAt?: Date;
  completedAt?: Date;
  duration?: number;
  steps: StepSummary[];
  runnerName?: string;
  runnerOS?: string;
}

export interface StepSummary {
  name: string;
  number: number;
  status: StepStatus;
  conclusion?: WorkflowConclusion;
  startedAt?: Date;
  completedAt?: Date;
  duration?: number;
}

export interface JobLog {
  jobId: string;
  jobName: string;
  content: string;
  steps: StepLog[];
}

export interface StepLog {
  name: string;
  number: number;
  content: string;
  errorLines?: string[];
}

export interface Artifact {
  id: string;
  name: string;
  sizeInBytes: number;
  createdAt: Date;
  expiresAt?: Date;
  downloadUrl?: string;
}

// ============================================================================
// Query Options
// ============================================================================

export interface WorkflowQueryOptions {
  repo?: string;
  branch?: string;
  workflow?: string;
  status?: WorkflowStatus;
  conclusion?: WorkflowConclusion;
  event?: string;
  actor?: string;
  createdAfter?: Date;
  createdBefore?: Date;
  limit?: number;
  page?: number;
}

export interface JobQueryOptions {
  runId: string;
  status?: JobStatus;
  name?: string;
}

// ============================================================================
// CI Events
// ============================================================================

export interface CIEvent {
  eventType: CIEventType;
  runId: string;
  workflowName: string;
  repo: string;
  branch: string;
  commitSha: string;
  commitMessage?: string;
  actor?: string;
  timestamp: Date;
  duration?: number;
  error?: CIError;
  ppDimension?: PPDimension;
}

export interface CIError {
  jobName: string;
  stepName?: string;
  message: string;
  details?: string;
  exitCode?: number;
  errorType?: 'compilation' | 'test' | 'lint' | 'deploy' | 'timeout' | 'resource' | 'unknown';
}

// ============================================================================
// Anomalies
// ============================================================================

export interface PerformanceAnomaly {
  type: AnomalyType;
  severity: Severity;
  workflowName: string;
  repo: string;
  branch: string;
  runId: string;
  currentValue: number;
  threshold: number;
  unit: string;
  message: string;
  timestamp: Date;
  context?: {
    jobName?: string;
    stepName?: string;
    previousValue?: number;
    avgValue?: number;
  };
}

// ============================================================================
// Adapter Interface
// ============================================================================

export interface CIAdapter {
  /** Adapter name for identification */
  name: string;

  /** Platform identifier (github, gitlab, etc.) */
  platform: string;

  /**
   * Get workflow runs matching query options
   */
  getWorkflowRuns(options: WorkflowQueryOptions): Promise<WorkflowRun[]>;

  /**
   * Get a specific workflow run by ID
   */
  getWorkflowRun(runId: string): Promise<WorkflowRun | null>;

  /**
   * Get jobs for a workflow run
   */
  getJobs(runId: string): Promise<JobSummary[]>;

  /**
   * Get logs for a specific job
   */
  getJobLogs(runId: string, jobId: string): Promise<JobLog | null>;

  /**
   * Get artifacts for a workflow run
   */
  getArtifacts(runId: string): Promise<Artifact[]>;

  /**
   * Download an artifact
   */
  downloadArtifact?(artifactId: string): Promise<Buffer>;

  /**
   * Re-run a failed workflow
   */
  rerunWorkflow?(runId: string): Promise<boolean>;

  /**
   * Cancel a running workflow
   */
  cancelWorkflow?(runId: string): Promise<boolean>;

  /**
   * Health check for the adapter
   */
  healthCheck(): Promise<boolean>;
}

// ============================================================================
// GUA Integration Types
// ============================================================================

export interface CIKnowledgeEntry {
  knowledge_type: 'ci_event';
  knowledge_id: string; // ci#repo#runId
  repo: string;
  workflow_name: string;
  branch: string;
  event_type: CIEventType;
  duration_ms?: number;
  error?: CIError;
  anomaly?: PerformanceAnomaly;
  challenge_id?: string;
  pp_dimension?: PPDimension;
  timestamp: string;
}

export interface CIReporterOptions {
  adapter: CIAdapter;
  guaPath?: string;
  autoLog?: boolean;
  logFailures?: boolean;
  logAnomalies?: boolean;
  anomalyThresholds?: AnomalyThresholds;
}

export interface AnomalyThresholds {
  build_time: { warning: number; critical: number };
  step_time: { warning: number; critical: number };
  failure_rate: { warning: number; critical: number };
}

// ============================================================================
// Webhook Types
// ============================================================================

export interface WebhookEvent {
  event: string;
  action?: string;
  payload: Record<string, unknown>;
  deliveryId?: string;
  signature?: string;
  timestamp: Date;
}

export interface WebhookHandler {
  handleEvent(event: WebhookEvent): Promise<void>;
  verifySignature(payload: string, signature: string): boolean;
}

// ============================================================================
// Metrics Types
// ============================================================================

export interface BuildMetrics {
  repo: string;
  workflow: string;
  period: {
    start: Date;
    end: Date;
  };
  totalRuns: number;
  successfulRuns: number;
  failedRuns: number;
  cancelledRuns: number;
  successRate: number;
  avgDuration: number;
  medianDuration: number;
  p95Duration: number;
  longestRun: {
    runId: string;
    duration: number;
    date: Date;
  };
  failuresByJob: Record<string, number>;
  failuresByStep: Record<string, number>;
}

// ============================================================================
// Configuration Types
// ============================================================================

export interface CIConfig {
  repos: string[];
  workflows?: string[];
  branches?: string[];
  thresholds: AnomalyThresholds;
  webhook?: {
    port: number;
    secret?: string;
  };
  notifications?: {
    slack?: string;
    email?: string;
  };
}

// ============================================================================
// Utility Types
// ============================================================================

export type AdapterFactory = (config?: Record<string, unknown>) => CIAdapter;

export interface AdapterRegistry {
  register(name: string, factory: AdapterFactory): void;
  get(name: string): AdapterFactory | undefined;
  list(): string[];
}
