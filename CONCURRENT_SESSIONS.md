# Concurrent Sessions Protocol

## Overview

This protocol enables multiple Claude Code sessions to work on the same project simultaneously without conflicts, with explicit handoffs and shared knowledge.

## Core Concepts

### Session Identity

Each Claude Code session has a unique identity:
```
SESSION_ID: sess_{random_8chars}
PROJECT: /path/to/project
ROLE: research | implementation | review | mixed
DOMAINS: [directories this session "owns"]
STATUS: active | paused | handoff_pending
```

### Lock Modes

| Mode | Description | Use Case |
|------|-------------|----------|
| **EXCLUSIVE** | Only lock holder can read/write | Critical edits, refactoring |
| **SHARED** | Multiple readers, one writer | Documentation, configs |
| **COLLABORATIVE** | Multiple writers with merge | Append-only files, logs |

### Domain vs File Locking

```
DOMAIN LOCK: Claim entire directory
└── Session A locks: human_nature_study/
    └── All files within are exclusively A's

FILE LOCK: Claim specific file
└── Session B locks: README.md
    └── Only this file is B's

FUNCTION LOCK: Claim code section (advanced)
└── Session A locks: auth.ts:handleLogin()
    └── Only this function is A's
```

---

## Directory Structure

```
~/.claude/sessions/
├── registry.json           # All known sessions
├── active/
│   ├── sess_abc123.json    # Session A metadata
│   └── sess_def456.json    # Session B metadata
├── locks/
│   ├── domain_locks.json   # Directory-level locks
│   └── file_locks.json     # File-level locks
├── handoffs/
│   ├── pending/            # Waiting for pickup
│   └── archive/            # Completed handoffs
└── messages/
    ├── sess_abc123.inbox   # Messages TO session A
    ├── sess_def456.inbox   # Messages TO session B
    └── broadcast.inbox     # Messages to ALL
```

---

## Commands Reference

### Session Management

```bash
# Initialize session (run at start)
gua session init --role=research --domains="human_nature_study/"

# Check session status
gua session status

# List all active sessions
gua session list

# End session gracefully
gua session end

# View session dashboard
gua session dashboard
```

### Locking

```bash
# Lock a domain (directory)
gua lock domain human_nature_study/ --mode=exclusive

# Lock a specific file
gua lock file INSIGHTS.md --mode=collaborative

# Lock a code section (function/class)
gua lock code auth.ts:handleLogin --mode=exclusive

# Release locks
gua unlock domain human_nature_study/
gua unlock file INSIGHTS.md
gua unlock all

# Check what's locked
gua locks list
gua locks check <file>   # Check if file is locked
```

### Handoffs

```bash
# Create a handoff for another session
gua handoff create --to=any --summary="Completed analysis"

# Create handoff for specific session
gua handoff create --to=sess_def456 --summary="Ready for implementation"

# List pending handoffs
gua handoff list

# Pick up a handoff
gua handoff pickup <handoff_id>

# Mark handoff complete
gua handoff complete <handoff_id>
```

### Messaging

```bash
# Send message to specific session
gua msg send sess_def456 "I'm about to edit INSIGHTS.md"

# Broadcast to all sessions
gua msg broadcast "Pausing for git rebase"

# Check messages
gua msg check

# Read messages
gua msg read

# Special messages
gua msg request-lock README.md "Need to update docs"
gua msg pause-request "Running migrations"
gua msg sync-point "Ready for merge"
```

### Insights (Session-Scoped)

```bash
# Capture insight (automatically session-scoped)
gua insight "Boundaries generate desire" --type=discovery

# List my session's insights
gua insights list --session

# List all insights (merged)
gua insights list --all

# Merge all session insights
gua insights merge
```

---

## Workflows

### Starting a Concurrent Session

```bash
# Terminal 1 - Research Session
gua session init --role=research --domains="human_nature_study/,docs/"
gua lock domain human_nature_study/
# Begin work...

# Terminal 2 - Implementation Session
gua session init --role=implementation --domains="src/,scripts/"
gua lock domain src/
# Begin work...
```

