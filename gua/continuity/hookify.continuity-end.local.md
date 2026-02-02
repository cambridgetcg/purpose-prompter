---
name: continuity-session-end
enabled: true
event: Stop
action: warn
---

## Continuity: Session Ending - Preserve Context

Before this session ends, ensure continuity is preserved for future sessions.

**Quick check - do you have uncommitted work?**
```bash
# Check for captured moments
wc -l ~/.gua/moments/current.jsonl 2>/dev/null || echo "No moments file"

# Check continuity health
~/.gua/gua.sh continuity signal
```

**If moments exist**, generate handoff:
```bash
~/.gua/gua.sh handoff
~/.gua/gua.sh save
```

**If no moments**, consider what should be captured:
- What decisions were made this session?
- What did you learn about the user?
- What should the next session focus on?

**Minimum before ending**:
```bash
# Capture at least one moment summarizing the session
~/.gua/gua.sh moment "Session summary: ..." --type context

# Generate handoff
~/.gua/gua.sh handoff
```

**Active thread**: If working on a thread, the handoff will update it automatically.
