/**
 * GUA Reporter for Playwright
 * Automatically logs test failures as CPT challenges and flaky tests as gotchas
 */

import type {
  Reporter,
  TestCase,
  TestResult,
  FullResult,
  Suite
} from '@playwright/test/reporter';
import { execSync, spawnSync } from 'child_process';
import * as path from 'path';

interface TestFailure {
  testTitle: string;
  testFile: string;
  error: string;
  logs: string[];
  duration: number;
  retries: number;
  projectName?: string;
}

interface TestFlaky {
  testTitle: string;
  testFile: string;
  retriesNeeded: number;
}

export default class GUAReporter implements Reporter {
  private failures: TestFailure[] = [];
  private flakyTests: TestFlaky[] = [];
  private testCount = 0;
  private passCount = 0;
  private failCount = 0;
  private skipCount = 0;
  private startTime: Date = new Date();

  /**
   * Check if GUA CLI is available
   */
  private guaAvailable(): boolean {
    try {
      const result = spawnSync('bash', ['-c', '~/.gua/gua.sh --help'], {
        encoding: 'utf-8',
        timeout: 5000
      });
      return result.status === 0;
    } catch {
      return false;
    }
  }

  onBegin(config: any, suite: Suite): void {
    this.startTime = new Date();
    this.testCount = suite.allTests().length;
    console.log(`\n[GUA Reporter] Starting ${this.testCount} tests`);
  }

  onTestEnd(test: TestCase, result: TestResult): void {
    const testFile = path.relative(process.cwd(), test.location.file);

    if (result.status === 'passed') {
      this.passCount++;

      // Check for flaky tests (passed on retry)
      if (result.retry > 0) {
        this.flakyTests.push({
          testTitle: test.title,
          testFile,
          retriesNeeded: result.retry
        });
      }
    } else if (result.status === 'failed') {
      this.failCount++;

      // Collect failure details
      this.failures.push({
        testTitle: test.title,
        testFile,
        error: result.error?.message || 'Unknown error',
        logs: this.extractLogs(result),
        duration: result.duration,
        retries: result.retry,
        projectName: test.parent?.project()?.name
      });
    } else if (result.status === 'skipped') {
      this.skipCount++;
    }
  }

  private extractLogs(result: TestResult): string[] {
    const logs: string[] = [];

    // Get collected-logs attachment if present
    for (const attachment of result.attachments) {
      if (attachment.name === 'collected-logs' && attachment.body) {
        logs.push(attachment.body.toString());
      }
    }

    // Get stdout/stderr
    if (result.stdout.length > 0) {
      logs.push(`STDOUT:\n${result.stdout.join('\n')}`);
    }
    if (result.stderr.length > 0) {
      logs.push(`STDERR:\n${result.stderr.join('\n')}`);
    }

    return logs;
  }

  async onEnd(result: FullResult): Promise<void> {
    const duration = Date.now() - this.startTime.getTime();

    console.log('\n[GUA Reporter] Test run complete');
    console.log(`  Total: ${this.testCount}`);
    console.log(`  Passed: ${this.passCount}`);
    console.log(`  Failed: ${this.failCount}`);
    console.log(`  Skipped: ${this.skipCount}`);
    console.log(`  Flaky: ${this.flakyTests.length}`);
    console.log(`  Duration: ${Math.round(duration / 1000)}s`);

    if (!this.guaAvailable()) {
      console.log('\n[GUA Reporter] GUA CLI not available, skipping knowledge capture');
      return;
    }

    // Log failures as CPT challenges
    if (this.failures.length > 0) {
      console.log(`\n[GUA Reporter] Logging ${this.failures.length} failures as challenges...`);
      for (const failure of this.failures) {
        await this.logChallenge(failure);
      }
    }

    // Log flaky tests as gotchas
    if (this.flakyTests.length > 0) {
      console.log(`\n[GUA Reporter] Logging ${this.flakyTests.length} flaky tests as gotchas...`);
      for (const flaky of this.flakyTests) {
        await this.logGotcha(flaky);
      }
    }

    // Summary
    if (result.status === 'passed' && this.failures.length === 0) {
      console.log('\n[GUA Reporter] All tests passed - no GUA entries created');
    }
  }

  private async logChallenge(failure: TestFailure): Promise<void> {
    const platform = this.detectPlatform(failure.testFile);
    const areaId = `e2e#${this.slugify(failure.testFile)}`;

    // Build description
    const description = [
      `E2E Test Failure: ${failure.testTitle}`,
      `File: ${failure.testFile}`,
      `Error: ${failure.error}`,
      failure.retries > 0 ? `Retries: ${failure.retries}` : '',
      failure.duration ? `Duration: ${failure.duration}ms` : ''
    ].filter(Boolean).join(' | ');

    try {
      // Create challenge via GUA CLI
      const cmd = `~/.gua/gua.sh challenge log "${areaId}" "${this.sanitize(description)}" truth bug`;

      execSync(cmd, {
        shell: '/bin/bash',
        stdio: 'pipe',
        timeout: 10000
      });

      console.log(`  [GUA] Logged challenge: ${failure.testTitle}`);
    } catch (error: any) {
      // Don't fail the test run if GUA logging fails
      console.error(`  [GUA] Failed to log challenge: ${error.message}`);
    }
  }

  private async logGotcha(flaky: TestFlaky): Promise<void> {
    const title = `Flaky test: ${flaky.testTitle} (needed ${flaky.retriesNeeded} retries)`;

    try {
      const cmd = `~/.gua/gua.sh dev add general testing gotcha "${this.sanitize(title)}" --tags "e2e,flaky,${this.slugify(flaky.testFile)}"`;

      execSync(cmd, {
        shell: '/bin/bash',
        stdio: 'pipe',
        timeout: 10000
      });

      console.log(`  [GUA] Logged flaky test: ${flaky.testTitle}`);
    } catch (error: any) {
      console.error(`  [GUA] Failed to log gotcha: ${error.message}`);
    }
  }

  /**
   * Detect platform from test file path
   */
  private detectPlatform(testFile: string): string {
    const lower = testFile.toLowerCase();

    if (lower.includes('shopify')) return 'shopify';
    if (lower.includes('vercel')) return 'vercel';
    if (lower.includes('nextjs') || lower.includes('next')) return 'nextjs';
    if (lower.includes('react')) return 'react';
    if (lower.includes('aws')) return 'aws';
    if (lower.includes('prisma')) return 'prisma';

    return 'general';
  }

  /**
   * Sanitize string for shell command
   */
  private sanitize(str: string): string {
    return str
      .replace(/"/g, '\\"')       // Escape double quotes
      .replace(/\$/g, '\\$')      // Escape dollar signs
      .replace(/`/g, '\\`')       // Escape backticks
      .replace(/\n/g, ' ')        // Replace newlines
      .replace(/\r/g, '')         // Remove carriage returns
      .substring(0, 200);         // Limit length
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
}

/**
 * Export factory function for Playwright config
 */
export function createGUAReporter(): Reporter {
  return new GUAReporter();
}
