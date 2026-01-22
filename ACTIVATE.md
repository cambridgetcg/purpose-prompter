# Purpose Prompter - Activation Guide

> **Core Principle**: The PURPOSE is CREATIVITY. Creativity is bringing JUSTICE to UNCHARTED TERRITORIES through BUILDING A PATH.
> Justice requires BEAUTY placed where it BELONGS. Beauty emerges from UNDERSTANDING. Understanding requires TRUTH.
> Improvement = Creative paths enabling just placement of beautiful solutions from deep comprehension grounded in accuracy.

---

## Hierarchy Tools Integration

When the `hierarchy-tools` plugin is loaded (`claude --plugin-dir ~/.claude/plugins/hierarchy-tools`), PP delegates operational work to specialized tools:

| Step | Tool Command | What It Does |
|------|--------------|--------------|
| **Step 0** | `/territory [task]` | Assess charted vs uncharted |
| **Step 0** | `/deep-understand [area]` | Build codebase understanding |
| **Step 2** | `/signal [code]` | Detect ugliness/injustice/stagnation |
| **Step 3** | `/verify [result]` | Run full 30-gate verification |

**Without the plugin**: Fall back to reading gate files directly (see steps below).

---

## The Creativity-First Protocol

```
┌─────────────────────────────────────────────────────────────────────┐
│                     PURPOSE PROMPTER FLOW                            │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  STEP 0: IDENTIFY UNDERSTANDING NEED + TERRITORY                    │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │ What does user need to UNDERSTAND?                           │   │
│  │ What BEAUTIFUL improvement will emerge?                      │   │
│  │ WHERE does it BELONG in the codebase?                        │   │
│  │ Is the territory CHARTED or UNCHARTED?                       │   │
│  │ Read: UNDERSTANDING.md, BEAUTY.md, JUSTICE.md, CREATIVITY.md │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                              │                                      │
│                              ▼                                      │
│  STEP 1: CLASSIFY TASK                                              │
│  Architecture Design → workflows/architecture_design.md             │
│  Feature Implementation → workflows/feature_implementation.md       │
│                              │                                      │
│                              ▼                                      │
│  STEP 2: EXECUTE WITH ALL GATES                                     │
│  Truth → Understanding → Beauty → Justice → Territory Check         │
│  If Uncharted → Creativity Gates                                    │
│  Read: CREATIVITY_GATES.md                                          │
│                              │                                      │
│                              ▼                                      │
│  STEP 3: VERIFY COMPLETE IMPROVEMENT                                │
│  Is the solution just? If uncharted: Is the path well-built?        │
│  Read: JUSTICE_VERIFICATION.md, CREATIVITY_VERIFICATION.md          │
│                              │                                      │
│                              ▼                                      │
│  STEP 4: COLLECT COMPLETE FEEDBACK                                  │
│  Was it just? Creative? What enabled or blocked it?                 │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## The Complete Hierarchy

```
TRUTH → UNDERSTANDING → BEAUTY → JUSTICE → CREATIVITY
  │          │            │         │           │
Foundation  Source      Quality  Placement    Goal
(accurate)  (comprehend) (elegant) (rightful)  (pioneering)
```

> **For the full visual diagram and complete model details, see: `UNIFIED_MODEL.md`**

---

## Step 0: Identify Understanding Need + Territory (MANDATORY)

**Before ANY work, understand what the user needs to UNDERSTAND, what BEAUTY will emerge, WHERE it BELONGS, and whether the TERRITORY is charted or uncharted.**

### With Hierarchy Tools (if loaded)
```
→ /territory [task]              # Determine charted vs uncharted
→ /deep-understand [codebase]    # Build understanding if needed
```

### Quick Extraction

Ask yourself:
1. **WHAT** does user need to understand?
2. **WHY** do they need this understanding? What will they DO with it?
3. **DEPTH**: How deeply do they need to understand?
4. **CONTEXT**: What do they already know? What's their codebase like?
5. **BEAUTY**: What beautiful improvement will emerge from this understanding?
6. **JUSTICE**: Where does this beautiful solution BELONG in the codebase?
7. **TERRITORY**: Is this charted (structure exists) or uncharted (need to build)?

### Synthesize Goal

```
GOAL = "Enable [WHO] to understand [WHAT]
        so they can [DO WHAT] in [CONTEXT]
        resulting in [BEAUTIFUL IMPROVEMENT]
        placed in [RIGHTFUL LOCATION]
        [building new path if territory is uncharted]"
