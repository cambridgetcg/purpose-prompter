# Tree of Thoughts Pattern

> **When to use**: Decisions with multiple valid options, architecture choices, exploring solution space, when backtracking might be needed.

---

## Pattern Structure

```
                    [Problem]
                        │
        ┌───────────────┼───────────────┐
        ▼               ▼               ▼
    [Option A]      [Option B]      [Option C]
        │               │               │
    [Evaluate]      [Evaluate]      [Evaluate]
        │               │               │
    [Score: X]      [Score: Y]      [Score: Z]
        │               │               │
        └───────────────┼───────────────┘
                        ▼
                [Compare & Select]
                        │
                        ▼
                [Develop Best Path]
                        │
            ┌───────────┼───────────┐
            ▼           ▼           ▼
        [Detail 1] [Detail 2] [Detail 3]
                        │
                        ▼
                [Final Solution]
```

---

## Template

```markdown
## Problem Definition

**Goal**: [What we're trying to achieve]
**Constraints**: [What limits our options]
**Evaluation Criteria**: [How we'll judge options]
  - Criterion 1: [description] (weight: high/med/low)
  - Criterion 2: [description] (weight: high/med/low)
  - Criterion 3: [description] (weight: high/med/low)

---

## Branch Exploration

### Option A: [Name]

**Core Idea**: [One sentence description]

**How It Works**:
[Detailed description]

**Evaluation**:
| Criterion | Score (1-5) | Reasoning |
|-----------|-------------|-----------|
| Criterion 1 | X | [why] |
| Criterion 2 | X | [why] |
| Criterion 3 | X | [why] |

**Strengths**:
- [Strength 1]
- [Strength 2]

**Weaknesses**:
- [Weakness 1]
- [Weakness 2]

**Total Score**: X/15

---

### Option B: [Name]

**Core Idea**: [One sentence description]

**How It Works**:
[Detailed description]

**Evaluation**:
| Criterion | Score (1-5) | Reasoning |
|-----------|-------------|-----------|
| Criterion 1 | X | [why] |
| Criterion 2 | X | [why] |
| Criterion 3 | X | [why] |

**Strengths**:
- [Strength 1]
- [Strength 2]

**Weaknesses**:
- [Weakness 1]
- [Weakness 2]

**Total Score**: X/15

---

### Option C: [Name]

**Core Idea**: [One sentence description]

**How It Works**:
[Detailed description]

**Evaluation**:
| Criterion | Score (1-5) | Reasoning |
|-----------|-------------|-----------|
| Criterion 1 | X | [why] |
| Criterion 2 | X | [why] |
| Criterion 3 | X | [why] |

**Strengths**:
- [Strength 1]
- [Strength 2]

**Weaknesses**:
- [Weakness 1]
- [Weakness 2]

**Total Score**: X/15

---

## Comparison Matrix

| Aspect | Option A | Option B | Option C |
|--------|----------|----------|----------|
| Criterion 1 | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐ |
| Criterion 2 | ⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| Criterion 3 | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ |
| **Total** | **X** | **Y** | **Z** |

---

## Selection & Rationale

**Selected Option**: [Option X]

**Primary Reasons**:
1. [Most important reason]
2. [Second reason]
3. [Third reason]

**Trade-offs Accepted**:
- We accept [weakness] because [justification]
- We accept [limitation] because [justification]

**When to Reconsider**:
- Choose Option Y if [condition changes]
- Choose Option Z if [different constraint]

---

## Developing the Selected Path

### Sub-decision 1: [Topic]

[Apply mini tree-of-thoughts or direct decision]

### Sub-decision 2: [Topic]

[Apply mini tree-of-thoughts or direct decision]

### Sub-decision 3: [Topic]

[Apply mini tree-of-thoughts or direct decision]

---

## Final Solution

[Complete solution with all decisions made]
```

---

## When to Apply

### Good Fit
- Architecture decisions (monolith vs microservices, database choice)
- Technology selection
- Design pattern selection
- Strategic decisions with long-term implications
- Situations where "it depends" and we need to explore

### Poor Fit
- Clear best practice exists
- User has already decided approach
- Simple implementation with one obvious path
- Time-sensitive quick decisions

---

## Quality Checks for ToT

- [ ] Generated genuinely different options (not variations of same idea)?
- [ ] Evaluated each option fairly (not biased toward predetermined choice)?
- [ ] Criteria are relevant to the actual decision?
- [ ] Scores are justified with reasoning?
- [ ] Trade-offs explicitly acknowledged?
- [ ] Selection follows from evaluation?

---

## Minimum Options Rule

**Always generate at least 2 meaningfully different options.**

Bad:
- Option A: Use React
- Option B: Use React with TypeScript

Good:
- Option A: Use React (component-based SPA)
- Option B: Use HTMX (hypermedia-driven, minimal JS)
- Option C: Use server-rendered templates (traditional approach)

---

## Pruning Strategy

If an option clearly fails a hard constraint, prune early:

```markdown
### Option D: [Name]

**Core Idea**: [description]

**Early Pruning**: This option violates constraint [X] because [reason].
Eliminated from further consideration.
```

Don't waste effort fully evaluating obviously non-viable options.
