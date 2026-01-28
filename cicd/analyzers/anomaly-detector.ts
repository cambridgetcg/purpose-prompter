/**
 * CI/CD Anomaly Detector
 * Detects performance anomalies and issues in workflow runs
 */

import type {
  WorkflowRun,
  JobSummary,
  PerformanceAnomaly,
  AnomalyThresholds,
  Severity,
  AnomalyType,
} from '../adapters/types';
import {
  defaultThresholds,
  extendedThresholds,
  formatDuration,
  getSeverity,
  ExtendedThresholds,
} from '../config/thresholds';

// ============================================================================
// Types
// ============================================================================

export interface AnomalyDetectorOptions {
  thresholds?: AnomalyThresholds | ExtendedThresholds;
  enableHistoricalComparison?: boolean;
  historicalWindow?: number; // Number of runs to consider
}

export interface DetectionResult {
  anomalies: PerformanceAnomaly[];
  summary: {
    totalChecks: number;
    anomaliesFound: number;
    criticalCount: number;
    highCount: number;
    mediumCount: number;
    lowCount: number;
  };
}

interface RunHistory {
  durations: number[];
  avgDuration: number;
  p95Duration: number;
  failureRate: number;
}

// ============================================================================
// Anomaly Detector
// ============================================================================

export class AnomalyDetector {
  private thresholds: AnomalyThresholds | ExtendedThresholds;
  private options: AnomalyDetectorOptions;
  private history: Map<string, RunHistory> = new Map();

  constructor(options: AnomalyDetectorOptions = {}) {
    this.options = {
      enableHistoricalComparison: false,
      historicalWindow: 20,
      ...options,
    };
    this.thresholds = options.thresholds || defaultThresholds;
  }

  // ==========================================================================
  // Main Detection Methods
  // ==========================================================================

  /**
   * Analyze a workflow run for anomalies
   */
  analyze(run: WorkflowRun, repo: string): DetectionResult {
    const anomalies: PerformanceAnomaly[] = [];

    // Check build time
    anomalies.push(...this.checkBuildTime(run, repo));

    // Check individual job and step times
    anomalies.push(...this.checkJobTimes(run, repo));
    anomalies.push(...this.checkStepTimes(run, repo));

    // Check for timeout
    anomalies.push(...this.checkTimeout(run, repo));

    // Check for resource issues (from conclusion)
    anomalies.push(...this.checkResourceIssues(run, repo));

    // Historical comparison if enabled
    if (this.options.enableHistoricalComparison) {
      anomalies.push(...this.checkHistoricalDeviation(run, repo));
    }

    return {
      anomalies,
      summary: this.summarize(anomalies),
    };
  }

  /**
   * Analyze multiple runs for patterns
   */
  analyzeMultiple(runs: WorkflowRun[], repo: string): DetectionResult {
    const allAnomalies: PerformanceAnomaly[] = [];

    // Analyze each run
    for (const run of runs) {
      const result = this.analyze(run, repo);
      allAnomalies.push(...result.anomalies);
    }

    // Check for flaky tests (failures that pass on retry)
    allAnomalies.push(...this.checkFlakyPatterns(runs, repo));

    // Check failure rate
    allAnomalies.push(...this.checkFailureRate(runs, repo));

    return {
      anomalies: allAnomalies,
      summary: this.summarize(allAnomalies),
    };
  }

  // ==========================================================================
  // Individual Checks
  // ==========================================================================

  private checkBuildTime(run: WorkflowRun, repo: string): PerformanceAnomaly[] {
    const anomalies: PerformanceAnomaly[] = [];

    if (!run.duration) return anomalies;

    const severity = getSeverity(run.duration, this.thresholds.build_time);

    if (severity) {
      anomalies.push({
        type: 'slow_build',
        severity,
        workflowName: run.name,
        repo,
        branch: run.branch,
        runId: run.id,
        currentValue: run.duration,
        threshold: severity === 'critical'
          ? this.thresholds.build_time.critical
          : this.thresholds.build_time.warning,
        unit: 'ms',
        message: `Build took ${formatDuration(run.duration)} (threshold: ${formatDuration(
          severity === 'critical'
            ? this.thresholds.build_time.critical
            : this.thresholds.build_time.warning
        )})`,
        timestamp: new Date(),
      });
    }

    return anomalies;
  }

