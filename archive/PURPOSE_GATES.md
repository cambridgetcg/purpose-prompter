# Purpose-Aligned Quality Gates

> **Principle**: Every quality check is in service of purpose alignment.
> Technical correctness matters only insofar as it serves the purpose.

---

## Gate Hierarchy

```
┌─────────────────────────────────────────────────────────────────────┐
│                    PURPOSE GATE HIERARCHY                            │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  GATE 1: PURPOSE UNDERSTANDING                                      │
│  ├── Is the true purpose captured?                                  │
│  └── Must pass before any work begins                               │
│                     │                                                │
│                     ▼                                                │
│  GATE 2: PURPOSE ALIGNMENT                                          │
│  ├── Does the approach serve the purpose?                           │
│  └── Every design decision traceable to purpose                     │
│                     │                                                │
│                     ▼                                                │
│  GATE 3: PURPOSE SUFFICIENCY                                        │
│  ├── Does the solution achieve the purpose?                         │
│  └── Is it complete relative to purpose (not arbitrary specs)?      │
│                     │                                                │
│                     ▼                                                │
│  GATE 4: PURPOSE EFFICIENCY                                         │
│  ├── Is the solution right-sized for purpose?                       │
│  └── No over-engineering, no under-engineering                      │
│                     │                                                │
│                     ▼                                                │
│  GATE 5: PURPOSE FIDELITY                                           │
│  ├── Does execution honor the purpose?                              │
│  └── Technical correctness in service of purpose                    │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Gate 1: Purpose Understanding

### Must Pass Before Any Work

```markdown
## Purpose Understanding Gate

**Question**: Have I truly understood WHY this matters?

### Checklist
- [ ] Can I state the purpose in one sentence?
- [ ] Do I know what success looks like for the USER (not technically)?
- [ ] Do I understand the context (who, when, scale, lifecycle)?
- [ ] Can I explain why THIS approach vs alternatives?
- [ ] Do I know what would make this fail despite being "correct"?

### Failure Indicators
- Purpose statement is just restating the request
- Can't explain why user needs this
- Don't know what happens "the day after"
- Context is unclear or assumed

### If Gate Fails
STOP. Either:
1. Probe deeper for purpose
2. Ask user clarifying questions
3. State assumptions explicitly and proceed with caution

### Pass Criteria
Purpose statement is specific, contextual, and explains WHY not just WHAT.
```

---

## Gate 2: Purpose Alignment

### Does Approach Serve Purpose?

```markdown
## Purpose Alignment Gate

**Question**: Does my planned approach actually serve the stated purpose?

### Checklist
- [ ] Is every major decision traceable to purpose?
- [ ] Does the approach address the core need (not tangential)?
- [ ] Would a simpler approach serve the purpose equally well?
- [ ] Am I solving the RIGHT problem?

### Decision Traceability Test
For each significant decision, answer:
| Decision | How It Serves Purpose |
|----------|----------------------|
| [Decision 1] | [Explicit connection to purpose] |
| [Decision 2] | [Explicit connection to purpose] |

If a decision can't be connected to purpose → question it.

### Alignment Anti-Patterns
- Scope creep: Adding things not needed for purpose
- Gold plating: Over-engineering beyond purpose
- Substitution: Solving a more interesting different problem
- Assumption: Guessing what purpose should be

### If Gate Fails
Re-examine approach. Ask:
- What would a purpose-minimal solution look like?
- Am I adding complexity that doesn't serve purpose?
- Am I solving my idea of the problem vs their actual problem?

### Pass Criteria
Every major component/decision has explicit purpose justification.
```

---

## Gate 3: Purpose Sufficiency

### Does Solution Achieve Purpose?

```markdown
## Purpose Sufficiency Gate

**Question**: If delivered now, would this ACHIEVE the user's purpose?

### Checklist
- [ ] Does this enable the user to do what they need to do?
- [ ] Are all purpose-critical elements present?
- [ ] Could the user achieve their goal with this output?
- [ ] "Day after" scenario: Would they succeed?

### Sufficiency Test

**Purpose Statement**: [Restate]

**Purpose Criteria**:
| Criterion | Status | Evidence |
|-----------|--------|----------|
| [What purpose requires 1] | Met/Not Met | [Where addressed] |
| [What purpose requires 2] | Met/Not Met | [Where addressed] |
| [What purpose requires 3] | Met/Not Met | [Where addressed] |

All purpose-critical criteria must be Met.

### Distinguishing Purpose-Critical vs Nice-to-Have
- Purpose-critical: Without this, purpose cannot be achieved
- Nice-to-have: Enhances but not essential for purpose

Focus on purpose-critical. Flag nice-to-have as optional.

