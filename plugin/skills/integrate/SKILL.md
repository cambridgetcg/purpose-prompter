---
name: integrate
description: "Synthesize accumulated perspectives and learnings into LIGHT and PATH"
version: 1.0.0
---

# Insight Integrator Skill

Synthesize perspectives and feedback into actionable understanding (LIGHT) and direction (PATH).

## Task
$ARGUMENTS

---

## Load Full Protocol

Read the complete integrate command protocol:
```
Read: ~/.claude/plugins/hierarchy-tools/commands/integrate.md
```

Execute according to that protocol with the provided arguments.

---

## Quick Reference

### Modes
- `full` - Complete re-analysis of all sources
- `incremental` - Process only new entries (default)
- `status` - Show current state
- `path` - Synthesize PATH.md only
- `classify` - Run scope classification only

### Scope Flags
- `--global` - Use only global perspectives
- `--project` - Use only project perspectives
- `--merge` - Combine global + project
- `--auto-classify` - Enable automatic scope classification (default)
- `--no-classify` - Disable classification

### Examples
```bash
/integrate path              # Synthesize PATH.md
/integrate full --global     # Full analysis, global scope
/integrate status            # Check current state
/integrate classify          # Route insights to correct scope
```
