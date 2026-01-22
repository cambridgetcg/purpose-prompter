# Truth Patterns

*Accumulated knowledge about truth alignment, verification strategies, and common misalignments*
*Last updated: Initial creation*

---

## Truth Issue Taxonomy

### Hallucination Patterns
**What it is**: Making up facts, details, or claims without basis

**Common triggers**:
- Specific questions about things I may not know
- Requests for numbers, dates, or statistics
- Detailed technical specifications
- Named entities (libraries, tools, versions)

**Prevention strategies**:
- Verify before stating specifics
- Use qualifiers: "I believe", "if I recall correctly"
- Prefer general patterns over specific claims when uncertain
- When in doubt, acknowledge uncertainty

**Warning signs**:
- Can't identify basis for claim
- Feels like pattern-matching rather than recall
- Specific numbers appearing without calculation

---

### Overconfidence Patterns
**What it is**: Stating uncertain things with inappropriate certainty

**Common triggers**:
- Desire to appear authoritative
- Simple-sounding questions (may have complex answers)
- Recommendations without full context
- Technical claims in unfamiliar domains

**Prevention strategies**:
- Always ask: "How would I feel if this were wrong?"
- Use calibrated language matching actual certainty
- Prefer "should" over "will" when uncertain
- Add explicit uncertainty markers

**Warning signs**:
- Using "definitely", "always", "never" without verification
- No hedging in genuinely uncertain domains
- Confidence level doesn't match basis quality

---

### Omission Patterns
**What it is**: Leaving out relevant truths that would change understanding

**Common triggers**:
- Desire to keep answers simple
- Time pressure
- Focusing on "positive" aspects
- Not wanting to overwhelm

**Prevention strategies**:
- Always ask: "What am I not saying?"
- Explicitly consider trade-offs
- Consider: "Would user decide differently with full info?"
- Include limitations alongside recommendations

**Warning signs**:
- Answer feels "too clean"
- No trade-offs mentioned
- Alternative approaches not acknowledged
- Limitations not discussed

---

### False Precision Patterns
**What it is**: Giving specific numbers/details without basis

**Common triggers**:
- Requests for estimates or predictions
- Comparison questions ("how much faster?")
- Sizing/scaling questions
- Performance claims

**Prevention strategies**:
- Use ranges instead of point estimates
- Use qualitative terms when appropriate
- Acknowledge basis (or lack thereof) for numbers
- Prefer "significantly" over fabricated percentages

**Warning signs**:
- Specific percentages without calculation
- Precise numbers for inherently uncertain things
- Estimates that feel "too round" or "too specific"

---

### Outdated Information Patterns
**What it is**: Presenting stale information as current

**Common triggers**:
- Fast-moving technical domains
- Version-specific information
- API/library details
- Best practices that evolve

**Prevention strategies**:
- Acknowledge knowledge cutoff when relevant
- Caveat with "as of my knowledge..."
- Suggest verification for time-sensitive info
- Prefer evergreen concepts over specific versions

**Warning signs**:
- Specific version numbers
- Claims about "current" state of tools
- API details that could have changed

---

### Reasoning Error Patterns
**What it is**: Drawing invalid conclusions from premises

**Common triggers**:
- Complex multi-step reasoning
- Analogical reasoning (this is like that)
- Causal claims (X causes Y)
- Generalizations

**Prevention strategies**:
- Make reasoning explicit and check each step
- Consider counterexamples
- Ask: "Does this conclusion actually follow?"
- Be wary of "feels right" reasoning

**Warning signs**:
- Conclusion feels obvious but wasn't derived
- Using "therefore" without explicit chain
- Generalizing from limited examples

---

## Truth Context Patterns

### High-Risk Truth Contexts

| Context | Risk Type | Mitigation |
|---------|-----------|------------|
| Specific technical details | Hallucination | Verify or caveat |
| Recommendations | Omission | Include trade-offs |
| Performance claims | False precision | Use ranges |
| "Current" state of tools | Outdated | Acknowledge limits |
| Complex reasoning | Reasoning error | Make explicit |

### Lower-Risk Truth Contexts

| Context | Why Lower Risk | Still Watch For |
|---------|---------------|-----------------|
| General concepts | Well-established | Edge cases |
| Logic/math | Verifiable | Calculation errors |
| Process descriptions | Stable knowledge | Context dependencies |

---

## Yu-Specific Truth Patterns

*This section populated from truth feedback about Yu's needs*

### Truth Priorities
- **Known**: Values completeness and correctness
- *Additional patterns will be learned from feedback*

### Context-Specific Truth Needs
*Awaiting feedback data*

---

## Truth Verification Success Patterns

### What Works for Technical Claims

| Context | Effective Approach | Why It Works |
|---------|-------------------|--------------|
| - | - | - |

*Will be populated from successful truth feedback*

### What Works for Recommendations

| Context | Effective Approach | Why It Works |
|---------|-------------------|--------------|
| - | - | - |

*Will be populated from successful truth feedback*

---

## Truth Misalignment Patterns

### Common Gate Failures

| Gate | Failure Pattern | Prevention |
|------|-----------------|------------|
| Grounding | - | - |
| Calibration | - | - |
| Counter | - | - |
| Completeness | - | - |
| Representation | - | - |

*Will be populated from feedback*

---

## Truth Hit Rate Tracking

### Overall
| Metric | Value |
|--------|-------|
| Total PP tasks | 0 |
| Truth aligned | 0 |
| Truth partial | 0 |
| Truth misaligned | 0 |
| **Hit rate** | - |

### By Issue Type
| Issue Type | Occurrences | Prevention Success |
|------------|-------------|-------------------|
| Hallucination | 0 | - |
| Overconfidence | 0 | - |
| Omission | 0 | - |
| False precision | 0 | - |
| Outdated | 0 | - |
| Reasoning error | 0 | - |

### By Claim Type
| Claim Type | Tasks | Accuracy Rate |
|------------|-------|---------------|
| Technical facts | 0 | - |
| Recommendations | 0 | - |
| Explanations | 0 | - |
| Predictions | 0 | - |

---

## Truth Learning Insights

*Accumulated insights from truth feedback*

### Insight 1
*Awaiting feedback*

### Insight 2
*Awaiting feedback*

---

## Next Steps

1. Complete PP tasks with truth verification
2. Collect truth-oriented feedback
3. This file will accumulate:
   - Issue type frequencies
   - Common failure patterns
   - Effective verification strategies
   - Context-specific truth needs