### Working on Shared Files

When multiple sessions need to edit the same file:

```bash
# Session A
gua lock file INSIGHTS.md --mode=collaborative
# Edit with session markers (see below)

# Session B
gua lock file INSIGHTS.md --mode=collaborative
# Edit with session markers

# Either session (or periodically)
gua merge file INSIGHTS.md
```

#### Session Markers for Shared Files

When editing collaboratively, wrap your additions:

```markdown
<!-- SESSION:sess_abc123:START:2026-02-02T21:00:00Z -->
### Insight #37: New Discovery
Content here...
<!-- SESSION:sess_abc123:END -->
```

The merge command will:
1. Find all session blocks
2. Sort by timestamp
3. Combine into clean output
4. Remove markers

### Handoff Between Sessions

```bash
# Session A (finishing up)
gua handoff create --to=any --summary="Completed forbidden psychology analysis"
# This captures:
# - Files modified
# - Insights generated
# - Pending tasks
# - Warnings about locks

gua session end
# Releases all locks, marks session inactive

# Session B (picking up)
gua msg check                      # See handoff notification
gua handoff list                   # See pending handoffs
gua handoff pickup handoff_001     # Accept handoff
# This:
# - Loads context from handoff
# - Transfers relevant locks
# - Shows pickup instructions
```

### Conflict Resolution

When conflict is detected:

```
┌─────────────────────────────────────────────────────┐
│  CONFLICT DETECTED                                  │
├─────────────────────────────────────────────────────┤
│  File: INSIGHTS.md                                  │
│  Your version: Modified 2 minutes ago              │
│  Their version: Modified 30 seconds ago            │
│  Other session: sess_def456 (implementation)       │
├─────────────────────────────────────────────────────┤
│  Options:                                           │
│  1. [RELOAD] Discard my changes, use theirs        │
│  2. [MERGE]  Attempt automatic merge               │
│  3. [DIFF]   Show differences                      │
│  4. [WAIT]   Pause until they finish               │
│  5. [MSG]    Send them a message                   │
├─────────────────────────────────────────────────────┤
│  Recommendation: MERGE (file has session markers)  │
└─────────────────────────────────────────────────────┘
```

---

## Same-Directory Nuances

### When Sessions MUST Share a Directory

Sometimes domain separation isn't possible. Handle with:

1. **File-Level Locking**
   ```bash
   # Session A
   gua lock file human_nature_study/ROLEPLAY_PSYCHOLOGY.md

   # Session B
   gua lock file human_nature_study/FORBIDDEN_PSYCHOLOGY.md
   ```

2. **Collaborative Mode for Shared Files**
   ```bash
   # Both sessions
   gua lock file human_nature_study/INSIGHTS.md --mode=collaborative
   ```

3. **Function-Level Locking (for code)**
   ```bash
   # Session A
   gua lock code api/handlers.ts:handleAuth

   # Session B
   gua lock code api/handlers.ts:handlePayment
   ```

### Append-Only File Protocol

For files that are append-only (logs, insights):

1. Always append, never modify existing content
2. Use session markers
3. Merge periodically
4. Final cleanup removes markers and renumbers

```bash
# Add to INSIGHTS.md safely
gua append INSIGHTS.md "### Insight: New finding..."
# Automatically adds session markers
```

### Structured File Protocol (JSON/YAML)

For config files, use path-based locking:

```bash
# Session A claims API config
gua lock json config.json --path="api.*"

# Session B claims UI config
gua lock json config.json --path="ui.*"
```

Merge combines both paths without conflict.

---

## Integration with Claude Code

### Session Start Behavior

When Claude Code starts, it should:
1. Check for existing sessions on this project
2. Initialize new session with role
3. Check for pending handoffs
4. Check for unread messages
5. Claim appropriate domains

### Pre-Edit Behavior

Before any file edit:
1. Check if file is locked by another session
2. Check if file mentioned in recent messages
3. If collaborative mode: add session markers
4. If conflict potential: warn user

