/**
 * Build Metrics Collector
 * Collects and aggregates CI/CD build metrics
 */

import type {
  CIAdapter,
  WorkflowRun,
  BuildMetrics,
  WorkflowQueryOptions,
} from '../adapters/types';
import { formatDuration, formatPercent } from '../config/thresholds';

// ============================================================================
// Types
// ============================================================================

export interface MetricsCollectorOptions {
  adapter: CIAdapter;
  repo?: string;
}

export interface MetricsQuery {
  repo?: string;
  workflow?: string;
  branch?: string;
  periodDays?: number;
  limit?: number;
}

export interface MetricsSummary {
  metrics: BuildMetrics;
  trends: {
    successRateTrend: 'improving' | 'declining' | 'stable';
    durationTrend: 'improving' | 'declining' | 'stable';
  };
  topIssues: Array<{
    type: string;
    count: number;
    description: string;
  }>;
}

// ============================================================================
// Metrics Collector
// ============================================================================

export class BuildMetricsCollector {
  private adapter: CIAdapter;
  private defaultRepo?: string;

  constructor(options: MetricsCollectorOptions) {
    this.adapter = options.adapter;
    this.defaultRepo = options.repo;
  }

  /**
   * Collect metrics for a repository/workflow
   */
  async collect(query: MetricsQuery = {}): Promise<BuildMetrics> {
    const repo = query.repo || this.defaultRepo;
    if (!repo) {
      throw new Error('Repository not specified');
    }

    const periodDays = query.periodDays || 7;
    const createdAfter = new Date();
    createdAfter.setDate(createdAfter.getDate() - periodDays);

    // Fetch workflow runs
    const options: WorkflowQueryOptions = {
      repo,
      workflow: query.workflow,
      branch: query.branch,
      createdAfter,
      limit: query.limit || 100,
    };

    const runs = await this.adapter.getWorkflowRuns(options);

    // Calculate metrics
    return this.calculateMetrics(runs, repo, query.workflow || 'all', {
      start: createdAfter,
      end: new Date(),
    });
  }

  /**
   * Get metrics summary with trends and insights
   */
  async getSummary(query: MetricsQuery = {}): Promise<MetricsSummary> {
    const metrics = await this.collect(query);

    // Calculate trends by comparing first half to second half of period
    const trends = await this.calculateTrends(query);

    // Identify top issues
    const topIssues = this.identifyTopIssues(metrics);

    return {
      metrics,
      trends,
      topIssues,
    };
  }

  /**
   * Get metrics for multiple workflows
   */
  async collectAll(query: Omit<MetricsQuery, 'workflow'> = {}): Promise<Map<string, BuildMetrics>> {
    const repo = query.repo || this.defaultRepo;
    if (!repo) {
      throw new Error('Repository not specified');
    }

    const periodDays = query.periodDays || 7;
    const createdAfter = new Date();
    createdAfter.setDate(createdAfter.getDate() - periodDays);

    // Fetch all runs
    const runs = await this.adapter.getWorkflowRuns({
      repo,
      branch: query.branch,
      createdAfter,
      limit: query.limit || 200,
    });

    // Group by workflow
    const byWorkflow = new Map<string, WorkflowRun[]>();
    for (const run of runs) {
      if (!byWorkflow.has(run.name)) {
        byWorkflow.set(run.name, []);
      }
      byWorkflow.get(run.name)!.push(run);
    }

    // Calculate metrics for each workflow
    const result = new Map<string, BuildMetrics>();
    for (const [workflow, workflowRuns] of byWorkflow) {
      const metrics = this.calculateMetrics(workflowRuns, repo, workflow, {
        start: createdAfter,
        end: new Date(),
      });
      result.set(workflow, metrics);
    }

    return result;
  }

  // ==========================================================================
  // Calculation Helpers
  // ==========================================================================

