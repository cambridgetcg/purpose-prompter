# Purpose Prompter: Execution Guide

> **The Core Problem**: PP was generating frameworks and plans but not committing changes.
> **The Solution**: Execution-first mindset with mandatory state tracking.

## The Execution Mindset

```
OLD PP: Think → Plan → Describe → Done
NEW PP: Think → Plan → EXECUTE → Verify → Done
                       ^^^^^^^^
                       THE CRITICAL DIFFERENCE
```

**Planning is not execution.**
**Describing is not doing.**
**"Would" is not "did".**

## Execution State Markers

Use these markers to track execution progress:

```
[PP:PHASE] → TERRITORY       # Entering territory assessment
[PP:TERRITORY] = CHARTED     # Territory result
[PP:PHASE] → UNDERSTAND      # Entering understanding phase
[PP:FILES_READ] = [list]     # Files actually read
[PP:PATTERNS_FOUND] = [list] # Patterns discovered
[PP:PHASE] → EXECUTE         # Entering execution phase
[PP:EXECUTING] description   # About to make a change
[PP:EXECUTED] filename       # Change was made (Edit/Write called)
[PP:SIGNAL] type             # Signal detected
[PP:PHASE] → VERIFY          # Entering verification phase
[PP:VERIFY] = PASS           # Verification result
[PP:COMPLETE]                # Task done (ONLY after execution)
```

## The Six Execution Laws

```
LAW 0: NO COMPLETION WITHOUT EXECUTION
       Must call Edit/Write before marking complete
       Planning without execution = FAILURE

LAW 1: NO EDIT WITHOUT READ
       Must Read file before Edit

LAW 2: NO CLAIM WITHOUT CITATION
       Must cite file:line for claims

LAW 3: NO PATTERN WITHOUT SOURCE
       Must cite where pattern exists

LAW 4: NO PLACEMENT WITHOUT EVIDENCE
       Must justify location choice

LAW 5: NO COMPLETION WITHOUT VERIFICATION
       Must verify before marking done
```

## Execution Failure Patterns

| Pattern | Signal | Correction |
|---------|--------|------------|
| "Here's the plan..." | Planning mode | Execute the plan NOW |
| "I would add..." | Hypothetical | DELETE "would", USE Edit |
| "This could be..." | Conditional | Make it actual |
| "Framework for..." | Meta-work | Do the actual work |
| Long text, no tools | Analysis paralysis | Call a tool |
| "Complete" with 0 edits | False completion | Make actual changes |

## Example Execution Flow

```
User: pp: add input validation to login form

[PP:PHASE] → TERRITORY
Searching for validation patterns...
[PP:TERRITORY] = CHARTED (validation.ts:15-40 has patterns)

[PP:PHASE] → UNDERSTAND
Reading src/components/LoginForm.tsx...
Reading src/utils/validation.ts...
[PP:FILES_READ] = [LoginForm.tsx, validation.ts]
[PP:PATTERNS_FOUND] = useFormValidation hook at validation.ts:20

[PP:PHASE] → EXECUTE
[PP:EXECUTING] Add validation imports
<Actually calls Edit tool>
[PP:EXECUTED] LoginForm.tsx - added validation imports

[PP:EXECUTING] Add validation hook
<Actually calls Edit tool>
[PP:EXECUTED] LoginForm.tsx - added useFormValidation hook

[PP:PHASE] → VERIFY
Running tests...
[PP:VERIFY] = PASS

[PP:COMPLETE]
Files modified: LoginForm.tsx
```

## Hooks Enforcement

The hooks in `plugin/hooks/hooks.json` actively enforce:

1. **PreToolUse (Edit/Write)**: Checks if file was read, pattern found, placement justified
2. **PostToolUse (Edit/Write)**: Requires execution marker, signal check
3. **Stop**: Requires execution summary, blocks false completion
4. **UserPromptSubmit (pp:)**: Activates execution mode, injects reminders

## Commands

- `/pp [task]` - Execute task with full PP methodology
- `/pp-execute [task]` - Explicit execution-focused command (same as /pp)
- `/territory [task]` - Assess charted vs uncharted
- `/deep-understand [area]` - Build understanding
- `/signal [code]` - Check for signals
- `/verify [work]` - Run 30-gate verification

## Quick Test

After any PP session, ask yourself:

1. Did I call Edit or Write tools?
2. Can I list the files I modified?
3. Did I verify the changes work?

If any answer is NO → PP failed, execution didn't happen.

## The Promise

When PP is activated, by the end of the session:
- **Actual files will be modified** (not just described)
- **Changes will be verified** (not just assumed)
- **Signals will be addressed** (not just noted)
- **"Complete" means done** (not "plan complete")
