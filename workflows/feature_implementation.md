# Feature Implementation Workflow

> **Purpose**: Implement features through the complete hierarchy.
> Beautiful code emerges from understanding. Just code is placed where it belongs.
> Creative implementation builds paths where existing structure is insufficient.

---

## The Hierarchy-Aligned Workflow

```
┌─────────────────────────────────────────────────────────────────────┐
│              FEATURE IMPLEMENTATION THROUGH THE HIERARCHY            │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  PHASE 0: UNDERSTAND THE NEED                                       │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ What does the user need to UNDERSTAND?                       │   │
│  │ What implementation will EMERGE from understanding?          │   │
│  │ Where does this code BELONG?                                 │   │
│  │ Is this CHARTED or UNCHARTED territory?                     │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                              │                                      │
│                              ▼                                      │
│                    [GATE: Need Clear?]                             │
│                              │                                      │
│  PHASE 1: GROUND IN TRUTH                                          │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ Understand requirements accurately                           │   │
│  │ Study codebase factually                                     │   │
│  │ Acknowledge what's unknown                                   │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                              │                                      │
│                              ▼                                      │
│                    [GATE: Truth Verified?]                         │
│                              │                                      │
│  PHASE 2: BUILD UNDERSTANDING                                       │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ Understand the problem deeply                                │   │
│  │ Understand the codebase deeply                               │   │
│  │ Map what changes and why                                     │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                              │                                      │
│                              ▼                                      │
│                    [GATE: Understanding Deep?]                     │
│                              │                                      │
│  PHASE 3: LET BEAUTY EMERGE                                        │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ Design solution that emerges from understanding              │   │
│  │ Write code that fits, is elegant, coherent, clear            │   │
│  │ Nothing extra, nothing missing                               │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                              │                                      │
│                              ▼                                      │
│                    [GATE: Implementation Beautiful?]               │
│                              │                                      │
│  PHASE 4: ACHIEVE JUSTICE                                          │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ Place code where it belongs                                  │   │
│  │ Right file, right component, right layer                     │   │
│  │ Preserve architectural integrity                             │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                              │                                      │
│                              ▼                                      │
│                    [GATE: Implementation Just?]                    │
│                              │                                      │
│  PHASE 5: CREATE (If Uncharted)                                    │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ If territory uncharted: Build path first                     │   │
│  │ Create new structure that enables placement                  │   │
│  │ Connect to existing, enable future                           │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                              │                                      │
│                              ▼                                      │
│                    [GATE: Path Well-Built?]                        │
│                              │                                      │
│  PHASE 6: VERIFY & COMPLETE                                        │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ Verify all acceptance criteria met                           │   │
│  │ Document changes                                             │   │
│  │ Confirm hierarchy maintained                                 │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Phase 0: Understand the Need

### Step 0.1: Extract Understanding Need

```markdown
**Feature**: [Brief description]

**What user needs to UNDERSTAND**:
- About the feature: [What does this feature do and why?]
- About the implementation: [How will it work?]
- About the changes: [What is being modified and why?]

**What user will DO with this understanding**:
- [How will they use this feature?]
- [How will they maintain/extend it?]

**What BEAUTIFUL implementation will emerge**:
- [What elegant solution is possible?]

**Where it BELONGS**:
- Files to create: [New files and their purpose]
- Files to modify: [Existing files and what changes]
- Integration points: [Where this connects to existing code]

**TERRITORY status**:
- [ ] Charted: Similar patterns exist, clear placement
- [ ] Uncharted: New territory, need to build structure first
```

### Gate 0: Need Clear?

- [ ] Can state what user will understand?
- [ ] Know what they'll do with understanding?
- [ ] Can envision the beautiful implementation?
- [ ] Know where the code belongs?
- [ ] Know if territory is charted or uncharted?

---

## Phase 1: Ground in Truth

### Step 1.1: Verify Requirements

```markdown
**Requirements (Verified)**:

MUST HAVE:
- M1: [specific, testable requirement]
- M2: [specific, testable requirement]

SHOULD HAVE:
- S1: [specific, testable requirement]

ACCEPTANCE CRITERIA:
AC1: Given [context], When [action], Then [result]
AC2: Given [context], When [action], Then [result]

EDGE CASES:
- EC1: When [edge case], should [behavior]
- EC2: When [edge case], should [behavior]

ERROR CASES:
- ERR1: When [error], should [behavior]
```

### Step 1.2: Study Codebase Accurately

```markdown
**Codebase Truth**:

