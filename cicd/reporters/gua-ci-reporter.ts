/**
 * GUA CI Reporter
 * Automatically logs CI/CD failures as CPT challenges and anomalies as gotchas
 */

import { execSync, spawnSync } from 'child_process';
import type {
  CIAdapter,
  WorkflowRun,
  CIEvent,
  CIError,
  PerformanceAnomaly,
  PPDimension,
  CIKnowledgeEntry,
  AnomalyThresholds,
} from '../adapters/types';
import { defaultThresholds, formatDuration, formatPercent } from '../config/thresholds';

// ============================================================================
// Types
// ============================================================================

export interface GUACIReporterOptions {
  adapter?: CIAdapter;
  guaPath?: string;
  autoLog?: boolean;
  logFailures?: boolean;
  logAnomalies?: boolean;
  thresholds?: AnomalyThresholds;
  verbose?: boolean;
}

export interface ReportResult {
  success: boolean;
  challengeId?: string;
  error?: string;
}

// ============================================================================
// PP Dimension Mapping
// ============================================================================

const ERROR_TYPE_TO_DIMENSION: Record<string, PPDimension> = {
  'compilation': 'truth',
  'test': 'truth',
  'lint': 'beauty',
  'deploy': 'justice',
  'timeout': 'truth',
  'resource': 'justice',
  'unknown': 'truth',
};

const ANOMALY_TYPE_TO_DIMENSION: Record<string, PPDimension> = {
  'slow_build': 'beauty',
  'slow_step': 'beauty',
  'flaky_test': 'truth',
  'timeout': 'truth',
  'resource_exhaustion': 'justice',
};

// ============================================================================
// GUA CI Reporter
// ============================================================================

export class GUACIReporter {
  private guaPath: string;
  private options: GUACIReporterOptions;
  private thresholds: AnomalyThresholds;

  constructor(options: GUACIReporterOptions = {}) {
    this.options = {
      autoLog: true,
      logFailures: true,
      logAnomalies: true,
      verbose: false,
      ...options,
    };
    this.guaPath = options.guaPath || '~/.gua/gua.sh';
    this.thresholds = options.thresholds || defaultThresholds;
  }

  // ==========================================================================
  // GUA CLI Integration
  // ==========================================================================

  /**
   * Check if GUA CLI is available
   */
  isGuaAvailable(): boolean {
    try {
      const result = spawnSync('bash', ['-c', `${this.guaPath} --help`], {
        encoding: 'utf-8',
        timeout: 5000,
      });
      return result.status === 0;
    } catch {
      return false;
    }
  }

  /**
   * Execute a GUA CLI command
   */
  private execGua(command: string): { success: boolean; output?: string; error?: string } {
    try {
      const output = execSync(`${this.guaPath} ${command}`, {
        shell: '/bin/bash',
        encoding: 'utf-8',
        timeout: 10000,
        stdio: ['pipe', 'pipe', 'pipe'],
      });
      return { success: true, output: output.trim() };
    } catch (error: unknown) {
      const err = error as { message?: string; stderr?: string };
      return {
        success: false,
        error: err.stderr || err.message || 'Unknown error',
      };
    }
  }

  // ==========================================================================
  // Event Reporting
  // ==========================================================================

  /**
   * Report a CI event (failure or success)
   */
  async reportEvent(event: CIEvent): Promise<ReportResult> {
    if (!this.options.autoLog) {
      return { success: true };
    }

    if (!this.isGuaAvailable()) {
      this.log('GUA CLI not available, skipping event report');
      return { success: false, error: 'GUA CLI not available' };
    }

    // Only log failures
    if (event.eventType === 'success') {
      this.log(`Success event for ${event.workflowName} - not logging`);
      return { success: true };
    }

    if (!this.options.logFailures && event.eventType !== 'anomaly') {
      return { success: true };
    }

    return this.logChallenge(event);
  }

