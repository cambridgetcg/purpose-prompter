---
description: "Generate insight MD from a specific perspective lens"
argument-hint: "[type] [target] [--global|--local|--auto] - e.g., beauty ./src or truth workflow --global"
allowed-tools: [Read, Write, Glob, Grep, Bash, Task, AskUserQuestion]
model: opus
---

# Perspective Command

Generate focused insights by examining a target through a specific lens.

## Arguments

```
$ARGUMENTS

Parse as:
- type: First word (truth|understanding|beauty|justice|creativity|custom:name)
- target: Second word/path (file, folder, concept, or "self")
- scope flags:
  - --global: Force save to global perspectives
  - --local:  Force save to project perspectives
  - --auto:   Use classification protocol (default)
```

---

## Perspective Types

### Hierarchy Perspectives

| Type | Lens | Key Questions |
|------|------|---------------|
| **truth** | Accuracy, verification | What claims are unverified? What's assumed vs proven? |
| **understanding** | Comprehension, mental models | Is the WHY clear? Are connections visible? |
| **beauty** | Elegance, fit, coherence | What's ugly? What doesn't fit? What's over-complicated? |
| **justice** | Placement, ownership, balance | Is code in the right place? Are responsibilities clear? |
| **creativity** | Innovation, paths, extension | What's stagnant? What new territory is needed? |

### Custom Perspectives

Use `custom:name` for domain-specific lenses:
- `custom:performance` - Speed, efficiency, resource usage
- `custom:security` - Vulnerabilities, attack surface, data protection
- `custom:ux` - User experience, friction points, clarity
- `custom:debt` - Technical debt, shortcuts, future cost

---

## Process

### Step 1: RESOLVE Location

**Quick Overrides (no classification needed):**
```
If --global flag present:
  → Save to: ~/.claude/purpose_prompter/integration/perspectives/

Else if --local flag present:
  → Save to: <project>/.claude/integration/perspectives/

Else if target is "self" or "workflow" or "process":
  → Save to: ~/.claude/purpose_prompter/integration/perspectives/
  (These are always about personal patterns)
```

**Auto-Classification (when --auto or no flag):**

If none of the above apply, use the classification protocol:

```
1. DETERMINE what the perspective will examine:
   - If target is a specific file path → Likely LOCAL
   - If target is a concept/technique → Run full classification

2. RUN CLASSIFICATION GATES (from SCOPE_CLASSIFICATION.md):

   GATE 1: SUBJECT TEST
   - Is this about how YOU work? → +2 GLOBAL
   - Is this about THIS CODE? → +2 LOCAL

   GATE 2: REFERENCE TEST
   - Will insights reference specific paths? → +2 LOCAL
   - Will insights be generic patterns? → +1 GLOBAL

   GATE 3: TRANSFER TEST
   - Will findings help in other projects? → +2 GLOBAL
   - Will findings only apply here? → +2 LOCAL

   GATE 4: DIMENSION TEST
   - TRUTH lens → +1 GLOBAL (about verification habits)
   - UNDERSTANDING lens → +0 (depends on target)
   - BEAUTY lens on code → +1 LOCAL (this codebase's style)
   - JUSTICE lens → +2 LOCAL (where things go here)
   - CREATIVITY lens → +0 (depends on target)

   GATE 5: LONGEVITY TEST
   - Permanent insight? → +1 GLOBAL
   - Project-lifetime? → +2 LOCAL

3. CALCULATE SCOPE:
   difference = GLOBAL_SCORE - LOCAL_SCORE

   IF difference >= 3: → GLOBAL (auto)
   ELIF difference <= -3: → LOCAL (auto)
   ELSE: → Ask user with AskUserQuestion
```

**Default Locations:**
```
GLOBAL: ~/.claude/purpose_prompter/integration/perspectives/
LOCAL:  <project>/.claude/integration/perspectives/
```

### Step 2: EXAMINE Target

