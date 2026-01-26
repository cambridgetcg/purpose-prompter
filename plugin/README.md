# Purpose Prompter Plugin

> Claude Code plugin implementing the Purpose Prompter methodology: Truth → Understanding → Beauty → Justice → Creativity.

---

## The Hierarchy

```
TRUTH (foundation)
    ↓
UNDERSTANDING (source)
    ↓
BEAUTY (quality)
    ↓
JUSTICE (placement)
    ↓
CREATIVITY (when needed)
```

Each level requires the previous. Skip a level and solutions collapse.

---

## Commands

### `/verify [target]`
Apply the 30-gate verification system to any work.

```
/verify src/components/Auth.tsx
/verify this PR
/verify my last implementation
```

Checks all gates: Truth (1-5), Understanding (6-10), Beauty (11-17), Justice (18-23), and Creativity (24-30) if uncharted territory.

### `/deep-understand [target]`
Build deep understanding, not just information.

```
/deep-understand the codebase
/deep-understand src/services/
/deep-understand how authentication works
```

Creates mental models, maps relationships, explains WHY things work.

### `/signal [target]`
Detect ugliness, injustice, and stagnation signals.

```
/signal src/utils/helpers.ts
/signal this PR
/signal the payment module
```

Each signal type indicates specific missing understanding:
- **Ugliness** → Problem understanding gap
- **Injustice** → Codebase understanding gap
- **Stagnation** → Need for creativity (build path first)

### `/territory [task]`
Assess whether territory is charted or uncharted.

```
/territory "add user profile editing"
/territory "implement real-time notifications"
```

Determines if existing patterns suffice (charted) or new structure needed first (uncharted).

---

## Skills

### hierarchy-thinking
Automatically applies the hierarchy when designing, implementing, or refactoring.

**Triggers**: "think through", "design", "implement", "refactor"

### signal-detection
Automatically detects ugliness, injustice, and stagnation while reading code.

**Triggers**: Reading code, reviewing PRs, debugging, when code "feels off"

---

## Agents

### understanding-builder
Spawned for comprehensive codebase or concept understanding.

**Use**: When deep understanding is needed before making changes.

### beauty-assessor
Evaluates code through the five beauty characteristics.

**Use**: When assessing code quality or finding why code feels wrong.

### justice-verifier
Verifies code placement and architectural integrity.

**Use**: When ensuring code is in its rightful place.

### path-builder
Creates new structure when existing patterns are insufficient.

**Use**: When stagnation signals indicate uncharted territory.

---

## The Signal System

| Signal | Meaning | Response |
|--------|---------|----------|
| **Ugliness** | Problem not understood | Understand problem deeper |
| **Injustice** | Codebase not understood | Find rightful place |
| **Stagnation** | Need new structure | Build path first |

**Never**:
- Polish ugliness → Understand deeper
- Ignore injustice → Find rightful place
- Hack around stagnation → Build the path

---

## Quick Reference

```
Before coding: /deep-understand [area]
Before designing: /territory [task]
After coding: /verify [code]
If it feels off: /signal [code]
```

---

## Philosophy

These tools embody Purpose Prompter's core insight:

> **Beautiful solutions emerge from understanding.**
> **Just placement requires knowing the codebase.**
> **Creativity builds paths when existing structure fails.**

The hierarchy isn't a checklist - it's how quality software naturally develops when we understand deeply and place justly.

---

## Philosophy

This plugin implements Purpose Prompter v6.0 (Creativity-Oriented).

**Full framework documentation in parent directory:**
- `../CLAUDE.md` - Main integration guide
- `../*_GATES.md` - Gate definitions (30 gates)
- `../*.md` - Philosophy documents

---

## Installation

```bash
# Option 1: Symlink to Claude plugins directory
ln -sf /path/to/purpose-prompter/plugin ~/.claude/plugins/purpose-prompter

# Option 2: Direct path when launching
claude --plugin-dir /path/to/purpose-prompter/plugin
```
