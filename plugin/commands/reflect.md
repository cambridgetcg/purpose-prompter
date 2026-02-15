---
description: "PP self-reflection — examine behavioral patterns and generate improvement suggestions from introspection"
argument-hint: "[deep] - optional 'deep' for comprehend phase, default is sense-only"
allowed-tools: [Read, Glob, Grep, Bash, Task]
---

# /reflect - The Ouroboros

> PP examines itself. Not as a byproduct of work, but as the subject.

Self-reflection generates improvement suggestions from accumulated evidence — fuel for the athanor without waiting for external tasks to accidentally trigger observations.

## Mode

REFLECT_MODE = "$ARGUMENTS"

If REFLECT_MODE contains "deep": run both sense + comprehend (2 agents).
Otherwise: sense-only (1 agent, faster).

---

## Phase 0: GATHER EVIDENCE

Collect all available self-knowledge. Read these files:

```bash
# Global PP improvements (cross-project)
wc -l ~/.gua/reflections/pp-improvements.jsonl 2>/dev/null || echo "0"
```

```
Read: ~/.gua/reflections/pp-improvements.jsonl (if exists)
Read: ~/.claude/purpose_prompter/integration/LIGHT.md (if exists)
```

```bash
# Project-local reflections
wc -l .gua/reflections/log.jsonl 2>/dev/null || echo "0"
```

```
Read: .gua/reflections/log.jsonl (if exists)
Read: .gua/mastery.json (if exists)
```

**Minimum threshold**: At least 3 reflections must exist (project-local + any other projects). If fewer than 3, output:
```
[REFLECT:INSUFFICIENT] Only {N} reflections found. Run /pp on more tasks to generate evidence.
Self-reflection requires substance to reflect upon.
```
Exit.

Compute summary statistics before spawning agents:
```bash
# Quick stats via python one-liner
python3 -c "
import json, sys
lines = [json.loads(l) for l in open(sys.argv[1]) if l.strip()]
n = len(lines)
projects = set(r.get('project','?') for r in lines)
print(f'IMPROVEMENTS: {n} across {len(projects)} projects: {projects}')
" ~/.gua/reflections/pp-improvements.jsonl 2>/dev/null || true
```

Output: `[REFLECT:EVIDENCE] {N} reflections, {N} improvements, {N} projects`

---

## Phase 1: SENSE (introspection)

What patterns exist in HOW PP works?

```
Task(
  description = "PP Self-Reflect Sense",
  subagent_type = "Explore",
  model = "sonnet",
  max_turns = 12,
  prompt = "You are PP examining itself. This is self-reflection, not task execution.

    Your mission: find patterns in PP's own behavioral data.

    Read these files for evidence:
    1. ~/.gua/reflections/pp-improvements.jsonl (cross-project improvement suggestions)
    2. {PROJECT_DIR}/.gua/reflections/log.jsonl (full reflections from this project)
    3. ~/.claude/purpose_prompter/integration/LIGHT.md (current knowledge state)
    4. {PROJECT_DIR}/.gua/mastery.json (current mastery level)

    Then read PP's own source to compare intention vs behavior:
    5. {PP_DIR}/plugin/commands/pp.md (the orchestration flow)
    6. {PP_DIR}/plugin/gates/GATES.md (the gate definitions)

    Analyze:
    A. BEHAVIORAL PATTERNS — What does PP consistently do well/poorly?
       - Which gates fail most often? Is there a pattern in WHEN they fail?
       - Which virtue tensions recur? What triggers them?
       - Do certain territory/risk combinations produce worse outcomes?

    B. AGENT EFFICIENCY — How well do the agents serve the hierarchy?
       - Do any agents overlap in their analysis?
       - Are turn budgets right-sized?
       - Do agents focus on what they should per their role?

    C. BLIND SPOTS — What is PP NOT seeing?
       - What kinds of tasks never generate improvement suggestions?
       - Are there gate dimensions that are never failed (suspiciously)?
       - Is mastery assessment accurate or inflated?

    D. STRUCTURAL GAPS — What can't PP do that it should?
       - Are there recurring suggestions that point to missing capabilities?
       - Do improvement themes cluster around a specific unmet need?

    Output a structured INTROSPECTION REPORT with sections A-D.
    Each finding must cite specific evidence (file:line or data point).
    End with 1-3 IMPROVEMENT SUGGESTIONS — concrete, actionable changes to PP.
    Format each suggestion as a single sentence starting with an action verb."
)
```

