# Feedback Collection Protocol

> **Trigger**: `/pp-feedback` or `pp feedback: [description]`

---

## When to Collect Feedback

### Automatic Prompts (Claude should ask)

After completing a PP-guided task, ask:
```
"Task complete. Quick feedback to improve the framework?
- What worked well?
- What was missing or wrong?
- Any blindspots I should watch for?"
```

### User-Initiated

User can provide feedback anytime with:
- `/pp-feedback` - Opens structured feedback flow
- `pp feedback: [quick note]` - Quick unstructured feedback

---

## Collection Flow

### Step 1: Gather Context

```markdown
## Feedback Collection

**Task Type**: [architecture_design / feature_implementation / other]
**Task Summary**: [Brief description from conversation]
**Date**: [Current date]
```

### Step 2: Assess Outcome

Ask or infer:
```
**Outcome**:
- [ ] Success - Completed correctly first time
- [ ] Partial - Needed adjustments
- [ ] Failure - Significant issues

**Description**: [What happened]
```

### Step 3: Identify Gaps (if any)

For Partial or Failure outcomes:
```
**What was missed?**

Gap 1:
- Type: [blindspot / assumption / requirement / edge_case]
- Description: [What was missed]
- Severity: [low / medium / high]
- When should this have been caught: [Phase/Gate]

Gap 2:
- ...
```

### Step 4: Score Quality

```
**Quality Scores** (1-5):
- Completeness: [_] - Were all requirements addressed?
- Correctness: [_] - Was logic/implementation correct?
- Clarity: [_] - Was output clear and well-explained?
- Efficiency: [_] - Was the process efficient?
```

### Step 5: Pattern Assessment

```
**What worked well?**
- [Specific technique, pattern, or approach]

**What didn't work?**
- [Specific technique, pattern, or approach]
```

### Step 6: Capture Learning

```
**Key Learning**:
- Positive (do more): [What to reinforce]
- Negative (avoid/check): [What to prevent]

**Suggested Framework Improvement**:
[Specific change to make]
```

---

## Quick Feedback Template

For rapid feedback, use this minimal format:

```
/pp-feedback
Task: [brief description]
Outcome: [success/partial/failure]
Gap: [what was missed, if any]
Learning: [one sentence]
```

---

## Write to Log

After collection, append to `~/.claude/purpose_prompter/feedback/entries.jsonl`:

```json
{
  "id": "[generate-uuid]",
  "timestamp": "[ISO8601]",
  "task_type": "[from step 1]",
  "task_summary": "[from step 1]",
  "outcome": {
    "status": "[from step 2]",
    "description": "[from step 2]"
  },
  "gaps": [
    {
      "type": "[from step 3]",
      "description": "[from step 3]",
      "severity": "[from step 3]",
      "should_have_caught": "[from step 3]"
    }
  ],
  "quality_scores": {
    "completeness": [from step 4],
    "correctness": [from step 4],
    "clarity": [from step 4],
    "efficiency": [from step 4]
  },
  "patterns": {
    "worked_well": ["from step 5"],
    "didnt_work": ["from step 5"]
  },
  "learnings": {
    "positive": "[from step 6]",
    "negative": "[from step 6]"
  },
  "suggested_improvement": "[from step 6]"
}
```

---

## Implicit Feedback Signals

Also track these signals automatically:

| Signal | Interpretation | Weight |
|--------|----------------|--------|
| User accepted output without changes | Likely success | +1 |
| User asked for corrections | Partial success | 0 |
| User asked to redo significantly | Failure | -1 |
| User explicitly praised | Strong success | +2 |
| User explicitly criticized | Strong failure | -2 |
| Follow-up questions needed | Incomplete | -0.5 |

---

## After Collection

1. Confirm feedback logged:
   ```
   "Feedback recorded. Entry #[N] added to learning system."
   ```

2. If high-severity gap identified:
   ```
   "High-severity blindspot detected. Consider running /pp-review
   to synthesize learnings."
   ```

3. Periodic reminder (every 5 tasks):
   ```
   "You have [N] feedback entries. Run /pp-review to synthesize
   patterns and improve the framework."
   ```
