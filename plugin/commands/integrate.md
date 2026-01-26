---
description: "Synthesize accumulated perspectives and learnings into LIGHT and PATH"
argument-hint: "[mode] [--global|--project|--merge] - e.g., path --merge, classify"
allowed-tools: [Read, Write, Glob, Grep, Bash, AskUserQuestion]
model: opus
---

# Insight Integrator Command

Synthesize perspectives and feedback into actionable understanding (LIGHT) and direction (PATH).

## Arguments

```
$ARGUMENTS

Parse as:
- mode: full | incremental | status | path | classify (default: incremental)
- scope flags:
  - --global   : Use only global perspectives (~/.claude/purpose_prompter/)
  - --project  : Use only project perspectives (<project>/.claude/)
  - --merge    : Combine global + project into unified output
  - --auto-classify : Enable automatic scope classification (default: ON)
  - --no-classify   : Disable automatic classification
  - (no flag)  : Auto-detect based on current directory
```

---

## Scope Resolution

### Folder Locations

**Global (personal patterns - how YOU work):**
```
~/.claude/purpose_prompter/integration/
├── LIGHT.md              # Cross-project understanding
├── PATH.md               # Personal growth direction
├── state.json            # Integration state
└── perspectives/         # Accumulated perspective MDs
```

**Project (codebase patterns - how THIS CODE works):**
```
<project>/.claude/integration/
├── LIGHT.md              # Project understanding
├── PATH.md               # Project direction
├── state.json            # Integration state
└── perspectives/         # Project perspective MDs
```

### Auto-Detection Logic

```
If --global flag:
  → Use ~/.claude/purpose_prompter/integration/

Else if --project flag:
  → Use <project>/.claude/integration/

Else if --merge flag:
  → Read BOTH, output to project if in project, else global

Else (auto-detect):
  → If in git repo or has .claude folder: use project
  → Else: use global
```

---

## Mode: classify

Run scope classification on unclassified insights and route them appropriately.

### Step C1: LOAD Classification Protocol

Read: `~/.claude/purpose_prompter/SCOPE_CLASSIFICATION.md`

### Step C2: GATHER Unclassified Items

```
Sources to classify:
1. Feedback entries without scope field
2. Insights in "pending" or unscoped location
3. Learnings and suggestions from entries
```

### Step C3: RUN Classification Gates

For each unclassified item, run the 5 gates:

```
GATE 1: SUBJECT TEST
- Look for: "I should", "Claude", "my pattern" → +2 GLOBAL
- Look for: "this codebase", specific paths → +2 LOCAL

GATE 2: REFERENCE TEST
- Contains project-specific file paths? → +2 LOCAL
- Generic patterns, no paths? → +1 GLOBAL

GATE 3: TRANSFER TEST
- Would help in any project? → +2 GLOBAL
- Needs this context to apply? → +2 LOCAL

GATE 4: DIMENSION TEST
- TRUTH/UNDERSTANDING insights → +1 GLOBAL
- BEAUTY/JUSTICE insights → +1 LOCAL

GATE 5: LONGEVITY TEST
- Permanent pattern? → +1 GLOBAL
- Project-lifetime? → +2 LOCAL
```

### Step C4: CALCULATE Scope

```
difference = GLOBAL_SCORE - LOCAL_SCORE

IF difference >= 3:
  → Classify as GLOBAL (auto)

ELIF difference <= -3:
  → Classify as LOCAL (auto)

ELSE:
  → AMBIGUOUS - Use interactive fallback
```

### Step C5: INTERACTIVE FALLBACK (for ambiguous)

When classification is ambiguous, use AskUserQuestion:

```
Present the insight and ask:
"This insight could apply globally or locally:

> {insight_text}

Analysis:
- Subject: {subject_analysis}
- References: {references_found}
- Transfer potential: {transfer_assessment}
- Score: GLOBAL={g_score}, LOCAL={l_score}

Where should this go?"

Options:
1. GLOBAL - Personal pattern (applies across projects)
2. LOCAL - Project pattern (specific to this codebase)
3. BOTH - Split into global principle + local specifics
4. SKIP - Don't classify now
```

### Step C6: ROUTE Classified Items

```
FOR each classified item:
  IF scope == GLOBAL:
    → Move/copy to ~/.claude/purpose_prompter/integration/
    → Update feedback entry with scope: "global"

  ELIF scope == LOCAL:
    → Move/copy to <project>/.claude/integration/
    → Create project integration folder if needed
    → Update feedback entry with scope: "local"

  ELIF scope == BOTH:
    → Extract principle → GLOBAL
    → Keep specifics → LOCAL
    → Tag as split in state
```

### Step C7: UPDATE State

Add to state.json:

```json
{
  "classification": {
    "last_run": "{timestamp}",
    "global_classified": N,
    "local_classified": M,
    "ambiguous_resolved": K,
    "splits_performed": S,
    "pending": P
  }
}
```