Extract improvement suggestions from the sense report.

Output: `[REFLECT:SENSE] {N} patterns found, {N} improvements suggested`

**If REFLECT_MODE is not "deep"**: skip to Phase 3.

---

## Phase 2: COMPREHEND (deep introspection)

WHY do these patterns exist? Only runs in "deep" mode.

```
Task(
  description = "PP Self-Reflect Comprehend",
  subagent_type = "general-purpose",
  model = "sonnet",
  max_turns = 15,
  prompt = "You are PP examining the structural causes of its own behavioral patterns.

    The sense phase identified these patterns:
    {SENSE_REPORT}

    Your mission: understand WHY these patterns exist by examining PP's architecture.

    Read PP's source files:
    1. {PP_DIR}/plugin/commands/pp.md (orchestration — how phases connect)
    2. {PP_DIR}/plugin/commands/transmute.md (alchemy — how improvements become modules)
    3. {PP_DIR}/plugin/gates/GATES.md (gate definitions — what we measure)
    4. {PP_DIR}/plugin/gates/ALCHEMY.md (transmutation reference)
    5. {PP_DIR}/CLAUDE.md (activation rules and hierarchy)

    For each pattern from sense:
    1. TRACE THE CAUSE — What in PP's architecture produces this pattern?
       Cite specific file:line showing the structural origin.
    2. ASSESS FIXABILITY — Is this tunable (adjust prompts/thresholds) or structural (needs new module)?
    3. PROPOSE INTERVENTION — What specific change would address the root cause?

    Output:
    - CAUSAL ANALYSIS: For each sense pattern, the structural cause with citations
    - TUNABLE vs STRUCTURAL: Classification of each issue
    - INTERVENTIONS: 1-3 concrete improvements, each more specific than sense's suggestions
      Format: action verb + target + expected outcome
      Example: 'Add sense report summary to comprehend prompt to eliminate redundant file reads'"
)
```

Merge comprehend's interventions with sense's suggestions. Deduplicate.

Output: `[REFLECT:COMPREHEND] {N} causes traced, {N} interventions proposed`

---

## Phase 3: CAPTURE

Append each improvement suggestion to the global PP improvements file:

```bash
mkdir -p ~/.gua/reflections
```

For each suggestion from sense (and comprehend if deep mode):

```bash
echo '{"timestamp":"ISO8601","project":"self-reflection","task":"PP self-reflection","improvement_for_pp":"<suggestion>","failed_gates":[],"signals":[],"virtue_tensions":[]}' >> ~/.gua/reflections/pp-improvements.jsonl
```

Mark these with `"project": "self-reflection"` to distinguish introspective improvements from task-derived ones.

Output per suggestion: `[REFLECT:CAPTURE] "<suggestion>"`

**Auto-distill** after capture:
```bash
gua distill
```

This immediately checks whether the new suggestions cluster with existing ones to form or heat athanor candidates.

Output: `[REFLECT:DISTILL] Athanor updated`

---

## Phase 4: REPORT

```
[REFLECT:COMPLETE] PP Self-Reflection

Mode: {sense-only | deep}
Evidence: {N} reflections across {N} projects
Patterns found: {N}
Improvements captured: {N}
Athanor candidates: {N} ({N} ready for transmutation)

Key finding: {most important pattern}
```

---

## Constraints

- **Minimum 3 reflections** to run (prevents reflecting on nothing)
- **Maximum 3 improvements per run** (prevents suggestion spam that dilutes the athanor)
- **No code changes** — reflection produces suggestions, not edits
- **No recursive reflection** — if the most recent entry in pp-improvements.jsonl is from "self-reflection", warn:
  ```
  [REFLECT:CAUTION] Last improvement was from self-reflection.
  Run /pp on a real task before reflecting again.
  ```
  This prevents the ouroboros from consuming itself.
- **Evidence-grounded** (T1) — every finding must cite a data point. No hallucinated self-improvement.

---

## When to Reflect

- After 5+ PP runs without reflecting
- When `gua load` shows "PP Self-Improvement Queue" in LIGHT.md
- When athanor candidates are stuck below heat threshold
- When mastery level plateaus across sessions
- NOT after every PP run (reflection needs substance)
