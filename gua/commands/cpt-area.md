---
description: "Manage tracked code areas and update progress"
argument-hint: "<add|status|update|understand> [args]"
allowed-tools: [Bash, Read]
model: haiku
---

# CPT Area Command

Manage code areas being tracked for progress and understanding depth.

## Arguments

```
$ARGUMENTS

Parse as one of:
- add <project> <path> [name]: Add a new tracked area
- status [project]: Show all tracked areas
- update <area_id> [options]: Update area progress
- understand <path>: Mark that code was studied (bumps understanding depth)

Examples:
  /cpt-area add purpose_prompter gua/ "GUA System"
  /cpt-area status purpose_prompter
  /cpt-area update area#pp#abc123 --impl 75 --depth L3
  /cpt-area understand gua/cli/
```

## Understanding Depth Levels

| Level | Name | Meaning | Triggers |
|-------|------|---------|----------|
| L0 | Unread | Never looked at this code | Initial state |
| L1 | Surveyed | Know it exists, rough purpose | Listed files, read README |
| L2 | Understood | Know structure and flow | Read main files, traced calls |
| L3 | Deep | Know edge cases and why | Resolved challenges, found edge cases |
| L4 | Expert | Could refactor confidently | Made significant changes successfully |

## Granularity Levels

| Level | Use When | Examples |
|-------|----------|----------|
| domain | Tracking broad areas | `gua/`, `pp/`, `auth/` |
| module | Specific components | `gua/cli/`, `auth/oauth/` |
| file | Complex individual files | `gua.sh`, `auth.ts` |
| function | Critical functions | `cmd_load_active_set` |

Start coarse (domain), refine where complexity warrants.

## Step 1: EXECUTE Based on Subcommand

### If subcommand == "add"

```bash
~/.gua/gua.sh area add "<project>" "<path>" "<name>" "<granularity>"
```

After adding, confirm:

```markdown
## Area Added

**Name**: {name}
**Project**: {project}
**Path**: {path}
**Granularity**: {granularity}

Initial state:
- Implementation: 0% (not_started)
- Understanding: L0 (unread)

---
### Next Steps
1. Read the code in this area to increase understanding
2. Update progress as you work: `/cpt-area update <id> --impl X`
3. Log challenges when stuck: `/cpt-challenge <description>`
```

### If subcommand == "status"

```bash
~/.gua/gua.sh area status "<project>"
```

Present as:

```markdown
## Code Areas: {project}

{Output from gua area status}

---
### Legend
- [NOT] not_started | [INP] in_progress | [BLK] blocked | [COM] completed
- Impl: Implementation percentage
- Depth: L0-L4 understanding depth

### Quick Actions
- Update area: `/cpt-area update <id> --impl X --depth LY`
- Add area: `/cpt-area add <project> <path> <name>`
```

### If subcommand == "update"

Parse options: --impl, --depth, --status, --model, --confidence

```bash
~/.gua/gua.sh area update "<area_id>" --impl "<pct>" --depth "<level>" --status "<status>" --model "<description>"
```

### If subcommand == "understand"

When Claude has studied an area, bump the understanding depth:

```bash
# Find the area by path
AREA_ID=$(~/.gua/gua.sh area status | grep "<path>" | grep -oE "area#[^[:space:]]+")

# Get current depth
CURRENT_DEPTH=$(aws dynamodb get-item ... | jq -r '.Item.understanding_depth.S')

# Calculate next depth (L0→L1, L1→L2, etc.)
NEXT_DEPTH="L$((${CURRENT_DEPTH:1} + 1))"

# Update
~/.gua/gua.sh area update "$AREA_ID" --depth "$NEXT_DEPTH"
```

Confirm:

```markdown
## Understanding Updated

**Area**: {area_name}
**Depth**: {old_depth} → {new_depth}

{If L1} You now have a basic survey of this area.
{If L2} You understand the structure and flow.
{If L3} You have deep knowledge including edge cases.
{If L4} You have expert-level understanding.
```

## Step 2: INTEGRATION Guidance

### When to Add Areas

Add areas when:
- Starting work on a new part of the codebase
- Encountering complexity that needs tracking
- Planning multi-session work

### When to Update Progress

Update implementation % when:
- Completing features or fixes
- Reaching milestones
- Shipping code

Update understanding depth when:
- Reading and comprehending code
- Resolving challenges (auto-bump to L3)
- Making successful modifications (auto-bump to L4)

### Adaptive Granularity

Start with `domain` granularity. Refine to `module` or `file` when:
- Multiple challenges in one area
- Different parts at different completion states
- Need finer tracking for complex code

```bash
# Refine: Split domain into modules
~/.gua/gua.sh area add purpose_prompter gua/cli/ "GUA CLI" module
~/.gua/gua.sh area add purpose_prompter gua/commands/ "GUA Commands" module
```

## Examples

```
# Add a new area
/cpt-area add purpose_prompter gua/ "GUA System" domain

# Check status
/cpt-area status purpose_prompter

# Update progress
/cpt-area update area#pp#abc --impl 80 --depth L3 --status in_progress

# Record studying code
/cpt-area understand gua/cli/

# Update mental model
/cpt-area update area#pp#abc --model "Shell CLI + DynamoDB for persistent knowledge"
```
