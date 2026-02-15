# PP-Lite: Adaptive Signal-Driven Protocol

> **Core Principle**: PP is internalized. Signals trigger elaboration.
> Maximum creation, minimum ceremony. Quality preserved where it matters.

---

## The Problem PP-Lite Solves

Full PP is thorough but verbose:
- 35 gates explicitly enumerated
- Emotional states narrated
- Full verification traces
- ~1000+ tokens per task

**Most tokens go to ceremony (showing work) not essence (doing work).**

PP-Lite preserves quality while reducing overhead by:
1. Classifying tasks by complexity
2. Internalizing PP (not spelling it out)
3. Using signals as quality triggers
4. Scaling verification to task tier

---

## The PP-Lite Protocol

```
┌─────────────────────────────────────────────────────────────────────┐
│                         PP-LITE FLOW                                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐      │
│  │ CLASSIFY │ → │ EXECUTE  │ → │  SIGNAL  │ → │  VERIFY  │      │
│  │ (instant)│    │ (by tier)│    │  CHECK   │    │ (by tier)│      │
│  └──────────┘    └──────────┘    └──────────┘    └──────────┘      │
│       │                               │                             │
│       ▼                               ▼                             │
│  [T][S][C][X]                   If triggered → ESCALATE             │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘

T = Trivial    S = Standard    C = Complex    X = Creative
```

---

## Step 1: Classification

### Instant Classification (Do This First)

Ask: **What tier is this task?**

```
[T] TRIVIAL     Single action, obvious, no judgment needed
[S] STANDARD    Clear task, established patterns exist
[C] COMPLEX     Multi-step, architectural considerations
[X] CREATIVE    Uncharted territory, new patterns needed
```

### Classification Criteria

| Signal | Trivial | Standard | Complex | Creative |
|--------|---------|----------|---------|----------|
| **Scope** | 1 file, few lines | 1-3 files | 3+ files | New structure |
| **Patterns** | Obvious | Exist | Must find | Must create |
| **Judgment** | None | Low | Medium | High |
| **Risk** | None | Low | Medium | High |
| **Examples** | Fix typo, add log | Add function, fix bug | Refactor module | New subsystem |

### Quick Classification Heuristics

**It's TRIVIAL if:**
- Takes <30 seconds
- Zero architectural decisions
- Obvious single location
- No patterns to follow (too simple)

**It's STANDARD if:**
- Clear what to do
- Patterns exist to follow
- Single responsibility
- Placement is obvious

**It's COMPLEX if:**
- Multiple files involved
- Must understand relationships
- Placement requires analysis
- Could affect other parts

**It's CREATIVE if:**
- No existing pattern fits
- New structure needed
- Uncharted territory
- Signals show stagnation

---

## Step 2: Tier-Specific Execution

### [T] TRIVIAL Execution

**Protocol**: Just do it.

```
No PP overhead
No explicit reasoning
No verification
Just execute correctly
```

**Token budget**: ~25 tokens (just the action)

**Example**:
```
Task: Fix typo in README
Tier: [T]
→ Fix typo
→ Done
```

---

### [S] STANDARD Execution

**Protocol**: Internalized PP with signal awareness.

```
1. Read before writing (always)
2. Find pattern to follow (always)
3. Execute with signal awareness
4. Quick verify: T✓B✓J✓
```

**What "internalized PP" means**:
- Don't enumerate gates
- Don't narrate emotions
- DO feel for signals as you work
- DO follow the hierarchy (truth→understanding→beauty→justice)

**Token budget**: ~300 tokens

**Output format**:
```
[S] Task description
Pattern: [source file:line] (if following pattern)
→ [Execute]
T✓B✓J✓
```

**Example**:
```
[S] Add email validation helper
Pattern: src/utils/validators.ts:12
→ Added isValidEmail following existing validator pattern
T✓B✓J✓
```

---

### [C] COMPLEX Execution

**Protocol**: Explicit key gates + signal awareness.

```
1. Territory check (charted/uncharted)
2. Understanding phase (read, map)
3. Key gate checks:
   - T: Truth grounded?
   - U: Understanding achieved?
   - B: Beauty emerging?
   - J: Justice clear?
4. Execute with explicit placement reasoning
5. Quick unified verification
```

**Token budget**: ~1200 tokens