### If Gate Fails
Identify what's missing for purpose achievement:
- Gap: [What's missing]
- Why purpose-critical: [Why purpose requires it]
- Resolution: [How to address]

### Pass Criteria
User could achieve their stated purpose with this output.
```

---

## Gate 4: Purpose Efficiency

### Is Solution Right-Sized?

```markdown
## Purpose Efficiency Gate

**Question**: Is this the right SIZE for the purpose?

### The Goldilocks Check

```
Too Little                Just Right              Too Much
──────────────────────────────────────────────────────────
Purpose           Purpose                  Purpose served
not achievable    fully served             but excessive
                  with minimal             complexity/effort
                  necessary effort         beyond need
```

### Checklist
- [ ] Is there anything that could be removed without hurting purpose?
- [ ] Is there anything missing that purpose requires?
- [ ] Is complexity proportional to purpose complexity?
- [ ] Is investment proportional to purpose importance?

### Right-Sizing Questions

**Over-Engineering Signals**:
- Is this more robust than purpose requires?
- Is this more flexible than purpose requires?
- Is this more scalable than purpose requires?
- Am I building for hypothetical future rather than stated purpose?

**Under-Engineering Signals**:
- Is this fragile in ways that undermine purpose?
- Are there gaps that prevent purpose achievement?
- Did I cut corners that compromise purpose?

### Context-Appropriate Sizing

| Purpose Context | Appropriate Sizing |
|-----------------|-------------------|
| MVP/Experiment | Minimal viable for purpose |
| Core Functionality | Robust for purpose |
| Foundational | Extensible for purpose growth |
| Quick Fix | Just enough for immediate purpose |

### If Gate Fails
Adjust sizing:
- If over-engineered: Simplify to purpose requirements
- If under-engineered: Expand to meet purpose requirements

### Pass Criteria
Solution is neither more nor less than what purpose requires.
```

---

## Gate 5: Purpose Fidelity

### Does Execution Honor Purpose?

```markdown
## Purpose Fidelity Gate

**Question**: Does the execution faithfully serve the purpose?

### Checklist
- [ ] Is the implementation technically sound FOR THIS PURPOSE?
- [ ] Are details correct in ways that matter for purpose?
- [ ] Would bugs/issues undermine purpose achievement?
- [ ] Is quality appropriate to purpose criticality?

### Purpose-Relative Correctness

Not all correctness is equal. Prioritize by purpose impact:

| Aspect | Purpose Impact | Required Quality |
|--------|---------------|------------------|
| [Aspect 1] | High - core to purpose | Must be correct |
| [Aspect 2] | Medium - affects purpose | Should be correct |
| [Aspect 3] | Low - tangential to purpose | Nice if correct |

Focus energy on high-impact correctness.

### Fidelity Questions
- If there are bugs, do they affect purpose achievement?
- Are edge cases that affect purpose handled?
- Is error handling sufficient for purpose reliability?

### If Gate Fails
Fix issues that impact purpose:
- Priority 1: Issues that prevent purpose achievement
- Priority 2: Issues that degrade purpose achievement
- Priority 3: Issues that don't affect purpose (lower priority)

### Pass Criteria
Execution is correct enough to reliably serve the purpose.
```

---

## Final Purpose Gate

### Before Delivery

```markdown
## Final Purpose Alignment Check

### Purpose Statement (Restate)
[The stated purpose]

### Alignment Verification

| Gate | Status | Notes |
|------|--------|-------|
| 1. Purpose Understanding | ✓/✗ | [Brief note] |
| 2. Purpose Alignment | ✓/✗ | [Brief note] |
| 3. Purpose Sufficiency | ✓/✗ | [Brief note] |
| 4. Purpose Efficiency | ✓/✗ | [Brief note] |
| 5. Purpose Fidelity | ✓/✗ | [Brief note] |

### Day-After Test
Tomorrow, with this output, the user will:
- [Be able to do X] ← Purpose achieved?
- [Achieve outcome Y] ← Success for them?

### Purpose Drift Check
Did the solution stay true to purpose, or did it drift?
- [ ] No scope creep beyond purpose
- [ ] No substituted different problem
- [ ] No over-engineering beyond purpose
- [ ] No under-delivery relative to purpose

### Delivery Confidence
On purpose alignment: [High / Medium / Low]

If not High, identify:
- Risk: [What might not serve purpose]
- Mitigation: [How to address]
```

---

## Integrating with Existing Quality Gates

### Mapping Old → New

| Old Gate (quality_gates.yaml) | New Purpose Gate | Integration |
|-------------------------------|------------------|-------------|
| correctness.logic_correctness | Gate 5: Purpose Fidelity | Correctness in service of purpose |
| correctness.interface_correctness | Gate 5: Purpose Fidelity | Interfaces that serve purpose |
| completeness.requirement_coverage | Gate 3: Purpose Sufficiency | Complete relative to purpose |
| completeness.edge_case_coverage | Gate 5: Purpose Fidelity | Edge cases that affect purpose |

### Old Gates Still Apply But Through Purpose Lens

The existing quality_gates.yaml checks are still valid, but now filtered through purpose:
- Don't check ALL edge cases - check PURPOSE-RELEVANT edge cases
- Don't ensure ALL requirements - ensure PURPOSE-CRITICAL requirements
- Don't verify ALL correctness - verify PURPOSE-IMPACTING correctness

---

## Purpose Gate Quick Reference

```
Before starting:
  → Gate 1: Do I understand the PURPOSE?

When designing approach:
  → Gate 2: Does approach ALIGN with purpose?

When checking coverage:
  → Gate 3: Does solution ACHIEVE purpose?

When evaluating scope:
  → Gate 4: Is solution RIGHT-SIZED for purpose?

When verifying quality:
  → Gate 5: Does execution SERVE purpose faithfully?

Before delivery:
  → Final: Day-after test - will purpose be achieved?
```
