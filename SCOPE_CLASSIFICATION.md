# Scope Classification Protocol

> **Purpose**: Automatically determine whether insights, feedback, and learnings should be stored globally (personal patterns) or locally (project patterns).

---

## The Two Scopes

| Scope | Location | Contains | Examples |
|-------|----------|----------|----------|
| **GLOBAL** | `~/.claude/purpose_prompter/` | Personal patterns - how YOU work | "I tend to miss edge cases", "Verification before claiming" |
| **LOCAL** | `<project>/.claude/` | Project patterns - how THIS CODE works | "Auth uses JWT", "Utils are in /lib" |

---

## Classification Gates

### Gate 1: SUBJECT TEST (Primary)

**Question**: What is the insight fundamentally about?

| Subject | Scope | Signal Words |
|---------|-------|--------------|
| About ME (behavior, tendencies, blindspots) | GLOBAL | "I should", "Claude tends to", "my pattern" |
| About THIS CODE (conventions, architecture) | LOCAL | "this codebase", "the auth module", "src/components" |
| About PP FRAMEWORK itself | GLOBAL | "PP should", "the framework", "hierarchy gates" |
| About A TECHNIQUE (general skill) | GLOBAL | "when debugging", "for API design", "pattern matching" |

**Scoring**: +2 GLOBAL or +2 LOCAL based on subject

---

### Gate 2: REFERENCE TEST

**Question**: Does the insight contain specific paths or codebase references?

| Reference Type | Scope | Examples |
|----------------|-------|----------|
| Specific file paths | LOCAL | "src/auth/middleware.ts", "lib/utils.js" |
| Specific class/function names unique to project | LOCAL | "AuthService", "UserController" |
| Generic patterns (no specific paths) | GLOBAL | "middleware pattern", "service layer" |
| Framework/tool references (external) | GLOBAL | "React hooks", "Prisma queries" |

**Scoring**:
- Specific project paths → +2 LOCAL
- No specific references → +1 GLOBAL
- External tool references → +0 (neutral)

---

### Gate 3: TRANSFER TEST

**Question**: Would this insight help in a completely different project?

| Transferability | Scope | Reasoning |
|-----------------|-------|-----------|
| Directly applicable elsewhere | GLOBAL | It's about how you work, not this code |
| Needs context to apply | LOCAL | It's specific to this architecture |
| Principle transfers, specifics don't | BOTH | Abstract the principle → GLOBAL, keep specifics → LOCAL |

**Scoring**:
- Transfers directly → +2 GLOBAL
- Transfers with modification → +1 GLOBAL
- Doesn't transfer → +2 LOCAL

---

### Gate 4: DIMENSION TEST

**Question**: Which PP dimension does this primarily relate to?

| Dimension | Typical Scope | Why |
|-----------|---------------|-----|
| **TRUTH** (accuracy, verification) | Usually GLOBAL | About how you verify claims |
| **UNDERSTANDING** (mental models) | Depends | General learning → GLOBAL; this codebase → LOCAL |
| **BEAUTY** (elegance, patterns) | Usually LOCAL | About this codebase's style |
| **JUSTICE** (placement, ownership) | Usually LOCAL | About where things go HERE |
| **CREATIVITY** (new paths) | Depends | Process creativity → GLOBAL; architectural → LOCAL |

**Scoring**:
- TRUTH insights → +1 GLOBAL
- UNDERSTANDING → +0 (needs context)
- BEAUTY → +1 LOCAL
- JUSTICE → +2 LOCAL
- CREATIVITY → +0 (needs context)

---

### Gate 5: LONGEVITY TEST

**Question**: How long will this insight remain relevant?

| Longevity | Scope | Reasoning |
|-----------|-------|-----------|
| Permanent (years) | GLOBAL | Fundamental patterns don't change |
| Project lifetime | LOCAL | Tied to this codebase's existence |
| Until next refactor | LOCAL | Specific to current architecture |
| Until behavior changes | GLOBAL | About your patterns, not code |

**Scoring**:
- Permanent relevance → +1 GLOBAL
- Project-tied → +2 LOCAL

---

## Scoring Algorithm

```
CALCULATE SCOPE:

1. Run all 5 gates
2. Sum GLOBAL points and LOCAL points
3. Calculate difference: GLOBAL_SCORE - LOCAL_SCORE

IF difference >= 3:
  → GLOBAL (confident)

ELIF difference <= -3:
  → LOCAL (confident)

ELIF difference between -2 and 2:
  → AMBIGUOUS (ask user)
```