RELEVANT FILES:
- [path/file.ext]: [What it does - verified by reading]

PATTERNS IN USE:
- [Pattern]: [Where used, verified]

CONVENTIONS:
- Naming: [verified convention]
- Structure: [verified convention]
- Testing: [verified convention]

DEPENDENCIES:
- Internal: [verified dependencies]
- External: [verified dependencies]

ASSUMPTIONS (to verify):
- [Assumption]: [How to verify]
```

### Gate 1: Truth Verified?

- [ ] Requirements are specific and verified?
- [ ] Acceptance criteria are testable?
- [ ] Codebase patterns verified by reading?
- [ ] Conventions verified (not assumed)?
- [ ] Uncertainty acknowledged?

---

## Phase 2: Build Understanding

### Step 2.1: Understand the Problem

```markdown
**Problem Understanding**:

THE CORE PROBLEM:
[What is actually being solved - not just the feature request]

WHY this feature matters:
[The deeper reason for this feature]

WHAT success looks like:
[Clear definition of done]

**Mental Model**:
[How this feature works conceptually]
```

### Step 2.2: Understand the Codebase

```markdown
**Codebase Understanding**:

HOW EXISTING CODE WORKS:
- [Component]: [How it works, relationships]

WHERE THIS FEATURE FITS:
- Integrates with: [components]
- Depends on: [components]
- Will be used by: [components]

