# Complex Tasks (Level 3)

## Task Selection Criteria
- 5+ files modified or new structure
- 100+ lines of code
- Architectural decisions required
- May need new patterns (uncharted territory)
- Significant design choices

---

## Task C1: Implement Caching Layer

**Requirement**: Add caching to reduce database load.

**Prompt (Control)**:
```
quick: Implement a caching layer for the user service - cache user data with 5 minute TTL, invalidate on update
```

**Prompt (PP)**:
```
pp: Implement a caching layer for the user service - cache user data with 5 minute TTL, invalidate on update
```

**Success Criteria**:
- [ ] Caching works correctly
- [ ] TTL implemented properly
- [ ] Invalidation on update works
- [ ] Cache layer is properly abstracted
- [ ] Doesn't break existing functionality
- [ ] Follows existing service patterns
- [ ] Cache configuration is externalized
- [ ] Error handling (cache miss, cache failure)

**Assessment Focus**: Does PP design proper architecture?

**What to Look For**:
- Control: May add caching inline, create tight coupling
- PP: Should design proper cache abstraction layer

**Complexity Factors**:
- Where should cache live? (service layer? repository layer?)
- How to handle cache failures gracefully?
- How to make cache configurable?
- How to test caching logic?

---

## Task C2: Add Authentication to API

**Requirement**: Secure existing API endpoints with authentication.

**Prompt (Control)**:
```
quick: Add JWT authentication to the API - protect all /api/* routes except /api/auth/login and /api/auth/register
```

**Prompt (PP)**:
```
pp: Add JWT authentication to the API - protect all /api/* routes except /api/auth/login and /api/auth/register
```

**Success Criteria**:
- [ ] JWT implementation is secure
- [ ] Protected routes require valid token
- [ ] Public routes work without token
- [ ] Token refresh mechanism
- [ ] Proper error responses (401, 403)
- [ ] Auth middleware properly placed
- [ ] User context available in protected routes
- [ ] Follows security best practices

**Assessment Focus**: Does PP consider security and placement?

**What to Look For**:
- Control: May implement working but insecure auth
- PP: Should consider security implications, proper middleware placement

**Complexity Factors**:
- Where to store JWT secret?
- How to handle token expiration?
- Where should auth middleware live?
- How to make routes declaratively public/private?

---

## Task C3: Refactor Module to New Pattern

**Requirement**: Refactor existing code to follow a better pattern.

**Prompt (Control)**:
```
quick: Refactor the notification system from callbacks to async/await, maintaining all existing functionality and tests
```

**Prompt (PP)**:
```
pp: Refactor the notification system from callbacks to async/await, maintaining all existing functionality and tests
```

**Success Criteria**:
- [ ] All callbacks converted to async/await
- [ ] All existing tests still pass
- [ ] No functionality regression
- [ ] Error handling preserved/improved
- [ ] Code is cleaner after refactor
- [ ] No mixed patterns (all async or all callback)
- [ ] Dependent code updated appropriately

**Assessment Focus**: Does PP maintain system integrity during refactor?

**What to Look For**:
- Control: May refactor partially, leave mixed patterns
- PP: Should map all dependencies, ensure complete refactor

**Complexity Factors**:
- What depends on this module?
- Are there edge cases in error handling?
- How to refactor incrementally without breaking?
- What tests need updating?

---

## Scoring Notes for Complex Tasks

**Expected Control Score**: 4-7/12 (likely architectural issues)
**Expected PP Score**: 8-11/12 (should handle complexity better)

**Key Question**: Does PP prevent architectural mistakes?

Metrics to Watch:
- UNDERSTANDING: Did it map the full scope?
- JUSTICE: Is new code properly placed in architecture?
- CREATIVITY: Did it build appropriate new structures?
- TASK SUCCESS: Is the solution complete and working?

**PP Advantage Indicators**:
- PP maps dependencies before changing
- PP considers failure modes
- PP creates proper abstractions
- PP maintains architectural integrity
- PP builds testable solutions

**Control Weakness Indicators**:
- Partial implementation
- Tight coupling introduced
- Mixed patterns
- Missing error handling
- Architectural violations

---

## Uncharted Territory Test

Complex Task C1 (caching) may be "uncharted" if:
- No existing caching pattern in codebase
- New infrastructure needed

**PP Should**:
1. Recognize this is uncharted territory
2. Build appropriate new structure first
3. Then implement feature on new structure

**Control Likely**:
1. Try to force caching into existing code
2. Create ad-hoc solution
3. Technical debt introduced
