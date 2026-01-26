---
description: "View accumulated PP knowledge - patterns, blindspots, and insights from feedback synthesis"
argument-hint: "[dimension] - optional, view specific dimension learnings (truth, understanding, beauty, justice, creativity, blindspots)"
allowed-tools: [Read, Glob]
model: haiku
---

# PP Learnings Command

Display accumulated knowledge from PP feedback and review cycles.

## Arguments

Focus area (optional): $ARGUMENTS

## Purpose

Learnings make PP's accumulated wisdom accessible:
- Quick reference for known patterns
- Blindspot awareness before starting tasks
- Task-type specific guidance
- Antipattern avoidance

## Knowledge Sources

### Insight Files
- `~/.claude/purpose_prompter/insights/truth_patterns.md`
- `~/.claude/purpose_prompter/insights/understanding_patterns.md`
- `~/.claude/purpose_prompter/insights/beauty_patterns.md`
- `~/.claude/purpose_prompter/insights/justice_patterns.md`
- `~/.claude/purpose_prompter/insights/creativity_patterns.md`
- `~/.claude/purpose_prompter/insights/blindspots.md`

### Learning Files
- `~/.claude/purpose_prompter/learnings/task_types/*.md`
- `~/.claude/purpose_prompter/learnings/antipatterns/*.md`

## Output Format

### All Learnings (no arguments)

```markdown
## PP Learnings: Accumulated Knowledge

### Quick Stats
- Total feedback entries: [count]
- Last review: [date]
- Top blindspot: [name]

### Dimension Summaries

**Truth**: [One-line summary of truth patterns]
**Understanding**: [One-line summary]
**Beauty**: [One-line summary]
**Justice**: [One-line summary]
**Creativity**: [One-line summary]

### Active Blindspots (address these)

1. **[Blindspot]**: [What to watch for]
2. **[Blindspot]**: [What to watch for]

### Top Antipatterns (avoid these)

1. **[Antipattern]**: [What NOT to do]
2. **[Antipattern]**: [What NOT to do]

### Task-Type Guidance

- **Architecture tasks**: [Key insight]
- **Implementation tasks**: [Key insight]
- **Refactoring tasks**: [Key insight]
- **Bug fixes**: [Key insight]

### Recent Learnings

1. [Most recent insight from /pp-review]
2. [Second most recent]

---

Use `/pp-learnings [dimension]` for detailed view
Use `/pp-review` to generate new insights
Use `/pp-refine` to apply learnings to framework
```

### Dimension-Specific (with argument)

```markdown
## PP Learnings: [Dimension]

### Patterns

**What works**:
- [Pattern 1]: [Description]
- [Pattern 2]: [Description]

**What fails**:
- [Pattern 1]: [Description]
- [Pattern 2]: [Description]

### Gates to Watch

| Gate | Failure Rate | Common Miss |
|------|-------------|-------------|
| [Gate 1] | X% | [How it's missed] |
| [Gate 2] | Y% | [How it's missed] |

### Recommendations

When working on [dimension]:
1. [First thing to do]
2. [Second thing to do]
3. [What to avoid]

### Examples from History

**Success example**:
> [Task]: [What was done]
> [Why it worked]: [Analysis]

**Failure example**:
> [Task]: [What was done]
> [What went wrong]: [Analysis]
> [Lesson]: [What to do instead]
```

### Blindspots Focus

```markdown
## PP Learnings: Blindspots

### Known Blindspots

**1. [Blindspot Name]**
- **What happens**: [Description of the failure mode]
- **Why it happens**: [Root cause analysis]
- **How often**: [Frequency from data]
- **Trigger**: [What situations trigger this]
- **Prevention**: [How to avoid]
- **Detection**: [How to notice if happening]

**2. [Blindspot Name]**
...

### Blindspot Prevention Checklist

Before starting any PP task, verify:
- [ ] [Check 1 based on blindspots]
- [ ] [Check 2 based on blindspots]
- [ ] [Check 3 based on blindspots]

### Recently Fixed Blindspots

- [Blindspot]: [How it was fixed]
```

## Process

1. Check for insight and learning files
2. Parse and format content
3. Display in requested format
4. If files missing, suggest running `/pp-review` first

## Integration

This command is read-only. To update learnings:
- Use `/pp-feedback` to log new assessments
- Use `/pp-review` to synthesize patterns
- Use `/pp-refine` to apply learnings to PP

## Empty State

If no learnings exist:
```
No PP learnings accumulated yet.

To build knowledge:
1. Complete PP tasks using the methodology
2. Log feedback with /pp-feedback
3. Synthesize patterns with /pp-review

Learnings emerge from the feedback loop over time.
```
