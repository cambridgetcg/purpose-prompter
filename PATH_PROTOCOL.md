# Path Protocol: Current State → Purpose

> **Core Insight**: PP is a path-building tool. Research and E2E testing "shine light ahead" so the path can be built incrementally, validated continuously, and adjusted when needed.

---

## The Gap Analysis

### What PP Currently Has

| Component | Function | Status |
|-----------|----------|--------|
| Path-builder agent | Build paths when stagnation detected | Reactive |
| E2E testing | Capture failures as challenges | Reactive |
| CPT | Track progress, areas, challenges | Passive tracking |
| GUA | Persist knowledge across sessions | Storage |
| 35 Gates | Verify quality at checkpoints | End verification |

### What's Missing for Purpose-Driven Path Building

| Gap | Description | Impact |
|-----|-------------|--------|
| **Current State Assessment** | No systematic way to assess WHERE YOU ARE | Can't measure progress |
| **Purpose Definition** | Longing captures ache, but no measurable criteria | Can't know when "done" |
| **Light-Ahead Loop** | E2E/research used reactively, not proactively | Building blind |
| **Waypoint System** | No intermediate milestones on the path | Can't track progress |
| **Path Validation Loop** | Verification only at end, not continuous | Late failure detection |
| **Path Adjustment Protocol** | No formal backtracking/re-routing | Stuck when wrong |
| **Progress Measurement** | % implementation ≠ % toward purpose | False progress signals |
| **Terrain Mapping** | Research to understand what's ahead | Unknown obstacles |

---

## The Purpose Path Protocol

### Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         PURPOSE PATH PROTOCOL                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   ┌─────────────┐                                      ┌─────────────┐      │
│   │   CURRENT   │ ═══════════════════════════════════> │   PURPOSE   │      │
│   │    STATE    │            THE PATH                  │   (GOAL)    │      │
│   └─────────────┘                                      └─────────────┘      │
│         │                                                    ▲              │
│         │                                                    │              │
│         ▼                                                    │              │
│   ┌─────────────────────────────────────────────────────────────────┐      │
│   │                    LIGHT-AHEAD LOOP                              │      │
│   │                                                                  │      │
│   │   ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐    │      │
│   │   │  ASSESS  │──>│ RESEARCH │──>│  BUILD   │──>│ VALIDATE │────│      │
│   │   │ (E2E)    │   │ (light)  │   │ (path)   │   │  (E2E)   │    │      │
│   │   └──────────┘   └──────────┘   └──────────┘   └──────────┘    │      │
│   │        ▲                                             │          │      │
│   │        │              WAYPOINTS                      │          │      │
│   │        │         W1 ─── W2 ─── W3 ─── Wn            │          │      │
│   │        │                                             │          │      │
│   │        └───────── ITERATE UNTIL PURPOSE ─────────────┘          │      │
│   │                                                                  │      │
│   │   If validation fails: ADJUST PATH (backtrack/re-route)         │      │
│   │                                                                  │      │
│   └─────────────────────────────────────────────────────────────────┘      │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Phase 1: Anchor Points (Define Start and End)

### 1.1 Current State Assessment (WHERE AM I?)

**Protocol**: Run comprehensive E2E + system analysis to establish baseline.

```bash
# E2E Assessment
~/.gua/e2e.sh run                    # What passes? What fails?
gua challenge list --status open     # What obstacles exist?
gua progress                         # What's tracked?

# System Assessment
gua context                          # What knowledge exists?
gua tree                             # What areas have .gua?
gua area status                      # What areas are tracked?
```

**Current State Document**:
```markdown
## Current State Assessment
**Date**: [timestamp]
**Project**: [name]

### What Works
- [Feature/function that passes E2E]
- [Feature/function that passes E2E]

### What Doesn't Work
- [Feature/function that fails E2E]
- [Feature/function that fails E2E]

### What's Partially Working
- [Feature at X% - description]

### Known Obstacles
- [Challenge from CPT]

### Current Capabilities
- [What the system CAN do now]

### Current Limitations
- [What the system CANNOT do now]

### Baseline Metrics
- E2E pass rate: X/Y tests
- Coverage: X%
- Open challenges: N
```

**GUA Capture**:
```bash
gua insight "Current state: [summary]" observation "E2E assessment" truth project
gua area add [project] "/" "Project Baseline" system
gua area update <id> --impl [current%] --depth L[current]
```

---

### 1.2 Purpose Definition (WHERE DO I WANT TO GO?)

