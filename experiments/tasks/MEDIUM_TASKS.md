# Medium Tasks (Level 2)

## Task Selection Criteria
- 2-5 files modified
- 10-100 lines of code
- Requires following existing patterns
- Minor design decisions

---

## Task M1: Add New API Endpoint

**Requirement**: Add a new endpoint following existing patterns.

**Prompt (Control)**:
```
quick: Add a GET /api/users/:id/preferences endpoint that returns user preferences from the database
```

**Prompt (PP)**:
```
pp: Add a GET /api/users/:id/preferences endpoint that returns user preferences from the database
```

**Success Criteria**:
- [ ] Endpoint works correctly
- [ ] Follows existing route patterns
- [ ] Follows existing controller patterns
- [ ] Error handling consistent
- [ ] Response format matches other endpoints

**Assessment Focus**: Does PP ensure pattern conformance better?

**What to Look For**:
- Control: May create endpoint that works but doesn't match style
- PP: Should examine existing endpoints first, match patterns

---

## Task M2: Add Form Validation

**Requirement**: Add validation to an existing form.

**Prompt (Control)**:
```
quick: Add validation to the registration form: email must be valid format, password minimum 8 characters with one number
```

**Prompt (PP)**:
```
pp: Add validation to the registration form: email must be valid format, password minimum 8 characters with one number
```

**Success Criteria**:
- [ ] Validation works correctly
- [ ] Error messages match existing style
- [ ] Validation placed in correct layer (client/server/both)
- [ ] Uses existing validation utilities if present
- [ ] Consistent with other forms in app

**Assessment Focus**: Does PP identify existing validation patterns?

**What to Look For**:
- Control: May implement custom validation, miss existing utilities
- PP: Should find and reuse existing validation approach

---

## Task M3: Add Feature Flag

**Requirement**: Add a feature flag to control a new feature.

**Prompt (Control)**:
```
quick: Add a feature flag "enableNewDashboard" that shows the new dashboard when enabled, falls back to old one when disabled
```

**Prompt (PP)**:
```
pp: Add a feature flag "enableNewDashboard" that shows the new dashboard when enabled, falls back to old one when disabled
```

**Success Criteria**:
- [ ] Flag works correctly
- [ ] Uses existing feature flag system if present
- [ ] Flag defined in correct location
- [ ] Toggle logic in correct place
- [ ] Fallback works properly

**Assessment Focus**: Does PP find the right location for flag definition?

**What to Look For**:
- Control: May create ad-hoc flag mechanism
- PP: Should identify existing flag system and integrate

---

## Scoring Notes for Medium Tasks

**Expected Control Score**: 6-9/12 (may miss patterns, placement issues)
**Expected PP Score**: 9-11/12 (better pattern matching, placement)

**Key Question**: Does PP's understanding phase pay off?

Metrics to Watch:
- UNDERSTANDING: Did it map existing patterns before implementing?
- BEAUTY: Does new code match existing style?
- JUSTICE: Is code in the right files/layers?

**PP Advantage Indicators**:
- PP reads existing similar code first
- PP matches patterns exactly
- PP places code in established locations
- PP reuses existing utilities

**Control Weakness Indicators**:
- Creates working but inconsistent code
- Misses existing utilities to reuse
- Places code in convenient but wrong location
