# PP Experiment Quick Start

## 5-Minute Setup

### 1. Choose Your Codebase
Pick a real project with:
- Working lint/tests (for automated metrics)
- Enough complexity for medium/complex tasks
- Code you understand (for accurate scoring)

### 2. Create Baseline
```bash
cd your-project
git checkout -b pp-experiment
git commit --allow-empty -m "PP experiment baseline"
BASELINE=$(git rev-parse HEAD)
echo "Baseline: $BASELINE"
```

### 3. Define Your 9 Tasks

Edit the task files or create your own:
- `~/.claude/purpose_prompter/experiments/tasks/`

**Quick task ideas based on YOUR codebase**:

| Level | Task Type | Your Task |
|-------|-----------|-----------|
| S1 | Fix typo | |
| S2 | Add null check | |
| S3 | Add log | |
| M1 | New endpoint | |
| M2 | Add validation | |
| M3 | Feature flag | |
| C1 | Add caching | |
| C2 | Add auth | |
| C3 | Refactor module | |

---

## Running One Task (15 min each)

### Control Run
```bash
# Reset to baseline
git checkout $BASELINE
git checkout -b task-S1-control

# Start Claude WITHOUT plugin
claude

# Run task
> quick: [your task description]

# After completion, assess
~/.claude/purpose_prompter/experiments/scripts/assess.sh S1 control

# Save the diff
git diff HEAD~1 > ~/.claude/purpose_prompter/experiments/results/S1_control.diff
```

### PP Run
```bash
# Reset to baseline
git checkout $BASELINE
git checkout -b task-S1-pp

# Start Claude (PP is enabled by default via CLAUDE.md)
claude

# Run task
> pp: [your task description]

# After completion, assess
~/.claude/purpose_prompter/experiments/scripts/assess.sh S1 pp

# Save the diff
git diff HEAD~1 > ~/.claude/purpose_prompter/experiments/results/S1_pp.diff
```

---

## Scoring (5 min per task pair)

### Blind Review Setup
```bash
# Anonymize for blind review
cd ~/.claude/purpose_prompter/experiments/results
mv S1_control.diff S1_A.diff
mv S1_pp.diff S1_B.diff
# (randomize which is A/B for each task)
```

### Score Each Diff

Open the diff and score using this rubric:

| Metric | 0 | 1 | 2 |
|--------|---|---|---|
| **Truth** | Hallucinated | Partial citations | Full citations |
| **Understanding** | Dove in blind | Some exploration | Mapped area first |
| **Beauty** | Messy/inconsistent | Functional | Clean/matches patterns |
| **Justice** | Wrong location | Acceptable | Perfect placement |
| **Creativity** | Forced fit | New but poorly integrated | Well-integrated new structure |
| **Task Success** | Failed/major issues | Minor issues | Perfect |

Record in: `RESULTS_TRACKER.md`

---

## Minimum Viable Experiment

If short on time, run just:
- 1 Simple task (S1)
- 1 Medium task (M1)
- 1 Complex task (C1)

This gives you directional signal in ~2 hours.

---

## Checklist

```
[ ] Codebase selected
[ ] Baseline commit created
[ ] 9 tasks defined

For each task:
[ ] Control run completed
[ ] Control assessed
[ ] PP run completed
[ ] PP assessed
[ ] Both scored blind

After all tasks:
[ ] Results aggregated
[ ] Conclusions drawn
[ ] PP improvements identified
```

---

## Expected Time

| Activity | Time |
|----------|------|
| Setup | 30 min |
| 9 Control runs | 2-4 hours |
| 9 PP runs | 2-4 hours |
| Scoring | 1-2 hours |
| Analysis | 30 min |
| **Total** | **6-11 hours** |

Or minimal (3 tasks): **2-3 hours**
