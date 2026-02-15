---
description: "Purpose Prompter orchestration - execute tasks through the T->U->B->J->X hierarchy"
argument-hint: "[task] - what to build, fix, or improve"
allowed-tools: [Read, Glob, Grep, Edit, Write, Bash, Task, WebFetch]
---

# /pp - Purpose Prompter

> TRUTH -> UNDERSTANDING -> BEAUTY -> JUSTICE -> CREATIVITY

Execute a task through the PP hierarchy: sense the landscape, comprehend the domain, build the path (if uncharted), execute with signal awareness, and assess the result.

## Task

PP_TASK = "$ARGUMENTS"

---

## Phase 0: LOAD CONTEXT (always, fast)

Before any agents, load cross-session knowledge from GUA:

```bash
# Run in Bash (< 5 seconds)
gua load 2>/dev/null || true
```

This populates `~/.claude/purpose_prompter/integration/LIGHT.md` with:
- **Blindspots** (CHECK THESE) - known failure patterns to watch for
- **Top patterns** - frequently accessed knowledge by dimension

Then read LIGHT.md to inject blindspot awareness into the session:
```
Read: ~/.claude/purpose_prompter/integration/LIGHT.md
```

Extract blindspots and pass them to agents. If `gua` is not available, skip silently.

Output: `[PP:CONTEXT] Loaded {N} patterns, {N} blindspots`

---

## Phase 1: SENSE (always)

Spawn one sense agent to assess territory, find patterns, and map impact.

```
Task(
  description = "PP Sense",
  subagent_type = "Explore",
  model = "sonnet",
  max_turns = 12,
  prompt = "You are the PP Sense agent.
    Your mission: assess territory (CHARTED/UNCHARTED), find existing patterns, and map impact.
    First read plugin/gates/GATES.md in the working directory for gate awareness.
    Then search the codebase to answer: What territory is this? What patterns exist? What files are affected?

    Task: {PP_TASK}
    Working directory: {WORKING_DIR}
    Blindspots: {BLINDSPOTS}

    Output a structured report with: TERRITORY, CONFIDENCE, RISK, PATTERNS (with file:line),
    IMPACT (files to modify/create), SUGGESTED_ORDER, KEY_INSIGHT, BLINDSPOT_CHECK,
    OWNERSHIP_MAP (which component/module owns each affected area, flag potential conflicts),
    and COVERAGE (what you analyzed vs what remains unexplored)."
)
```

After sense returns, extract:
- `territory`: CHARTED or UNCHARTED
- `risk`: LOW, MEDIUM, or HIGH
- `patterns`: primary template and conventions
- `impact`: files affected, suggested order

Output: `[PP:SENSE] Territory={territory} Risk={risk} Impact={N} files`

**Decision:**
- CHARTED + LOW -> Skip to Phase 4 (Execute)
- CHARTED + MEDIUM/HIGH -> Phase 2 (Comprehend), then Phase 4
- UNCHARTED -> Phase 2, then Phase 3 (Build), then Phase 4

---

## Phase 2: COMPREHEND (conditional)

When risk >= MEDIUM or territory == UNCHARTED.

```
Task(
  description = "PP Comprehend",
  subagent_type = "general-purpose",
  model = "sonnet",
  max_turns = 20,
  prompt = "You are the PP Comprehend agent.
    Your mission: fill the gaps in sense's analysis with deep understanding.
    First: Read the sense report. Identify what sense discovered, what it left unexplored
    (noted in COVERAGE), and what questions remain unanswered.
    Then: Read plugin/gates/GATES.md for gate awareness.
    Then: Read ONLY the files needed to answer those questions. Trace data flow where sense didn't.
    Build a mental model that COMPLETES sense's picture, not duplicates it.

    Task: {PP_TASK}
    Working directory: {WORKING_DIR}
    Sense report: {SENSE_REPORT}

    Output: GAP_ANALYSIS (what sense missed/left open), MENTAL_MODEL (how it works — new insights only),
    KEY_DECISIONS (why, with file:line), INTEGRATION_POINTS (where new code connects),
    OWNERSHIP_CONFLICTS (from sense OWNERSHIP_MAP — any contested areas?), RISKS, RECOMMENDATIONS."
)
```

