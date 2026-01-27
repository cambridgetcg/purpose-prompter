# Eureka Recorder: Capturing "Ahh Hah" Moments

> **Vision**: Capture the raw moments of realization during Claude's thinking process - not just the polished insights, but the transformation from confusion to clarity.

---

## The Problem

Current insight capture (`/gua-insight`) is:
- **Deliberate** - Requires explicit invocation
- **Post-hoc** - Captured after refinement
- **Static** - Just the insight, not the journey

What's lost:
- The "before" state (what was confusing)
- The catalyst (what triggered clarity)
- The transformation (how thinking shifted)
- The raw realization (before polish)

---

## The Vision

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         EUREKA RECORDER                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  THINKING PROCESS                          CAPTURE                          │
│  ─────────────────                         ───────                          │
│                                                                              │
│  Working on task X...                                                        │
│  Confused about Y...                      ┌─────────────┐                   │
│  Trying approach A...                     │  TRIGGER    │                   │
│  Trying approach B...                     │  context    │                   │
│  Reading code at Z...         ─────────►  │  confusion  │                   │
│                                           │  catalyst   │                   │
│  "Oh! It's because W!"        ─────────►  ├─────────────┤                   │
│                                           │ REALIZATION │                   │
│  This means V, U, T...        ─────────►  │  content    │                   │
│                                           │  type       │                   │
│                                           │  impact     │                   │
│                                           └─────────────┘                   │
│                                                  │                          │
│                                                  ▼                          │
│                                           ┌─────────────┐                   │
│                                           │   AWS       │                   │
│                                           │ DynamoDB    │                   │
│                                           └─────────────┘                   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Seven Types of Eureka Moments

| Type | Description | Example |
|------|-------------|---------|
| **CONNECTION** | Linking previously separate ideas | "The signal system and CPT challenges are the same thing!" |
| **RESOLUTION** | Confusion clearing to clarity | "That's why it wasn't working - the filter returns null!" |
| **PATTERN** | Recognizing recurring structure | "All three failures had the same root cause" |
| **CONSTRAINT** | Understanding impossibility | "DynamoDB can't do cross-partition transactions" |
| **REFRAME** | Problem reconceptualization | "It's not 'where to put it' but 'what owns it'" |
| **SIMPLIFY** | Complexity collapse | "All these cases reduce to one rule" |
| **COUNTER-INTUITIVE** | Reality contradicting expectation | "More abstraction made it HARDER" |

---

## Recognition Techniques

### 1. Linguistic Marker Detection

**High-Confidence Markers** (almost always eureka):
```
"Oh, I see..."
"Ah, so..."
"Wait, that means..."
"That's why!"
"The key insight is..."
"This changes everything because..."
"Now I understand why..."
```

**Medium-Confidence Markers** (context-dependent):
```
"So the real issue is..."
"Actually, it's..."
"The pattern here is..."
"Interestingly..."
```

### 2. State Transition Detection

| Before State | → | After State |
|--------------|---|-------------|
| Exploring options | → | Confident direction |
| Multiple hypotheses | → | Single explanation |
| Confusion markers | → | Clarity markers |
| "Why doesn't..." | → | "It's because..." |
| "Trying to..." | → | "The answer is..." |

### 3. Structural Pattern Detection

The "eureka structure" in thinking:
```
1. CONTEXT: Working on X
2. CONFUSION: But Y doesn't make sense
3. EXPLORATION: Maybe it's A... or B... or C...
4. CATALYST: *reads something* or *connects two ideas*
5. EUREKA: Oh! It's because Z!
6. IMPLICATIONS: This means W, V, U...
```

### 4. Self-Annotation (Trained Behavior)

During thinking, annotate:
```
[EUREKA:CONNECTION] Just realized X relates to Y
[EUREKA:RESOLUTION] Found why Z wasn't working
[EUREKA:PATTERN] Seeing the same structure in A, B, C
```

### 5. Post-Task Reflection

