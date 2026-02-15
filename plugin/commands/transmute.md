---
description: "Transmute accumulated reflections into new PP modules via the Alchemical Ritual"
argument-hint: "[candidate|scan] - candidate ID or 'scan' to detect candidates"
allowed-tools: [Read, Glob, Grep, Edit, Write, Bash, Task, WebFetch]
---

# /transmute - Alchemical Ritual

> NIGREDO → ALBEDO → CITRINITAS → RUBEDO

Transmute accumulated evidence of structural gaps into new PP modules. Each stage maps to a PP dimension and reuses existing agents.

## Task

TRANSMUTE_ARG = "$ARGUMENTS"

---

## Phase 0: LOAD ATHANOR

Load cross-session knowledge and athanor state:

```bash
gua load 2>/dev/null || true
```

Read LIGHT.md for context:
```
Read: ~/.claude/purpose_prompter/integration/LIGHT.md
```

Scan athanor for candidates (global — shared across all projects):
```bash
ls ~/.gua/athanor/*.json 2>/dev/null || echo "EMPTY"
```

Read all candidate JSON files found.

**If TRANSMUTE_ARG == "scan":**
Run `gua distill`, report athanor state, and exit:
```bash
gua distill
```
Output: `[TRANSMUTE:SCAN] {N} candidates in athanor. {N} ready for transmutation.`
Exit here.

**If TRANSMUTE_ARG is a candidate ID:**
Load that specific candidate. Verify it exists. Determine current stage.

**If TRANSMUTE_ARG is empty:**
List candidates sorted by heat, suggest the highest-heat candidate that meets threshold, exit.

Output: `[TRANSMUTE:STATE] candidate={id} stage={current} heat={h}`

Resume from the candidate's current stage (skip completed stages).

---

## Phase 1: NIGREDO (Dissolution → Truth)

*Is the pain real and structural?*

Spawn sense agent to validate evidence:

```
Task(
  description = "Transmute Nigredo",
  subagent_type = "Explore",
  model = "sonnet",
  max_turns = 12,
  prompt = "You are validating a transmutation candidate through NIGREDO (Truth).
    First read plugin/gates/ALCHEMY.md and plugin/gates/GATES.md.
    Then read the candidate file and all referenced reflection entries.

    Candidate: {CANDIDATE_JSON}
    Reflections file: .gua/reflections/log.jsonl

    Evaluate:
    1. T1 (Grounding): Is the evidence real? Are the referenced reflections actual PP runs?
    2. T4 (Completeness): Is the evidence persistent across sessions, not a one-off?
    3. Structural: Could this be fixed by tuning (adjusting blindspots, adding knowledge)?
       Or does it require NEW structure that doesn't exist?

    Output exactly one verdict:
    - ADVANCE_TO_ALBEDO: Evidence is real, persistent, and structural. Include: theme summary,
      evidence count, structural gap description.
    - NEEDS_MORE_EVIDENCE: Real but insufficient. Include: what's missing, current heat vs threshold.
    - DISSOLVE: Not structural, fixable by tuning. Include: recommended tuning action."
)
```

**On ADVANCE_TO_ALBEDO**: Update candidate JSON:
- Set `stage` to `ALBEDO`
- Populate `nigredo` field with theme, evidence_count, first_seen, structural_gap
- Append to `history`

**On NEEDS_MORE_EVIDENCE**: Report status, no stage change.

**On DISSOLVE**: Update candidate `stage` to `DISSOLVED`, append to history. Suggest tuning action.

Output: `[TRANSMUTE:NIGREDO] {verdict} for {candidate_id}`

---

## Phase 2: ALBEDO (Purification → Understanding)

*What exactly is missing?*

Requires candidate at ALBEDO stage with heat >= 5.

```
Task(
  description = "Transmute Albedo",
  subagent_type = "general-purpose",
  model = "sonnet",
  max_turns = 20,
  prompt = "You are crystallizing a transmutation candidate through ALBEDO (Understanding).
    First read plugin/gates/ALCHEMY.md and plugin/gates/GATES.md.
    Then read the full plugin structure to understand what exists:
    - plugin/commands/*.md (all commands)
    - plugin/agents/*.md (all agents)
    - plugin/gates/*.md (all references)
    - gua/cli/gua-v3.sh (GUA functions)

    Candidate: {CANDIDATE_JSON}
    NIGREDO result: {NIGREDO_DATA}

    Evaluate:
    1. U1 (Mental Model): What exactly is missing? Build a model of the gap.
    2. U2 (Why): Why can't existing modules handle this? Cite specific file:line showing limits.
    3. U5 (Boundaries): What is the boundary of the new module? What it SHOULD and SHOULD NOT do.
    4. Module type: command | gua_function | gate_reference

    Output exactly one verdict:
    - ADVANCE_TO_CITRINITAS: Gap crystallized. Include: gap description, module type,
      integration points, why existing modules fail (with citations).
    - RECLASSIFY_AS_TUNING: On closer inspection, existing modules can handle it.
      Include: which module, what adjustment needed."
)
```

**On ADVANCE_TO_CITRINITAS**: Update candidate:
- Set `stage` to `CITRINITAS`
- Populate `albedo` field with gap_description, module_type, integration_points, existing_limits
- Append to `history`

