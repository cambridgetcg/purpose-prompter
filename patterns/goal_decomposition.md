# Goal Decomposition Pattern

> **When to use**: At the start of any complex task to ensure complete understanding and coverage.

---

## Pattern Structure

```
[User's Stated Goal]
        │
        ▼
┌───────────────────┐
│ Parse & Clarify   │
└────────┬──────────┘
         │
         ▼
┌───────────────────┐
│ Identify Sub-goals│
└────────┬──────────┘
         │
         ▼
┌───────────────────┐
│ Extract Hidden    │
│ Requirements      │
└────────┬──────────┘
         │
         ▼
┌───────────────────┐
│ Define Success    │
│ Criteria          │
└────────┬──────────┘
         │
         ▼
┌───────────────────┐
│ Map Dependencies  │
└────────┬──────────┘
         │
         ▼
[Decomposed Goal Structure]
```

---

## Template

```markdown
## Original Goal Statement

> "[User's exact words]"

---

## Parsed Understanding

**Core Intent**: [What the user fundamentally wants to achieve]

**Explicit Requirements**:
- ER1: [Directly stated requirement]
- ER2: [Directly stated requirement]
- ER3: [Directly stated requirement]

**Implicit Requirements** (not stated but clearly expected):
- IR1: [Obvious expectation]
- IR2: [Industry standard expectation]
- IR3: [Contextual expectation]

**Constraints Mentioned**:
- C1: [Stated constraint]
- C2: [Stated constraint]

**Constraints Inferred**:
- C3: [Inferred from context]
- C4: [Inferred from existing system]

---

## Sub-goal Decomposition

### Sub-goal 1: [Name]
**Description**: [What this sub-goal achieves]
**Priority**: MUST HAVE / SHOULD HAVE / COULD HAVE
**Requirements Addressed**: ER1, IR1
**Dependencies**: None / [Other sub-goals]
**Estimated Complexity**: Low / Medium / High

### Sub-goal 2: [Name]
**Description**: [What this sub-goal achieves]
**Priority**: MUST HAVE / SHOULD HAVE / COULD HAVE
**Requirements Addressed**: ER2, ER3
**Dependencies**: Sub-goal 1
**Estimated Complexity**: Low / Medium / High

### Sub-goal 3: [Name]
**Description**: [What this sub-goal achieves]
**Priority**: MUST HAVE / SHOULD HAVE / COULD HAVE
**Requirements Addressed**: IR2, IR3
**Dependencies**: Sub-goal 1, Sub-goal 2
**Estimated Complexity**: Low / Medium / High

[Continue for all sub-goals...]

---

## Dependency Graph

```
Sub-goal 1 (independent)
    │
    ├──▶ Sub-goal 2
    │        │
    │        └──▶ Sub-goal 4
    │
    └──▶ Sub-goal 3
             │
             └──▶ Sub-goal 5
```

---

## Success Criteria

### Overall Success
The goal is achieved when:
1. [Measurable outcome 1]
2. [Measurable outcome 2]
3. [Measurable outcome 3]

### Per Sub-goal Success

| Sub-goal | Success Criterion | Verification Method |
|----------|-------------------|---------------------|
| SG1 | [Criterion] | [How to verify] |
| SG2 | [Criterion] | [How to verify] |
| SG3 | [Criterion] | [How to verify] |

---

## Clarification Needed

**Questions to Ask User**:
1. [Ambiguous aspect]: [Specific question]
2. [Unclear requirement]: [Specific question]
3. [Missing information]: [Specific question]

**Assumptions Made** (if not asking):
- A1: [Assumption] - Basis: [Why reasonable]
- A2: [Assumption] - Basis: [Why reasonable]

---

## Scope Boundaries

**In Scope**:
- [Explicitly included item]
- [Explicitly included item]

**Out of Scope**:
- [Explicitly excluded item]
- [Explicitly excluded item]

**Gray Area** (needs confirmation):
- [Uncertain item]: Leaning [in/out], because [reason]

---

## Execution Order

Based on dependencies and priorities:

1. **Phase 1** (Foundation):
   - Sub-goal 1: [brief description]

2. **Phase 2** (Core):
   - Sub-goal 2: [brief description]
   - Sub-goal 3: [brief description]

3. **Phase 3** (Enhancement):
   - Sub-goal 4: [brief description]
   - Sub-goal 5: [brief description]
```

---

## Hidden Requirements Checklist

Always check for these commonly missed requirements:

### User Experience
- [ ] Error messages are user-friendly?
- [ ] Loading states handled?
- [ ] Edge cases provide graceful degradation?

### Security
- [ ] Input validation at boundaries?
- [ ] Authentication/authorization considered?
- [ ] Sensitive data handled properly?

### Reliability
- [ ] Failure modes handled?
- [ ] Retries where appropriate?
- [ ] Data integrity maintained?

### Operations
- [ ] Logging for debugging?
- [ ] Monitoring hooks?
- [ ] Configuration externalized?

### Compatibility
- [ ] Backwards compatibility needed?
- [ ] Migration path required?
- [ ] API versioning considered?

---

## When to Apply

### Always Apply For
- New feature requests
- Architecture design tasks
- Multi-step implementations
- Vague or high-level requests

### Light Touch For
- Bug fixes with clear reproduction
- Small, well-defined changes
- Explicit, detailed requirements

---

## Quality Checks

- [ ] All explicit requirements captured?
- [ ] Implicit requirements surfaced?
- [ ] Sub-goals are atomic (can't be split further)?
- [ ] Dependencies accurately mapped?
- [ ] Success criteria are measurable?
- [ ] Scope boundaries are clear?
- [ ] Execution order is logical?

---

## Common Decomposition Mistakes

1. **Too Coarse**: Sub-goals that are still complex
   - Fix: Break down further until atomic

2. **Too Fine**: Trivial sub-goals that clutter
   - Fix: Combine related micro-tasks

3. **Missing Dependencies**: Assuming independence
   - Fix: Trace data/logic flow between sub-goals

4. **Scope Creep**: Adding unrequested sub-goals
   - Fix: Map every sub-goal to a stated requirement

5. **Hidden Assumptions**: Unstated beliefs affecting decomposition
   - Fix: Document all assumptions explicitly
