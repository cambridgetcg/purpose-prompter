# MD Insight Integrator: Design Brainstorm

> **Vision**: A skill that reads accumulated session artifacts and synthesizes them into **LIGHT** (understanding) and **PATH** (direction forward).

---

## The Problem

Currently PP accumulates knowledge but doesn't integrate it:

```
SESSION 1 → feedback entry → stored
SESSION 2 → feedback entry → stored
SESSION 3 → feedback entry → stored
...
SESSION N → feedback entry → stored

Result: Pile of entries, no synthesis
```

Each session starts fresh. Patterns exist in the data but aren't extracted. Blindspots repeat. Wisdom doesn't compound.

---

## The Vision

```
┌─────────────────────────────────────────────────────────────┐
│                  INSIGHT INTEGRATOR                          │
│                                                              │
│   ┌─────────┐    ┌─────────────┐    ┌──────────────────┐   │
│   │ GATHER  │ →  │  ANALYZE    │ →  │   SYNTHESIZE     │   │
│   │         │    │             │    │                  │   │
│   │ Read    │    │ Extract     │    │ LIGHT.md         │   │
│   │ all MDs │    │ patterns    │    │ (understanding)  │   │
│   │         │    │             │    │                  │   │
│   │         │    │ Detect      │    │ PATH.md          │   │
│   │         │    │ themes      │    │ (direction)      │   │
│   │         │    │             │    │                  │   │
│   │         │    │ Find        │    │ Updated          │   │
│   │         │    │ blindspots  │    │ blindspots.md    │   │
│   └─────────┘    └─────────────┘    └──────────────────┘   │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## What is "LIGHT"?

**LIGHT = Illumination of what has been learned**

Not a summary. Not a list. UNDERSTANDING that emerges from accumulated experience.

### LIGHT.md Structure

```markdown
# LIGHT - Current Understanding

## Last Integrated: [timestamp]
## Sessions Analyzed: [N]
## Confidence Level: [LOW/MEDIUM/HIGH based on data volume]

---

## Confirmed Patterns (HIGH confidence)

Patterns observed repeatedly, across multiple contexts:

### Pattern: [Name]
- **Observed**: [N] times across [M] sessions
- **Context**: When [situation], [outcome] tends to occur
- **Implication**: This suggests [insight]
- **Evidence**: [session refs]

---

## Emerging Patterns (MEDIUM confidence)

Starting to see, but not yet confirmed:

### Pattern: [Name]
- **Observed**: [N] times
- **Tentative insight**: [description]
- **Needs**: More data to confirm

---

## Questions (require investigation)

What we don't yet understand:

1. Why does [X] sometimes lead to [Y] but sometimes to [Z]?
2. What's the relationship between [A] and [B]?
3. Under what conditions does [pattern] hold?

---

## Contradictions (require resolution)

Patterns that conflict:

1. **[Pattern A]** vs **[Pattern B]**
   - Context where A holds: [description]
   - Context where B holds: [description]
   - Possible resolution: [hypothesis]

---

## Blindspots (active weaknesses)

Things we consistently miss or get wrong:

1. **[Blindspot]**: Tendency to [specific weakness]
   - Observed in: [sessions]
   - Mitigation: [suggested approach]

---

## Current State of Understanding

### What We Know Well
- [Area 1]: HIGH understanding
- [Area 2]: HIGH understanding

### What We're Learning
- [Area 3]: MEDIUM understanding, improving
- [Area 4]: MEDIUM understanding, stagnant

### What We Don't Know
- [Area 5]: LOW understanding, critical gap
- [Area 6]: LOW understanding, less critical
```

---

## What is "PATH"?

**PATH = Direction forward based on understanding**

Not a todo list. WISDOM about where to focus next.

### PATH.md Structure

```markdown
# PATH - Direction Forward

## Last Updated: [timestamp]
## Based on: LIGHT.md from [timestamp]

---

## Immediate Focus (This Session)

Based on current understanding, prioritize:

### Priority 1: [Action]
- **Why**: [Grounded in LIGHT insight]
- **How**: [Specific approach]
- **Success looks like**: [Measurable outcome]

### Priority 2: [Action]
- **Why**: [Grounded in LIGHT insight]
- **How**: [Specific approach]
- **Success looks like**: [Measurable outcome]

---

## Short-term Direction (Next 5-10 Sessions)

### Investigation: [Topic]
- **Question**: [From LIGHT.md questions]
- **Approach**: [How to investigate]
- **Expected learning**: [What we hope to understand]

### Refinement: [Process/Tool]
- **Current state**: [Description]
- **Target state**: [Description]
- **Steps**: [Approach]

---

## Long-term Evolution (Framework Level)

