# E2E Testing Pipeline

Platform-agnostic E2E testing with Playwright, integrated with GUA for automatic knowledge capture.

## Quick Start

```bash
# Install dependencies
npm install -D @playwright/test
npx playwright install

# Run tests
~/.gua/e2e.sh run

# Run in debug mode
~/.gua/e2e.sh run:debug

# Check status
~/.gua/e2e.sh status
```

## Features

- **Platform Adapters**: Fetch logs from Vercel, AWS CloudWatch, or browser console
- **Log Correlation**: Correlate logs to specific requests/actions
- **GUA Integration**: Auto-capture test failures as CPT challenges
- **Debug Helpers**: Tools for investigating and resolving test failures

## Directory Structure

```
e2e/
├── adapters/           # Platform-specific log fetching
│   ├── types.ts        # Interface definitions
│   ├── vercel.ts       # Vercel adapter
│   ├── aws.ts          # AWS CloudWatch adapter
│   └── generic.ts      # Browser console fallback
│
├── fixtures/           # Playwright test fixtures
│   ├── base.ts         # Base fixture with log capture
│   └── log-collector.ts # Log correlation fixtures
│
├── reporters/          # Custom reporters
│   └── gua-reporter.ts # GUA knowledge capture
│
├── debug/              # Debug utilities
│   └── resolution.ts   # Resolution helpers
│
├── tests/              # Test files
│   └── smoke.spec.ts   # Example smoke tests
│
└── playwright.config.ts # Playwright configuration
```

## Configuration

### Environment Variables

```bash
# Platform selection
E2E_PLATFORM=vercel        # vercel | aws | generic

# Application URL
APP_URL=http://localhost:3000

# Vercel (for log fetching)
VERCEL_TOKEN=xxx
VERCEL_TEAM_ID=xxx
VERCEL_PROJECT_ID=xxx

# AWS (for CloudWatch logs)
AWS_REGION=us-west-2
AWS_LOG_GROUP=/app/logs
```

## Writing Tests

### Basic Test with Log Collection

```typescript
import { test, expect } from '../fixtures';

test('user can log in', async ({ page, collectLogs, getErrors }) => {
  await page.goto('/login');
  await page.fill('[name="email"]', 'test@example.com');
  await page.fill('[name="password"]', 'password');
  await page.click('button[type="submit"]');

  await expect(page).toHaveURL('/dashboard');

  // Check for errors
  const errors = await getErrors();
  expect(errors).toHaveLength(0);
});
```

### Test with Log Correlation

```typescript
import { test, expect } from '../fixtures/log-collector';

test('API request succeeds', async ({ page, correlateLogsToRequest }) => {
  await page.goto('/');
  await page.click('#load-data');

  const correlation = await correlateLogsToRequest('/api/data');

  if (correlation) {
    console.log(`Request ${correlation.requestId} took ${correlation.duration}ms`);
    expect(correlation.errors).toHaveLength(0);
  }
});
```

## CLI Commands

```bash
# Run all tests
~/.gua/e2e.sh run

# Run specific file
~/.gua/e2e.sh run tests/auth.spec.ts

# Run in debug mode
~/.gua/e2e.sh run:debug

# Run with browser visible
~/.gua/e2e.sh run --headed

# Run UI mode
~/.gua/e2e.sh run:ui

# Investigate failures
~/.gua/e2e.sh debug "test name"

# Fetch logs for request
~/.gua/e2e.sh logs <request-id>

# View status
~/.gua/e2e.sh status

# List challenges
~/.gua/e2e.sh challenges

# Resolve challenge
~/.gua/e2e.sh resolve challenge#xxx "Fixed by adding wait"
```

## GUA Integration

### Automatic Capture

When tests fail, the GUA reporter automatically:
1. Creates a CPT challenge for the failure
2. Captures error details and logs
3. Tags with relevant platform/domain

When tests are flaky (pass on retry):
1. Creates a dev knowledge "gotcha" entry
2. Tags as flaky test

### Manual Resolution

After fixing a test:

```bash
# Resolve the challenge
~/.gua/e2e.sh resolve challenge#e2e#xxx "Fixed by adding explicit wait"

# Promote to dev knowledge (optional)
~/.gua/gua.sh dev promote challenge#e2e#xxx --platform nextjs --domain testing
```

### Learning Flow

```
Test fails
    ↓
GUA Reporter logs challenge
    ↓
Developer investigates
    ↓
Developer resolves challenge
    ↓
Developer promotes to dev knowledge
    ↓
Knowledge available for future debugging
```

## Troubleshooting

### Tests timing out

1. Increase timeout in playwright.config.ts
2. Add explicit waits: `await page.waitForSelector(...)`
3. Check network requests in debug mode

### Flaky tests

1. Run in headed mode to observe: `e2e run --headed`
2. Add stability waits between actions
3. Use more specific selectors

### Log collection not working

1. Check E2E_PLATFORM environment variable
2. Verify platform credentials (VERCEL_TOKEN, etc.)
3. Check adapter health: adapter.healthCheck()

## Best Practices

1. **Use data-testid attributes** for stable selectors
2. **Wait for network idle** before assertions
3. **Collect logs on failure** for debugging
4. **Resolve challenges promptly** to build knowledge
5. **Promote useful fixes** to dev knowledge
