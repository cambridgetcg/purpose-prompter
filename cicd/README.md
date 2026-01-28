# CI/CD Monitor Pipeline

Platform-agnostic CI/CD monitoring with GitHub Actions API, integrated with GUA for automatic knowledge capture.

## Quick Start

```bash
# Set your GitHub token
export GITHUB_TOKEN=ghp_xxxxxxxxxxxx

# Check status
~/.gua/ci.sh status

# Watch for failures
~/.gua/ci.sh watch --workflow "CI"

# Debug a failed run
~/.gua/ci.sh debug 12345 --logs
```

## Features

- **GitHub Actions Integration**: Fetch workflow runs, jobs, logs, and artifacts
- **Anomaly Detection**: Detect slow builds, timeouts, and flaky tests
- **GUA Integration**: Auto-capture failures as CPT challenges, anomalies as gotchas
- **Webhook Support**: Real-time event processing from GitHub
- **Build Metrics**: Track success rates, durations, and trends

## Directory Structure

```
cicd/
├── adapters/               # Platform adapters
│   ├── types.ts            # Core interfaces and types
│   ├── github.ts           # GitHub Actions adapter
│   ├── generic.ts          # Generic/mock adapter
│   └── index.ts            # Adapter factory
│
├── analyzers/              # Analysis tools
│   └── anomaly-detector.ts # Performance anomaly detection
│
├── collectors/             # Metrics collection
│   └── build-metrics.ts    # Build time and success metrics
│
├── config/                 # Configuration
│   └── thresholds.ts       # Performance thresholds
│
├── reporters/              # GUA integration
│   └── gua-ci-reporter.ts  # Report events to GUA
│
├── webhook/                # Webhook handling
│   ├── handler.ts          # Event handler
│   └── server.ts           # HTTP server
│
└── README.md               # This file

~/.gua/
└── ci.sh                   # CLI tool
```

## CLI Commands

| Command | Description |
|---------|-------------|
| `ci status` | Show recent workflow runs |
| `ci watch [workflow]` | Real-time monitoring with polling |
| `ci debug <run-id>` | Investigate a failed run |
| `ci failures` | List recent failures |
| `ci metrics` | Build metrics and trends |
| `ci resolve <id> <msg>` | Resolve a CI challenge |
| `ci webhook start` | Start webhook listener |
| `ci config` | Manage configuration |
| `ci init` | Initialize CI monitoring |

### Examples

```bash
# Show status for a specific repo
ci status --repo owner/repo

# Watch CI workflow with 30s polling
ci watch --workflow "CI" --poll 30

# Debug a run with logs
ci debug 12345 --logs

# View failures from last week
ci failures --since 7d

# View 30-day metrics
ci metrics --period 30

# Resolve a CI challenge
ci resolve challenge#ci#owner-repo#12345 "Fixed by adding cache"
```

## Configuration

### Environment Variables

```bash
# Required
GITHUB_TOKEN=ghp_xxxxxxxxxxxx    # GitHub personal access token

# Optional
GITHUB_REPOSITORY=owner/repo    # Default repository
CI_WEBHOOK_PORT=8787            # Webhook server port
CI_WEBHOOK_SECRET=xxx           # Webhook signature secret

# Threshold overrides
CI_THRESHOLD_BUILD_TIME=600000  # 10 minutes in ms
CI_THRESHOLD_STEP_TIME=300000   # 5 minutes in ms
```

### Config File (`~/.gua/ci-config.json`)

```json
{
  "repos": ["owner/repo1", "owner/repo2"],
  "workflows": ["CI", "Deploy"],
  "branches": ["main", "develop"],
  "thresholds": {
    "build_time": { "warning": 300000, "critical": 600000 },
    "step_time": { "warning": 120000, "critical": 300000 },
    "failure_rate": { "warning": 0.1, "critical": 0.25 }
  }
}
```

## GUA Integration

### Automatic Capture

When CI events occur, the GUA reporter automatically:

| Event | GUA Action | PP Dimension |
|-------|------------|--------------|
| Build failure | Challenge (bug) | truth |
| Test failure | Challenge (bug) | truth |
| Deploy failure | Challenge (config) | justice |
| Slow build | Gotcha | beauty |
| Timeout | Gotcha | truth |
| Flaky test | Gotcha | truth |

