---
description: "Log or resolve a code challenge with PP dimension mapping"
argument-hint: "<description> or resolve:<id> <resolution>"
allowed-tools: [Bash, Read]
model: haiku
---

# CPT Challenge Command

Log challenges encountered while working on code, with automatic PP dimension mapping for root cause analysis.

## Arguments

```
$ARGUMENTS

Parse as one of:
- <description>: Log a new challenge (will prompt for details)
- resolve:<id> <resolution>: Resolve an existing challenge
- list: List active challenges
- promote:<id>: Promote challenge learning to GUA insight

Examples:
  /cpt-challenge Empty query returns when index not populated
  /cpt-challenge resolve:challenge#2026-01-27#abc123 "Added null check"
  /cpt-challenge list
  /cpt-challenge promote:challenge#2026-01-27#abc123
```

## Purpose

Track challenges to:
1. Remember what blocked progress across sessions
2. Map problems to PP dimensions for systematic resolution
3. Capture learnings when challenges are resolved
4. Promote patterns to GUA for cross-project knowledge

## Step 1: DETECT Current Context

Before logging, determine the current area:

```bash
# Get recent file operations from context
# Look for patterns like: Read /path/to/file or Edit /path/to/file

# Try to find matching area
~/.gua/gua.sh area status | head -20
```

If no area matches, suggest creating one first.

## Step 2: PARSE and EXECUTE

### If logging new challenge (default)

Ask user for PP dimension mapping:

```markdown
## Challenge Category

The description suggests this might be a:

1. **Bug** (TRUTH) - An assumption was wrong
2. **Confusion** (UNDERSTANDING) - Mental model is incomplete
3. **Ugly Hack** (BEAUTY) - Solution doesn't fit elegantly
4. **Wrong Place** (JUSTICE) - Code is in the wrong location
5. **Dead End** (CREATIVITY) - Need to build new structure

Which category best describes this challenge?
```

Then execute:

```bash
# After user confirms area and category
~/.gua/gua.sh challenge log "<area_id>" "<description>" "<pp_dimension>" "<category>"
```

### If resolving challenge

```bash
# Parse: resolve:<id> <resolution>
~/.gua/gua.sh challenge resolve "<challenge_id>" "<resolution>" --learning "<optional_insight>"
```

### If listing challenges

```bash
~/.gua/gua.sh challenge list
```

### If promoting challenge

```bash
~/.gua/gua.sh challenge promote "<challenge_id>"
```

## Step 3: CONFIRM and Guide

After logging:

```markdown
## Challenge Logged

**Description**: {description}
**Area**: {area_id}
**PP Dimension**: {pp_dimension}
**Category**: {category}

---

### Root Cause Analysis

Since this is a **{pp_dimension}** issue:

{If TRUTH}
- The assumption "{related assumption}" may be false
- Verify: Read the actual code, check documentation
- Pattern: "Read before claim, cite file:line"

{If UNDERSTANDING}
- The mental model for this area is incomplete
- Action: Study the code more deeply, trace the flow
- Consider: Why does it work this way?

{If BEAUTY}
- The solution doesn't fit the existing patterns
- Look for: Similar code elsewhere, established conventions
- Goal: Elegance emerges from understanding

{If JUSTICE}
- The code may be in the wrong location
- Survey: What else is in this area? Where do similar things live?
- Principle: Right solution in the right place

{If CREATIVITY}
- Existing patterns don't support this need
- Assess: Is this truly uncharted territory?
- If yes: Build a path that enables future work

### Next Steps
- Continue working, or investigate the root cause
- To resolve: `/cpt-challenge resolve:<id> <resolution>`
- To promote learning: `/cpt-challenge promote:<id>`
```

## PP Dimension Quick Reference

| Category | PP Dimension | Question to Ask |
|----------|--------------|-----------------|
| Bug | TRUTH | "What did I assume that was wrong?" |
| Confusion | UNDERSTANDING | "What don't I understand about this?" |
| Ugly Hack | BEAUTY | "Why doesn't this solution fit?" |
| Wrong Place | JUSTICE | "Where should this actually live?" |
| Dead End | CREATIVITY | "What new structure is needed?" |

## Integration with GUA

When challenges are resolved with valuable learnings:

1. Use `/cpt-challenge promote:<id>` to create a GUA insight
2. The insight is stored in `gua-insights` with full taxonomy
3. Eventually synthesizes into LIGHT.md patterns
4. Cross-project patterns emerge from repeated challenges

## Examples

```
# Log a new challenge
/cpt-challenge DynamoDB scan returns empty when filter doesn't match

# Resolve with learning
/cpt-challenge resolve:challenge#2026-01-27#abc "Fixed by using query instead of scan"

# List active challenges
/cpt-challenge list

# Promote to insight
/cpt-challenge promote:challenge#2026-01-27#abc
```
