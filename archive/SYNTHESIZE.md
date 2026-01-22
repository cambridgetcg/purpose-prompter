# Feedback Synthesis Protocol

> **Trigger**: `/pp-review`

---

## Purpose

Analyze accumulated feedback to identify:
1. **Recurring blindspots** - Things consistently missed
2. **Common mistakes** - Errors that repeat
3. **Effective patterns** - Approaches that work well
4. **Framework gaps** - Missing checks or steps

---

## Synthesis Flow

### Step 1: Load Feedback Data

```
Read: ~/.claude/purpose_prompter/feedback/entries.jsonl
Count: [N] entries since last review
Period: [date range]
```

### Step 2: Aggregate by Category

#### 2.1 Outcome Distribution

```markdown
## Outcome Summary

| Outcome | Count | Percentage |
|---------|-------|------------|
| Success | X | X% |
| Partial | Y | Y% |
| Failure | Z | Z% |

**Trend**: [Improving / Stable / Declining]
```

#### 2.2 Gap Analysis

```markdown
## Gap Frequency Analysis

### By Type
| Gap Type | Count | Avg Severity |
|----------|-------|--------------|
| Blindspot | X | [high/med/low] |
| Assumption | Y | [high/med/low] |
| Requirement | Z | [high/med/low] |
| Edge Case | W | [high/med/low] |

### Top Blindspots (Recurring)
1. [Description] - Occurred X times
2. [Description] - Occurred Y times
3. [Description] - Occurred Z times

### Top Mistakes (By Severity × Frequency)
1. [Description] - Severity: High, Frequency: X
2. [Description] - Severity: Med, Frequency: Y
3. [Description] - Severity: High, Frequency: Z
```

#### 2.3 Quality Score Trends

```markdown
## Quality Score Averages

| Dimension | Average | Trend |
|-----------|---------|-------|
| Completeness | X.X | [↑/→/↓] |
| Correctness | X.X | [↑/→/↓] |
| Clarity | X.X | [↑/→/↓] |
| Efficiency | X.X | [↑/→/↓] |

**Weakest Dimension**: [Dimension] - Focus improvement here
```

#### 2.4 Pattern Effectiveness

```markdown
## Pattern Analysis

### Most Effective (Correlated with Success)
1. [Pattern/Approach] - Success rate: X%
2. [Pattern/Approach] - Success rate: Y%

### Least Effective (Correlated with Failure)
1. [Pattern/Approach] - Failure rate: X%
2. [Pattern/Approach] - Failure rate: Y%

### Underutilized (Suggested but rarely used)
1. [Pattern/Approach] - Consider using more for [context]
```

---

### Step 3: Identify Actionable Patterns

#### 3.1 Blindspot Clustering

Group similar blindspots:
```markdown
## Blindspot Clusters

### Cluster: [Theme Name]
Related blindspots:
- [Blindspot 1]
- [Blindspot 2]
- [Blindspot 3]

**Root Cause**: [Why these are being missed]
**Recommended Check**: [Specific verification to add]
```

#### 3.2 Mistake Root Cause Analysis

For each recurring mistake:
```markdown
## Mistake Analysis: [Mistake Description]

**Frequency**: X occurrences
**Severity**: [High/Med/Low]
**When it occurs**: [Phase/Context]

**Root Cause Analysis**:
1. Why did this happen? [Immediate cause]
2. Why wasn't it caught? [Process gap]
3. Why does it recur? [Systemic issue]

**Prevention Strategy**:
- Add check at [specific gate/step]
- Modify [workflow/pattern] to include [verification]
```

#### 3.3 Success Pattern Extraction

For highly effective patterns:
```markdown
## Success Pattern: [Pattern Name]

**When used**: [Context]
**Success rate**: X%
**Key characteristics**:
- [What makes this effective]
- [What makes this effective]

**Recommendation**: [How to reinforce/expand use]
```

---

### Step 4: Generate Improvement Recommendations

```markdown
## Recommended Framework Updates

### Priority 1: Critical (Address Immediately)

#### Update 1: [Title]
- **Target**: [File to modify]
- **Change**: [Specific change]
- **Rationale**: [Based on X feedback entries showing Y]

### Priority 2: Important (Address Soon)

#### Update 2: [Title]
- **Target**: [File to modify]
- **Change**: [Specific change]
- **Rationale**: [Based on pattern analysis]

### Priority 3: Enhancement (When Convenient)

#### Update 3: [Title]
- **Target**: [File to modify]
- **Change**: [Specific change]
- **Rationale**: [Would improve Z]
```

---

### Step 5: Write Insights

Output to `~/.claude/purpose_prompter/insights/`:

#### patterns.md
```markdown
# Synthesized Patterns
*Last updated: [date]*
*Based on: [N] feedback entries*

## Key Findings
[Summary of analysis]

## Top Blindspots
[From Step 2.2]

## Top Mistakes
[From Step 2.2]

## Effective Patterns
[From Step 2.4]

## Recommendations
[From Step 4]
```

#### blindspots.md
```markdown
# Known Blindspots Checklist
*Auto-generated from feedback synthesis*

## Always Check For:

### Architecture Design
- [ ] [Blindspot from feedback]
- [ ] [Blindspot from feedback]

### Feature Implementation
- [ ] [Blindspot from feedback]
- [ ] [Blindspot from feedback]

### General
- [ ] [Blindspot from feedback]
```

#### mistakes.md
```markdown
# Common Mistakes to Avoid
*Auto-generated from feedback synthesis*

## Mistake: [Title]
- **What happens**: [Description]
- **Why it's wrong**: [Impact]
- **Prevention**: [How to avoid]
- **Detection**: [How to catch if made]

[Repeat for each common mistake]
```

---

### Step 6: Summary Report

Present to user:
```markdown
## PP Review Complete

### Feedback Analyzed
- Entries reviewed: [N]
- Period: [date range]

### Key Findings
- Success rate: [X%]
- Most common blindspot: [Description]
- Most common mistake: [Description]
- Weakest quality dimension: [Dimension]

### Recommended Actions
1. [Highest priority action]
2. [Second priority action]
3. [Third priority action]

Run `/pp-refine` to apply these learnings to the framework.
```

---

## Review Triggers

### Automatic Suggestions
Suggest running `/pp-review` when:
- 5+ new feedback entries since last review
- High-severity gap reported
- 2+ failures in recent tasks
- Monthly (if not run)

### User-Initiated
User can run `/pp-review` anytime to see current state.
