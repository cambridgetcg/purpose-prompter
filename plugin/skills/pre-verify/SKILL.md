---
name: pre-verify
description: "Run pre-tool verification checks before Edit/Write operations"
version: 1.0.0
---

# Pre-Tool Verification Skill

Quick verification gate before modifying a file. Ensures PP execution laws are followed.

## Target File
$ARGUMENTS

---

## Load Full Protocol

Read the complete pre-verify command protocol:
```
Read: ~/.claude/plugins/hierarchy-tools/commands/pre-verify.md
```

Execute according to that protocol with the provided arguments.

---

## Quick Reference

### What It Checks
1. **READ** - Has file been read in this session?
2. **PATTERN** - Is there similar code to follow?
3. **PLACEMENT** - Does file belong in this location?
4. **COHERENCE** - Does change match existing style?

### Output Format
```
[PP:PRE-VERIFY] [file] - READ✓ PATTERN✓ PLACEMENT✓ → PROCEED
```

Or detailed:
```
Pre-Tool Verification: [file]
═══════════════════════════════
READ:      ✓ Read (45 lines)
PATTERN:   ✓ Following utils.ts:12
PLACEMENT: ✓ Belongs in /src/lib
COHERENCE: ✓ camelCase, JSDoc comments

Verdict: PROCEED
```

### Example
```bash
/pre-verify ./src/utils/helper.ts
```