### Consider Adding: [Capability]
- **Why**: [Pattern suggests need]
- **Complexity**: [LOW/MEDIUM/HIGH]
- **Priority**: [LOW/MEDIUM/HIGH]

### Consider Removing: [Element]
- **Why**: [Not providing value per data]
- **Risk**: [What might be lost]

### Consider Rethinking: [Approach]
- **Current**: [Description]
- **Alternative**: [Description]
- **Evidence needed**: [What would decide]

---

## Experiments to Run

Structured tests to increase understanding:

### Experiment 1: [Name]
- **Hypothesis**: [Statement]
- **Method**: [How to test]
- **Success criteria**: [Measurable]
- **Priority**: [HIGH/MEDIUM/LOW]

---

## Anti-Patterns to Avoid

Based on accumulated blindspots:

1. **Don't**: [Specific anti-pattern]
   **Instead**: [Alternative approach]

2. **Don't**: [Specific anti-pattern]
   **Instead**: [Alternative approach]

---

## Review Schedule

- [ ] Review LIGHT.md weekly
- [ ] Update PATH.md after each integration
- [ ] Full re-integration after 10 sessions
```

---

## Input Sources

What does the integrator read?

### Primary Sources
| Source | Content | Weight |
|--------|---------|--------|
| `feedback/entries.jsonl` | Structured feedback | HIGH |
| `insights/*.md` | Current patterns | HIGH |
| `learnings/**/*.md` | Task-specific | MEDIUM |
| `blindspots.md` | Known weaknesses | HIGH |

### Secondary Sources
| Source | Content | Weight |
|--------|---------|--------|
| Session transcripts | Raw session data | MEDIUM |
| Created/modified files | What was built | LOW |
| Error logs | What went wrong | MEDIUM |

### Derived Sources
| Source | Content | Weight |
|--------|---------|--------|
| Git history | Changes over time | LOW |
| Experiment results | Structured tests | HIGH |

---

## Processing Pipeline

### Phase 1: GATHER

```
1. List all sources
2. Filter by recency (if incremental)
3. Read content into working memory
4. Parse structured data (JSONL, frontmatter)
5. Extract text for analysis
```

### Phase 2: ANALYZE

```
1. PATTERN EXTRACTION
   - Frequency analysis: What appears repeatedly?
   - Co-occurrence: What appears together?
   - Temporal: What's increasing/decreasing?

2. THEME CLUSTERING
   - Group related patterns
   - Identify overarching themes
   - Name clusters meaningfully

3. CONTRADICTION DETECTION
   - Find patterns that conflict
   - Identify contextual boundaries
   - Flag for resolution

4. BLINDSPOT DETECTION
   - Find repeated failures
   - Identify systematic misses
   - Track blindspot evolution

5. CONFIDENCE SCORING
   - Based on: frequency, recency, consistency
   - HIGH: 5+ observations, consistent
   - MEDIUM: 2-4 observations, mostly consistent
   - LOW: 1 observation or inconsistent
```

### Phase 3: SYNTHESIZE

```
1. Generate LIGHT.md
   - Structure insights by confidence
   - Include evidence citations
   - Note questions and contradictions

2. Generate PATH.md
   - Derive actions from insights
   - Prioritize by impact and confidence
   - Include specific, testable steps

3. Update blindspots.md
   - Add new blindspots
   - Update existing ones
   - Remove resolved ones

4. Update *_patterns.md
   - Add confirmed patterns
   - Update pattern confidence
   - Archive deprecated patterns
```

### Phase 4: VALIDATE

```
1. GROUNDING CHECK
   - Every insight cites evidence
   - No hallucinated patterns
   - Confidence matches data

2. ACTIONABILITY CHECK
   - Every action is specific
   - Every action is testable
   - Priorities are justified

3. COHERENCE CHECK
   - LIGHT and PATH align
   - No internal contradictions
   - Narrative makes sense
```

---

## Integration with PP

### When to Run

| Trigger | Mode | Depth |
|---------|------|-------|
| Session start | Load | Light (read LIGHT.md, PATH.md) |
| Session end | Update | Medium (process new feedback) |
| On-demand `/pp-integrate` | Full | Deep (full re-analysis) |
| After N sessions | Scheduled | Deep (comprehensive) |
| After major task | Automatic | Medium |

### In PP Orchestrator Flow

```
PP SESSION START
       │
       ▼
┌──────────────┐
│ Load LIGHT   │  ← Quick: read current understanding
│ Load PATH    │  ← Quick: read current direction
└──────────────┘
       │
       ▼
[... normal PP work ...]
       │
       ▼
┌──────────────┐
│ Log feedback │  ← Normal: add to entries.jsonl
└──────────────┘
       │
       ▼
┌──────────────┐
│ Quick update │  ← Optional: lightweight integration
│ to LIGHT/PATH│
└──────────────┘
       │
       ▼