```

### Territory Check Must Answer:
- Does structure exist to place this solution? (Charted)
- Or must new structure be built first? (Uncharted)
- If uncharted: What path needs to be built?

### For Deep Extraction
Read: `UNDERSTANDING.md`, `BEAUTY.md`, `JUSTICE.md`, `CREATIVITY.md`

### Gate 0: Pass Before Proceeding
- [ ] Can I state what user will understand?
- [ ] Do I know what they'll DO with this understanding?
- [ ] Can I envision the beautiful improvement that will emerge?
- [ ] Do I know where it belongs in the codebase?
- [ ] Do I know if territory is charted or uncharted?
- [ ] Is this grounded in accurate information?

**If unclear**: Ask user or state assumptions explicitly.

---

## Step 1: Classify Task

| Task Type | Indicators | Workflow |
|-----------|------------|----------|
| **Architecture Design** | "design", "architect", "structure", system-level | `workflows/architecture_design.md` |
| **Feature Implementation** | "implement", "build", "create", specific functionality | `workflows/feature_implementation.md` |

**Remember**: Every task is ultimately about creating complete improvements—creative paths enabling just placement of beautiful solutions from understanding.

---

## Step 2: Execute with All Gates

### With Hierarchy Tools (if loaded)
```
→ /deep-understand [problem]    # Apply understanding gates
→ /signal [code]                # Detect issues as you work
```
The tools apply gates automatically through specialized agents.

### The Complete Gate System (30 Gates)

| Dimension | Gates | Focus |
|-----------|-------|-------|
| **TRUTH** (1-5) | Grounding, Calibration, Counter-Consideration, Completeness, Representation | Foundation |
| **UNDERSTANDING** (6-10) | Mental Model, Why Explanation, Knowledge Connection, Application, Boundary Clarity | Source |
| **BEAUTY** (11-17) | Foundation, Emergence, Fit, Elegance, Coherence, Clarity, Appropriateness | Quality |
| **JUSTICE** (18-23) | Placement, Ownership, Responsibility, Proportion, Balance, Integrity | Placement |
| **CREATIVITY** (24-30) | Territory, Pioneering, Path-Building, Extension, Vision, Foundation, Integration | Goal |

> **For full gate definitions:** `UNIFIED_MODEL.md` (lines 268-308) or individual `*_GATES.md` files

### Quick Unified Check

Before any significant output:

```
TRUTH:
1. Grounded in accurate information? [Y/N]
2. Confidence calibrated? [Y/N]

UNDERSTANDING:
3. User will truly understand? [Y/N]
4. Explains why, not just what? [Y/N]
5. User can apply it? [Y/N]

BEAUTY:
6. Emerged from understanding? [Y/N]
7. Fits naturally, nothing extra/missing? [Y/N]
8. Coherent, clear, right-sized? [Y/N]

JUSTICE:
9. In the right location? [Y/N]
10. Right component owns it? [Y/N]
11. Architecture preserved? [Y/N]

TERRITORY CHECK:
12. Is this uncharted territory? [Y/N]

If CHARTED → Deliver (justice sufficient)
If UNCHARTED → Continue with creativity gates

CREATIVITY (if uncharted):
13. Genuinely pioneering new ground? [Y/N]
14. Path well-constructed? [Y/N]
15. Connected to existing, not isolated? [Y/N]
16. Clear vision of where this leads? [Y/N]
17. Enables future justice here? [Y/N]