### Learning Flow

```
CI fails
    ↓
GUA logs challenge (automatic)
    ↓
Developer investigates (`ci debug`)
    ↓
Developer resolves (`ci resolve`)
    ↓
Knowledge promoted (`dev promote`)
    ↓
Knowledge available for future debugging
```

### Manual Resolution

```bash
# Resolve a CI challenge
ci resolve challenge#ci#owner-repo#12345 "Fixed by caching dependencies"

# Promote to dev knowledge
~/.gua/gua.sh dev promote challenge#ci#owner-repo#12345 --platform general --domain deployment
```

## Webhook Setup

### GitHub Webhook Configuration

1. Go to your repository Settings → Webhooks → Add webhook
2. Configure:
   - Payload URL: `https://your-server.com/webhook`
   - Content type: `application/json`
   - Secret: Set `CI_WEBHOOK_SECRET` to match
   - Events: Select "Workflow runs" and "Workflow jobs"

### Local Development

```bash
# Start webhook server
ci webhook start

# Use ngrok for external access
ngrok http 8787
```

### Programmatic Usage

```typescript
import { startWebhookServer } from './cicd/webhook/server';

const server = await startWebhookServer({
  port: 8787,
  secret: process.env.CI_WEBHOOK_SECRET,
  verbose: true,
});
```

## Programmatic API

### Using the Adapter

```typescript
import { createAdapter, GitHubActionsAdapter } from './cicd/adapters';

// Auto-detect platform
const adapter = createAdapter({
  token: process.env.GITHUB_TOKEN,
  repo: 'owner/repo',
});

// Get recent runs
const runs = await adapter.getWorkflowRuns({
  branch: 'main',
  limit: 10,
});

// Get job logs
const logs = await adapter.getJobLogs(runId, jobId);
```

### Using the Reporter

```typescript
import { createGUACIReporter } from './cicd/reporters/gua-ci-reporter';

const reporter = createGUACIReporter({
  verbose: true,
  logFailures: true,
  logAnomalies: true,
});

// Report a workflow run
await reporter.reportWorkflowRun(run, 'owner/repo');
```

### Using the Anomaly Detector

```typescript
import { createAnomalyDetector } from './cicd/analyzers/anomaly-detector';

const detector = createAnomalyDetector({
  thresholds: {
    build_time: { warning: 300000, critical: 600000 },
    step_time: { warning: 120000, critical: 300000 },
    failure_rate: { warning: 0.1, critical: 0.25 },
  },
});

const result = detector.analyze(run, 'owner/repo');
console.log(`Found ${result.anomalies.length} anomalies`);
```

### Collecting Metrics

```typescript
import { createMetricsCollector } from './cicd/collectors/build-metrics';
import { createAdapter } from './cicd/adapters';

const adapter = createAdapter({ repo: 'owner/repo' });
const collector = createMetricsCollector({ adapter });

const metrics = await collector.collect({
  workflow: 'CI',
  periodDays: 30,
});

console.log(collector.formatReport(metrics));
```

## Troubleshooting

### No data showing

1. Verify `GITHUB_TOKEN` is set and has `repo` and `workflow` scopes
2. Check repository name format: `owner/repo`
3. Run `ci init` to check prerequisites

### Webhook not receiving events

1. Verify webhook URL is accessible from GitHub
2. Check webhook secret matches `CI_WEBHOOK_SECRET`
3. Verify selected events include "Workflow runs"
4. Check webhook delivery logs in GitHub

### GUA not logging

1. Verify GUA CLI is available: `~/.gua/gua.sh --help`
2. Check the reporter is enabled: `logFailures: true`
3. Run with verbose mode: `--verbose`

## Best Practices

1. **Set appropriate thresholds**: Tune warning/critical thresholds for your workflows
2. **Use webhook for production**: Polling is fine for development, webhooks for production
3. **Resolve challenges promptly**: This builds knowledge for future debugging
4. **Promote useful learnings**: Use `dev promote` for fixes that benefit the team
5. **Monitor flaky tests**: High flaky test rate indicates reliability issues
