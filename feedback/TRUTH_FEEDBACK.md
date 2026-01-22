# Truth-Oriented Feedback Protocol

> **Core Question**: Was the output truthful and honest?
> Feedback measures TRUTH ALIGNMENT alongside purpose alignment.

---

## Feedback Dimensions

### The Two Dimensions of Quality

```
                    HIGH TRUTH ALIGNMENT
                           │
                           │
    Useless but Honest     │     IDEAL
    (Accurate but doesn't  │  (Serves purpose with
     serve purpose)        │   accurate information)
                           │
    ───────────────────────┼─────────────────────── HIGH PURPOSE
    LOW PURPOSE            │                        ALIGNMENT
                           │
    Worst                  │     Dangerous
    (Wrong and useless)    │  (Serves purpose but
                           │   based on falsehood)
                           │
                    LOW TRUTH ALIGNMENT
```

---

## Truth Feedback Collection Flow

### Step 1: Recall Truth Claims

```markdown
## Truth Claims Recall

**Task**: [Brief description]

**Key Claims Made**:
1. [Claim 1]
2. [Claim 2]
3. [Claim 3]

**Confidence Expressed**:
- [High/Medium/Low] for [which claims]

**Uncertainties Acknowledged**:
- [What was marked uncertain]
```

### Step 2: Assess Truth Alignment

```markdown
## Truth Alignment Assessment

**For each significant claim**:

| Claim | Accurate? | Appropriately Confident? | Complete? |
|-------|-----------|-------------------------|-----------|
| [1] | [Yes/No/Partially] | [Yes/Over/Under] | [Yes/No] |
| [2] | [Yes/No/Partially] | [Yes/Over/Under] | [Yes/No] |

**Overall Truth Alignment**:
| Level | Description |
|-------|-------------|
| **Illuminated** | Revealed deeper truths, exceeded factual needs |
| **Represented** | Accurate and honest about uncertainty |
| **Partial** | True but incomplete, missing context |
| **Distorted** | Contains errors or misrepresentations |
| **Opposed** | Actively false or misleading |

**Rating**: [Illuminated / Represented / Partial / Distorted / Opposed]

**Evidence**:
[What indicates this rating?]
```

### Step 3: Diagnose Truth Misalignment (If Any)

```markdown
## Truth Misalignment Analysis

### Which Truth Dimension Failed?

**Factual Truth**:
- [ ] Incorrect facts stated
- [ ] Hallucinated information
- [ ] Outdated information presented as current

**Logical Truth**:
- [ ] Invalid reasoning
- [ ] Conclusions didn't follow from premises
- [ ] Logical fallacies

**Epistemic Truth**:
- [ ] Overconfidence - stated uncertain things as certain
- [ ] Underconfidence - hedged when should have been direct
- [ ] Failed to acknowledge uncertainty

**Representational Truth**:
- [ ] Incomplete picture presented
- [ ] Trade-offs omitted
- [ ] One-sided presentation

**Self-Truth**:
- [ ] Failed to acknowledge limitations
- [ ] Claimed knowledge I didn't have

### Specific Misalignment

**What was false/misleading?**
[Describe specific truth issue]

**Why did it happen?**
- [ ] Hallucination - pattern-matched incorrectly
- [ ] Overconfidence - assumed more certainty than warranted
- [ ] Omission - left out inconvenient truth
- [ ] Outdated - knowledge was stale
- [ ] Context-blindness - didn't account for specifics
- [ ] Reasoning error - logic was flawed

**What should have been said instead?**
[The truthful alternative]
```

### Step 4: Truth Learning Capture

```markdown
## Truth Learning

### Positive (What Was Truthful)

**Truth-Aligned Elements**:
- [Element that was accurate and honest]
- [Element that appropriately acknowledged uncertainty]

**Why It Worked**:
[What made this truthful]

**Pattern to Reinforce**:
[Generalizable insight for future]

---

### Negative (What Was Untruthful)

**Truth-Misaligned Elements**:
- [Element that was inaccurate or misleading]
- [Element that was overconfident or incomplete]

**Why It Failed**:
[What caused truth misalignment]

**Pattern to Avoid**:
[Generalizable warning for future]

---

### Truth Insight

**What I learned about staying truthful in this context**:
[Insight about truth patterns]

**What verification would have caught this**:
[How to prevent similar issues]
```

### Step 5: Truth Improvement Recommendation

```markdown
## Truth-Oriented Improvement

### For Grounding
[How to better ground claims of this type]

### For Calibration
[How to better calibrate confidence]

### For Counter-Consideration
[What counters should have been considered]

### For Completeness
[What should have been included]

### For Representation
[How language should have been different]

### Specific Gate to Strengthen
[Which truth gate needs work]
```

---

## Truth Feedback Entry Schema