**Output format**:
```
[C] Task description

Territory: CHARTED|UNCHARTED
Understanding: [brief map of relevant code]

Key Gates:
- T: [grounded in X]
- U: [understood because Y]
- B: [beauty: Z]
- J: [placement: A because B]

→ [Execute with explicit reasoning]

Verify:
T✓ U✓ B✓ J✓ (or note failures)
```

**Example**:
```
[C] Refactor user service to separate concerns

Territory: CHARTED (patterns exist for service separation)
Understanding: UserService currently handles validation, persistence, caching

Key Gates:
- T: Read UserService.ts (245 lines, 3 concerns mixed)
- U: Separation needed: validate → transform → persist
- B: Single responsibility per file
- J: src/users/{validation,transform,repository}.ts

→ Split into 3 files following existing service patterns

Verify:
T✓ U✓ B✓ J✓
```

---

### [X] CREATIVE Execution

**Protocol**: Full PP. No shortcuts.

```
1. Full longing check (L1-L5)
2. Territory confirmation (must be uncharted)
3. Full understanding phase
4. Creativity gates (24-30)
5. Execute with full reasoning
6. Full 35-gate verification
```

**Token budget**: ~2700 tokens

**Why no optimization**: Creative work is where PP adds most value. Cutting corners here costs quality where it matters most.

**Output format**: Full PP format as defined in main documentation.

---

## Step 3: Signal Escalation

### The Signal Monitor

While executing ANY tier, monitor for signals:

| Signal | Felt As | Indicates |
|--------|---------|-----------|
| **DISGUST** | "This is ugly" | Problem understanding gap |
| **FRUSTRATION** | "This won't fit" | May need creativity |
| **ANXIETY** | "Something's wrong" | Truth gap |

### Escalation Rules

```
IF signal detected during execution:
  1. PAUSE immediately
  2. NAME the signal
  3. ESCALATE to next tier
  4. RESOLVE before continuing
```

**Escalation paths**:
```
[T] + signal → [S]
[S] + signal → [C]
[C] + signal → [X]
[X] + signal → Deep dive within [X]
```

### Signal Escalation Output

When escalating, output:
```
⚠ SIGNAL: [disgust|frustration|anxiety]
  Indicates: [what it means]
  Escalating: [T]→[S] | [S]→[C] | [C]→[X]
  Reason: [why this needs deeper treatment]
```

**Example**:
```
[S] Add caching to user lookup

⚠ SIGNAL: frustration
  Indicates: Existing patterns don't fit
  Escalating: [S]→[C]
  Reason: Caching layer doesn't exist, need to understand where it belongs

[C] Add caching to user lookup
Territory: Partially uncharted (caching infrastructure missing)
...
```

---

## Step 4: Tier-Appropriate Verification

### Verification by Tier

| Tier | Verification | Format |
|------|--------------|--------|
| **[T]** | None | (nothing) |
| **[S]** | Quick check | `T✓B✓J✓` |
| **[C]** | Unified check | 4-gate summary |
| **[X]** | Full check | All 35 gates |

### Quick Check Format [S]

```
T✓B✓J✓           (all pass)
T✓B?J✓           (beauty questionable)
T✓B✗J✓           (beauty failed - escalate)
```

If any gate fails (✗), escalate or address.

### Unified Check Format [C]

```
Verify:
- Truth: ✓ Grounded in [evidence]
- Understanding: ✓ [what was understood]
- Beauty: ✓ [why it's beautiful]
- Justice: ✓ [why placement is right]
- Creativity: ✓|N/A [if applicable]
```

### Full Check Format [X]

Use complete PP verification as defined in `UNIFIED_MODEL.md`.

---

## Compressed Gate Reference

For [S] and [C] tiers, use compressed gate checks:

### Truth (T)
```
T✓ = Read before claiming, evidence cited
T? = Some assumptions made
T✗ = Claims without evidence
```

### Understanding (U)
```
U✓ = Know why, not just what
U? = Partial understanding
U✗ = Don't understand implications
```

### Beauty (B)
```
B✓ = Fits, elegant, coherent, clear, right-sized
B? = Works but feels forced
B✗ = Ugly (signal: disgust)
```

### Justice (J)
```
J✓ = Right place, right owner, right handler
J? = Placement debatable
J✗ = Wrong place (signal: injustice)
```