### Session End Behavior

When ending session:
1. Create handoff if work is incomplete
2. Release all locks
3. Send end notification to other sessions
4. Mark session as inactive

---

## Best Practices

### DO

- Claim domains at session start
- Use collaborative mode for shared files
- Create handoffs when pausing mid-task
- Check messages periodically
- Release locks when done with file

### DON'T

- Edit files in another session's domain without messaging
- Hold exclusive locks longer than needed
- Ignore conflict warnings
- End session without handoff if work is pending

### Role Guidelines

| Role | Typical Domains | Lock Mode |
|------|-----------------|-----------|
| **Research** | docs/, analysis/ | Exclusive on domain |
| **Implementation** | src/, lib/ | Exclusive on domain |
| **Review** | (none - reads all) | Shared only |
| **Mixed** | Varies | File-level as needed |

---

## Session Metadata Format

```json
{
  "session_id": "sess_abc12345",
  "created": "2026-02-02T20:00:00Z",
  "last_heartbeat": "2026-02-02T21:30:00Z",
  "project": "/Users/yu/Desktop/translate_api",
  "role": "research",
  "status": "active",
  "domains": ["human_nature_study/"],
  "file_locks": [
    {
      "file": "INSIGHTS.md",
      "mode": "collaborative",
      "acquired": "2026-02-02T20:30:00Z"
    }
  ],
  "insights_generated": ["abc_20260202_001", "abc_20260202_002"],
  "files_modified": ["FORBIDDEN_PSYCHOLOGY.md", "INSIGHTS.md"],
  "messages_unread": 0
}
```

## Handoff Document Format

```yaml
handoff_id: handoff_20260202_001
from_session: sess_abc12345
to_session: any
created: "2026-02-02T21:00:00Z"
expires: "2026-02-02T23:00:00Z"
status: pending

summary: "Completed forbidden psychology deep dive"

context:
  role: research
  domains_held: ["human_nature_study/"]

  files_modified:
    - path: human_nature_study/FORBIDDEN_PSYCHOLOGY.md
      action: created
      summary: "7 mechanisms of transgression arousal"
    - path: human_nature_study/INSIGHTS.md
      action: updated
      summary: "Added insights #32-36"

  insights_generated:
    - id: 32
      title: "Boundaries Generate Desire"
    - id: 33
      title: "Seven-Mechanism Model"
    - id: 34
      title: "Transgression is THE Category"
    - id: 35
      title: "The Taboo Equilibrium"
    - id: 36
      title: "Escalation is Built In"

  pending_tasks:
    - "API search for transgression category prevalence"
    - "Cross-reference with studio archetype data"
    - "Create visualization of mechanism hierarchy"

  warnings:
    - "INSIGHTS.md has collaborative lock - merge before major edits"
    - "36 insights total - next should be #37"

  state:
    git_branch: main
    git_commit: abc1234def
    gua_version: "2026-02-02T21:00:00Z"

pickup_instructions: |
  1. Run `gua load` to sync latest insights
  2. Run `gua handoff pickup handoff_20260202_001`
  3. Continue with pending_tasks above
  4. The forbidden psychology analysis is complete
  5. Focus now on quantitative validation via API
```

---

## Troubleshooting

### "File is locked by another session"

```bash
# Check who has the lock
gua locks check FILENAME

# Request they release it
gua msg request-lock FILENAME "I need to update X"

# Or wait for lock timeout (30 min default)
```

### "Session appears stale"

Sessions with no heartbeat for 30+ minutes are considered stale:
```bash
# Clear stale sessions
gua session cleanup

# Force-release stale locks
gua locks cleanup
```

### "Merge conflict in shared file"

```bash
# View the conflict
gua merge file FILENAME --dry-run

# Manual resolution
gua merge file FILENAME --manual
# Opens diff view for manual resolution

# Force one version
gua merge file FILENAME --prefer=mine
gua merge file FILENAME --prefer=theirs
```

---

*Part of Purpose Prompter Framework*
*Version: 1.0*
*Created: 2026-02-02*
