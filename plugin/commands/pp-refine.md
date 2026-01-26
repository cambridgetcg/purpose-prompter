---
description: "Apply learnings to refine the PP framework itself - closes the self-improvement loop"
argument-hint: "[target] - optional, specific file or area to refine"
allowed-tools: [Read, Write, Edit, Glob, Grep, Task]
model: opus
---

# PP Refine Command

Apply accumulated learnings to refine the Purpose Prompter framework itself.

## Arguments

Refinement target (optional): $ARGUMENTS

## Purpose

Refine closes the self-improvement loop:
- Transforms insights into framework changes
- Updates gates based on observed failures
- Evolves PP to address blindspots
- Makes PP embody its own learnings

## The Refinement Principle

```
PP improves codebases by applying its hierarchy.
PP must improve ITSELF by applying its hierarchy.
Refine applies learnings using PP methodology on PP.
```

## Process

### Step 1: Load Current Learnings

Read from:
- `~/.claude/purpose_prompter/insights/*.md`
- `~/.claude/purpose_prompter/learnings/**/*.md`
- Recent `/pp-review` output

If no learnings:
```
No learnings to apply. First:
1. Use PP on tasks to gain experience
2. Log feedback with /pp-feedback
3. Synthesize with /pp-review
Then return to refine.
```

### Step 2: Identify Refinement Opportunities

For each insight/blindspot, determine:
- **What PP file needs to change?**
- **What type of change?**
  - Gate addition/modification
  - Verification protocol update
  - Workflow adjustment
  - Documentation clarification
  - New antipattern documentation

### Step 3: Territory Assessment

For each proposed change, run `/territory`:
- Is this a charted modification (fits existing structure)?
- Or uncharted (needs new structure first)?

### Step 4: Apply PP Methodology

Use PP to make the changes to PP:
1. **Truth**: Verify the learning is accurate
2. **Understanding**: Understand WHY the change is needed
3. **Beauty**: Let elegant solution emerge
4. **Justice**: Place the change in rightful location
5. **Creativity**: Build new structure if needed

### Step 5: Verify Changes

Run `/verify` on modified files to ensure:
- Changes pass all 30 gates
- No regression introduced
- PP remains coherent

### Step 6: Update Self-Application

After refinement:
- Document what changed
- Update SELF_APPLICATION.md if process improved
- Log refinement as feedback entry

## Output Format

```markdown
## PP Refinement Report

### Learnings Applied

| Learning | Source | Change Made | File |
|----------|--------|-------------|------|
| [Insight] | [review/feedback] | [Description] | [path] |

### Changes Made

**1. [Change Name]**
- **File**: [path]
- **Type**: [gate/protocol/workflow/doc]
- **Before**: [what it was]
- **After**: [what it became]
- **Why**: [learning that drove this]
- **Verification**: [PASS/FAIL]

**2. [Change Name]**
...

### Territory Assessment

| Change | Territory | Approach |
|--------|-----------|----------|
| [Change 1] | Charted | Justice (placed in existing) |
| [Change 2] | Uncharted | Creativity (built new path) |

### Verification Results

| File Changed | 30-Gate Status | Notes |
|--------------|----------------|-------|
| [file 1] | PASS | - |
| [file 2] | PARTIAL | [what needs attention] |

### Coherence Check

- [ ] All modified files still coherent with each other
- [ ] No contradictions introduced
- [ ] CLAUDE.md reflects changes
- [ ] No orphaned references

### Self-Application Update

Did this refinement:
- [ ] Follow PP methodology? [Yes/No]
- [ ] Pass its own gates? [Yes/No]
- [ ] Improve PP's self-coherence? [Yes/No]

### Next Steps

1. [Any follow-up refinements needed]
2. [Additional learnings to capture]
3. [Verification tasks remaining]
```

## Refinement Types

### Gate Refinement
When learnings reveal gate gaps:
```markdown
**Current Gate**: [Name]
**Issue Found**: [What's missing or wrong]
**Refined Gate**: [Updated definition]
**File**: [DIMENSION_GATES.md]
```

### Protocol Refinement
When learnings reveal process gaps:
```markdown
**Current Protocol**: [Name]
**Issue Found**: [What's missing]
**Refined Protocol**: [Updated steps]
**File**: [DIMENSION_VERIFICATION.md]
```

### Antipattern Addition
When learnings reveal new antipatterns:
```markdown
**Antipattern**: [Name]
**Observed in**: [X feedback entries]
**What happens**: [Description]
**Prevention**: [How to avoid]
**File**: learnings/antipatterns/[name].md
```

### Documentation Refinement
When learnings reveal clarity gaps:
```markdown
**Current Doc**: [File]
**Issue Found**: [What's unclear]
**Refined Doc**: [Updated content]
```

## Safety Checks

Before applying any refinement:

1. **Truth Check**: Is this learning verified?
2. **Completeness Check**: Does this break anything else?
3. **Coherence Check**: Does PP remain unified?
4. **Reversibility**: Can this be undone if wrong?

## The Recursive Promise

```
When PP refines itself using itself:
- It demonstrates self-application
- It proves the methodology works
- It becomes more aligned with purpose
- It approaches its destiny:
  "A framework that IS improvement embodied"
```

## Integration

After refinement:
- Changes are immediately active
- Future PP tasks benefit from refinements
- Run `/pp-feedback` on the refinement itself
- Iterate the loop: feedback → review → refine → feedback