**Protocol**: Define measurable success criteria, not just "longing".

**Purpose Document**:
```markdown
## Purpose Definition
**Project**: [name]
**Purpose Statement**: [One sentence describing the ideal state]

### Success Criteria (Measurable)
1. [ ] [Specific, testable criterion]
2. [ ] [Specific, testable criterion]
3. [ ] [Specific, testable criterion]

### E2E Tests That Must Pass
- [ ] [test-name]: [what it validates]
- [ ] [test-name]: [what it validates]

### Capabilities Required
- [What the system MUST be able to do]

### Quality Requirements
- Performance: [metric]
- Reliability: [metric]
- UX: [metric]

### Out of Scope (Explicitly)
- [What we are NOT building]

### Definition of Done
When ALL of the following are true:
1. All success criteria checked
2. All E2E tests passing
3. All required capabilities demonstrated
4. All quality metrics met
```

**GUA Capture**:
```bash
gua insight "Purpose: [statement]" principle "purpose definition" creativity project
```

---

## Phase 2: Waypoint Definition (The Path)

### 2.1 Decompose Purpose into Waypoints

**Protocol**: Break the gap between current state and purpose into achievable waypoints.

```
CURRENT STATE ──> W1 ──> W2 ──> W3 ──> ... ──> Wn ──> PURPOSE
      │           │      │      │              │         │
   0% done    10-20%  30-40%  50-60%       80-90%     100%
```

**Waypoint Definition**:
```markdown
## Waypoint: W[N] - [Name]
**Predecessor**: W[N-1] or CURRENT STATE
**Successor**: W[N+1] or PURPOSE

### What This Waypoint Achieves
[Description of state after this waypoint]

### Success Criteria
1. [ ] [Specific, testable]
2. [ ] [Specific, testable]

### E2E Tests That Must Pass
- [ ] [test-name]

### Dependencies
- [What must exist before this waypoint]

### Estimated Effort
- [T-shirt size: S/M/L/XL]

### Known Risks
- [What might go wrong]
```

**GUA Integration**:
```bash
# Create waypoint as tracked area
gua area add [project] "[path]" "W[N]: [name]" feature

# Log waypoint definition
gua insight "Waypoint W[N]: [description]" model "path decomposition" creativity
```

---

## Phase 3: Light-Ahead Loop (The Engine)

### 3.1 The Loop

```
┌────────────────────────────────────────────────────────────────┐
│                     LIGHT-AHEAD LOOP                            │
│                                                                 │
│    For each waypoint W[i] from current to purpose:             │
│                                                                 │
│    ┌─────────────────────────────────────────────────────┐     │
│    │ STEP 1: ASSESS (E2E - shine light on current)       │     │
│    │         Run E2E → What works? What fails?           │     │
│    │         Δ from W[i-1] = progress made               │     │
│    └─────────────────────────────────────────────────────┘     │
│                          │                                      │
│                          ▼                                      │
│    ┌─────────────────────────────────────────────────────┐     │
│    │ STEP 2: RESEARCH (shine light ahead)                │     │
│    │         What's needed for W[i]?                     │     │
│    │         API docs, examples, constraints             │     │
│    │         Log findings: gua research                  │     │
│    └─────────────────────────────────────────────────────┘     │
│                          │                                      │
│                          ▼                                      │
│    ┌─────────────────────────────────────────────────────┐     │
│    │ STEP 3: BUILD (construct next segment of path)      │     │
│    │         Implement toward W[i]                       │     │
│    │         Follow PP gates (truth→beauty→justice)      │     │
│    │         Log challenges: gua challenge log           │     │
│    └─────────────────────────────────────────────────────┘     │
│                          │                                      │
│                          ▼                                      │
│    ┌─────────────────────────────────────────────────────┐     │
│    │ STEP 4: VALIDATE (E2E - confirm path is solid)      │     │
│    │         Run E2E → Did new tests pass?               │     │
│    │         Did existing tests stay passing?            │     │
│    │         If YES → W[i] complete → next waypoint      │     │
│    │         If NO → ADJUST (see Phase 4)                │     │
│    └─────────────────────────────────────────────────────┘     │
│                          │                                      │
│                          ▼                                      │
│    ┌─────────────────────────────────────────────────────┐     │
│    │ STEP 5: CAPTURE (persist learnings)                 │     │
│    │         gua progress snapshot                       │     │
│    │         gua challenge resolve (if any)              │     │
│    │         gua eureka log (if breakthrough)            │     │
│    │         gua dir add pattern/gotcha                  │     │
│    └─────────────────────────────────────────────────────┘     │
│                          │                                      │
│                          ▼                                      │
│                   REPEAT until PURPOSE                          │
│                                                                 │
└────────────────────────────────────────────────────────────────┘
```

