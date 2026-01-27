---
description: "Inject code progress context into current session"
argument-hint: "[mode: overview | challenges | gaps]"
allowed-tools: [Bash, Read]
model: haiku
---

# CPT Context Command

Inject code progress and challenge context from the Code Progress Tracker into the current session.

## Arguments

```
$ARGUMENTS

Parse as mode:
- overview (default): Progress summary for current/all projects
- challenges: Active challenges with PP dimension breakdown
- gaps: Areas with low understanding depth (L0-L1)

Examples:
  /cpt-context                   # Progress overview
  /cpt-context challenges        # Active challenges
  /cpt-context gaps              # Low-understanding areas
```

## Purpose

This command surfaces Claude's accumulated understanding of code areas across sessions:
- What areas have been worked on
- What challenges were encountered
- What gaps in understanding remain
- Progress toward completion

Use at session start to recall previous context.

## Step 1: CHECK CPT Configuration

```bash
CPT_ENABLED=$(jq -r '.cpt.enabled // false' ~/.gua/config.json 2>/dev/null)
echo "CPT Enabled: $CPT_ENABLED"

if [[ "$CPT_ENABLED" != "true" ]]; then
    echo "CPT not enabled. Run: ~/.gua/upgrade-cpt.sh"
fi
```

## Step 2: EXECUTE Based on Mode

### If mode == "overview" (default)

```bash
~/.gua/gua.sh progress
```

Present as:

```markdown
## CPT Progress Overview

{Output from gua progress}

---
### Session Actions
- Log challenge: `/cpt-challenge <description>`
- Update area: `gua area update <id> --impl X --depth LY`
- View details: `/cpt-context challenges` or `/cpt-context gaps`
```

### If mode == "challenges"

```bash
~/.gua/gua.sh challenge list
~/.gua/gua.sh challenge list --status resolved --limit 5
```

Present as:

```markdown
## Active Challenges

{Output from challenge list}

### Recently Resolved
{Last 5 resolved challenges}

---
### Challenge Categories → PP Dimensions
- **bug** → TRUTH (assumption was false)
- **confusion** → UNDERSTANDING (mental model incomplete)
- **ugly_hack** → BEAUTY (solution doesn't fit)
- **wrong_place** → JUSTICE (code doesn't belong here)
- **dead_end** → CREATIVITY (need new structure)

To resolve: `gua challenge resolve <id> <resolution>`
```

### If mode == "gaps"

```bash
# Query areas with L0-L1 understanding
~/.gua/gua.sh area status | grep -E "Depth: L[01]"
```

Present as:

```markdown
## Understanding Gaps

Areas with L0-L1 understanding depth:

{Areas that haven't been deeply studied}

---
### Understanding Levels
- **L0 (Unread)**: Never looked at this code
- **L1 (Surveyed)**: Know it exists, rough purpose
- **L2 (Understood)**: Know structure and flow
- **L3 (Deep)**: Know edge cases and why
- **L4 (Expert)**: Could refactor confidently

To study an area: Read the files, then update:
`gua area update <id> --depth L2 --model "Brief description"`
```

## Step 3: SUGGEST Next Actions

After presenting context:

```markdown
### Recommended Actions

Based on current state:
1. {If active challenges} → Consider resolving oldest challenge
2. {If gaps exist} → Study areas with low understanding
3. {If progress stalled} → Check for blocked areas

### Quick Commands
- `/cpt-context` - This overview
- `/cpt-challenge <description>` - Log new challenge
- `gua area update <id> --impl X` - Update completion
- `gua progress snapshot` - Save daily progress
```

## Integration with PP

CPT challenges map directly to PP dimensions for root cause analysis:

| Challenge Type | PP Dimension | Signal |
|----------------|--------------|--------|
| Bug | TRUTH | Assumption was wrong |
| Confusion | UNDERSTANDING | Mental model incomplete |
| Ugly Hack | BEAUTY | Solution doesn't fit |
| Wrong Place | JUSTICE | Code misplaced |
| Dead End | CREATIVITY | Need new structure |

When logging a challenge, consider which PP dimension it affects.

## Examples

```
/cpt-context                 # Show progress overview
/cpt-context challenges      # Show active challenges by PP dimension
/cpt-context gaps            # Show areas needing deeper understanding
```