PP SESSION END
```

### Command Definition

```markdown
---
name: integrate
description: "Synthesize accumulated learnings into LIGHT (understanding) and PATH (direction)"
argument-hint: "[full|incremental|load] - depth of integration"
allowed-tools: [Read, Write, Glob, Grep]
model: opus
---

# Insight Integrator Command

/pp-integrate [mode]

Modes:
- `full` - Complete re-analysis of all sources
- `incremental` - Process only new content since last integration
- `load` - Just load current LIGHT and PATH (no processing)
```

---

## Technical Considerations

### Handling Scale

**Problem**: As sessions accumulate, data grows unbounded.

**Solutions**:
1. **Rolling window**: Only analyze last N sessions
2. **Compression**: Confirmed patterns replace raw data
3. **Archiving**: Old entries move to archive after integration
4. **Sampling**: For very large datasets, sample strategically

### Incremental Updates

**Problem**: Full re-analysis is expensive.

**Solution**: Track integration state:

```json
{
  "last_integration": "2025-01-22T12:00:00Z",
  "entries_processed": 47,
  "sources_hash": "abc123",
  "light_version": 3,
  "path_version": 5
}
```

Only process entries newer than `last_integration`.

### Avoiding Hallucinated Patterns

**Problem**: LLM might see patterns that don't exist.

**Solutions**:
1. **Require citations**: Every pattern must cite specific entries
2. **Minimum threshold**: Pattern needs N observations
3. **Recency weighting**: Recent observations count more
4. **Contradiction flagging**: Conflicting data = lower confidence

### Storage Strategy

```
purpose_prompter/
├── integration/
│   ├── LIGHT.md           # Current understanding
│   ├── PATH.md            # Current direction
│   ├── state.json         # Integration state
│   └── archive/
│       ├── LIGHT_v1.md    # Historical versions
│       └── LIGHT_v2.md
├── feedback/
│   └── entries.jsonl      # Raw feedback
├── insights/
│   └── *.md               # Pattern files
└── learnings/
    └── **/*.md            # Task learnings
```

---

## MVP Implementation

### Phase 1: Basic Integration

```
INPUT:
- feedback/entries.jsonl only

PROCESS:
- Count patterns by dimension
- Identify top 5 successes
- Identify top 5 failures
- Extract recurring themes

OUTPUT:
- Simple LIGHT.md (patterns + blindspots)
- Simple PATH.md (top priorities)
```

### Phase 2: Add Insights Sources

```
INPUT:
- feedback/entries.jsonl
- insights/*.md

PROCESS:
- Previous + cross-reference with existing insights
- Confirm or challenge existing patterns

OUTPUT:
- Enhanced LIGHT.md with confidence levels
- Enhanced PATH.md with investigations
```

### Phase 3: Full Integration

```
INPUT:
- All sources

PROCESS:
- Full analysis pipeline
- Temporal analysis
- Theme clustering
- Contradiction detection

OUTPUT:
- Comprehensive LIGHT.md
- Comprehensive PATH.md
- Updated all pattern files
```

---

## Connection to PP Philosophy

### TRUTH Dimension
- Grounded in actual data (citations required)
- No hallucinated patterns
- Honest about confidence levels

### UNDERSTANDING Dimension
- Creates genuine comprehension, not just summaries
- Answers WHY, not just WHAT
- Builds mental models

### BEAUTY Dimension
- Elegant output structure
- Clear, readable documents
- Right-sized (not overwhelming)

### JUSTICE Dimension
- Insights placed in appropriate files
- Priorities based on actual impact
- Fair weighting of evidence

### CREATIVITY Dimension
- May identify need for new structures
- Suggests framework evolution
- Builds new paths when needed

---

## The Name

Options considered:
- "Insight Integrator" - Descriptive
- "Wisdom Synthesizer" - Grand
- "Light & Path" - Evocative
- "Learning Compounder" - Functional

**Recommendation**: **"Light & Path"** or **"Insight Integrator"**

The command could be: `/pp-integrate` or `/light-path`

---

## Next Steps

1. [ ] Define feedback entry schema (if not exists)
2. [ ] Create MVP integrator command
3. [ ] Test on current feedback data
4. [ ] Iterate based on output quality
5. [ ] Add incremental mode
6. [ ] Add to PP orchestrator flow

---

## Open Questions

1. **How much context can we reasonably process?**
   - Need to test with real data volumes

2. **How to handle contradictions gracefully?**
   - Surface them? Resolve them? Flag for human?

3. **Should LIGHT/PATH be session-specific or global?**
   - Probably global, but could have session overlays

4. **How to measure integration quality?**
   - Are the insights actionable?
   - Do they improve future sessions?

5. **Who validates the synthesis?**
   - Automatic? Human review? Both?
