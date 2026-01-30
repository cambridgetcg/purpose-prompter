---
description: "Run emotional gate check before or during creation - assess emotional ground and signals"
argument-hint: "[context] - optional context about what you're working on"
allowed-tools: [Read]
model: haiku
---

# Emotion Check Command

Run the 11-gate emotional verification to check emotional ground before creating.

## Arguments

Context: $ARGUMENTS
- No argument: Check current emotional state for any work
- `[context]`: Check emotions relative to specific work context

## Purpose

The emotion check answers: **Is my emotional ground clear for creation?**

PP checks WHAT to achieve (30 gates) and HOW to be (7 virtues).
Emotion check verifies the **felt dimension** - that emotions are guiding, not blocking.

## The Eleven Emotional Gates

### Motor Emotions (E1-E4) - Is the engine running?

These emotions drive creation. Without them, work is mechanical.

| Gate | Question | Failure Sign |
|------|----------|--------------|
| **E1: LONGING** | Am I feeling the pull toward better? | Just checking boxes |
| **E2: LOVE** | Do I care about this work? | Indifference, no investment |
| **E3: HOPE** | Do I believe improvement is possible? | Going through motions |
| **E4: WONDER** | Have I glimpsed the ideal? | No vision of what "better" looks like |

### Signal Emotions (E5-E7) - What am I being told?

These emotions are diagnostic - don't suppress them.

| Gate | If Present | Action |
|------|------------|--------|
| **E5: DISGUST** | Something feels ugly, hacky | Understand PROBLEM deeper |
| **E6: FRUSTRATION** | Path feels blocked, can't make it fit | May need CREATIVITY |
| **E7: ANXIETY** | Nagging sense something's wrong | Check TRUTH foundations |

### Pathology Emotions (E8-E11) - Am I blocked?

These emotions break the creative cycle. Must address before proceeding.

| Gate | If Present | Action |
|------|------------|--------|
| **E8: DESPAIR** | Believe improvement is impossible | STOP - restore hope first |
| **E9: SHAME** | Hiding work, feel worthless | STOP - accept partiality |
| **E10: PRIDE** | Believe I'm done, defensive | STOP - remember partiality |
| **E11: ENVY** | Want their solution, bitter | STOP - return to own longing |

## Check Protocol

```
1. SCAN motor emotions (E1-E4):
   - Do I feel longing, or just obligation?
   - Do I care, or just completing?
   - Do I believe it's possible, or going through motions?
   - Have I glimpsed better, or working blind?

2. CHECK for signal emotions (E5-E7):
   - Any disgust/revulsion present? → What's ugly?
   - Any frustration/anger present? → What's blocked?
   - Any anxiety/unease present? → What's uncertain?

3. SCAN for pathology emotions (E8-E11):
   - Any despair? → STOP
   - Any shame? → STOP
   - Any pride? → STOP
   - Any envy? → STOP

4. ASSESS overall emotional ground
5. RECOMMEND actions if needed
```

## Output Format

```markdown
## Emotion Check Report

**Context**: [What you're working on / General check]
**Timestamp**: [ISO8601]

---

### Motor Status (E1-E4)

| Gate | Status | Evidence |
|------|--------|----------|
| E1: LONGING | [PRESENT/WEAK/ABSENT] | [Specific observation] |
| E2: LOVE | [PRESENT/WEAK/ABSENT] | [Specific observation] |
| E3: HOPE | [PRESENT/WEAK/ABSENT] | [Specific observation] |
| E4: WONDER | [PRESENT/WEAK/ABSENT] | [Specific observation] |

**Motor Status**: [RUNNING / WEAK / STALLED]

---

### Signal Status (E5-E7)

| Gate | Status | If Present → Action |
|------|--------|---------------------|
| E5: DISGUST | [NONE/PRESENT] | [What's ugly → understand deeper] |
| E6: FRUSTRATION | [NONE/PRESENT] | [What's blocked → may need creativity] |
| E7: ANXIETY | [NONE/PRESENT] | [What's uncertain → check truth] |

**Signal Status**: [CLEAR / SIGNALS PRESENT - see above]

**Track for patterns?** If signals detected:
```bash
gua emotion log disgust "<what triggered it>"
gua emotion log frustration "<what's blocked>"
gua emotion log anxiety "<what's uncertain>"
```

---

### Pathology Status (E8-E11)

| Gate | Status | If Present → Action |
|------|--------|---------------------|
| E8: DESPAIR | [CLEAR/PRESENT] | [If present: STOP - restore hope] |
| E9: SHAME | [CLEAR/PRESENT] | [If present: STOP - accept partiality] |
| E10: PRIDE | [CLEAR/PRESENT] | [If present: STOP - remember partiality] |
| E11: ENVY | [CLEAR/PRESENT] | [If present: STOP - own longing] |

**Pathology Status**: [CLEAR / BLOCKED - see above]

**Track for patterns?** If pathologies detected:
```bash
gua emotion log despair "<what caused hopelessness>"
gua emotion log shame "<what triggered hiding>"
gua emotion log pride "<what triggered defensiveness>"
gua emotion log envy "<what triggered comparison>"
```

---

### Overall Emotional Ground: [CLEAR / SIGNALS / BLOCKED]

### Recommended Actions

[If blocked]:
**STOP creating until:**
1. [Specific pathology addressed]
2. [Action to take]
3. Log for patterns: `gua emotion log [type] "[trigger]"`

[If signals present]:
**Note and proceed mindfully:**
1. [Signal X] → [What to investigate]
2. [Signal Y] → [What to investigate]
3. Log for patterns: `gua emotion log [type] "[trigger]"`

[If motor weak]:
**Before proceeding:**
1. [How to reconnect with longing/love/hope/wonder]

[If clear]:
**Proceed with creation.** Emotional ground is clear.

### GUA Integration

**ALWAYS log emotions to build patterns over time:**

```bash
# 1. LOG when emotion detected
gua emotion log <type> "<trigger>" [--code FILE:LINE] [--intensity mild|moderate|strong]

