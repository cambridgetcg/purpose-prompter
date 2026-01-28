/**
 * Platform Adapter Factory
 * Creates the appropriate adapter based on environment configuration
 */

import { PlatformAdapter } from './types';
import { GenericAdapter } from './generic';
import { VercelAdapter } from './vercel';
import { AWSAdapter } from './aws';

export { PlatformAdapter, LogEntry, LogQueryOptions, DeploymentInfo, TestContext, LogCorrelation } from './types';
export { GenericAdapter } from './generic';
export { VercelAdapter } from './vercel';
export { AWSAdapter } from './aws';

type AdapterType = 'vercel' | 'aws' | 'generic' | 'auto';

/**
 * Create a platform adapter based on configuration
 *
 * @param type - Adapter type ('vercel', 'aws', 'generic', or 'auto')
 * @param baseUrl - Base URL for the application (used for generic adapter)
 * @returns Platform adapter instance
 */
export function createAdapter(
  type: AdapterType = 'auto',
  baseUrl?: string
): PlatformAdapter {
  const adapterType = type === 'auto' ? detectPlatform() : type;

  switch (adapterType) {
    case 'vercel': {
      const adapter = VercelAdapter.fromEnv();
      if (adapter) return adapter;
      console.warn('[E2E] Vercel adapter requested but env vars missing, falling back to generic');
      return new GenericAdapter(baseUrl || getBaseUrl());
    }

    case 'aws': {
      const adapter = AWSAdapter.fromEnv();
      if (adapter) return adapter;
      console.warn('[E2E] AWS adapter requested but env vars missing, falling back to generic');
      return new GenericAdapter(baseUrl || getBaseUrl());
    }

    case 'generic':
    default:
      return new GenericAdapter(baseUrl || getBaseUrl());
  }
}

/**
 * Detect platform from environment variables
 */
function detectPlatform(): AdapterType {
  // Check environment variable override
  const platform = process.env.E2E_PLATFORM?.toLowerCase();
  if (platform === 'vercel' || platform === 'aws' || platform === 'generic') {
    return platform;
  }

  // Auto-detect from environment
  if (process.env.VERCEL || process.env.VERCEL_URL) {
    return 'vercel';
  }

  if (process.env.AWS_LAMBDA_FUNCTION_NAME || process.env.AWS_LOG_GROUP) {
    return 'aws';
  }

  return 'generic';
}

/**
 * Get base URL from environment
 */
function getBaseUrl(): string {
  return (
    process.env.APP_URL ||
    process.env.BASE_URL ||
    process.env.PLAYWRIGHT_BASE_URL ||
    (process.env.VERCEL_URL ? `https://${process.env.VERCEL_URL}` : '') ||
    'http://localhost:3000'
  );
}

/**
 * Check if all required env vars are set for a specific adapter
 */
export function checkAdapterRequirements(type: AdapterType): {
  ready: boolean;
  missing: string[];
} {
  const missing: string[] = [];

  switch (type) {
    case 'vercel':
      if (!process.env.VERCEL_TOKEN) missing.push('VERCEL_TOKEN');
      if (!process.env.VERCEL_TEAM_ID) missing.push('VERCEL_TEAM_ID');
      if (!process.env.VERCEL_PROJECT_ID) missing.push('VERCEL_PROJECT_ID');
      break;

    case 'aws':
      if (!process.env.AWS_LOG_GROUP) missing.push('AWS_LOG_GROUP');
      // AWS credentials are typically handled by SDK chain
      break;

    case 'generic':
      // No requirements
      break;
  }

  return { ready: missing.length === 0, missing };
}

/**
 * Get adapter status information
 */
export async function getAdapterStatus(): Promise<{
  platform: string;
  healthy: boolean;
  deployment: {
    environment: string;
    version?: string;
    url: string;
  };
}> {
  const adapter = createAdapter();
  const healthy = await adapter.healthCheck();
  const deployment = await adapter.getDeploymentInfo();

  return {
    platform: adapter.name,
    healthy,
    deployment: {
      environment: deployment.environment,
      version: deployment.version,
      url: deployment.url
    }
  };
}
