# PP Agents — Subagent Integration for Purpose Prompter

> **Core Principle**: Agents handle research. Main handles execution.
> Agents NEVER edit files. Main NEVER skips scouts on complex tasks.

---

## Agent Roles

Six roles map to PP's Claude Enhancement Gates:

| Role | Type | PP Gate | Purpose |
|------|------|---------|---------|
| **Territory Scout** | Explore | Creativity: Territory | Charted/uncharted assessment via exhaustive search |
| **Pattern Archaeologist** | Explore | Beauty: Conformance | Find existing patterns, conventions, anti-patterns |
| **Placement Surveyor** | Explore | Justice: Evidence | Survey candidate locations, cite placement evidence |
| **Design Architect** | Plan | Understanding: Mental Model | Design approach from research results |
| **Verification Auditor** | Explore | Truth: Citation + all gates | Post-execution gate verification |
| **Test Runner** | Bash | Truth: Grounding | Type check + test suite execution |

---

## Tier-Based Dispatch

### [T] TRIVIAL — 0 agents

Execute directly. No overhead.

### [S] STANDARD — 0-1 agents

```
IF uncertain about pattern or placement:
  Spawn 1 Pattern Archaeologist
  → Consume PATTERNS_FOUND
  → Execute with conformance
ELSE:
  Execute directly
  Inline verify: T✓B✓J✓
```

### [C] COMPLEX — 2-3 agents per phase

```
STEP 0 ─── Territory Scout ──────────────────────→ TERRITORY output
              │
STEP 1 ─── ┌─┴────────────────────────────────┐
            │ Pattern Archaeologist (parallel)  │ → PATTERNS_FOUND
            │ Placement Surveyor   (parallel)  │ → CANDIDATES
            └──────────────────────────────────┘
              │
STEP 2 ─── Main synthesizes + executes (Edit/Write)
              │
STEP 3 ─── ┌─┴────────────────────────────────┐
            │ Test Runner          (parallel)  │ → pass/fail
            │ Verification Auditor (parallel)  │ → GATE_RESULTS
            └──────────────────────────────────┘
```

### [X] CREATIVE — Full orchestration

```
STEP 0 ─── Territory Scout (MUST prove uncharted) ─→ TERRITORY output
              │
STEP 1 ─── ┌─┴────────────────────────────────┐
            │ Pattern Archaeologist (parallel)  │ → PATTERNS_FOUND + near-misses
            │ Placement Surveyor   (parallel)  │ → CANDIDATES
            │ (Optional) Domain Expert         │ → domain-specific research
            └──────────────────────────────────┘
              │
STEP 2 ─── Design Architect (Plan agent)
            Input: all Step 0-1 outputs
            Output: APPROACH + CHANGES
              │
STEP 3 ─── Main executes from plan (Edit/Write)
              │
STEP 4 ─── ┌─┴────────────────────────────────┐
            │ Test Runner          (parallel)  │ → pass/fail
            │ Verification Auditor (parallel)  │ → GATE_RESULTS
            └──────────────────────────────────┘
```

---

## Output Contracts

Agents return **structured output**, not prose. Main consumes these as phase inputs.

### Territory Scout

```
TERRITORY: charted | uncharted | mixed
EVIDENCE:
  - Similar: [file:line — description]
  - Near-misses: [file:line — why it doesn't apply]
SEARCHES_PERFORMED:
  - Grep: "[pattern]" → [N results]
  - Glob: "[pattern]" → [N files]
RECOMMENDATION: use existing | extend existing | build new
```

### Pattern Archaeologist

```
PATTERNS_FOUND:
  - Pattern: [name]
    Source: [file:line]
    Convention: [naming | structure | error handling | imports | etc.]
    Applicability: direct | adapt | reference only
CONVENTIONS:
  - Naming: [observed convention]
  - Error handling: [observed convention]
  - File structure: [observed convention]
ANTI_PATTERNS:
  - [what NOT to follow, with source citation]
```

### Placement Surveyor