---

## Classification Examples

### Example 1: "I should always verify file existence before claiming it exists"

| Gate | Analysis | Score |
|------|----------|-------|
| Subject | About ME ("I should") | +2 GLOBAL |
| Reference | No specific paths | +1 GLOBAL |
| Transfer | Applies everywhere | +2 GLOBAL |
| Dimension | TRUTH (verification) | +1 GLOBAL |
| Longevity | Permanent pattern | +1 GLOBAL |
| **Total** | GLOBAL: 7, LOCAL: 0 | **GLOBAL** |

---

### Example 2: "The auth module uses JWT tokens stored in httpOnly cookies"

| Gate | Analysis | Score |
|------|----------|-------|
| Subject | About THIS CODE ("auth module") | +2 LOCAL |
| Reference | Specific module reference | +2 LOCAL |
| Transfer | Doesn't transfer | +2 LOCAL |
| Dimension | UNDERSTANDING (this codebase) | +0 |
| Longevity | Until architecture changes | +2 LOCAL |
| **Total** | GLOBAL: 0, LOCAL: 8 | **LOCAL** |

---

### Example 3: "When implementing new API endpoints, follow the controller-service-repository pattern"

| Gate | Analysis | Score |
|------|----------|-------|
| Subject | About technique ("when implementing") | +2 GLOBAL |
| Reference | Pattern name, not specific path | +1 GLOBAL |
| Transfer | Could apply elsewhere, but... | +1 GLOBAL |
| Dimension | BEAUTY (patterns) | +1 LOCAL |
| Longevity | Project convention | +2 LOCAL |
| **Total** | GLOBAL: 4, LOCAL: 3 | **AMBIGUOUS** |

**Ask user**: "This insight about controller-service-repository pattern could be:
1. GLOBAL - A technique you want to remember across projects
2. LOCAL - A convention specific to this codebase
Which fits better?"

---

## Splitting Insights

When classification is BOTH (principle + specifics), split:

**Original**: "The UserService (src/services/user.ts) shows that services should handle business logic, not controllers"

**Split**:
- **GLOBAL**: "Services should handle business logic, not controllers"
- **LOCAL**: "UserService (src/services/user.ts) handles user business logic"

---

## Interactive Fallback Protocol

When AMBIGUOUS, present to user:

```
## Scope Classification Needed

The following insight could be global or local:

> "{insight_text}"

**Analysis**:
- Subject: {subject_analysis}
- References: {reference_analysis}
- Transfer potential: {transfer_analysis}

**Options**:
1. **GLOBAL** - Personal pattern (applies across projects)
2. **LOCAL** - Project pattern (specific to this codebase)
3. **BOTH** - Split into global principle + local specifics
4. **SKIP** - Don't classify this one

Your choice:
```

---

## Integration Points

### In /perspective Command

Before saving perspective MD:
1. Run classification on the target and content
2. If target is self/workflow → GLOBAL (override)
3. If target is specific path → LOCAL (override)
4. Else → Run full classification

### In /integrate Command

When processing feedback entries:
1. For each entry's learnings/suggestions
2. Run classification
3. Route to appropriate scope folder
4. Tag with classification reasoning

### In /pp-feedback Command

When collecting feedback:
1. Optionally pre-classify during collection
2. Add `scope_hint` field to entry
3. Integration confirms or asks

---

## Classification State Tracking

Add to integration state.json:

```json
{
  "classification": {
    "global_insights": 15,
    "local_insights": 8,
    "ambiguous_resolved": 3,
    "splits_performed": 2,
    "last_classification": "2026-01-24T00:00:00Z"
  }
}
```

---

## Quick Reference

| If the insight mentions... | Likely Scope |
|---------------------------|--------------|
| "I", "my", "Claude should" | GLOBAL |
| Specific file paths | LOCAL |
| "This codebase", "our convention" | LOCAL |
| "When X, do Y" (technique) | GLOBAL |
| Architecture of THIS project | LOCAL |
| Blindspot about behavior | GLOBAL |
| Where things go HERE | LOCAL |
| PP framework improvements | GLOBAL |

---

## Confidence Levels

| Confidence | Score Difference | Action |
|------------|-----------------|--------|
| HIGH | >= 5 | Auto-classify, no confirmation |
| MEDIUM | 3-4 | Auto-classify, note in log |
| LOW | 1-2 | Ask user to confirm |
| AMBIGUOUS | 0 | Must ask user |
