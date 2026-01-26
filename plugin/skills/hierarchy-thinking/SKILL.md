---
name: hierarchy-thinking
description: This skill should be used when the user asks to "think through" a problem, "design" something, "implement" a feature, "refactor" code, or when working on any non-trivial task. Applies the Truth-Understanding-Beauty-Justice-Creativity hierarchy to ensure complete, well-placed solutions.
version: 1.0.0
---

# Hierarchy Thinking Skill

Apply the complete hierarchy to any software development task.

## The Hierarchy

```
TRUTH (foundation)
    ↓
UNDERSTANDING (source)
    ↓
BEAUTY (quality)
    ↓
JUSTICE (placement)
    ↓
CREATIVITY (when needed)
```

**Each level requires the previous. Skip a level and the solution collapses.**

## When to Apply

Use this approach for any task that involves:
- Designing architecture
- Implementing features
- Refactoring code
- Making technical decisions
- Reviewing code
- Debugging problems
- Writing documentation

## The Protocol

### Level 1: TRUTH (Ground First)

Before anything else, establish accurate foundation:

- What are the actual requirements?
- What does the code actually do? (Read it, don't assume)
- What are the real constraints?
- What do we NOT know? (Acknowledge uncertainty)

**Gate**: Are claims verifiable? Is confidence calibrated?

### Level 2: UNDERSTANDING (Build Deep Comprehension)

From truth, build understanding:

- WHY does this need to exist?
- HOW does the existing system work?
- WHAT is the mental model?
- WHERE does this fit in the larger picture?

**Gate**: Can you explain why, not just what? Could you teach this?

### Level 3: BEAUTY (Let Solutions Emerge)

From understanding, let elegant solutions emerge:

- Does this FIT naturally with the context?
- Is it ELEGANT (nothing extra, nothing missing)?
- Is it COHERENT (hangs together as a whole)?
- Is it CLEAR (others can understand)?
- Is it APPROPRIATE (right-sized)?

**Gate**: Did this emerge from understanding, or was it forced?

**Signal**: If it feels ugly, STOP. Understand the problem deeper.

### Level 4: JUSTICE (Place Where It Belongs)

Beautiful solutions need rightful placement:

- Is this in the RIGHT location?
- Does the RIGHT component own this?
- Is RESPONSIBILITY distributed appropriately?
- Is COMPLEXITY distributed fairly?
- Does this PRESERVE architectural integrity?

**Gate**: Is everything in its rightful place?

**Signal**: If placement feels wrong, STOP. Understand the codebase deeper.

### Level 5: CREATIVITY (When Territory is Uncharted)

Only when existing structure is insufficient:

- Is this genuinely UNCHARTED territory?
- Are we PIONEERING (not reinventing)?
- Is the PATH well-constructed?
- Does it EXTEND coherently?
- Is there clear VISION?
- Does it ENABLE future justice?
- Is it INTEGRATED with the whole?

**Gate**: Is the path well-built?

**Signal**: If you can't place justly in existing structure, STOP. Build the path first.

## Quick Reference

```
TASK RECEIVED
    │
    ▼
[TRUTH] Ground in accurate information
    │
    ▼
[UNDERSTANDING] Build deep comprehension
    │
    ▼
[BEAUTY] Let elegant solution emerge
    │
    ▼
[JUSTICE] Place where it belongs
    │
    ├── Can place in existing structure? → DONE
    │
    └── No existing structure fits?
            │
            ▼
        [CREATIVITY] Build path first, then place
            │
            ▼
          DONE
```

## The Signal System

- **Ugliness** → Understand the PROBLEM deeper
- **Injustice** → Understand the CODEBASE deeper
- **Stagnation** → Need CREATIVITY (build path first)

Never polish ugliness. Never ignore injustice. Never hack around stagnation.