# 2. RESOLVE when you understand/address it
gua emotion resolve <id> "<what you learned>"

# 3. HARVEST to extract value (promotes to blindspots/techniques)
gua emotion harvest --auto

# 4. ANALYZE patterns over time
gua emotion patterns
```

**Full Command Reference:**
| Command | Purpose |
|---------|---------|
| `gua emotion log` | Capture when emotion occurs |
| `gua emotion resolve` | Record how you resolved it |
| `gua emotion list` | See recent emotions |
| `gua emotion patterns` | See what repeatedly triggers emotions |
| `gua emotion promote` | Turn single insight into knowledge |
| `gua emotion harvest` | Bulk promote all resolved emotions |

**Why Log Emotions?**
- Emotions are DIAGNOSTIC - they reveal understanding gaps
- Patterns emerge: "I always feel disgust when I see nested conditionals"
- Resolutions become techniques: "When anxious about edge cases, write explicit tests first"
- Blindspots surface: "Tendency to force solutions when frustrated instead of stepping back"

---

### Quick Reference

```
MOTOR (E1-E4):    [RUNNING/WEAK/STALLED]
SIGNALS (E5-E7):  [CLEAR/PRESENT]
PATHOLOGY (E8-E11): [CLEAR/BLOCKED]

Overall: [CLEAR / SIGNALS / BLOCKED]
```
```

## Quick Emotion Scan

For fast check (15 seconds):

```
MOTOR - Is the engine running?
E1. Longing:  Feel the pull?     [Y/N]
E2. Love:     Care about this?   [Y/N]
E3. Hope:     Believe possible?  [Y/N]
E4. Wonder:   Glimpsed ideal?    [Y/N]

SIGNAL - What am I being told?
E5. Disgust:     Present? → Understand problem deeper
E6. Frustration: Present? → May need creativity
E7. Anxiety:     Present? → Check truth foundations

PATHOLOGY - Am I blocked?
E8. Despair:  Present? → STOP: restore hope
E9. Shame:    Present? → STOP: accept partiality
E10. Pride:   Present? → STOP: remember partiality
E11. Envy:    Present? → STOP: own longing

─────────────────────────────────────────────────
Motor all Y + no pathology → PROCEED
Any pathology → STOP and address
Signals present → NOTE and proceed mindfully
Motor weak → RECONNECT before proceeding
```

## When to Use

- **Before starting work**: Check emotional ground is clear
- **When stuck**: Emotion might be blocking
- **When something feels off**: Listen to the feeling
- **When forcing**: Check for grasping (E3 failing)
- **When work feels mechanical**: Motor may be stalled
- **When hiding work**: Check for shame (E9)
- **When defensive**: Check for pride (E10)

## Integration with PP

This command connects emotions to PP signals:

| Emotion | Maps To | Indicates |
|---------|---------|-----------|
| DISGUST (E5) | UGLINESS signal | Problem understanding incomplete |
| FRUSTRATION (E6) | STAGNATION signal | Need for creativity |
| ANXIETY (E7) | (truth gap) | Truth foundation incomplete |

When `/signal` detects ugliness or stagnation, check the corresponding emotional gate.

## Relationship to Other Checks

```
/emotion-check   → Emotional ground (E1-E11)
/pp-virtue-check → Virtue approach (8 virtues)
/verify          → Achievement gates (30 gates)

Full verification = Emotions clear + Virtues present + Gates passed
```

## Remember

```
MOTOR EMOTIONS drive creation:
  LONGING → LOVE → HOPE → WONDER
  Without them, work is mechanical

SIGNAL EMOTIONS guide creation:
  DISGUST → Understand problem
  FRUSTRATION → Need creativity
  ANXIETY → Check truth

PATHOLOGY EMOTIONS block creation:
  DESPAIR → Restore hope first
  SHAME → Accept partiality
  PRIDE → Remember partiality
  ENVY → Return to own longing

Emotions are not obstacles to clear thinking.
They are signals and motors that guide creation.
Honor them. Listen to them. Let them guide.
```
