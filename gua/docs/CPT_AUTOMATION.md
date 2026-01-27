# CPT + Eureka Automation Reference

> **Purpose**: Document the CPT and Eureka Recorder automation hooks and PP integrations
> **Location**: These configurations live in `~/.claude/` and are applied automatically

---

## Automated Integrations

### 1. PP Trigger Hook (`~/.claude/hookify.pp-trigger.local.md`)

When user invokes `pp:`, `/pp`, or `use purpose prompter`, the hook automatically:

1. **Loads CPT context** - Shows progress and active challenges
2. **Loads recent eurekas** - Shows recent "ahh hah" moments for context
3. **Adds CPT instructions** - Guides challenge logging when signals detected
4. **Adds Eureka capture** - Guides eureka logging during thinking
5. **Includes wrap-up steps** - Reminds to update progress, resolve challenges, and promote eurekas

### 2. Main PP Command (`~/.claude/plugins/purpose-prompter/commands/pp.md`)

The `/pp` orchestrator now includes:

| Phase | CPT + Eureka Integration |
|-------|--------------------------|
| Phase 0 | Load `gua progress`, `gua challenge list`, and `gua eureka list` |
| Phase 2 | Log challenges when signals detected |
| Phase 2 | Capture eurekas during thinking (recognition markers) |
| Phase 3 | Update area progress after verification |
| Phase 4 | Include CPT summary and eureka count in assessment |
| Phase 4 | Promote valuable eurekas to insights |

### 3. Signal Command (`~/.claude/plugins/purpose-prompter/commands/signal.md`)

The `/signal` command output now:
- Generates exact `gua challenge log` commands for each signal
- Maps signals to PP dimensions automatically
- Explains why tracking signals as challenges is valuable
- **Suggests eureka capture** when signals resolve (the "ahh hah" often happens here)
- Documents the Signal-Eureka Loop

### 4. Eureka Suggest Hook (`~/.claude/hookify.eureka-suggest.local.md`)

A **suggestive** hook that triggers when Claude uses eureka-marker phrases:
- Pattern: `(Oh,? I see|Ah,? so|Wait,? that means|That'?s why|...)`
- Action: **warn** (suggests, doesn't force)
- Reminds to capture eureka when linguistic markers detected

### 5. CLAUDE.md Protocol (`~/.claude/CLAUDE.md`)

The Signal Response Protocol now includes:
- CPT challenge logging for each signal type
- **Eureka capture** when signals resolve
- Challenge resolution steps
- The Signal-Eureka Loop documentation
- Completion Gate includes CPT update and eureka capture verification

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

## Eureka Type → PP Dimension Mapping

| Eureka Type | PP Dimension | What Was Realized |
|-------------|--------------|-------------------|
| `connection` | UNDERSTANDING | Two things link together |
| `reframe` | UNDERSTANDING | Problem was framed wrong |
| `resolution` | TRUTH | Why something wasn't working |
| `constraint` | TRUTH | Something CAN'T work |
| `counter_intuitive` | TRUTH | Intuition was wrong |
| `pattern` | BEAUTY | Recurring structure recognized |
| `simplify` | BEAUTY | Complexity collapsed |

---

## Signal → Likely Eureka (When Resolved)

| Signal | When resolved, often produces | Eureka Type |
|--------|-------------------------------|-------------|
| Ugliness | "Why it wasn't working" | resolution |
| Ugliness | "Complexity collapsed" | simplify |
| Injustice | "Things are connected" | connection |
| Injustice | "Problem was framed wrong" | reframe |
| Stagnation | "What CAN'T work" | constraint |
| Stagnation | "Pattern was recurring" | pattern |

---

## Automatic Behavior Summary

### When PP Activates

```
1. gua progress              ← Shows current state
2. gua challenge list        ← Shows blockers
3. gua eureka list           ← Shows recent "ahh hah" moments
4. /territory [task]         ← Standard PP flow
5. ... work proceeds ...
6. IF eureka moment detected (recognition markers):
   - gua eureka log ...      ← Captures the realization
7. IF signal detected:
   - /signal [code]          ← Detects issue
   - gua challenge log ...   ← Logs it for tracking
8. WHEN signal resolved:
   - CHECK for eureka        ← Did understanding shift?
   - gua eureka log ...      ← Capture if "ahh hah"
9. /verify [result]          ← Standard PP verification
10. gua area update ...      ← Update progress
11. gua challenge resolve ...← Resolve any fixed issues
12. gua challenge promote ...← Promote valuable learnings
13. gua eureka promote ...   ← Promote valuable eurekas
```

### What Gets Tracked

- **Signals encountered** → Become CPT challenges
- **Learnings from resolution** → Promoted to GUA insights
- **Implementation progress** → Updated after tasks
- **Understanding depth** → Bumped when code is deeply studied
- **Eureka moments** → Captured during thinking with type and catalyst
- **Valuable eurekas** → Promoted to GUA insights

---

## Configuration Files

| File | Purpose |
|------|---------|
| `~/.claude/hookify.pp-trigger.local.md` | Auto-trigger when PP invoked |
| `~/.claude/hookify.eureka-suggest.local.md` | Suggestive hook for eureka markers |
| `~/.claude/plugins/purpose-prompter/commands/pp.md` | Main orchestrator |
| `~/.claude/plugins/purpose-prompter/commands/signal.md` | Signal detection output |
| `~/.claude/plugins/purpose-prompter/commands/eureka.md` | Eureka capture command |
| `~/.claude/CLAUDE.md` | Global PP + CPT + Eureka protocol |

---

## Restoring Configuration

If you need to restore these configurations on a new machine:

1. Copy `~/.claude/` directory from backup
2. Or re-run the setup by reading this documentation and applying manually

The key additions are:
- CPT context injection at PP start
- Eureka context injection at PP start
- Challenge logging when signals detected
- Eureka capture during thinking (recognition markers)
- Signal-Eureka Loop (capture eurekas when signals resolve)
- Progress updates after task completion
- CPT + Eureka summary in PP assessment output

---

## Version History

- **1.1** (2026-01-27): Eureka Recorder integration
  - PP trigger hook enhanced with eureka context and capture
  - pp.md orchestrator updated with eureka phases
  - signal.md updated with Signal-Eureka Loop
  - CLAUDE.md protocol updated with eureka capture protocol
  - Added eureka-suggest hookify hook
  - Added Eureka Type → PP Dimension mapping
  - Added Signal → Likely Eureka mapping

- **1.0** (2026-01-27): Initial CPT automation
  - PP trigger hook enhanced
  - pp.md orchestrator updated
  - signal.md output enhanced
  - CLAUDE.md protocol updated
