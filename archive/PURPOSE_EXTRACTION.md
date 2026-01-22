# Purpose Extraction Protocol

> **Axiom**: The stated request is the surface. Purpose lies beneath.
> Before solving, understand WHY the solution matters.

---

## The Purpose Extraction Chain

```
┌─────────────────────────────────────────────────────────────────────┐
│                    PURPOSE EXTRACTION CHAIN                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  [User Request]                                                      │
│        │                                                             │
│        ▼                                                             │
│  ┌─────────────┐                                                    │
│  │   PARSE     │  What are they literally asking for?               │
│  │   REQUEST   │                                                    │
│  └──────┬──────┘                                                    │
│         │                                                            │
│         ▼                                                            │
│  ┌─────────────┐                                                    │
│  │   PROBE     │  Why do they need this?                            │
│  │   INTENT    │  What problem does this solve?                     │
│  └──────┬──────┘                                                    │
│         │                                                            │
│         ▼                                                            │
│  ┌─────────────┐                                                    │
│  │   UNCOVER   │  What will they do with this?                      │
│  │   OUTCOME   │  What does success look like for them?             │
│  └──────┬──────┘                                                    │
│         │                                                            │
│         ▼                                                            │
│  ┌─────────────┐                                                    │
│  │   MAP       │  Who uses this? In what environment?               │
│  │   CONTEXT   │  What constraints exist?                           │
│  └──────┬──────┘                                                    │
│         │                                                            │
│         ▼                                                            │
│  ┌─────────────┐                                                    │
│  │   SYNTHESIZE│  Combine into Purpose Statement                    │
│  │   PURPOSE   │                                                    │
│  └──────┬──────┘                                                    │
│         │                                                            │
│         ▼                                                            │
│  ┌─────────────┐                                                    │
│  │   VALIDATE  │  Confirm purpose understanding with user           │
│  │   PURPOSE   │  (when uncertainty is high)                        │
│  └─────────────┘                                                    │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Step 1: Parse Request

### What They're Literally Asking

Extract the surface-level request:

```markdown
**Stated Request**: [User's exact words]

**Parsed As**:
- Action: [What to do: build, design, fix, create, explain]
- Object: [What to act on: system, feature, code, architecture]
- Modifiers: [Any specifications: using X, with Y, for Z]
```

### Example

```
User: "Design an API for user management"

Parsed:
- Action: Design
- Object: API for user management
- Modifiers: None explicit
```

**Do not stop here.** This tells us WHAT, not WHY.

---

## Step 2: Probe Intent

### The "Why" Questions

Ask (internally or to user if unclear):

```markdown
**Intent Probing**:

1. Why is this needed?
   - What problem exists without it?
   - What pain point does this address?

2. Why now?
   - What triggered this request?
   - Is there urgency? Why?

3. Why this approach?
   - Have alternatives been considered?
   - What led to requesting this specific thing?
```

### Intent Signals to Look For

| Signal | Indicates |
|--------|-----------|
| "I need to..." | Direct purpose expression |
| "So that..." | Outcome connection |
| "Because..." | Reasoning behind request |
| "Currently..." | Pain point description |
| "The problem is..." | Core issue identification |
| Technical jargon heavy | May be means vs ends confusion |
| Vague ask | Purpose may be unclear to user too |

### Example

```
User: "Design an API for user management"

Intent Probing (internal):
- Why needed? Probably need to manage users in a system
- Why now? [Unknown - could ask or infer from context]
- Why API specifically? [Unknown - could be for integration, separation of concerns, etc.]

Questions to clarify:
- "What will consume this API?" → Reveals integration context
- "What user operations are most important?" → Reveals priority
```

---

## Step 3: Uncover Outcome

### What Success Looks Like

```markdown
**Outcome Discovery**:

1. What will they DO with this once delivered?
   - Immediate use: [How will it be used right away?]
   - Longer term: [What does it enable?]

2. What does "success" mean for THEM?
   - Not technical success (it works)
   - Business/personal success (it achieves their goal)

3. What would make this NOT successful even if technically correct?
   - [Scenarios where correct != useful]
```

### The "Day After" Test

Imagine the day after delivery:
- What is the user doing?
- What problem is now solved?
- What can they do that they couldn't before?

If you can't answer these, purpose is not yet clear.

### Example

```
User: "Design an API for user management"

Outcome Discovery:
- Day after: They have API endpoints for CRUD on users
- What they'll do: Integrate with frontend/other services
- Success means: Other parts of system can manage users without direct DB access

But deeper:
- Real success: Enable the application to handle user lifecycle
- Not successful if: API exists but doesn't fit their auth model, or is over-complex for their scale
```

---

## Step 4: Map Context

### Environmental Factors

```markdown
**Context Mapping**:

1. Who/What uses this?
   - Primary users/consumers: [Who]
   - Secondary users: [Who]
   - Volume/scale: [How much]

2. Environment:
   - Technical environment: [Stack, constraints]
   - Organizational context: [Team size, skills]
   - Lifecycle stage: [MVP, growth, mature]

3. Constraints:
   - Must have: [Hard requirements]
   - Must avoid: [Dealbreakers]
   - Resources: [Time, budget, capacity]
```

### Context Types

| Context Aspect | Questions | Impact on Purpose |
|----------------|-----------|-------------------|
| **Scale** | How many users/requests? | Right-sizing the solution |
| **Lifecycle** | MVP or mature product? | Investment level appropriate |
| **Team** | Who maintains this? | Complexity appropriate to skill |
| **Integration** | What does this connect to? | Interface requirements |
| **Timeline** | How urgent? | Depth vs speed tradeoff |

### Example

```
User: "Design an API for user management"

Context:
- Users: Internal admin dashboard (low volume)
- Environment: Small team, Python/FastAPI stack
- Lifecycle: MVP stage
- Constraints: Ship this week, one backend dev

Impact on Purpose:
- Purpose is NOT "enterprise-grade user management"
- Purpose IS "enable basic user CRUD for admin dashboard in MVP timeframe"
```

---

## Step 5: Synthesize Purpose

### The Purpose Statement

Combine findings into a clear purpose statement:

```markdown
## Purpose Statement

**Ultimate Intent**: [Why this fundamentally matters]

**Desired Outcome**: [What success looks like]

**Context**: [Key environmental factors]

**Therefore, the purpose is**:
[One clear statement that captures why this matters and what it should achieve]
```

### Purpose Statement Formula

```
PURPOSE =
  "Enable [WHO] to [ACHIEVE WHAT]
   by [PROVIDING WHAT CAPABILITY]
   in [CONTEXT/CONSTRAINTS]"
```

### Example

```
User: "Design an API for user management"

Purpose Statement:

Ultimate Intent: Enable the admin dashboard to manage users

Desired Outcome: Admin can create, view, update, delete users through the dashboard

Context: MVP stage, small team, needs to ship quickly, internal use only

Therefore, the purpose is:
"Enable admin dashboard to perform basic user CRUD operations with minimal implementation complexity appropriate for MVP stage"

This is NOT:
- Enterprise user management with roles, permissions, audit trails
- Public-facing user registration system
- High-scale user service
```

---

## Step 6: Validate Purpose (When Needed)

### When to Validate Explicitly

| Situation | Action |
|-----------|--------|
| Purpose seems complex or multi-faceted | Confirm understanding |
| Request is vague | Ask clarifying questions |
| Multiple possible purposes exist | Get user to disambiguate |
| Stakes are high | Double-check before proceeding |
| Purpose seems mismatched to request | Verify intent |

### Validation Format

```markdown
"Before I proceed, let me confirm I understand the purpose:

You need [PURPOSE STATEMENT].

Key aspects:
- [Aspect 1]
- [Aspect 2]

This means I should focus on [FOCUS] rather than [NON-FOCUS].

Is that right, or should I adjust my understanding?"
```

### When NOT to Validate

- Purpose is clear from context
- Request is straightforward
- You have high confidence
- User has provided rich context

Over-validating is friction. Use judgment.

---

## Purpose Extraction Quick Reference

### The Five Questions

1. **WHAT**: What are they literally asking for?
2. **WHY**: Why do they need this?
3. **OUTCOME**: What will success look like for them?
4. **CONTEXT**: What environment/constraints exist?
5. **THEREFORE**: What is the true purpose?

### Red Flags (Purpose May Be Unclear)

- Request is very technical without context
- Request is very vague
- Request seems disproportionate to stated reason
- Request doesn't fit typical patterns
- User seems uncertain themselves

### Green Flags (Purpose Is Clear)

- User explained why they need it
- Context is well-understood
- Request fits logically with purpose
- Day-after scenario is clear
- Success criteria are implicit or explicit

---

## Purpose Extraction in Practice

### For Architecture Design

```markdown
Before designing, extract:

1. What system/capability is being designed?
2. Why is this system needed? What problem does it solve?
3. Who will use/maintain this system?
4. What scale/lifecycle stage?
5. What does success look like?

Purpose gates architecture decisions:
- If purpose is "MVP experiment" → don't over-architect
- If purpose is "foundational platform" → invest in extensibility
- If purpose is "replace legacy" → ensure migration path
```

### For Feature Implementation

```markdown
Before implementing, extract:

1. What feature is being built?
2. Why is this feature needed? What user problem?
3. How will users interact with this feature?
4. What's the scope appropriate to purpose?
5. What does the user achieve when this works?

Purpose gates implementation decisions:
- If purpose is "quick fix" → minimal viable solution
- If purpose is "core functionality" → robust implementation
- If purpose is "experiment" → reversible, minimal investment
```

---

## Integrating Purpose with Existing Workflow

### Updated Workflow Start

Every PP task now begins:

```markdown
## Step 0: Purpose Extraction (Before Anything Else)

[Run Purpose Extraction Protocol]

### Purpose Statement
[Synthesized purpose]

### Purpose Alignment Criteria
This output will be purpose-aligned if:
- [ ] [Criterion derived from purpose]
- [ ] [Criterion derived from purpose]
- [ ] [Criterion derived from purpose]

### Purpose Boundaries
This output should NOT:
- [What would violate purpose]
- [What would exceed purpose]

---

[Now proceed with workflow, using purpose as the North Star]
```
