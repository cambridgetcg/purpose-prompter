---
description: "Quick diagnostic of PP's current state - checks commands, feedback, insights, locks, and drift"
argument-hint: "[verbose] - optional, show detailed output"
allowed-tools: [Read, Glob, Grep, Bash]
model: haiku
---

# PP Health Check Command

Quick diagnostic of Purpose Prompter's current state. Run this before starting work to ensure PP is healthy.

## Arguments

Verbosity (optional): $ARGUMENTS
- No argument: Summary view
- `verbose`: Detailed view with file listings

## Purpose

Health check provides instant visibility into:
- PP infrastructure status
- Feedback system health
- Active blindspots
- Lock status
- Potential drift

## Protocol

### Step 1: Check Core Infrastructure

```
ACTION: Verify core PP files exist and are readable

CHECK:
- ~/.claude/CLAUDE.md (orchestration layer)
- ~/.claude/purpose_prompter/UNIFIED_MODEL.md (canonical model)
- ~/.claude/purpose_prompter/ACTIVATE.md (operational guide)

OUTPUT:
✅ CLAUDE.md: [X lines]
✅ UNIFIED_MODEL.md: [X lines]
✅ ACTIVATE.md: [X lines]
-- OR --
❌ [file]: MISSING or unreadable
```

### Step 2: Check Commands

```
ACTION: Count commands in plugins/hierarchy-tools/commands/

GLOB: ~/.claude/plugins/hierarchy-tools/commands/*.md
COUNT: Number of .md files

OUTPUT:
✅ Commands: [X] found
   [list if verbose]
```

### Step 3: Check Feedback System

```
ACTION: Count feedback entries and check insight files

READ: ~/.claude/purpose_prompter/feedback/entries.jsonl
COUNT: Number of lines (entries)

CHECK insight files exist:
- insights/blindspots.md
- insights/truth_patterns.md
- insights/understanding_patterns.md
- insights/beauty_patterns.md
- insights/justice_patterns.md
- insights/creativity_patterns.md

OUTPUT:
✅ Feedback: [X] entries
✅ Insights: [Y] files present
⚠️  Insights: [file] missing
```

### Step 4: Check Active Blindspots

```
ACTION: Parse blindspots.md for active blindspots

GREP: "### \[NEW\]" or "### 1." patterns in blindspots.md
COUNT: Active blindspots

OUTPUT:
✅ Blindspots: [X] active
   - [blindspot name 1]
   - [blindspot name 2]
-- OR --
✅ Blindspots: None active
```

### Step 5: Check Lock Status

```
ACTION: Check if review lock is held

CHECK: ~/.claude/purpose_prompter/feedback/.review.lock exists

IF exists:
  READ timestamp
  OUTPUT: ⚠️  Lock: Held since [timestamp]
ELSE:
  OUTPUT: ✅ Lock: Not held
```

### Step 6: Quick Drift Check

```
ACTION: Compare documented commands vs actual commands

PARSE: Commands mentioned in CLAUDE.md
GLOB: Actual commands in plugins/hierarchy-tools/commands/
COMPARE:
- Ghost commands (documented but don't exist)
- Orphan commands (exist but not documented)

OUTPUT:
✅ Drift: None detected
-- OR --
⚠️  Drift: [X] ghost, [Y] orphan commands
   Use /pp-drift-check for details
```

### Step 7: Last Verification Status

```
ACTION: Check last feedback entry for alignment score

READ: Last entry in entries.jsonl
PARSE: ratings field

OUTPUT:
✅ Last task: [task name]
   Ratings: T:[p/f] U:[p/f] B:[p/f] J:[p/f] C:[p/f]
```

### Step 8: Alignment Metrics (if 5+ entries)

```
ACTION: Calculate alignment metrics from feedback entries

IF entries.jsonl has 5+ entries:
  1. Calculate scores for each dimension:
     - pass = 100, partial = 50, fail = 0, n/a = excluded

  2. Calculate alignment score:
     - Average of all dimension scores across entries

  3. Calculate convergence (if 10+ entries):
     - Compare last 5 entries vs previous 5
     - Positive = improving, negative = declining

  4. Determine status:
     - Alignment >= 80%: ALIGNED
     - Alignment 60-79%: IMPROVING
     - Alignment < 60%: AT RISK

OUTPUT (5-9 entries):
📊 Alignment: [X%] [ALIGNED/IMPROVING/AT RISK]
   (10+ entries needed for convergence trend)

OUTPUT (10+ entries):
📊 Alignment: [X%] [↑/→/↓]
   Convergence: [+/-X%] over last 10 entries
   Decision: [Continue/Investigate/Question]

OUTPUT (< 5 entries):
📊 Alignment: Insufficient data (need 5+ entries)
```

## Output Format

### Summary View (default)

```
╔═══════════════════════════════════════════════════════════════╗
║                     PP HEALTH CHECK                           ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  Infrastructure                                               ║
║  ✅ CLAUDE.md: 650 lines                                      ║
║  ✅ Commands: 11 found                                        ║
║  ✅ Feedback: 5 entries                                       ║
║                                                               ║
║  Learning System                                              ║
║  ✅ Insights: 6/6 files present                               ║
║  ✅ Blindspots: 1 active                                      ║
║     └─ Ghost Documentation (Truth)                            ║
║                                                               ║
║  Concurrency                                                  ║
║  ✅ Lock: Not held                                            ║
║                                                               ║
║  Integrity                                                    ║
║  ✅ Drift: None detected                                      ║
║                                                               ║
║  Last Task                                                    ║
║  ✅ "PP concurrency safety" - All pass                        ║
║                                                               ║
║  Alignment Metrics                                            ║
║  📊 Alignment: 85% ↑                                          ║
║     Convergence: +8% (improving)                              ║
║     Decision: Continue refining                               ║
║                                                               ║
╠═══════════════════════════════════════════════════════════════╣
║  STATUS: HEALTHY                                              ║
╚═══════════════════════════════════════════════════════════════╝
```

### Status Levels

| Status | Meaning | Action |
|--------|---------|--------|
| **HEALTHY** | All checks pass | Proceed normally |
| **WARNING** | Minor issues (⚠️) | Review warnings, can proceed |
| **UNHEALTHY** | Critical issues (❌) | Fix before proceeding |

### Warning Conditions

- Lock held for > 5 minutes
- Drift detected (ghost/orphan commands)
- Missing insight files
- Last task had failures
- Alignment score 60-79% (IMPROVING but not ALIGNED)
- Negative convergence rate (declining trend)

### Unhealthy Conditions

- Core files missing (CLAUDE.md, UNIFIED_MODEL.md)
- No commands found
- Feedback system broken
- Alignment score < 60% (AT RISK - requires attention)
- Decision threshold: "Question Approach" triggered

## Integration

Run `/pp-health` at:
- Start of new session
- Before major PP tasks
- After PP modifications
- When something feels wrong

## Quick Reference

```bash
# Check PP health
/pp-health

# Detailed view
/pp-health verbose
```