  private checkJobTimes(run: WorkflowRun, repo: string): PerformanceAnomaly[] {
    const anomalies: PerformanceAnomaly[] = [];

    for (const job of run.jobs) {
      if (!job.duration) continue;

      // Jobs get a 2x multiplier on step thresholds
      const jobThreshold = {
        warning: this.thresholds.step_time.warning * 2,
        critical: this.thresholds.step_time.critical * 2,
      };

      const severity = getSeverity(job.duration, jobThreshold);

      if (severity) {
        anomalies.push({
          type: 'slow_step',
          severity,
          workflowName: run.name,
          repo,
          branch: run.branch,
          runId: run.id,
          currentValue: job.duration,
          threshold: severity === 'critical' ? jobThreshold.critical : jobThreshold.warning,
          unit: 'ms',
          message: `Job "${job.name}" took ${formatDuration(job.duration)}`,
          timestamp: new Date(),
          context: {
            jobName: job.name,
          },
        });
      }
    }

    return anomalies;
  }

  private checkStepTimes(run: WorkflowRun, repo: string): PerformanceAnomaly[] {
    const anomalies: PerformanceAnomaly[] = [];

    for (const job of run.jobs) {
      for (const step of job.steps) {
        if (!step.duration) continue;

        const severity = getSeverity(step.duration, this.thresholds.step_time);

        if (severity) {
          anomalies.push({
            type: 'slow_step',
            severity,
            workflowName: run.name,
            repo,
            branch: run.branch,
            runId: run.id,
            currentValue: step.duration,
            threshold: severity === 'critical'
              ? this.thresholds.step_time.critical
              : this.thresholds.step_time.warning,
            unit: 'ms',
            message: `Step "${step.name}" in "${job.name}" took ${formatDuration(step.duration)}`,
            timestamp: new Date(),
            context: {
              jobName: job.name,
              stepName: step.name,
            },
          });
        }
      }
    }

    return anomalies;
  }

  private checkTimeout(run: WorkflowRun, repo: string): PerformanceAnomaly[] {
    if (run.conclusion !== 'timed_out') return [];

    return [{
      type: 'timeout',
      severity: 'critical',
      workflowName: run.name,
      repo,
      branch: run.branch,
      runId: run.id,
      currentValue: run.duration || 0,
      threshold: 0,
      unit: 'ms',
      message: `Workflow timed out${run.duration ? ` after ${formatDuration(run.duration)}` : ''}`,
      timestamp: new Date(),
    }];
  }

  private checkResourceIssues(run: WorkflowRun, repo: string): PerformanceAnomaly[] {
    const anomalies: PerformanceAnomaly[] = [];

    // Check for resource-related failures
    for (const job of run.jobs) {
      if (job.conclusion === 'failure') {
        // Check step names for resource hints
        for (const step of job.steps) {
          if (step.conclusion === 'failure') {
            const name = step.name.toLowerCase();
            if (
              name.includes('memory') ||
              name.includes('disk') ||
              name.includes('quota') ||
              name.includes('resource')
            ) {
              anomalies.push({
                type: 'resource_exhaustion',
                severity: 'high',
                workflowName: run.name,
                repo,
                branch: run.branch,
                runId: run.id,
                currentValue: 0,
                threshold: 0,
                unit: '',
                message: `Possible resource exhaustion in "${step.name}"`,
                timestamp: new Date(),
                context: {
                  jobName: job.name,
                  stepName: step.name,
                },
              });
            }
          }
        }
      }
    }

    return anomalies;
  }

  private checkHistoricalDeviation(run: WorkflowRun, repo: string): PerformanceAnomaly[] {
    const anomalies: PerformanceAnomaly[] = [];

    if (!run.duration) return anomalies;

    const historyKey = `${repo}:${run.name}`;
    const history = this.history.get(historyKey);

    if (history && history.durations.length >= 5) {
      // Check if current run is significantly slower than average
      const deviation = run.duration / history.avgDuration;

      if (deviation > 2.0) {
        anomalies.push({
          type: 'slow_build',
          severity: deviation > 3.0 ? 'high' : 'medium',
          workflowName: run.name,
          repo,
          branch: run.branch,
          runId: run.id,
          currentValue: run.duration,
          threshold: history.avgDuration,
          unit: 'ms',
          message: `Build ${(deviation * 100 - 100).toFixed(0)}% slower than average (${formatDuration(run.duration)} vs ${formatDuration(history.avgDuration)})`,
          timestamp: new Date(),
          context: {
            avgValue: history.avgDuration,
          },
        });
      }
    }

    return anomalies;
  }

