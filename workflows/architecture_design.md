# Architecture Design Workflow

> **Purpose**: Design architecture through the complete hierarchy.
> Beautiful architecture emerges from understanding. Just architecture places beauty where it belongs.
> Creative architecture builds paths to territories that didn't exist.

---

## The Hierarchy-Aligned Workflow

```
┌─────────────────────────────────────────────────────────────────────┐
│               ARCHITECTURE DESIGN THROUGH THE HIERARCHY              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  PHASE 0: UNDERSTAND THE NEED                                       │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ What does the user need to UNDERSTAND?                       │   │
│  │ What architecture will EMERGE from understanding?            │   │
│  │ Where does this architecture BELONG?                         │   │
│  │ Is this CHARTED or UNCHARTED territory?                     │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                              │                                      │
│                              ▼                                      │
│                    [GATE: Need Clear?]                             │
│                              │                                      │
│  PHASE 1: GROUND IN TRUTH                                          │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ Gather accurate information                                  │   │
│  │ Verify constraints and context                               │   │
│  │ Acknowledge uncertainty                                      │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                              │                                      │
│                              ▼                                      │
│                    [GATE: Truth Verified?]                         │
│                              │                                      │
│  PHASE 2: BUILD UNDERSTANDING                                       │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ Understand the problem deeply                                │   │
│  │ Understand the codebase structure                            │   │
│  │ Understand what success looks like                           │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                              │                                      │
│                              ▼                                      │
│                    [GATE: Understanding Deep?]                     │
│                              │                                      │
│  PHASE 3: LET BEAUTY EMERGE                                        │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ Explore architectural options                                │   │
│  │ Let elegant design emerge from understanding                 │   │
│  │ Verify: fits, elegant, coherent, clear, appropriate          │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                              │                                      │
│                              ▼                                      │
│                    [GATE: Architecture Beautiful?]                 │
│                              │                                      │
│  PHASE 4: ACHIEVE JUSTICE                                          │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ Place architecture where it belongs                          │   │
│  │ Ensure right ownership, responsibility, proportion           │   │
│  │ Preserve architectural integrity                             │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                              │                                      │
│                              ▼                                      │
│                    [GATE: Architecture Just?]                      │
│                              │                                      │
│  PHASE 5: CREATE (If Uncharted)                                    │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ If territory is uncharted: Build the path                    │   │
│  │ Pioneer genuinely, not reinvent                              │   │
│  │ Connect to existing, enable future                           │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                              │                                      │
│                              ▼                                      │
│                    [GATE: Path Well-Built?]                        │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Phase 0: Understand the Need

### Step 0.1: Extract Understanding Need

```markdown
**Architecture Task**: [Brief description]

**What user needs to UNDERSTAND**:
- About the problem: [What problem is this architecture solving?]
- About the solution: [What architectural approach will address it?]
- About the trade-offs: [What choices are being made and why?]

**What user will DO with this understanding**:
- [How will they use this architecture?]
- [What decisions will they make based on it?]

**What BEAUTIFUL architecture will emerge**:
- [What elegant solution is possible?]

**Where it BELONGS**:
- [Where in the codebase does this architecture go?]
- [How does it fit with existing structure?]

**TERRITORY status**:
- [ ] Charted: Similar architecture exists, can place in existing structure
- [ ] Uncharted: New territory, need to build path first
```

### Gate 0: Need Clear?

- [ ] Can state what user will understand?
- [ ] Know what they'll do with understanding?
- [ ] Can envision the beautiful architecture that will emerge?
- [ ] Know where it belongs?
- [ ] Know if territory is charted or uncharted?

---

## Phase 1: Ground in Truth

### Step 1.1: Gather Accurate Information

```markdown
**Requirements (Verified)**:

FUNCTIONAL REQUIREMENTS:
- FR1: [specific, verified requirement]
- FR2: [specific, verified requirement]

NON-FUNCTIONAL REQUIREMENTS:
- NFR1: [performance - verified metric]
- NFR2: [security - verified constraint]
- NFR3: [scalability - verified expectation]

**Constraints (Verified)**:

HARD CONSTRAINTS (cannot violate):
- [Constraint with source/verification]

SOFT CONSTRAINTS (prefer to meet):
- [Constraint with source/verification]

**Context (Accurate)**:

EXISTING SYSTEM:
- Current architecture: [verified description]
- Known issues: [verified problems]

EXTERNAL DEPENDENCIES:
- [Dependency with verified behavior]