```
CANDIDATES:
  - Location: [file path]
    Contents: [what's already there]
    Fit: high | medium | low
    Reason: [why this location]
RECOMMENDED: [file path]
EVIDENCE: [similar code at file:line]
NOT_RECOMMENDED: [path — reason]
```

### Design Architect

```
APPROACH: [1-2 sentence summary]
CHANGES:
  - [file path]: [what and why]
DEPENDENCIES: [ordering constraints]
RISKS: [what could go wrong]
ALTERNATIVES_REJECTED:
  - [alternative — why not]
```

### Verification Auditor

```
GATE_RESULTS:
  T: pass | fail — [reason, citation]
  U: pass | fail — [reason, citation]
  B: pass | fail — [reason, citation]
  J: pass | fail — [reason, citation]
  C: pass | fail — [reason, citation]  (creative tier only)
SIGNALS:
  Ugliness: none | [where — what]
  Injustice: none | [where — what]
  Stagnation: none | [where — what]
ISSUES: [specific problems with file:line]
VERDICT: clean | needs fixes
```

### Test Runner

```
TYPE_CHECK: pass | fail — [error count]
TESTS: pass | fail — [passed/total, failures listed]
COVERAGE_DELTA: [if available]
```

---

## Execution Markers (Agent-Aware)

Extended markers track agent dispatch:

```
[PP:CLASSIFY]    Tier assigned: [T|S|C|X]
[PP:SCOUT]       Territory Scout spawned → TERRITORY: charted|uncharted
[PP:RESEARCH]    Pattern Archaeologist + Placement Surveyor spawned (parallel)
[PP:PATTERNS]    Consumed: N patterns found, convention: [summary]
[PP:PLACEMENT]   Consumed: recommended [file], evidence: [file:line]
[PP:DESIGN]      Design Architect spawned (X tier only)
[PP:EXECUTE]     Main editing [file]
[PP:VERIFY]      Verification Auditor + Test Runner spawned (parallel)
[PP:GATE_RESULT] T✓U✓B✓J✓ or T✓U✓B✓J✓C✓
[PP:COMPLETE]    All gates passed, verified
```

---

## Memory Integration

After agent-assisted tasks, update project memory:

| Agent | Memory Target | Condition |
|-------|---------------|-----------|
| Pattern Archaeologist | `.claude/context/API_PATTERNS.md` | New pattern discovered |
| Verification Auditor | `.claude/memory/GAPS.md` | New gaps found |
| Territory Scout | `.claude/memory/INSIGHTS.md` | Useful near-misses |
| Any agent | `gua moment "..."` | Signal detected |

---

## Signal-Driven Agent Escalation

When a signal is detected mid-execution:

```
Signal: Ugliness (understanding gap)
  → Spawn Pattern Archaeologist to deepen understanding
  → May escalate tier: [S]→[C] or [C]→[X]

Signal: Injustice (placement doubt)
  → Spawn Placement Surveyor to re-survey
  → May require re-execution at different location

Signal: Stagnation (need new structure)
  → Spawn Territory Scout to confirm uncharted
  → Escalate to [X] creative tier
```

---

## Rules

1. **Agents NEVER edit files.** Main conversation owns all Edit/Write calls.
2. **[C] and [X] MUST spawn Territory Scout** before execution (Law 6).
3. **[C] and [X] MUST spawn Verification Auditor** after execution (Law 7).
4. **Max 3 parallel agents** per spawn. Don't over-parallelize.
5. **Agent prompts include output contract.** Agents return structured data, not essays.
6. **Main synthesizes.** Agent outputs are inputs to main's judgment, not directives.
7. **Inject project context.** Every agent prompt includes the project's Agent Context block.
8. **Resume agents when possible.** If follow-up needed, resume the same agent ID.

---

## Quick Reference

```
Task arrives
  │
  ├─ [T] → Execute → Done
  │
  ├─ [S] → (optional: 1 Explore) → Execute → Inline T✓B✓J✓
  │
  ├─ [C] → Scout → 2 Explores ║ → Execute → Test+Audit ║
  │
  └─ [X] → Scout → 3 Explores ║ → Plan → Execute → Test+Audit ║

║ = parallel spawn
```
