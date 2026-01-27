---
description: "Capture insights and observations to the Global Understanding Archive"
argument-hint: "<insight> [type] [evidence] [pp_dimension] [scope]"
allowed-tools: [Bash, Read]
model: haiku
---

# GUA Insight Command

Capture insights and observations to the Global Understanding Archive (AWS-backed) with taxonomy metadata.

## Arguments

```
$ARGUMENTS

Parse as:
- insight: The insight or observation content (required)
- type: observation | pattern | blindspot | hypothesis | anti-pattern | technique | principle | model (default: "observation")
- evidence: Supporting evidence or context (optional)
- pp_dimension: truth | understanding | beauty | justice | creativity (default: infer from content)
- scope: global | domain | project | personal (default: "global")
```

## Insight Types

| Type | Use When |
|------|----------|
| **observation** | Noticed something worth remembering |
| **pattern** | Recurring behavior or approach that works |
| **blindspot** | Identified a gap or weakness |
| **hypothesis** | Untested idea worth exploring |
| **anti-pattern** | Approach that fails or causes problems |
| **technique** | Specific method or procedure |
| **principle** | Guiding rule or truth |
| **model** | Mental framework for understanding |

## PP Dimensions

| Dimension | For Knowledge About |
|-----------|---------------------|
| **truth** | Verification, accuracy, calibration |
| **understanding** | Mental models, comprehension |
| **beauty** | Elegance, fit, coherence |
| **justice** | Placement, ownership, architecture |
| **creativity** | Path-building, pioneering |

## Scopes

| Scope | Applies To |
|-------|------------|
| **global** | All projects, all domains |
| **domain** | Specific technology (aws, typescript, etc.) |
| **project** | Specific codebase only |
| **personal** | Individual working style |

## Step 1: VALIDATE Arguments

Ensure insight content is provided.

If missing, prompt:
```
Usage: /gua-insight <insight> [type] [evidence] [pp_dimension] [scope]

Types: observation, pattern, blindspot, hypothesis, anti-pattern, technique, principle, model
PP Dimensions: truth, understanding, beauty, justice, creativity
Scopes: global, domain, project, personal

Examples:
  /gua-insight "Tiered implementation reduces risk"
  /gua-insight "Always read before claiming" pattern "PP protocol" truth global
  /gua-insight "Tendency to skip territory check" blindspot "Failed 3x" creativity
  /gua-insight "DynamoDB PAY_PER_REQUEST for personal tools" technique "GUA" justice domain
```

## Step 2: INFER PP Dimension if Not Provided

Use these heuristics:
- Mentions verification/accuracy/calibration → **truth**
- Mentions mental models/comprehension/why → **understanding**
- Mentions elegance/fit/coherence/patterns → **beauty**
- Mentions placement/ownership/architecture → **justice**
- Mentions path-building/pioneering/new territory → **creativity**

Default to **understanding** if unclear.

## Step 3: CHECK GUA Configuration

```bash
if [[ -f ~/.gua/config.json ]]; then
    echo "GUA configured"
else
    echo "ERROR: GUA not configured. Run: ~/.gua/setup.sh"
fi
```

If not configured, inform user to run setup.

## Step 4: LOG Insight to AWS with Taxonomy

Execute the gua CLI with all metadata:

```bash
~/.gua/gua.sh insight "{insight}" "{type}" "{evidence}" "{pp_dimension}" "{scope}"
```

## Step 5: CONFIRM and Contextualize

After logging, output:

```
## Insight Captured

**Type**: {type}
**Content**: {insight}
**Evidence**: {evidence or "none provided"}
**PP Dimension**: {pp_dimension}
**Scope**: {scope}

Logged to AWS DynamoDB (gua-insights table) with taxonomy metadata.

---

### What Happens Next

This insight will be:
1. **Stored** in AWS for cross-session persistence
2. **Categorized** by PP dimension and scope
3. **Promotable** to knowledge file via `gua promote <id>`
4. **Synthesized** into LIGHT.md when you run `/integrate`

### Knowledge Taxonomy Location

When promoted, this insight will go to:
- `knowledge/by-dimension/{pp_dimension}/{type}s.md`

**Tip**: Use `gua query insights` to see recent insights and their IDs for promotion.
```

## Step 6: SUGGEST Related Actions

Based on insight type:

**If blindspot**:
```
Consider: What would prevent this blindspot?
Action: Run `gua promote <id> {dimension}` to add to active blindspots
```

**If pattern**:
```
Consider: Can this pattern be codified into a workflow?
Action: When observed 3+ times, promote to confirmed pattern
```

**If hypothesis**:
```
Consider: How could you test this?
Action: Design an experiment for next session
```

**If technique**:
```
Consider: What domain does this apply to?
Action: May also want to add to by-domain/{domain}/patterns.md
```

## Error Handling

If AWS call fails:
1. Check if ~/.gua/config.json exists
2. Check AWS credentials: `aws sts get-caller-identity`
3. Suggest running setup: `~/.gua/setup.sh`

## Examples

```
# Basic (will infer dimension)
/gua-insight "Breaking large tasks into smaller todos improves completion"

# With type
/gua-insight "Signal detection catches 80% of quality issues" pattern "Tracked across 10 sessions"

# With type and evidence
/gua-insight "Forget to check territory when task seems simple" blindspot "Failed 3x"

# Full taxonomy
/gua-insight "Always cite file:line for claims" pattern "PP protocol" truth global
/gua-insight "Use PAY_PER_REQUEST for personal AWS" technique "GUA" justice domain
/gua-insight "Hookify can inject context on events" pattern "PP trigger" creativity domain
```

## Integration with Knowledge Taxonomy

This command captures raw insights. To promote to structured knowledge:

```
1. Capture: /gua-insight "..."
2. Query: gua query insights
3. Promote: gua promote <timestamp_uuid> [dimension]
4. Verify: /gua-context dimension:{dim}
```

Insights start as `hypothesis` confidence and at `L1` depth. Promotion increases confidence to `emerging` and depth to `L2`.
