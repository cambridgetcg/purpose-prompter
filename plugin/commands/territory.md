---
description: Assess whether a task/feature is charted territory (use existing patterns) or uncharted (need to build new structure first)
argument-hint: [task description] - what you're trying to accomplish
allowed-tools: [Read, Glob, Grep, Bash, Task]
model: sonnet
---

# Territory Assessment Command

Before implementing: Is this charted territory (existing patterns suffice) or uncharted territory (need to build new structure first)?

## Arguments

Task to assess: $ARGUMENTS

## Why Territory Matters

```
CHARTED TERRITORY                    UNCHARTED TERRITORY
        │                                    │
        ▼                                    ▼
Similar patterns exist              No existing structure fits
        │                                    │
        ▼                                    ▼
Apply JUSTICE:                      Apply CREATIVITY:
Place in existing structure         Build the path FIRST
        │                                    │
        ▼                                    ▼
    DONE                            Then apply JUSTICE
                                            │
                                            ▼
                                        DONE
```

**The mistake**: Forcing uncharted work into charted patterns (results in hacks and technical debt)

## Assessment Protocol

### Step 1: Search for Similar Patterns

Look in the codebase for:
1. Similar features already implemented
2. Established patterns that match this need
3. Conventions that cover this case
4. Architecture that can accommodate this

### Step 2: Evaluate Fit

For each pattern found, ask:
- Does this pattern naturally fit the new requirement?
- Would using it require hacks or workarounds?
- Does it extend cleanly or fight the new need?

### Step 3: Determine Territory Type

**CHARTED indicators**:
- [ ] Similar feature exists (can follow the pattern)
- [ ] Established pattern covers this case
- [ ] Clear file/location for this code
- [ ] Existing abstractions accommodate this
- [ ] No workarounds needed

**UNCHARTED indicators**:
- [ ] No similar feature exists
- [ ] Existing patterns don't fit naturally
- [ ] No clear home for this code
- [ ] Would require hacks to fit existing structure
- [ ] Extends beyond current architecture

### Step 4: If Uncharted, Identify the Path Needed

What new structure would enable proper justice?
- New abstraction layer?
- New module/directory?
- New pattern to establish?
- Refactoring existing code?

## Output Format

```markdown
## Territory Assessment: [Task]

### Task Understanding
**What we're trying to accomplish**: [Clear description]
**What it requires**: [Key requirements]

### Codebase Exploration

**Similar patterns found**:
| Pattern | Location | Fit Quality |
|---------|----------|-------------|
| [pattern] | [file:line] | [Natural/Partial/Poor] |

**Existing structure**:
- [Structure element]: [How it relates to this task]

### Territory Verdict: [CHARTED / UNCHARTED]

---

### If CHARTED:

**Pattern to follow**: [Which existing pattern]
**Location for implementation**: [Where to place the code]
**Integration points**: [How it connects to existing code]

**Proceed with**: Justice (place in existing structure)

---

### If UNCHARTED:

**Why uncharted**:
- [Specific reason existing structure doesn't fit]

**Path needed**:
```
[Describe the new structure/pattern/abstraction needed]
```

**Before implementing the feature**:
1. [First structural change needed]
2. [Second structural change needed]
...

**Proceed with**: Creativity (build path first), then Justice (place feature)

---

### Risk Assessment

| Risk | If Treated as Charted | If Treated as Uncharted |
|------|----------------------|-------------------------|
| Technical debt | [risk if we force it] | [minimal] |
| Time | [quick but costly later] | [more upfront, cleaner result] |
| Maintainability | [low] | [high] |

### Recommendation

[Clear recommendation: treat as charted/uncharted, specific next steps]
```

## The Stagnation Warning

If you find yourself thinking:
- "We can make it fit if we just..."
- "It's not perfect but it'll work..."
- "We can refactor later..."

**STOP**. These are stagnation signals. The territory is probably uncharted. Build the path first.
