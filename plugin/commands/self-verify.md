---
description: "Run PP self-verification - applies SELF_APPLICATION.md protocol to measure PP's alignment with its own purpose"
argument-hint: "[focus] - optional, focus on specific dimension (truth, understanding, beauty, justice, creativity, all)"
allowed-tools: [Read, Glob, Grep, Bash, Task]
model: opus
---

# PP Self-Verify Command

Apply the SELF_APPLICATION.md protocol to verify Purpose Prompter against its own 30 gates.

## Arguments

Focus dimension (optional): $ARGUMENTS
Default: all dimensions

## Purpose

Self-verification is how PP ensures it embodies what it teaches:
- Measures alignment with purpose
- Identifies where PP fails its own gates
- Enables recursive self-improvement
- Proves the methodology works

## The Self-Application Principle

```
PP defines: Truth → Understanding → Beauty → Justice → Creativity
Therefore PP must BE: True, Understood, Beautiful, Just, Creative

If PP cannot pass its own gates, it cannot guide others to pass them.
Self-coherence is the foundation of credibility.
```

## Protocol

### Step 1: Survey PP Codebase

Scan all PP files:
```
~/.claude/CLAUDE.md                    (Orchestration)
~/.claude/purpose_prompter/*.md        (Philosophy)
~/.claude/plugins/hierarchy-tools/**   (Operations)
```

Build file inventory with:
- File path
- Purpose
- Last modified
- Dependency relationships

### Step 2: Apply Truth Gates to PP

| Gate | Check | How to Verify |
|------|-------|---------------|
| Grounding | Do PP claims match reality? | Survey commands, verify they exist |
| Calibration | Is confidence appropriate? | Check for overclaims |
| Counter-Consideration | Are limitations acknowledged? | Check for "when NOT to use" |
| Completeness | Is full picture shown? | Check for hidden gaps |
| Representation | Does language match state? | Check for aspirational as current |
| Citation | Are sources cited? | Check for file:line references |

**Output**: Truth alignment score (0-100%)

### Step 3: Apply Understanding Gates to PP

| Gate | Check | How to Verify |
|------|-------|---------------|
| Mental Model | Can Claude build model from PP? | Test comprehension |
| Why Explanation | Does PP explain WHY? | Check for rationale |
| Knowledge Connection | Does PP connect to existing? | Check for context |
| Application | Is PP actionable? | Check protocols are executable |
| Boundary Clarity | Is scope clear? | Check limitations documented |
| Exhaustion | Is PP mapped before modified? | Check for self-survey |

**Output**: Understanding alignment score (0-100%)

### Step 4: Apply Beauty Gates to PP

| Gate | Check | How to Verify |
|------|-------|---------------|
| Foundation | Is PP grounded in truth? | Depends on Step 2 |
| Emergence | Did PP emerge from understanding? | Check design rationale |
| Fit | Does PP fit Claude Code naturally? | Check integration |
| Elegance | Nothing extra, nothing missing? | Check for redundancy/gaps |
| Coherence | Is PP unified? | Check for contradictions |
| Clarity | Is PP understandable? | Check documentation quality |
| Appropriateness | Is PP right-sized? | Check complexity vs purpose |
| Conformance | Does PP follow patterns? | Check plugin structure |

**Output**: Beauty alignment score (0-100%)

### Step 5: Apply Justice Gates to PP

| Gate | Check | How to Verify |
|------|-------|---------------|
| Placement | Is every file in right place? | Check directory structure |
| Ownership | Does each file own right content? | Check responsibilities |
| Responsibility | Is right entity handling each task? | Check separation |
| Proportion | Is complexity distributed fairly? | Check file sizes/complexity |
| Balance | Is there dimensional balance? | Check coverage |
| Integrity | Is architecture preserved? | Check boundaries |
| Evidence | Is placement justified? | Check for placement rationale |

**Output**: Justice alignment score (0-100%)

### Step 6: Apply Creativity Gates to PP