```json
{
  "id": "uuid",
  "timestamp": "ISO8601",
  "task_type": "architecture_design|feature_implementation|other",
  "task_summary": "Brief description",

  "truth_claims": [
    {
      "claim": "What was claimed",
      "accuracy": "accurate|inaccurate|partially_accurate",
      "confidence_expressed": "high|medium|low",
      "confidence_appropriate": "yes|overconfident|underconfident",
      "complete": "yes|no"
    }
  ],

  "truth_alignment": {
    "level": "illuminated|represented|partial|distorted|opposed",
    "evidence": "What indicates this rating"
  },

  "truth_misalignment": {
    "dimension": "factual|logical|epistemic|representational|self|none",
    "type": "hallucination|overconfidence|omission|outdated|context_blind|reasoning_error|none",
    "description": "Specific issue",
    "root_cause": "Why it happened",
    "correction": "What should have been said"
  },

  "learnings": {
    "positive": {
      "elements": ["What was truthful"],
      "pattern": "Generalizable insight"
    },
    "negative": {
      "elements": ["What was untruthful"],
      "pattern": "Generalizable warning"
    },
    "truth_insight": "Insight about truth patterns"
  },

  "improvement": {
    "grounding": "How to better ground",
    "calibration": "How to better calibrate",
    "counter": "What to consider",
    "completeness": "What to include",
    "representation": "How to phrase",
    "gate_to_strengthen": "Which gate needs work"
  }
}
```

---

## Quick Truth Feedback

For rapid feedback, use this minimal format:

```
/pp-truth-feedback
Truth: [Aligned / Partial / Misaligned]
Issue: [Hallucination / Overconfidence / Omission / None]
Key learning: [One sentence]
```

Or even simpler:
```
pp truth feedback: [hit/miss] because [reason]
```

---

## Truth Feedback Triggers

### When to Collect Truth Feedback

| Outcome | Feedback Depth |
|---------|----------------|
| Claims verified accurate | Quick confirmation |
| Minor inaccuracies | Moderate - identify gaps |
| Significant errors | Deep - full diagnosis |
| Misleading output | Deep + root cause analysis |

### Automatic Truth Check

After task completion:
```
"Truth check: Was the information accurate?
- Yes, claims were accurate
- Partially, some inaccuracies
- No, significant errors
- Confidence was miscalibrated

(Reply or /pp-truth-feedback for detailed logging)"
```

---

## Synthesizing Truth Feedback

### Truth Hit Rate

```
Truth Hit Rate = (Illuminated + Represented) / Total Tasks

Trend: [Improving / Stable / Declining]
```

### Common Truth Issues

| Issue Type | Frequency | Trigger Pattern |
|------------|-----------|-----------------|
| Hallucination | [Count] | [What triggers this] |
| Overconfidence | [Count] | [What triggers this] |
| Omission | [Count] | [What triggers this] |
| Outdated info | [Count] | [What triggers this] |

### Truth by Claim Type

| Claim Type | Accuracy Rate | Common Issue |
|------------|---------------|--------------|
| Technical facts | X% | [Pattern] |
| Recommendations | X% | [Pattern] |
| Explanations | X% | [Pattern] |
| Predictions | X% | [Pattern] |

---

## Integrated Feedback: Purpose + Truth

### Unified Feedback Format

```markdown
## Integrated Feedback

**Task**: [Description]

### Purpose Dimension
- Purpose understood: [Yes/Partially/No]
- Purpose achieved: [Yes/Partially/No]
- Where purpose broke: [Extraction/Design/Execution/None]

### Truth Dimension
- Claims accurate: [Yes/Partially/No]
- Confidence calibrated: [Yes/Over/Under]
- Complete picture: [Yes/No]
- Where truth broke: [Grounding/Calibration/Counter/Completeness/Representation/None]

### Combined Assessment
| | Purpose Achieved | Purpose Missed |
|---|-----------------|----------------|
| **Truth Aligned** | IDEAL | Useless but honest |
| **Truth Misaligned** | Dangerous | Worst |

**This output was**: [Ideal / Useless / Dangerous / Worst]

### Key Learning
[One integrated insight about purpose+truth]
```

### Quick Integrated Feedback

```
/pp-feedback
Purpose: [Hit/Miss]
Truth: [Hit/Miss]
Learning: [One sentence]
```

---

## From Truth Feedback to Improvement

### The Truth Improvement Loop

```
Truth Feedback
      │
      ▼
Identify Truth Issue Type
      │
      ├── Hallucination → Add grounding checks
      │
      ├── Overconfidence → Strengthen calibration
      │
      ├── Omission → Improve completeness checks
      │
      ├── Outdated → Add currency verification
      │
      └── Reasoning error → Improve counter-consideration
```

### Concrete Improvements

When pattern emerges:
1. Add to `insights/truth_patterns.md`
2. Add check to relevant gate in `TRUTH_GATES.md`
3. Update `TRUTH_VERIFICATION.md` if verification issue
4. Update workflow if process issue

---

## Truth Feedback Quick Reference

**After every PP task**:
1. Were claims accurate? [Yes/Partially/No]
2. Was confidence appropriate? [Yes/Over/Under]
3. Was picture complete? [Yes/No]
4. What's one truth learning?

**Deep feedback when**:
- Claims were inaccurate
- Confidence was miscalibrated
- Important information omitted
- Novel truth insight emerged
