# Alchemy: Structural Creation from Accumulated Understanding

> When tuning isn't enough, new structure must be born.

The Alchemical Ritual detects structural gaps from accumulated reflections, matures them in the Athanor, and transmutes them into new modules via `/transmute`.

## The Extended Loop

```
reflect → persist → digest → DISTILL → inject → act → reflect
                               ↓ (when ready)
                           TRANSMUTE → new module → (generates own reflections)
```

## The Four Stages

| Stage | Alchemical | PP Dimension | Agent | Purpose |
|-------|-----------|-------------|-------|---------|
| **NIGREDO** | Dissolution | TRUTH | sense (sonnet, Explore, 12 turns) | Validate the pain is real and structural |
| **ALBEDO** | Purification | UNDERSTANDING | comprehend (sonnet, general-purpose, 20 turns) | Crystallize what exactly is missing |
| **CITRINITAS** | Awakening | BEAUTY + JUSTICE | build (opus, general-purpose, 20 turns) | Design the module, find its form and place |
| **RUBEDO** | Completion | CREATIVITY | execute + assess (opus, Explore, 20 turns) | Create, integrate, verify |

## The Athanor

The Athanor (`~/.gua/athanor/`) is the global furnace where transmutation candidates mature across all projects. Each candidate accumulates **heat** — evidence pressure from recurring reflections.

**Global by design**: PP improvements from any project feed into `~/.gua/reflections/pp-improvements.jsonl`. The athanor is shared because PP self-improvement is universal, not project-specific.

**Heat thresholds** (Patience made operational):
- **NIGREDO → ALBEDO**: heat >= 5 (evidence must accumulate)
- **ALBEDO → CITRINITAS**: heat >= 7 (need must crystallize)
- All stage transitions require `/transmute` (user-triggered, never automatic)
- **Heat decay**: -1 per idle month (prevents stale candidates from blocking the athanor)

Heat prevents rashness. You can't transmute on a bad day.

**Why 5 and 7?**
- **5** (NIGREDO → ALBEDO): 3 creates a cluster, 5 proves persistence across sessions. Statistical confidence that the pain is real.
- **7** (ALBEDO → CITRINITAS): Evidence must accumulate beyond initial detection to warrant structural creation. Design maturity threshold.
- These operationalize Patience — no transmutation from a single frustration spike.

## Transmutation Criteria

Each stage maps to existing PP gates:

| Stage | Required Gates | What They Verify |
|-------|---------------|-----------------|
| NIGREDO | T1 (Grounding), T4 (Completeness) | Evidence is real, persistent across sessions |
| ALBEDO | U1 (Mental Model), U2 (Why), U5 (Boundaries) | Gap is understood, existing modules can't handle it |
| CITRINITAS | B4 (Elegance), J1 (Placement), X1 (Territory), X7 (Integration) | Design is minimal, placed right, genuinely uncharted, connected |
| RUBEDO | X1-X7 (full Creativity) + Philosopher's Stone | Creation is complete, integrated, self-sustaining |

## Module Types

A transmutation can produce:

| Type | Description | Example |
|------|------------|---------|
| `command` | New `/command` in plugin/commands/ | `/transmute` itself was the first |
| `gua_function` | New `cmd_*()` in gua-v3.sh | `gua distill` |
| `gate_reference` | New reference doc in plugin/gates/ | This file |

## The Philosopher's Stone Test

A transmuted module must generate its own reflections. This means:
1. It integrates into the PP execution flow
2. Its outputs feed back into `.gua/reflections/log.jsonl`
3. Future `gua distill` runs can detect patterns from its usage

If a module cannot be reflected upon, it is inert — not truly transmuted.

## Candidate Schema

Candidates live in `.gua/athanor/<id>.json`:

```json
{
  "id": "athanor-<uuid8>",
  "name": "descriptive-slug",
  "title": "Human-Readable Need Statement",
  "stage": "NIGREDO|ALBEDO|CITRINITAS|RUBEDO|INTEGRATED|DISSOLVED",
  "heat": 3,
  "created_at": "ISO8601",
  "updated_at": "ISO8601",
  "prima_materia": {
    "reflections": ["refl-abc"],
    "improvement_suggestions": ["..."],
    "failed_gates": {"B4": 5},
    "signals": {"ugliness": 4},
    "virtue_tensions": {"temperance-deficiency": 3},
    "evidence_summary": {"theme": "...", "cluster_size": 3, "first_seen": "ISO8601"}
  },
  "nigredo": null,
  "albedo": null,
  "citrinitas": null,
  "rubedo": null,
  "history": [{"stage": "NIGREDO", "date": "2026-02-15", "note": "..."}]
}
```

## Stage Labels (for LIGHT.md)

| Stage | Label | Meaning |
|-------|-------|---------|
| NIGREDO | `[RAW]` | Evidence collected, not yet validated |
| ALBEDO | `[PURE]` | Need crystallized, gap confirmed |
| CITRINITAS | `[GOLD]` | Design complete, awaiting creation |
| RUBEDO | `[STONE]` | Created and integrated |
| INTEGRATED | `[LIVE]` | Active, generating reflections |
| DISSOLVED | `[TUNED]` | ALBEDO reclassified as tuning — applied via prompt/config changes, no new module needed |

## Dissolution (DISSOLVED)

Not every candidate reaches RUBEDO. ALBEDO may reveal the gap is real but solvable by **tuning** — prompt modifications, configuration changes, or parameter adjustments — rather than structural creation. This is a valid and common outcome.

When ALBEDO reclassifies a candidate as TUNING:
1. Apply the tuning directly (no CITRINITAS/RUBEDO needed)
2. Set candidate stage to DISSOLVED with albedo.classification = "TUNING"
3. Capture a reflection documenting what was tuned and why

DISSOLVED is not failure — it is the alchemy working correctly. NIGREDO dissolved assumptions, ALBEDO crystallized the true nature of the gap, and the system self-corrected before over-engineering.

## Bootstrap Path

The alchemy system requires seed reflections to operate.

1. Run `/pp` on 3-5 varied tasks to generate reflections with `improvement_for_pp` suggestions
2. Run `gua distill` to cluster suggestions into athanor candidates
3. Run `/transmute scan` to verify candidates were created
4. When a candidate reaches heat threshold, run `/transmute [candidate-id]`

The Philosopher's Recursion: The alchemy system itself may be the first transmutation target — PP improving PP.

## Virtues in Alchemy

- **Patience**: Heat thresholds prevent premature transmutation
- **Humility**: NIGREDO dissolves assumptions before building
- **Courage**: RUBEDO commits to creation
- **Temperance**: B4 (Elegance) ensures nothing extra, nothing missing
- **Wisdom**: The Philosopher's Stone test — true creation sustains itself