  private checkFlakyPatterns(runs: WorkflowRun[], repo: string): PerformanceAnomaly[] {
    const anomalies: PerformanceAnomaly[] = [];

    // Group by branch and workflow
    const grouped = new Map<string, WorkflowRun[]>();
    for (const run of runs) {
      const key = `${run.name}:${run.branch}`;
      if (!grouped.has(key)) {
        grouped.set(key, []);
      }
      grouped.get(key)!.push(run);
    }

    // Check for flaky patterns (failure followed by success on same commit)
    for (const [key, groupRuns] of grouped) {
      const sortedRuns = groupRuns.sort(
        (a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()
      );

      for (let i = 0; i < sortedRuns.length - 1; i++) {
        const current = sortedRuns[i];
        const previous = sortedRuns[i + 1];

        if (
          current.conclusion === 'success' &&
          previous.conclusion === 'failure' &&
          current.commitSha === previous.commitSha
        ) {
          anomalies.push({
            type: 'flaky_test',
            severity: 'medium',
            workflowName: current.name,
            repo,
            branch: current.branch,
            runId: previous.id,
            currentValue: 1,
            threshold: 0,
            unit: 'occurrences',
            message: `Flaky: ${current.name} failed then passed on commit ${current.commitSha.slice(0, 8)}`,
            timestamp: new Date(),
          });
        }
      }
    }

    return anomalies;
  }

  private checkFailureRate(runs: WorkflowRun[], repo: string): PerformanceAnomaly[] {
    const anomalies: PerformanceAnomaly[] = [];

    // Group by workflow
    const grouped = new Map<string, WorkflowRun[]>();
    for (const run of runs) {
      if (!grouped.has(run.name)) {
        grouped.set(run.name, []);
      }
      grouped.get(run.name)!.push(run);
    }

    for (const [workflowName, workflowRuns] of grouped) {
      const total = workflowRuns.length;
      const failures = workflowRuns.filter(r => r.conclusion === 'failure').length;
      const failureRate = failures / total;

      const severity = getSeverity(failureRate, this.thresholds.failure_rate);

      if (severity && total >= 5) {
        anomalies.push({
          type: 'flaky_test',
          severity,
          workflowName,
          repo,
          branch: 'all',
          runId: workflowRuns[0].id,
          currentValue: failureRate,
          threshold: severity === 'critical'
            ? this.thresholds.failure_rate.critical
            : this.thresholds.failure_rate.warning,
          unit: 'rate',
          message: `High failure rate: ${workflowName} has ${(failureRate * 100).toFixed(1)}% failure rate (${failures}/${total})`,
          timestamp: new Date(),
        });
      }
    }

    return anomalies;
  }

  // ==========================================================================
  // History Management
  // ==========================================================================

  /**
   * Update history with a completed run
   */
  updateHistory(run: WorkflowRun, repo: string): void {
    if (!run.duration || run.status !== 'completed') return;

    const historyKey = `${repo}:${run.name}`;
    let history = this.history.get(historyKey);

    if (!history) {
      history = {
        durations: [],
        avgDuration: 0,
        p95Duration: 0,
        failureRate: 0,
      };
      this.history.set(historyKey, history);
    }

    // Add to durations (keep window size)
    history.durations.push(run.duration);
    if (history.durations.length > (this.options.historicalWindow || 20)) {
      history.durations.shift();
    }

    // Recalculate stats
    history.avgDuration = history.durations.reduce((a, b) => a + b, 0) / history.durations.length;

    const sorted = [...history.durations].sort((a, b) => a - b);
    const p95Index = Math.floor(sorted.length * 0.95);
    history.p95Duration = sorted[p95Index] || sorted[sorted.length - 1];
  }

  /**
   * Get history for a workflow
   */
  getHistory(repo: string, workflowName: string): RunHistory | undefined {
    return this.history.get(`${repo}:${workflowName}`);
  }

  // ==========================================================================
  // Helpers
  // ==========================================================================

  private summarize(anomalies: PerformanceAnomaly[]): DetectionResult['summary'] {
    return {
      totalChecks: anomalies.length > 0 ? 1 : 0, // Simplified
      anomaliesFound: anomalies.length,
      criticalCount: anomalies.filter(a => a.severity === 'critical').length,
      highCount: anomalies.filter(a => a.severity === 'high').length,
      mediumCount: anomalies.filter(a => a.severity === 'medium').length,
      lowCount: anomalies.filter(a => a.severity === 'low').length,
    };
  }
}

// ============================================================================
// Factory
// ============================================================================

export function createAnomalyDetector(options?: AnomalyDetectorOptions): AnomalyDetector {
  return new AnomalyDetector(options);
}
