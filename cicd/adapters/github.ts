/**
 * GitHub Actions Adapter
 * Fetches workflow runs, jobs, logs, and artifacts from GitHub Actions
 */

import type {
  CIAdapter,
  WorkflowRun,
  WorkflowQueryOptions,
  JobSummary,
  JobLog,
  StepLog,
  Artifact,
  WorkflowStatus,
  WorkflowConclusion,
  JobStatus,
  StepStatus,
} from './types';

// ============================================================================
// GitHub API Response Types
// ============================================================================

interface GitHubWorkflowRun {
  id: number;
  run_number: number;
  name: string;
  status: string;
  conclusion: string | null;
  head_branch: string;
  head_sha: string;
  head_commit?: {
    message: string;
  };
  actor?: {
    login: string;
  };
  event: string;
  created_at: string;
  updated_at: string;
  run_started_at?: string;
  html_url: string;
  logs_url: string;
  artifacts_url: string;
}

interface GitHubJob {
  id: number;
  name: string;
  status: string;
  conclusion: string | null;
  started_at: string | null;
  completed_at: string | null;
  steps?: GitHubStep[];
  runner_name?: string;
  runner_os?: string;
}

interface GitHubStep {
  name: string;
  number: number;
  status: string;
  conclusion: string | null;
  started_at: string | null;
  completed_at: string | null;
}

interface GitHubArtifact {
  id: number;
  name: string;
  size_in_bytes: number;
  created_at: string;
  expires_at: string;
  archive_download_url: string;
}

// ============================================================================
// GitHub Actions Adapter
// ============================================================================

export class GitHubActionsAdapter implements CIAdapter {
  name = 'github-actions';
  platform = 'github';

  private token: string;
  private defaultRepo: string;
  private baseUrl: string;

  constructor(options: {
    token?: string;
    repo?: string;
    baseUrl?: string;
  } = {}) {
    this.token = options.token || process.env.GITHUB_TOKEN || '';
    this.defaultRepo = options.repo || process.env.GITHUB_REPOSITORY || '';
    this.baseUrl = options.baseUrl || 'https://api.github.com';

    if (!this.token) {
      console.warn('[GitHubActionsAdapter] No GITHUB_TOKEN provided. API calls may be rate-limited.');
    }
  }

  // ==========================================================================
  // Private Helpers
  // ==========================================================================

  private async fetch<T>(endpoint: string, options: RequestInit = {}): Promise<T> {
    const url = endpoint.startsWith('http') ? endpoint : `${this.baseUrl}${endpoint}`;

    const headers: Record<string, string> = {
      'Accept': 'application/vnd.github+json',
      'X-GitHub-Api-Version': '2022-11-28',
      ...((options.headers as Record<string, string>) || {}),
    };

    if (this.token) {
      headers['Authorization'] = `Bearer ${this.token}`;
    }

    const response = await fetch(url, {
      ...options,
      headers,
    });

    if (!response.ok) {
      const error = await response.text();
      throw new Error(`GitHub API error: ${response.status} ${response.statusText} - ${error}`);
    }

    // Handle empty responses
    const text = await response.text();
    if (!text) {
      return {} as T;
    }

    return JSON.parse(text) as T;
  }

  private getRepo(repo?: string): string {
    const r = repo || this.defaultRepo;
    if (!r) {
      throw new Error('Repository not specified. Set GITHUB_REPOSITORY or pass repo option.');
    }
    return r;
  }

  private mapStatus(status: string): WorkflowStatus {
    switch (status) {
      case 'queued':
      case 'pending':
      case 'waiting':
        return 'queued';
      case 'in_progress':
        return 'in_progress';
      case 'completed':
      default:
        return 'completed';
    }
  }

  private mapConclusion(conclusion: string | null): WorkflowConclusion | undefined {
    if (!conclusion) return undefined;
    switch (conclusion) {
      case 'success':
        return 'success';
      case 'failure':
        return 'failure';
      case 'cancelled':
        return 'cancelled';
      case 'skipped':
        return 'skipped';
      case 'timed_out':
        return 'timed_out';
      case 'action_required':
        return 'action_required';
      default:
        return undefined;
    }
  }

  private mapJobStatus(status: string): JobStatus {
    switch (status) {
      case 'queued':
      case 'pending':
      case 'waiting':
        return 'queued';
      case 'in_progress':
        return 'in_progress';
      case 'completed':
      default:
        return 'completed';
    }
  }

