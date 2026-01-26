---
name: post-verify
description: "Run post-tool verification checks after Edit/Write operations"
version: 1.0.0
---

# Post-Tool Verification Skill

Verification gate after modifying a file. Checks for signals and coherence.

## Target File
$ARGUMENTS

---

## Load Full Protocol

Read the complete post-verify command protocol:
```
Read: ~/.claude/plugins/hierarchy-tools/commands/post-verify.md
```

Execute according to that protocol with the provided arguments.

---

## Quick Reference

### What It Checks
1. **SIGNAL** - Ugliness, injustice, or stagnation detected?
2. **COHERENCE** - Does change fit naturally?
3. **INTEGRATION** - Is it connected properly?

### Output Format
```
[PP:POST-VERIFY] [file] - SIGNAL✓ COHERENCE✓ → CONTINUE
```

Or detailed:
```
Post-Tool Verification: [file]
═══════════════════════════════
SIGNAL:      ✓ Clean
COHERENCE:   ✓ Fits naturally
INTEGRATION: ✓ Connected properly

Verdict: CONTINUE
```

### Signal Responses
| Signal | Action |
|--------|--------|
| Ugliness | Stop, understand problem deeper |
| Injustice | Survey better locations |
| Stagnation | Assess if territory is uncharted |

### Example
```bash
/post-verify ./src/utils/helper.ts
```
