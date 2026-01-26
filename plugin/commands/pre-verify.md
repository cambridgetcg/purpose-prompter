---
description: "Run pre-tool verification checks before Edit/Write operations"
argument-hint: "[file] - the file about to be modified"
allowed-tools: [Read, Glob, Grep]
model: haiku
---

# Pre-Tool Verification Command

Quick verification gate before modifying a file. Run this before Edit/Write to ensure PP laws are followed.

## Arguments

```
$ARGUMENTS

Parse as:
- file: The file path about to be modified
```

---

## Verification Protocol

### Step 1: READ CHECK

```
Has the file been read in this conversation?

IF file was read:
  → Output: "✓ READ: [file] read ([N] lines)"

ELSE:
  → Read the file now
  → Output: "✓ READ: [file] read ([N] lines) - loaded now"
```

### Step 2: PATTERN CHECK

```
Search for similar code in codebase:
1. Grep for similar function/class names
2. Glob for similar file patterns
3. Read any close matches

IF pattern found:
  → Output: "✓ PATTERN: Following [file:line] - [brief description]"

ELSE:
  → Output: "⚠ PATTERN: No similar code found - verify this is intentional"
```

### Step 3: PLACEMENT CHECK

```
Survey the file's location context:
1. What directory is this in?
2. What other files are nearby?
3. Does this file's purpose match its location?

Output: "✓ PLACEMENT: [file] belongs in [dir] because [reason]"

IF placement seems wrong:
  → Output: "⚠ PLACEMENT: Consider [alternative] instead because [reason]"
```

### Step 4: COHERENCE CHECK

```
Examine the file's existing style:
1. Naming conventions used
2. Code structure patterns
3. Comment style

Output: "✓ COHERENCE: Style notes - [brief notes]"
```

---

## Output Format

```
Pre-Tool Verification: [file]
═══════════════════════════════

READ:      [✓/⚠] [status]
PATTERN:   [✓/⚠] [status]
PLACEMENT: [✓/⚠] [status]
COHERENCE: [✓/⚠] [status]

Verdict: [PROCEED / INVESTIGATE]

[If INVESTIGATE, explain what needs resolution]
```

---

## Quick Mode

For simple verifications, output single line:

```
[PP:PRE-VERIFY] [file] - READ✓ PATTERN✓ PLACEMENT✓ → PROCEED
```

---

## Integration

This command is called automatically by `/pp` before each Edit/Write when execution enforcement is active.

Can also be invoked manually:
```
/pre-verify ./src/utils/helper.ts
```
