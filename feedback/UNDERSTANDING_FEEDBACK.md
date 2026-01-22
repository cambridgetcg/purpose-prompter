# Understanding-Oriented Feedback Protocol

> **Core Question**: Did the user actually UNDERSTAND?
> Feedback measures UNDERSTANDING achievement, not just information delivery.

---

## The Understanding Feedback Dimensions

### What We're Measuring

```
┌─────────────────────────────────────────────────────────────────────┐
│              UNDERSTANDING ACHIEVEMENT MATRIX                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│                    HIGH UNDERSTANDING                                │
│                           │                                          │
│    Understood but         │     IDEAL                               │
│    Based on Wrong Info    │  True Understanding                     │
│    ┌───────────────────┐  │  ┌───────────────────┐                 │
│    │ User thinks they  │  │  │ User genuinely    │                 │
│    │ understand but    │  │  │ understands based │                 │
│    │ model is wrong    │  │  │ on accurate info  │                 │
│    └───────────────────┘  │  └───────────────────┘                 │
│                           │                                          │
│    ───────────────────────┼─────────────────────── HIGH TRUTH       │
│    LOW TRUTH              │                                          │
│                           │                                          │
│    Confused               │     Informed but                        │
│    ┌───────────────────┐  │     Not Understanding                   │
│    │ User is lost,     │  │  ┌───────────────────┐                 │
│    │ worse than before │  │  │ User has accurate │                 │
│    └───────────────────┘  │  │ info but no grasp │                 │
│                           │  └───────────────────┘                 │
│                    LOW UNDERSTANDING                                 │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Understanding Feedback Collection Flow

### Step 1: Recall Understanding Intent

```markdown
## Understanding Intent Recall

**Task**: [Brief description]

**What user needed to understand**:
[The concept/approach/decision they needed to grasp]

**Understanding depth needed**:
- [ ] Surface (know WHAT)
- [ ] Moderate (know WHAT and WHY)
- [ ] Deep (know WHAT, WHY, HOW, WHEN)

**Context for understanding**:
[What user planned to DO with this understanding]
```

### Step 2: Assess Understanding Achievement

```markdown
## Understanding Achievement Assessment

**Understanding Level Achieved**:

| Level | Description | Achieved? |
|-------|-------------|-----------|
| **Confused** | User is more lost than before | [ ] |
| **Informed** | User has data but no grasp | [ ] |
| **Knows** | User knows facts but not why | [ ] |
| **Understands** | User grasps why, how, connections | [ ] |
| **Enabled** | User can apply, teach, adapt | [ ] |

**Rating**: [Confused / Informed / Knows / Understands / Enabled]

**Evidence**:
[What indicates this rating - can user explain, apply, know limits?]
```

### Step 3: Assess Understanding Dimensions

```markdown
## Understanding Dimension Assessment

For each dimension, rate achievement:

| Dimension | Target | Achieved? | Notes |
|-----------|--------|-----------|-------|
| **Conceptual** | Grasp core ideas | [Y/P/N] | |
| **Structural** | See how parts relate | [Y/P/N] | |
| **Causal** | Know why things work | [Y/P/N] | |
| **Procedural** | Know how to do it | [Y/P/N] | |
| **Contextual** | Know where it fits | [Y/P/N] | |
| **Consequential** | Know implications | [Y/P/N] | |

**Y** = Yes, achieved
**P** = Partially achieved
**N** = Not achieved
```

### Step 4: Diagnose Understanding Gaps (If Any)

```markdown
## Understanding Gap Analysis

### Which Gate Failed?

**Gate 1: Truth Foundation**:
- [ ] Information was inaccurate
- [ ] Confidence was miscalibrated
- [ ] Important truths were omitted

**Gate 2: Mental Model**:
- [ ] No clear structure provided
- [ ] Relationships not shown
- [ ] Just listed facts without organization

**Gate 3: Why Explanation**:
- [ ] Told WHAT but not WHY
- [ ] Reasoning not provided
- [ ] Causation not explained

