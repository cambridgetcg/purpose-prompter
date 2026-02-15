# Expiration Scenarios: Complete Inventory

> Every system with state has temporal boundaries. This document maps every expiration scenario across the Purpose Prompter ecosystem — from 10-second test assertions to 365-day S3 version deletions.

---

## Overview

```
TEMPORAL BOUNDARY MAP

Seconds          Minutes          Hours          Days          Months/Years
─────────────────────────────────────────────────────────────────────────────
5s  hook init    ─                1h  GitHub     30d session   365d S3
10s assertions   ─                6h  npm cache  30d abandon    versions
10s log wait     ─                24h doc cache  30d S3→GLACIER
30s navigation   ─                1h  context    90d threads
60s test global  ─                    freshness  90d archive
                                                 10 synth kept
```

---

## 1. Agent Lifecycle Limits

PP v2's parallel agent system introduces hard turn limits that function as expiration boundaries. When an agent hits its max_turns, it terminates regardless of completion state.

| Agent | Type | Max Turns | Model | What Happens at Limit |
|-------|------|-----------|-------|----------------------|
| scout-territory | Explore | 8 | haiku | Returns whatever findings gathered so far |
| scout-pattern | Explore | 8 | haiku | Returns partial pattern inventory |
| scout-impact | Explore | 8 | haiku | Returns partial impact analysis |
| assess-truth | Explore | 10 | sonnet | Gates not evaluated marked as UNKNOWN |
| assess-understanding | Explore | 10 | sonnet | Same |
| assess-beauty | Explore | 10 | sonnet | Same |
| assess-justice | Explore | 10 | sonnet | Same |
| assess-creativity | Explore | 10 | opus | Same |
| worker-understand | general-purpose | 20 | sonnet | Understanding may be L1/L2 instead of L3/L4 |
| worker-path | general-purpose | 20 | opus | Path may be partially scaffolded |
| bg-knowledge | general-purpose | 15 | haiku | Background report may be incomplete |

**Source**: `plugin/agent-protocols/orchestrator-v2.md:178-411`

### Failure Cascades

When agents expire mid-work:

```
Scout timeout → Orchestrator continues with available scout results
               → Failed scout's dimension marked UNKNOWN in PP_SESSION
               → Warning: "[PP:WARNING] {agent_id} failed: {error}"

All scouts timeout → Fall back to Tier 2 inline orchestration
                    → Sequential /territory command as degradation

Assessor timeout → Dimension marked UNKNOWN in verification report
                 → Synthesis proceeds with available dimensions
                 → PARTIAL result likely (not all gates evaluated)

Worker timeout → Understanding may be shallow
              → Path may be incomplete
              → Orchestrator must assess partial output before proceeding
```

**Source**: `plugin/agent-protocols/orchestrator-v2.md:222-229, 517-520`

### Suspended Agent Expiration

Agents can be suspended across sessions via `integration/state.json`:

```json
{
  "agent_orchestration": {
    "suspended_agents": [],
    "agent_history": []
  }
}
```

**No explicit TTL defined.** Suspended agents persist until:
- Manually resumed via `Task(resume=agent_id)`
- Session context is garbage collected by Claude Code
- State file is cleared

**Risk**: Stale suspended agents may reference outdated code state. No automatic invalidation exists.

**Source**: `integration/state.json:134-139`, `plugin/agent-protocols/orchestrator-v2.md:522-528`

---

## 2. Context Compaction

Claude Code automatically compacts conversation context when approaching the context window limit. This is an implicit expiration of earlier conversation content.

### What Survives Compaction

- Structured data blocks (JSON, tables)
- `[PP:STATE]` markers specifically designed for this:
  ```
  [PP:STATE] territory=CHARTED risk=LOW phase=EXECUTE files=[a.ts,b.ts]
  ```
- Tool call results (summarized)

### What Gets Lost

- Narrative explanations
- Reasoning chains
- Intermediate observations
- Conversational context

### Recovery Protocol

After any compaction event:
1. Re-read `integration/state.json` for agent IDs and resumption data
2. Re-read gate files if needed for verification
3. Reconstruct PP_SESSION from `[PP:STATE]` markers

