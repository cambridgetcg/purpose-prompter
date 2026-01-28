/**
 * Generic CI Adapter
 * Fallback adapter for unsupported platforms or testing
 * Returns mock/empty data
 */

import type {
  CIAdapter,
  WorkflowRun,
  WorkflowQueryOptions,
  JobSummary,
  JobLog,
  Artifact,
} from './types';

export class GenericAdapter implements CIAdapter {
  name = 'generic';
  platform = 'generic';

  private mockRuns: WorkflowRun[] = [];

  constructor(options: { mockData?: WorkflowRun[] } = {}) {
    this.mockRuns = options.mockData || [];
  }

  async getWorkflowRuns(options: WorkflowQueryOptions = {}): Promise<WorkflowRun[]> {
    let runs = [...this.mockRuns];

    // Apply filters
    if (options.branch) {
      runs = runs.filter(r => r.branch === options.branch);
    }
    if (options.status) {
      runs = runs.filter(r => r.status === options.status);
    }
    if (options.conclusion) {
      runs = runs.filter(r => r.conclusion === options.conclusion);
    }
    if (options.limit) {
      runs = runs.slice(0, options.limit);
    }

    return runs;
  }

  async getWorkflowRun(runId: string): Promise<WorkflowRun | null> {
    return this.mockRuns.find(r => r.id === runId) || null;
  }

  async getJobs(runId: string): Promise<JobSummary[]> {
    const run = this.mockRuns.find(r => r.id === runId);
    return run?.jobs || [];
  }

  async getJobLogs(_runId: string, _jobId: string): Promise<JobLog | null> {
    // Generic adapter doesn't have real logs
    return null;
  }

  async getArtifacts(_runId: string): Promise<Artifact[]> {
    return [];
  }

  async healthCheck(): Promise<boolean> {
    return true;
  }

  // Helper methods for testing
  addMockRun(run: WorkflowRun): void {
    this.mockRuns.push(run);
  }

  clearMockData(): void {
    this.mockRuns = [];
  }
}

export function createGenericAdapter(options?: { mockData?: WorkflowRun[] }): CIAdapter {
  return new GenericAdapter(options);
}
