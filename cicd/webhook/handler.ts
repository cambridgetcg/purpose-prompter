/**
 * CI/CD Webhook Event Handler
 * Processes GitHub webhook events and reports to GUA
 */

import * as crypto from 'crypto';
import type {
  WebhookEvent,
  WebhookHandler,
  WorkflowRun,
  CIEvent,
  CIAdapter,
} from '../adapters/types';
import { GUACIReporter } from '../reporters/gua-ci-reporter';
import { AnomalyDetector } from '../analyzers/anomaly-detector';

// ============================================================================
// Types
// ============================================================================

export interface WebhookHandlerOptions {
  secret?: string;
  adapter?: CIAdapter;
  reporter?: GUACIReporter;
  detector?: AnomalyDetector;
  allowedWorkflows?: string[];
  allowedBranches?: string[];
  verbose?: boolean;
}

export interface GitHubWorkflowRunPayload {
  action: 'requested' | 'completed' | 'in_progress';
  workflow_run: {
    id: number;
    name: string;
    head_branch: string;
    head_sha: string;
    status: string;
    conclusion: string | null;
    html_url: string;
    created_at: string;
    updated_at: string;
    run_started_at?: string;
    actor?: {
      login: string;
    };
    head_commit?: {
      message: string;
    };
    repository: {
      full_name: string;
    };
  };
}

export interface GitHubWorkflowJobPayload {
  action: 'queued' | 'in_progress' | 'completed';
  workflow_job: {
    id: number;
    name: string;
    status: string;
    conclusion: string | null;
    started_at: string | null;
    completed_at: string | null;
    steps?: Array<{
      name: string;
      status: string;
      conclusion: string | null;
      number: number;
    }>;
    workflow_name?: string;
    head_branch: string;
    run_id: number;
  };
  repository: {
    full_name: string;
  };
}

// ============================================================================
// Webhook Handler
// ============================================================================

export class CIWebhookHandler implements WebhookHandler {
  private secret?: string;
  private adapter?: CIAdapter;
  private reporter: GUACIReporter;
  private detector: AnomalyDetector;
  private options: WebhookHandlerOptions;

  constructor(options: WebhookHandlerOptions = {}) {
    this.options = {
      verbose: false,
      ...options,
    };
    this.secret = options.secret || process.env.CI_WEBHOOK_SECRET;
    this.adapter = options.adapter;
    this.reporter = options.reporter || new GUACIReporter({ verbose: options.verbose });
    this.detector = options.detector || new AnomalyDetector();
  }

  // ==========================================================================
  // Main Handler
  // ==========================================================================

  /**
   * Handle incoming webhook event
   */
  async handleEvent(event: WebhookEvent): Promise<void> {
    this.log(`Received event: ${event.event} (${event.action || 'no action'})`);

    switch (event.event) {
      case 'workflow_run':
        await this.handleWorkflowRun(event.payload as unknown as GitHubWorkflowRunPayload);
        break;
      case 'workflow_job':
        await this.handleWorkflowJob(event.payload as unknown as GitHubWorkflowJobPayload);
        break;
      case 'check_run':
        // Similar to workflow_job but for checks
        this.log('check_run event received (not implemented)');
        break;
      default:
        this.log(`Unhandled event type: ${event.event}`);
    }
  }

  /**
   * Verify webhook signature
   */
  verifySignature(payload: string, signature: string): boolean {
    if (!this.secret) {
      this.log('No webhook secret configured, skipping signature verification');
      return true;
    }

    if (!signature) {
      this.log('No signature provided');
      return false;
    }

    // GitHub sends signature as "sha256=<hash>"
    const expected = `sha256=${crypto
      .createHmac('sha256', this.secret)
      .update(payload)
      .digest('hex')}`;

    try {
      return crypto.timingSafeEqual(
        Buffer.from(signature),
        Buffer.from(expected)
      );
    } catch {
      return false;
    }
  }

  // ==========================================================================
  // Event Handlers
  // ==========================================================================

  private async handleWorkflowRun(payload: GitHubWorkflowRunPayload): Promise<void> {
    const { action, workflow_run: run } = payload;
    const repo = run.repository.full_name;

    this.log(`Workflow run ${action}: ${run.name} on ${repo}/${run.head_branch}`);

    // Filter by allowed workflows/branches
    if (!this.isAllowed(run.name, run.head_branch)) {
      this.log('Skipping: not in allowed workflows/branches');
      return;
    }

    // Only process completed runs
    if (action !== 'completed') {
      this.log('Skipping: not completed');
      return;
    }

    // Create workflow run object
    const workflowRun = this.mapPayloadToRun(payload);

    // Check for failures
    if (run.conclusion === 'failure') {
      this.log('Failure detected, creating event...');
      const event = this.createEventFromPayload(payload);
      await this.reporter.reportEvent(event);
    }

    // Check for anomalies
    const result = this.detector.analyze(workflowRun, repo);
    if (result.anomalies.length > 0) {
      this.log(`Found ${result.anomalies.length} anomalies`);
      for (const anomaly of result.anomalies) {
        await this.reporter.reportAnomaly(anomaly);
      }
    }

    // Update history for future comparisons
    this.detector.updateHistory(workflowRun, repo);
  }

