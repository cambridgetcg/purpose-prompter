---
name: pp-orchestrator
description: "Auto-invoke when user message starts with 'pp:', '/pp', 'use purpose prompter', or 'use pp'. Orchestrates the Purpose Prompter hierarchy via agents."
version: 3.0.0
---

# PP Orchestrator

**Auto-Trigger**: User message matches `^(pp:|/pp\s|use purpose prompter|use pp)`

When this skill activates, delegate to the `/pp` command with the extracted task.

## Activation

1. Extract task from user input (strip prefix: `pp:`, `/pp`, `use purpose prompter`, `use pp`)
2. Execute: `/pp {extracted_task}`

The `/pp` command (commands/pp.md) handles all orchestration: sensing, comprehension, building, execution, and assessment.

## Bypass Detection

If user input contains "quick", "fast", "just do it", "no pp", or "skip pp":
- Do NOT activate PP orchestration
- Execute the task directly without hierarchy overhead

## Architecture

```
User Input -> SKILL.md (this file, trigger detection)
                |
                v
           commands/pp.md (orchestration)
                |
                v
           agents/{sense,comprehend,build,assess}.md (via Task tool)
                |
                v
           gates/GATES.md (read by agents for gate definitions)
```

4 agents max. Natural language prompts. No template interpolation.
