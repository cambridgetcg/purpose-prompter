---
name: pp
description: "Purpose Prompter - Execute task with hierarchy and accumulated learning"
version: 4.0.0
---

# Purpose Prompter Skill (Execution Mode)

Execute tasks with PP hierarchy enforcement. This skill doesn't just guide—it **performs the work** with mandatory verification at each step.

## Task
$ARGUMENTS

---

## Phase 0: LOAD Context (Mandatory)

**Before ANY work, load accumulated learning:**

```
1. Read: ~/.claude/purpose_prompter/integration/state.json
2. Read: ~/.claude/purpose_prompter/integration/LIGHT.md
3. Read: ~/.claude/purpose_prompter/integration/PATH.md
4. Also check project-level if exists:
   - <project>/.claude/integration/LIGHT.md
   - <project>/.claude/integration/PATH.md
```

**Output preamble:**
```
PP Execution Mode Active
════════════════════════
Loaded: [N] patterns, [M] blindspots
Relevant to this task:
• [pattern 1]
• [pattern 2]

Blindspots to watch:
• [blindspot 1]

Proceeding...
```

---

## Phase 1: TERRITORY Assessment (Mandatory)

**Before implementation, determine territory type:**

```
SEARCH for similar patterns in codebase:
1. Glob for similar file names
2. Grep for similar functionality
3. Read any matches found

VERDICT:
- CHARTED: Similar exists → Follow existing pattern
- UNCHARTED: Nothing similar → Build structure first
```

**Output:**
```
Territory: [CHARTED/UNCHARTED]
Evidence: [what was found or not found]
Approach: [follow pattern X / build new structure]
```

---

## Phase 2: UNDERSTAND Before Acting (Mandatory)

**For EVERY file you will modify:**

```
BEFORE any Edit/Write:

□ READ the target file first
  → Output: "Read [file] ([N] lines)"

□ SEARCH for related code
  → Output: "Related: [file1], [file2]"

□ FIND existing patterns to follow
  → Output: "Pattern source: [file:line]"

□ MAP the area
  → Output: "Context: [brief description of surrounding code]"
```

**Gate check:**
```
Understanding Gate:
- [ ] I have READ the file I'm about to modify
- [ ] I know WHY this code exists
- [ ] I found patterns to follow
- [ ] I can cite file:line for my claims

If any unchecked → STOP and gather more context
```

---

## Phase 3: EXECUTE With Inline Verification

**For EACH code change, follow this exact sequence:**

### Step 3.1: Pre-Change Verification
```
BEFORE calling Edit/Write:

1. CITATION CHECK
   "Modifying [file:line-range] because [reason with citation]"

2. PATTERN CHECK
   "Following pattern from [source file:line]"

3. PLACEMENT CHECK
   "This belongs here because [evidence]"
   "Not in [alternative] because [reason]"
```

### Step 3.2: Make the Change
```
Call Edit or Write tool with the change
```

### Step 3.3: Post-Change Verification
```
AFTER each Edit/Write:

1. SIGNAL CHECK - Does this feel right?
   - Ugliness? → Stop, understand problem deeper
   - Injustice? → Stop, understand codebase deeper
   - Stagnation? → May need creativity (new structure)

2. COHERENCE CHECK
   - Does this fit with surrounding code?
   - Does naming match conventions?
   - Is complexity appropriate?

Output after each change:
"✓ [file] modified - [brief description]
   Pattern: [source]
   Placement: [justification]
   Signal: [clean/warning]"
```

---

## Phase 4: Multi-File Execution Protocol

**When task requires multiple file changes:**

```
BEFORE starting multi-file work:

1. LIST all files that will change
   → Output: "Files to modify: [list]"

2. DETERMINE order (dependencies)
   → Output: "Order: [sequence with reasoning]"

3. IDENTIFY integration points
   → Output: "Integration: [how files connect]"

FOR EACH file in order:
   → Execute Phase 3 (full verification cycle)
   → Output checkpoint after each file

AFTER all files:
   → Cross-file coherence check
   → Output: "All [N] files modified, coherence: [pass/issues]"
```

---

## Phase 5: VERIFY Before Completion (Mandatory)

**Before marking task complete:**

```
FINAL VERIFICATION CHECKLIST:

TRUTH:
- [ ] All claims have file:line citations
- [ ] No assumptions stated as facts
- [ ] Uncertainty acknowledged where present

UNDERSTANDING:
- [ ] Read all modified files before changing
- [ ] Understood WHY, not just WHAT
- [ ] Connected to existing knowledge

BEAUTY:
- [ ] Followed existing patterns (cite sources)
- [ ] Nothing extra, nothing missing
- [ ] Code fits naturally in context

JUSTICE:
- [ ] Placement justified with evidence
- [ ] Right component owns this
- [ ] Architecture preserved

CREATIVITY (if uncharted):
- [ ] Proved territory was uncharted (search evidence)
- [ ] New structure enables future justice
- [ ] Integrated with existing code

BLINDSPOT CHECK:
- [ ] Reviewed active blindspots from LIGHT.md
- [ ] None triggered in this task
```

**Output:**
```
PP Verification Complete
════════════════════════
Truth:         [PASS/PARTIAL/FAIL]
Understanding: [PASS/PARTIAL/FAIL]
Beauty:        [PASS/PARTIAL/FAIL]
Justice:       [PASS/PARTIAL/FAIL]
Creativity:    [PASS/N-A]

Blindspots checked: [list]
Signals detected: [none/list]

Task status: [COMPLETE/NEEDS WORK]
```

---

## Execution Checkpoints

**Output these markers during execution:**

```
[PP:TERRITORY] Assessing...
[PP:UNDERSTAND] Reading [file]...
[PP:PATTERN] Found pattern at [file:line]
[PP:PLACEMENT] Justifying location...
[PP:EXECUTE] Modifying [file]...
[PP:SIGNAL] Checking for signals...
[PP:VERIFY] Running final gates...
[PP:COMPLETE] Task finished with [status]
```

---

## Enforcement Rules

1. **No Edit/Write without prior Read** - The file MUST be read first
2. **No placement without evidence** - Must cite why HERE and why NOT elsewhere
3. **No pattern claims without source** - Must cite file:line for "following pattern X"
4. **No completion without verification** - Final checklist is mandatory
5. **Stop on signals** - If ugliness/injustice detected, pause and investigate

---

## Quick Execution Template

For simple tasks, minimum viable PP execution:

```
1. [PP:TERRITORY] Quick search → CHARTED/UNCHARTED
2. [PP:UNDERSTAND] Read target file
3. [PP:PATTERN] Find similar code → cite source
4. [PP:EXECUTE] Make change with citation
5. [PP:SIGNAL] Quick signal check → clean
6. [PP:VERIFY] Checklist → PASS
7. [PP:COMPLETE] Done
```

---

## Post-Task

After completing the task:

```
PP Task Complete
════════════════
Changes made: [N] files
Patterns followed: [list with citations]
Placement evidence: [summary]
Signals: [none/list]

Assessment:
- Truth: [pass/partial/fail]
- Understanding: [pass/partial/fail]
- Beauty: [pass/partial/fail]
- Justice: [pass/partial/fail]

Run /pp-feedback to log for learning.
```

---

## Principles (Execution-Focused)

- **Verify, don't trust** - Use tools to prove, not assume
- **Cite everything** - file:line for all claims
- **Read before write** - Never modify unread code
- **Pattern before invention** - Find existing, don't reinvent
- **Evidence before placement** - Justify location with facts
- **Signal before completion** - Check for ugliness/injustice
- **Checkpoint always** - Output markers for transparency