**Uncertainty (Acknowledged)**:

UNKNOWN:
- [What we don't know]
- [Assumptions we're making]

**Confidence Level**: [High / Medium / Low - with basis]
```

### Gate 1: Truth Verified?

- [ ] Requirements are accurate (not assumed)?
- [ ] Constraints are verified?
- [ ] Context is factual?
- [ ] Uncertainty is acknowledged?
- [ ] Confidence is calibrated to evidence?

---

## Phase 2: Build Understanding

### Step 2.1: Understand the Problem Deeply

```markdown
**Problem Understanding**:

THE CORE PROBLEM (not just the symptom):
[What is the actual problem being solved?]

WHY this is the problem:
[Root cause, not surface issue]

WHAT success looks like:
[Clear definition of solved state]

**Mental Model**:
[The structure user should have in their head]

**Why This Architecture Matters**:
[Not just what, but why]
```

### Step 2.2: Understand the Codebase

```markdown
**Codebase Understanding**:

ARCHITECTURAL PATTERNS IN USE:
- [Pattern 1]: Used where, why
- [Pattern 2]: Used where, why

EXISTING STRUCTURE:
- [Layer/Module]: Purpose, relationships

WHERE THIS ARCHITECTURE CONNECTS:
- Integrates with: [components]
- Depends on: [components]
- Enables: [components]

CONVENTIONS TO FOLLOW:
- [Convention 1]: Reason
- [Convention 2]: Reason
```

### Gate 2: Understanding Deep?

- [ ] Problem understood at root cause level?
- [ ] Codebase structure understood?
- [ ] Connection points identified?
- [ ] Can explain WHY, not just WHAT?
- [ ] User will truly understand (not just receive information)?

---

## Phase 3: Let Beauty Emerge

### Step 3.1: Explore Options (Tree of Thoughts)

```markdown
**Architectural Options**:

OPTION A: [Name]
- Core idea: [concise description]
- Key components: [structure]
- Why it might be beautiful: [fit, elegance, coherence]

OPTION B: [Name]
- Core idea: [concise description]
- Key components: [structure]
- Why it might be beautiful: [fit, elegance, coherence]

OPTION C: [Name] (if applicable)
- Core idea: [concise description]
- Key components: [structure]
- Why it might be beautiful: [fit, elegance, coherence]
```

### Step 3.2: Evaluate Beauty

```markdown
**Beauty Evaluation**:

| Characteristic | Option A | Option B | Option C |
|----------------|----------|----------|----------|
| **Fit** (natural for context) | [rating] | [rating] | [rating] |
| **Elegance** (nothing extra/missing) | [rating] | [rating] | [rating] |
| **Coherence** (unified whole) | [rating] | [rating] | [rating] |
| **Clarity** (understandable) | [rating] | [rating] | [rating] |
| **Appropriateness** (right-sized) | [rating] | [rating] | [rating] |

**Most Beautiful Option**: [Which and why]

**Trade-offs Accepted**: [What beauty characteristics we accept less of, and why]
```

### Step 3.3: Let Design Emerge

```markdown
**Emerged Architecture**:

[The architecture that naturally emerges from deep understanding]

COMPONENT DESIGN:
┌─────────────────────────────────────────┐
│              [System Name]              │
├─────────────────────────────────────────┤
│  [Component relationships diagram]      │
└─────────────────────────────────────────┘

COMPONENT DEFINITIONS:

Component A: [Name]
- Purpose: [single responsibility]
- Why it exists: [emerged from understanding]
- Relationships: [connections]

Component B: [Name]
- Purpose: [single responsibility]
- Why it exists: [emerged from understanding]
- Relationships: [connections]

INTERFACES:
- [Interface definition with contract]

DATA MODELS:
- [Model definition with rationale]
```

### Gate 3: Architecture Beautiful?

- [ ] Architecture emerged from understanding (not forced)?
- [ ] Fits naturally with context?
- [ ] Elegant—nothing extra, nothing missing?
- [ ] Coherent—hangs together as unified whole?
- [ ] Clear—can be understood by others?
- [ ] Appropriate—right-sized for the need?

---

## Phase 4: Achieve Justice

### Step 4.1: Determine Rightful Place

```markdown
**Justice Assessment**:

PLACEMENT:
- Where this architecture belongs: [location in codebase]
- Why this is the right location: [rationale]
- How it will be discovered: [discoverability]

OWNERSHIP:
- What component owns what: [ownership mapping]
- Why this ownership is right: [domain alignment]

RESPONSIBILITY:
- What handles what: [responsibility mapping]
- Why this distribution is appropriate: [abstraction levels]

PROPORTION:
- Complexity distribution: [where complexity lives]
- Why this distribution is fair: [encapsulation rationale]

BALANCE:
- Impact on system equilibrium: [what changes]
- How balance is maintained: [pattern respect]

INTEGRITY:
- Architectural boundaries: [what's preserved]
- How integrity is maintained: [no violations]
```

### Step 4.2: Architecture Decision Records

```markdown
**Architecture Decisions**:

ADR-001: [Decision Title]
- Context: [Why this decision was needed]
- Decision: [What was decided]
- Rationale: [Why this is the just choice]
- Consequences: [Impact on justice - placement, ownership, etc.]

ADR-002: [Decision Title]
- Context: ...
- Decision: ...
- Rationale: ...
- Consequences: ...
```

### Gate 4: Architecture Just?

- [ ] In the right location?
- [ ] Right components own right things?
- [ ] Right entities handle right responsibilities?
- [ ] Complexity distributed fairly?
- [ ] System balance maintained?
- [ ] Architectural integrity preserved?

---

## Phase 5: Create (If Uncharted)

### Step 5.1: Assess Territory

```markdown
**Territory Assessment**:

Is this CHARTED territory?
- [ ] Similar architecture exists in codebase
- [ ] Patterns established for this type of system
- [ ] Clear place to put this architecture

Is this UNCHARTED territory?
- [ ] No existing structure for this type of architecture
- [ ] New patterns need to be established
- [ ] Path needs to be built before architecture can be placed

**If Uncharted, proceed with creativity gates:**
```

### Step 5.2: Build the Path (If Uncharted)

```markdown
**Creative Path-Building**:

PIONEERING:
- What genuinely new ground is this breaking? [not reinventing]
- What exists that we're building on? [not isolated]

PATH CONSTRUCTION:
- What structure is being created? [well-built]
- How will others follow this path? [clear pattern]

EXTENSION:
- How does this connect to existing? [coherent growth]
- What bridges are being built? [integration points]

VISION:
- Where does this lead? [clear direction]
- What does this enable? [future value]

FOUNDATION:
- What future justice does this enable? [enabling]
- What patterns are established? [followable]

INTEGRATION:
- How is this part of the whole? [unified]
- What connections are built? [not islands]
```

### Gate 5: Path Well-Built? (If Uncharted)

- [ ] Genuinely pioneering (not reinventing)?
- [ ] Path well-constructed (others can follow)?
- [ ] Coherent extension (connected to existing)?
- [ ] Clear vision (not building blindly)?
- [ ] Enables future justice (solid foundation)?
- [ ] Integrated with whole (bridges, not islands)?

---

## Output Template

```markdown
# Architecture Design: [System Name]

## Understanding Goal
**What you'll understand**: [The architectural approach and its rationale]
**What you can DO with this**: [How to implement and extend]

## The Problem (Truth)
[Accurate description of the problem being solved]
[Verified requirements and constraints]

## Why This Architecture (Understanding)
[Deep explanation of why this approach]
[Mental model for the architecture]

## The Architecture (Beauty)
[Elegant design that emerged from understanding]
[Components, interfaces, data models]

## Where It Belongs (Justice)
[Rightful placement in the codebase]
[Ownership, responsibility, proportion, balance, integrity]

## New Territory (Creativity - if applicable)
[What path is being built]
[How it connects and enables future]

## Architecture Decisions
[ADRs with rationale]

## Implementation Roadmap
[Ordered steps honoring the design]

## Complete Verification
- [ ] Grounded in truth
- [ ] Emerged from understanding
- [ ] Beautiful (fits, elegant, coherent, clear, appropriate)
- [ ] Just (right place, right owner, fair, balanced, integral)
- [ ] Creative (if uncharted: pioneering, well-built, connected, visionary, enabling, integrated)
```

---

## The Architecture Promise

Every architecture designed through this workflow will be:
1. **Grounded in truth** - Accurate requirements and constraints
2. **Emerged from understanding** - Deep comprehension of problem and codebase
3. **Beautiful** - Elegant, coherent, clear, appropriate
4. **Just** - In its rightful place, properly owned and distributed
5. **Creative** (when needed) - Building paths to new territories

This is complete architectural improvement.