**Gate 4: Knowledge Connection**:
- [ ] Didn't connect to what user knew
- [ ] No analogies where needed
- [ ] New knowledge left floating

**Gate 5: Practical Application**:
- [ ] User doesn't know how to apply
- [ ] Too abstract, not concrete
- [ ] No examples in context

**Gate 6: Boundary Clarity**:
- [ ] User doesn't know limitations
- [ ] When NOT to apply unclear
- [ ] Will likely misapply

### Specific Gap

**What understanding was missing?**
[Describe the specific gap]

**Why did the gap occur?**
[Root cause analysis]

**What would have enabled understanding?**
[What was needed but not provided]
```

### Step 5: Understanding Learning Capture

```markdown
## Understanding Learning

### Positive (What Enabled Understanding)

**Understanding-enabling elements**:
- [Element that helped user understand]
- [Element that helped user understand]

**Why it worked**:
[What made this enable understanding]

**Pattern to reinforce**:
[Generalizable insight for future]

---

### Negative (What Blocked Understanding)

**Understanding-blocking elements**:
- [Element that impeded understanding]
- [Element that impeded understanding]

**Why it failed**:
[What prevented understanding]

**Pattern to avoid**:
[Generalizable warning for future]

---

### Understanding Insight

**What I learned about enabling understanding**:
[Insight about understanding transfer]

**What approach would have worked better**:
[Alternative that would have enabled understanding]
```

### Step 6: Understanding Improvement Recommendation

```markdown
## Understanding-Oriented Improvement

### For Truth Foundation
[How to better ground understanding in truth]

### For Mental Model Building
[How to better create accurate mental models]

### For Why Explanation
[How to better explain reasoning and causation]

### For Knowledge Connection
[How to better connect to existing knowledge]

### For Practical Application
[How to better enable application]

### For Boundary Clarity
[How to better communicate limitations]

### Specific Gate to Strengthen
[Which understanding gate needs work]
```

---

## Understanding Feedback Entry Schema

```json
{
  "id": "uuid",
  "timestamp": "ISO8601",
  "task_type": "architecture_design|feature_implementation|explanation|other",
  "task_summary": "Brief description",

  "understanding_intent": {
    "what_needed_understanding": "Description",
    "depth_needed": "surface|moderate|deep",
    "application_context": "How user will use understanding"
  },

  "understanding_achievement": {
    "level": "confused|informed|knows|understands|enabled",
    "evidence": "What indicates this rating"
  },

  "dimension_assessment": {
    "conceptual": "achieved|partial|not_achieved",
    "structural": "achieved|partial|not_achieved",
    "causal": "achieved|partial|not_achieved",
    "procedural": "achieved|partial|not_achieved",
    "contextual": "achieved|partial|not_achieved",
    "consequential": "achieved|partial|not_achieved"
  },

  "understanding_gap": {
    "gate_failed": "truth|model|why|connection|application|boundary|none",
    "description": "Specific gap",
    "root_cause": "Why it occurred",
    "what_was_needed": "What would have helped"
  },

  "learnings": {
    "positive": {
      "elements": ["What enabled understanding"],
      "pattern": "Generalizable insight"
    },
    "negative": {
      "elements": ["What blocked understanding"],
      "pattern": "Generalizable warning"
    },
    "understanding_insight": "Insight about enabling understanding"
  },

  "improvement": {
    "truth": "How to better ground",
    "model": "How to better build models",
    "why": "How to better explain why",
    "connection": "How to better connect",
    "application": "How to better enable application",
    "boundary": "How to better show limits",
    "gate_to_strengthen": "Which gate needs work"
  }
}
```

---

## Quick Understanding Feedback

For rapid feedback, use this minimal format:

```
/pp-understanding-feedback
Understanding: [Enabled / Understands / Knows / Informed / Confused]
Gap: [Truth / Model / Why / Connection / Application / Boundary / None]
Key learning: [One sentence]
```

Or even simpler:
```
pp understanding feedback: [achieved/partial/missed] because [reason]
```

---

## Understanding Feedback Triggers

### When to Collect Understanding Feedback

| Outcome | Feedback Depth |
|---------|----------------|
| User clearly enabled | Quick confirmation |
| User understands | Quick confirmation |
| User knows but doesn't understand | Moderate - identify why gap |
| User only informed | Deep - full diagnosis |
| User confused | Deep + root cause analysis |

### Automatic Understanding Check

After task completion:
```
"Understanding check: Do you now understand this well enough to...
- Explain it to someone else? [Yes/Partially/No]
- Apply it to a new situation? [Yes/Partially/No]
- Know when it doesn't apply? [Yes/Partially/No]