  private async handleWorkflowJob(payload: GitHubWorkflowJobPayload): Promise<void> {
    const { action, workflow_job: job, repository } = payload;
    const repo = repository.full_name;

    this.log(`Workflow job ${action}: ${job.name} on ${repo}`);

    // Only process completed jobs
    if (action !== 'completed') {
      return;
    }

    // Check for job failures
    if (job.conclusion === 'failure') {
      this.log(`Job failure: ${job.name}`);

      // Find failed step
      const failedStep = job.steps?.find(s => s.conclusion === 'failure');

      const event: CIEvent = {
        eventType: this.classifyEventType(job.workflow_name || job.name, job.name),
        runId: String(job.run_id),
        workflowName: job.workflow_name || job.name,
        repo,
        branch: job.head_branch,
        commitSha: '', // Not available in job payload
        timestamp: new Date(),
        error: {
          jobName: job.name,
          stepName: failedStep?.name,
          message: `Job "${job.name}" failed`,
          errorType: this.classifyErrorType(job.name, failedStep?.name),
        },
      };

      await this.reporter.reportEvent(event);
    }
  }

  // ==========================================================================
  // Helpers
  // ==========================================================================

  private mapPayloadToRun(payload: GitHubWorkflowRunPayload): WorkflowRun {
    const { workflow_run: run } = payload;

    const startedAt = run.run_started_at ? new Date(run.run_started_at) : new Date(run.created_at);
    const completedAt = new Date(run.updated_at);
    const duration = completedAt.getTime() - startedAt.getTime();

    return {
      id: String(run.id),
      runNumber: 0, // Not in webhook payload
      name: run.name,
      status: run.status as 'queued' | 'in_progress' | 'completed',
      conclusion: run.conclusion as any,
      branch: run.head_branch,
      commitSha: run.head_sha,
      commitMessage: run.head_commit?.message,
      actor: run.actor?.login,
      event: 'webhook',
      createdAt: new Date(run.created_at),
      updatedAt: completedAt,
      startedAt,
      completedAt,
      duration,
      jobs: [], // Not available in workflow_run webhook
      url: run.html_url,
    };
  }

  private createEventFromPayload(payload: GitHubWorkflowRunPayload): CIEvent {
    const { workflow_run: run } = payload;
    const repo = run.repository.full_name;

    return {
      eventType: this.classifyEventType(run.name),
      runId: String(run.id),
      workflowName: run.name,
      repo,
      branch: run.head_branch,
      commitSha: run.head_sha,
      commitMessage: run.head_commit?.message,
      actor: run.actor?.login,
      timestamp: new Date(run.updated_at),
    };
  }

  private classifyEventType(
    workflowName: string,
    jobName?: string
  ): 'build_failure' | 'test_failure' | 'deploy_failure' | 'anomaly' {
    const name = `${workflowName} ${jobName || ''}`.toLowerCase();

    if (name.includes('deploy') || name.includes('release') || name.includes('publish')) {
      return 'deploy_failure';
    }
    if (name.includes('test') || name.includes('spec') || name.includes('jest')) {
      return 'test_failure';
    }
    return 'build_failure';
  }

  private classifyErrorType(jobName?: string, stepName?: string): 'compilation' | 'test' | 'lint' | 'deploy' | 'unknown' {
    const name = `${jobName || ''} ${stepName || ''}`.toLowerCase();

    if (name.includes('compile') || name.includes('build') || name.includes('tsc')) {
      return 'compilation';
    }
    if (name.includes('test') || name.includes('spec') || name.includes('jest')) {
      return 'test';
    }
    if (name.includes('lint') || name.includes('eslint')) {
      return 'lint';
    }
    if (name.includes('deploy') || name.includes('release')) {
      return 'deploy';
    }
    return 'unknown';
  }

  private isAllowed(workflowName: string, branch: string): boolean {
    // Check allowed workflows
    if (this.options.allowedWorkflows && this.options.allowedWorkflows.length > 0) {
      const allowed = this.options.allowedWorkflows.some(w =>
        workflowName.toLowerCase().includes(w.toLowerCase())
      );
      if (!allowed) return false;
    }

    // Check allowed branches
    if (this.options.allowedBranches && this.options.allowedBranches.length > 0) {
      const allowed = this.options.allowedBranches.some(b =>
        branch === b || branch.startsWith(b)
      );
      if (!allowed) return false;
    }

    return true;
  }

  private log(message: string): void {
    if (this.options.verbose) {
      console.log(`[CI Webhook] ${message}`);
    }
  }
}

// ============================================================================
// Factory
// ============================================================================

export function createWebhookHandler(options?: WebhookHandlerOptions): CIWebhookHandler {
  return new CIWebhookHandler(options);
}