### Step C8: OUTPUT Summary

```
## Classification Complete

**Items processed**: {N}
**Auto-classified**: {auto_count}
**User-resolved**: {user_count}
**Splits performed**: {split_count}

### Routing Summary
| Destination | Count | Examples |
|-------------|-------|----------|
| GLOBAL | {N} | "{example_1}" |
| LOCAL | {M} | "{example_2}" |
| SPLIT | {K} | "{example_3}" |

### Pending (skipped)
- {pending items if any}

Next: Run `/integrate full` to synthesize classified insights.
```

---

## Mode: path

Synthesize all accumulated perspectives into PATH.md.

### Step P0: ENSURE CLASSIFICATION (if --auto-classify)

Before gathering perspectives, check for unclassified items:

```
IF unclassified items exist AND --no-classify not set:
  → Run classification gates on each
  → Route to appropriate scope
  → Log classification decisions
```

### Step P1: GATHER Perspectives

```
Based on scope, read all files from:
  {scope}/integration/perspectives/*.md

Also read:
  {scope}/integration/LIGHT.md (if exists)
```

### Step P2: EXTRACT From Each Perspective

For each perspective MD, extract:
- **Key insight**: The most important finding
- **Blindspot risk**: Potential blindspot identified
- **Path implication**: How this affects direction
- **Recommendations**: Immediate, short-term, long-term
- **Questions raised**: Uncertainties to investigate

### Step P3: SYNTHESIZE Across Perspectives

Identify:
- **Convergent findings**: Multiple perspectives point to same issue
- **Priority conflicts**: Different perspectives suggest different priorities
- **Coverage gaps**: Areas not examined by any perspective
- **Cumulative recommendations**: All suggested actions

### Step P4: GENERATE PATH.md

```markdown
# PATH - Direction Forward

> Synthesized from {N} perspectives
> Scope: {global|project|merged}
> Generated: {timestamp}

---

## Source Perspectives

| Date | Type | Target | Key Finding |
|------|------|--------|-------------|
| {date} | {type} | {target} | {finding} |
...

---

## Immediate Focus (This Session)

### Priority 1: {title}
- **Why**: {reasoning from perspectives}
- **Evidence**: {which perspectives support this}
- **Action**: {specific steps}
- **Measure**: {how to verify success}

### Priority 2: {title}
...

### Priority 3: {title}
...

---

## Short-term Direction (Next 5-10 Sessions)

### Investigation: {area}
- **Source**: {which perspective raised this}
- **Question**: {what to investigate}
- **Method**: {how to investigate}

### Improvement: {area}
...

---

## Long-term Evolution

### Consider: {strategic change}
- **Why**: {pattern from perspectives}
- **Complexity**: {high/medium/low}
- **Prerequisite**: {what needs to happen first}

---

## Anti-Patterns to Avoid

| Pattern | Source | Why Dangerous |
|---------|--------|---------------|
| {pattern} | {perspective} | {reasoning} |

---

## Open Questions

- [ ] {question from perspective 1}
- [ ] {question from perspective 2}

---

## Review Schedule

- Next perspective recommended: {type} on {target}
- Re-integrate after: {N} more perspectives
- Full review: {timeframe}
```

### Step P5: UPDATE State

```json
{
  "last_integration": "{timestamp}",
  "mode": "path",
  "scope": "{global|project|merged}",
  "perspectives_processed": N,
  "priorities_identified": M
}
```

### Step P6: OUTPUT Summary

```
## PATH Synthesized

**Scope**: {global|project|merged}
**Perspectives processed**: {N}
**Date range**: {earliest} to {latest}

### Top Priorities
1. {priority 1}
2. {priority 2}
3. {priority 3}

### Perspectives Used
- {date}: {type} on {target}
- ...

Full PATH: {path to PATH.md}

Next: Run more `/perspective` commands to enrich future integrations.
```

---

## Mode: full

Complete re-analysis of all sources (feedback + perspectives).

### Step F0: CLASSIFY Feedback Learnings

Before analysis, classify learnings from feedback entries:

```
FOR each feedback entry:
  IF entry has "learning" or "suggestion" field:
    → Run classification gates
    → Tag entry with scope
    → Route insight to appropriate location
```

### Sources Read

```
{scope}/feedback/entries.jsonl
{scope}/insights/blindspots.md
{scope}/insights/*_patterns.md
{scope}/integration/perspectives/*.md
{scope}/integration/state.json
```

### Process

1. **Classify learnings**: Route to global or local (new step)
2. **Analyze feedback entries**: Extract dimension, rating, reason, task type
3. **Analyze perspectives**: Extract insights, blindspots, recommendations
4. **Cross-reference**: Find patterns that appear in both
5. **Generate LIGHT.md**: Current understanding with confidence levels
6. **Generate PATH.md**: Direction forward with priorities

