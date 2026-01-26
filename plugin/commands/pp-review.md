---
description: "Synthesize patterns from accumulated PP feedback - identifies blindspots and recurring issues"
argument-hint: "[dimension] - optional, focus on specific dimension (truth, understanding, beauty, justice, creativity)"
allowed-tools: [Read, Write, Glob, Grep, Bash]
model: sonnet
---

# PP Review Command

Synthesize patterns from feedback entries to identify blindspots and improvement opportunities.

## Arguments

Focus dimension (optional): $ARGUMENTS

## Purpose

Review transforms raw feedback into actionable insights:
- Identify recurring patterns across tasks
- Surface blindspots (systematic failures)
- Quantify alignment trends
- Generate refinement recommendations

## Concurrency Control

**CRITICAL**: This command modifies shared insight files. Use lock file to prevent concurrent synthesis.

### Lock File Protocol

```
LOCK_FILE = ~/.claude/purpose_prompter/feedback/.review.lock
STALE_THRESHOLD = 10 minutes

Step 0: Check and Acquire Lock
──────────────────────────────
1. Check if LOCK_FILE exists
2. If exists:
   a. Read lock file content (timestamp, session info)
   b. If lock age > STALE_THRESHOLD:
      - Warn: "Stale lock detected (session may have crashed). Removing."
      - Remove stale lock
      - Proceed to acquire
   c. If lock age <= STALE_THRESHOLD:
      - ERROR: "Another session is currently running /pp-review"
      - Output: "Lock held since: [timestamp]"
      - Output: "Try again in a few minutes, or remove lock manually if stuck:"
      - Output: "  rm ~/.claude/purpose_prompter/feedback/.review.lock"
      - ABORT (do not proceed)
3. If not exists (or stale removed):
   - Create lock file with content:
     {
       "timestamp": "[ISO8601]",
       "session": "[session identifier]",
       "task": "pp-review synthesis"
     }
   - Proceed with synthesis

Step FINAL: Release Lock
────────────────────────
ALWAYS release lock after synthesis completes (success or failure):
- Remove LOCK_FILE
- Confirm: "Lock released. Synthesis complete."
```

### Lock File Commands

**Acquire lock** (run via Bash):
```bash
echo '{"timestamp":"'$(date -u +%Y-%m-%dT%H:%M:%SZ)'","task":"pp-review"}' > ~/.claude/purpose_prompter/feedback/.review.lock
```

**Check lock age** (run via Bash):
```bash
if [ -f ~/.claude/purpose_prompter/feedback/.review.lock ]; then
  lock_time=$(cat ~/.claude/purpose_prompter/feedback/.review.lock | grep -o '"timestamp":"[^"]*"' | cut -d'"' -f4)
  echo "Lock exists, created: $lock_time"
else
  echo "No lock file"
fi
```

**Release lock** (run via Bash):
```bash
rm -f ~/.claude/purpose_prompter/feedback/.review.lock && echo "Lock released"
```

## Process

### Step 0: Acquire Lock (ALWAYS FIRST)

```
ACTION: Check and acquire lock file
IF lock exists and not stale:
  OUTPUT: "Cannot proceed - another /pp-review is running"
  ABORT
ELSE:
  Create lock file
  PROCEED
```

### Step 1: Load Feedback Data

Read `~/.claude/purpose_prompter/feedback/entries.jsonl`

If file doesn't exist or is empty:
```
No feedback entries found. Use /pp-feedback after completing PP tasks to log assessments.
```
**Remember to release lock before aborting.**

### Step 2: Analyze Patterns

For each dimension, calculate:
- **Pass rate**: % of entries rated "pass"
- **Partial rate**: % rated "partial"
- **Fail rate**: % rated "fail"
- **Common themes**: Recurring phrases in notes

### Step 2.5: Calculate Quantitative Metrics

**Innovation Accounting for PP Self-Improvement:**

```
Score Conversion:
  pass   = 100
  partial = 50
  fail   = 0
  n/a    = excluded

Dimension Score = Average of scores for that dimension across entries
Alignment Score = Average of all dimension scores

Example (from 5 entries):
  truth: [100, 100, 50, 100, 100] → 90%
  understanding: [100, 100, 100, 100, 100] → 100%
  beauty: [100, 50, 50, 100, 100] → 80%
  justice: [100, 100, 50, 50, 100] → 80%
  creativity: [100, n/a, n/a, 100, n/a] → 100% (only 2 applicable)

  Alignment Score = (90 + 100 + 80 + 80 + 100) / 5 = 90%
```

