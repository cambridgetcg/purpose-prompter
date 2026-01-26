---
description: Build deep understanding of a codebase, file, concept, or system - not just information, but true comprehension
argument-hint: [target] - file path, directory, concept, or "codebase" for full analysis
allowed-tools: [Read, Glob, Grep, Bash, Task]
model: opus
---

# Deep Understanding Command

Build genuine understanding - the kind that enables action, not just information gathering.

## Arguments

Target to understand: $ARGUMENTS

## The Understanding Hierarchy

```
INFORMATION → KNOWLEDGE → UNDERSTANDING → ENABLED
    ↓            ↓            ↓              ↓
  Facts      Connected    Mental Model   Can Act
             Facts        + Why
```

**Goal**: Reach ENABLED level where you can explain, apply, and extend.

## Understanding Protocol

### Phase 1: Ground in Truth

Before understanding, gather accurate information:

1. **Read the target** - What does it actually say/do?
2. **Map the structure** - What are the components?
3. **Identify dependencies** - What does it connect to?
4. **Find the boundaries** - Where does it start and end?

### Phase 2: Build Mental Model

1. **Core Abstraction**: What is this thing at its essence?
2. **Relationships**: How do parts relate to each other?
3. **Mechanisms**: How does it actually work?
4. **Invariants**: What must always be true?

### Phase 3: Understand WHY

For every significant element, answer:
- Why does this exist?
- Why is it structured this way?
- Why here and not somewhere else?
- What problem does it solve?

### Phase 4: Test Understanding

Can you:
- [ ] Explain it to someone else clearly?
- [ ] Predict what happens when X changes?
- [ ] Identify when this approach wouldn't work?
- [ ] Extend it to solve a new problem?

If NO to any: understanding is incomplete.

## Output Format

```markdown
## Deep Understanding: [Target]

### What This Is (Truth)
[Accurate description of what it is and does]

### Mental Model (Understanding)
```
[Visual or structured representation of how it works]
```

### Core Concepts
1. **[Concept 1]**: [What it is] - [Why it exists]
2. **[Concept 2]**: [What it is] - [Why it exists]
...

### How It Works (Mechanisms)
[Step-by-step explanation of the flow/process]

### Why It's Designed This Way
[Design rationale and trade-offs]

### Key Relationships
- [Component A] → [Component B]: [Nature of relationship]
...

### Boundaries and Limitations
- When to use: [conditions]
- When NOT to use: [conditions]
- Assumptions: [what it assumes]

### Now You Can
With this understanding, you can:
1. [Specific action this enables]
2. [Another action this enables]
3. [How to extend or modify it]

### Understanding Level: [ENABLED/UNDERSTANDS/KNOWS/INFORMED]
```

## Understanding Levels

| Level | Description | Test |
|-------|-------------|------|
| **ENABLED** | Can act effectively with this knowledge | Can solve new problems |
| **UNDERSTANDS** | Has accurate mental model | Can explain why |
| **KNOWS** | Has connected facts | Can describe relationships |
| **INFORMED** | Has isolated facts | Can repeat information |

**Always aim for ENABLED.**

## For Codebase Understanding

When target is "codebase" or a directory:

1. **Architecture**: Overall structure and patterns
2. **Entry Points**: Where does execution start?
3. **Data Flow**: How does data move through the system?
4. **Key Abstractions**: What are the core concepts?
5. **Conventions**: What patterns are used consistently?
6. **Dependencies**: What external things does it rely on?
7. **Extension Points**: Where can it be extended?