  private mapStepStatus(status: string): StepStatus {
    switch (status) {
      case 'pending':
      case 'queued':
        return 'pending';
      case 'in_progress':
        return 'in_progress';
      case 'completed':
        return 'completed';
      case 'skipped':
        return 'skipped';
      default:
        return 'completed';
    }
  }

  private calculateDuration(startedAt?: string | null, completedAt?: string | null): number | undefined {
    if (!startedAt || !completedAt) return undefined;
    return new Date(completedAt).getTime() - new Date(startedAt).getTime();
  }

  private mapWorkflowRun(run: GitHubWorkflowRun, jobs: JobSummary[] = []): WorkflowRun {
    const startedAt = run.run_started_at ? new Date(run.run_started_at) : undefined;
    const completedAt = run.status === 'completed' ? new Date(run.updated_at) : undefined;

    return {
      id: String(run.id),
      runNumber: run.run_number,
      name: run.name,
      status: this.mapStatus(run.status),
      conclusion: this.mapConclusion(run.conclusion),
      branch: run.head_branch,
      commitSha: run.head_sha,
      commitMessage: run.head_commit?.message,
      actor: run.actor?.login,
      event: run.event,
      createdAt: new Date(run.created_at),
      updatedAt: new Date(run.updated_at),
      startedAt,
      completedAt,
      duration: this.calculateDuration(run.run_started_at, run.status === 'completed' ? run.updated_at : null),
      jobs,
      url: run.html_url,
      logsUrl: run.logs_url,
      artifactsUrl: run.artifacts_url,
    };
  }

  private mapJob(job: GitHubJob): JobSummary {
    return {
      id: String(job.id),
      name: job.name,
      status: this.mapJobStatus(job.status),
      conclusion: this.mapConclusion(job.conclusion),
      startedAt: job.started_at ? new Date(job.started_at) : undefined,
      completedAt: job.completed_at ? new Date(job.completed_at) : undefined,
      duration: this.calculateDuration(job.started_at, job.completed_at),
      steps: (job.steps || []).map(step => ({
        name: step.name,
        number: step.number,
        status: this.mapStepStatus(step.status),
        conclusion: this.mapConclusion(step.conclusion),
        startedAt: step.started_at ? new Date(step.started_at) : undefined,
        completedAt: step.completed_at ? new Date(step.completed_at) : undefined,
        duration: this.calculateDuration(step.started_at, step.completed_at),
      })),
      runnerName: job.runner_name,
      runnerOS: job.runner_os,
    };
  }

  // ==========================================================================
  // Public API
  // ==========================================================================

  async getWorkflowRuns(options: WorkflowQueryOptions = {}): Promise<WorkflowRun[]> {
    const repo = this.getRepo(options.repo);
    const params = new URLSearchParams();

    if (options.branch) params.append('branch', options.branch);
    if (options.status) params.append('status', options.status);
    if (options.event) params.append('event', options.event);
    if (options.actor) params.append('actor', options.actor);
    if (options.createdAfter) params.append('created', `>=${options.createdAfter.toISOString()}`);
    params.append('per_page', String(options.limit || 30));
    if (options.page) params.append('page', String(options.page));

    // If workflow is specified, use workflow-specific endpoint
    let endpoint: string;
    if (options.workflow) {
      endpoint = `/repos/${repo}/actions/workflows/${options.workflow}/runs?${params}`;
    } else {
      endpoint = `/repos/${repo}/actions/runs?${params}`;
    }

    const response = await this.fetch<{ workflow_runs: GitHubWorkflowRun[] }>(endpoint);

    // Fetch jobs for each run
    const runs = await Promise.all(
      response.workflow_runs.map(async (run) => {
        const jobs = await this.getJobs(String(run.id));
        return this.mapWorkflowRun(run, jobs);
      })
    );

    // Filter by conclusion if specified (GitHub API doesn't support this directly)
    if (options.conclusion) {
      return runs.filter(run => run.conclusion === options.conclusion);
    }

    return runs;
  }

  async getWorkflowRun(runId: string): Promise<WorkflowRun | null> {
    const repo = this.getRepo();

    try {
      const run = await this.fetch<GitHubWorkflowRun>(`/repos/${repo}/actions/runs/${runId}`);
      const jobs = await this.getJobs(runId);
      return this.mapWorkflowRun(run, jobs);
    } catch (error) {
      if (error instanceof Error && error.message.includes('404')) {
        return null;
      }
      throw error;
    }
  }