**Convergence Rate** (if 10+ entries):
```
Compare last 5 entries vs previous 5 entries:
  Previous alignment: X%
  Current alignment: Y%
  Convergence: Y - X (positive = improving)

Trend indicators:
  ↑ = Improving (convergence > +5%)
  → = Stable (convergence between -5% and +5%)
  ↓ = Declining (convergence < -5%)
```

**Hypothesis Validation** (if entries have hypotheses):
```
For entries with "hypothesis" field:
  Count validated: true vs false
  Validation rate = validated / total hypotheses

Report: "X of Y hypotheses validated (Z%)"
```

**Decision Thresholds** (when to act):
```
THRESHOLD-BASED DECISIONS:

1. Continue Refining (alignment improving):
   - Convergence > 0 (positive trend)
   - Hypothesis validation rate > 60%
   - No dimension below 60% average
   → Action: Continue current approach, refine based on patterns

2. Investigate (alignment stagnant):
   - Convergence between -5% and +5% for 3+ reviews
   - Hypothesis validation rate between 40-60%
   - Some dimensions stuck at partial
   → Action: Deep-dive into stagnant dimensions, question assumptions

3. Question Approach (alignment declining):
   - Convergence < -5% (negative trend)
   - Hypothesis validation rate < 40%
   - Any dimension below 50% average
   → Action: Fundamental reassessment needed, consider structural changes

DIMENSION-SPECIFIC THRESHOLDS:
  - Fail rate > 20% → Critical blindspot, immediate attention
  - Partial rate > 40% → Systematic issue, structural fix needed
  - Pass rate < 60% → Dimension at risk, focused improvement needed
```

### Step 3: Identify Blindspots

**Blindspot criteria**:
- Dimension with fail rate > 20%
- Dimension with partial rate > 40%
- Recurring failure patterns (3+ similar failures)

### Step 4: Generate Insights

For each pattern found:
- What understanding is missing?
- What gate is being skipped?
- What would fix this systemically?

### Step 5: Persist to Files

**CRITICAL**: After generating the report, persist insights to files for cross-session learning.
See "Step 5: Persist Insights to Files" section below for detailed protocol.

## Output Format

```markdown
## PP Review: Pattern Synthesis

**Period**: [date range of entries]
**Total Entries**: [count]
**Alignment Score**: [X%]
**Convergence**: [+/-X%] [↑/↓/→]

### Metrics Summary

| Metric | Value | Status |
|--------|-------|--------|
| Alignment Score | X% | [Good/Warning/Critical] |
| Convergence Rate | +/-X% | [↑ Improving / → Stable / ↓ Declining] |
| Hypothesis Validation | X/Y (Z%) | [High/Medium/Low] |
| Decision Threshold | [Continue/Investigate/Question] | [Recommendation] |

### Dimension Summary

| Dimension | Pass | Partial | Fail | Trend |
|-----------|------|---------|------|-------|
| Truth | X% | Y% | Z% | [↑/↓/→] |
| Understanding | X% | Y% | Z% | [↑/↓/→] |
| Beauty | X% | Y% | Z% | [↑/↓/→] |
| Justice | X% | Y% | Z% | [↑/↓/→] |
| Creativity | X% | Y% | Z% | [↑/↓/→] |

### Blindspots Detected

**1. [Blindspot Name]**
- Dimension: [affected dimension]
- Frequency: [X occurrences]
- Pattern: [what keeps happening]
- Root cause: [what understanding is missing]
- Recommendation: [how to fix]

**2. [Blindspot Name]**
...

### Recurring Themes

**Worked well**:
- [Theme 1]: [X occurrences]
- [Theme 2]: [Y occurrences]

**Common failures**:
- [Failure pattern 1]: [X occurrences]
- [Failure pattern 2]: [Y occurrences]

### Key Learnings

1. [Most important insight]
2. [Second most important]
3. [Third most important]

### Decision Assessment

**Current Status**: [Continue Refining / Investigate / Question Approach]

**Rationale**:
- Alignment trend: [description]
- Hypothesis validation: [description]
- Dimension health: [description]

**Recommended Action**: [specific recommendation based on thresholds]

### Recommendations

**Immediate**:
- [Quick fix for most common issue]

**Structural**:
- [Deeper fix for systemic issue]

**Framework evolution**:
- [Changes to PP itself suggested by patterns]

### Next Actions

- Use `/pp-refine` to apply these learnings
- Use `/pp-learnings` to view accumulated knowledge
- Continue using `/pp-feedback` after tasks
```

