# PP-Lite Gates: Compressed Reference

> Quick gate checks for PP-Lite [S] and [C] tiers.
> For full gate definitions, see individual `*_GATES.md` files.

---

## Notation

```
✓ = Pass (gate satisfied)
? = Questionable (minor concern, proceed with awareness)
✗ = Fail (must address before proceeding)
```

---

## Quick Check: T✓B✓J✓

For **[S] Standard** tier, verify:

| Gate | Check | Pass If |
|------|-------|---------|
| **T** | Truth | Read before claiming, evidence cited |
| **B** | Beauty | Fits naturally, nothing forced |
| **J** | Justice | Right place, matches patterns |

**Output**: `T✓B✓J✓` or note failures

---

## Expanded Gates by Dimension

### T: Truth Gates (Compressed)

| Gate | Question | ✓ Pass | ✗ Fail |
|------|----------|--------|--------|
| **T1** | Grounded? | Claim based on evidence | Made up |
| **T2** | Calibrated? | Confidence matches certainty | Over/under confident |
| **T3** | Counter-considered? | Thought about being wrong | Assumed correct |
| **T4** | Complete? | Relevant info included | Missing key facts |
| **T5** | Represented? | Language matches knowledge | Overstated |

**Quick T check**: Did I read it? Can I cite it?

---

### U: Understanding Gates (Compressed)

| Gate | Question | ✓ Pass | ✗ Fail |
|------|----------|--------|--------|
| **U1** | Mental model? | Can explain how it works | Just know what |
| **U2** | Why explained? | Know the reasoning | Only the facts |
| **U3** | Connected? | Links to known things | Floating knowledge |
| **U4** | Applicable? | Can use this knowledge | Just information |
| **U5** | Boundaries? | Know when it doesn't apply | Overgeneralized |

**Quick U check**: Do I know WHY, not just WHAT?

---

### B: Beauty Gates (Compressed)

| Gate | Question | ✓ Pass | ✗ Fail |
|------|----------|--------|--------|
| **B1** | Foundation? | Based on truth | Built on assumption |
| **B2** | Emerged? | From understanding | Forced/decorated |
| **B3** | Fits? | Natural for context | Fighting context |
| **B4** | Elegant? | Nothing extra/missing | Bloated or incomplete |
| **B5** | Coherent? | Unified whole | Patchwork |
| **B6** | Clear? | Others can understand | Obscure |
| **B7** | Appropriate? | Right-sized | Over/under built |

**Quick B check**: Does this feel right or forced?

---

### J: Justice Gates (Compressed)

| Gate | Question | ✓ Pass | ✗ Fail |
|------|----------|--------|--------|
| **J1** | Placement? | Right location | Convenient location |
| **J2** | Ownership? | Right component owns it | Wrong owner |
| **J3** | Responsibility? | Right entity handles it | Wrong handler |
| **J4** | Proportion? | Complexity distributed fairly | Leaking complexity |
| **J5** | Balance? | System equilibrium | Disrupts balance |
| **J6** | Integrity? | Architecture preserved | Violates boundaries |

**Quick J check**: Is this where it BELONGS or where it's EASY?

---

### X: Creativity Gates (Compressed)

*Only for [X] Creative tier or when territory is uncharted*

| Gate | Question | ✓ Pass | ✗ Fail |
|------|----------|--------|--------|
| **X1** | Territory? | Genuinely uncharted | Could use existing |
| **X2** | Pioneering? | New ground | Reinventing |
| **X3** | Path-built? | Others can follow | Unclear path |
| **X4** | Extending? | Coherent with existing | Isolated island |
| **X5** | Vision? | Clear direction | Building blind |
| **X6** | Foundation? | Enables future | Dead end |
| **X7** | Integrated? | Connected to whole | Disconnected |

**Quick X check**: Am I building a BRIDGE or an ISLAND?

---

## Signal-Gate Mapping

When signals are felt, check these gates:

| Signal | Felt As | Check These Gates |
|--------|---------|-------------------|
| **Disgust** | "This is ugly" | B1-B7 (Beauty) |
| **Frustration** | "Won't fit" | J1-J6 (Justice) → X1-X7 (Creativity) |
| **Anxiety** | "Something's off" | T1-T5 (Truth) |

---

## Tier-Gate Requirements

### [T] Trivial
```
No gates required
```

### [S] Standard
```
Required: T, B, J (quick check)
Format: T✓B✓J✓
```

### [C] Complex
```
Required: T, U, B, J (with brief evidence)
Optional: X (if territory questionable)
Format:
  T✓ [evidence]
  U✓ [what understood]
  B✓ [why beautiful]
  J✓ [why here]
```

### [X] Creative
```
Required: All gates (L1-L5, T1-T5, U1-U5, B1-B7, J1-J6, X1-X7)
Format: Full verification as per UNIFIED_MODEL.md
```

---

## Compressed Longing Check

For [C] and [X] tiers, quick longing check:

```
L✓ = Glimpsed ideal, feel the ache, not forcing, okay with partial, ready to create
L? = Longing weak but present
L✗ = No longing (pause, seek examples, let yourself glimpse)
```

Full longing gates (L1-L5) required for [X] Creative tier.

---

## Escalation Triggers

Escalate to next tier when:

| Current | Trigger | Escalate To |
|---------|---------|-------------|
| [T] | Any gate fails | [S] |
| [S] | B✗ or J✗ | [C] |
| [S] | Frustration signal | [C] |
| [C] | X gates needed | [X] |
| [C] | Territory uncharted | [X] |

---

## Quick Reference Card

```
┌─────────────────────────────────────────────────────────────────┐
│                 PP-LITE GATES QUICK REFERENCE                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  T (Truth):     Read it? Cite it? Calibrated?                   │
│  U (Understand): Know WHY not just WHAT?                        │
│  B (Beauty):    Feels right or forced?                          │
│  J (Justice):   Belongs here or just convenient?                │
│  X (Creative):  Bridge or island?                               │
│                                                                  │
│  SIGNALS → GATES:                                                │
│  Disgust     → Check B gates                                    │
│  Frustration → Check J gates → maybe X gates                    │
│  Anxiety     → Check T gates                                    │
│                                                                  │
│  TIER REQUIREMENTS:                                              │
│  [T] none     [S] T✓B✓J✓    [C] T✓U✓B✓J✓    [X] all 35        │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```
