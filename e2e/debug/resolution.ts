/**
 * Debug Resolution Helpers
 * Utilities for resolving test failures and capturing learnings
 */

import { execSync, spawnSync } from 'child_process';

export interface ResolutionOptions {
  /** Platform (shopify, vercel, nextjs, etc.) */
  platform: string;
  /** Domain (auth, api, testing, etc.) */
  domain: string;
  /** Dev knowledge type */
  devType?: 'pattern' | 'gotcha' | 'error_fix' | 'recipe' | 'config';
  /** Promote to dev knowledge */
  promote?: boolean;
  /** Additional tags */
  tags?: string[];
}

/**
 * Resolve a challenge with optional learning capture
 */
export async function resolveChallenge(
  challengeId: string,
  resolution: string,
  options?: Partial<ResolutionOptions>
): Promise<{ success: boolean; error?: string }> {
  try {
    // Resolve the challenge
    const resolveCmd = `~/.gua/gua.sh challenge resolve "${challengeId}" "${sanitize(resolution)}"`;

    execSync(resolveCmd, {
      shell: '/bin/bash',
      stdio: 'pipe',
      timeout: 10000
    });

    console.log(`[Resolution] Challenge resolved: ${challengeId}`);

    // Promote to dev knowledge if requested
    if (options?.promote && options.platform && options.domain) {
      const promoteCmd = `~/.gua/gua.sh dev promote "${challengeId}" --platform ${options.platform} --domain ${options.domain}`;

      execSync(promoteCmd, {
        shell: '/bin/bash',
        stdio: 'pipe',
        timeout: 10000
      });

      console.log(`[Resolution] Promoted to dev knowledge`);
    }

    return { success: true };
  } catch (error: any) {
    return { success: false, error: error.message };
  }
}

/**
 * Add dev knowledge directly (without going through challenge)
 */
export async function addDevKnowledge(
  title: string,
  options: ResolutionOptions & { code?: string; errorCodes?: string[] }
): Promise<{ success: boolean; error?: string }> {
  try {
    let cmd = `~/.gua/gua.sh dev add ${options.platform} ${options.domain} ${options.devType || 'pattern'} "${sanitize(title)}"`;

    if (options.code) {
      cmd += ` --code "${sanitize(options.code)}"`;
    }

    if (options.tags && options.tags.length > 0) {
      cmd += ` --tags "${options.tags.join(',')}"`;
    }

    if (options.errorCodes && options.errorCodes.length > 0) {
      cmd += ` --error "${options.errorCodes.join(',')}"`;
    }

    execSync(cmd, {
      shell: '/bin/bash',
      stdio: 'pipe',
      timeout: 10000
    });

    console.log(`[Resolution] Added dev knowledge: ${title}`);
    return { success: true };
  } catch (error: any) {
    return { success: false, error: error.message };
  }
}

/**
 * Common fix templates for E2E issues
 */
export const commonFixes = {
  /**
   * Timeout issues
   */
  timeout: (context: string) => ({
    resolution: `Increased timeout for ${context}`,
    devType: 'config' as const,
    domain: 'testing',
    platform: 'general',
    tags: ['timeout', 'e2e']
  }),

  /**
   * Flaky test fixes
   */
  flaky: (context: string) => ({
    resolution: `Added waitForSelector/stability check for ${context}`,
    devType: 'pattern' as const,
    domain: 'testing',
    platform: 'general',
    tags: ['flaky', 'e2e', 'stability']
  }),

  /**
   * API error handling
   */
  apiError: (statusCode: number, context: string) => ({
    resolution: `Handle ${statusCode} response for ${context}`,
    devType: 'error_fix' as const,
    domain: 'api',
    platform: 'general',
    tags: ['api', `http-${statusCode}`]
  }),

  /**
   * Selector issues
   */
  selector: (oldSelector: string, newSelector: string) => ({
    resolution: `Changed selector from '${oldSelector}' to '${newSelector}'`,
    devType: 'pattern' as const,
    domain: 'testing',
    platform: 'general',
    tags: ['selector', 'e2e']
  }),

  /**
   * Race condition fixes
   */
  raceCondition: (context: string) => ({
    resolution: `Fixed race condition in ${context} by adding proper synchronization`,
    devType: 'pattern' as const,
    domain: 'testing',
    platform: 'general',
    tags: ['race-condition', 'e2e', 'async']
  }),

  /**
   * Authentication issues
   */
  auth: (context: string) => ({
    resolution: `Fixed authentication issue in ${context}`,
    devType: 'error_fix' as const,
    domain: 'auth',
    platform: 'general',
    tags: ['auth', 'e2e', 'session']
  }),

  /**
   * Network issues
   */
  network: (context: string) => ({
    resolution: `Added retry/fallback for network issue in ${context}`,
    devType: 'pattern' as const,
    domain: 'api',
    platform: 'general',
    tags: ['network', 'retry', 'e2e']
  }),

  /**
   * State management issues
   */
  state: (context: string) => ({
    resolution: `Fixed state management issue in ${context}`,
    devType: 'pattern' as const,
    domain: 'testing',
    platform: 'general',
    tags: ['state', 'e2e']
  })
};