  private calculateMetrics(
    runs: WorkflowRun[],
    repo: string,
    workflow: string,
    period: { start: Date; end: Date }
  ): BuildMetrics {
    const completedRuns = runs.filter(r => r.status === 'completed');

    const successful = completedRuns.filter(r => r.conclusion === 'success');
    const failed = completedRuns.filter(r => r.conclusion === 'failure');
    const cancelled = completedRuns.filter(r => r.conclusion === 'cancelled');

    // Duration calculations
    const durations = successful
      .map(r => r.duration)
      .filter((d): d is number => d !== undefined && d > 0);

    const sortedDurations = [...durations].sort((a, b) => a - b);

    const avgDuration = durations.length > 0
      ? durations.reduce((a, b) => a + b, 0) / durations.length
      : 0;

    const medianDuration = sortedDurations.length > 0
      ? sortedDurations[Math.floor(sortedDurations.length / 2)]
      : 0;

    const p95Index = Math.floor(sortedDurations.length * 0.95);
    const p95Duration = sortedDurations[p95Index] || sortedDurations[sortedDurations.length - 1] || 0;

    // Find longest run
    const longestRun = completedRuns.reduce<{ runId: string; duration: number; date: Date } | null>(
      (max, run) => {
        if (run.duration && (!max || run.duration > max.duration)) {
          return {
            runId: run.id,
            duration: run.duration,
            date: run.completedAt || run.updatedAt,
          };
        }
        return max;
      },
      null
    ) || { runId: '', duration: 0, date: new Date() };

    // Failures by job
    const failuresByJob: Record<string, number> = {};
    const failuresByStep: Record<string, number> = {};

    for (const run of failed) {
      for (const job of run.jobs) {
        if (job.conclusion === 'failure') {
          failuresByJob[job.name] = (failuresByJob[job.name] || 0) + 1;

          for (const step of job.steps) {
            if (step.conclusion === 'failure') {
              const key = `${job.name}/${step.name}`;
              failuresByStep[key] = (failuresByStep[key] || 0) + 1;
            }
          }
        }
      }
    }

    return {
      repo,
      workflow,
      period,
      totalRuns: completedRuns.length,
      successfulRuns: successful.length,
      failedRuns: failed.length,
      cancelledRuns: cancelled.length,
      successRate: completedRuns.length > 0
        ? successful.length / completedRuns.length
        : 0,
      avgDuration,
      medianDuration,
      p95Duration,
      longestRun,
      failuresByJob,
      failuresByStep,
    };
  }

  private async calculateTrends(query: MetricsQuery): Promise<MetricsSummary['trends']> {
    const periodDays = query.periodDays || 7;
    const halfPeriod = Math.floor(periodDays / 2);

    // Get metrics for first half and second half
    const now = new Date();
    const midpoint = new Date();
    midpoint.setDate(now.getDate() - halfPeriod);

    const recentQuery = { ...query, periodDays: halfPeriod };
    const olderQuery = {
      ...query,
      periodDays: halfPeriod,
      // Would need to modify collect to support date ranges
    };

    // Simplified: just return stable for now
    // Full implementation would compare two periods
    return {
      successRateTrend: 'stable',
      durationTrend: 'stable',
    };
  }

  private identifyTopIssues(metrics: BuildMetrics): MetricsSummary['topIssues'] {
    const issues: MetricsSummary['topIssues'] = [];

    // Low success rate
    if (metrics.successRate < 0.8 && metrics.totalRuns >= 5) {
      issues.push({
        type: 'low_success_rate',
        count: metrics.failedRuns,
        description: `Success rate is ${formatPercent(metrics.successRate)} (${metrics.failedRuns} failures out of ${metrics.totalRuns} runs)`,
      });
    }

    // Slow builds
    if (metrics.avgDuration > 10 * 60 * 1000) { // > 10 minutes
      issues.push({
        type: 'slow_builds',
        count: Math.floor(metrics.avgDuration / 60000),
        description: `Average build time is ${formatDuration(metrics.avgDuration)}`,
      });
    }

    // Frequent job failures
    const topFailingJobs = Object.entries(metrics.failuresByJob)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 3);

    for (const [job, count] of topFailingJobs) {
      if (count >= 3) {
        issues.push({
          type: 'frequent_job_failure',
          count,
          description: `Job "${job}" has failed ${count} times`,
        });
      }
    }

    return issues;
  }

  // ==========================================================================
  // Formatting Helpers
  // ==========================================================================

  /**
   * Format metrics as a report string
   */
  formatReport(metrics: BuildMetrics): string {
    const lines: string[] = [
      `=== Build Metrics: ${metrics.workflow} ===`,
      `Repository: ${metrics.repo}`,
      `Period: ${metrics.period.start.toLocaleDateString()} - ${metrics.period.end.toLocaleDateString()}`,
      '',
      `Total Runs:     ${metrics.totalRuns}`,
      `Successful:     ${metrics.successfulRuns}`,
      `Failed:         ${metrics.failedRuns}`,
      `Cancelled:      ${metrics.cancelledRuns}`,
      `Success Rate:   ${formatPercent(metrics.successRate)}`,
      '',
      `Avg Duration:   ${formatDuration(metrics.avgDuration)}`,
      `Median:         ${formatDuration(metrics.medianDuration)}`,
      `P95:            ${formatDuration(metrics.p95Duration)}`,
    ];

    if (metrics.longestRun.duration > 0) {
      lines.push(`Longest:        ${formatDuration(metrics.longestRun.duration)} (Run #${metrics.longestRun.runId})`);
    }

    if (Object.keys(metrics.failuresByJob).length > 0) {
      lines.push('', 'Top Failing Jobs:');
      const sorted = Object.entries(metrics.failuresByJob)
        .sort((a, b) => b[1] - a[1])
        .slice(0, 5);
      for (const [job, count] of sorted) {
        lines.push(`  ${count}x ${job}`);
      }
    }

    return lines.join('\n');
  }
}

// ============================================================================
// Factory
// ============================================================================

export function createMetricsCollector(options: MetricsCollectorOptions): BuildMetricsCollector {
  return new BuildMetricsCollector(options);
}
