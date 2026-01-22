# Justice-Oriented Feedback Protocol

> **Core Question**: Was the beautiful solution placed where it belongs?
> Feedback measures JUSTICE achievement: beautiful solutions in their rightful places.

---

## The Justice Feedback Dimensions

### What We're Measuring

```
┌─────────────────────────────────────────────────────────────────────┐
│                  JUSTICE ACHIEVEMENT MATRIX                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│                    HIGH JUSTICE                                      │
│                       │                                              │
│   Beautiful but       │     IDEAL                                   │
│   Misplaced          │     Complete Justice                         │
│   ┌─────────────────┐ │  ┌─────────────────┐                       │
│   │ Great solution  │ │  │ Beautiful       │                       │
│   │ in wrong place  │ │  │ solution in     │                       │
│   │ (technical debt)│ │  │ rightful place  │                       │
│   │                 │ │  │ (true value)    │                       │
│   └─────────────────┘ │  └─────────────────┘                       │
│                       │                                              │
│   ────────────────────┼──────────────────── HIGH BEAUTY             │
│   LOW BEAUTY          │                                              │
│                       │                                              │
│   Ugly and Misplaced  │     Ugly but Placed                         │
│   ┌─────────────────┐ │  ┌─────────────────┐                       │
│   │ Bad solution    │ │  │ Suboptimal      │                       │
│   │ in wrong place  │ │  │ solution but    │                       │
│   │ (double harm)   │ │  │ at least it's   │                       │
│   │                 │ │  │ where it belongs│                       │
│   └─────────────────┘ │  └─────────────────┘                       │
│                       │                                              │
│                    LOW JUSTICE                                       │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Justice Feedback Collection Flow

### Step 1: Recall the Placement

```markdown
## Placement Recall

**Task**: [Brief description]

**What was placed**:
[The solution that was delivered]

**Where it was placed**:
[Location/component/layer where it landed]

**Intended justice characteristics**:
- Placement: [Why this location was chosen]
- Ownership: [Why this component owns it]
- Responsibility: [Why this entity handles it]
```

### Step 2: Assess Justice Achievement

```markdown
## Justice Achievement Assessment

**Rate each justice dimension**:

| Dimension | Rating | Notes |
|-----------|--------|-------|
| **Placement** | [Right / Partial / Wrong] | |
| **Ownership** | [Rightful / Partial / Wrong] | |
| **Responsibility** | [Appropriate / Partial / Inappropriate] | |
| **Proportion** | [Fair / Partial / Unfair] | |
| **Balance** | [Maintained / Partial / Disturbed] | |
| **Integrity** | [Preserved / Partial / Violated] | |

**Overall Justice Level**:

| Level | Description |
|-------|-------------|
| **Perfect Justice** | Beauty in exactly the right place |
| **Just** | Beauty appropriately placed |
| **Partial Justice** | Some placement issues |
| **Injustice** | Beauty significantly misplaced |
| **Grave Injustice** | Major architectural violation |

**Rating**: [Perfect Justice / Just / Partial Justice / Injustice / Grave Injustice]

**Evidence**:
[What indicates this rating?]
```

### Step 3: Diagnose Justice Gaps (If Any)

```markdown
## Justice Gap Analysis

### Which Gate Failed?

**Gate 1: Placement**:
- [ ] Wrong location
- [ ] Doesn't follow conventions
- [ ] Not discoverable

**Gate 2: Ownership**:
- [ ] Wrong component owns it
- [ ] Creates god class
- [ ] Creates feature envy

**Gate 3: Responsibility**:
- [ ] Wrong abstraction level
- [ ] Wrong entity type
- [ ] Mixed concerns

**Gate 4: Proportion**:
- [ ] Complexity leaked
- [ ] Simple things made complex
- [ ] Poor encapsulation

**Gate 5: Balance**:
- [ ] Breaks patterns
- [ ] Creates hotspots
- [ ] Fragments system

**Gate 6: Integrity**:
- [ ] Boundary violated
- [ ] Wrong dependency direction
- [ ] Architecture compromised

### Specific Gap