**If target is a path:**
```
1. Glob to find files matching target
2. Read key files (prioritize: main modules, entry points, configs)
3. Map the structure
```

**If target is "self" or "workflow":**
```
1. Reflect on recent session behavior
2. Review patterns in how tasks were approached
3. Note decision points and outcomes
```

**If target is a concept:**
```
1. Search codebase for related code
2. Read documentation
3. Trace usage patterns
```

### Step 3: APPLY Lens

For each perspective type, ask the specific questions:

**TRUTH lens:**
- What claims exist in comments/docs that aren't verified?
- What's assumed to work but never tested?
- Where is confidence higher than evidence warrants?

**UNDERSTANDING lens:**
- Is the purpose of each module clear?
- Can a newcomer understand WHY, not just WHAT?
- Are the mental models explicit or hidden?

**BEAUTY lens:**
- What feels awkward or forced?
- What has unnecessary complexity?
- What doesn't fit the surrounding patterns?
- What's missing that would complete it?

**JUSTICE lens:**
- Is functionality in the right files/modules?
- Are naming conventions consistent?
- Is responsibility distributed appropriately?
- Are boundaries respected?

**CREATIVITY lens:**
- What's been the same too long?
- Where is the system hitting limits?
- What new capabilities are needed?
- What paths don't exist yet?

### Step 4: GENERATE Insight MD

Write to perspectives folder with filename: `{date}_{type}_{target_slug}.md`

```markdown
# {Type} Perspective: {Target}

> Generated: {timestamp}
> Scope: {global|project}
> Target: {what was examined}

---

## Summary

{2-3 sentence overview of key findings}

---

## Observations

### {Observation 1 Title}
- **What**: {factual description}
- **Evidence**: {file:line or specific example}
- **Implication**: {what this means}

### {Observation 2 Title}
...

---

## Patterns Identified

1. **{Pattern name}**: {description}
   - Frequency: {how often observed}
   - Examples: {specific instances}

2. ...

---

## Issues Found

| Issue | Severity | Location | Suggested Action |
|-------|----------|----------|------------------|
| {issue} | {high/medium/low} | {where} | {what to do} |

---

## Recommendations

### Immediate (This Session)
- [ ] {action 1}
- [ ] {action 2}

### Short-term (Next Few Sessions)
- [ ] {action 1}

### Consider Later
- [ ] {action 1}

---

## Questions Raised

- {Question that needs investigation}
- {Uncertainty that emerged}

---

## Integration Notes

*For /integrate path consumption:*
- **Key insight**: {most important finding}
- **Blindspot risk**: {potential blindspot identified}
- **Path implication**: {how this should affect direction}
- **Scope**: {global|local}
- **Scope reasoning**: {why this scope was chosen}
```

### Step 5: OUTPUT Summary

```
## Perspective Generated

**Type**: {type}
**Target**: {target}
**Scope**: {global|project}
**Classification**: {auto|forced|user-selected}
**Saved**: {filepath}

### Key Findings
- {finding 1}
- {finding 2}
- {finding 3}

### Recommended Actions
- {action 1}
- {action 2}

### Scope Reasoning
{Why this was classified as global/local - brief explanation}

Run `/integrate path` when ready to synthesize all perspectives.
```

---

## Examples

```bash
# Review codebase architecture through beauty lens
/perspective beauty ./src

# Audit documentation accuracy
/perspective truth ./docs

# Check if code is in right places
/perspective justice ./lib

# Personal workflow reflection (global)
/perspective understanding self --global

# Custom security review
/perspective custom:security ./api

# Review specific module
/perspective beauty ./src/auth/middleware.ts
```

---

## Integration with PATH

Perspectives accumulate in the perspectives/ folder. When you run `/integrate path`:

1. All perspective MDs are read
2. Patterns across perspectives are identified
3. Recommendations are prioritized
4. PATH.md is generated with concrete direction

The more perspectives you accumulate, the richer your PATH becomes.
