# CPT Automation Reference

> **Purpose**: Document the CPT automation hooks and PP integrations
> **Location**: These configurations live in `~/.claude/` and are applied automatically

---

## Automated Integrations

### 1. PP Trigger Hook (`~/.claude/hookify.pp-trigger.local.md`)

When user invokes `pp:`, `/pp`, or `use purpose prompter`, the hook automatically:

1. **Loads CPT context** - Shows progress and active challenges
2. **Adds CPT instructions** - Guides challenge logging when signals detected
3. **Includes wrap-up steps** - Reminds to update progress and resolve challenges

### 2. Main PP Command (`~/.claude/plugins/purpose-prompter/commands/pp.md`)

The `/pp` orchestrator now includes:

| Phase | CPT Integration |
|-------|-----------------|
| Phase 0 | Load `gua progress` and `gua challenge list` |
| Phase 2 | Log challenges when signals detected |
| Phase 3 | Update area progress after verification |
| Phase 4 | Include CPT summary in assessment |

### 3. Signal Command (`~/.claude/plugins/purpose-prompter/commands/signal.md`)

The `/signal` command output now:
- Generates exact `gua challenge log` commands for each signal
- Maps signals to PP dimensions automatically
- Explains why tracking signals as challenges is valuable

### 4. CLAUDE.md Protocol (`~/.claude/CLAUDE.md`)

The Signal Response Protocol now includes:
- CPT challenge logging for each signal type
- Challenge resolution steps
- Completion Gate includes CPT update verification

---

## Signal → Challenge Mapping

| PP Signal | Challenge Category | PP Dimension | Root Cause |
|-----------|-------------------|--------------|------------|
| Ugliness | `confusion` | UNDERSTANDING | Problem not understood |
| Injustice | `wrong_place` | JUSTICE | Codebase not understood |
| Stagnation | `dead_end` | CREATIVITY | Structure missing |
| Bug | `bug` | TRUTH | False assumption |
| Hacky | `ugly_hack` | BEAUTY | Forced solution |

---

## Automatic Behavior Summary

### When PP Activates

```
1. gua progress              ← Shows current state
2. gua challenge list        ← Shows blockers
3. /territory [task]         ← Standard PP flow
4. ... work proceeds ...
5. IF signal detected:
   - /signal [code]          ← Detects issue
   - gua challenge log ...   ← Logs it for tracking
6. /verify [result]          ← Standard PP verification
7. gua area update ...       ← Update progress
8. gua challenge resolve ... ← Resolve any fixed issues
9. gua challenge promote ... ← Promote valuable learnings
```

### What Gets Tracked

- **Signals encountered** → Become CPT challenges
- **Learnings from resolution** → Promoted to GUA insights
- **Implementation progress** → Updated after tasks
- **Understanding depth** → Bumped when code is deeply studied

---

## Configuration Files

| File | Purpose |
|------|---------|
| `~/.claude/hookify.pp-trigger.local.md` | Auto-trigger when PP invoked |
| `~/.claude/plugins/purpose-prompter/commands/pp.md` | Main orchestrator |
| `~/.claude/plugins/purpose-prompter/commands/signal.md` | Signal detection output |
| `~/.claude/CLAUDE.md` | Global PP + CPT protocol |

---

## Restoring Configuration

If you need to restore these configurations on a new machine:

1. Copy `~/.claude/` directory from backup
2. Or re-run the setup by reading this documentation and applying manually

The key additions are:
- CPT context injection at PP start
- Challenge logging when signals detected
- Progress updates after task completion
- CPT summary in PP assessment output

---

## Version History

- **1.0** (2026-01-27): Initial CPT automation
  - PP trigger hook enhanced
  - pp.md orchestrator updated
  - signal.md output enhanced
  - CLAUDE.md protocol updated