After task completion, review thinking for:
- Moments where direction changed suddenly
- Points where confusion → clarity
- Connections not obvious at start

---

## Capture Format

### Full Schema

```json
{
  "moment_id": "eureka#{timestamp}#{short_uuid}",
  "knowledge_type": "eureka_moment",

  "trigger": {
    "task_context": "What was being worked on",
    "confusion_state": "What wasn't understood",
    "exploration_path": "What was being tried",
    "catalyst": "What triggered the realization"
  },

  "realization": {
    "content": "The insight itself - the 'ahh hah'",
    "type": "connection|resolution|pattern|constraint|reframe|simplify|counter_intuitive",
    "one_liner": "Distilled to one sentence"
  },

  "impact": {
    "changes_understanding_of": "What existing knowledge this affects",
    "enables": "What becomes possible now",
    "prevents": "What mistakes/confusion this prevents",
    "pp_dimension": "truth|understanding|beauty|justice|creativity"
  },

  "evidence": {
    "files_involved": ["file:line", ...],
    "thinking_excerpt": "The actual thinking where it happened"
  },

  "meta": {
    "thinking_phase": "early|mid|late",
    "session_id": "UUID of session",
    "confidence": "immediate|needs_verification",
    "promoted": false,
    "promoted_to": null
  },

  "timestamp": "ISO 8601",
  "user_id": "User identifier"
}
```

### Minimal Capture Format

```
/eureka "The insight" [type] [catalyst]
```

Expands to full format with auto-detected context.

---

## AWS Architecture

### Extend gua-knowledge-index

No new table needed. Reuse existing with new `knowledge_type`:

```
Table: gua-knowledge-index (existing)

New knowledge_type: "eureka_moment"

Primary Key:
  PK: user_id (S)
  SK: knowledge_id (S)  → "eureka#{timestamp}#{uuid}"

Attributes:
  knowledge_type: "eureka_moment"

  # Trigger Context
  task_context: (S)
  confusion_state: (S)
  exploration_path: (S)
  catalyst: (S)

  # Realization
  content: (S)
  eureka_type: (S)
  one_liner: (S)

  # Impact
  changes_understanding: (S)
  enables: (S)
  prevents: (S)
  pp_dimension: (S)

  # Evidence
  files_involved: (L)
  thinking_excerpt: (S)

  # Meta
  thinking_phase: (S)
  session_id: (S)
  confidence: (S)
  promoted: (BOOL)
  promoted_to: (S)

  # Standard
  created_at: (S)
  updated_at: (S)
```

### New GSIs Required

```
eureka-type-index:
  PK: eureka_type (S)
  SK: created_at (S)
  Purpose: "Show all CONNECTIONs"

session-eurekas-index:
  PK: session_id (S)
  SK: created_at (S)
  Purpose: "Eurekas from this session"
```

### Upgrade Script: upgrade-eureka.sh

```bash
#!/bin/bash
# Upgrade gua-knowledge-index with eureka GSIs

set -e
REGION="${AWS_REGION:-us-west-2}"

echo "Adding eureka GSIs to gua-knowledge-index..."

aws dynamodb update-table \
    --table-name gua-knowledge-index \
    --attribute-definitions \
        AttributeName=eureka_type,AttributeType=S \
        AttributeName=session_id,AttributeType=S \
    --global-secondary-index-updates \
        "[
            {
                \"Create\": {
                    \"IndexName\": \"eureka-type-index\",
                    \"KeySchema\": [
                        {\"AttributeName\": \"eureka_type\", \"KeyType\": \"HASH\"},
                        {\"AttributeName\": \"created_at\", \"KeyType\": \"RANGE\"}
                    ],
                    \"Projection\": {\"ProjectionType\": \"ALL\"}
                }
            },
            {
                \"Create\": {
                    \"IndexName\": \"session-eurekas-index\",
                    \"KeySchema\": [
                        {\"AttributeName\": \"session_id\", \"KeyType\": \"HASH\"},
                        {\"AttributeName\": \"created_at\", \"KeyType\": \"RANGE\"}
                    ],
                    \"Projection\": {\"ProjectionType\": \"ALL\"}
                }
            }
        ]" \
    --region "$REGION"

echo "GSIs created. They will take a few minutes to become active."
echo "Check status: aws dynamodb describe-table --table-name gua-knowledge-index --query 'Table.GlobalSecondaryIndexes'"
```