### LIGHT.md Structure

```markdown
# LIGHT - Current Understanding

> Scope: {global|project|merged}
> Last integrated: {timestamp}
> Sources: {N} feedback entries, {M} perspectives
> Classification: {G} global insights, {L} local insights

---

## Confirmed Patterns (HIGH confidence)

### Pattern: {name}
- **Observed**: {frequency}
- **Evidence**: {from feedback and perspectives}
- **Insight**: {what this means}
- **Implication**: {how to use this}
- **Scope**: {global|local}

---

## Emerging Patterns (MEDIUM confidence)

### Pattern: {name}
- **Observed**: {frequency}
- **Needs more data**: {what would confirm}
- **Scope**: {global|local}

---

## Active Blindspots

### Blindspot: {name}
- **Frequency**: {how often occurs}
- **Dimension**: {which PP dimension}
- **Pattern**: {what happens}
- **Mitigation**: {how to prevent}
- **Status**: ACTIVE
- **Scope**: {global|local}

---

## Open Questions

1. **{question}**
   - Source: {where this came from}
   - Investigation: {how to answer}

---

## Confidence Notes

| Category | Confidence | Basis |
|----------|------------|-------|
| Confirmed patterns | HIGH | {N}+ observations |
| Emerging patterns | MEDIUM | Limited data |
| Blindspots | {varies} | {reasoning} |
```

---

## Mode: incremental

Process only new entries since last integration.

### Process

1. Read state.json to find last_integration timestamp
2. Filter feedback entries after that timestamp
3. **Classify new entries** (new step - run classification gates)
4. Read any new perspective MDs after that timestamp
5. Merge new patterns with existing LIGHT.md
6. Regenerate PATH.md with updated priorities

---

## Mode: status

Show current state without processing.

### Output

```
## Integration Status

**Scope**: {auto-detected}

### Global (~/.claude/purpose_prompter/)
- LIGHT.md: {exists|missing} ({date if exists})
- PATH.md: {exists|missing} ({date if exists})
- Perspectives: {N} files
- Last integration: {date}
- Classification: {stats}

### Project ({project}/.claude/)
- LIGHT.md: {exists|missing} ({date if exists})
- PATH.md: {exists|missing} ({date if exists})
- Perspectives: {N} files
- Last integration: {date}
- Classification: {stats}

### Unclassified Items
- Feedback learnings: {N} pending
- Insights: {M} pending

### Recommendation
{What to do next based on state}
```

---

## Merge Mode (--merge)

When --merge flag is used:

1. Read global perspectives → extract meta-patterns (how you work)
2. Read project perspectives → extract specific patterns (this codebase)
3. Generate combined output:

```markdown
# PATH - Merged Direction

## Personal Growth (from global)
{patterns about how you work across projects}

## Project Direction (from project)
{patterns specific to this codebase}

## Combined Priorities
{merged and prioritized actions}
```

---

## Classification Quick Reference

When classifying insights, use these heuristics:

| Signal | Points to GLOBAL | Points to LOCAL |
|--------|------------------|-----------------|
| "I should", "Claude tends" | +2 GLOBAL | |
| "This codebase", specific paths | | +2 LOCAL |
| Would help any project | +2 GLOBAL | |
| Needs this context | | +2 LOCAL |
| TRUTH dimension | +1 GLOBAL | |
| BEAUTY/JUSTICE dimension | | +1 LOCAL |
| Permanent pattern | +1 GLOBAL | |
| Project lifetime | | +2 LOCAL |

**Thresholds**:
- Score >= 3: Auto-classify GLOBAL
- Score <= -3: Auto-classify LOCAL
- Score -2 to 2: Ask user

Full protocol: `~/.claude/purpose_prompter/SCOPE_CLASSIFICATION.md`

---

## Integration Rules

1. **Every pattern needs evidence**: Cite source perspective or entry
2. **Confidence from frequency**: 5+ = confirmed, 2-4 = emerging, 1 = noted
3. **Recency matters**: Weight recent perspectives higher
4. **Convergence strengthens**: Multiple perspectives → higher confidence
5. **Contradictions surface**: Don't hide conflicts, note them
6. **Actions must be specific**: Vague advice is useless
7. **Scope clarity**: Always clear whether global or project
8. **Classify before integrate**: Route insights to correct scope first

---

## Examples

```bash
# Auto-detect scope, synthesize perspectives into PATH
/integrate path

# Force global scope (personal patterns)
/integrate path --global

# Force project scope
/integrate path --project

# Merge global + project
/integrate path --merge

# Full re-analysis of everything
/integrate full

# Check current state
/integrate status

# Incremental update
/integrate incremental

# Run classification only (route insights to global/local)
/integrate classify

# Full integration without classification
/integrate full --no-classify
```
