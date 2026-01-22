# Purpose Prompter Depth System

A layered learning system that accumulates context-specific knowledge over time.

---

## Depth Layers Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                         DEPTH LAYERS                                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Layer 4: ANTI-PATTERNS                                             │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │ Known failure modes, near-misses, things that don't work   │    │
│  └────────────────────────────────────────────────────────────┘    │
│                              │                                      │
│  Layer 3: DOMAIN-SPECIFIC    │                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │ API Design │ Data Models │ Auth │ Infra │ UI │ ...        │    │
│  └────────────────────────────────────────────────────────────┘    │
│                              │                                      │
│  Layer 2: TASK-TYPE SPECIFIC │                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │ Architecture Design Learnings │ Feature Impl Learnings     │    │
│  └────────────────────────────────────────────────────────────┘    │
│                              │                                      │
│  Layer 1: UNIVERSAL          │                                      │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │ Core quality gates, base workflows, fundamental patterns   │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Layer 1: Universal (Base Framework)

The foundation - applies to all tasks.

**Location**: Core framework files
- `quality_gates.yaml` - Universal quality checks
- `workflows/*.md` - Base workflows
- `patterns/*.md` - Core reasoning patterns

**Characteristics**:
- Stable, rarely changes
- High confidence learnings only
- Broad applicability

---

## Layer 2: Task-Type Specific

Learnings specific to architecture design vs feature implementation.

**Location**: `learnings/task_types/`

### architecture_design.md
```markdown
# Architecture Design Learnings

## Effective Approaches
[Accumulated from successful architecture tasks]

### What Works
- [Approach] in [context] - Success rate: X%
- [Approach] in [context] - Success rate: Y%

### What to Avoid
- [Anti-pattern] - Failure rate: X%

## Common Blindspots
[Accumulated from feedback]
- [ ] [Blindspot specific to architecture tasks]

## Quality Adjustments
[Task-type specific threshold adjustments]
- Emphasis on: Interface completeness
- Less critical: Implementation details
```

### feature_implementation.md
```markdown
# Feature Implementation Learnings

## Effective Approaches
[Accumulated from successful implementation tasks]

### What Works
- [Approach] in [context]

### What to Avoid
- [Anti-pattern]

## Common Blindspots
- [ ] [Blindspot specific to implementation tasks]

## Quality Adjustments
- Emphasis on: Edge cases, error handling
- Less critical: High-level architecture
```

---

## Layer 3: Domain-Specific

Learnings organized by technical domain.

**Location**: `learnings/domains/`

### Structure
```
domains/
├── api_design.md
├── data_modeling.md
├── authentication.md
├── caching.md
├── database.md
├── frontend.md
├── infrastructure.md
├── testing.md
└── ...
```

### Domain File Template
```markdown
# [Domain] Learnings

*Last updated: [date]*
*Based on: [N] relevant feedback entries*

## Domain-Specific Checks

When working on [domain], always verify:
- [ ] [Domain-specific check 1]
- [ ] [Domain-specific check 2]
- [ ] [Domain-specific check 3]

## Common Patterns in [Domain]

### Pattern: [Name]
- When to use: [Context]
- How it works: [Description]
- Watch out for: [Pitfalls]

## Anti-Patterns in [Domain]

### Anti-Pattern: [Name]
- What it looks like: [Description]
- Why it's bad: [Consequences]
- Better alternative: [Recommendation]

## [Domain] Blindspots

Things often missed when working on [domain]:
1. [Blindspot]
2. [Blindspot]

## Decision Framework for [Domain]

When making decisions about [domain]:
1. First consider: [Factor]
2. Then evaluate: [Factor]
3. Finally check: [Factor]
```

---

## Layer 4: Anti-Pattern Library

Accumulated knowledge of what doesn't work.

**Location**: `learnings/antipatterns/`

### common_mistakes.md
```markdown
# Common Mistakes Library

*Accumulated from feedback analysis*

## Mistake: [Title]

**ID**: M-[number]
**Frequency**: [N] occurrences
**Severity**: [Critical/High/Medium/Low]
**Category**: [Logic/Completeness/Interface/etc.]

### Description
[What the mistake looks like]

### Why It Happens
[Root cause]

### Impact
[What goes wrong]

### Detection
[How to catch it]

### Prevention
[How to avoid it]

### Related Checks
- Gate: [quality_gates.yaml reference]
- Workflow step: [workflow reference]

---

[Repeat for each catalogued mistake]
```

### near_misses.md
```markdown
# Near-Miss Library

*Things that were almost missed but caught*

## Near-Miss: [Title]

**ID**: NM-[number]
**How caught**: [What revealed it]
**Would have caused**: [Impact if missed]

### Description
[What was almost missed]

### Why Almost Missed
[Why it wasn't obvious]

### Now Handled By
[What check/gate catches this now]

---

[Repeat for each catalogued near-miss]
```

---

## Depth Application Logic

When a PP task begins, apply depth layers:

```
1. Load Layer 1 (Universal)
   └─ Always applied

2. Load Layer 2 (Task-Type)
   └─ Based on task classification

3. Load Layer 3 (Domain) [if detectable]
   └─ Based on keywords/context in task description
   └─ E.g., "API" → load api_design.md
   └─ E.g., "auth" → load authentication.md

4. Load Layer 4 (Anti-Patterns) [selective]
   └─ Load relevant anti-patterns based on:
      - Task type
      - Domain
      - Past mistakes for similar tasks
```

### Domain Detection Keywords

| Keywords | Domain File |
|----------|-------------|
| API, endpoint, REST, GraphQL | api_design.md |
| database, schema, SQL, query | database.md |
| auth, login, session, token | authentication.md |
| cache, redis, memcached | caching.md |
| UI, component, frontend, react | frontend.md |
| deploy, infra, AWS, cloud | infrastructure.md |
| test, spec, coverage | testing.md |

---

## Depth Accumulation

### How Learnings Enter Each Layer

**Layer 1 (Universal)**:
- Only from highly confident, frequently occurring patterns
- Requires: 5+ occurrences across different contexts
- Manual review before promotion

**Layer 2 (Task-Type)**:
- From feedback tagged with specific task type
- Requires: 3+ occurrences within task type
- Auto-promoted with review

**Layer 3 (Domain)**:
- From feedback involving specific domain
- Requires: 2+ occurrences within domain
- Auto-accumulated

**Layer 4 (Anti-Patterns)**:
- Any significant mistake or near-miss
- Requires: 1 occurrence if severity=high
- 2+ occurrences otherwise

### Promotion Path

```
Feedback Entry
    │
    ├─► Layer 4 (if mistake/near-miss)
    │
    ├─► Layer 3 (if domain identifiable)
    │
    ├─► Layer 2 (based on task type)
    │
    └─► Layer 1 (if universal pattern, 5+ occurrences)
```

---

## Viewing Current Depth

Command: `/pp-learnings`

```markdown
## Purpose Prompter Knowledge State

### Layer 1: Universal
- Quality gates: [N] checks
- Workflow steps: [M] total

### Layer 2: Task-Type
- Architecture Design: [N] learnings
- Feature Implementation: [M] learnings

### Layer 3: Domain-Specific
- API Design: [N] entries
- Authentication: [M] entries
- Database: [P] entries
- [etc.]

### Layer 4: Anti-Patterns
- Common Mistakes: [N] catalogued
- Near-Misses: [M] catalogued

### Recent Additions
- [Date]: Added [learning] to [layer]
- [Date]: Added [learning] to [layer]
```
