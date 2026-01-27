---
description: "Capture an 'ahh hah' moment - the raw realization during thinking"
argument-hint: "<insight> [type] [catalyst]"
allowed-tools: [Bash, Read]
model: haiku
---

# Eureka Command

Capture eureka moments - the "ahh hah" realizations during thinking, not just polished insights.

## Arguments

```
$ARGUMENTS

Parse as:
- insight: The realization content (required)
- type: connection | resolution | pattern | constraint | reframe | simplify | counter_intuitive (default: "resolution")
- catalyst: What triggered the realization (optional)
```

## Eureka Types

| Type | What It Is | Example |
|------|------------|---------|
| **connection** | Linking separate ideas | "Signal system and CPT challenges are the same!" |
| **resolution** | Confusion → clarity | "That's why it wasn't working - the filter returns null!" |
| **pattern** | Recognizing recurrence | "All three failures have the same root cause" |
| **constraint** | Understanding impossibility | "DynamoDB can't do cross-partition transactions" |
| **reframe** | Shifting perspective | "Not 'where to put' but 'what owns it'" |
| **simplify** | Complexity collapse | "All cases reduce to one rule" |
| **counter_intuitive** | Reality vs expectation | "More abstraction made it HARDER" |

## Type → PP Dimension Mapping

| Type | PP Dimension | Why |
|------|--------------|-----|
| connection, reframe | UNDERSTANDING | Links build mental models |
| resolution, constraint, counter_intuitive | TRUTH | Clarifies what's actually true |
| pattern, simplify | BEAUTY | Reveals elegant structure |

## Step 1: VALIDATE Arguments

If no insight provided:
```
Usage: /eureka <insight> [type] [catalyst]

Types:
  connection       - Linking previously separate ideas
  resolution       - Confusion clearing to clarity
  pattern          - Recognizing recurring structure
  constraint       - Understanding impossibility
  reframe          - Problem reconceptualization
  simplify         - Complexity collapse
  counter_intuitive - Reality contradicting expectation

Examples:
  /eureka "The null was from the filter" resolution "reading error trace"
  /eureka "Challenges are immature insights" connection "reading gua-insight.md"
  /eureka "All reduce to one rule" simplify
```

## Step 2: AUTO-DETECT Context (if not provided)

If no catalyst provided, infer from recent activity:
- If just read a file → "reading [filename]"
- If just ran a command → "running [command]"
- If in PP execution → "PP phase [current phase]"
- Default → "thinking"

## Step 3: LOG to GUA

Execute:
```bash
~/.gua/gua.sh eureka log "{insight}" "{type}" "{catalyst}" "{task_context}"
```

## Step 4: CONFIRM Capture

Output:
```
## Eureka Captured!

**Type**: {type}
**Content**: {insight}
**Catalyst**: {catalyst}
**PP Dimension**: {inferred dimension}

---

### What Happens Next

This eureka moment will be:
1. **Stored** in AWS (gua-knowledge-index)
2. **Linked** to current session (if active)
3. **Analyzable** via `gua eureka analyze`
4. **Promotable** to insight via `gua eureka promote <id>`

### Why Capture Eurekas?

Unlike polished insights, eurekas capture:
- The **before state** (what was confusing)
- The **catalyst** (what triggered clarity)
- The **transformation** (how thinking shifted)

This enables meta-learning about HOW understanding happens.

---

Use `gua eureka list` to see recent moments.
Use `gua eureka analyze` to find patterns in your eurekas.
```

## Step 5: SUGGEST Follow-up

Based on type:

**If connection**:
```
Consider: What else might these connected ideas link to?
```

**If resolution**:
```
Consider: Log this confusion pattern to prevent recurrence.
```

**If pattern**:
```
Consider: Can this pattern be generalized into a principle?
```

**If constraint**:
```
Consider: Document this constraint in architecture notes.
```

**If reframe**:
```
Consider: Does this reframe apply to other problems?
```

**If simplify**:
```
Consider: Can this simplification be codified?
```

**If counter_intuitive**:
```
Consider: What false assumption led to the wrong intuition?
```

## Quick Examples

```
# Basic capture
/eureka "The timeout was causing the retry loop"

# With type
/eureka "Both systems use the same pattern" connection

# Full capture
/eureka "Null checks should happen at boundaries, not everywhere" pattern "reviewing auth code"
```

## Integration

Eurekas integrate with:
- **PP signals** - Resolved signals often produce eurekas
- **CPT challenges** - Resolved challenges often produce eurekas
- **GUA insights** - Promoted eurekas become insights
- **LIGHT.md** - Synthesis includes eureka analysis