**On RECLASSIFY_AS_TUNING**: Set stage to `DISSOLVED`, record the tuning recommendation.

Output: `[TRANSMUTE:ALBEDO] {verdict} for {candidate_id}`

---

## Phase 3: CITRINITAS (Awakening → Beauty + Justice)

*Design the module. Find its form and place.*

Requires candidate at CITRINITAS stage with heat >= 7.

```
Task(
  description = "Transmute Citrinitas",
  subagent_type = "general-purpose",
  model = "opus",
  max_turns = 20,
  prompt = "You are designing a new PP module through CITRINITAS (Beauty + Justice).
    First read plugin/gates/ALCHEMY.md and plugin/gates/GATES.md.
    Then read all existing files of the same type as the proposed module.

    Candidate: {CANDIDATE_JSON}
    ALBEDO result: {ALBEDO_DATA}

    Design requirements:
    1. X1 (Territory): Verify this is genuinely uncharted — search for near-misses.
    2. B4 (Elegance): Nothing extra, nothing missing. Minimal viable module.
    3. J1 (Placement): Right location in the plugin/GUA structure.
    4. X7 (Integration): How does it connect to existing modules?
    5. Philosopher's Stone: How will this module generate its own reflections?

    Output a DESIGN SPEC containing:
    - Files to create/modify (with paths)
    - Content outline for each file (structure, not full code)
    - Integration points (what existing code connects to this)
    - Reflection mechanism (how it feeds back into the loop)
    - ADVANCE_TO_RUBEDO verdict with the design spec"
)
```

**CRITICAL: Present design to user and request explicit approval before proceeding to RUBEDO.**

Update candidate:
- Set `stage` to `RUBEDO` (after approval)
- Populate `citrinitas` field with design_spec, files, integration_points, reflection_mechanism
- Append to `history`

Output: `[TRANSMUTE:CITRINITAS] Design complete for {candidate_id}. Awaiting approval.`

---

## Phase 4: RUBEDO (Completion → Creativity)

*Create, integrate, verify.*

Requires user approval from CITRINITAS. Execute in main context.

**Step 1: Create** — Using the CITRINITAS design spec, create all files and modifications. Follow the 5 Execution Laws. Use `[PP:EXECUTE]`, `[PP:PATTERN]`, `[PP:PLACEMENT]` markers.

**Step 2: Assess** — Spawn assess agent to verify:

```
Task(
  description = "Transmute Rubedo Assess",
  subagent_type = "Explore",
  model = "opus",
  max_turns = 20,
  prompt = "You are assessing a transmuted module through RUBEDO (Creativity assessment).
    First read plugin/gates/ALCHEMY.md and plugin/gates/GATES.md.
    Then read all files created/modified by this transmutation.

    Candidate: {CANDIDATE_JSON}
    Files created: {FILES_CREATED}
    Files modified: {FILES_MODIFIED}

    Evaluate full Creativity gates (X1-X7):
    - X1 Territory: Genuinely uncharted?
    - X2 Pioneering: Original approach?
    - X3 Path-Building: Others can follow?
    - X4 Extension: Coherent with existing?
    - X5 Vision: Clear direction?
    - X6 Foundation: Enables future?
    - X7 Integration: Connected to whole?

    Also evaluate the Philosopher's Stone test:
    - Does this module integrate into the PP execution flow?
    - Can its outputs feed back into reflections?
    - Will future gua distill runs detect patterns from its usage?

    Output: Per-gate PASS/FAIL, Philosopher's Stone PASS/FAIL, OVERALL verdict,
    and specific recommendations."
)
```

**On COMPLETE**: Update candidate:
- Set `stage` to `INTEGRATED`
- Populate `rubedo` field with assessment_result, philosopher_stone, files_created, files_modified
- Append to `history`

**On INCOMPLETE**: Keep stage at `RUBEDO`, record what needs fixing.

Output: `[TRANSMUTE:RUBEDO] {INTEGRATED|INCOMPLETE} for {candidate_id}`

---

## Phase 5: COMPLETE

```
[TRANSMUTE:COMPLETE] {candidate_title}

Stage: INTEGRATED
Heat: {final}
Module type: {type}
Files: {list}
Philosopher's Stone: {PASS|FAIL}
[TRANSMUTE:STATE] candidate={id} stage=INTEGRATED heat={h}
```

**Reflection capture**: Construct reflection JSON and append to `.gua/reflections/log.jsonl`:

```bash
mkdir -p .gua/reflections
```

The reflection should record:
- Task: "Transmutation: {candidate_title}"
- Territory: UNCHARTED
- Assessment from RUBEDO assess agent
- `improvement_for_pp`: observations about the transmutation process itself

**GUA capture**:
```bash
gua add "Transmuted: {candidate_title} -> {module_type}" creativity observation 2>/dev/null || true
gua save 2>/dev/null || true
```

---

## State (compaction-safe)

```
[TRANSMUTE:STATE] candidate={id} stage={s} heat={h}
```

---

## Graceful Degradation

If Task tool fails, fall back to inline execution:
- Read ALCHEMY.md and GATES.md directly
- Evaluate criteria manually in main context
- `[TRANSMUTE:DEGRADED] Running without agents`
