# Integrated Workflow: PP + GUA + CPT

> **Version**: 1.0
> **Created**: 2026-01-27
> **Purpose**: Document the integrated session workflow across Purpose Prompter, GUA, and CPT

---

## The Three Systems

| System | Purpose | What It Tracks |
|--------|---------|----------------|
| **PP** (Purpose Prompter) | Methodology framework | Quality gates, signals, verification |
| **GUA** (Global Understanding Archive) | Cross-session knowledge | Patterns, blindspots, insights, research |
| **CPT** (Code Progress Tracker) | Code-specific progress | Areas, understanding depth, challenges |

---

## Session Workflow

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         INTEGRATED SESSION FLOW                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  SESSION START                                                               │
│  ─────────────                                                               │
│  1. gua load                    → Loads LIGHT.md (patterns + blindspots)    │
│                                 → Shows CPT summary (areas, challenges)      │
│                                                                              │
│  2. /gua-context                → Injects full context:                     │
│                                   • Active blindspots to check              │
│                                   • Top patterns to apply                   │
│                                   • Code progress summary                   │
│                                   • Active challenges                       │
│                                                                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  DURING WORK                                                                 │
│  ───────────                                                                 │
│                                                                              │
│  PP Gates Apply Automatically:                                               │
│  ┌─────────────────────────────────────────────────────────────────┐        │
│  │ TRUTH → UNDERSTANDING → BEAUTY → JUSTICE → CREATIVITY           │        │
│  └─────────────────────────────────────────────────────────────────┘        │
│                                                                              │
│  When PP Detects Signal:                                                     │
│  ┌─────────────────────────────────────────────────────────────────┐        │
│  │ UGLINESS detected      → /cpt-challenge (confusion category)    │        │
│  │ INJUSTICE detected     → /cpt-challenge (wrong_place category)  │        │
│  │ STAGNATION detected    → /cpt-challenge (dead_end category)     │        │
│  └─────────────────────────────────────────────────────────────────┘        │
│                                                                              │
│  When Learning Something:                                                    │
│  • /gua-insight <observation>   → Capture to GUA                            │
│                                                                              │
│  When Making Progress:                                                       │
│  • gua area update <id> --impl X --depth LY                                 │
│                                                                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  SESSION END                                                                 │
│  ───────────                                                                 │
│  1. Resolve challenges:                                                      │
│     gua challenge resolve <id> <resolution> --learning <insight>            │
│                                                                              │
│  2. Promote valuable learnings:                                              │
│     gua challenge promote <id>  → Creates GUA insight from challenge        │
│                                                                              │
│  3. Save to AWS:                                                             │
│     gua save                    → Persists all changes                      │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Signal → Challenge → Insight Flow

This is the core integration between PP, CPT, and GUA:

```
PP SIGNAL                    CPT CHALLENGE                   GUA INSIGHT
─────────                    ─────────────                   ───────────

Ugliness detected    →→→     /cpt-challenge
  (doesn't fit)              Category: confusion
  (feels hacky)              PP Dimension: UNDERSTANDING
                                    │
                                    ▼
                             Challenge logged
                             (tracked in DynamoDB)
                                    │
                                    ▼
                             Work continues...
                             Challenge resolved
                                    │
                                    ▼
                             gua challenge resolve
                             --learning "What I learned"
                                    │
                                    ▼
                             gua challenge promote    →→→   Insight created
                                                            in gua-knowledge-index
                                                                   │
                                                                   ▼
                                                            Next gua load
                                                            includes insight
                                                            in LIGHT.md
```

---

## Challenge → PP Dimension Mapping

When logging a challenge, the category maps to a PP dimension for root cause analysis:

| Challenge Category | PP Dimension | Root Cause Question | Signal Type |
|--------------------|--------------|---------------------|-------------|
| `bug` | TRUTH | "What did I assume that was wrong?" | False assumption |
| `confusion` | UNDERSTANDING | "What don't I understand?" | Incomplete mental model |
| `ugly_hack` | BEAUTY | "Why doesn't this solution fit?" | Forced solution |
| `wrong_place` | JUSTICE | "Where should this actually live?" | Misplaced code |
| `dead_end` | CREATIVITY | "What new structure is needed?" | Missing path |

---

## Understanding Depth Progression

CPT tracks Claude's understanding of code areas:

```
L0 (Unread)     →  L1 (Surveyed)   →  L2 (Understood)  →  L3 (Deep)    →  L4 (Expert)
Never looked       Listed files,       Read main files,     Resolved         Made significant
at this code       read README         traced calls         challenges,      changes
                                                            found edge       successfully
                                                            cases

Triggers:
• Initial state    • gua area add      • Read code          • Resolve        • Major refactor
                   • /cpt-area add       thoroughly           challenge        succeeds
                                       • /cpt-area update     in area
                                         --depth L2         • Auto-bump
```

---

## Quick Commands Reference

### Session Start
```bash
gua load                    # Load patterns + CPT summary
/gua-context                # Inject full context
/gua-context progress       # CPT progress only
```

### During Work
```bash
/cpt-challenge <desc>       # Log a challenge
/gua-insight <observation>  # Capture an insight
gua area update <id> --impl X --depth LY
```

### Session End
```bash
gua challenge resolve <id> <resolution> --learning <insight>
gua challenge promote <id>  # Promote to GUA insight
gua save                    # Persist to AWS
```

### Queries
```bash
/gua-context full           # Complete context
/gua-context dimension:X    # PP dimension patterns
/gua-context search:query   # Search knowledge
gua progress                # CPT dashboard
gua area status             # All tracked areas
gua challenge list          # Active challenges
```

---

## Integration Points Summary

| From | To | Integration |
|------|----|-------------|
| PP signals | CPT challenges | Signal type → challenge category |
| CPT challenges | GUA insights | Promote resolved challenges |
| GUA patterns | PP work | Patterns inform gate checks |
| CPT progress | GUA load | Progress shown at session start |
| PP dimensions | Both | Unified vocabulary across systems |

---

## The Integration Promise

When using all three systems together:

1. **Every session starts informed** - GUA patterns + CPT progress loaded
2. **Every signal is actionable** - PP dimension → challenge category → root cause
3. **Every learning persists** - Challenges → insights → patterns → LIGHT.md
4. **Every area is tracked** - Understanding depth + implementation progress
5. **Every session builds on the last** - Cross-session continuity via AWS

---

## Files Reference

| System | Key Files |
|--------|-----------|
| PP | `~/.claude/CLAUDE.md`, `~/Desktop/purpose_prompter/ACTIVATE.md` |
| GUA | `~/.gua/gua.sh`, `~/.claude/purpose_prompter/integration/LIGHT.md` |
| CPT | `gua/commands/cpt-*.md`, stored in `gua-knowledge-index` |

---

## Version History

- **1.0** (2026-01-27): Initial integrated workflow documentation