/**
 * Get related challenges for a test file
 */
export async function getRelatedChallenges(testFile: string): Promise<string[]> {
  try {
    const result = spawnSync('bash', [
      '-c',
      `~/.gua/gua.sh challenge list --status open 2>/dev/null | grep -i "${testFile}" || true`
    ], {
      encoding: 'utf-8',
      timeout: 10000
    });

    if (result.stdout) {
      return result.stdout.trim().split('\n').filter(Boolean);
    }
    return [];
  } catch {
    return [];
  }
}

/**
 * Get related dev knowledge for a topic
 */
export async function getRelatedKnowledge(topic: string): Promise<string[]> {
  try {
    const result = spawnSync('bash', [
      '-c',
      `~/.gua/gua.sh dev search "${topic}" 2>/dev/null || true`
    ], {
      encoding: 'utf-8',
      timeout: 10000
    });

    if (result.stdout) {
      return result.stdout.trim().split('\n').filter(Boolean);
    }
    return [];
  } catch {
    return [];
  }
}

/**
 * Sanitize string for shell command
 */
function sanitize(str: string): string {
  return str
    .replace(/"/g, '\\"')
    .replace(/\$/g, '\\$')
    .replace(/`/g, '\\`')
    .replace(/\n/g, ' ')
    .substring(0, 200);
}

/**
 * Interactive resolution helper
 * Guides through the resolution process
 */
export function createResolutionGuide(failure: {
  testTitle: string;
  testFile: string;
  error: string;
}): {
  suggestedFix: ReturnType<typeof commonFixes.timeout>;
  steps: string[];
  commands: string[];
} {
  const error = failure.error.toLowerCase();
  let suggestedFix: ReturnType<typeof commonFixes.timeout>;
  const steps: string[] = [];
  const commands: string[] = [];

  // Detect issue type and suggest fix
  if (error.includes('timeout') || error.includes('exceeded')) {
    suggestedFix = commonFixes.timeout(failure.testTitle);
    steps.push('1. Check if the element selector is correct');
    steps.push('2. Increase the timeout value');
    steps.push('3. Add explicit waits before the action');
  } else if (error.includes('not found') || error.includes('no element')) {
    suggestedFix = commonFixes.selector('old-selector', 'new-selector');
    steps.push('1. Verify the selector matches current DOM');
    steps.push('2. Use more specific/stable selectors (data-testid)');
    steps.push('3. Add waitForSelector before interaction');
  } else if (error.includes('401') || error.includes('403') || error.includes('unauthorized')) {
    suggestedFix = commonFixes.auth(failure.testTitle);
    steps.push('1. Check authentication state');
    steps.push('2. Ensure test user has correct permissions');
    steps.push('3. Verify session/token is valid');
  } else if (error.includes('500') || error.includes('502') || error.includes('503')) {
    suggestedFix = commonFixes.apiError(500, failure.testTitle);
    steps.push('1. Check server logs for error details');
    steps.push('2. Verify test data is valid');
    steps.push('3. Add retry logic for transient errors');
  } else {
    suggestedFix = commonFixes.flaky(failure.testTitle);
    steps.push('1. Run test in headed mode to observe behavior');
    steps.push('2. Check for race conditions');
    steps.push('3. Add stabilization waits');
  }

  // Generate resolution commands
  const challengeId = `challenge#e2e#${failure.testFile.replace(/[^a-z0-9]/gi, '-').toLowerCase()}`;

  commands.push(`# View challenge details`);
  commands.push(`~/.gua/gua.sh challenge show "${challengeId}"`);
  commands.push('');
  commands.push(`# Resolve challenge`);
  commands.push(`~/.gua/gua.sh challenge resolve "${challengeId}" "${suggestedFix.resolution}"`);
  commands.push('');
  commands.push(`# Promote to dev knowledge`);
  commands.push(`~/.gua/gua.sh dev promote "${challengeId}" --platform ${suggestedFix.platform} --domain ${suggestedFix.domain}`);

  return { suggestedFix, steps, commands };
}