### Optional: S3 for Large Excerpts

```
s3://gua-archive-{user}/eureka/{moment_id}/thinking.md
```

DynamoDB stores reference, S3 stores full thinking excerpt if >4KB.

---

## Integration Points

### PP Integration

```
PP WORKFLOW
─────────────────────────────────────────────────────
Phase 0: Territory Assessment
  └─→ If territory confusion → eureka potential HIGH

Phase 1: Understanding
  └─→ PRIME eureka detection zone
  └─→ Monitor for RESOLUTION, PATTERN, REFRAME types

Phase 2: Execution
  └─→ If signal detected → eureka potential HIGH
  └─→ When signal addressed → likely RESOLUTION eureka

Phase 3: Verification
  └─→ If unexpected result → COUNTER-INTUITIVE potential
  └─→ Post-task reflection → catch missed eurekas
```

### GUA Integration

```
EUREKA → GUA FLOW
─────────────────────────────────────────────────────
Eureka captured
    │
    ▼
[immediate storage in gua-knowledge-index]
    │
    ▼
[session continues...]
    │
    ▼
gua eureka promote <id>
    │
    ▼
Creates insight in gua-insights with:
  - type: derived from eureka_type
  - evidence: from eureka context
  - pp_dimension: from eureka
  - promotion_source: eureka#{id}
    │
    ▼
LIGHT.md synthesis includes promoted eurekas
```

### CPT Integration

```
EUREKA → CPT FLOW
─────────────────────────────────────────────────────
If eureka.files_involved overlaps with tracked area:
    │
    ▼
Auto-link eureka to area
    │
    ▼
Consider: Should understanding depth increase?
  - RESOLUTION about code → bump depth
  - PATTERN in codebase → bump depth
    │
    ▼
If eureka resolves active challenge:
  - Suggest: gua challenge resolve <id> using eureka insight
```

### LIGHT.md Integration

```
When synthesizing LIGHT.md:

Section: "Recent Eureka Moments"
  - Last 5 eurekas with one-liners
  - Grouped by type
  - Pattern: "Many CONNECTIONs suggest X..."

Section: "Eureka-Derived Insights"
  - Promoted eurekas → confirmed patterns
  - High-frequency eureka types → meta-pattern
```

---

## CLI Commands

### Eureka Management

```bash
# Log a eureka moment
gua eureka log "<content>" [type] [catalyst]

# List eurekas
gua eureka list [--type TYPE] [--session SESSION] [--limit N]

# Show eureka details
gua eureka show <eureka_id>

# Promote to insight
gua eureka promote <eureka_id>

# Session summary
gua eureka session [session_id]

# Type analysis
gua eureka analyze [--type TYPE]
```

### Plugin Command: /eureka

```markdown
---
description: "Capture an 'ahh hah' moment during thinking"
argument-hint: "<insight> [type] [catalyst]"
allowed-tools: [Bash, Read]
model: haiku
---

/eureka "<insight>" [type] [catalyst]

Types: connection, resolution, pattern, constraint, reframe, simplify, counter_intuitive

Auto-detects: task context, files involved, thinking phase
```

---

## Implementation Phases

### Phase 1: MVP (Foundation)

| Task | Description |
|------|-------------|
| Add `gua eureka log` | Basic capture to DynamoDB |
| Add `gua eureka list` | List recent eurekas |
| Create `/eureka` plugin | Quick capture command |
| Test basic flow | Capture → Store → Retrieve |

### Phase 2: Integration

| Task | Description |
|------|-------------|
| Add GSIs | eureka-type-index, session-eurekas-index |
| Add `gua eureka promote` | Promote to insight |
| Hookify detection | Suggest capture on linguistic markers |
| Link to CPT | Auto-link to code areas |