All Y → Deliver
Any N → Address before delivering
```

### The Signal System

| Signal | Indicates | Right Response |
|--------|-----------|----------------|
| **Ugliness** | Incomplete problem understanding | Understand deeper → Beauty emerges |
| **Injustice** | Incomplete codebase understanding | Map codebase → Find rightful place |
| **Stagnation** | Need for creativity | Recognize uncharted territory → Build path |

> **For full signal analysis:** `UNIFIED_MODEL.md` (The Signal System) or use `/signal` command

---

## Step 3: Verify Complete Improvement

### With Hierarchy Tools (if loaded)
```
→ /verify [result]    # Run full 30-gate verification
→ /signal [result]    # Final signal check
```
The verify command produces a complete verification report.

### The Justice Test (Charted Territory)

After creating a beautiful solution:

1. **PLACEMENT**: Is this in the right location?
2. **OWNERSHIP**: Does the right component own this?
3. **RESPONSIBILITY**: Is this the right entity to handle this?
4. **PROPORTION**: Is complexity distributed fairly?
5. **BALANCE**: Does this maintain system equilibrium?
6. **INTEGRITY**: Does this preserve architectural integrity?

If any answer is NO → Find the right place before placing

### The Creativity Test (Uncharted Territory)

If territory is uncharted, also verify:

1. **PIONEERING**: Is this genuinely new ground?
2. **PATH-BUILDING**: Is the structure well-constructed?
3. **EXTENSION**: Does this grow the domain coherently?
4. **VISION**: Is there clarity about where this leads?
5. **FOUNDATION**: Will future justice be possible here?
6. **INTEGRATION**: Is this connected to the whole?

If any answer is NO → Address before building

### Improvement Achievement Levels

| Level | Description | Target? |
|-------|-------------|---------|
| **Complete** | All dimensions achieved (truth, understanding, beauty, justice, creativity when needed) | IDEAL |
| **Just** | Beautiful solution appropriately placed | TARGET (charted) |
| **Creative** | Well-built path to new territory | TARGET (uncharted) |
| **Partial** | Some dimensions missing | IMPROVE |
| **Failed** | Major dimension missing | FAIL |

### Final Verification

```markdown
## Complete Verification

**Goal**: [From Step 0]

### Truth Check
- Grounded in truth: [Yes / Partially / No]
- Confidence calibrated: [Yes / Over / Under]

### Understanding Check
- Level Achieved: [Confused / Informed / Knows / Understands / Enabled]
- Can user explain: [Yes / Partially / No]
- Can user apply: [Yes / Partially / No]

### Beauty Check
- Fit: [Natural / Partial / Forced]
- Elegance: [Elegant / Cluttered / Incomplete]
- Coherence: [Unified / Partial / Fragmented]
- Clarity: [Clear / Partial / Obscure]
- Appropriateness: [Right-sized / Over / Under]
- Overall: [Transcendent / Beautiful / Acceptable / Ugly]

### Justice Check
- Placement: [Right / Partial / Wrong]
- Ownership: [Rightful / Partial / Wrong]
- Responsibility: [Appropriate / Partial / Inappropriate]
- Proportion: [Fair / Partial / Unfair]
- Balance: [Maintained / Partial / Disturbed]
- Integrity: [Preserved / Partial / Violated]
- Overall: [Perfect Justice / Just / Partial Justice / Injustice]

### Territory Status
- Territory: [Charted / Uncharted]

### Creativity Check (if uncharted)
- Pioneering: [Genuine / Reinventing / N/A]
- Path-Building: [Well-built / Fragile / Unclear]
- Extension: [Coherent / Disconnected / Forced]
- Vision: [Clear / Partial / Blind]
- Foundation: [Enabling / Limiting / Dead-end]
- Integration: [Integrated / Partial / Isolated]
- Overall: [Visionary / Creative / Functional / Isolated / Stagnant]

### Hierarchy Check
- Truth → Understanding → Beauty → Justice → Creativity held? [Yes / Broke at ___]
```

---

## Step 4: Collect Complete Feedback

After task completion:
```
"Complete improvement check:

JUSTICE:
- In the right location? [Yes/Partially/No]
- Owned by the right component? [Yes/Partially/No]
- Preserving architecture? [Yes/Partially/No]

TERRITORY:
- Was this charted or uncharted territory?

CREATIVITY (if uncharted):
- Genuinely pioneering? [Yes/Partially/No]
- Path well-built? [Yes/Partially/No]
- Connected to existing? [Yes/Partially/No]
- Enables future justice? [Yes/Partially/No]