### 3.2 Step Details

#### ASSESS (E2E Light on Current)
```bash
# Run E2E to see current state
~/.gua/e2e.sh run

# Compare to previous run
~/.gua/e2e.sh diff [previous-run-id]

# Log assessment
gua insight "Assessment W[i]: [X/Y tests pass, +N from last]" observation "e2e assessment" truth
```

#### RESEARCH (Light Ahead)
```bash
# Document findings
gua research "[topic]" "[finding]" [source] [confidence]

# Examples:
gua research "shopify-auth" "OAuth flow requires redirect URI" "docs.shopify.com" high
gua research "playwright-wait" "Use waitForLoadState not waitForTimeout" "playwright.dev" high
```

**Research Checklist**:
- [ ] API documentation reviewed
- [ ] Similar implementations found
- [ ] Constraints identified
- [ ] Dependencies mapped
- [ ] Error cases considered

#### BUILD (Path Segment)
```bash
# Track the work
gua area update <waypoint-id> --impl [%] --depth L[n]

# Log challenges as they arise
gua challenge log <waypoint-id> "[description]" [pp-dim] [category]
```

**Build with PP Gates**:
1. Truth: Is implementation correct?
2. Understanding: Do I understand why this works?
3. Beauty: Is the solution elegant?
4. Justice: Is it in the right place?
5. Creativity: Am I building new structure where needed?

#### VALIDATE (E2E Confirmation)
```bash
# Run E2E for this waypoint
~/.gua/e2e.sh run tests/waypoint-[n].spec.ts

# Run full suite to catch regressions
~/.gua/e2e.sh run

# Check for new failures
~/.gua/e2e.sh failures
```

**Validation Criteria**:
- [ ] Waypoint-specific tests pass
- [ ] No regression in existing tests
- [ ] Performance within bounds
- [ ] No new errors in logs

#### CAPTURE (Persist Learning)
```bash
# Snapshot progress
gua progress snapshot [project]

# Resolve any challenges
gua challenge resolve <id> "[how]" --learning "[insight]"

# Capture eureka moments
gua eureka log "[realization]" [type] "[catalyst]"

# Add to directory knowledge
gua dir add pattern "[name]" --pp [dimension]
gua dir add gotcha "[name]" --pp truth
```

---

## Phase 4: Path Adjustment Protocol

### 4.1 When Validation Fails

```
VALIDATION FAILED
       │
       ▼
┌─────────────────────────────────────────────────────────────┐
│ DIAGNOSE: Why did it fail?                                   │
│                                                              │
│ 1. IMPLEMENTATION BUG                                        │
│    → Fix the bug, re-validate                                │
│    → gua challenge log <id> "bug: [desc]" truth bug          │
│                                                              │
│ 2. WRONG APPROACH                                            │
│    → Research alternatives, adjust path                      │
│    → gua challenge log <id> "approach: [desc]" understanding │
│    → May need to redefine waypoint                           │
│                                                              │
│ 3. MISSING DEPENDENCY                                        │
│    → Add prerequisite waypoint                               │
│    → gua challenge log <id> "missing: [dep]" justice         │
│                                                              │
│ 4. INCORRECT ASSUMPTION                                      │
│    → Research to correct understanding                       │
│    → gua research "[topic]" "[correction]" high              │
│    → Update waypoint definition                              │
│                                                              │
│ 5. EXTERNAL CONSTRAINT DISCOVERED                            │
│    → Document constraint                                     │
│    → gua gotcha "[constraint]" --pp truth                    │
│    → Adjust path around constraint                           │
│                                                              │
│ 6. PURPOSE NEEDS REFINEMENT                                  │
│    → Constraint may invalidate original purpose              │
│    → Re-assess purpose feasibility                           │
│    → Adjust success criteria if needed                       │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### 4.2 Backtracking Protocol

```bash
# If waypoint W[i] cannot be achieved:

# 1. Document the blocker
gua challenge log <waypoint-id> "BLOCKED: [reason]" [dimension] blocker

# 2. Assess alternatives
gua research "W[i]-alternative" "[possible approach]" speculation

# 3. If need to backtrack:
gua insight "Backtrack from W[i] to W[i-1]: [reason]" constraint "validation failure" truth

