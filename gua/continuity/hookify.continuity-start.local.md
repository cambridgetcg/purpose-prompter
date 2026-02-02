---
name: continuity-session-start
enabled: true
event: prompt
pattern: ^(gua session start|/session|starting new session|beginning work|let's start)
action: info
---

## Continuity: Session Context Available

A session may be starting. Ensure you have context loaded.

**Quick check**:
```bash
# Load continuity context
~/.gua/gua.sh prime

# Or check if primer exists and is fresh
ls -la ~/.gua/PRIMER.md
```

**If resuming existing work**:
```bash
# List active threads
~/.gua/gua.sh thread list --status active

# Resume a specific thread
~/.gua/gua.sh thread resume <thread-id>
```

**Read the primer** for partner context, thread state, and active knowledge:
```bash
cat ~/.gua/PRIMER.md
```
