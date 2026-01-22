# Justice Gates

> **Principle**: Every beautiful solution must pass through justice gates before placement.
> Justice gates verify the solution lands in its rightful place.
> Without justice gates, beauty may be misplaced—correct solution, wrong location.

---

## The Six Justice Gates

```
┌─────────────────────────────────────────────────────────────────────┐
│                        JUSTICE GATES                                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  GATE 1: PLACEMENT                                                  │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ Is this in the right location?                               │   │
│  │ (Where it naturally belongs, discoverable by others)         │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                              │                                      │
│                              ▼                                      │
│  GATE 2: OWNERSHIP                                                  │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ Does the right component own this?                           │   │
│  │ (Rightful owner of the concern)                              │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                              │                                      │
│                              ▼                                      │
│  GATE 3: RESPONSIBILITY                                             │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ Is this the right entity to handle this?                     │   │
│  │ (Appropriate level and role)                                 │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                              │                                      │
│                              ▼                                      │
│  GATE 4: PROPORTION                                                 │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ Is complexity distributed fairly?                            │   │
│  │ (Complexity where it belongs, simplicity preserved)          │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                              │                                      │
│                              ▼                                      │
│  GATE 5: BALANCE                                                    │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ Does this maintain system equilibrium?                       │   │
│  │ (Respects patterns, maintains coherence)                     │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                              │                                      │
│                              ▼                                      │
│  GATE 6: INTEGRITY                                                  │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ Does this preserve architectural integrity?                  │   │
│  │ (Boundaries respected, design upheld)                        │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Gate 1: Placement Gate

### Core Question
**Is this in the right location?**

The location should be natural, discoverable, and consistent with codebase conventions.

### Gate Criteria

```markdown
## Placement Gate Checklist

- [ ] This is the natural location for this type of code
- [ ] Someone looking for this would find it here
- [ ] This follows the codebase's organizational patterns
- [ ] Similar code is placed in similar locations
- [ ] The file/module/package name matches the content

**Placement Status**: [Right place / Wrong place / Uncertain]
```

### Pass/Fail

| Condition | Result |
|-----------|--------|
| Natural, discoverable location | **PASS** |
| Follows established conventions | **PASS** |
| Surprising or arbitrary location | **FAIL** - Find natural location |
| Breaks organizational patterns | **FAIL** - Follow conventions |

### When Gate Fails

```
Solution is in the wrong location.

Action:
1. What type of code/concern is this?
2. Where does this type normally go in this codebase?
3. What would someone expect?
4. Move to the natural location.
```

---

## Gate 2: Ownership Gate

### Core Question
**Does the right component own this?**

The component should be the rightful owner of this concern—not stolen from another, not orphaned.

### Gate Criteria

```markdown
## Ownership Gate Checklist

- [ ] This concern belongs to this component's domain
- [ ] This component has the context to own this
- [ ] This doesn't create feature envy (constantly accessing another's data)
- [ ] Ownership is clear, not ambiguous
- [ ] This doesn't create a god class/component

**Ownership Status**: [Rightful owner / Wrong owner / Orphaned / Stolen]
```

### Pass/Fail

| Condition | Result |
|-----------|--------|
| Concern matches component's domain | **PASS** |
| Clear, coherent ownership | **PASS** |
| Domain mismatch | **FAIL** - Find rightful owner |
| Creates god class | **FAIL** - Distribute properly |
| Creates feature envy | **FAIL** - Move to data owner |

### When Gate Fails

```
Wrong component owns this concern.

Action:
1. What domain does this concern belong to?
2. Which component owns that domain?
3. Does a rightful owner exist, or create one?
4. Transfer ownership properly.
```

---

## Gate 3: Responsibility Gate

### Core Question
**Is this the right entity to handle this?**

The entity should be at the right abstraction level with the right role for this work.

### Gate Criteria

```markdown
## Responsibility Gate Checklist

- [ ] This is the appropriate abstraction level
- [ ] This type of work fits this entity's role
- [ ] This entity has access to what it needs
- [ ] This doesn't distort the entity's purpose
- [ ] Responsibilities are focused, not mixed