**What made it unjust (if applicable)?**
[Describe specific justice failure]

**What structural understanding was missing?**
[Root cause—justice requires understanding codebase structure]

**Where did it actually belong?**
[The just alternative location]
```

### Step 4: Justice Learning Capture

```markdown
## Justice Learning

### Positive (What Made It Just)

**Justice-enabling factors**:
- [Factor that contributed to just placement]
- [Factor that contributed to just placement]

**Why it was just**:
[What understanding enabled this justice]

**Pattern to reinforce**:
[Generalizable insight for future]

---

### Negative (What Made It Unjust)

**Justice-blocking factors**:
- [Factor that caused misplacement]
- [Factor that caused misplacement]

**Why it was unjust**:
[What understanding gap caused this]

**Pattern to avoid**:
[Generalizable warning for future]

---

### Justice Insight

**What I learned about placing beauty where it belongs**:
[Insight about justice achievement]

**What structural understanding would have helped**:
[The codebase comprehension that was needed]
```

### Step 5: Justice Improvement Recommendation

```markdown
## Justice-Oriented Improvement

### For Placement
[How to better identify natural locations]

### For Ownership
[How to better identify rightful owners]

### For Responsibility
[How to better match handlers to concerns]

### For Proportion
[How to better distribute complexity]

### For Balance
[How to better maintain system equilibrium]

### For Integrity
[How to better preserve architecture]

### Specific Gate to Strengthen
[Which justice gate needs work]
```

---

## Justice Feedback Entry Schema

```json
{
  "id": "uuid",
  "timestamp": "ISO8601",
  "task_type": "new_feature|refactoring|bug_fix|other",
  "task_summary": "Brief description",

  "placement": {
    "what_placed": "Description of solution",
    "where_placed": "Location in codebase",
    "why_there": "Reasoning for placement"
  },

  "justice_assessment": {
    "placement": "right|partial|wrong",
    "ownership": "rightful|partial|wrong",
    "responsibility": "appropriate|partial|inappropriate",
    "proportion": "fair|partial|unfair",
    "balance": "maintained|partial|disturbed",
    "integrity": "preserved|partial|violated",
    "overall": "perfect_justice|just|partial_justice|injustice|grave_injustice",
    "evidence": "What indicates this rating"
  },

  "justice_gap": {
    "gate_failed": "placement|ownership|responsibility|proportion|balance|integrity|none",
    "description": "Specific gap",
    "understanding_missing": "What structural comprehension was lacking",
    "just_alternative": "Where it actually belonged"
  },

  "learnings": {
    "positive": {
      "factors": ["What enabled justice"],
      "pattern": "Generalizable insight"
    },
    "negative": {
      "factors": ["What blocked justice"],
      "pattern": "Generalizable warning"
    },
    "justice_insight": "Insight about placing beauty where it belongs"
  },

  "improvement": {
    "placement": "How to better identify locations",
    "ownership": "How to better identify owners",
    "responsibility": "How to better match handlers",
    "proportion": "How to better distribute complexity",
    "balance": "How to better maintain equilibrium",
    "integrity": "How to better preserve architecture",
    "gate_to_strengthen": "Which gate needs work"
  }
}
```

---

## Quick Justice Feedback

For rapid feedback, use this minimal format:

```
/pp-justice-feedback
Justice: [Perfect Justice / Just / Partial Justice / Injustice]
Gate failed: [Placement / Ownership / Responsibility / Proportion / Balance / Integrity / None]
Key learning: [One sentence]
```

Or even simpler:
```
pp justice feedback: [just/unjust] because [reason]
```

---

## Justice Feedback Triggers

### When to Collect Justice Feedback

| Outcome | Feedback Depth |
|---------|----------------|
| Solution placed perfectly | Quick—what made it right |
| Solution placed appropriately | Quick confirmation |
| Some placement issues | Moderate—what to improve |
| Solution significantly misplaced | Deep—analyze the gap |
| Major architectural violation | Deep—prevent recurrence |

### Automatic Justice Check

After placing a solution:
```
"Justice check: Is this solution...
- In the right location? [Yes/Partially/No]
- Owned by the right component? [Yes/Partially/No]
- Handled by the right entity? [Yes/Partially/No]
- Distributing complexity fairly? [Yes/Partially/No]
- Maintaining system balance? [Yes/Partially/No]
- Preserving architecture? [Yes/Partially/No]