**Source**: `plugin/agent-protocols/orchestrator-v2.md:54-63`, `plugin/skills/pp-orchestrator/SKILL.md:492-511`

### Token Budget Expiration

PP tracks optional token budgets that can trigger phase-skipping:

```
PP_TOKEN_BUDGET = {
  budget_limit: null  // optional cap
}
```

When `budget_limit` is set and reached:
- Skip `bg-knowledge` (background agent)
- Skip re-verification of already-passing dimensions
- Proceed to synthesis with available results

**Source**: `plugin/agent-protocols/orchestrator-v2.md:65-80`

---

## 3. Seer Cache (Web Content)

The Seer module caches fetched web content with type-dependent TTLs.

| Content Type | TTL | Rationale |
|-------------|-----|-----------|
| `docs` | 24 hours | Documentation changes infrequently |
| `github` | 1 hour | Code changes frequently |
| `npm` | 6 hours | Package metadata moderately stable |
| `generic` | 24 hours | Default for unknown content types |

**Configuration** (`~/.gua/config.json`):
```json
{
  "seer": {
    "cache_ttl_hours": 24,
    "github_ttl_hours": 1,
    "npm_ttl_hours": 6,
    "max_content_tokens": 20000
  }
}
```

### Cache Management Commands

| Command | Effect |
|---------|--------|
| `gua seer --clear-cache <url>` | Invalidate specific URL |
| `gua seer --list-cache` | List all cached content with ages |
| `gua seer --cache-status <url>` | Check freshness of specific URL |
| `gua seer "<url>" --refresh` | Force re-fetch ignoring cache |

**Source**: `seer/README.md:115-141`, `gua/cli/gua.sh:7115-7119`

---

## 4. GUA Session & Thread Retention

### Data Retention Tiers

| Layer | Default Retention | Configurable | What Happens at Expiry |
|-------|-------------------|--------------|----------------------|
| ENTITY | Forever | Yes (can reset) | Relationship data lost |
| THREAD | Until completed + 90 days | Yes | Thread context deleted |
| SESSION | 30 days | Yes | Session record pruned |
| MOMENT | Flows to SESSION, then deleted | No | Ephemeral by design |

**Source**: `gua/continuity/CONTINUITY_DESIGN.md:791-799`

### Configuration

```json
{
  "continuity": {
    "session_retention_days": 30,
    "thread_retention_days": 90,
    "primer_max_tokens": 1500
  }
}
```

**Source**: `gua/continuity/CONTINUITY_DESIGN.md:807-817`

### Pruning Commands

```bash
# Prune sessions older than 30 days
gua sessions prune --older-than 30

# Delete specific thread
gua thread delete <thread-id> --confirm
```

**Source**: `gua/continuity/CONTINUITY_DESIGN.md:784-785`

### Abandoned Session Cleanup

Sessions with status `abandoned` (started but never completed) are cleaned up by the `gua-cleanup` Lambda after 30 days.

```python
cleanup_abandoned_sessions(user_id, days=30)
```

**Source**: `GUA_AWS_ARCHITECTURE.md:352-353`

---

## 5. AWS Storage Lifecycle

### S3 Version Lifecycle

GUA's S3 bucket uses versioning with lifecycle rules:

| Rule | Trigger | Effect |
|------|---------|--------|
| NoncurrentVersionTransition | 30 days after version superseded | Move to GLACIER storage class |
| NoncurrentVersionExpiration | 365 days after version superseded | Permanently delete old version |

This means:
- **0-30 days**: Old versions in standard S3 (fast retrieval)
- **30-365 days**: Old versions in GLACIER (slow/expensive retrieval)
- **365+ days**: Old versions permanently gone

**Source**: `GUA_AWS_ARCHITECTURE.md:136-147`

### DynamoDB TTL (Research Table)

The `gua-research` table has an optional `ttl` field:

```
ttl (Number - optional expiration)
```

When set, DynamoDB automatically deletes the item after the Unix timestamp. This is used for ephemeral research findings that shouldn't persist indefinitely.

