---
description: "Show PP × Superpowers integration status and mapping. Use to see how the two systems work together."
allowed-tools: [Read, Glob]
model: haiku
---

# PP × Superpowers Bridge Status

Show how Purpose Prompter and Superpowers integrate for the current task.

## Check

1. Is Superpowers plugin installed? (Check for superpowers skills availability)
2. Display the active mapping:

```markdown
## PP × Superpowers Bridge: ACTIVE

### Pipeline Flow
1. /territory → superpowers:systematic-debugging (TRUTH)
2. /understand → superpowers:brainstorming (UNDERSTANDING)  
3. /pp [task] → superpowers:writing-plans (BEAUTY)
4. Execute → superpowers:executing-plans (JUSTICE)
5. /verify → superpowers:verification-before-completion (TRUTH → loop)

### Signal Gates: ENABLED
- Ugliness → pauses Superpowers batch execution
- Injustice → pauses Superpowers batch execution  
- Stagnation → returns to brainstorming

### Override Rules
- PP signals override Superpowers batches
- Superpowers evidence overrides PP subjective beauty
- Both must pass before completion claims
```

If Superpowers is NOT installed, show:

```markdown
## PP × Superpowers Bridge: STANDALONE

Superpowers not detected. PP running in standalone mode.
Install with: /plugin install superpowers@claude-plugins-official
```
