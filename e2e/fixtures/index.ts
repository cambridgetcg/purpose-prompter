/**
 * E2E Fixtures Index
 * Re-exports all fixtures for convenient import
 */

// Base fixtures with log capture
export { test, expect, testWithLogs } from './base';

// Extended fixtures with log correlation
export {
  test as testWithLogCorrelation,
  formatLogs,
  groupLogsByRequest,
  getErrorSummary
} from './log-collector';
