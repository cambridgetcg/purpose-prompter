# Prompt Patterns Library

Quick reference for selecting the right pattern.

---

## Pattern Selection Guide

| Situation | Pattern | File |
|-----------|---------|------|
| Starting any complex task | Goal Decomposition | `goal_decomposition.md` |
| Architecture decisions with trade-offs | Tree of Thoughts | `tree_of_thoughts.md` |
| Complex reasoning, explaining decisions | Chain of Thought | `chain_of_thought.md` |
| Step-by-step implementation | Sequential with Gates | `sequential_with_gates.md` |

---

## Decision Tree

```
Is this a complex task?
├── No → Just do it (no pattern needed)
└── Yes → Start with Goal Decomposition
              │
              ▼
         Does it involve decisions with trade-offs?
         ├── Yes → Use Tree of Thoughts
         └── No → Is it step-by-step execution?
                  ├── Yes → Use Sequential with Gates
                  └── No → Use Chain of Thought for reasoning
```

---

## Pattern Combinations

### Architecture Design
1. Goal Decomposition (understand scope)
2. Tree of Thoughts (explore options)
3. Chain of Thought (detail the chosen path)

### Feature Implementation
1. Goal Decomposition (understand requirements)
2. Sequential with Gates (execute with validation)
3. Chain of Thought (for tricky parts)

---

## Quick Reference

### Goal Decomposition
- **Purpose**: Ensure complete understanding before starting
- **Output**: Structured breakdown with dependencies
- **Use when**: Task is vague or complex

### Tree of Thoughts
- **Purpose**: Explore multiple solutions, pick best
- **Output**: Evaluated options with recommendation
- **Use when**: Multiple valid approaches exist

### Chain of Thought
- **Purpose**: Transparent step-by-step reasoning
- **Output**: Documented reasoning chain
- **Use when**: Complex logic or explanation needed

### Sequential with Gates
- **Purpose**: Execute steps with validation checkpoints
- **Output**: Validated incremental progress
- **Use when**: Multi-step implementation
