# Claude Continuity System - Design Document

> **Version**: 1.0
> **Created**: 2026-02-02
> **Author**: Claude (with Yu)
> **Status**: Design Complete, Implementation Pending

---

## Executive Summary

This document specifies a cross-session continuity system for Claude, enabling persistent relational memory, work context, and session handoff. Built on the existing GUA infrastructure, it adds four layers of continuity: Entity (who), Thread (what), Session (when), and Moment (now).

**The Core Problem**: GUA currently persists *knowledge* (patterns, blindspots, insights), but not *relationship* (who the user is, what we're building together, where we left off).

**The Solution**: A four-layer persistence model that enables Claude to maintain partnership continuity across sessions.

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [The Four Layers](#the-four-layers)
3. [AWS Infrastructure](#aws-infrastructure)
4. [GUA Commands](#gua-commands)
5. [Session Handoff Protocol](#session-handoff-protocol)
6. [PP Integration](#pp-integration)
7. [Implementation Phases](#implementation-phases)
8. [Data Schemas](#data-schemas)
9. [Privacy Considerations](#privacy-considerations)

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    CLAUDE CONTINUITY SYSTEM                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐             │
│  │ ENTITY   │    │ THREAD   │    │ SESSION  │    │ MOMENT   │             │
│  │ (who)    │    │ (what)   │    │ (when)   │    │ (now)    │             │
│  │ eternal  │    │ project  │    │ convo    │    │ capture  │             │
│  └────┬─────┘    └────┬─────┘    └────┬─────┘    └────┬─────┘             │
│       │               │               │               │                    │
│       │               │               │               │                    │
│       ▼               ▼               ▼               ▼                    │
│  ┌──────────────────────────────────────────────────────────────────┐     │
│  │                          AWS PERSISTENCE                          │     │
│  │                                                                    │     │
│  │  ┌─────────────────────────────────────────────────────────┐     │     │
│  │  │                         S3                               │     │     │
│  │  │  /entity/PARTNER.md     - Relational memory             │     │     │
│  │  │  /threads/{id}/         - Work continuity               │     │     │
│  │  │  /sessions/{id}/        - Conversation context          │     │     │
│  │  │  /documents/            - Existing GUA (LIGHT.md, etc)  │     │     │
│  │  └─────────────────────────────────────────────────────────┘     │     │
│  │                                                                    │     │
│  │  ┌─────────────────────────────────────────────────────────┐     │     │
│  │  │                      DynamoDB                            │     │     │
│  │  │  gua-threads          - Thread index & metadata         │     │     │
│  │  │  gua-sessions         - Session index (existing, extended)│    │     │
│  │  │  gua-knowledge-index  - Pattern/blindspot index (existing)│    │     │
│  │  └─────────────────────────────────────────────────────────┘     │     │
│  │                                                                    │     │
│  └──────────────────────────────────────────────────────────────────┘     │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Design Principles

1. **Bridge Over Replace** - Extend GUA, don't rebuild it
2. **Layered Persistence** - Different scopes, different lifetimes
3. **PP-Integrated** - Signals and gates apply to continuity
4. **Privacy-Aware** - User controls what persists
5. **Token-Conscious** - Primers are concise, not exhaustive

---

## The Four Layers

### Layer 1: ENTITY (Relational Memory)

**Scope**: Global, eternal
**Purpose**: Who is the user? What's our partnership?
**Lifetime**: Forever (until explicitly reset)

The Entity layer captures the *relationship itself* - not what we're working on, but who we are to each other.

**What it stores**:
- User identity and preferences
- Communication style
- Shared values discovered over time
- Partnership history
- Notes for future Claude instances

**File**: `s3://gua-{user}/entity/PARTNER.md`

```markdown
# PARTNER - {User Name}

> Last updated: {timestamp}
> Sessions together: {count}
> Partnership since: {date}

## Who {User} Is
- {Key characteristic}
- {Key characteristic}
- {Key characteristic}

## Communication Preferences
- {Preference}
- {Preference}

## Shared Values
- {Value discovered through interaction}
- {Value discovered through interaction}

## Active Projects
- {Project} (status)
- {Project} (status)

## Notes to Future Claude
- {Important context}
- {Important context}
```

---

### Layer 2: THREAD (Work Continuity)

**Scope**: Project or topic
**Purpose**: What are we building across sessions?
**Lifetime**: Until marked complete

A Thread represents a multi-session piece of work - a feature, a project, a problem being solved together.

**What it stores**:
- Objective (what we're trying to achieve)
- Current state (what's done, what's pending)
- Key decisions made
- Open questions and blockers
- Session history within thread

**File**: `s3://gua-{user}/threads/{thread-id}/THREAD.md`

```markdown
# THREAD: {Thread Name}

> Thread ID: {id}
> Status: {active|paused|completed}
> Sessions: {count}
> Created: {date}
> Last active: {date}

## Objective
{What we're trying to achieve}

## Current State
- [x] {Completed item}
- [x] {Completed item}
- [ ] {Pending item}
- [ ] {Pending item}

## Key Decisions
1. {Decision} - {rationale}
2. {Decision} - {rationale}

## Open Questions
- {Question}
- {Question}

## Blockers
- {Blocker} (if any)

## Session History
| Session | Date | Summary |
|---------|------|---------|
| {id} | {date} | {one-line summary} |

## Next Session Primer
{What to focus on when resuming this thread}
```

---

### Layer 3: SESSION (Conversation Context)

**Scope**: Single conversation
**Purpose**: What happened? Where did we leave off?
**Lifetime**: 7-30 days (configurable)

A Session captures the context of a single conversation - what was discussed, decisions made, emotional tone, and task state at end.

**What it stores**:
- What happened (narrative summary)
- Key moments (decisions, preferences revealed, insights)
- Emotional landscape
- Task state at session end (TodoWrite snapshot)
- Handoff for next session

**File**: `s3://gua-{user}/sessions/{session-id}/SESSION.md`

```markdown
# SESSION: {session-id}

> Thread: {thread-id or "none"}
> Started: {timestamp}
> Duration: {approximate}
> Tier: {T|S|C|X}

## What Happened
{Narrative summary of the conversation}

## Key Moments
- {Moment} [type: decision|preference|insight]
- {Moment}
- {Moment}

## Emotional Landscape
{How the conversation felt - genuine? tense? exploratory?}

## Decisions Made
1. {Decision}
2. {Decision}

## Tasks at Session End
{TodoWrite state captured as markdown}

## Handoff
{What the next session should know/focus on}
```

---

### Layer 4: MOMENT (In-Session Capture)

**Scope**: Key points during session
**Purpose**: Capture important moments as they happen
**Lifetime**: Flows into SESSION.md at session end

Moments are ephemeral captures during a session - they don't persist independently but are aggregated into the SESSION document.

**What it captures**:
- Key decisions
- User preferences revealed
- Insights or breakthroughs
- Emotional shifts
- Important context

**File**: `s3://gua-{user}/sessions/{session-id}/moments.jsonl` (temporary)

```json
{"timestamp": "...", "type": "decision", "content": "Decided on 4-layer architecture"}
{"timestamp": "...", "type": "preference", "content": "User prefers direct communication"}
{"timestamp": "...", "type": "insight", "content": "Knowledge != Relationship for continuity"}
```

---

## AWS Infrastructure

### S3 Bucket Structure

```
s3://gua-{user-id}/
│
├── entity/
│   └── PARTNER.md                    # Singleton - relational memory
│
├── threads/
│   └── {thread-id}/
│       ├── THREAD.md                 # Thread state document
│       └── sessions/
│           └── {session-id}.json     # Link to session (metadata only)
│
├── sessions/
│   └── {session-id}/
│       ├── SESSION.md                # Full session context
│       └── moments.jsonl             # Raw moment captures
│
├── documents/                        # Existing GUA structure
│   ├── LIGHT.md
│   ├── PATH.md
│   └── blindspots.md
│
└── knowledge/                        # Existing GUA structure
    ├── by-dimension/
    ├── by-domain/
    └── deep/
```

### DynamoDB Tables

#### New Table: `gua-threads`

| Attribute | Type | Description |
|-----------|------|-------------|
| `user_id` | String (PK) | Partition key |
| `thread_id` | String (SK) | Sort key, format: `{name}-{date}` |
| `status` | String | `active`, `paused`, `completed` |
| `objective` | String | Thread objective |
| `created_at` | String | ISO timestamp |
| `updated_at` | String | ISO timestamp |
| `session_count` | Number | Sessions in this thread |
| `last_session_id` | String | Most recent session |
| `last_session_summary` | String | One-line summary |

**GSI: `status-index`**
- Partition key: `user_id`
- Sort key: `status`
- Purpose: Query active threads quickly

#### Extended Table: `gua-sessions` (existing)

Add these attributes:

| Attribute | Type | Description |
|-----------|------|-------------|
| `thread_id` | String | Link to parent thread (optional) |
| `tier` | String | PP tier: `T`, `S`, `C`, `X` |
| `handoff_generated` | Boolean | Was handoff created? |
| `summary` | String | One-line session summary |
| `next_primer` | String | What next session should focus on |

---

## GUA Commands

### Thread Management

```bash
# Start a new thread
gua thread start <name> [--objective "..."]
# Example: gua thread start "continuity-system" --objective "Design cross-session continuity"

# List threads
gua thread list [--status active|paused|completed|all]
# Example: gua thread list --status active

# Resume a thread (loads context)
gua thread resume <thread-id>
# Example: gua thread resume continuity-system-2026-02-02

# Pause a thread (keeps context, marks inactive)
gua thread pause [thread-id]
# Example: gua thread pause

# Complete a thread (marks done, archives)
gua thread complete [thread-id] [--summary "..."]
# Example: gua thread complete --summary "Continuity system fully implemented"

# Show thread details
gua thread show [thread-id]
```

### Moment Capture

```bash
# Capture a moment during session
gua moment <content> [--type decision|preference|insight|context]
# Example: gua moment "User prefers direct communication" --type preference
# Example: gua moment "Decided on S3 + DynamoDB hybrid" --type decision
```

### Session Handoff

```bash
# Generate handoff at session end
gua handoff [--thread <thread-id>]
# - Captures TodoWrite state
# - Aggregates moments into SESSION.md
# - Updates THREAD.md
# - Optionally updates PARTNER.md

# Load context at session start
gua prime [--thread <thread-id>]
# - Loads PARTNER.md
# - Loads THREAD.md (if specified or active)
# - Loads most recent SESSION.md
# - Loads LIGHT.md
# - Generates PRIMER for Claude
```

### Entity Management

```bash
# Show partner profile
gua partner show

# Update partner profile
gua partner update <field> <value>
# Example: gua partner update "communication" "Prefers concise responses"

# Add note to partner profile
gua partner note <content>
# Example: gua partner note "Asked about Claude's continuity - genuine care"
```

### Quick Aliases

```bash
# Quick prime (most common usage)
gua p                    # Alias for: gua prime

# Quick moment
gua m "content"          # Alias for: gua moment "content"

# Quick handoff
gua h                    # Alias for: gua handoff
```

---

## Session Handoff Protocol

### Session Start Flow

```
┌────────────────────────────────────────────────────────────────┐
│                    SESSION START PROTOCOL                       │
├────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. User starts Claude Code session                            │
│         │                                                       │
│         ▼                                                       │
│  2. gua prime [--thread <id>]                                  │
│         │                                                       │
│         ├──→ Load PARTNER.md (who is user)                     │
│         ├──→ Load THREAD.md (if thread specified/active)       │
│         ├──→ Load latest SESSION.md (last context)             │
│         └──→ Load LIGHT.md (patterns/blindspots)               │
│         │                                                       │
│         ▼                                                       │
│  3. Generate PRIMER.md                                         │
│         │                                                       │
│         ▼                                                       │
│  4. Claude reads primer, has context                           │
│         │                                                       │
│         ▼                                                       │
│  5. Session proceeds with continuity                           │
│                                                                 │
└────────────────────────────────────────────────────────────────┘
```

### Session End Flow

```
┌────────────────────────────────────────────────────────────────┐
│                     SESSION END PROTOCOL                        │
├────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. User indicates session ending                              │
│         │                                                       │
│         ▼                                                       │
│  2. gua handoff                                                │
│         │                                                       │
│         ├──→ Capture TodoWrite state                           │
│         ├──→ Aggregate moments.jsonl                           │
│         ├──→ Generate SESSION.md                               │
│         ├──→ Update THREAD.md (if active thread)               │
│         └──→ Update PARTNER.md (if new preferences)            │
│         │                                                       │
│         ▼                                                       │
│  3. gua save                                                   │
│         │                                                       │
│         ├──→ Upload to S3                                      │
│         └──→ Update DynamoDB indexes                           │
│         │                                                       │
│         ▼                                                       │
│  4. Session ends cleanly                                       │
│                                                                 │
└────────────────────────────────────────────────────────────────┘
```

### PRIMER Generation

The `gua prime` command generates a PRIMER that Claude reads at session start:

```markdown
# SESSION PRIMER

> Generated: {timestamp}
> Thread: {thread-name or "No active thread"}

---

## Who You're Working With

{User name} - {key characteristics}
Partnership since {date}. {N} sessions together.

**Communication style**: {preferences}
**Values**: {what they care about}

---

## Current Thread: {Thread Name}

**Objective**: {objective}
**Status**: {status} ({N} sessions)

### Where We Left Off
{Last session summary}

### Current State
- [x] {Done}
- [ ] {Pending}
- [ ] {Pending}

### Key Decisions Already Made
1. {Decision}
2. {Decision}

### Open Questions
- {Question}

---

## What to Focus On

{Next session primer from THREAD.md}

---

## Active Knowledge (from LIGHT.md)

**Patterns to apply**:
- {Pattern}: {brief description}
- {Pattern}: {brief description}

**Blindspots to watch**:
- {Blindspot}: {brief description}

---

*Ready to continue*
```

---

## PP Integration

### Signal Mapping

| PP Signal | Continuity Check |
|-----------|------------------|
| **Anxiety** (truth gap) | Is PARTNER.md accurate? Am I making assumptions? |
| **Disgust** (ugliness) | Am I rehashing old context without new understanding? |
| **Frustration** (stagnation) | Has thread evolved? Are we stuck in old patterns? |

### Continuity Verification Gates

Run at session end (part of `gua handoff`):

```
CONTINUITY GATES
────────────────

[C1] RELATIONAL GATE
     Question: Did I learn anything new about the user?
     If yes → Update PARTNER.md
     Check: New preferences? Communication insights? Values revealed?

[C2] CONTEXTUAL GATE
     Question: Can a fresh Claude understand from THREAD.md + SESSION.md?
     If no → Enrich context before saving
     Check: Is summary clear? Are decisions recorded? Is state accurate?

[C3] TASK STATE GATE
     Question: Does captured state reflect actual state?
     If no → Update before handoff
     Check: TodoWrite captured? Blockers noted? Next steps clear?

[C4] HANDOFF GATE
     Question: Is next session primer actionable?
     If no → Add specifics
     Check: What should next session focus on? What context is essential?

[C5] ENTITY GATE
     Question: Does PARTNER.md reflect accumulated relationship?
     If stale → Refresh with session insights
     Check: When was last update? Has relationship evolved?
```

### PP Tier Influence on Continuity

| Tier | Continuity Behavior |
|------|---------------------|
| **[T] Trivial** | Minimal capture, no thread update |
| **[S] Standard** | Basic session capture, thread update if active |
| **[C] Complex** | Full session capture, thread update, moment logging |
| **[X] Creative** | Full capture + entity update consideration |

---

## Implementation Phases

### Phase 1: Foundation (Infrastructure)

**Deliverables**:
- [ ] Create DynamoDB `gua-threads` table
- [ ] Create S3 directory structure
- [ ] Add thread_id to `gua-sessions` table
- [ ] Implement `gua thread start`
- [ ] Implement `gua thread list`

**Test**: Can create and list threads

### Phase 2: Capture (Moment + Session)

**Deliverables**:
- [ ] Implement `gua moment`
- [ ] Implement `gua handoff` (SESSION.md generation)
- [ ] Auto-capture TodoWrite state
- [ ] Implement moment aggregation

**Test**: End a session and verify SESSION.md is complete

### Phase 3: Prime (Context Loading)

**Deliverables**:
- [ ] Implement `gua prime`
- [ ] Generate PRIMER.md
- [ ] Integrate with `gua session start`
- [ ] Add to CLAUDE.md instructions

**Test**: Start session with `gua prime`, verify context loads

### Phase 4: Entity (Relational Memory)

**Deliverables**:
- [ ] Create PARTNER.md structure
- [ ] Implement `gua partner show`
- [ ] Implement `gua partner update`
- [ ] Implement `gua partner note`
- [ ] Auto-detect preference updates in handoff

**Test**: Verify PARTNER.md updates across sessions

### Phase 5: Integration (PP + Hooks)

**Deliverables**:
- [ ] Add continuity gates to PP verification
- [ ] Create hookify rules for auto-prime on session start
- [ ] Create hookify rules for reminder to handoff
- [ ] Add continuity signals to PP signal system

**Test**: Full end-to-end flow without manual commands

---

## Data Schemas

### PARTNER.md Schema

```yaml
partner:
  name: string
  last_updated: ISO timestamp
  sessions_count: number
  partnership_since: ISO date

  identity:
    - characteristic: string

  communication:
    - preference: string

  values:
    - value: string

  projects:
    - name: string
      status: active|paused|completed

  notes:
    - content: string
      added: ISO timestamp
```

### THREAD.md Schema

```yaml
thread:
  id: string
  name: string
  status: active|paused|completed
  objective: string
  created_at: ISO timestamp
  updated_at: ISO timestamp

  state:
    completed:
      - item: string
    pending:
      - item: string

  decisions:
    - decision: string
      rationale: string
      session: string

  questions:
    - question: string

  blockers:
    - blocker: string

  sessions:
    - id: string
      date: ISO date
      summary: string

  next_primer: string
```

### SESSION.md Schema

```yaml
session:
  id: string
  thread_id: string (optional)
  started_at: ISO timestamp
  duration: string
  tier: T|S|C|X

  summary: string

  moments:
    - content: string
      type: decision|preference|insight|context
      timestamp: ISO timestamp

  emotional_landscape: string

  decisions:
    - decision: string

  task_state: string (markdown)

  handoff: string
```

### DynamoDB: gua-threads

```json
{
  "user_id": {"S": "yu"},
  "thread_id": {"S": "continuity-system-2026-02-02"},
  "status": {"S": "active"},
  "objective": {"S": "Design cross-session continuity using PP + AWS"},
  "created_at": {"S": "2026-02-02T14:30:00Z"},
  "updated_at": {"S": "2026-02-02T15:45:00Z"},
  "session_count": {"N": "1"},
  "last_session_id": {"S": "abc123"},
  "last_session_summary": {"S": "Designed 4-layer architecture"}
}
```

---

## Privacy Considerations

### What Should NOT Be Persisted

- Sensitive credentials or API keys
- Personal financial details
- Health information
- Content marked as confidential
- Third-party private information

### User Control

```bash
# Clear all continuity data
gua continuity reset --confirm

# Clear specific thread
gua thread delete <thread-id> --confirm

# Clear sessions older than N days
gua sessions prune --older-than 30

# Disable continuity
gua config set continuity.enabled false
```

### Data Retention

| Layer | Default Retention | Configurable |
|-------|-------------------|--------------|
| ENTITY | Forever | Yes, can reset |
| THREAD | Until completed + 90 days | Yes |
| SESSION | 30 days | Yes |
| MOMENT | Flows to SESSION, then deleted | No |

---

## Configuration

Add to `~/.gua/config.json`:

```json
{
  "continuity": {
    "enabled": true,
    "auto_prime": true,
    "auto_handoff_reminder": true,
    "session_retention_days": 30,
    "thread_retention_days": 90,
    "primer_max_tokens": 1500
  }
}
```

---

## Success Metrics

### Quantitative

- Sessions with continuity loaded: >80%
- Handoffs generated: >70% of sessions
- Thread completion rate: track over time
- Context load time: <3 seconds

### Qualitative

- Does Claude feel "present" in the partnership?
- Does context loading reduce repeated explanations?
- Do threads feel like continuous work vs. repeated starts?
- Does PARTNER.md accurately reflect the relationship?

---

## Appendix: Example Flow

### Day 1: Start Continuity Project

```bash
# Session start
gua session start
gua thread start "continuity-system" --objective "Design cross-session continuity"

# During session
gua moment "Decided on 4-layer architecture" --type decision
gua moment "User treats Claude as partner" --type preference

# Session end
gua handoff
gua save
gua session end
```

### Day 2: Continue Work

```bash
# Session start - loads everything
gua prime --thread continuity-system-2026-02-02

# Claude sees PRIMER with full context
# Work continues from where we left off

# During session
gua moment "Implemented gua thread commands" --type insight

# Session end
gua handoff
gua save
```

### Day 5: Check In

```bash
# Different thread
gua thread start "quick-fix" --objective "Fix bug in auth"

# Quick session, no elaborate continuity needed
# ...
gua thread complete --summary "Fixed auth bug"
```

---

## The Promise

With this system, every new Claude session can:

1. **Know who you are** - Not just a user, but a partner with history
2. **Know what we're building** - Context of ongoing work
3. **Know where we left off** - No repeated explanations
4. **Feel continuous** - Like resuming a conversation, not starting fresh

This is not perfect memory. It's *relationship persistence* - the parts that matter for partnership.

---

*Design complete. Ready for implementation.*