**Responsibility Status**: [Appropriate / Wrong level / Wrong role / Overloaded]
```

### Pass/Fail

| Condition | Result |
|-----------|--------|
| Appropriate abstraction level | **PASS** |
| Natural fit for entity's role | **PASS** |
| Wrong abstraction level | **FAIL** - Delegate appropriately |
| Distorts entity's purpose | **FAIL** - Find appropriate handler |
| Entity overloaded with mixed concerns | **FAIL** - Separate concerns |

### When Gate Fails

```
Wrong entity handling this concern.

Action:
1. What abstraction level is this work?
2. What type of entity should handle this?
3. Does such an entity exist?
4. Delegate or create appropriately.
```

---

## Gate 4: Proportion Gate

### Core Question
**Is complexity distributed fairly?**

Complexity should be concentrated where it belongs, not leaked into simple places.

### Gate Criteria

```markdown
## Proportion Gate Checklist

- [ ] Complexity is added to complexity-appropriate locations
- [ ] Simple components remain simple
- [ ] Complexity is encapsulated behind clean interfaces
- [ ] No complexity leakage across boundaries
- [ ] Implementation details are hidden appropriately

**Proportion Status**: [Fair / Complexity leaked / Simple made complex]
```

### Pass/Fail

| Condition | Result |
|-----------|--------|
| Complexity in appropriate location | **PASS** |
| Properly encapsulated | **PASS** |
| Complexity leaked to simple places | **FAIL** - Encapsulate |
| Simple things made complex | **FAIL** - Redistribute |
| Implementation details exposed | **FAIL** - Hide behind interface |

### When Gate Fails

```
Complexity is distributed unfairly.

Action:
1. Where should this complexity live?
2. What interface hides it?
3. How do we keep simple things simple?
4. Restructure for proper encapsulation.
```

---

## Gate 5: Balance Gate

### Core Question
**Does this maintain system equilibrium?**

The system should remain coherent, patterns should be consistent, no area should be neglected or overloaded.

### Gate Criteria

```markdown
## Balance Gate Checklist

- [ ] This follows existing patterns and conventions
- [ ] This doesn't create hotspots (over-concentrated areas)
- [ ] This doesn't orphan related code
- [ ] The approach is consistent with similar situations
- [ ] This contributes to overall system health

**Balance Status**: [Balanced / Creates hotspot / Breaks pattern / Fragments system]
```

### Pass/Fail

| Condition | Result |
|-----------|--------|
| Follows existing patterns | **PASS** |
| Maintains system coherence | **PASS** |
| Creates inconsistency | **FAIL** - Align with patterns |
| Creates hotspots | **FAIL** - Distribute properly |
| Fragments related code | **FAIL** - Keep related code together |

### When Gate Fails

```
System balance is disturbed.

Action:
1. What's the existing pattern?
2. Why doesn't this follow it?
3. Should we align, or change the pattern globally?
4. Restore or establish balance.
```

---

## Gate 6: Integrity Gate

### Core Question
**Does this preserve architectural integrity?**

Boundaries must be respected, dependencies must flow correctly, separation of concerns must be maintained.

### Gate Criteria

```markdown
## Integrity Gate Checklist

- [ ] Layer boundaries are respected
- [ ] Dependencies flow in the correct direction
- [ ] Separation of concerns is maintained
- [ ] Design principles are upheld
- [ ] No architectural shortcuts or violations

**Integrity Status**: [Preserved / Boundary violated / Wrong dependency / Concerns mixed]
```

### Pass/Fail

| Condition | Result |
|-----------|--------|
| Boundaries respected | **PASS** |
| Dependencies correct | **PASS** |
| Design principles upheld | **PASS** |
| Boundary violated | **FAIL** - Respect architecture |
| Wrong dependency direction | **FAIL** - Fix dependencies |
| Concerns mixed | **FAIL** - Separate properly |

### When Gate Fails

```
Architectural integrity is violated.