(/pp-justice-feedback for detailed logging)"
```

---

## Synthesizing Justice Feedback

### Justice Achievement Rate

```
Justice Rate = (Perfect Justice + Just) / Total Tasks

Trend: [Improving / Stable / Declining]
```

### Common Justice Failures

| Failure Type | Frequency | Gate | Structural Gap |
|--------------|-----------|------|----------------|
| [Type] | [Count] | [Gate] | [What wasn't understood about codebase] |

### Justice by Task Type

| Task Type | Justice Rate | Common Gap |
|-----------|--------------|------------|
| New features | X% | [Pattern] |
| Refactoring | X% | [Pattern] |
| Bug fixes | X% | [Pattern] |

---

## The Justice Test Questions

### For Self-Assessment

After placing a solution:

1. **PLACEMENT**: Would someone expect to find this here?
2. **OWNERSHIP**: Is this component the rightful owner?
3. **RESPONSIBILITY**: Is this the right entity to handle this?
4. **PROPORTION**: Is complexity in the right place?
5. **BALANCE**: Does this fit the existing patterns?
6. **INTEGRITY**: Does this respect the architecture?

If any answer reveals injustice → Find the right place

---

## Integrated Feedback: Complete Hierarchy

### Full Unified Feedback Format

```markdown
## Integrated Justice Feedback

**Task**: [Description]

### Truth Dimension
- Information accurate: [Yes/Partially/No]
- Confidence calibrated: [Yes/Over/Under]

### Understanding Dimension
- User understands: [Enabled/Understands/Knows/Informed/Confused]
- Can explain, apply, know limits: [Yes/Partially/No]

### Beauty Dimension
- Fit: [Natural/Partial/Forced]
- Elegance: [Elegant/Cluttered/Incomplete]
- Coherence: [Unified/Partial/Fragmented]
- Clarity: [Clear/Partial/Obscure]
- Appropriateness: [Right-sized/Over/Under]

### Justice Dimension
- Placement: [Right/Partial/Wrong]
- Ownership: [Rightful/Partial/Wrong]
- Responsibility: [Appropriate/Partial/Inappropriate]
- Proportion: [Fair/Partial/Unfair]
- Balance: [Maintained/Partial/Disturbed]
- Integrity: [Preserved/Partial/Violated]

### Combined Assessment
**This improvement was**: [Perfect / Complete / Partial / Failed]

**The hierarchy held?**:
- Truth → Understanding → Beauty → Justice: [Yes / Broke at ___]

### Key Learning
[One integrated insight about creating just, beautiful improvements from understanding based on truth]
```

---

## From Justice Feedback to Improvement

### The Justice Improvement Loop

```
Justice Feedback
      │
      ▼
Identify Justice Gap
      │
      ├── Placement wrong → Better understand codebase organization
      │
      ├── Ownership wrong → Better understand component domains
      │
      ├── Responsibility wrong → Better understand abstraction levels
      │
      ├── Proportion wrong → Better understand complexity distribution
      │
      ├── Balance disturbed → Better understand existing patterns
      │
      └── Integrity violated → Better understand architecture
```

### The Core Insight

**Injustice signals incomplete understanding of codebase structure.**

When justice fails:
1. Don't place anyway
2. Identify what you don't understand about the codebase
3. Understand the structure more deeply
4. Find the rightful place
5. Place with justice

---

## Justice Feedback Quick Reference

**After every PP task**:
1. Was it just? [Perfect Justice/Just/Partial/Unjust]
2. Which dimension failed (if any)? [Placement/Ownership/Responsibility/Proportion/Balance/Integrity]
3. What structural understanding was missing? [One sentence]
4. What's one justice learning?

**Deep feedback when**:
- Solution is significantly misplaced
- Architecture was violated
- Novel insight about codebase structure
- Pattern is forming