Output: `[PP:COMPREHEND] Mental model built. {N} integration points, {N} risks.`

---

## Phase 3: BUILD (uncharted only)

When territory == UNCHARTED.

```
Task(
  description = "PP Build",
  subagent_type = "general-purpose",
  model = "opus",
  max_turns = 20,
  prompt = "You are the PP Build agent.
    Your mission: scaffold new structure for uncharted territory.
    First read plugin/gates/GATES.md. Then prove territory is genuinely uncharted (search for
    near-misses, explain why extension doesn't work). Design and create the structural files.

    Task: {PP_TASK}
    Working directory: {WORKING_DIR}
    Sense report: {SENSE_REPORT}
    Comprehend report: {COMPREHEND_REPORT}

    Output: VERIFICATION (search evidence), DESIGN (new structure), VISION (direction),
    BUILD_REPORT (what was scaffolded)."
)
```

Output: `[PP:BUILD] Path scaffolded. {N} files created.`

---

## Phase 4: EXECUTE (main context)

Execute the task directly, following:
1. Patterns from sense agent
2. Integration points from comprehend agent (if run)
3. Scaffolding from build agent (if run)

**The 5 Execution Laws** (mandatory):
1. No edit without read
2. No claim without citation (file:line)
3. No pattern without source (cite where it exists)
4. No placement without evidence (justify why here, why not elsewhere)
5. No completion without verification

**Output markers:**
```
[PP:EXECUTE] Modifying {file}...
[PP:PATTERN] Following {source file:line}
[PP:PLACEMENT] {file} justified: {evidence}
[PP:SIGNAL] {clean | warning: details}
```

**Signal response:**
- Ugliness -> Stop, understand problem deeper
- Injustice -> Stop, survey better locations
- Stagnation -> Stop, reassess territory

Track: files_modified, files_created, signals_encountered.

---

## Phase 5: ASSESS

**CHARTED + LOW risk** - inline verify, no agent:
```
[PP:VERIFY:INLINE] Truth: grounded? Beauty: fits pattern? Justice: right place? -> PASS/FAIL
```

**Otherwise** - spawn assess agent:
```
Task(
  description = "PP Assess",
  subagent_type = "Explore",
  model = "sonnet" (charted) / "opus" (uncharted),
  max_turns = 20,
  prompt = "You are the PP Assess agent.
    Your mission: evaluate completed work against all applicable gates.
    Read plugin/gates/GATES.md for gate definitions. Read every modified file.
    Evaluate each dimension (T, U, B, J, and X if uncharted).

    Task: {PP_TASK}
    Territory: {TERRITORY}
    Files modified: {FILES_MODIFIED}
    Files created: {FILES_CREATED}
    Working directory: {WORKING_DIR}

    Output per-dimension PASS/PARTIAL/FAIL with per-gate detail, signals detected,
    OVERALL verdict, and specific recommendations for any failures."
)
```

After assess returns:
- COMPLETE -> Phase 6
- PARTIAL -> Present recommendations, ask: accept or rework?
- FAILED -> Rework, re-assess failed dimensions

Output: `[PP:ASSESS] {COMPLETE|PARTIAL|FAILED}`

---

## Phase 6: COMPLETE

```
[PP:COMPLETE] {PP_TASK}

Territory: {CHARTED|UNCHARTED}
Risk: {LOW|MEDIUM|HIGH}
Verification: {COMPLETE|PARTIAL}
Signals: {None | list}
[PP:MASTERY] L{N} {Level Name} ({leading dimension} leading at L{N})
```

Extract mastery level from the assess agent's MASTERY section (if assess ran), or estimate from inline verification.

**Mastery auto-update**: If the assess agent returned MASTERY data, write it to `.gua/mastery.json`:
```bash
# Only if assess returned mastery data — construct JSON from assess output
# Fields: overall, dimensions (per-dim level + marker), crystallization, next_threshold
# Read existing file to preserve history array, then merge new assessment
# Skip if no assess agent ran (CHARTED+LOW inline verify)
```