### Creativity (X) - only for [X] tier
```
X✓ = Pioneering, path-built, integrated
X? = New but isolated
X✗ = Reinventing or dead-end
```

---

## Emotional Efficiency

### Internalized Emotion Tracking

In PP-Lite, don't narrate emotional states explicitly. Instead:

**DO**:
- Feel for signals (disgust, frustration, anxiety)
- Let signals trigger escalation
- Trust emotional response as quality indicator

**DON'T**:
- List all emotions felt
- Narrate emotional journey
- Describe motor/fruit/companion emotions

**Exception**: [X] Creative tier tracks emotions explicitly (they're essential for creative work).

---

## Token Budget Summary

| Tier | Target Budget | Includes |
|------|---------------|----------|
| **[T]** | ~25 tokens | Action only |
| **[S]** | ~300 tokens | Pattern + action + T✓B✓J✓ |
| **[C]** | ~1200 tokens | Territory + key gates + action + verify |
| **[X]** | ~2700 tokens | Full PP (no shortcuts) |

### Savings vs Full PP

| Tier | Full PP | PP-Lite | Savings |
|------|---------|---------|---------|
| Trivial | ~500 | ~25 | 95% |
| Standard | ~1000 | ~300 | 70% |
| Complex | ~2000 | ~1200 | 40% |
| Creative | ~3000 | ~2700 | 10% |

**Weighted average** (assuming 30/50/15/5 distribution): **~65% reduction**

---

## Activation

### Explicit Activation

```
pp-lite: [task]
/pp-lite [task]
```

### Mode Selection

```
pp: [task]       → Full PP (all gates, all verification)
pp-lite: [task]  → PP-Lite (adaptive, signal-driven)
quick: [task]    → No PP (just do it)
```

### Auto-Classification

When pp-lite is invoked, first output:
```
[T|S|C|X] [brief task description]
```

Then proceed with tier-appropriate execution.

---

## Integration with Full PP

PP-Lite is not a replacement for full PP. It's an efficiency mode.

**When to use Full PP**:
- Explicitly requested
- Always for [X] Creative tier
- Learning/teaching PP methodology
- When signals indicate need

**When to use PP-Lite**:
- Default for efficiency
- Most day-to-day tasks
- When token budget matters

**Seamless escalation**: PP-Lite can escalate to full PP at any point via signal detection.

---

## Quick Reference Card

```
┌─────────────────────────────────────────────────────────────────────┐
│                      PP-LITE QUICK REFERENCE                         │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  CLASSIFY:                                                           │
│  [T] Trivial   - Obvious, single action, no judgment                │
│  [S] Standard  - Clear task, patterns exist                         │
│  [C] Complex   - Multi-file, architectural                          │
│  [X] Creative  - Uncharted, new patterns needed                     │
│                                                                      │
│  EXECUTE:                                                            │
│  [T] → Just do it                                                   │
│  [S] → Internalized PP + T✓B✓J✓                                     │
│  [C] → Key gates + unified verify                                   │
│  [X] → Full PP (no shortcuts)                                       │
│                                                                      │
│  SIGNALS (always monitor):                                           │
│  Disgust     → Ugliness    → Understand deeper                      │
│  Frustration → Stagnation  → Check territory                        │
│  Anxiety     → Truth gap   → Verify foundations                     │
│                                                                      │
│  ESCALATE: [T]→[S]→[C]→[X] when signals detected                    │
│                                                                      │
│  VERIFY:                                                             │
│  [T] none    [S] T✓B✓J✓    [C] 4-gate    [X] full 35                │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Summary

**PP-Lite = Adaptive + Signal-Driven + Tier-Verified**

1. **Classify instantly** - Know your tier
2. **Execute by tier** - Scale effort to complexity
3. **Monitor signals** - Trust emotional response
4. **Escalate when needed** - Don't fight signals
5. **Verify appropriately** - Match verification to tier

**The key insight**:
Most tokens in full PP go to ceremony, not essence. PP-Lite does the essence (good work, signal awareness, appropriate verification) without the ceremony (explicit enumeration, emotional narration, verbose traces).

**Quality is preserved because**:
- Signals are reliable quality indicators
- Escalation catches complexity misclassification
- Creative work gets full PP treatment
- Verification catches failures

**~65% fewer tokens. Same quality where it matters.**