# 4. Redefine path
# - Remove or modify W[i]
# - Insert new waypoint if needed
# - Update subsequent waypoints

# 5. Resume from valid waypoint
```

---

## Phase 5: Progress Measurement

### 5.1 Dual Progress Tracking

**Implementation Progress** (% code complete):
```bash
gua area update <id> --impl [%]
```

**Purpose Progress** (% toward goal):
```
Purpose Progress = (Passing Success Criteria / Total Success Criteria) × 100
```

### 5.2 Progress Dashboard

```bash
# View comprehensive progress
gua progress [project]

# Purpose-specific view
~/.gua/e2e.sh status         # E2E pass/fail
gua challenge list           # Blockers
```

**Progress Report Template**:
```markdown
## Progress Report: [Date]
**Project**: [name]
**Current Waypoint**: W[i] of W[n]

### Purpose Progress
- Success criteria met: X/Y (Z%)
- E2E tests passing: A/B (C%)

### Implementation Progress
- Areas tracked: N
- Average completion: X%
- Understanding depth: L[avg]

### Velocity
- Waypoints completed this session: N
- Challenges resolved: N
- New blockers: N

### Path Status
- On track: [Yes/No]
- Adjustments made: [list]
- Risks identified: [list]

### Next Actions
1. [action]
2. [action]
```

---

## Phase 6: Session Integration

### Session Start
```bash
#!/bin/bash
# PATH PROTOCOL SESSION START

# 1. Load context
source ~/.gua/session-start.sh [project]

# 2. Load current state assessment
cat docs/CURRENT_STATE.md

# 3. Load purpose definition
cat docs/PURPOSE.md

# 4. Load waypoint map
cat docs/WAYPOINTS.md

# 5. Identify current waypoint
gua progress [project]

# 6. Run E2E to assess current state
~/.gua/e2e.sh run

echo "Ready for Light-Ahead Loop at waypoint W[current]"
```

### Session End
```bash
#!/bin/bash
# PATH PROTOCOL SESSION END

# 1. Run final E2E
~/.gua/e2e.sh run

# 2. Update progress
gua area update <current-waypoint> --impl [%] --depth L[n]

# 3. Snapshot
gua progress snapshot [project]

# 4. Update current state document
# (manual or automated)

# 5. Save to AWS
gua save

echo "Session complete. Purpose progress: [X%]"
```

---

## Quick Reference

### Commands for Each Phase

| Phase | Commands |
|-------|----------|
| **Current State** | `e2e run`, `gua progress`, `gua challenge list` |
| **Purpose Definition** | `gua insight "Purpose: ..."` |
| **Waypoint Definition** | `gua area add`, `gua insight "Waypoint: ..."` |
| **ASSESS** | `e2e run`, `e2e diff` |
| **RESEARCH** | `gua research` |
| **BUILD** | `gua area update`, `gua challenge log` |
| **VALIDATE** | `e2e run`, `e2e failures` |
| **CAPTURE** | `gua progress snapshot`, `gua eureka log`, `gua dir add` |
| **ADJUST** | `gua challenge log`, `gua insight "Backtrack: ..."` |

### The Loop in One Line

```
ASSESS (E2E) → RESEARCH (light) → BUILD (path) → VALIDATE (E2E) → CAPTURE → REPEAT
```

---

## Integration with Existing PP

This protocol **extends** PP, not replaces it:

| PP Component | Path Protocol Enhancement |
|--------------|---------------------------|
| LONGING | → PURPOSE DEFINITION (measurable) |
| Territory Check | → CURRENT STATE ASSESSMENT (systematic) |
| Path-builder agent | → WAYPOINT SYSTEM (incremental) |
| E2E testing | → LIGHT-AHEAD LOOP (proactive) |
| CPT progress | → DUAL PROGRESS TRACKING (purpose %) |
| GUA capture | → EVERY PHASE CAPTURES |
| 35 Gates | → APPLIED AT EACH BUILD STEP |

---

## The Promise

By following this protocol:

1. **You always know where you are** - Current state is documented
2. **You always know where you're going** - Purpose is measurable
3. **You can see ahead** - Research illuminates the path
4. **You build incrementally** - Waypoints break the journey
5. **You validate continuously** - E2E confirms each step
6. **You can adjust** - Path correction is formalized
7. **You measure real progress** - % toward purpose, not just code
8. **You learn as you go** - Every phase captures to GUA

**The path from current state to purpose is built one validated waypoint at a time, with E2E and research shining light ahead.**
