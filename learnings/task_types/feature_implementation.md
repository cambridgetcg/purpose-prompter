# Feature Implementation Learnings

*Task-specific knowledge accumulated from feedback*
*Last updated: Initial creation*

---

## Effective Approaches

### What Works Well

*Will be populated from successful implementation tasks*

| Approach | Context | Success Indicators |
|----------|---------|-------------------|
| Sequential with Gates | Multi-step features | Each step validated |
| Test-first thinking | Complex logic | Edge cases caught early |
| - | - | - |

### What to Avoid

*Will be populated from failed/partial implementation tasks*

| Anti-Pattern | Why It Fails | Better Alternative |
|--------------|--------------|-------------------|
| - | - | - |

---

## Implementation-Specific Blindspots

In addition to universal blindspots, check for:

- [ ] Have I handled all input validation?
- [ ] Are all error paths returning appropriate responses?
- [ ] Is there proper cleanup/resource management?
- [ ] Are edge cases at boundaries handled?
- [ ] Is the happy path actually tested?
- [ ] Are side effects documented?

*Additional items will be added from feedback*

---

## Quality Emphasis for Implementation

When doing feature implementation, weight quality dimensions as:

| Dimension | Weight | Rationale |
|-----------|--------|-----------|
| Correctness | Highest | Bugs are expensive |
| Completeness | High | Missing cases cause production issues |
| Clarity | Medium | Code needs to be maintainable |
| Efficiency | Medium | Performance matters in implementation |

---

## Common Implementation Mistakes

*Will be populated from feedback*

### Mistake: [Title]
*None catalogued yet*

---

## Successful Patterns in Implementation

### Pattern: Gate-Protected Steps

**When effective**:
- Multi-step implementation
- Each step has clear deliverable
- Verification is possible between steps

**How to apply**:
1. Break implementation into discrete steps
2. Define what "done" means for each step
3. Verify before proceeding to next step
4. If gate fails, fix before continuing

**Watch out for**:
- Too many gates (slows progress)
- Too few gates (miss errors)
- Gates that don't catch real issues

---

## Code Quality Checklist

Before marking implementation complete:

### Logic
- [ ] All branches have correct conditions
- [ ] Loops terminate correctly
- [ ] Null/undefined handled
- [ ] Type coercion is intentional

### Error Handling
- [ ] All thrown errors are intentional
- [ ] Errors have meaningful messages
- [ ] Recovery is handled where possible
- [ ] Errors don't leak sensitive info

### Integration
- [ ] Interfaces match callers
- [ ] Data formats are consistent
- [ ] Dependencies are satisfied
- [ ] No breaking changes to existing code

---

## Recent Additions from Feedback

| Date | Learning | Source | Applied |
|------|----------|--------|---------|
| - | - | - | - |
