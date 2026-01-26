---
description: "Detect drift between PP documentation and implementation - finds ghost commands, orphan commands, stale descriptions"
argument-hint: "[fix] - optional, auto-update CLAUDE.md to match reality"
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash]
model: sonnet
---

# PP Drift Check Command

Detect and optionally fix drift between PP documentation and actual implementation.

## Arguments

Mode (optional): $ARGUMENTS
- No argument: Report only
- `fix`: Auto-update CLAUDE.md to match reality

## Purpose

Drift detection prevents truth violations:
- **Ghost commands**: Documented but don't exist (truth violation)
- **Orphan commands**: Exist but not documented (completeness gap)
- **Stale descriptions**: Implementation changed, docs didn't

## The Ghost Command Problem

```
CLAUDE.md says: "/pp-magic - Do something magical"
Reality: pp-magic.md doesn't exist

Result: User tries /pp-magic → Nothing happens → Trust broken

This is a TRUTH VIOLATION - the most severe PP failure.
```

## Protocol

### Step 1: Extract Documented Commands

```
ACTION: Parse CLAUDE.md for command references

GREP patterns in ~/.claude/CLAUDE.md:
- `/[a-z-]+` (slash commands)
- `| \`/[a-z-]+\`` (table entries)

STORE: DOCUMENTED_COMMANDS = [list of command names]

Example output:
- /verify
- /deep-understand
- /signal
- /territory
- /pp
- /pp-feedback
- /pp-review
- /pp-learnings
- /pp-refine
- /self-verify
```

### Step 2: Discover Actual Commands

```
ACTION: Glob command files

GLOB: ~/.claude/plugins/hierarchy-tools/commands/*.md
EXTRACT: Command names (filename without .md)

STORE: ACTUAL_COMMANDS = [list of command names]

Example output:
- verify
- deep-understand
- signal
- territory
- pp
- pp-feedback
- pp-review
- pp-learnings
- pp-refine
- self-verify
- pp-health
- pp-drift-check
```

### Step 3: Compute Drift

```
GHOST_COMMANDS = DOCUMENTED_COMMANDS - ACTUAL_COMMANDS
  (Documented but don't exist)

ORPHAN_COMMANDS = ACTUAL_COMMANDS - DOCUMENTED_COMMANDS
  (Exist but not documented)

MATCHED_COMMANDS = DOCUMENTED_COMMANDS ∩ ACTUAL_COMMANDS
  (Properly aligned)
```

### Step 4: Check Description Accuracy (Optional Deep Check)

```
FOR each MATCHED_COMMAND:
  1. Read command file frontmatter (description field)
  2. Find description in CLAUDE.md
  3. Compare for semantic match
  4. Flag if significantly different
```

### Step 5: Report Findings

```
OUTPUT drift report (see format below)
```

### Step 6: Auto-Fix (if requested)

```
IF $ARGUMENTS contains "fix":

  FOR each ORPHAN_COMMAND:
    1. Read command file
    2. Extract description from frontmatter
    3. Add to CLAUDE.md command table

  FOR each GHOST_COMMAND:
    1. Remove from CLAUDE.md
    -- OR --
    2. Create stub command file (user choice)

  OUTPUT: "Fixed [X] drift issues. Verify changes."
```

## Output Format

### Drift Report

```markdown
## PP Drift Check Report

**Timestamp**: [ISO8601]
**CLAUDE.md**: [line count] lines
**Commands discovered**: [count]

### Alignment Summary

| Category | Count | Status |
|----------|-------|--------|
| Matched | [X] | ✅ Aligned |
| Ghost | [Y] | ❌ Truth violation |
| Orphan | [Z] | ⚠️ Undocumented |

### Ghost Commands (CRITICAL - Truth Violations)

These are documented in CLAUDE.md but DON'T EXIST:

| Command | Documented Location | Action Needed |
|---------|---------------------|---------------|
| /[name] | CLAUDE.md:[line] | Remove from docs OR create command |

**Impact**: Users will try these commands and fail. This breaks trust.

### Orphan Commands (Missing Documentation)

These exist but are NOT documented in CLAUDE.md:

| Command | File | Description |
|---------|------|-------------|
| /[name] | commands/[name].md | [from frontmatter] |

**Impact**: Users won't discover these features.

### Matched Commands (Aligned)

| Command | Documented | Implemented |
|---------|------------|-------------|
| /verify | ✅ | ✅ |
| /signal | ✅ | ✅ |
| ... | | |

### Recommendations

**Immediate (Truth violations)**:
1. [Fix ghost commands]

**Important (Completeness)**:
2. [Document orphan commands]

### Auto-Fix Available

Run `/pp-drift-check fix` to automatically:
- Remove ghost commands from CLAUDE.md
- Add orphan commands to CLAUDE.md command table
```

## Integration with Self-Verify

`/self-verify` should call `/pp-drift-check` as part of Truth gate verification:

```
Truth Gate: Grounding
├── Check: Do PP claims match reality?
└── Method: /pp-drift-check
    └── Ghost commands = FAIL Grounding gate
```

## Integration with PP Health

`/pp-health` does a quick drift check:
- Counts ghost/orphan commands
- Doesn't show details
- Suggests `/pp-drift-check` for full report

## Prevention

After any PP modification:
1. Run `/pp-drift-check`
2. Fix any drift immediately
3. Never commit with drift

Add to workflow:
```
PP modification → /pp-drift-check → Fix drift → Commit
```

## The Truth Promise

```
PP claims only what exists.
PP documents only what is implemented.
PP's words match PP's reality.

Drift is the enemy of truth.
/pp-drift-check is the guardian.
```