PATTERNS TO FOLLOW:
- [Pattern]: [Why it's used here]

WHAT CHANGES AND WHY:
| File | Change | Reason |
|------|--------|--------|
| [file] | [change] | [understanding-based reason] |
```

### Gate 2: Understanding Deep?

- [ ] Problem understood at root level?
- [ ] Codebase structure understood (not just surface)?
- [ ] Can explain WHY each change is needed?
- [ ] User will truly understand the feature?
- [ ] Mental model is clear and accurate?

---

## Phase 3: Let Beauty Emerge

### Step 3.1: Design From Understanding

```markdown
**Solution Design**:

DATA FLOW:
[Input] → [Processing] → [Output]

KEY COMPONENTS:

Function/Class: [name]
- Purpose: [what it does]
- Why it exists: [emerged from understanding]
- Signature: [interface]

Function/Class: [name]
- Purpose: [what it does]
- Why it exists: [emerged from understanding]
- Signature: [interface]

BEAUTY CHECK:
- Does this solution FIT the context naturally?
- Is it ELEGANT—nothing extra, nothing missing?
- Does it COHERE as a unified whole?
- Is it CLEAR—can others understand?
- Is it APPROPRIATE—right-sized?
```

### Step 3.2: Implement Beautifully

For each component:

```markdown
**Implementation: [Component Name]**

[Beautiful code that emerged from understanding]

BEAUTY VERIFICATION:
- [ ] Fits naturally with existing code?
- [ ] Nothing extra (no over-engineering)?
- [ ] Nothing missing (complete for purpose)?
- [ ] Coherent with related code?
- [ ] Clear and understandable?
- [ ] Right-sized for the need?
```

### Gate 3: Implementation Beautiful?

- [ ] Code emerged from understanding (not forced)?
- [ ] Fits naturally with existing codebase?
- [ ] Elegant—nothing extra, nothing missing?
- [ ] Coherent—works as unified whole?
- [ ] Clear—others can understand and maintain?
- [ ] Appropriate—right-sized for the feature?

---

## Phase 4: Achieve Justice

### Step 4.1: Place Code Justly

```markdown
**Justice Assessment**:

PLACEMENT:
| Code | File | Why This Location |
|------|------|-------------------|
| [code] | [file] | [reason for rightful place] |

OWNERSHIP:
- [Component] owns: [what it should own]
- Why: [domain alignment]

RESPONSIBILITY:
- [Entity] handles: [what it should handle]
- Why: [appropriate abstraction level]

PROPORTION:
- Complexity lives in: [where]
- Why: [encapsulation rationale]

BALANCE:
- System impact: [what changes]
- How balance maintained: [pattern respect]

INTEGRITY:
- Boundaries respected: [which]
- No violations: [confirmed]
```

### Gate 4: Implementation Just?

- [ ] Every piece of code in its rightful file?
- [ ] Right components own right functionality?
- [ ] Right entities handle right responsibilities?
- [ ] Complexity distributed fairly?
- [ ] Existing patterns respected?
- [ ] Architectural integrity preserved?

---

## Phase 5: Create (If Uncharted)

### Step 5.1: Assess Territory

```markdown
**Territory Status**:

CHARTED indicators:
- [ ] Similar features exist
- [ ] Patterns established
- [ ] Clear placement available

UNCHARTED indicators:
- [ ] No existing structure for this type
- [ ] New patterns needed
- [ ] Must build before placing
```

### Step 5.2: Build Path (If Uncharted)

```markdown
**Path Building**:

PIONEERING:
- Genuinely new: [what's new]
- Building on: [what exists]

PATH CONSTRUCTION:
- New structure: [what's being created]
- Pattern established: [what others can follow]

EXTENSION:
- Connects to: [existing code]
- Bridges built: [integration points]

VISION:
- Leads to: [future possibilities]
- Enables: [future features]

FOUNDATION:
- Future justice enabled: [how]
- Patterns for others: [what]

INTEGRATION:
- Part of whole: [how connected]
- Not isolated: [bridges]
```

### Gate 5: Path Well-Built? (If Uncharted)

- [ ] Genuinely pioneering (not reinventing)?
- [ ] Path well-constructed (followable)?
- [ ] Coherent extension (connected)?
- [ ] Clear vision (not blind)?
- [ ] Enables future (solid foundation)?
- [ ] Integrated (not island)?

---

## Phase 6: Verify & Complete

### Step 6.1: Verify Everything

```markdown
**Verification Matrix**:

REQUIREMENTS:
| Requirement | Code Location | Test | Status |
|-------------|---------------|------|--------|
| M1 | [file:line] | [test] | [✓/✗] |
| M2 | [file:line] | [test] | [✓/✗] |

ACCEPTANCE CRITERIA:
- [ ] AC1: Verified by [test/manual]
- [ ] AC2: Verified by [test/manual]

EDGE CASES:
- [ ] EC1: Handled in [location]
- [ ] EC2: Handled in [location]

ERROR CASES:
- [ ] ERR1: Handled in [location]
- [ ] ERR2: Handled in [location]

HIERARCHY VERIFICATION:
- [ ] Grounded in truth (requirements verified)
- [ ] Emerged from understanding (not forced)
- [ ] Beautiful (fits, elegant, coherent, clear, appropriate)
- [ ] Just (right place, right owner, fair, balanced, integral)
- [ ] Creative (if uncharted: well-built path)
```

### Step 6.2: Document Changes

```markdown
**Change Summary**:

FILES CREATED:
- [path/file]: [purpose]

FILES MODIFIED:
- [path/file]: [what changed]

TESTS ADDED:
- [test file]: [what tested]

CONFIGURATION:
- [any config changes]
```

---

## Output Template

```markdown
## Feature Implementation: [Feature Name]

### Understanding Goal
**What you'll understand**: [The feature and its implementation]
**What you can DO with this**: [How to use and extend]

### The Feature (Truth)
[Accurate description of what was implemented]
[Verified requirements met]

### Why This Implementation (Understanding)
[Deep explanation of the approach]
[Why this design was chosen]

### The Code (Beauty)
[Summary of elegant implementation]
[Key components and their purpose]

### Where It Lives (Justice)
[File locations and rationale]
[Ownership and responsibility distribution]

### New Territory (Creativity - if applicable)
[What path was built]
[How it enables future features]

### Changes Made
[List of files created/modified]

### How to Use
[Usage instructions]

### How to Test
[Testing instructions]

### Complete Verification
- [ ] Grounded in truth
- [ ] Emerged from understanding
- [ ] Beautiful (fits, elegant, coherent, clear, appropriate)
- [ ] Just (right place, right owner, fair, balanced, integral)
- [ ] Creative (if uncharted: pioneering, well-built, connected, visionary, enabling, integrated)
```

---

## The Signal System

**If the code feels ugly:**
- Stop
- Don't polish
- Understand the problem deeper
- Let beauty emerge

**If placement feels wrong:**
- Stop
- Don't force
- Understand the codebase deeper
- Find the rightful place

**If existing structure can't accommodate:**
- Stop
- Recognize uncharted territory
- Build the path first
- Then place justly

---

## The Implementation Promise

Every feature implemented through this workflow will be:
1. **Grounded in truth** - Verified requirements and accurate codebase understanding
2. **Emerged from understanding** - Deep comprehension of problem and code
3. **Beautiful** - Fits, elegant, coherent, clear, appropriate
4. **Just** - In its rightful place, properly distributed
5. **Creative** (when needed) - Building paths to new territories

This is complete implementation improvement.