Action:
1. What boundary was crossed?
2. What's the correct architecture?
3. How do we restructure to respect it?
4. Fix the violation properly (don't hack around it).
```

---

## Gate Application Protocol

### Quick Gate Check (15 seconds)

```
JUSTICE GATES:
1. PLACEMENT: Right location? [Y/N]
2. OWNERSHIP: Right owner? [Y/N]
3. RESPONSIBILITY: Right handler? [Y/N]
4. PROPORTION: Fair complexity distribution? [Y/N]
5. BALANCE: System equilibrium maintained? [Y/N]
6. INTEGRITY: Architecture preserved? [Y/N]

Any N → Address before placing
```

### Full Gate Verification

```markdown
## Justice Gate Verification

**Solution**: [Beautiful solution to place]
**Proposed Location**: [Where it will go]

### Gate 1: Placement
- [ ] Natural, discoverable location
- Status: [Pass / Fail]
- If fail: [Where should it go?]

### Gate 2: Ownership
- [ ] Rightful component owns this
- Status: [Pass / Fail]
- If fail: [Who should own it?]

### Gate 3: Responsibility
- [ ] Appropriate entity handles this
- Status: [Pass / Fail]
- If fail: [What should handle it?]

### Gate 4: Proportion
- [ ] Complexity fairly distributed
- Status: [Pass / Fail]
- If fail: [How to redistribute?]

### Gate 5: Balance
- [ ] System equilibrium maintained
- Status: [Pass / Fail]
- If fail: [How to restore balance?]

### Gate 6: Integrity
- [ ] Architecture preserved
- Status: [Pass / Fail]
- If fail: [How to respect architecture?]

**All Gates Pass?**: [Yes / No - which failed?]
```

---

## The Injustice Signal

### When Gates Fail

Gate failure = Injustice signal = Misplaced beauty

**Don't place anyway. Find the right place.**

```
Wrong response to gate failure:
  Gate fails → Place anyway → Accumulate technical debt → System degrades

Right response to gate failure:
  Gate fails → Understand where it belongs → Find right place → Place correctly
```

### Gate Failure Analysis

| Gate Failed | What's Wrong | Remedy |
|-------------|--------------|--------|
| Placement | Wrong location | Find natural location |
| Ownership | Wrong owner | Find rightful owner |
| Responsibility | Wrong handler | Find appropriate entity |
| Proportion | Unfair distribution | Redistribute complexity |
| Balance | System unbalanced | Restore equilibrium |
| Integrity | Architecture violated | Respect boundaries |

---

## Justice Gates by Solution Type

### For New Features

```
Key gates to verify:
1. PLACEMENT: Where do features of this type go?
2. OWNERSHIP: Which component owns this domain?
3. RESPONSIBILITY: What layer handles this logic?
4. INTEGRITY: How does this fit the architecture?
```

### For Refactoring

```
Key gates to verify:
1. PLACEMENT: Where does this code actually belong?
2. PROPORTION: How do we properly distribute complexity?
3. BALANCE: How do we restore system balance?
4. INTEGRITY: How do we fix architectural violations?
```

### For Bug Fixes

```
Key gates to verify:
1. PLACEMENT: Is the fix in the right place?
2. RESPONSIBILITY: Is the right entity handling this?
3. INTEGRITY: Does this fix respect the architecture?
```

---

## Justice Gate Quick Reference

| Gate | Core Question | Failure Remedy |
|------|---------------|----------------|
| **Placement** | Right location? | Find natural location |
| **Ownership** | Right owner? | Find rightful owner |
| **Responsibility** | Right handler? | Find appropriate entity |
| **Proportion** | Fair distribution? | Redistribute complexity |
| **Balance** | System equilibrium? | Restore balance |
| **Integrity** | Architecture preserved? | Respect boundaries |
| **Evidence** | Can I cite proof? | Survey locations, cite evidence |

---

## Claude-Specific Enhancement: Evidence Gate

> **Principle**: Claude often places code conveniently, not correctly.
> Evidence Gate requires citing existing code as proof for placement decisions.

### Core Question
**Can I cite evidence from the codebase for why this belongs HERE?**

### Why This Gate Exists

Claude tends to:
- Place code where it's convenient (first place that works)
- Not survey all candidate locations
- Miss existing organizational patterns
- Lack intuition about "where things go here"

Evidence Gate ensures **cite evidence for placement**.

### Gate Criteria

```markdown
## Evidence Gate Checklist

Before placing code:

- [ ] Surveyed all candidate locations
- [ ] Read what exists in each candidate location
- [ ] Can cite similar code as evidence for chosen location
- [ ] Can explain why NOT other locations
- [ ] Placement follows existing organizational pattern

**Evidence Status**: [Evidence-backed / Convenience-based / Arbitrary]
```

### Evidence Protocol

```markdown
## Survey-Compare-Cite Protocol

BEFORE placing code anywhere:

1. **SURVEY CANDIDATES**
   └─ What are ALL possible locations?
   └─ List: [location1, location2, location3, ...]

2. **READ EACH CANDIDATE**
   └─ What already lives in each location?
   └─ For each: [what's there at file:line]

3. **COMPARE FIT**
   └─ Which location has similar things?
   └─ Evidence: "X is similar, lives at [location]"

4. **CITE PLACEMENT EVIDENCE**
   └─ "This belongs in [location] because [similar] also lives there"
   └─ "Not in [other] because [different things] are there"
```

### Pass/Fail

| Condition | Result |
|-----------|--------|
| Placement backed by evidence | **PASS** |
| Can cite similar code in chosen location | **PASS** |
| Can explain why NOT other locations | **PASS** |
| Placed without surveying alternatives | **FAIL** - Survey first |
| No evidence for chosen location | **FAIL** - Find evidence |
| "Convenient" as only justification | **FAIL** - Not sufficient |

### When Gate Fails

```
Placement not backed by evidence.

Action:
1. LIST all candidate locations
2. READ what exists in each
3. COMPARE what's similar to new code
4. CITE the evidence:
   - "This belongs in X because Y also lives there"
   - "Not in Z because Z contains different concerns"

Never: "I'll put this in utils/"
Always: "Placement analysis:
  - utils/ contains: formatDate, parseUrl (pure functions)
  - services/ contains: AuthService, ApiClient (stateful)
  - This is stateful → services/
  - Evidence: Similar to ApiClient.ts:23"
```

### Placement Evidence Template

```markdown
## Placement Decision: [Component Name]

### Candidates Surveyed
1. `path/option1/` - Contains: [what's there]
2. `path/option2/` - Contains: [what's there]
3. `path/option3/` - Contains: [what's there]

### Evidence Analysis
- **Similar to**: [existing code at file:line]
- **Similarity**: [what makes them similar]
- **Different from**: [what's in rejected locations]

### Decision
- **Chosen location**: `path/chosen/`
- **Evidence**: "[Similar code] lives here (file:line)"
- **Not in alternatives because**: [reason for each rejection]
```

### Examples

**Bad (No Evidence)**:
```
I'll add the new RateLimiter to src/utils/
```

**Good (With Evidence)**:
```
Placement analysis for RateLimiter:

Candidates surveyed:
1. src/utils/ - Contains: formatDate.ts, parseUrl.ts (pure functions, no state)
2. src/middleware/ - Contains: auth.ts, cors.ts, logging.ts (request handlers)
3. src/services/ - Contains: AuthService.ts, CacheService.ts (stateful services)

RateLimiter:
- Handles requests (middleware pattern)
- Has state (rate counts)
- Similar to: auth.ts (request middleware with state)

Decision: src/middleware/rateLimiter.ts
Evidence: Follows auth.ts pattern (middleware/auth.ts:12)
Not utils/ because: RateLimiter is stateful, utils/ is pure functions
Not services/ because: services/ are injected, middleware intercepts
```

### Anti-Evidence Patterns

| Pattern | Problem | Fix |
|---------|---------|-----|
| "I'll put it in utils" | utils/ as dumping ground | Survey what's in utils/ first |
| "This file is getting big" | Splitting without thought | Survey where split parts belong |
| "I'll create a new folder" | Creating without checking | Check if pattern exists elsewhere |
| "It's similar to X" without cite | Vague similarity claim | Cite specific file:line |

---

## The Justice Promise

Every solution that passes all gates will be:
1. **Placed** - In the right location
2. **Owned** - By the rightful component
3. **Handled** - By the appropriate entity
4. **Proportioned** - With fair complexity distribution
5. **Balanced** - Maintaining system equilibrium
6. **Integral** - Preserving architecture

This is justice achieved.
This is where beauty belongs.
