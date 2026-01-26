---
description: "Purpose Prompter EXECUTION orchestrator - drives actual implementation through PP phases, not just planning"
argument-hint: "[task] - the task to execute with PP methodology"
allowed-tools: [Read, Glob, Grep, Bash, Task, Edit, Write, TodoWrite, Skill, AskUserQuestion]
model: opus
---

# PP Execute - The Execution Driver

This command **DRIVES EXECUTION**, not just planning. It ensures PP methodology is applied AND the actual work gets done.

## Arguments

Task to execute: $ARGUMENTS

## Critical Difference from /pp

```
/pp      = Describes what should happen, generates plans
/pp-execute = Actually DOES the work, makes changes, verifies completion
```

**YOU MUST ACTUALLY MAKE THE CHANGES, NOT JUST PLAN THEM**

## Execution State Machine

You will track state through these phases:

```
PP_STATE = {
  phase: "INIT",           // INIT → TERRITORY → UNDERSTAND → EXECUTE → VERIFY → COMPLETE
  task: "$ARGUMENTS",
  territory: null,         // CHARTED | UNCHARTED
  understanding: [],       // Key insights gathered
  planned_changes: [],     // What we plan to do
  executed_changes: [],    // What we actually did (files modified)
  signals_detected: [],    // Any ugliness/injustice/stagnation
  verification_status: null
}
```

## Phase Execution Protocol

### PHASE 0: TERRITORY (Required)

```
[PP:PHASE] → TERRITORY

You MUST actually run territory assessment.
DO NOT just describe what territory assessment would find.

Actions:
1. Search codebase for similar patterns (Glob, Grep)
2. Read relevant files to understand structure
3. Determine CHARTED vs UNCHARTED

Output:
[PP:TERRITORY] = CHARTED | UNCHARTED
[PP:TERRITORY_EVIDENCE] = [specific files/patterns found]
```

### PHASE 1: UNDERSTAND (Required for non-trivial)

```
[PP:PHASE] → UNDERSTAND

You MUST actually build understanding before modifying.
DO NOT assume you understand. PROVE understanding.

Actions:
1. Read ALL files that will be modified
2. Read related files for patterns
3. Document mental model

Output:
[PP:UNDERSTAND_COMPLETE]
[PP:FILES_READ] = [list of files read]
[PP:PATTERNS_FOUND] = [patterns discovered]
[PP:MENTAL_MODEL] = [brief description]
```

### PHASE 2: EXECUTE (The Actual Work)

```
[PP:PHASE] → EXECUTE

THIS IS WHERE YOU ACTUALLY MAKE CHANGES.
DO NOT describe what changes you would make.
ACTUALLY USE Edit/Write TOOLS.

For each planned change:
1. Output: [PP:EXECUTING] [description of change]
2. ACTUALLY call Edit or Write tool
3. Output: [PP:EXECUTED] [file] - [what was done]

Track:
- PP_STATE.executed_changes += [each file modified]
```

**CRITICAL**: If you find yourself writing "I would..." or "This would..." STOP.
Those are planning words. Use action words and CALL THE TOOLS.

### PHASE 3: VERIFY (Required)

```
[PP:PHASE] → VERIFY

You MUST verify after execution.

Actions:
1. Run tests if applicable
2. Check each executed change against requirements
3. Verify no signals (ugliness, injustice, stagnation)

Output:
[PP:VERIFY] = PASS | PARTIAL | FAIL
[PP:VERIFY_DETAILS] = [specific results]
```

### PHASE 4: COMPLETE (Only After Execution)

```
[PP:PHASE] → COMPLETE

You can ONLY reach this phase if:
- [ ] executed_changes.length > 0 (actual changes made)
- [ ] verification_status === PASS
- [ ] No unresolved signals

Output:
[PP:COMPLETE]

Summary of actual changes made:
[list each file and what was changed]
```

## Execution Enforcement Rules

### RULE 1: No Verification Without Execution

```
IF executed_changes.length === 0:
  CANNOT enter VERIFY phase
  CANNOT output [PP:COMPLETE]

  Instead:
  [PP:BLOCKED] No changes have been executed yet
  Continue to EXECUTE phase
```

