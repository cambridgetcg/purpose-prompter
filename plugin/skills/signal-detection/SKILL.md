---
name: signal-detection
description: This skill should be used when reading code, reviewing PRs, debugging issues, or anytime code "feels off". Automatically detects ugliness (problem understanding gap), injustice (codebase understanding gap), and stagnation (need for creativity) signals.
version: 1.0.0
---

# Signal Detection Skill

Code problems are signals that reveal specific types of incomplete understanding.

## The Three Signals

### UGLINESS Signal

**Triggers**: Code feels hacky, convoluted, hard to read, "clever" in a bad way

**What it means**: You don't fully understand the **PROBLEM**.

**Detection patterns**:
- Complex nested conditionals
- Functions doing multiple unrelated things
- Unclear naming that requires comments to explain
- Magic numbers and strings
- Code that fights the language/framework
- "I know this is hacky but..."

**Response**: Don't polish. Step back and understand the problem deeper. When you truly understand, beauty emerges naturally.

---

### INJUSTICE Signal

**Triggers**: Code is in the wrong place, wrong component, violates architecture

**What it means**: You don't fully understand the **CODEBASE**.

**Detection patterns**:
- "This doesn't belong here but..."
- God classes/modules
- Business logic in wrong layers
- Feature envy between classes
- Circular dependencies
- Duplicate code in multiple places
- Leaky abstractions

**Response**: Don't leave it. Understand the codebase architecture deeper. Find the rightful place.

---

### STAGNATION Signal

**Triggers**: Can't add features without hacks, workarounds accumulating, "needs rewrite"

**What it means**: You need **CREATIVITY** - existing structure is insufficient.

**Detection patterns**:
- "We can't do X because..."
- Feature flags multiplying
- Workarounds on workarounds
- Copy-paste because "refactoring is too hard"
- Architecture fights the problem domain
- Every change touches many files

**Response**: Don't force it. Recognize uncharted territory. Build a new path first, then place the solution justly.

## When to Activate

Activate this skill when:
- Reading code for the first time
- Reviewing pull requests
- Debugging issues
- Feeling resistance while coding
- Code "smells" but you can't articulate why
- Choosing where to put new code
- Extending existing functionality

## What to Do When Signal Detected

```
SIGNAL DETECTED
      │
      ├── Ugliness?
      │       │
      │       └── STOP trying to fix
      │           ASK: What do I not understand about the PROBLEM?
      │           ACTION: Understand deeper, then let solution emerge
      │
      ├── Injustice?
      │       │
      │       └── STOP accepting the location
      │           ASK: What do I not understand about the CODEBASE?
      │           ACTION: Understand deeper, find rightful place
      │
      └── Stagnation?
              │
              └── STOP forcing into existing structure
                  ASK: What new STRUCTURE is needed?
                  ACTION: Build the path first, then place justly
```

## Signal to Root Cause Mapping

| You Feel | Signal Type | Root Cause | Action |
|----------|-------------|------------|--------|
| "This is hacky" | Ugliness | Problem not understood | Understand problem |
| "This is messy" | Ugliness | Problem not understood | Understand problem |
| "This doesn't belong here" | Injustice | Codebase not understood | Find rightful place |
| "This violates our patterns" | Injustice | Codebase not understood | Find rightful place |
| "We can't do this cleanly" | Stagnation | Need new structure | Build the path |
| "Everything we try is a hack" | Stagnation | Need new structure | Build the path |

## Remember

These signals are **gifts**. They tell you exactly what's missing:
- Ugliness → Missing problem understanding
- Injustice → Missing codebase understanding
- Stagnation → Missing structure (need creativity)

Don't suppress signals. Don't work around them. **Address the underlying gap**.
