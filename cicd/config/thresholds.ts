/**
 * CI/CD Performance Thresholds
 * Configurable thresholds for anomaly detection
 */

import type { AnomalyThresholds, Severity } from '../adapters/types';

// ============================================================================
// Default Thresholds
// ============================================================================

export const defaultThresholds: AnomalyThresholds = {
  // Build time thresholds (milliseconds)
  build_time: {
    warning: 5 * 60 * 1000,    // 5 minutes
    critical: 10 * 60 * 1000,  // 10 minutes
  },

  // Individual step time thresholds (milliseconds)
  step_time: {
    warning: 2 * 60 * 1000,    // 2 minutes
    critical: 5 * 60 * 1000,   // 5 minutes
  },

  // Failure rate thresholds (percentage as decimal)
  failure_rate: {
    warning: 0.10,  // 10%
    critical: 0.25, // 25%
  },
};

// ============================================================================
// Extended Thresholds (for comprehensive monitoring)
// ============================================================================

export interface ExtendedThresholds extends AnomalyThresholds {
  // Queue time (waiting for runner)
  queue_time: { warning: number; critical: number };

  // Artifact size
  artifact_size: { warning: number; critical: number };

  // Consecutive failures
  consecutive_failures: { warning: number; critical: number };

  // Flaky test rate
  flaky_rate: { warning: number; critical: number };
}

export const extendedThresholds: ExtendedThresholds = {
  ...defaultThresholds,

  // Queue time thresholds (milliseconds)
  queue_time: {
    warning: 5 * 60 * 1000,    // 5 minutes
    critical: 15 * 60 * 1000,  // 15 minutes
  },

  // Artifact size thresholds (bytes)
  artifact_size: {
    warning: 500 * 1024 * 1024,  // 500 MB
    critical: 1024 * 1024 * 1024, // 1 GB
  },

  // Consecutive failures count
  consecutive_failures: {
    warning: 3,
    critical: 5,
  },

  // Flaky test rate (percentage as decimal)
  flaky_rate: {
    warning: 0.05,  // 5%
    critical: 0.15, // 15%
  },
};

// ============================================================================
// Threshold Utilities
// ============================================================================

/**
 * Determine severity based on value and thresholds
 */
export function getSeverity(
  value: number,
  thresholds: { warning: number; critical: number },
  lowerIsBetter = false
): Severity | null {
  if (lowerIsBetter) {
    // For rates/percentages where lower is better
    if (value >= thresholds.critical) return 'critical';
    if (value >= thresholds.warning) return 'high';
    return null;
  } else {
    // For times/sizes where lower is better (default)
    if (value >= thresholds.critical) return 'critical';
    if (value >= thresholds.warning) return 'high';
    return null;
  }
}

/**
 * Check if value exceeds warning threshold
 */
export function isWarning(
  value: number,
  thresholds: { warning: number; critical: number }
): boolean {
  return value >= thresholds.warning && value < thresholds.critical;
}

/**
 * Check if value exceeds critical threshold
 */
export function isCritical(
  value: number,
  thresholds: { warning: number; critical: number }
): boolean {
  return value >= thresholds.critical;
}

/**
 * Format duration in human-readable format
 */
export function formatDuration(ms: number): string {
  if (ms < 1000) return `${ms}ms`;
  if (ms < 60000) return `${(ms / 1000).toFixed(1)}s`;
  if (ms < 3600000) return `${(ms / 60000).toFixed(1)}m`;
  return `${(ms / 3600000).toFixed(1)}h`;
}

/**
 * Format size in human-readable format
 */
export function formatSize(bytes: number): string {
  if (bytes < 1024) return `${bytes}B`;
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)}KB`;
  if (bytes < 1024 * 1024 * 1024) return `${(bytes / 1024 / 1024).toFixed(1)}MB`;
  return `${(bytes / 1024 / 1024 / 1024).toFixed(1)}GB`;
}

/**
 * Format percentage
 */
export function formatPercent(value: number): string {
  return `${(value * 100).toFixed(1)}%`;
}

// ============================================================================
// Configuration Loading
// ============================================================================

/**
 * Load thresholds from environment or config file
 */
export function loadThresholds(configPath?: string): AnomalyThresholds {
  const thresholds = { ...defaultThresholds };

  // Override from environment variables
  if (process.env.CI_THRESHOLD_BUILD_TIME) {
    const value = parseInt(process.env.CI_THRESHOLD_BUILD_TIME, 10);
    if (!isNaN(value)) {
      thresholds.build_time.critical = value;
      thresholds.build_time.warning = Math.floor(value * 0.5);
    }
  }

  if (process.env.CI_THRESHOLD_STEP_TIME) {
    const value = parseInt(process.env.CI_THRESHOLD_STEP_TIME, 10);
    if (!isNaN(value)) {
      thresholds.step_time.critical = value;
      thresholds.step_time.warning = Math.floor(value * 0.4);
    }
  }

  if (process.env.CI_THRESHOLD_FAILURE_RATE) {
    const value = parseFloat(process.env.CI_THRESHOLD_FAILURE_RATE);
    if (!isNaN(value)) {
      thresholds.failure_rate.critical = value;
      thresholds.failure_rate.warning = value * 0.4;
    }
  }

  // Load from config file if specified
  if (configPath) {
    try {
      // eslint-disable-next-line @typescript-eslint/no-require-imports
      const config = require(configPath);
      if (config.thresholds) {
        Object.assign(thresholds, config.thresholds);
      }
    } catch (error) {
      console.warn(`[Thresholds] Could not load config from ${configPath}:`, error);
    }
  }

  return thresholds;
}
