---
name: perspective
description: "Generate insight MD from a specific perspective lens"
version: 1.0.0
---

# Perspective Skill

Generate focused insights by examining a target through a specific lens.

## Task
$ARGUMENTS

---

## Load Full Protocol

Read the complete perspective command protocol:
```
Read: ~/.claude/plugins/hierarchy-tools/commands/perspective.md
```

Execute according to that protocol with the provided arguments.

---

## Quick Reference

### Perspective Types
| Type | Lens | Key Questions |
|------|------|---------------|
| **truth** | Accuracy, verification | What claims are unverified? |
| **understanding** | Comprehension, models | Is the WHY clear? |
| **beauty** | Elegance, fit | What's ugly or forced? |
| **justice** | Placement, ownership | Is code in the right place? |
| **creativity** | Innovation, paths | What's stagnant? |

### Custom Perspectives
- `custom:performance` - Speed, efficiency
- `custom:security` - Vulnerabilities
- `custom:ux` - User experience
- `custom:debt` - Technical debt

### Scope Flags
- `--global` - Save to global perspectives
- `--local` - Save to project perspectives
- `--auto` - Use classification protocol (default)

### Examples
```bash
/perspective beauty ./src           # Review codebase beauty
/perspective truth ./docs           # Audit docs accuracy
/perspective justice ./lib          # Check code placement
/perspective understanding self     # Personal workflow reflection
/perspective custom:security ./api  # Custom security review
```

### Output Location
- Global: `~/.claude/purpose_prompter/integration/perspectives/`
- Local: `<project>/.claude/integration/perspectives/`
