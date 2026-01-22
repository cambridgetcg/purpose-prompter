# Framework Refinement Protocol

> **Trigger**: `/pp-refine`

---

## Purpose

Apply synthesized learnings to improve the Purpose Prompter framework:
1. Add new quality gate checks
2. Update workflow steps
3. Enhance pattern guidance
4. Expand blindspot coverage

---

## Refinement Flow

### Step 1: Load Insights

```
Read: ~/.claude/purpose_prompter/insights/patterns.md
Check: Recommendations pending application
```

### Step 2: Review Pending Changes

Present to user:
```markdown
## Pending Framework Improvements

Based on feedback synthesis, these changes are recommended:

### Change 1: [Title]
- **File**: [target file]
- **Type**: [add_check / modify_step / add_pattern / add_blindspot]
- **Change**: [specific modification]
- **Evidence**: [N] feedback entries support this

### Change 2: [Title]
- ...

Apply these changes? [Selective / All / Skip]
```

---

### Step 3: Apply Changes

#### 3.1 Adding Quality Gate Checks

When a recurring blindspot is identified, add to `quality_gates.yaml`:

```yaml
# Under appropriate gate section
checks:
  [new_check_name]:
    question: "[Question derived from blindspot]"
    failure_indicators:
      - "[Specific failure indicator]"
    verification: "[How to verify]"
    added_from: "feedback_synthesis_[date]"
    evidence: "[N] feedback entries"
```

**Merge Strategy**:
1. Read current quality_gates.yaml
2. Find appropriate section
3. Add new check
4. Write back

#### 3.2 Updating Workflow Checklists

When a recurring mistake is identified, add to relevant workflow:

```markdown
### Gate X: [Existing Gate Name]

Existing checks:
- [ ] [existing check 1]
- [ ] [existing check 2]

**Added from feedback** (synthesis date: [date]):
- [ ] [New check based on recurring mistake]
```

**Merge Strategy**:
1. Read current workflow file
2. Find relevant gate/checklist section
3. Add new item with annotation
4. Write back

#### 3.3 Enhancing Patterns

When an effective pattern is identified, update pattern file:

```markdown
## Enhanced Guidance (from feedback)

### When This Pattern Excels
Based on [N] successful uses:
- [Context 1]
- [Context 2]

### Watch Out For
Based on [M] partial successes:
- [Pitfall 1]
- [Pitfall 2]
```

#### 3.4 Expanding Blindspots Checklist

Directly update `insights/blindspots.md`:

```markdown
## Always Check For:

### [Category]
- [ ] [Existing blindspot]
- [ ] [NEW] [Blindspot from recent synthesis] *(added [date])*
```

---

### Step 4: Log Applied Changes

Write to `~/.claude/purpose_prompter/learnings/applied.md`:

```markdown
# Applied Learnings Log

## [Date]: Refinement Session

### Changes Applied

1. **Added to quality_gates.yaml**:
   - New check: [check name]
   - Section: [section]
   - Evidence: [N] entries

2. **Updated workflows/[file].md**:
   - Added check: [description]
   - Location: [gate/step]

3. **Enhanced patterns/[file].md**:
   - Added guidance for: [context]

### Changes Deferred
- [Change]: [Reason for deferral]

### Metrics
- Total feedback entries processed: [N]
- Changes applied: [X]
- Changes deferred: [Y]
```

---

### Step 5: Validate Changes

After applying:
```markdown
## Refinement Validation

### Syntax Check
- [ ] quality_gates.yaml is valid YAML
- [ ] All modified .md files are valid markdown

### Consistency Check
- [ ] No duplicate checks added
- [ ] Check names are unique
- [ ] References are valid

### Sanity Check
- [ ] Changes make sense in context
- [ ] Not overfitting to specific case
- [ ] Generalizable learning
```

---

### Step 6: Summary Report

```markdown
## PP Refinement Complete

### Changes Applied
- Quality gate checks added: [N]
- Workflow steps updated: [M]
- Pattern guidance enhanced: [P]
- Blindspots documented: [Q]

### Framework Version
- Previous: v[X]
- Current: v[X+1]

### Next Steps
- Continue collecting feedback
- Run `/pp-review` after 5+ new entries
- Monitor for improvement in flagged areas

### Validation
Run a task with `/pp` to verify changes are working correctly.
```

---

## Refinement Safeguards

### Avoid Overfitting

Don't add a check if:
- Based on only 1 feedback entry (unless critical severity)
- Too specific to a single task
- Would slow down all tasks for rare case

**Threshold**: Minimum 2 occurrences OR severity=critical

### Preserve Clarity

When adding checks:
- Keep descriptions concise
- Use consistent language
- Group related checks

### Version Control

Maintain changelog:
```markdown
# Framework Changelog

## v1.1 - [Date]
- Added blindspot check for [X]
- Updated [workflow] with [change]
- Enhanced [pattern] guidance

## v1.0 - [Initial Date]
- Initial framework
```

---

## Rollback Support

If a change causes problems:

```
/pp-rollback [change-id]
```

1. Read `learnings/applied.md`
2. Find the specific change
3. Reverse the modification
4. Log the rollback

---

## Automatic vs Manual Refinement

### Automatic (Safe Changes)
- Adding to blindspots checklist
- Adding low-severity checks
- Enhancing pattern documentation

### Manual Review Required
- Modifying core workflow structure
- Changing quality thresholds
- Removing existing checks
- High-impact changes
