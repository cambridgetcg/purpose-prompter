---
description: Detect ugliness, injustice, and stagnation signals in code
argument-hint: [target] - file path, directory, or PR to analyze
allowed-tools: [Read, Glob, Grep, Bash]
model: sonnet
---

# /signal - Signal Detection

The PP Signal System: code problems signal specific types of incomplete understanding.

## Target

$ARGUMENTS

## The Three Signals

### Ugliness - Problem understanding incomplete

**Symptoms**: Complex conditionals, functions doing too much, unclear names, magic numbers, deep nesting, "clever" code, inconsistent patterns.

**Wrong response**: Polish it (comments, renames, extractions).
**Right response**: Understand the problem deeper. Beauty emerges naturally from understanding.

### Injustice - Codebase understanding incomplete

**Symptoms**: God classes, utilities that should be services, business logic in controllers, scattered cross-cutting concerns, circular dependencies, leaky abstractions, duplicate logic.

**Wrong response**: Leave it because "it works".
**Right response**: Understand the codebase architecture. Find where code rightfully belongs.

### Stagnation - Need for creativity

**Symptoms**: "Can't do X because of Y", multiplying feature flags, workarounds on workarounds, copy-paste instead of refactoring, architecture fighting the domain.

**Wrong response**: Force it (more hacks, flags, workarounds).
**Right response**: Recognize uncharted territory. Build a new path, then place justly.

## Process

1. Read gate definitions from `plugin/gates/GATES.md`
2. Read the target code
3. Look for each signal type
4. Identify specific instances with file:line citations
5. Diagnose the underlying incomplete understanding
6. Recommend the right response

## Output Format

```markdown
## Signal Analysis: [Target]

### Ugliness: [Found/None]
| Location | Symptom | Missing Understanding |
|----------|---------|----------------------|
| [file:line] | [what looks ugly] | [what problem understanding is missing] |

### Injustice: [Found/None]
| Location | Symptom | Rightful Place |
|----------|---------|----------------|
| [file:line] | [what's misplaced] | [where it should be] |

### Stagnation: [Found/None]
| Location | Symptom | Path Needed |
|----------|---------|-------------|
| [area] | [what's blocked] | [what structure is missing] |

### Summary
| Signal | Count | Severity |
|--------|-------|----------|
| Ugliness | [n] | [H/M/L] |
| Injustice | [n] | [H/M/L] |
| Stagnation | [n] | [H/M/L] |

### Key Insight
[The most important understanding gap to address]
```
