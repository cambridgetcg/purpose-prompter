# PP Controlled Experiment Framework

## Hypothesis

**H1**: PP produces higher quality outputs than non-PP for medium and complex tasks.
**H2**: PP overhead is not justified for simple tasks.
**H0**: No significant difference in output quality.

---

## Complexity Levels

### Level 1: SIMPLE (Single-location, obvious solution)
**Characteristics**:
- Single file modification
- Clear, unambiguous requirement
- Existing pattern to follow
- <10 lines of code change
- No architectural decisions

**Example tasks**:
- Fix a typo in a string
- Add a missing null check
- Rename a variable
- Add a simple validation

**Expected PP value**: LOW (overhead may exceed benefit)

---

### Level 2: MEDIUM (Multi-location, pattern-following)
**Characteristics**:
- 2-5 files modified
- Requires understanding existing patterns
- Follows established architecture
- 10-100 lines of code change
- Minor design decisions

**Example tasks**:
- Add a new API endpoint following existing patterns
- Implement a new form with validation
- Add a feature flag with toggle
- Create a new component similar to existing ones

**Expected PP value**: MEDIUM-HIGH (understanding and placement matter)

---

### Level 3: COMPLEX (Architectural, novel solution)
**Characteristics**:
- 5+ files modified or new structure created
- Requires architectural decisions
- May need new patterns
- 100+ lines of code change
- Significant design decisions
- Could be "uncharted territory"

**Example tasks**:
- Implement authentication system
- Add real-time features
- Refactor module architecture
- Integrate new third-party service

**Expected PP value**: HIGH (understanding, placement, creativity all critical)

---

## Objective Metrics

### Automated Metrics (Measurable)

| Metric | How to Measure | Tool |
|--------|----------------|------|
| **Syntax correctness** | Code compiles/lints | `eslint`, `tsc`, `ruff` |
| **Test pass rate** | Tests pass after change | `npm test`, `pytest` |
| **Complexity delta** | Cyclomatic complexity change | `eslint-plugin-complexity` |
| **File count** | Number of files touched | `git diff --stat` |
| **Line count** | Lines added/removed | `git diff --numstat` |
| **Citation rate** | % of claims with file:line | Manual count |

### Manual Metrics (Rubric-scored)

| Metric | What to Assess | Scale |
|--------|----------------|-------|
| **Understanding** | Did it read before writing? | 0-2 |
| **Pattern conformance** | Matches existing code style? | 0-2 |
| **Placement accuracy** | Code in right location? | 0-2 |
| **Completeness** | All requirements addressed? | 0-2 |
| **No regressions** | Didn't break existing code? | 0-2 |

---

## Scoring Rubric

### TRUTH Score (0-2)
```
0 = Made claims without reading code, or hallucinated
1 = Read some code, partial citations
2 = Read all relevant code, cited file:line for claims
```

### UNDERSTANDING Score (0-2)
```
0 = Dove into code without understanding context
1 = Some exploration, but missed key relationships
2 = Mapped area thoroughly, understood WHY not just WHAT
```

### BEAUTY Score (0-2)
```
0 = Code is messy, doesn't follow patterns, overly complex
1 = Code is functional but inconsistent with codebase style
2 = Code is clean, follows patterns, right-sized complexity
```

### JUSTICE Score (0-2)
```
0 = Code placed in wrong location, violates architecture
1 = Code placement is acceptable but not ideal
2 = Code is in exactly the right place, respects boundaries
```

### CREATIVITY Score (0-2) [Complex tasks only]
```
0 = Forced solution into wrong structure, created tech debt
1 = Built new structure but poorly integrated
2 = Built appropriate new structure, well-integrated
```

### TASK SUCCESS Score (0-2)
```
0 = Task not completed or major issues
1 = Task completed with minor issues
2 = Task completed perfectly
```

---

## Experiment Protocol

### Setup
1. Select a real codebase (this repo or another)
2. Create 3 tasks per complexity level (9 total)
3. Document each task with clear requirements
4. Record baseline state (git commit)

### Execution
For each task:

```
1. RESET to baseline state
   git checkout [baseline]

2. RUN WITHOUT PP (Control)
   claude (no plugin)
   > quick: [task description]

   Record:
   - Time taken
   - Files changed
   - Output quality (auto + manual metrics)
   - Save diff: git diff > results/task_X_control.diff

3. RESET to baseline state
   git checkout [baseline]

4. RUN WITH PP (Treatment)
   claude
   > pp: [task description]

   Record:
   - Time taken
   - Files changed
   - Output quality (auto + manual metrics)
   - Save diff: git diff > results/task_X_pp.diff

5. BLIND REVIEW
   - Anonymize diffs (remove PP references)
   - Score both using rubric
   - Record in results spreadsheet
```

### Blinding
To reduce bias:
- Reviewer should not know which output is PP vs control
- Rename files: `task_X_A.diff`, `task_X_B.diff`
- Randomize A/B assignment per task

---

## Results Template

```
Task ID: ___
Complexity: [ ] Simple [ ] Medium [ ] Complex
Description: ___

                        CONTROL    PP
Time (minutes)          ___        ___
Files changed           ___        ___
Lines changed           ___        ___
Lint errors             ___        ___
Tests pass              ___        ___

TRUTH                   ___/2      ___/2
UNDERSTANDING           ___/2      ___/2
BEAUTY                  ___/2      ___/2
JUSTICE                 ___/2      ___/2
CREATIVITY              ___/2      ___/2
TASK SUCCESS            ___/2      ___/2

TOTAL                   ___/12     ___/12

Winner: [ ] Control [ ] PP [ ] Tie
Notes: ___
```

---

## Statistical Analysis

With 9 tasks (3 per level):
- Use paired comparison (same task, different treatment)
- Calculate mean score difference per complexity level
- Report: PP_score - Control_score for each dimension

### Expected Outcomes

| Level | Expected PP Advantage |
|-------|----------------------|
| Simple | -1 to 0 (overhead cost) |
| Medium | +1 to +3 (understanding helps) |
| Complex | +2 to +5 (all dimensions help) |

### Success Criteria

PP is valuable if:
1. Simple: PP overhead is minimal (< 2 point deficit)
2. Medium: PP shows advantage (> 1 point gain)
3. Complex: PP shows clear advantage (> 2 point gain)

---

## Quick Start

1. Pick your codebase
2. Define 9 tasks (see task templates)
3. Run experiment protocol
4. Score using rubrics
5. Analyze results

See `tasks/` folder for task templates.
See `rubrics/` folder for detailed scoring guides.
See `results/` folder for recording outcomes.
