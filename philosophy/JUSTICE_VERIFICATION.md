# Justice Verification Protocol

> **Axiom**: Justice is bringing beauty to where it belongs.
> Verification ensures the beautiful solution lands in its rightful place.
> Without justice verification, beauty may be misplaced—correct solution, wrong location.

---

## The Justice Verification Chain

```
┌─────────────────────────────────────────────────────────────────────┐
│                  JUSTICE VERIFICATION CHAIN                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  [Beautiful Solution Ready to Place]                                │
│        │                                                             │
│        ▼                                                             │
│  ┌─────────────┐                                                    │
│  │ PLACEMENT   │  Is this in the right location?                    │
│  │   CHECK     │  Would someone expect to find it here?             │
│  └──────┬──────┘                                                    │
│         │                                                            │
│         ▼                                                            │
│  ┌─────────────┐                                                    │
│  │ OWNERSHIP   │  Does the right component own this?                │
│  │   CHECK     │  Is this the rightful owner of this concern?       │
│  └──────┬──────┘                                                    │
│         │                                                            │
│         ▼                                                            │
│  ┌─────────────┐                                                    │
│  │RESPONSIBILITY│  Is this the right entity to handle this?         │
│  │   CHECK     │  Does the abstraction level match?                 │
│  └──────┬──────┘                                                    │
│         │                                                            │
│         ▼                                                            │
│  ┌─────────────┐                                                    │
│  │ PROPORTION  │  Is complexity distributed fairly?                 │
│  │   CHECK     │  Are we adding complexity to the right place?      │
│  └──────┬──────┘                                                    │
│         │                                                            │
│         ▼                                                            │
│  ┌─────────────┐                                                    │
│  │  BALANCE    │  Does this maintain system equilibrium?            │
│  │   CHECK     │  Does this respect existing patterns?              │
│  └──────┬──────┘                                                    │
│         │                                                            │
│         ▼                                                            │
│  ┌─────────────┐                                                    │
│  │ INTEGRITY   │  Does this preserve architectural integrity?       │
│  │   CHECK     │  Are boundaries respected?                         │
│  └─────────────┘                                                    │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Step 1: Placement Check

### The Core Question
**Is this in the right location?**

### Verification Questions

```markdown
**Solution**: [What I'm placing]
**Proposed Location**: [Where I plan to put it]

**Placement Check**:
1. Is this the natural location for this type of code? [Yes / No]
2. Would someone looking for this find it here? [Yes / No]
3. Does this follow the codebase's organizational conventions? [Yes / No]
4. Is this consistent with where similar things are placed? [Yes / No]

**Placement Indicators**:
- [ ] Location matches the concern type (UI/domain/data/etc.)
- [ ] Location follows established patterns in this codebase
- [ ] Someone unfamiliar could predict this location
- [ ] This doesn't require explaining why it's here
```

### Right Location vs. Wrong Location

| Right Location | Wrong Location |
|----------------|----------------|
| Follows codebase conventions | Breaks from established patterns |
| Discoverable by others | Hidden or surprising |
| Near related code | Far from related code |
| Matches concern type | Mixed with unrelated concerns |

### Pass/Fail

| Condition | Result |
|-----------|--------|
| Natural, discoverable location | **PASS** |
| Follows established patterns | **PASS** |
| Arbitrary or surprising location | **FAIL** - Find right location |
| Breaks from codebase conventions | **FAIL** - Follow patterns |

---

## Step 2: Ownership Check

### The Core Question
**Does the right component own this?**

### Verification Questions

```markdown
**Solution**: [What I'm placing]
**Proposed Owner**: [Which component/module will own this]

**Ownership Check**:
1. Is this concern part of this component's domain? [Yes / No]
2. Does this component have the context needed to own this? [Yes / No]
3. Would this concern be orphaned elsewhere or stolen here? [Yes / No]
4. Is ownership coherent with the component's stated purpose? [Yes / No]

**Ownership Indicators**:
- [ ] Concern falls within component's domain
- [ ] Component has related data/logic to support this
- [ ] This doesn't create feature envy
- [ ] Ownership is clear, not ambiguous
```

### Rightful Owner vs. Wrong Owner

| Rightful Owner | Wrong Owner |
|----------------|-------------|
| Domain matches the concern | Domain mismatch |
| Has context and related data | Lacks necessary context |
| Coherent responsibility expansion | Bloated with unrelated concerns |
| Clear ownership boundary | Ambiguous ownership |

### Pass/Fail

| Condition | Result |
|-----------|--------|
| Concern matches component's domain | **PASS** |
| Coherent with existing responsibilities | **PASS** |
| Domain mismatch | **FAIL** - Find rightful owner |
| Creates god class/component | **FAIL** - Distribute properly |

---

## Step 3: Responsibility Check

### The Core Question
**Is this the right entity to handle this concern?**

### Verification Questions

```markdown
**Solution**: [What I'm placing]
**Proposed Handler**: [Which layer/entity will handle this]

**Responsibility Check**:
1. Is this the appropriate abstraction level? [Yes / No]
2. Does this entity have the right to handle this type of work? [Yes / No]
3. Does this entity have what it needs to fulfill this responsibility? [Yes / No]
4. Would handling this distort this entity's purpose? [Yes / No]

**Responsibility Indicators**:
- [ ] Abstraction level matches (high-level handles high-level, etc.)
- [ ] Entity's role naturally includes this type of work
- [ ] Entity has access to necessary dependencies
- [ ] This doesn't burden entity with inappropriate work
```

### Appropriate vs. Inappropriate Responsibility

| Appropriate | Inappropriate |
|-------------|---------------|
| Matches abstraction level | Wrong level (low in high, high in low) |
| Natural extension of role | Distorts entity's purpose |
| Has necessary context | Missing required dependencies |
| Focused responsibility | Mixed, incoherent responsibilities |

### Pass/Fail

| Condition | Result |
|-----------|--------|
| Appropriate abstraction level | **PASS** |
| Natural fit for entity's role | **PASS** |
| Wrong abstraction level | **FAIL** - Delegate appropriately |
| Distorts entity's purpose | **FAIL** - Find appropriate handler |

---

## Step 4: Proportion Check

### The Core Question
**Is complexity distributed fairly?**

### Verification Questions

```markdown
**Solution**: [What I'm placing]
**Complexity Level**: [How complex is this]
**Destination**: [Where it's going]

**Proportion Check**:
1. Is complexity being added to the right place? [Yes / No]
2. Does this maintain simplicity where simplicity belongs? [Yes / No]
3. Is complexity appropriately encapsulated? [Yes / No]
4. Does this avoid leaking complexity to wrong places? [Yes / No]

**Proportion Indicators**:
- [ ] Complex things are in complexity-appropriate locations
- [ ] Simple components remain simple
- [ ] Complexity is hidden behind clean interfaces
- [ ] No complexity leakage across boundaries
```

### Fair Distribution vs. Unfair Distribution

| Fair Distribution | Unfair Distribution |
|-------------------|---------------------|
| Complexity concentrated appropriately | Complexity scattered randomly |
| Simple layers remain simple | Simple things made complex |
| Clear complexity boundaries | Complexity leaked everywhere |
| Encapsulated behind interfaces | Implementation details exposed |

### Pass/Fail

| Condition | Result |
|-----------|--------|
| Complexity in appropriate location | **PASS** |
| Properly encapsulated | **PASS** |
| Complexity leaked to wrong places | **FAIL** - Encapsulate properly |
| Simple things made complex | **FAIL** - Redistribute complexity |

---

## Step 5: Balance Check

### The Core Question
**Does this maintain system equilibrium?**

### Verification Questions

```markdown
**Solution**: [What I'm placing]
**System Impact**: [How this affects the overall system]

**Balance Check**:
1. Does this respect existing patterns and conventions? [Yes / No]
2. Does this avoid creating hotspots or neglected areas? [Yes / No]
3. Is this consistent with how similar things are handled? [Yes / No]
4. Does this contribute to overall system health? [Yes / No]

**Balance Indicators**:
- [ ] Follows established conventions
- [ ] Doesn't create over-concentrated areas
- [ ] Doesn't orphan related code
- [ ] Maintains architectural consistency
```

### Balanced vs. Unbalanced

| Balanced | Unbalanced |
|----------|------------|
| Follows existing patterns | Introduces inconsistent patterns |
| Work distributed appropriately | Creates hotspots |
| Maintains convention consistency | Breaks conventions without reason |
| System remains coherent | System becomes fragmented |

### Pass/Fail

| Condition | Result |
|-----------|--------|
| Respects existing patterns | **PASS** |
| Maintains system coherence | **PASS** |
| Creates inconsistency | **FAIL** - Align with patterns |
| Unbalances the system | **FAIL** - Redistribute |

---

## Step 6: Integrity Check

### The Core Question
**Does this preserve architectural integrity?**

### Verification Questions

```markdown
**Solution**: [What I'm placing]
**Architectural Impact**: [How this affects architecture]

**Integrity Check**:
1. Does this respect layer boundaries? [Yes / No]
2. Does this follow dependency rules? [Yes / No]
3. Does this maintain separation of concerns? [Yes / No]
4. Does this align with design principles? [Yes / No]

**Integrity Indicators**:
- [ ] Layer boundaries not violated
- [ ] Dependencies flow correctly
- [ ] Concerns properly separated
- [ ] Design principles upheld
```

### Preserved Integrity vs. Violated Integrity

| Preserved | Violated |
|-----------|----------|
| Boundaries respected | Boundaries crossed |
| Dependencies correct | Circular or wrong dependencies |
| Concerns separated | Concerns mixed |
| Design principles upheld | Design principles ignored |

### Pass/Fail

| Condition | Result |
|-----------|--------|
| Boundaries respected | **PASS** |
| Dependencies correct | **PASS** |
| Boundaries violated | **FAIL** - Respect architecture |
| Wrong dependencies introduced | **FAIL** - Fix dependency direction |

---

## Quick Justice Verification

### The 20-Second Justice Check

```
1. PLACEMENT: Is this in the right location? [Y/N]
2. OWNERSHIP: Does the right component own this? [Y/N]
3. RESPONSIBILITY: Is this the right handler? [Y/N]
4. PROPORTION: Is complexity distributed fairly? [Y/N]
5. BALANCE: Does this maintain system equilibrium? [Y/N]
6. INTEGRITY: Does this preserve architecture? [Y/N]

Any N → Find the right place before placing
```

### The Quick Justice Questions

For rapid verification:

1. **Would someone expect to find this here?** (Placement)
2. **Does this component rightfully own this?** (Ownership)
3. **Should this entity handle this type of work?** (Responsibility)
4. **Are we putting complexity in the right place?** (Proportion)
5. **Does this fit the existing patterns?** (Balance)
6. **Does this respect the architecture?** (Integrity)

---

## The Injustice Signal

### When Justice Verification Reveals Problems

**Injustice signals misplaced beauty or misunderstood structure.**

```
Signs of injustice:
- "This doesn't belong here" → Placement failed
- "This isn't our concern" → Ownership failed
- "This level shouldn't do this" → Responsibility failed
- "This is too complex for this place" → Proportion failed
- "This breaks our pattern" → Balance failed
- "This violates the architecture" → Integrity failed
```

### The Right Response to Injustice

```
Wrong response:
  Injustice detected → Place it anyway → Accumulate technical debt

Right response:
  Injustice detected → Understand where it belongs → Place it correctly
```

---

## Full Justice Verification Template

```markdown
## Justice Verification

**Solution**: [Beautiful solution to place]
**Proposed Location**: [Where it will go]

### Placement Check
- [ ] Natural location for this type of code
- [ ] Discoverable by others
- [ ] Follows codebase conventions
- Status: [Right place / Wrong place]

### Ownership Check
- [ ] Concern matches component's domain
- [ ] Component has necessary context
- [ ] Coherent with existing responsibilities
- Status: [Right owner / Wrong owner]

### Responsibility Check
- [ ] Appropriate abstraction level
- [ ] Natural fit for entity's role
- [ ] Entity has necessary access
- Status: [Right handler / Wrong handler]

### Proportion Check
- [ ] Complexity in appropriate location
- [ ] Simple things remain simple
- [ ] Properly encapsulated
- Status: [Fair / Unfair]

### Balance Check
- [ ] Follows existing patterns
- [ ] Maintains system coherence
- [ ] Contributes to system health
- Status: [Balanced / Unbalanced]

### Integrity Check
- [ ] Layer boundaries respected
- [ ] Dependencies correct
- [ ] Separation of concerns maintained
- Status: [Preserved / Violated]

### Justice Verdict
**All checks pass?**: [Yes / No - which failed?]
**Place the solution?**: [Yes / No - find right place first]
```

---

## When Justice Verification Fails

### If Placement Fails
```
Solution is in the wrong location.

Action:
1. What type of code is this?
2. Where does this type of code normally go?
3. What's the codebase convention?
4. Move to the right location.
```

### If Ownership Fails
```
Wrong component owns this.

Action:
1. What domain does this concern belong to?
2. Which component owns that domain?
3. Move to the rightful owner.
4. Ensure clean interfaces between components.
```

### If Responsibility Fails
```
Wrong entity handling this.

Action:
1. What abstraction level is this work?
2. Which entity handles that level?
3. Delegate to appropriate entity.
4. Clean up the calling code.
```

### If Proportion Fails
```
Complexity in the wrong place.

Action:
1. Where should complexity be concentrated?
2. How can we encapsulate this?
3. What interface hides the complexity?
4. Restructure for proper encapsulation.
```

### If Balance Fails
```
System becoming unbalanced.

Action:
1. What's the existing pattern?
2. How do we align with it?
3. If pattern should change, is it global or local?
4. Restore or establish balance.
```

### If Integrity Fails
```
Architecture violated.

Action:
1. What boundary was crossed?
2. What's the correct dependency direction?
3. How do we respect the architecture?
4. Restructure to preserve integrity.
```

---

## Justice Verification Summary

### The Core Question
**Is this beautiful solution in its rightful place?**

### The Verification Chain
1. **PLACEMENT**: Right location?
2. **OWNERSHIP**: Right owner?
3. **RESPONSIBILITY**: Right handler?
4. **PROPORTION**: Fair distribution?
5. **BALANCE**: System equilibrium?
6. **INTEGRITY**: Architecture preserved?

### The Rule
**Don't place until justice is verified.**

A beautiful solution in the wrong place creates technical debt.
A beautiful solution in the right place creates lasting value.

### The Promise
Every solution will be placed where it belongs—achieving justice.