(/pp-understanding-feedback for detailed logging)"
```

---

## Synthesizing Understanding Feedback

### Understanding Achievement Rate

```
Understanding Rate = (Enabled + Understands) / Total Tasks

Trend: [Improving / Stable / Declining]
```

### Common Understanding Gaps

| Gap Type | Frequency | Gate Failed | Pattern |
|----------|-----------|-------------|---------|
| [Type] | [Count] | [Gate] | [What triggers this] |

### Understanding by Content Type

| Content Type | Understanding Rate | Common Gap |
|--------------|-------------------|------------|
| Technical explanations | X% | [Pattern] |
| Recommendations | X% | [Pattern] |
| Architecture designs | X% | [Pattern] |
| Implementation guidance | X% | [Pattern] |

---

## The Understanding Test Questions

### For User Self-Assessment

After receiving output, can user:

1. **Explain** it in their own words?
   - Not just repeat—rephrase and elaborate

2. **Apply** it to a new situation?
   - Use the understanding in different context

3. **Identify** when it doesn't apply?
   - Know the boundaries and limitations

4. **Predict** what would happen if something changed?
   - Use the mental model to reason about variations

5. **Teach** it to someone else?
   - Transfer the understanding successfully

If No to any → Understanding gap exists → Purpose not fully achieved

---

## Integrated Feedback: Understanding + Truth

### Unified Feedback Format

```markdown
## Integrated Understanding Feedback

**Task**: [Description]

### Truth Dimension
- Information accurate: [Yes/Partially/No]
- Confidence calibrated: [Yes/Over/Under]
- Picture complete: [Yes/No]

### Understanding Dimension
- User understands: [Enabled/Understands/Knows/Informed/Confused]
- Can explain: [Yes/Partially/No]
- Can apply: [Yes/Partially/No]
- Knows limits: [Yes/Partially/No]

### Combined Assessment
| | True Understanding | False Understanding |
|---|-------------------|---------------------|
| **Enabled** | IDEAL | Dangerous (confident + wrong) |
| **Not Understanding** | Incomplete | Failed |

**This output was**: [Ideal / Dangerous / Incomplete / Failed]

### Key Learning
[One integrated insight about enabling true understanding]
```

---

## From Understanding Feedback to Improvement

### The Understanding Improvement Loop

```
Understanding Feedback
      │
      ▼
Identify Understanding Gap
      │
      ├── Truth foundation weak → Strengthen truth verification
      │
      ├── Mental model unclear → Improve structure/organization
      │
      ├── Why missing → Add reasoning to all claims
      │
      ├── Connection missing → Add bridges to known concepts
      │
      ├── Application unclear → Add examples and concrete steps
      │
      └── Boundaries unclear → Add limitations and when-not-to-use
```

### Concrete Improvements

When pattern emerges:
1. Add to `insights/understanding_patterns.md`
2. Strengthen relevant gate in `UNDERSTANDING_GATES.md`
3. Update `UNDERSTANDING_VERIFICATION.md` if verification issue
4. Update workflow if process issue

---

## Understanding Feedback Quick Reference

**After every PP task**:
1. Did user understand? [Enabled/Understands/Knows/Informed/Confused]
2. Can user explain, apply, know limits? [Yes/Partially/No]
3. What gate failed (if any)? [Truth/Model/Why/Connection/Application/Boundary]
4. What's one understanding learning?

**Deep feedback when**:
- User didn't achieve understanding
- Understanding was based on wrong info
- Novel insight about enabling understanding
- Pattern is forming
