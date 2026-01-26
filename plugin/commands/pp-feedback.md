---
description: "Log structured feedback on PP task completion - captures truth, understanding, beauty, justice, and creativity assessments for learning"
argument-hint: "[dimension] [rating] [reason] - e.g., 'beauty partial because forced elegance'"
allowed-tools: [Read, Write, Bash]
model: haiku
---

# PP Feedback Command

Log structured feedback after a PP task to enable framework learning and self-improvement.

## Arguments

Feedback specification: $ARGUMENTS

## Purpose

Feedback is how PP learns. Every logged entry contributes to:
- Pattern recognition across tasks
- Blindspot identification
- Framework refinement
- Convergence toward perfect alignment

## Feedback Format

### Quick Feedback (with arguments)

```
/pp-feedback [dimension] [rating] [reason]

Examples:
/pp-feedback beauty pass emerged naturally from understanding
/pp-feedback justice partial placement unclear, needed more codebase understanding
/pp-feedback truth fail claimed without citation
```

**Dimensions**: truth, understanding, beauty, justice, creativity, overall
**Ratings**: pass, partial, fail

### Full Feedback (without arguments)

If no arguments provided, prompt for complete assessment:

```markdown
## PP Task Feedback

**Task**: [What was accomplished]
**Date**: [Timestamp]

### Dimension Ratings

| Dimension | Rating | Notes |
|-----------|--------|-------|
| Truth | [pass/partial/fail] | [Brief note] |
| Understanding | [pass/partial/fail] | [Brief note] |
| Beauty | [pass/partial/fail] | [Brief note] |
| Justice | [pass/partial/fail] | [Brief note] |
| Creativity | [pass/partial/fail/na] | [Brief note] |

### What Worked
[Specific things that went well]

### What Didn't Work
[Specific issues encountered]

### Key Learning
[Most important insight from this task]

### Improvement Suggestion
[How could PP be better?]
```

## Storage

Append feedback to: `~/.claude/purpose_prompter/feedback/entries.jsonl`

**Entry format**:
```json
{
  "timestamp": "ISO8601",
  "task": "brief description",
  "ratings": {
    "truth": "pass|partial|fail",
    "understanding": "pass|partial|fail",
    "beauty": "pass|partial|fail",
    "justice": "pass|partial|fail",
    "creativity": "pass|partial|fail|na"
  },
  "scores": {
    "truth": 100,
    "understanding": 100,
    "beauty": 50,
    "justice": 50,
    "creativity": 100,
    "alignment": 80
  },
  "notes": {
    "truth": "note",
    "understanding": "note",
    "beauty": "note",
    "justice": "note",
    "creativity": "note"
  },
  "worked": ["list of successes"],
  "failed": ["list of issues"],
  "learning": "key insight",
  "suggestion": "improvement idea",
  "hypothesis": {
    "prediction": "optional: what I expected to happen",
    "validated": true
  }
}
```

### Quantitative Scoring

Convert qualitative ratings to scores for tracking:

```
Rating    → Score
─────────────────
pass      → 100
partial   → 50
fail      → 0
n/a       → (excluded from alignment)

Alignment Score = Average of applicable dimension scores
```

**Example**:
```
truth: pass (100), understanding: pass (100), beauty: partial (50),
justice: partial (50), creativity: n/a (excluded)

Alignment = (100 + 100 + 50 + 50) / 4 = 75%
```

### Hypothesis Tracking (Optional)

For PP self-improvement experiments, track predictions:

```json
"hypothesis": {
  "prediction": "Using /territory before implementation will improve justice scores",
  "baseline": "Previous 3 entries averaged 60% justice",
  "validated": true,
  "actual": "This entry: justice pass (100%)"
}
```

This enables:
- Measuring whether PP changes improve outcomes
- Validated learning about what works
- Data-driven framework refinement

## Process

1. Parse arguments or prompt for full feedback
2. Validate dimension and rating
3. Create JSON entry
4. Append to entries.jsonl
5. Confirm logged

## Feedback Patterns

Watch for these patterns across entries:

**Truth patterns**:
- Frequent "fail" → Need stronger Citation Gate enforcement
- "partial" with "no citation" → Verification-first not followed

**Understanding patterns**:
- Frequent "partial" → May be rushing to implementation
- "fail" with "didn't explain why" → Mental model building incomplete

**Beauty patterns**:
- "partial" with "forced" → Didn't understand problem deeply enough
- "fail" with "ugly but works" → Polishing instead of understanding

**Justice patterns**:
- "partial" with "placement unclear" → Codebase understanding gap
- "fail" with "wrong location" → Evidence Gate not applied

**Creativity patterns**:
- "fail" with "forced into existing" → Didn't recognize uncharted territory
- "partial" with "path incomplete" → Rushed to implement before building path

## Integration

After logging, suggest:
- `/pp-review` to synthesize patterns (after 5+ entries)
- `/pp-learnings` to view accumulated knowledge
- `/pp-refine` to apply learnings to framework

## Example Usage

```
User: /pp-feedback justice partial needed more codebase exploration before placing