## Dimension-Specific Analysis

If $ARGUMENTS specifies a dimension:

### Truth Focus
- Citation gate violations
- Verification failures
- Calibration issues

### Understanding Focus
- Mental model gaps
- Why explanation misses
- Boundary clarity issues

### Beauty Focus
- Forced solutions
- Elegance violations
- Coherence breaks

### Justice Focus
- Placement errors
- Ownership confusion
- Architectural violations

### Creativity Focus
- Missed uncharted territory
- Forced extensions
- Path-building failures

## Step 5: Persist Insights to Files (CRITICAL)

**After generating the review report, WRITE insights to files for cross-session learning.**

### Write Blindspots File

Write to `~/.claude/purpose_prompter/insights/blindspots.md`:

```markdown
# Active Blindspots

Last updated: [timestamp]
Source: /pp-review synthesis from [X] feedback entries

## Critical Blindspots (Address First)

### 1. [Blindspot Name]
- **Dimension**: [truth/understanding/beauty/justice/creativity]
- **Frequency**: [X occurrences in Y entries]
- **Pattern**: [What keeps happening]
- **Prevention**: [How to avoid]
- **Detection**: [How to notice if happening]

### 2. [Blindspot Name]
...

## Resolved Blindspots (Historical)

- [Date]: [Blindspot] - Resolved by [what fixed it]
```

### Write Dimension Pattern Files

For each dimension with significant patterns, write to respective file:

**Example: `~/.claude/purpose_prompter/insights/truth_patterns.md`**
```markdown
# Truth Patterns

Last updated: [timestamp]

## What Works
- [Pattern 1]: [X occurrences] - [Why it works]
- [Pattern 2]: [Y occurrences] - [Why it works]

## What Fails
- [Anti-pattern 1]: [X occurrences] - [Why it fails]
- [Anti-pattern 2]: [Y occurrences] - [Why it fails]

## Key Learnings
1. [Most important truth-related insight]
2. [Second most important]
```

**Repeat for**: understanding_patterns.md, beauty_patterns.md, justice_patterns.md, creativity_patterns.md

### Persistence Protocol

```
AFTER generating review report:
1. Parse synthesized patterns from report
2. READ existing insight files (preserve historical data)
3. MERGE new insights with existing (don't overwrite history)
4. WRITE updated files with timestamp
5. CONFIRM: "Insights persisted to [X] files for cross-session learning."
```

## Step 6: Release Lock (ALWAYS LAST)

**CRITICAL**: Always release the lock, even if synthesis failed.

```
ACTION: Remove lock file
COMMAND: rm -f ~/.claude/purpose_prompter/feedback/.review.lock
OUTPUT: "Lock released. Synthesis complete."
```

**Error handling**: If any step fails, STILL release the lock before reporting the error.

```
try:
  Step 1-5: Synthesis and persistence
finally:
  Step 6: Release lock (ALWAYS)
```

## Integration

The persisted insight files are loaded by pp-orchestrator at session start:
- `~/.claude/purpose_prompter/insights/truth_patterns.md`
- `~/.claude/purpose_prompter/insights/understanding_patterns.md`
- `~/.claude/purpose_prompter/insights/beauty_patterns.md`
- `~/.claude/purpose_prompter/insights/justice_patterns.md`
- `~/.claude/purpose_prompter/insights/creativity_patterns.md`
- `~/.claude/purpose_prompter/insights/blindspots.md`

This closes the learning loop: feedback → review → persist → load → apply → feedback

## Minimum Entries

Recommend at least 5 feedback entries before meaningful review.
Recommend 10+ entries for reliable pattern detection.

## The Learning Loop

```
/pp-feedback → /pp-review → /pp-refine → Improved PP → /pp-feedback
     │              │              │                          │
     └──────────────┴──────────────┴──────────────────────────┘
                    Continuous improvement cycle
```