  async getJobs(runId: string): Promise<JobSummary[]> {
    const repo = this.getRepo();

    const response = await this.fetch<{ jobs: GitHubJob[] }>(
      `/repos/${repo}/actions/runs/${runId}/jobs`
    );

    return response.jobs.map(job => this.mapJob(job));
  }

  async getJobLogs(runId: string, jobId: string): Promise<JobLog | null> {
    const repo = this.getRepo();

    try {
      // Get job details first
      const jobResponse = await this.fetch<GitHubJob>(
        `/repos/${repo}/actions/jobs/${jobId}`
      );

      // Get job logs - GitHub returns plain text
      const logsResponse = await fetch(
        `${this.baseUrl}/repos/${repo}/actions/jobs/${jobId}/logs`,
        {
          headers: {
            'Authorization': `Bearer ${this.token}`,
            'Accept': 'application/vnd.github+json',
          },
          redirect: 'follow',
        }
      );

      if (!logsResponse.ok) {
        return null;
      }

      const content = await logsResponse.text();

      // Parse logs into steps
      const steps: StepLog[] = [];
      const stepRegex = /##\[group\](.*?)\n([\s\S]*?)(?=##\[endgroup\]|##\[group\]|$)/g;
      let match;

      while ((match = stepRegex.exec(content)) !== null) {
        const stepName = match[1].trim();
        const stepContent = match[2].trim();
        const errorLines = stepContent
          .split('\n')
          .filter(line => line.includes('error') || line.includes('Error') || line.includes('ERROR'))
          .slice(0, 10); // Limit error lines

        steps.push({
          name: stepName,
          number: steps.length + 1,
          content: stepContent,
          errorLines: errorLines.length > 0 ? errorLines : undefined,
        });
      }

      return {
        jobId,
        jobName: jobResponse.name,
        content,
        steps,
      };
    } catch (error) {
      console.error(`[GitHubActionsAdapter] Failed to get logs for job ${jobId}:`, error);
      return null;
    }
  }

  async getArtifacts(runId: string): Promise<Artifact[]> {
    const repo = this.getRepo();

    const response = await this.fetch<{ artifacts: GitHubArtifact[] }>(
      `/repos/${repo}/actions/runs/${runId}/artifacts`
    );

    return response.artifacts.map(artifact => ({
      id: String(artifact.id),
      name: artifact.name,
      sizeInBytes: artifact.size_in_bytes,
      createdAt: new Date(artifact.created_at),
      expiresAt: artifact.expires_at ? new Date(artifact.expires_at) : undefined,
      downloadUrl: artifact.archive_download_url,
    }));
  }

  async downloadArtifact(artifactId: string): Promise<Buffer> {
    const repo = this.getRepo();

    const response = await fetch(
      `${this.baseUrl}/repos/${repo}/actions/artifacts/${artifactId}/zip`,
      {
        headers: {
          'Authorization': `Bearer ${this.token}`,
          'Accept': 'application/vnd.github+json',
        },
        redirect: 'follow',
      }
    );

    if (!response.ok) {
      throw new Error(`Failed to download artifact: ${response.status} ${response.statusText}`);
    }

    const arrayBuffer = await response.arrayBuffer();
    return Buffer.from(arrayBuffer);
  }

  async rerunWorkflow(runId: string): Promise<boolean> {
    const repo = this.getRepo();

    try {
      await this.fetch(`/repos/${repo}/actions/runs/${runId}/rerun`, {
        method: 'POST',
      });
      return true;
    } catch (error) {
      console.error(`[GitHubActionsAdapter] Failed to rerun workflow ${runId}:`, error);
      return false;
    }
  }

  async cancelWorkflow(runId: string): Promise<boolean> {
    const repo = this.getRepo();

    try {
      await this.fetch(`/repos/${repo}/actions/runs/${runId}/cancel`, {
        method: 'POST',
      });
      return true;
    } catch (error) {
      console.error(`[GitHubActionsAdapter] Failed to cancel workflow ${runId}:`, error);
      return false;
    }
  }

  async healthCheck(): Promise<boolean> {
    try {
      const repo = this.getRepo();
      await this.fetch(`/repos/${repo}/actions/runs?per_page=1`);
      return true;
    } catch (error) {
      console.error('[GitHubActionsAdapter] Health check failed:', error);
      return false;
    }
  }
}

// ============================================================================
// Factory Function
// ============================================================================

export function createGitHubAdapter(options?: {
  token?: string;
  repo?: string;
  baseUrl?: string;
}): CIAdapter {
  return new GitHubActionsAdapter(options);
}