  /**
   * Report a workflow run (analyzes and reports any issues)
   */
  async reportWorkflowRun(run: WorkflowRun, repo: string): Promise<ReportResult[]> {
    const results: ReportResult[] = [];

    // Report failure if present
    if (run.conclusion === 'failure') {
      const event = this.createEventFromRun(run, repo);
      const result = await this.reportEvent(event);
      results.push(result);
    }

    // Check for anomalies
    if (this.options.logAnomalies) {
      const anomalies = this.detectAnomalies(run, repo);
      for (const anomaly of anomalies) {
        const result = await this.reportAnomaly(anomaly);
        results.push(result);
      }
    }

    return results;
  }

  /**
   * Report a performance anomaly
   */
  async reportAnomaly(anomaly: PerformanceAnomaly): Promise<ReportResult> {
    if (!this.options.logAnomalies) {
      return { success: true };
    }

    if (!this.isGuaAvailable()) {
      this.log('GUA CLI not available, skipping anomaly report');
      return { success: false, error: 'GUA CLI not available' };
    }

    return this.logGotcha(anomaly);
  }

  // ==========================================================================
  // Challenge Logging
  // ==========================================================================

  /**
   * Log a CI event as a CPT challenge
   */
  private async logChallenge(event: CIEvent): Promise<ReportResult> {
    const areaId = this.createAreaId(event);
    const description = this.createChallengeDescription(event);
    const dimension = this.getDimension(event);
    const challengeType = this.getChallengeType(event);

    try {
      const cmd = `challenge log "${areaId}" "${this.sanitize(description)}" ${dimension} ${challengeType}`;
      const result = this.execGua(cmd);

      if (result.success) {
        this.log(`Logged challenge: ${event.workflowName} (${event.eventType})`);
        // Try to extract challenge ID from output
        const idMatch = result.output?.match(/challenge#[a-z0-9#-]+/);
        return {
          success: true,
          challengeId: idMatch?.[0],
        };
      } else {
        this.log(`Failed to log challenge: ${result.error}`);
        return { success: false, error: result.error };
      }
    } catch (error: unknown) {
      const err = error as Error;
      this.log(`Failed to log challenge: ${err.message}`);
      return { success: false, error: err.message };
    }
  }

  /**
   * Log a performance anomaly as a dev knowledge gotcha
   */
  private async logGotcha(anomaly: PerformanceAnomaly): Promise<ReportResult> {
    const title = this.createGotchaTitle(anomaly);
    const tags = this.createGotchaTags(anomaly);

    try {
      const cmd = `dev add general deployment gotcha "${this.sanitize(title)}" --tags "${tags}"`;
      const result = this.execGua(cmd);

      if (result.success) {
        this.log(`Logged gotcha: ${anomaly.type} in ${anomaly.workflowName}`);
        return { success: true };
      } else {
        this.log(`Failed to log gotcha: ${result.error}`);
        return { success: false, error: result.error };
      }
    } catch (error: unknown) {
      const err = error as Error;
      this.log(`Failed to log gotcha: ${err.message}`);
      return { success: false, error: err.message };
    }
  }

  // ==========================================================================
  // Anomaly Detection
  // ==========================================================================

  /**
   * Detect performance anomalies in a workflow run
   */
  detectAnomalies(run: WorkflowRun, repo: string): PerformanceAnomaly[] {
    const anomalies: PerformanceAnomaly[] = [];

    // Check build time
    if (run.duration && run.duration > this.thresholds.build_time.critical) {
      anomalies.push({
        type: 'slow_build',
        severity: 'high',
        workflowName: run.name,
        repo,
        branch: run.branch,
        runId: run.id,
        currentValue: run.duration,
        threshold: this.thresholds.build_time.critical,
        unit: 'ms',
        message: `Build took ${formatDuration(run.duration)} (threshold: ${formatDuration(this.thresholds.build_time.critical)})`,
        timestamp: new Date(),
      });
    } else if (run.duration && run.duration > this.thresholds.build_time.warning) {
      anomalies.push({
        type: 'slow_build',
        severity: 'medium',
        workflowName: run.name,
        repo,
        branch: run.branch,
        runId: run.id,
        currentValue: run.duration,
        threshold: this.thresholds.build_time.warning,
        unit: 'ms',
        message: `Build took ${formatDuration(run.duration)} (warning threshold: ${formatDuration(this.thresholds.build_time.warning)})`,
        timestamp: new Date(),
      });
    }

    // Check individual step times
    for (const job of run.jobs) {
      for (const step of job.steps) {
        if (step.duration && step.duration > this.thresholds.step_time.critical) {
          anomalies.push({
            type: 'slow_step',
            severity: 'high',
            workflowName: run.name,
            repo,
            branch: run.branch,
            runId: run.id,
            currentValue: step.duration,
            threshold: this.thresholds.step_time.critical,
            unit: 'ms',
            message: `Step "${step.name}" took ${formatDuration(step.duration)}`,
            timestamp: new Date(),
            context: {
              jobName: job.name,
              stepName: step.name,
            },
          });
        }
      }
    }

    // Check for timeout
    if (run.conclusion === 'timed_out') {
      anomalies.push({
        type: 'timeout',
        severity: 'critical',
        workflowName: run.name,
        repo,
        branch: run.branch,
        runId: run.id,
        currentValue: run.duration || 0,
        threshold: 0,
        unit: 'ms',
        message: `Workflow timed out after ${formatDuration(run.duration || 0)}`,
        timestamp: new Date(),
      });
    }

    return anomalies;
  }

  // ==========================================================================
  // Helper Methods
  // ==========================================================================

  private createEventFromRun(run: WorkflowRun, repo: string): CIEvent {
    // Find the failed job and step
    const failedJob = run.jobs.find(j => j.conclusion === 'failure');
    const failedStep = failedJob?.steps.find(s => s.conclusion === 'failure');

    // Determine event type based on workflow name and failed step
    const eventType = this.classifyEventType(run.name, failedJob?.name, failedStep?.name);

    const event: CIEvent = {
      eventType,
      runId: run.id,
      workflowName: run.name,
      repo,
      branch: run.branch,
      commitSha: run.commitSha,
      commitMessage: run.commitMessage,
      actor: run.actor,
      timestamp: run.completedAt || run.updatedAt,
      duration: run.duration,
      ppDimension: ERROR_TYPE_TO_DIMENSION[eventType] || 'truth',
    };

    if (failedJob) {
      event.error = {
        jobName: failedJob.name,
        stepName: failedStep?.name,
        message: `Job "${failedJob.name}" failed`,
        errorType: this.classifyErrorType(failedJob.name, failedStep?.name),
      };
    }

    return event;
  }

  private classifyEventType(
    workflowName: string,
    jobName?: string,
    stepName?: string
  ): 'build_failure' | 'test_failure' | 'deploy_failure' | 'anomaly' {
    const name = `${workflowName} ${jobName || ''} ${stepName || ''}`.toLowerCase();

    if (name.includes('deploy') || name.includes('release') || name.includes('publish')) {
      return 'deploy_failure';
    }
    if (name.includes('test') || name.includes('spec') || name.includes('jest') || name.includes('vitest')) {
      return 'test_failure';
    }
    return 'build_failure';
  }

  private classifyErrorType(
    jobName?: string,
    stepName?: string
  ): CIError['errorType'] {
    const name = `${jobName || ''} ${stepName || ''}`.toLowerCase();

    if (name.includes('compile') || name.includes('build') || name.includes('tsc')) {
      return 'compilation';
    }
    if (name.includes('test') || name.includes('spec') || name.includes('jest')) {
      return 'test';
    }
    if (name.includes('lint') || name.includes('eslint') || name.includes('prettier')) {
      return 'lint';
    }
    if (name.includes('deploy') || name.includes('release')) {
      return 'deploy';
    }
    return 'unknown';
  }

  private createAreaId(event: CIEvent): string {
    const repo = event.repo.replace('/', '-');
    return `ci#${repo}#${event.runId}`;
  }

  private createChallengeDescription(event: CIEvent): string {
    const parts = [
      `CI ${event.eventType.replace('_', ' ')}: ${event.workflowName}`,
      `Repo: ${event.repo}`,
      `Branch: ${event.branch}`,
    ];

    if (event.error) {
      parts.push(`Job: ${event.error.jobName}`);
      if (event.error.stepName) {
        parts.push(`Step: ${event.error.stepName}`);
      }
    }

    if (event.duration) {
      parts.push(`Duration: ${formatDuration(event.duration)}`);
    }

    return parts.join(' | ');
  }

  private getDimension(event: CIEvent): PPDimension {
    if (event.ppDimension) return event.ppDimension;
    if (event.error?.errorType) {
      return ERROR_TYPE_TO_DIMENSION[event.error.errorType] || 'truth';
    }
    return 'truth';
  }

  private getChallengeType(event: CIEvent): string {
    switch (event.eventType) {
      case 'build_failure':
        return 'bug';
      case 'test_failure':
        return 'bug';
      case 'deploy_failure':
        return 'config';
      default:
        return 'bug';
    }
  }

  private createGotchaTitle(anomaly: PerformanceAnomaly): string {
    switch (anomaly.type) {
      case 'slow_build':
        return `Slow build: ${anomaly.workflowName} took ${formatDuration(anomaly.currentValue)}`;
      case 'slow_step':
        return `Slow step in ${anomaly.workflowName}: ${anomaly.context?.stepName} took ${formatDuration(anomaly.currentValue)}`;
      case 'timeout':
        return `Workflow timeout: ${anomaly.workflowName}`;
      case 'flaky_test':
        return `Flaky test detected in ${anomaly.workflowName}`;
      case 'resource_exhaustion':
        return `Resource exhaustion in ${anomaly.workflowName}`;
      default:
        return `CI anomaly in ${anomaly.workflowName}: ${anomaly.message}`;
    }
  }

  private createGotchaTags(anomaly: PerformanceAnomaly): string {
    const tags = ['ci', anomaly.type, anomaly.severity];

    if (anomaly.repo) {
      tags.push(anomaly.repo.replace('/', '-'));
    }
    if (anomaly.context?.jobName) {
      tags.push(this.slugify(anomaly.context.jobName));
    }

    return tags.join(',');
  }

  /**
   * Sanitize string for shell command
   */
  private sanitize(str: string): string {
    return str
      .replace(/"/g, '\\"')
      .replace(/\$/g, '\\$')
      .replace(/`/g, '\\`')
      .replace(/\n/g, ' ')
      .replace(/\r/g, '')
      .substring(0, 250);
  }

  /**
   * Create a slug from string
   */
  private slugify(str: string): string {
    return str
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/^-|-$/g, '')
      .substring(0, 50);
  }

  private log(message: string): void {
    if (this.options.verbose) {
      console.log(`[GUA CI Reporter] ${message}`);
    }
  }

  // ==========================================================================
  // Knowledge Entry Creation
  // ==========================================================================

  /**
   * Create a knowledge entry for manual storage
   */
  createKnowledgeEntry(event: CIEvent, challengeId?: string): CIKnowledgeEntry {
    return {
      knowledge_type: 'ci_event',
      knowledge_id: this.createAreaId(event),
      repo: event.repo,
      workflow_name: event.workflowName,
      branch: event.branch,
      event_type: event.eventType,
      duration_ms: event.duration,
      error: event.error,
      challenge_id: challengeId,
      pp_dimension: event.ppDimension,
      timestamp: event.timestamp.toISOString(),
    };
  }
}

// ============================================================================
// Factory Function
// ============================================================================

export function createGUACIReporter(options?: GUACIReporterOptions): GUACIReporter {
  return new GUACIReporter(options);
}