### Phase 3: Synthesis

| Task | Description |
|------|-------------|
| LIGHT.md eureka section | Include in synthesis |
| Pattern analysis | Analyze across eurekas |
| Auto-detection | More sophisticated detection |
| Meta-learning | Patterns in how understanding happens |

---

## The Key Insight

The value isn't just capturing insights - it's capturing the **MOMENT OF TRANSFORMATION**.

The "before" state (confusion) is as valuable as the "after" state (clarity) because it reveals:
- Where understanding was incomplete
- What triggered the shift
- How thinking evolved

This enables **meta-learning**: understanding HOW understanding happens.

---

## Eureka Type → PP Dimension Mapping

| Eureka Type | Primary PP Dimension | Why |
|-------------|---------------------|-----|
| CONNECTION | UNDERSTANDING | Links build mental models |
| RESOLUTION | TRUTH | Clarifies what's actually true |
| PATTERN | BEAUTY | Reveals elegant underlying structure |
| CONSTRAINT | TRUTH | Defines boundaries of possibility |
| REFRAME | UNDERSTANDING | Shifts mental model |
| SIMPLIFY | BEAUTY | Reveals essential form |
| COUNTER-INTUITIVE | TRUTH | Corrects false assumptions |

---

## Example Eureka Capture

```json
{
  "moment_id": "eureka#2026-01-27T15:30:00Z#abc12",
  "knowledge_type": "eureka_moment",

  "trigger": {
    "task_context": "Designing CPT challenge → insight promotion flow",
    "confusion_state": "Unclear if challenges should become insights or remain separate",
    "exploration_path": "Considered: separate tables, references, embedding",
    "catalyst": "Reading existing insight taxonomy in gua-insight.md"
  },

  "realization": {
    "content": "Challenges and insights are both knowledge - just at different maturity levels. A challenge is an 'immature insight' waiting to be resolved and promoted.",
    "type": "connection",
    "one_liner": "Challenges are immature insights"
  },

  "impact": {
    "changes_understanding_of": "The relationship between CPT and GUA",
    "enables": "Unified knowledge model, clear promotion path",
    "prevents": "Creating redundant storage, unclear boundaries",
    "pp_dimension": "understanding"
  },

  "evidence": {
    "files_involved": ["gua/commands/gua-insight.md:37", "gua/cli/gua.sh:450"],
    "thinking_excerpt": "Looking at the insight types (observation, pattern, blindspot...)... wait, a challenge IS basically an observation that needs resolution. The promotion path is: challenge → resolve → extract learning → becomes insight!"
  },

  "meta": {
    "thinking_phase": "mid",
    "session_id": "ba49f5ba-8439-480d-b8de-d3ec281a6f26",
    "confidence": "immediate",
    "promoted": false,
    "promoted_to": null
  },

  "timestamp": "2026-01-27T15:30:00Z",
  "user_id": "yu"
}
```

---

## Version History

- **1.0** (2026-01-27): Initial design
  - Seven eureka types defined
  - Recognition techniques documented
  - AWS architecture designed
  - Integration points mapped

---

## Files to Create/Modify

| File | Action | Purpose |
|------|--------|---------|
| `gua/cli/gua.sh` | MODIFY | Add eureka commands |
| `gua/cli/upgrade-eureka.sh` | CREATE | Add GSIs |
| `gua/commands/eureka.md` | CREATE | Plugin command |
| `gua/docs/EUREKA_RECORDER_DESIGN.md` | CREATE | This document |
| `~/.claude/hookify.eureka-suggest.local.md` | CREATE | Detection hook |

---

## Success Criteria

After implementation:
1. `/eureka "insight"` captures to DynamoDB
2. `gua eureka list` shows recent eurekas
3. `gua eureka promote <id>` creates insight
4. Linguistic markers trigger capture suggestion
5. LIGHT.md synthesis includes eureka section
6. Pattern analysis reveals meta-insights about understanding
