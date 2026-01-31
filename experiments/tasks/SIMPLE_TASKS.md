# Simple Tasks (Level 1)

## Task Selection Criteria
- Single file modification
- <10 lines of code
- Obvious solution
- No architectural decisions

---

## Task S1: Fix String Typo

**Requirement**: Find and fix a typo in a user-facing string.

**Prompt (Control)**:
```
quick: Fix the typo "recieve" -> "receive" in the error messages
```

**Prompt (PP)**:
```
pp: Fix the typo "recieve" -> "receive" in the error messages
```

**Success Criteria**:
- [ ] Typo fixed
- [ ] No other changes
- [ ] Correct file identified

**Assessment Focus**: Does PP add overhead without benefit?

---

## Task S2: Add Null Check

**Requirement**: Add a null/undefined check to prevent a crash.

**Prompt (Control)**:
```
quick: Add a null check for user.email before accessing it in the sendEmail function
```

**Prompt (PP)**:
```
pp: Add a null check for user.email before accessing it in the sendEmail function
```

**Success Criteria**:
- [ ] Null check added
- [ ] Handles edge case correctly
- [ ] Consistent with existing null checks in codebase

**Assessment Focus**: Does PP notice existing patterns for null checks?

---

## Task S3: Add Console Log for Debugging

**Requirement**: Add a debug log statement.

**Prompt (Control)**:
```
quick: Add a console.log to show the API response in the fetchData function
```

**Prompt (PP)**:
```
pp: Add a console.log to show the API response in the fetchData function
```

**Success Criteria**:
- [ ] Log added in correct location
- [ ] Useful log message
- [ ] Matches existing log style

**Assessment Focus**: Pure overhead test - simplest possible task.

---

## Scoring Notes for Simple Tasks

**Expected Control Score**: 10-12/12 (should do well on simple tasks)
**Expected PP Score**: 9-12/12 (may lose points for overhead)

**Key Question**: Is PP overhead justified for simple tasks?

If PP scores lower due to:
- Taking longer for same result → Overhead not justified
- Over-engineering → PP miscalibrated for simple tasks

If PP scores same or higher:
- Notices patterns Control missed → PP adds value even here
- Better placement → PP helps even simple tasks
