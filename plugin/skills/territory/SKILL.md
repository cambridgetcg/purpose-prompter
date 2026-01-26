---
name: territory
description: "Assess whether a task/feature is charted territory or uncharted"
version: 1.0.0
---

# Territory Assessment Skill

Before implementing: Is this charted territory (existing patterns suffice) or uncharted territory (need to build new structure first)?

## Task
$ARGUMENTS

---

## Load Full Protocol

Read the complete territory command protocol:
```
Read: ~/.claude/plugins/hierarchy-tools/commands/territory.md
```

Execute according to that protocol with the provided arguments.

---

## Quick Reference

### Territory Types

**CHARTED TERRITORY**:
- Similar patterns exist in codebase
- Apply JUSTICE: Place in existing structure

**UNCHARTED TERRITORY**:
- No existing structure fits
- Apply CREATIVITY: Build the path FIRST, then apply JUSTICE

### Charted Indicators
- Similar feature exists (can follow the pattern)
- Established pattern covers this case
- Clear file/location for this code
- Existing abstractions accommodate this
- No workarounds needed

### Uncharted Indicators
- No similar feature exists
- Existing patterns don't fit naturally
- No clear home for this code
- Would require hacks to fit existing structure
- Extends beyond current architecture

### Stagnation Warning

If you find yourself thinking:
- "We can make it fit if we just..."
- "It's not perfect but it'll work..."
- "We can refactor later..."

**STOP**. These are stagnation signals. The territory is probably uncharted.

### Example
```bash
/territory add user authentication
/territory implement caching layer
/territory create new API endpoint
```
