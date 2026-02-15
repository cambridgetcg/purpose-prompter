# Purpose Prompter Plugin v3.0

> T -> U -> B -> J -> X: Truth, Understanding, Beauty, Justice, Creativity

## Structure

```
plugin/
  .claude-plugin/plugin.json     # Plugin manifest
  commands/
    pp.md                        # /pp - Full orchestration
    verify.md                    # /verify - 30-gate verification
    signal.md                    # /signal - Signal detection
    reflect.md                   # /reflect - PP self-reflection
    transmute.md                 # /transmute - Alchemical ritual
  skills/
    pp-orchestrator/SKILL.md     # Auto-trigger for pp:/use pp
  agents/
    sense.md                     # Territory + patterns + impact (sonnet, Explore)
    comprehend.md                # Deep understanding (sonnet, general-purpose)
    build.md                     # Path builder for uncharted (opus, general-purpose)
    assess.md                    # All 30 gates unified (sonnet/opus, Explore)
  gates/
    GATES.md                     # All 30 gates + 5 enhancements
    ALCHEMY.md                   # Transmutation reference for agents
  hooks/
    hooks.json                   # PreToolUse reminder
```

## Commands

| Command | Purpose |
|---------|---------|
| `/pp [task]` | Full PP orchestration with agents |
| `/verify [target]` | 30-gate verification |
| `/signal [target]` | Signal detection (ugliness, injustice, stagnation) |
| `/reflect [deep]` | PP self-reflection — examine behavioral patterns |
| `/transmute [candidate\|scan]` | Alchemical ritual — transmute reflections into modules |

## Agent Flow

```
sense -> comprehend (if needed) -> build (if uncharted) -> execute -> assess
```

Max 4 agents per task. Agents read gates/GATES.md themselves. No template interpolation.

## Installation

```bash
claude --plugin-dir /path/to/purpose-prompter/plugin
# or
rsync -av plugin/ ~/.claude/plugins/hierarchy-tools/
```

## Philosophy

Philosophy files archived in `../philosophy/`. Gate definitions consolidated in `gates/GATES.md`.
