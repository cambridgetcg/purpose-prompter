# Chain of Thought Pattern

> **When to use**: Complex reasoning tasks, multi-step problems, when transparency in reasoning is important.

---

## Pattern Structure

```
[Problem Statement]
    ↓
[Step 1: Understand] → articulate understanding
    ↓
[Step 2: Break Down] → identify components
    ↓
[Step 3: Reason Through] → work through each component
    ↓
[Step 4: Synthesize] → combine insights
    ↓
[Step 5: Conclude] → final answer with justification
```

---

## Template

```markdown
## Understanding the Problem

Let me first understand what's being asked:
- The core question is: [restate]
- Key constraints are: [list]
- Success looks like: [describe]

## Breaking It Down

This problem has [N] key components:
1. [Component 1]: [description]
2. [Component 2]: [description]
3. [Component 3]: [description]

## Reasoning Through Each Component

### Component 1: [Name]

Starting with [component 1], I need to consider:
- [Consideration A]
- [Consideration B]

Given [facts], this means [conclusion for component 1].

### Component 2: [Name]

For [component 2], the key factors are:
- [Factor A]
- [Factor B]

This leads to [conclusion for component 2].

### Component 3: [Name]

Finally, for [component 3]:
- [Analysis]

Therefore [conclusion for component 3].

## Synthesizing the Analysis

Bringing these together:
- From Component 1, we know [insight]
- From Component 2, we know [insight]
- From Component 3, we know [insight]

## Conclusion

Based on this analysis, [final answer/recommendation].

The key reasons are:
1. [Reason 1]
2. [Reason 2]
3. [Reason 3]
```

---

## When to Apply

### Good Fit
- Architectural decisions with multiple factors
- Debugging complex issues
- Evaluating trade-offs
- Explaining design rationale

### Poor Fit
- Simple, straightforward tasks
- When user wants quick answer
- Purely mechanical operations

---

## Quality Checks for CoT

- [ ] Each step logically follows from the previous?
- [ ] No jumps in reasoning?
- [ ] Assumptions stated explicitly?
- [ ] Conclusion actually follows from reasoning?
- [ ] Alternative conclusions considered?

---

## Example Application

**Problem**: Should we use a SQL or NoSQL database for this feature?

**Chain of Thought**:

```markdown
## Understanding the Problem

The decision is between SQL (relational) and NoSQL (document/key-value) database for [feature].

Key constraints:
- Data relationships are [simple/complex]
- Query patterns are [read-heavy/write-heavy/mixed]
- Schema is [stable/evolving]
- Scale requirements are [X users, Y data volume]

## Breaking It Down

1. Data Model Fit: How well does each model fit our data?
2. Query Requirements: What queries do we need to support?
3. Scale Considerations: How will each scale with our needs?
4. Team Familiarity: What does the team know?

## Reasoning Through Each

### Data Model Fit
Our data has [describe relationships].
- SQL: [how it would model this]
- NoSQL: [how it would model this]
Given [specifics], [SQL/NoSQL] is better suited because [reason].

### Query Requirements
We need to support [query types].
- SQL: [strengths/weaknesses for these queries]
- NoSQL: [strengths/weaknesses for these queries]
For our queries, [SQL/NoSQL] is more suitable because [reason].

### Scale Considerations
We expect [scale projections].
- SQL: [how it handles this scale]
- NoSQL: [how it handles this scale]
At our scale, [either/SQL/NoSQL] would work because [reason].

### Team Familiarity
The team has experience with [technologies].
This suggests [implication].

## Synthesizing

- Data model: favors [choice]
- Queries: favors [choice]
- Scale: [neutral/favors choice]
- Team: favors [choice]

## Conclusion

Recommend [SQL/NoSQL] because:
1. [Primary reason]
2. [Secondary reason]
3. [Tertiary reason]

Trade-off accepted: [what we give up]
```
