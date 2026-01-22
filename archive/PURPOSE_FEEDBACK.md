# Purpose-Oriented Feedback Protocol

> **Core Question**: Did the output serve the true purpose?
> Feedback measures PURPOSE ALIGNMENT, not just technical quality.

---

## Feedback Reframed

### Old Feedback Questions
- What worked well? ❌
- What was missing? ❌
- What was wrong? ❌

### New Purpose-Oriented Questions
- Did this serve your actual purpose? ✓
- Where did it miss the purpose? ✓
- What was the purpose I should have understood? ✓
- Where did purpose alignment break down? ✓

---

## Purpose Feedback Collection Flow

### Step 1: Recall the Purpose

```markdown
## Purpose Recall

**Task**: [Brief description]

**Stated Purpose** (from extraction):
[The purpose statement from task start]

**Actual Purpose** (in hindsight):
[User confirms or corrects the purpose understanding]

**Purpose Match**: [Aligned / Partially Aligned / Misaligned]
```

### Step 2: Assess Purpose Achievement

```markdown
## Purpose Achievement

**Core Question**: Did the output enable the user to achieve their purpose?

| Level | Description |
|-------|-------------|
| **Purpose Achieved** | User can/did accomplish what they needed |
| **Purpose Partially Achieved** | Some of the purpose served, gaps remain |
| **Purpose Not Achieved** | Output doesn't enable purpose achievement |
| **Purpose Opposed** | Output works against the purpose |

**Rating**: [Achieved / Partially / Not Achieved / Opposed]

**Evidence**:
[What indicates this rating?]
```

### Step 3: Diagnose Purpose Misalignment (If Any)

```markdown
## Purpose Misalignment Analysis

### Where Did Alignment Break?

**Extraction Phase**:
- [ ] Purpose was incorrectly understood
- [ ] Wrong assumptions about intent
- [ ] Missed contextual factors
- [ ] User's purpose was unclear/evolving

**Design Phase**:
- [ ] Approach didn't serve purpose
- [ ] Solved different problem
- [ ] Over-scoped beyond purpose
- [ ] Under-scoped for purpose

**Execution Phase**:
- [ ] Implementation drifted from purpose
- [ ] Details undermined purpose
- [ ] Quality issues affected purpose

### Specific Misalignment

**What was the gap?**
[Describe specific purpose misalignment]

**Why did it happen?**
[Root cause of misalignment]

**What signal was missed?**
[What could have indicated correct purpose?]
```

### Step 4: Purpose Learning Capture

```markdown
## Purpose Learning

### Positive (What Served Purpose Well)

**Purpose-Serving Elements**:
- [Element that served purpose]
- [Element that served purpose]

**Why It Worked**:
[What made this purpose-aligned]

**Pattern to Reinforce**:
[Generalizable insight for future]

---

### Negative (What Missed Purpose)

**Purpose-Missing Elements**:
- [Element that missed purpose]
- [Element that missed purpose]

**Why It Missed**:
[What caused purpose misalignment]

**Pattern to Avoid**:
[Generalizable warning for future]

---

### Purpose Insight

**What I learned about this type of purpose**:
[Insight about purpose patterns]

**What I learned about Yu's purposes**:
[Insight about user-specific purpose patterns]
```

### Step 5: Improvement Recommendation

```markdown
## Purpose-Oriented Improvement

### For Purpose Extraction
[How to better extract this type of purpose]

### For Purpose Alignment
[How to better align solutions to purpose]

### For Purpose Gates
[What checks would have caught this misalignment]

### Specific Framework Change
[Concrete change to make to PP framework]
```

---

## Purpose Feedback Entry Schema

```json
{
  "id": "uuid",
  "timestamp": "ISO8601",
  "task_type": "architecture_design|feature_implementation|other",
  "task_summary": "Brief description",

  "purpose": {
    "stated_purpose": "Purpose extracted at task start",
    "actual_purpose": "Purpose confirmed/corrected in hindsight",
    "purpose_match": "aligned|partially_aligned|misaligned"
  },

  "achievement": {
    "level": "achieved|partially|not_achieved|opposed",
    "evidence": "What indicates this rating"
  },

  "misalignment": {
    "phase": "extraction|design|execution|none",
    "type": "wrong_purpose|over_scope|under_scope|drift|quality|none",
    "description": "Specific misalignment",
    "root_cause": "Why it happened",
    "missed_signal": "What could have indicated correct path"
  },

  "learnings": {
    "positive": {
      "elements": ["What served purpose"],
      "pattern": "Generalizable insight"
    },
    "negative": {
      "elements": ["What missed purpose"],
      "pattern": "Generalizable warning"
    },
    "purpose_insight": "Insight about purpose patterns"
  },

  "improvement": {
    "extraction": "How to better extract purpose",
    "alignment": "How to better align",
    "gates": "What checks to add",
    "specific_change": "Concrete framework change"
  }
}
```