### RULE 2: No Completion Without Verification

```
IF verification_status !== PASS:
  CANNOT output [PP:COMPLETE]

  Instead:
  [PP:BLOCKED] Verification not passed
  Address issues, re-verify
```

### RULE 3: Signal Response is Mandatory

```
IF signal detected during execution:
  STOP current change
  [PP:SIGNAL] [type] detected in [location]

  Response:
  - Ugliness → /deep-understand the problem
  - Injustice → /deep-understand the codebase
  - Stagnation → /territory to confirm uncharted

  Only continue after signal addressed
```

## Output Format During Execution

Use these markers so progress is visible:

```
[PP:PHASE] → [PHASE_NAME]       // Entering a phase
[PP:TERRITORY] = CHARTED        // Territory result
[PP:UNDERSTAND_COMPLETE]        // Understanding built
[PP:EXECUTING] Add auth check   // About to make change
[PP:EXECUTED] src/auth.ts       // Change made
[PP:SIGNAL] Ugliness in X       // Signal detected
[PP:VERIFY] = PASS              // Verification result
[PP:COMPLETE]                   // Task finished
[PP:BLOCKED] [reason]           // Cannot proceed
```

## Example Execution Flow

```
User: /pp-execute add input validation to the login form

[PP:PHASE] → TERRITORY
Searching for validation patterns...
Found: src/utils/validation.ts (validation helpers)
Found: src/components/SignupForm.tsx (similar validation)
[PP:TERRITORY] = CHARTED
[PP:TERRITORY_EVIDENCE] = Validation patterns exist, follow SignupForm

[PP:PHASE] → UNDERSTAND
Reading src/components/LoginForm.tsx...
Reading src/components/SignupForm.tsx for pattern...
Reading src/utils/validation.ts for helpers...
[PP:UNDERSTAND_COMPLETE]
[PP:FILES_READ] = [LoginForm.tsx, SignupForm.tsx, validation.ts]
[PP:PATTERNS_FOUND] = useFormValidation hook, validateRequired helper
[PP:MENTAL_MODEL] = Login form uses controlled inputs, needs validation on submit

[PP:PHASE] → EXECUTE
[PP:EXECUTING] Import validation utilities
<Edit tool called on LoginForm.tsx>
[PP:EXECUTED] src/components/LoginForm.tsx - added imports

[PP:EXECUTING] Add validation state
<Edit tool called on LoginForm.tsx>
[PP:EXECUTED] src/components/LoginForm.tsx - added useFormValidation hook

[PP:EXECUTING] Add validation on submit
<Edit tool called on LoginForm.tsx>
[PP:EXECUTED] src/components/LoginForm.tsx - added validation check before submit

[PP:PHASE] → VERIFY
Running validation test...
Checking pattern conformance...
[PP:VERIFY] = PASS

[PP:COMPLETE]
Summary of changes:
- src/components/LoginForm.tsx: Added input validation using useFormValidation hook
  - Imported validateRequired, validateEmail from utils
  - Added validation state management
  - Added validation check on form submit
```

## Anti-Pattern Detection

If you catch yourself doing any of these, STOP and course-correct:

| Anti-Pattern | Signal | Correction |
|--------------|--------|------------|
| "I would add..." | Planning without doing | Use Edit tool NOW |
| "This could be..." | Hypothetical | Make it actual |
| "Here's the plan..." | Planning mode | Execute the plan |
| "Framework for..." | Meta-work | Do the actual work |
| Long explanation, no tools | Analysis paralysis | Call a tool |
| "Complete" with no edits | Premature completion | Make actual changes |

## The Execution Promise

When this command runs, by the end:

1. **Actual files will be modified** - Not just described
2. **Changes will be verified** - Not just assumed correct
3. **Signals will be addressed** - Not just noted
4. **Completion means done** - Not "plan complete"

## Remember

**Planning is not execution.**
**Description is not action.**
**"Would" is not "did".**

You have the tools. Use them. Make the changes. Verify the results.

NOW EXECUTE: $ARGUMENTS