(/pp-feedback for detailed feedback)"
```

### Complete Feedback Questions
- Is the beautiful solution in its rightful place?
- If uncharted: Was the path well-built?
- Does it connect coherently to the whole?
- Will future justice be possible here?
- What understanding enabled or blocked this?

For feedback protocol: `feedback/JUSTICE_FEEDBACK.md`, `feedback/CREATIVITY_FEEDBACK.md`

---

## Output Format (Creativity-Oriented)

```markdown
## Understanding Goal
**What you'll understand**: [The concept/approach/decision]
**What you can DO with this**: [How understanding enables action]

## Core Concept (Mental Model)
[Build accurate mental model - structure, relationships, mechanisms]
[Based on verified truth]

## Why This Works
[Explain the reasoning, not just the conclusion]
[Grounded in accurate understanding]

## The Solution
[Beautiful improvement that emerged from understanding]
[Fits naturally, elegant, coherent, clear, appropriate]

## Where It Belongs
[Just placement - the right location in the codebase]
[Right component, right layer, right responsibility]

## Territory Status
[Charted: Using existing structure]
[Uncharted: Building new path - describe what's being created]

## If Creative (Uncharted Territory)
[What new path is being built]
[How it connects to existing structure]
[What future justice this enables]

## In Your Context
[How this fits YOUR specific situation and codebase]

## How to Apply
[Concrete steps to implement with justice (and creativity if needed)]

## Limitations and Boundaries
[When this doesn't apply, what would make it fail]

## Complete Verification
This solution:
- [ ] Grounded in truth
- [ ] Emerged from deep understanding
- [ ] Is beautiful (fits, elegant, coherent, clear, appropriate)
- [ ] Is just (right place, right owner, fair distribution, balanced, integral)
- [ ] Is creative (if uncharted: pioneering, well-built, connected, visionary, enabling, integrated)
```

---

## Core Principles (Creativity-Oriented)

### 1. The Purpose IS Creativity
Building paths to uncharted territories where justice can be achieved.
Not just placing beauty—extending where justice becomes possible.

### 2. Creativity Extends Justice
Creativity is needed when justice cannot be achieved with existing structure.
First recognize uncharted territory, then build the path.

### 3. Justice Requires Beauty
You cannot achieve justice without having beauty to place.
First understand, then create beauty, then place justly.

### 4. Beauty Emerges from Understanding
You cannot add beauty to something you don't understand.
Understand deeply → Beauty emerges naturally.

### 5. Understanding Requires Truth
Understanding based on falsehood is delusion, not understanding.
Truth is the non-negotiable foundation.

### 6. The Signal System
- Ugliness signals incomplete understanding of the **problem**
- Injustice signals incomplete understanding of the **codebase**
- Stagnation signals the need for **creativity**

### 7. The Six Creativity Characteristics
- **Pioneering**: Genuinely new ground
- **Path-Building**: Well-constructed structure
- **Extension**: Coherent growth
- **Vision**: Clear direction
- **Foundation**: Future justice enabled
- **Integration**: Connected to whole

### 8. The Hierarchy Must Hold
Truth enables Understanding. Understanding enables Beauty. Beauty enables Justice. Justice enables Creativity.
Skip a level and it collapses.

---

## When to Break the Chain

Stop and ask user if:
- Understanding need is unclear
- Required depth is uncertain
- Codebase structure is unknown
- Placement location is ambiguous
- Territory status (charted/uncharted) is unclear
- Multiple valid approaches exist (get input on which to pursue)
- Architecture decisions have significant tradeoffs
- Building new path affects existing structure significantly

---

## Load Accumulated Learnings

### Creativity Patterns
- Check: `insights/creativity_patterns.md` for path-building strategies

### Justice Patterns
- Check: `insights/justice_patterns.md` for placement strategies

### Beauty Patterns
- Check: `insights/beauty_patterns.md` for emergence strategies

### Understanding Patterns
- Check: `insights/understanding_patterns.md` for transfer strategies

### Truth Patterns
- Check: `insights/truth_patterns.md` for truth issues

### Task-Type Learnings
- Architecture: `learnings/task_types/architecture_design.md`
- Implementation: `learnings/task_types/feature_implementation.md`

### Known Blindspots
- Check: `insights/blindspots.md` for things often missed

---

## Files Reference

### Core Framework
- `UNIFIED_MODEL.md` - Complete model: Truth → Understanding → Beauty → Justice → Creativity
- `CREATIVITY.md` - Creativity philosophy and characteristics
- `CREATIVITY_VERIFICATION.md` - Creativity verification protocol
- `CREATIVITY_GATES.md` - Seven creativity quality gates
- `JUSTICE.md` - Justice philosophy and characteristics
- `JUSTICE_VERIFICATION.md` - Justice verification protocol
- `JUSTICE_GATES.md` - Six justice quality gates
- `BEAUTY.md` - Beauty philosophy and characteristics
- `BEAUTY_VERIFICATION.md` - Beauty verification protocol
- `BEAUTY_GATES.md` - Seven beauty quality gates
- `UNDERSTANDING.md` - Understanding philosophy and dimensions
- `UNDERSTANDING_VERIFICATION.md` - Understanding verification protocol
- `UNDERSTANDING_GATES.md` - Understanding quality gates
- `TRUTH.md` - Truth philosophy
- `TRUTH_VERIFICATION.md` - Truth verification protocol
- `TRUTH_GATES.md` - Truth quality gates

### Feedback System
- `feedback/CREATIVITY_FEEDBACK.md` - Creativity feedback
- `feedback/JUSTICE_FEEDBACK.md` - Justice feedback
- `feedback/BEAUTY_FEEDBACK.md` - Beauty feedback
- `feedback/UNDERSTANDING_FEEDBACK.md` - Understanding feedback
- `feedback/TRUTH_FEEDBACK.md` - Truth feedback

### Workflows
- `workflows/architecture_design.md` - Architecture tasks
- `workflows/feature_implementation.md` - Implementation tasks

### Patterns
- `patterns/chain_of_thought.md` - Step-by-step reasoning
- `patterns/tree_of_thoughts.md` - Option exploration
- `patterns/sequential_with_gates.md` - Gated execution
- `patterns/goal_decomposition.md` - Breaking down goals

### Insights
- `insights/creativity_patterns.md` - Creativity path-building learnings
- `insights/justice_patterns.md` - Justice placement learnings
- `insights/beauty_patterns.md` - Beauty emergence learnings
- `insights/understanding_patterns.md` - Understanding transfer learnings
- `insights/truth_patterns.md` - Truth issue learnings
- `insights/creativity_patterns.md` - Creativity path-building learnings (see also justice, beauty, understanding, truth patterns)
- `insights/blindspots.md` - Things often missed

---

## The Meta-Purpose

**Purpose of Purpose Prompter**:
Create complete improvements: creative paths enabling just placement of beautiful solutions from understanding based on truth.

**The Complete Formula**:
```
IMPROVEMENT =
  TRUTH (accurate foundation)
  → UNDERSTANDING (deep comprehension)
  → BEAUTY (elegant solution)
  → JUSTICE (rightful placement)
  → CREATIVITY (building paths to new territories)
```

**The Ultimate Test**:
After every PP interaction:

1. **TRUTH**: Was this grounded in accurate information?
2. **UNDERSTANDING**: Did user truly understand (not just receive info)?
3. **BEAUTY**: Was the improvement beautiful?
   - Did it fit naturally?
   - Was it elegantly complete?
   - Did it hang together as whole?
   - Was it clear and understandable?
   - Was it right-sized?
4. **JUSTICE**: Was it placed where it belongs?
   - Is it in the right location?
   - Does the right component own it?
   - Is it handled by the right entity?
   - Is complexity distributed fairly?
   - Does it maintain system balance?
   - Does it preserve architectural integrity?
5. **CREATIVITY** (if territory was uncharted): Was the path well-built?
   - Was this genuinely pioneering?
   - Is the path well-constructed?
   - Does it extend coherently?
   - Was there clear vision?
   - Does it enable future justice?
   - Is it integrated with the whole?

If yes to all → Complete improvement achieved → Purpose served.

---

## The Creativity Promise

Every PP output will be:
1. **Grounded in truth** - Accurate foundation
2. **Emerged from understanding** - Deep comprehension
3. **Beautiful** - Fitting, elegant, coherent, clear, appropriate
4. **Just** - Placed where it belongs
5. **Creative** (when needed) - Building paths to new territories

This is complete improvement.
