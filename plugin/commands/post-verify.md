---
description: "Run post-tool verification checks after Edit/Write operations"
argument-hint: "[file] - the file that was just modified"
allowed-tools: [Read, Glob, Grep]
model: haiku
---

# Post-Tool Verification Command

Verification gate after modifying a file. Run this after Edit/Write to check for signals.

## Arguments

```
$ARGUMENTS

Parse as:
- file: The file path that was just modified
```

---

## Verification Protocol

### Step 1: SIGNAL CHECK

```
Examine the change just made:

UGLINESS signals:
- Does the code feel forced or awkward?
- Is there unnecessary complexity?
- Does it fight the surrounding code?

INJUSTICE signals:
- Does the code feel misplaced?
- Should it be somewhere else?
- Does it violate module boundaries?

STAGNATION signals:
- Did we force-fit into inadequate structure?
- Is there a pattern that should exist but doesn't?
- Are we working around limitations?

IF any signal detected:
  → Output: "⚠ SIGNAL: [type] detected - [description]"
  → Recommend: "[what to investigate]"

ELSE:
  → Output: "✓ SIGNAL: Clean"
```

### Step 2: COHERENCE CHECK

```
Re-read the modified section:
1. Does naming match conventions?
2. Does structure match surrounding code?
3. Is complexity appropriate?

IF coherent:
  → Output: "✓ COHERENCE: Fits naturally"

ELSE:
  → Output: "⚠ COHERENCE: [issue] - consider [adjustment]"
```

### Step 3: INTEGRATION CHECK

```
Consider the change in context:
1. Does it connect properly to related code?
2. Are imports/exports correct?
3. Does it break any existing functionality?

IF integrated:
  → Output: "✓ INTEGRATION: Connected properly"

ELSE:
  → Output: "⚠ INTEGRATION: [issue]"
```

---

## Output Format

```
Post-Tool Verification: [file]
═══════════════════════════════

SIGNAL:      [✓/⚠] [status]
COHERENCE:   [✓/⚠] [status]
INTEGRATION: [✓/⚠] [status]

Verdict: [CONTINUE / INVESTIGATE / ROLLBACK]

[If not CONTINUE, explain what needs resolution]
```

---

## Quick Mode

For simple verifications, output single line:

```
[PP:POST-VERIFY] [file] - SIGNAL✓ COHERENCE✓ → CONTINUE
```

---

## Signal Response Actions

```
IF UGLINESS:
  → Don't proceed with more changes
  → Understand the problem deeper
  → May need to undo and rethink

IF INJUSTICE:
  → Consider moving the code
  → Survey better locations
  → May need to refactor

IF STAGNATION:
  → Territory may be uncharted
  → Consider building new structure
  → Run /territory to assess
```

---

## Integration

This command is called automatically by `/pp` after each Edit/Write when execution enforcement is active.

Can also be invoked manually:
```
/post-verify ./src/utils/helper.ts
```
