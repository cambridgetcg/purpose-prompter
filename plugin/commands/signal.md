---
description: Detect ugliness, injustice, and stagnation signals in code - each signal indicates a specific type of incomplete understanding
argument-hint: [target] - file path, directory, or PR to analyze for signals
allowed-tools: [Read, Glob, Grep, Bash]
model: sonnet
---

# Signal Detection Command

The PP Signal System: Code problems signal specific types of incomplete understanding.

## Arguments

Target to analyze: $ARGUMENTS

## The Three Signals

### 1. UGLINESS Signal

**What it is**: Code that feels wrong, hacky, or uncomfortable to read.

**What it signals**: Incomplete understanding of the **PROBLEM**.

**Symptoms**:
- Complex conditionals that feel convoluted
- Functions doing too many things
- Unclear variable/function names
- Magic numbers without explanation
- Deeply nested code
- Code that requires extensive comments to understand
- "Clever" code that's hard to follow
- Inconsistent patterns within the same context

**Wrong response**: Try to polish it (add comments, rename things, extract methods)

**Right response**: Step back and understand the problem deeper. When you truly understand, beauty emerges naturally.

---

### 2. INJUSTICE Signal

**What it is**: Code that's in the wrong place, owned by the wrong component, or violates architectural integrity.

**What it signals**: Incomplete understanding of the **CODEBASE**.

**Symptoms**:
- God classes/modules doing everything
- Utilities that should be domain services
- Business logic in controllers/views
- Cross-cutting concerns scattered everywhere
- Circular dependencies
- Leaky abstractions
- Code that "doesn't belong here"
- Duplicate logic in multiple places
- Feature envy (one class using another's data extensively)

**Wrong response**: Leave it because "it works"

**Right response**: Understand the codebase architecture deeper. Find where this code rightfully belongs.

---

### 3. STAGNATION Signal

**What it is**: Inability to add features or make changes without hacking around limitations.

**What it signals**: Need for **CREATIVITY** - existing structure is insufficient.

**Symptoms**:
- "We can't do X because of how Y works"
- Feature flags multiplying
- Workarounds on top of workarounds
- Copy-paste because refactoring is "too hard"
- Technical debt that blocks progress
- Architecture that fights the problem domain
- "This needs a rewrite"
- Extending functionality requires touching many files

**Wrong response**: Force it (add more hacks, flags, workarounds)

**Right response**: Recognize uncharted territory. Build a new path that enables the needed functionality. Then place the solution justly.

---

## Analysis Process

1. **Read the target code**
2. **Look for each signal type**
3. **Identify specific instances**
4. **Diagnose the underlying incomplete understanding**
5. **Recommend the right response**

## Output Format

```markdown
## Signal Analysis: [Target]

### Ugliness Signals (Problem Understanding)

**Found**: [Yes/No]

| Location | Symptom | Underlying Issue |
|----------|---------|------------------|
| [file:line] | [What looks ugly] | [What problem understanding is missing] |

**Recommendation**: [How to understand the problem deeper]

---

### Injustice Signals (Codebase Understanding)

**Found**: [Yes/No]

| Location | Symptom | Rightful Place |
|----------|---------|----------------|
| [file:line] | [What's misplaced] | [Where it should be] |

**Recommendation**: [How to understand the codebase deeper]

---

### Stagnation Signals (Need for Creativity)

**Found**: [Yes/No]

| Location | Symptom | Path Needed |
|----------|---------|-------------|
| [area] | [What's blocked] | [What structure is missing] |

**Recommendation**: [What path needs to be built]

---

### Summary

| Signal | Count | Severity | Priority |
|--------|-------|----------|----------|
| Ugliness | [n] | [High/Med/Low] | [1-3] |
| Injustice | [n] | [High/Med/Low] | [1-3] |
| Stagnation | [n] | [High/Med/Low] | [1-3] |

### Recommended Action Order

1. [First thing to address and why]
2. [Second thing]
...

### Key Insight

[The most important thing to understand to improve this code]
```

## Remember

- **Don't polish ugliness** - understand the problem deeper
- **Don't ignore injustice** - understand the codebase deeper
- **Don't hack around stagnation** - build the path first

These signals are gifts - they tell you exactly what understanding is missing.