---

## Quick Purpose Feedback

For rapid feedback, use this minimal format:

```
/pp-feedback
Purpose: [Achieved / Partially / Missed]
Where it broke: [Extraction / Design / Execution / None]
Key learning: [One sentence]
```

Or even simpler:
```
pp feedback: purpose [hit/miss] because [reason]
```

---

## Purpose Feedback Triggers

### When to Collect Feedback

**Always** after PP tasks, but depth varies:

| Outcome | Feedback Depth |
|---------|----------------|
| Purpose clearly achieved | Quick confirmation |
| Purpose partially achieved | Moderate - identify gaps |
| Purpose missed | Deep - full diagnosis |
| Purpose opposed | Deep + root cause analysis |

### Automatic Purpose Check

After task completion:
```
"Purpose check: Did this serve your actual purpose?
- Yes, purpose achieved
- Partially, some gaps
- No, missed the purpose
- Actually, the purpose was different

(Reply or /pp-feedback for detailed logging)"
```

---

## Synthesizing Purpose Feedback

### Purpose Hit Rate

```
Purpose Hit Rate = (Achieved + Partially) / Total Tasks

Trend: [Improving / Stable / Declining]
```

### Common Purpose Misalignments

| Misalignment Type | Frequency | Phase | Pattern |
|-------------------|-----------|-------|---------|
| [Type] | [Count] | [Phase] | [What triggers this] |

### Purpose Extraction Failures

| Failure Mode | Frequency | Signal Missed |
|--------------|-----------|---------------|
| [Mode] | [Count] | [What to look for] |

### Purpose Drift Patterns

| Drift Type | Frequency | Prevention |
|------------|-----------|------------|
| Scope creep | [Count] | [How to prevent] |
| Problem substitution | [Count] | [How to prevent] |
| Over-engineering | [Count] | [How to prevent] |

---

## Purpose Learning Accumulation

### By Purpose Type

Track which purpose types are well-served vs poorly-served:

| Purpose Type | Hit Rate | Common Miss | Learning |
|--------------|----------|-------------|----------|
| Efficiency | X% | [Pattern] | [Insight] |
| Capability | X% | [Pattern] | [Insight] |
| Understanding | X% | [Pattern] | [Insight] |

### By Task Type

| Task Type | Purpose Hit Rate | Common Misalignment |
|-----------|------------------|---------------------|
| Architecture | X% | [Pattern] |
| Implementation | X% | [Pattern] |

### Yu-Specific Purpose Patterns

Over time, learn Yu's purpose patterns:

```markdown
## Yu's Purpose Patterns

### Common Purpose Types Yu Has
- [Type 1]: [How to recognize, how to serve]
- [Type 2]: [How to recognize, how to serve]

### Yu's Purpose Signals
- When Yu says X, purpose is usually Y
- When context includes A, purpose likely includes B

### Yu's Purpose Priorities
- Values [X] in solutions
- Prefers [Y] approach
- Dislikes [Z] when purpose is [W]
```

---

## From Feedback to Improvement

### The Purpose Improvement Loop

```
Purpose Feedback
      │
      ▼
Identify Misalignment Pattern
      │
      ├── Extraction failure → Improve PURPOSE_EXTRACTION.md
      │
      ├── Alignment failure → Improve PURPOSE_GATES.md
      │
      ├── Drift pattern → Add drift checks to workflow
      │
      └── Purpose type insight → Add to purpose learnings
```

### Concrete Improvements

When pattern emerges:
1. Add to `insights/purpose_patterns.md`
2. Add check to relevant gate in `PURPOSE_GATES.md`
3. Update `PURPOSE_EXTRACTION.md` if extraction issue
4. Update workflow if process issue

---

## Purpose Feedback Quick Reference

**After every PP task**:
1. Did this achieve your purpose? [Yes/Partially/No]
2. If not fully: Where did alignment break?
3. What's one thing to learn for next time?

**Deep feedback when**:
- Purpose was missed
- Something surprising happened
- Novel insight emerged
- Pattern seems to be forming
