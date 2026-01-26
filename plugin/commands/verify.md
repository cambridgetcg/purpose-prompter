---
description: Apply the 30-gate hierarchy verification to any work (code, architecture, design)
argument-hint: [target] - file path, PR, or description of what to verify
allowed-tools: [Read, Glob, Grep, Bash, WebFetch]
model: sonnet
---

# Hierarchy Verification Command

Apply the complete 30-gate verification system from Purpose Prompter to ensure work is grounded in truth, emerged from understanding, beautiful, just, and creative when needed.

## Arguments

Target to verify: $ARGUMENTS

## The 30-Gate System

### TRUTH GATES (1-5) - Foundation

Run these checks first:

1. **Grounding**: Are claims based on something identifiable and verifiable?
2. **Calibration**: Does confidence match the evidence?
3. **Counter-Consideration**: Have we considered what would make this wrong?
4. **Completeness**: Is the full relevant picture represented?
5. **Representation**: Does the language match the actual knowledge state?

### UNDERSTANDING GATES (6-10) - Source

6. **Mental Model**: Does this build an accurate mental model?
7. **Why Explanation**: Does it explain WHY, not just WHAT?
8. **Knowledge Connection**: Does it connect to what the reader already knows?
9. **Practical Application**: Can the reader actually apply this?
10. **Boundary Clarity**: Is it clear when this doesn't apply?

### BEAUTY GATES (11-17) - Quality

11. **Foundation**: Is this grounded in truth?
12. **Emergence**: Did this emerge from understanding (not forced)?
13. **Fit**: Does it fit the context naturally?
14. **Elegance**: Is there nothing extra and nothing missing?
15. **Coherence**: Does it hang together as a unified whole?
16. **Clarity**: Can others understand this?
17. **Appropriateness**: Is it right-sized for the purpose?

### JUSTICE GATES (18-23) - Placement

18. **Placement**: Is this in the right location?
19. **Ownership**: Does the right component own this?
20. **Responsibility**: Is the right entity handling this?
21. **Proportion**: Is complexity distributed fairly?
22. **Balance**: Is system equilibrium maintained?
23. **Integrity**: Is architectural integrity preserved?

### CREATIVITY GATES (24-30) - When Territory is Uncharted

Only apply if existing structure is insufficient:

24. **Territory**: Is this genuinely uncharted territory?
25. **Pioneering**: Is this genuinely new ground (not reinventing)?
26. **Path-Building**: Is the structure well-constructed?
27. **Extension**: Does this grow the domain coherently?
28. **Vision**: Is there clarity about where this leads?
29. **Foundation**: Does this enable future justice?
30. **Integration**: Is this connected to the whole (not isolated)?

## Verification Process

1. **Read/analyze the target** specified in arguments
2. **Apply each gate** systematically
3. **Report findings** in this format:

```markdown
## Verification Report: [Target]

### Truth Status: [PASS/PARTIAL/FAIL]
- Grounding: [status] - [brief note]
- Calibration: [status]
- Counter-Consideration: [status]
- Completeness: [status]
- Representation: [status]

### Understanding Status: [PASS/PARTIAL/FAIL]
- Mental Model: [status]
- Why Explanation: [status]
- Knowledge Connection: [status]
- Practical Application: [status]
- Boundary Clarity: [status]

### Beauty Status: [PASS/PARTIAL/FAIL]
- Foundation: [status]
- Emergence: [status]
- Fit: [status]
- Elegance: [status]
- Coherence: [status]
- Clarity: [status]
- Appropriateness: [status]

### Justice Status: [PASS/PARTIAL/FAIL]
- Placement: [status]
- Ownership: [status]
- Responsibility: [status]
- Proportion: [status]
- Balance: [status]
- Integrity: [status]

### Territory Assessment
- Territory Type: [Charted/Uncharted]
- If Uncharted:
  - Pioneering: [status]
  - Path-Building: [status]
  - Extension: [status]
  - Vision: [status]
  - Foundation: [status]
  - Integration: [status]

### Overall Verdict: [COMPLETE/JUST/PARTIAL/FAILED]

### Recommendations
[Specific improvements needed to pass failed gates]
```

## The Signal System

During verification, watch for these signals:

- **Ugliness** signals incomplete understanding of the PROBLEM
  - Response: Understand the problem deeper, don't polish

- **Injustice** (misplacement) signals incomplete understanding of the CODEBASE
  - Response: Understand the codebase deeper, find the rightful place

- **Stagnation** signals the need for CREATIVITY
  - Response: Recognize uncharted territory, build the path first

---

## Claude-Specific Enhancement Gates (MANDATORY)

These gates compensate for Claude's known limitations. Always check these.

### Enhancement Gate Verification

```markdown
### Claude Enhancement Status: [PASS/PARTIAL/FAIL]

**Citation Gate** (Truth):
- [ ] Claims cite file:line as source
- [ ] Code was READ before claiming
- [ ] Negative claims show search evidence
- Status: [PASS/FAIL]

**Exhaustion Gate** (Understanding):
- [ ] Related files searched (Glob)
- [ ] Patterns searched (Grep)
- [ ] Dependencies traced
- [ ] Mapping documented
- Status: [PASS/FAIL]

**Conformance Gate** (Beauty):
- [ ] Similar code found in codebase
- [ ] Pattern extracted and followed
- [ ] Pattern source cited
- Status: [PASS/FAIL]

**Evidence Gate** (Justice):
- [ ] All candidate locations surveyed
- [ ] Contents of each location read
- [ ] Similar code cited as placement evidence
- [ ] Rejection reasons documented for other locations
- Status: [PASS/FAIL]

**Proof Gate** (Creativity - if uncharted):
- [ ] Multiple search terms used
- [ ] Near-misses identified
- [ ] Extension impossibility explained
- [ ] Search attempts documented
- Status: [PASS/FAIL/N/A]
```

### Verification-First Principle

```
When verifying, CHECK:

1. Are claims CITED with file:line? (not assumed)
2. Was understanding MAPPED before modification?
3. Does new code MATCH existing patterns?
4. Is placement backed by EVIDENCE?
5. Is "uncharted" claim PROVEN?

Uncited claims = FAIL Citation Gate
Unmapped areas = FAIL Exhaustion Gate
Unmatched patterns = FAIL Conformance Gate
Unevidenced placement = FAIL Evidence Gate
Unproven pioneering = FAIL Proof Gate
```

### Enhanced Report Format

Add this section to the verification report:

```markdown
### Claude Enhancement Verification

| Gate | Status | Evidence |
|------|--------|----------|
| Citation | [P/F] | [file:line refs or "missing"] |
| Exhaustion | [P/F] | [search summary or "not mapped"] |
| Conformance | [P/F] | [pattern source or "no pattern check"] |
| Evidence | [P/F] | [placement evidence or "no survey"] |
| Proof | [P/F/NA] | [search doc or "not pioneering"] |

Enhancement Status: [ALL PASS / FAILURES NOTED]
```
