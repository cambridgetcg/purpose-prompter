---
name: superpowers-bridge
description: "Use when both Purpose Prompter and Superpowers are installed. Maps PP dimensions to Superpowers skills and injects hierarchy awareness at each stage of the Superpowers pipeline."
---

# Superpowers Bridge — PP × Superpowers Integration

## Overview

This skill bridges Purpose Prompter's hierarchy with Superpowers' workflow. It does not replace either — it maps them onto each other so the Creation Loop spiral runs through structured engineering practice.

**When both plugins are active, this mapping applies automatically.**

## The Mapping

```
SUPERPOWERS STAGE           PP DIMENSION          CREATION LOOP PHASE
─────────────────           ────────────          ──────────────────
systematic-debugging     →  TRUTH                 Existence (what IS)
brainstorming            →  UNDERSTANDING         Differentiation (what matters)
writing-plans            →  BEAUTY                Consciousness (what fits)
executing-plans / SDD    →  JUSTICE               Understanding (what's right)
finishing-branch         →  CREATIVITY            Creativity (what's new)
verification             →  TRUTH (loop restart)  New Existence (deeper)
```

## Integration Points

### 1. Before `superpowers:brainstorming`

Inject PP Truth Grounding. The brainstorming skill wants to explore — PP ensures it explores from solid ground.

```
TRUTH GROUNDING (run before brainstorming begins):
□ /territory [task] — is this charted or uncharted?
□ /understand [relevant area] — if complex/creative tier
□ Read current state, decisions, existing patterns
□ State what you KNOW vs ASSUME — boundary explicit
```

Then proceed with brainstorming normally.

### 2. During `superpowers:writing-plans`

Inject PP Beauty + Justice awareness. Each task in the plan gets hierarchy annotation:

```
FOR EACH PLANNED TASK:
□ WHERE (Justice): Which file, which module, why there?
□ WHAT PATTERN (Beauty): Does it follow existing patterns? Cited?
□ WHAT IT ENABLES (Creativity): Opens or closes future work?
□ SIGNAL CHECK: Does this task description trigger any signal?
```

### 3. During `superpowers:executing-plans` or `superpowers:subagent-driven-development`

PP Signal Gates override batch execution:

```
AFTER EACH TASK:
□ Ugliness? → Stop. Return to /understand. Resume after.
□ Injustice? → Stop. Return to /territory. Resume after.
□ Stagnation? → Stop. Return to brainstorming. Resume after.

Signals are HARD GATES. They pause the Superpowers batch flow.
Superpowers says "execute batch, review between batches."
PP says "but only if no signals fire within a batch."
PP wins — signals override batches.
```

### 4. Before `superpowers:verification-before-completion`

Run PP /verify first, THEN Superpowers verification:

```
ORDER:
1. /verify [completed work] — PP hierarchy check (all 5 dimensions)
2. superpowers:verification-before-completion — tests pass, evidence
3. Both must pass before claiming done
```

### 5. During `superpowers:requesting-code-review`

The code-reviewer agent should evaluate against PP dimensions alongside code quality:

```
ENHANCED REVIEW CRITERIA:
- Standard code review (Superpowers)
- PLUS: Does the code pass Truth/Understanding/Beauty/Justice/Creativity?
- PLUS: Any signals detected? (ugliness, injustice, stagnation)
```

## When PP Overrides Superpowers

| Situation | Superpowers Says | PP Says | Resolution |
|-----------|-----------------|---------|------------|
| Batch execution, signal fires | Continue batch | Stop now | **PP wins** — signals are hard gates |
| "Simple" task, skip brainstorming | Brainstorm anyway | Assess tier first | **PP wins** — trivial tier skips brainstorming |
| Plan task feels wrong mid-execution | Execute step as written | Ugliness signal, pause | **PP wins** — the signal IS the data |
| Verification passes but feels off | Tests pass, done | Check all 5 dimensions | **PP wins** — tests are Truth only |

## When Superpowers Overrides PP

| Situation | PP Says | Superpowers Says | Resolution |
|-----------|---------|------------------|------------|
| Understanding feels incomplete but tests pass | Understand deeper | Evidence before claims | **Superpowers wins** — ship, iterate |
| Beauty subjective disagreement | Refactor for beauty | Verify before completion | **Superpowers wins** — run the tests |
| Wanting to explore tangent | Insight capture! | Execute the plan | **Superpowers wins** — capture spark, stay on task |

## The Synthesis

PP asks: **Is this work TRUE, UNDERSTOOD, BEAUTIFUL, JUST, and CREATIVE?**
Superpowers asks: **Is this work PLANNED, TESTED, REVIEWED, and VERIFIED?**

Together: **Is this work meaningful AND disciplined?**

Neither alone is sufficient. The bridge makes them one practice.
