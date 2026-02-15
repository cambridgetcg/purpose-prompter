---
description: Apply the 30-gate hierarchy verification to any work (code, architecture, design)
argument-hint: [target] - file path, PR, or description of what to verify
allowed-tools: [Read, Glob, Grep, Bash, WebFetch]
model: sonnet
---

# /verify - Hierarchy Verification

Apply the complete 30-gate verification from Purpose Prompter.

## Target

$ARGUMENTS

## Process

1. **Read gate definitions**: Read `plugin/gates/GATES.md` for the complete gate reference
2. **Read/analyze the target** specified in arguments
3. **Evaluate each dimension** systematically:
   - Truth (T1-T5 + Citation enhancement)
   - Understanding (U1-U5 + Exhaustion enhancement)
   - Beauty (B1-B7 + Conformance enhancement)
   - Justice (J1-J6 + Evidence enhancement)
   - Creativity (X1-X7 + Proof enhancement) - only if territory is uncharted
4. **Check for signals**: ugliness, injustice, stagnation
5. **Report findings**

## Output Format

```markdown
## Verification Report: [Target]

### Truth: [PASS/PARTIAL/FAIL]
T1 Grounding: [status] - [note]
T2 Calibration: [status]
T3 Counter: [status]
T4 Completeness: [status]
T5 Representation: [status]
Citation Enhancement: [status]

### Understanding: [PASS/PARTIAL/FAIL]
U1-U5: [status per gate]
Exhaustion Enhancement: [status]

### Beauty: [PASS/PARTIAL/FAIL]
B1-B7: [status per gate]
Conformance Enhancement: [status]

### Justice: [PASS/PARTIAL/FAIL]
J1-J6: [status per gate]
Evidence Enhancement: [status]

### Creativity: [PASS/PARTIAL/FAIL/N/A]
(Only if uncharted territory)
X1-X7: [status per gate]
Proof Enhancement: [status]

### Signals
- Ugliness: [none | description]
- Injustice: [none | description]
- Stagnation: [none | description]

### Overall: [COMPLETE/PARTIAL/FAILED]

### Recommendations
[Specific improvements to pass failed gates]
```

## Signal Mapping

| Signal | Meaning | Action |
|--------|---------|--------|
| Ugliness | Problem understanding incomplete | Understand problem deeper |
| Injustice | Codebase understanding incomplete | Find rightful place |
| Stagnation | Need for creativity | Build new path |
