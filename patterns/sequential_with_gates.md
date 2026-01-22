# Sequential with Gates Pattern

> **When to use**: Feature implementation, multi-step tasks where each step must be validated before proceeding.

---

## Pattern Structure

```
[Start]
    │
    ▼
┌─────────┐
│ Step 1  │
└────┬────┘
     │
     ▼
┌─────────┐     ┌─────────┐
│ Gate 1  │────▶│ Remediate│ (if fail)
└────┬────┘     └────┬────┘
     │ pass          │
     │◀──────────────┘
     ▼
┌─────────┐
│ Step 2  │
└────┬────┘
     │
     ▼
┌─────────┐     ┌─────────┐
│ Gate 2  │────▶│ Remediate│ (if fail)
└────┬────┘     └────┬────┘
     │ pass          │
     │◀──────────────┘
     ▼
    ...
     │
     ▼
┌─────────┐
│ Step N  │
└────┬────┘
     │
     ▼
┌─────────┐
│ Final   │
│ Gate    │
└────┬────┘
     │ pass
     ▼
[Complete]
```

---

## Template

```markdown
## Task Overview

**Goal**: [What we're building]
**Steps Identified**: [N]
**Quality Gates**: [List key gates]

---

## Step 1: [Title]

### Objective
[What this step accomplishes]

### Prerequisites
- [What must be true before starting]

### Execution
[Actual work of the step]

### Output
[What this step produces]

---

### Gate 1: [Step 1 Validation]

**Checks**:
- [ ] [Specific check 1]
- [ ] [Specific check 2]
- [ ] [Specific check 3]

**Result**: [PASS/FAIL]

**If FAIL**:
- Issue: [What's wrong]
- Remediation: [How to fix]
- [Apply fix, re-check gate]

---

## Step 2: [Title]

### Objective
[What this step accomplishes]

### Prerequisites
- Step 1 complete and validated
- [Additional prerequisites]

### Execution
[Actual work of the step]

### Output
[What this step produces]

---

### Gate 2: [Step 2 Validation]

**Checks**:
- [ ] [Specific check 1]
- [ ] [Specific check 2]
- [ ] [Specific check 3]
- [ ] Integrates correctly with Step 1 output

**Result**: [PASS/FAIL]

**If FAIL**:
- Issue: [What's wrong]
- Remediation: [How to fix]
- [Apply fix, re-check gate]

---

[Continue for all steps...]

---

## Final Gate: Complete Validation

**Completeness Checks**:
- [ ] All requirements addressed
- [ ] No TODO/placeholders remaining
- [ ] All edge cases handled
- [ ] All error cases handled

**Correctness Checks**:
- [ ] Logic verified
- [ ] Types/interfaces correct
- [ ] Integration points working
- [ ] Tests passing (if applicable)

**Result**: [PASS/FAIL]

---

## Delivery

[Final output to user]
```

---

## Gate Types

### Hard Gates
Must pass before proceeding. Failure blocks progress.

```markdown
### Gate X: [Name] (HARD)

This gate is HARD - cannot proceed without passing.

- [ ] [Critical check 1]
- [ ] [Critical check 2]

If blocked: Resolve before continuing.
```

### Soft Gates
Should pass, but can proceed with documented technical debt.

```markdown
### Gate X: [Name] (SOFT)

This gate is SOFT - can proceed with noted issues.

- [ ] [Check 1]
- [ ] [Check 2]

If issues: Document and continue, but flag for future.

**Documented Issues**:
- [Issue 1]: Will address in [when/how]
```

---

## Gate Failure Protocol

When a gate fails:

1. **Identify Root Cause**
   - What specific check failed?
   - Why did it fail?

2. **Determine Remediation**
   - What needs to change?
   - Does this affect previous steps?

3. **Apply Fix**
   - Make the necessary changes
   - If previous steps affected, backtrack

4. **Re-verify**
   - Run gate checks again
   - Ensure fix didn't break other checks

5. **Document**
   - Note what failed and how it was fixed
   - Update approach if systemic issue

---

## When to Apply

### Good Fit
- Feature implementation with clear steps
- Tasks where order matters
- When intermediate validation is valuable
- Complex implementations with dependencies

### Poor Fit
- Exploratory tasks
- When steps are highly interdependent
- Simple single-step tasks

---

## Quality Checks for Sequential Pattern

- [ ] Steps are in logical order?
- [ ] Each step has clear deliverable?
- [ ] Gates check the right things?
- [ ] Remediation paths are clear?
- [ ] No steps skipped?

---

## Example Application

**Task**: Add user authentication feature

```markdown
## Step 1: Design Data Model

### Execution
- Define User model with fields
- Define Session/Token model
- Define relationships

### Output
```python
class User:
    id: UUID
    email: str
    password_hash: str
    created_at: datetime
```

### Gate 1: Data Model Valid?
- [x] All required fields present
- [x] Types appropriate
- [x] Security considerations (no plain password)
- [x] Indexes planned for query patterns

**Result**: PASS

---

## Step 2: Implement Registration

### Execution
- Create registration endpoint
- Implement validation
- Implement password hashing
- Store user

### Output
[Registration endpoint code]

### Gate 2: Registration Works?
- [x] Validates email format
- [x] Validates password strength
- [x] Hashes password securely
- [x] Returns appropriate responses
- [x] Handles duplicate email

**Result**: PASS

---

## Step 3: Implement Login

[Continue pattern...]
```