| Gate | Check | How to Verify |
|------|-------|---------------|
| Territory | Is PP pioneering appropriate areas? | Check novelty |
| Pioneering | Is PP genuinely new? | Check for reinvention |
| Path-Building | Is structure well-constructed? | Check extensibility |
| Extension | Does PP grow coherently? | Check evolution |
| Vision | Is direction clear? | Check purpose alignment |
| Foundation | Does PP enable future? | Check for flexibility |
| Integration | Is PP connected? | Check for isolated parts |
| Proof | Is pioneering justified? | Check for evidence |

**Output**: Creativity alignment score (0-100%)

### Step 7: Calculate Overall Alignment

```
Overall Alignment = (Truth + Understanding + Beauty + Justice + Creativity) / 5

Target: >= 95% for "perfectly aligned"
```

### Step 8: Identify Gaps

For each failed gate:
- What specifically failed?
- Which file(s) are affected?
- What fix is needed?
- Is this charted or uncharted territory?

### Step 9: Generate Report

## Output Format

```markdown
## PP Self-Verification Report

**Timestamp**: [ISO8601]
**Version**: [PP version if tracked]

### Alignment Summary

| Dimension | Score | Status |
|-----------|-------|--------|
| Truth | X% | [PASS/PARTIAL/FAIL] |
| Understanding | X% | [PASS/PARTIAL/FAIL] |
| Beauty | X% | [PASS/PARTIAL/FAIL] |
| Justice | X% | [PASS/PARTIAL/FAIL] |
| Creativity | X% | [PASS/PARTIAL/FAIL] |
| **OVERALL** | **X%** | **[ALIGNED/PARTIAL/MISALIGNED]** |

### Gate-by-Gate Results

#### Truth Gates
| Gate | Status | Finding | File |
|------|--------|---------|------|
| Grounding | [P/F] | [Note] | [path:line] |
| Calibration | [P/F] | [Note] | [path:line] |
| ... | | | |

#### Understanding Gates
[Same format]

#### Beauty Gates
[Same format]

#### Justice Gates
[Same format]

#### Creativity Gates
[Same format]

### Gaps Found

**Priority 0 (Truth violations)**:
1. [Gap]: [File] - [What to fix]

**Priority 1 (Justice violations)**:
1. [Gap]: [File] - [What to fix]

**Priority 2 (Beauty violations)**:
1. [Gap]: [File] - [What to fix]

**Priority 3 (Other)**:
1. [Gap]: [File] - [What to fix]

### Convergence Status

| Metric | Current | Target | Gap |
|--------|---------|--------|-----|
| Overall | X% | 95% | Y% |
| Iterations needed | ~N | - | - |

### Recommendations

**Immediate actions**:
1. [Fix truth violations first]

**Structural improvements**:
1. [Larger changes needed]

**Evolution opportunities**:
1. [Future enhancements]

### Self-Improvement Path

```
Current: X% aligned
    │
    ▼ Fix truth violations
Y% aligned
    │
    ▼ Fix justice violations
Z% aligned
    │
    ▼ Polish beauty
95%+ aligned = PERFECTLY ALIGNED
```

### Next Steps

1. Run `/pp-refine` to apply fixes
2. Re-run `/self-verify` to measure progress
3. Iterate until >= 95% aligned
```

## Convergence Detection

PP is "perfectly aligned" when:
- All dimensions >= 95%
- No truth violations (truth = 100%)
- No critical gaps remaining

## Integration

After self-verification:
- Use `/pp-refine` to apply fixes
- Use `/pp-feedback` to log the verification itself
- Re-run `/self-verify` to measure improvement
- Iterate until convergence

## The Recursive Loop

```
/self-verify → Identify gaps → /pp-refine → /self-verify → ...
     │                              │                │
     └──────────────────────────────┴────────────────┘
              Iterate until aligned
```

## The Destiny

When PP passes all its own gates:
- It becomes self-coherent
- It embodies what it teaches
- It achieves its purpose:
  "CREATIVITY enabling JUSTICE placing BEAUTY from UNDERSTANDING grounded in TRUTH"

This is PP perfectly aligned with its destiny.