**Reflection capture**: Construct a structured reflection from accumulated phase data and append to `.gua/reflections/log.jsonl`:

```bash
mkdir -p .gua/reflections
```

Reflection JSON (one line, appended):
```json
{
  "id": "refl-<uuid>",
  "timestamp": "ISO8601",
  "task": "PP_TASK description",
  "territory": "CHARTED|UNCHARTED",
  "risk": "LOW|MEDIUM|HIGH",
  "flow": "sense -> comprehend -> execute -> assess",
  "assessment": {
    "overall": "COMPLETE|PARTIAL|FAILED",
    "truth": "PASS|PARTIAL|FAIL",
    "understanding": "PASS|PARTIAL|FAIL",
    "beauty": "PASS|PARTIAL|FAIL",
    "justice": "PASS|PARTIAL|FAIL",
    "creativity": "PASS|PARTIAL|FAIL|N/A",
    "failed_gates": ["B4", "T1"],
    "signals": ["ugliness: description"]
  },
  "virtues": {
    "observed": ["discipline: thorough citations"],
    "tensions": ["courage-deficiency: avoided refactoring"]
  },
  "mastery_level": "L2",
  "key_insight": "one-line takeaway or null",
  "improvement_for_pp": "self-improvement suggestion or null"
}
```

Build the reflection from:
- Task, territory, risk from `[PP:STATE]`
- Flow from which phases actually ran
- Assessment from assess agent output (or inline verify)
- Virtues from assess agent's VIRTUE OBSERVATIONS section
- Key insight: most important thing learned (or null)
- improvement_for_pp: any observation about PP itself (or null)

Write as single-line JSON, one per run. Use Bash to append:
```bash
echo '{...}' >> .gua/reflections/log.jsonl
```

Output: `[PP:REFLECT] Reflection #{N} captured`

**Centralized PP improvement** (cross-project alchemy fuel):
If `improvement_for_pp` is not null, also append a slim record to the global location:
```bash
mkdir -p ~/.gua/reflections
echo '{"timestamp":"...","project":"$(basename $(pwd))","task":"...","improvement_for_pp":"...","failed_gates":[...],"signals":[...],"virtue_tensions":[...]}' >> ~/.gua/reflections/pp-improvements.jsonl
```
This feeds `gua distill` across all projects. Project-local `log.jsonl` remains complete for per-project `gua reflect`.

Output: `[PP:REFLECT:GLOBAL] PP improvement captured to ~/.gua/reflections/pp-improvements.jsonl`

**Athanor detection** (read-only, creation is `gua distill`'s job):
If `improvement_for_pp` is not null in the reflection:
1. Check `~/.gua/athanor/*.json` for candidates whose `prima_materia.improvement_suggestions` overlap with this improvement (keyword match).
2. If match found: `[PP:ATHANOR] Heat added to {candidate_id}` — note only, `gua distill` handles the actual update.
3. If no match but 3+ similar `improvement_for_pp` entries in recent reflections: `[PP:ATHANOR] Emerging theme detected — run gua distill`.
4. Add `"transmutation_candidate": "{id or null}"` to the reflection JSON above.

**GUA capture** (if signals or insights arose during execution):
```bash
# Capture any signals that fired as knowledge
gua add "Signal: {description}" {dimension} observation 2>/dev/null || true

# Save state for next session
gua save 2>/dev/null || true
```

---

## State (compaction-safe)

```
[PP:STATE] task="{task}" territory={t} risk={r} phase={p} files=[{list}] reflections={count}
```

---

## Graceful Degradation

If Task tool fails:
- Fall back to inline execution without agents
- Read gates/GATES.md directly, apply as inline checks
- `[PP:DEGRADED] Running without agents`

## When NOT to PP

Skip: simple questions, trivial fixes, "quick"/"fast"/"no pp".
Use: code changes, architecture, multi-file, quality matters.
Test: if it touches code and takes >30 seconds, use PP.
