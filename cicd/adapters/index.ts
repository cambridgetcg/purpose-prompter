/**
 * CI Adapter Factory
 * Creates platform-specific adapters
 */

import type { CIAdapter, AdapterFactory, AdapterRegistry } from './types';
import { createGitHubAdapter, GitHubActionsAdapter } from './github';
import { createGenericAdapter, GenericAdapter } from './generic';

// Re-export types
export * from './types';

// Re-export adapters
export { GitHubActionsAdapter, createGitHubAdapter } from './github';
export { GenericAdapter, createGenericAdapter } from './generic';

// ============================================================================
// Adapter Registry
// ============================================================================

const adapters: Map<string, AdapterFactory> = new Map([
  ['github', createGitHubAdapter],
  ['github-actions', createGitHubAdapter],
  ['generic', createGenericAdapter],
]);

export const adapterRegistry: AdapterRegistry = {
  register(name: string, factory: AdapterFactory): void {
    adapters.set(name.toLowerCase(), factory);
  },

  get(name: string): AdapterFactory | undefined {
    return adapters.get(name.toLowerCase());
  },

  list(): string[] {
    return Array.from(adapters.keys());
  },
};

// ============================================================================
// Factory Function
// ============================================================================

export interface CreateAdapterOptions {
  platform?: string;
  token?: string;
  repo?: string;
  baseUrl?: string;
  [key: string]: unknown;
}

/**
 * Create a CI adapter based on platform or environment
 */
export function createAdapter(options: CreateAdapterOptions = {}): CIAdapter {
  // Determine platform from options or environment
  const platform = (
    options.platform ||
    process.env.CI_PLATFORM ||
    detectPlatform()
  ).toLowerCase();

  // Get factory for platform
  const factory = adapters.get(platform);

  if (!factory) {
    console.warn(`[CI Adapter] Unknown platform '${platform}', falling back to generic`);
    return createGenericAdapter();
  }

  return factory(options);
}

/**
 * Auto-detect CI platform from environment
 */
function detectPlatform(): string {
  // GitHub Actions
  if (process.env.GITHUB_ACTIONS === 'true') {
    return 'github';
  }

  // GitLab CI
  if (process.env.GITLAB_CI === 'true') {
    return 'gitlab';
  }

  // CircleCI
  if (process.env.CIRCLECI === 'true') {
    return 'circleci';
  }

  // Jenkins
  if (process.env.JENKINS_URL) {
    return 'jenkins';
  }

  // Travis CI
  if (process.env.TRAVIS === 'true') {
    return 'travis';
  }

  // Vercel
  if (process.env.VERCEL === '1') {
    return 'vercel';
  }

  // Default to generic
  return 'generic';
}

// ============================================================================
// Convenience Exports
// ============================================================================

/** Get a GitHub Actions adapter */
export function getGitHubAdapter(options?: {
  token?: string;
  repo?: string;
}): CIAdapter {
  return createGitHubAdapter(options);
}

/** Get a generic adapter (for testing) */
export function getGenericAdapter(): CIAdapter {
  return createGenericAdapter();
}