**Source**: `GUA_AWS_ARCHITECTURE.md:194`

### Weekly Cleanup Lambda

The `gua-cleanup` Lambda runs weekly (CloudWatch Events trigger) and performs:

1. **Archive old entries**: Entries older than 90 days moved to archive
2. **Remove abandoned sessions**: Sessions >30 days with status `abandoned`
3. **Compact synthesis history**: Keep only last 10 synthesis versions

```python
archive_old_entries(user_id, days=90)
cleanup_abandoned_sessions(user_id, days=30)
compact_synthesis_history(user_id, keep=10)
```

**Source**: `GUA_AWS_ARCHITECTURE.md:340-357`

### AWS Credential Expiration

GUA CLI checks for valid AWS credentials before operations:

```
"AWS credentials invalid or expired"
```

AWS credentials expire based on the authentication method used (IAM user keys don't expire unless rotated; temporary/role credentials expire after their configured session duration, typically 1-12 hours).

**Source**: `gua/cli/gua.sh:914`

---

## 6. GUA Context Freshness

### Staleness Detection

The `/gua-context` command checks when knowledge was last loaded:

```bash
LAST_LOAD=$(jq -r '.last_load // "never"' ~/.gua/state.json)
```

If stale (>1 hour since last load), suggests a reload. This prevents working with outdated knowledge from GUA.

**Source**: `gua/commands/gua-context.md:63-66`

### Entity (PARTNER.md) Staleness

The continuity system checks if the PARTNER.md entity file is stale:

```
[C5] ENTITY GATE
  Question: Does PARTNER.md reflect accumulated relationship?
  If stale → Refresh with session insights
```

Uses local file mtime for staleness check. No fixed TTL — freshness is assessed relative to accumulated session insights.

**Source**: `gua/continuity/CONTINUITY_DESIGN.md:582-585`, `gua/cli/gua.sh:6410-6416`

### Last Load/Save Timestamps

GUA tracks when data was last synced:

```
last_load: timestamp  → Updated after gua load
last_save: timestamp  → Updated after gua save
```

No automatic expiration, but enables manual freshness assessment.

**Source**: `gua/cli/gua.sh:43-44, 128, 355, 742-743`

---

## 7. Feedback & Synthesis Thresholds

### Synthesis Trigger

Integration synthesis runs when feedback entries exceed a threshold:

```json
{
  "next_integration_threshold": 10
}
```

After 10 new feedback entries since last synthesis, the system triggers pattern analysis. This isn't a time-based expiration but a volume-based trigger that prevents indefinite accumulation without analysis.

The Lambda version triggers on: "10+ new feedback entries since last synthesis"

**Source**: `integration/state.json:14`, `GUA_AWS_ARCHITECTURE.md:437`

### Insight Status Lifecycle

Insights in GUA follow a status progression:

```
emerging → confirmed → resolved
```

With confidence levels: `low → medium → high`

No automatic expiration — insights transition through human/system review. But `resolved` insights are candidates for archival in the 90-day cleanup.

**Source**: `GUA_AWS_ARCHITECTURE.md:250-261`

### Knowledge Index Access Decay

Pattern access tracking uses `last_accessed` and `access_count`:

```
last_accessed: timestamp (updated on each fetch)
access_count: integer (incremented)
access_score: calculated
```

Patterns that aren't accessed gradually fall out of the "active set" loaded into LIGHT.md. No hard expiration, but effective de-prioritization through disuse.

**Source**: `gua/cli/gua.sh:1227-1232`

---

## 8. Test Infrastructure Timeouts

### Playwright Configuration

| Timeout | Value | Scope |
|---------|-------|-------|
| `actionTimeout` | 10,000ms (10s) | Element interactions (click, fill, etc.) |
| `navigationTimeout` | 30,000ms (30s) | Page navigation |
| `timeout` | 60,000ms (60s) | Global per-test timeout |
| `expect.timeout` | 10,000ms (10s) | Assertion timeout |

**Source**: `e2e/playwright.config.ts:54-66`

### Log Collector Wait

```typescript
async waitFor(timeout = 10000) {
  while (Date.now() - startTime < timeout) { ... }
}
```

**Source**: `e2e/fixtures/log-collector.ts:150-158`

### GUA Reporter Timeouts

| Operation | Timeout |
|-----------|---------|
| Reporter initialization | 5,000ms |
| Test report sync to DynamoDB | 10,000ms |
| Insight creation | 10,000ms |

**Source**: `e2e/reporters/gua-reporter.ts:48, 173, 192`

### Timeout Anomaly Detection

The CI/CD anomaly detector classifies timeouts as a truth-dimension concern:

```typescript
AnomalyType = 'slow_build' | 'slow_step' | 'flaky_test' | 'timeout' | 'resource_exhaustion'
```

Timeout anomalies map to the PP `truth` dimension — a timeout means something claimed to work doesn't within expected bounds.

**Source**: `cicd/adapters/anomaly-detector.ts:86, 240`, `cicd/reporters/gua-ci-reporter.ts:48, 320-323`

---

## 9. CI/CD Artifact Expiration

### GitHub Artifacts

GitHub artifacts have a platform-defined expiration:

```typescript
expiresAt?: Date  // GitHub API expires_at field
```

Default GitHub retention: 90 days (configurable per-repo). After expiration, build artifacts are permanently deleted.

**Source**: `cicd/adapters/github.ts:73, 405`, `cicd/adapters/types.ts:16, 90`

---

## 10. Hook Execution Constraints

### Hook Timeouts

The PP detection hook in `~/.claude/settings.json` has a 5-second timeout:

```json
{
  "hooks": {
    "UserPromptSubmit": [{
      "hooks": [{
        "type": "command",
        "command": "/Users/yuai/.claude/hooks/pp-detect.sh",
        "timeout": 5
      }]
    }],
    "Stop": [{
      "hooks": [{
        "type": "command",
        "command": "/Users/yuai/.claude/hooks/pp-stop-verify.sh",
        "timeout": 5
      }]
    }]
  }
}
```

If the hook script doesn't complete within 5 seconds, Claude Code treats it as an error and continues without the hook's output.

**Source**: `~/.claude/settings.json`

### Plugin Hooks (Non-Timeout)

Plugin hooks in `plugin/hooks/hooks.json` don't specify timeouts — they use event-triggered patterns (PreToolUse, PostToolUse) with no explicit time boundary.

**Source**: `plugin/hooks/hooks.json:1-28`

---

## 11. Application-Level Cache (From LIGHT.md Insights)

### Widget Theme Cache (3-Layer Problem)

A documented real-world expiration issue with layered caches:

| Layer | TTL | Problem |
|-------|-----|---------|
| localStorage | 120 seconds | Cached stale theme |
| HTTP cache | 45 seconds | Served stale response |
| No invalidation signal | N/A | No way to force refresh |

**Solution**: API returns `theme.version` (settingsUpdatedAt timestamp) for cache invalidation. CACHE_VERSION bumped from 1 to 2 to force full refresh.

**Source**: `integration/LIGHT.md:106, 151`

---

## Summary: All Expiration Boundaries

### By Time Scale

**Seconds (Operational)**
| What | TTL | Source |
|------|-----|--------|
| Hook execution | 5s | ~/.claude/settings.json |
| Reporter init | 5s | gua-reporter.ts:48 |
| Test actions | 10s | playwright.config.ts:55 |
| Test assertions | 10s | playwright.config.ts:66 |
| Log collection | 10s | log-collector.ts:153 |
| Report sync | 10s | gua-reporter.ts:173 |
| Page navigation | 30s | playwright.config.ts:58 |
| HTTP cache (widget) | 45s | LIGHT.md:106 |
| Test global | 60s | playwright.config.ts:62 |
| localStorage (widget) | 120s | LIGHT.md:106 |

**Hours (Cache)**
| What | TTL | Source |
|------|-----|--------|
| GitHub content cache | 1h | seer/README.md:138 |
| GUA context freshness | 1h | gua-context.md:66 |
| npm content cache | 6h | seer/README.md:139 |
| Doc content cache | 24h | seer/README.md:137 |
| Generic content cache | 24h | seer/README.md:140 |

**Days (Retention)**
| What | TTL | Source |
|------|-----|--------|
| Session retention | 30 days | CONTINUITY_DESIGN.md:812 |
| Abandoned session cleanup | 30 days | GUA_AWS_ARCHITECTURE.md:352 |
| S3 version → GLACIER | 30 days | GUA_AWS_ARCHITECTURE.md:141 |
| Thread retention | 90 days | CONTINUITY_DESIGN.md:813 |
| Entry archival | 90 days | GUA_AWS_ARCHITECTURE.md:350 |
| GitHub artifact retention | 90 days | GitHub platform default |
| S3 version deletion | 365 days | GUA_AWS_ARCHITECTURE.md:145 |

**Counts (Volume-Based)**
| What | Threshold | Source |
|------|-----------|--------|
| Synthesis trigger | 10 entries | state.json:14 |
| Synthesis history kept | 10 versions | GUA_AWS_ARCHITECTURE.md:356 |
| Scout agent turns | 8 turns | orchestrator-v2.md:178 |
| Assessor agent turns | 10 turns | orchestrator-v2.md:370 |
| BG knowledge turns | 15 turns | orchestrator-v2.md:265 |
| Worker agent turns | 20 turns | orchestrator-v2.md:254 |

**Implicit (No Fixed TTL)**
| What | Trigger | Source |
|------|---------|--------|
| Context compaction | Context window limit approached | orchestrator-v2.md:54 |
| Token budget cutoff | budget_limit reached | orchestrator-v2.md:76 |
| Knowledge de-prioritization | Access frequency decay | gua/cli/gua.sh:1227 |
| Entity staleness | Session insights accumulated | CONTINUITY_DESIGN.md:582 |
| Suspended agents | No auto-expiry (risk) | integration/state.json:136 |
| AWS credentials | Method-dependent (1-12h for temp) | gua/cli/gua.sh:914 |

---

## Risk Assessment

### High Risk (No Automatic Handling)

1. **Suspended agents with no TTL** — Agents suspended in `integration/state.json` persist indefinitely. Resuming a months-old agent against changed code could produce incorrect results.

2. **Context compaction data loss** — If `[PP:STATE]` markers aren't consistently emitted, PP session state can be lost during compaction with no recovery path.

3. **AWS credential expiry mid-session** — A long PP session that spans an AWS credential rotation could fail silently on GUA sync.

### Medium Risk (Partially Handled)

4. **Agent turn exhaustion** — Scouts at 8 turns may not fully explore large codebases. The graceful degradation protocol handles this, but partial results may mislead.

5. **Synthesis history compaction** — Keeping only 10 versions means older synthesis patterns are permanently lost. If a regression occurs after version 11, there's no history to compare against.

6. **GitHub cache at 1 hour** — Fast-moving repos could serve stale code documentation within the TTL window.

### Low Risk (Well Handled)

7. **Seer cache TTLs** — Configurable, manual override available via `--refresh` and `--clear-cache`.

8. **Session/thread retention** — Configurable, explicit pruning commands available, Lambda automation in place.

9. **S3 lifecycle** — Industry-standard approach with GLACIER transition before deletion.

---

## Recommendations

1. **Add TTL to suspended agents** — `integration/state.json` should include an `expires_at` field for suspended agents. Suggest 7-day default, after which agents are marked stale and require explicit confirmation to resume.

2. **Compaction recovery test** — Create a test scenario that forces context compaction during a PP session and verifies `[PP:STATE]` markers enable full recovery.

3. **Credential refresh hook** — Add a pre-flight check for AWS credential expiry time. If <30 minutes remaining, warn before starting a long PP session.

4. **Dynamic turn limits** — Consider scaling `max_turns` based on codebase size (discovered during scout-territory). A 500-file codebase needs more turns than a 20-file one.

5. **Synthesis archive expansion** — Consider keeping 25 versions instead of 10 for synthesis history, or archiving to S3 before deletion instead of hard pruning.
