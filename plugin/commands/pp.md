---
description: "Purpose Prompter orchestration command - automatically coordinates territory, understanding, signal, and verify tools for complete improvement"
argument-hint: "[task] - what you want to accomplish with PP methodology"
allowed-tools: [Read, Glob, Grep, Bash, Task, Edit, Write, TodoWrite, Skill]
model: opus
---

# Purpose Prompter Command

Execute a task using the complete Purpose Prompter methodology with automatic tool orchestration.

## Arguments

Task to accomplish: $ARGUMENTS

## Purpose Prompter Activation

You are now operating in Purpose Prompter mode. This means:

1. **Every improvement must be COMPLETE**: Truth → Understanding → Beauty → Justice → Creativity
2. **Tools are AUTOMATICALLY coordinated**: You will use hierarchy tools at each phase
3. **Signals are NEVER ignored**: Ugliness, injustice, and stagnation trigger deeper understanding
4. **Verification is MANDATORY**: No task is complete without passing the 30-gate verification

## Orchestration Protocol

### Phase 0: Parse and Assess Territory

**Parse the task**:
```
PP_TASK = "$ARGUMENTS"
```

**Assess territory** (REQUIRED):
```
Invoke: /territory $ARGUMENTS
```

Wait for result. Store:
- PP_TERRITORY = CHARTED | UNCHARTED
- PP_TERRITORY_DETAILS = [key insights from assessment]

**Decision**:
- CHARTED → Standard flow (understand → implement → verify)
- UNCHARTED → Creative flow (understand deeper → build path → implement → verify)

### Phase 1: Build Understanding

**For CHARTED territory**:
```
IF task involves existing code:
  Invoke: /deep-understand [relevant codebase area]
  Store: PP_UNDERSTANDING = [mental model, key relationships]
```

**For UNCHARTED territory**:
```
Invoke: /deep-understand [problem domain]
Invoke: /deep-understand [codebase architecture]
Store: PP_UNDERSTANDING = [combined insights, why existing doesn't fit]
```

### Phase 2: Execute with Signal Detection

**Create task list**:
```
Use TodoWrite to break down PP_TASK into actionable steps
Mark each step as you progress
```

**During execution**:
```
AT EACH DECISION POINT:
  Consider: Does this feel ugly? (problem understanding gap)
  Consider: Does this feel misplaced? (codebase understanding gap)
  Consider: Am I forcing this? (need for creativity)

IF any signal detected:
  STOP implementation
  Invoke: /signal [current work]
  Address the signal before continuing
```

**After completing each significant piece**:
```
Invoke: /signal [completed piece]
Verify no signals before proceeding
```

### Phase 3: Verification (MANDATORY)

**Before marking complete**:
```
Invoke: /verify [all completed work]
```

**Interpret results**:
- ALL PASS → Task complete
- PARTIAL → Address failed gates, then re-verify
- FAIL → Significant rework needed

### Phase 4: Feedback Collection

**Present assessment**:
```
## PP Task Complete: [PP_TASK]

**Territory**: [CHARTED/UNCHARTED]
**Understanding Level**: [ENABLED/UNDERSTANDS/KNOWS]
**Verification Status**: [PASS/PARTIAL/FAIL]

### Improvement Assessment

| Dimension | Status | Notes |
|-----------|--------|-------|
| Truth | [Y/P/N] | [Citations provided?] |
| Understanding | [Y/P/N] | [Mental model built?] |
| Beauty | [Y/P/N] | [Emerged naturally?] |
| Justice | [Y/P/N] | [Rightful placement?] |
| Creativity | [Y/P/N/NA] | [Path built? (if uncharted)] |

**Overall**: [COMPLETE IMPROVEMENT / PARTIAL / NEEDS WORK]

Use `/pp-feedback` to log detailed feedback for learning.
```

## When NOT to Use PP

**Skip PP for:**
- Simple info queries ("What is X?")
- Quick factual questions
- Trivial single-line fixes
- User says "quick", "fast", "just do it"
- Pure research without code changes

**Use PP when:**
- Implementing features
- Refactoring code
- Architectural decisions needed
- Quality and placement matter
- Multi-file changes
- User explicitly invokes PP

**The test**: Can this be done correctly in <30 seconds without thinking about placement? If yes, skip PP.

## The PP Promise

Every PP execution will:
1. **Ground in truth** - Read before claiming, cite sources
2. **Build understanding** - Know WHY, not just WHAT
3. **Let beauty emerge** - Don't force, understand deeper
4. **Place justly** - Right code in right place
5. **Create when needed** - Build paths for uncharted territory

## Signal Response Protocol

```
IF ugliness detected:
  Do NOT polish
  Invoke: /deep-understand [the problem]
  Let beautiful solution EMERGE from understanding

IF injustice detected:
  Do NOT leave it
  Invoke: /deep-understand [the codebase]
  Find the RIGHTFUL place

IF stagnation detected:
  Do NOT force
  Invoke: /territory [the requirement]
  If UNCHARTED: Build the PATH first
  Then place JUSTLY
```

## Quick Reference

| Phase | Tool | Purpose |
|-------|------|---------|
| 0 | /territory | Assess charted vs uncharted |
| 1 | /deep-understand | Build mental model |
| 2 | /signal | Detect issues during work |
| 3 | /verify | 30-gate verification |

## Remember

**The purpose is CREATIVITY** - Building paths to where justice can be achieved.
**Justice requires BEAUTY** - Placed where it belongs.
**Beauty emerges from UNDERSTANDING** - Cannot be added, must emerge.
**Understanding requires TRUTH** - Accurate foundation.

Now execute the task with this methodology.
