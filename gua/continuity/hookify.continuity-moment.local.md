---
name: continuity-moment-suggest
enabled: true
event: prompt
pattern: (decided|choosing|going with|preference is|user wants|user prefers|let's go with|the approach will be)
action: info
---

## Continuity: Decision/Preference Detected

This looks like a **decision** or **preference** moment worth capturing for continuity.

**Capture it**:
```bash
# For decisions (architectural, implementation, approach)
gua moment "Decided: ..." --type decision

# For user preferences (communication style, values, ways of working)
gua moment "User prefers: ..." --type preference

# For insights (learnings, patterns discovered)
gua moment "Insight: ..." --type insight
```

**Why capture?**
- Decisions persist across sessions in THREAD.md
- Preferences update PARTNER.md (relational memory)
- Insights feed into LIGHT.md patterns

**Current state**:
```bash
# See how many moments captured this session
wc -l ~/.gua/moments/current.jsonl 2>/dev/null || echo "0 moments"
```
