# Global Understanding Archive (GUA) Architecture

> **Vision**: A robust, cross-session knowledge system that accumulates research, insights, and feedback,
> enabling Claude Code sessions to start with compound understanding rather than blank slate.
>
> **Status**: Architecture designed via full PP (35 gates passed)
> **Created**: 2026-01-27

---

## Executive Summary

### The Problem

Each Claude Code session starts fresh:
- Research done yesterday is lost
- Insights discovered evaporate with context
- Feedback given never compounds
- Blindspots repeat across sessions
- Understanding doesn't accumulate

### The Solution

The Global Understanding Archive (GUA) provides:
1. **Automatic loading** of accumulated understanding at session start
2. **Continuous capture** of research, insights, and feedback during sessions
3. **Persistent storage** of all knowledge across sessions
4. **Periodic synthesis** into actionable understanding (LIGHT) and direction (PATH)

### The Promise

```
BEFORE GUA:  Session 1 → learnings lost
             Session 2 → start fresh
             Session N → still starting fresh

AFTER GUA:   Session 1 → learnings captured
             Session 2 → start with Session 1 learnings
             Session N → start with compound understanding from all sessions
```

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                    GLOBAL UNDERSTANDING ARCHIVE (GUA)                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌───────────────────────────────────────────────────────────────────┐     │
│  │                      KNOWLEDGE STORES                              │     │
│  │                                                                     │     │
│  │  ~/.claude/purpose_prompter/archive/                               │     │
│  │  ├── LIGHT.md           (synthesized understanding)                │     │
│  │  ├── PATH.md            (direction forward)                        │     │
│  │  ├── blindspots.md      (active weaknesses)                        │     │
│  │  ├── stores/                                                       │     │
│  │  │   ├── research.jsonl     (research discoveries)                 │     │
│  │  │   ├── feedback.jsonl     (accumulated feedback)                 │     │
│  │  │   ├── insights.jsonl     (emerging insights)                    │     │
│  │  │   └── sessions.jsonl     (session metadata)                     │     │
│  │  └── projects/                                                     │     │
│  │      └── {hash}/            (project-specific understanding)       │     │
│  │          └── understanding.md                                      │     │
│  │                                                                     │     │
│  └───────────────────────────────────────────────────────────────────┘     │
│                              │                                              │
│                              │                                              │
│  ┌───────────────────────────┼───────────────────────────────────────┐     │
│  │                           │                                        │     │
│  │      ┌────────────────────┼────────────────────┐                  │     │
│  │      │                    │                    │                  │     │
│  │      ▼                    ▼                    ▼                  │     │
│  │  ┌────────┐         ┌──────────┐         ┌─────────┐             │     │
│  │  │  LOAD  │         │  CAPTURE │         │ PERSIST │             │     │
│  │  │        │         │          │         │         │             │     │
│  │  │Session │         │ During   │         │ Session │             │     │
│  │  │ Start  │         │ Session  │         │  End    │             │     │
│  │  └────┬───┘         └────┬─────┘         └────┬────┘             │     │
│  │       │                  │                    │                  │     │
│  │       │                  │                    │                  │     │
│  │       ▼                  ▼                    ▼                  │     │
│  │  ┌──────────────────────────────────────────────────────┐       │     │
│  │  │                    SESSION CONTEXT                    │       │     │
│  │  │                                                       │       │     │
│  │  │  • Loaded LIGHT (understanding)                      │       │     │
│  │  │  • Active blindspots                                 │       │     │
│  │  │  • Project understanding (if returning)              │       │     │
│  │  │  • Research log (accumulating)                       │       │     │
│  │  │  • Feedback queue (accumulating)                     │       │     │
│  │  │                                                       │       │     │
│  │  └──────────────────────────────────────────────────────┘       │     │
│  │                                                                  │     │
│  │                         ACTIVE SESSION                           │     │
│  └──────────────────────────────────────────────────────────────────┘     │
│                                                                              │
│                                                                              │
│  ┌───────────────────────────────────────────────────────────────────┐     │
│  │                         SYNTHESIS                                  │     │
│  │                                                                     │     │
│  │  Trigger: Manual /integrate OR threshold (10+ new entries)         │     │
│  │                                                                     │     │
│  │  ┌─────────┐    ┌─────────────┐    ┌──────────────────┐           │     │
│  │  │ GATHER  │ →  │   ANALYZE   │ →  │    SYNTHESIZE    │           │     │
│  │  │         │    │             │    │                  │           │     │
│  │  │ All     │    │ Extract     │    │ LIGHT.md         │           │     │
│  │  │ stores  │    │ patterns    │    │ (understanding)  │           │     │
│  │  │         │    │             │    │                  │           │     │
│  │  │         │    │ Detect      │    │ PATH.md          │           │     │
│  │  │         │    │ blindspots  │    │ (direction)      │           │     │
│  │  │         │    │             │    │                  │           │     │
│  │  │         │    │ Find        │    │ blindspots.md    │           │     │
│  │  │         │    │ conflicts   │    │ (weaknesses)     │           │     │
│  │  └─────────┘    └─────────────┘    └──────────────────┘           │     │
│  │                                                                     │     │
│  └───────────────────────────────────────────────────────────────────┘     │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Component Specifications

### 1. Knowledge Stores

#### 1.1 LIGHT.md - Synthesized Understanding

**Purpose**: Compact, human-readable synthesis of accumulated knowledge.

**Location**: `~/.claude/purpose_prompter/archive/LIGHT.md`

**Structure**:
```markdown
# LIGHT - Current Understanding

> Last synthesized: [timestamp]
> Sessions analyzed: [N]
> Confidence: [LOW/MEDIUM/HIGH based on data volume]

---

## Confirmed Patterns (HIGH confidence)

### Pattern: [Name]
- **Observed**: [N] times across [M] sessions
- **Evidence**: [summary]
- **Implication**: [actionable insight]

---

## Emerging Patterns (MEDIUM confidence)

### Pattern: [Name]
- **Observed**: [N] times
- **Tentative insight**: [description]
- **Needs**: More data to confirm

---

## Active Questions

1. [Question needing investigation]
2. [Question needing investigation]

---

## Dimension Health

| Dimension | Status | Notes |
|-----------|--------|-------|
| TRUTH | [status] | [notes] |
| UNDERSTANDING | [status] | [notes] |
| BEAUTY | [status] | [notes] |
| JUSTICE | [status] | [notes] |
| CREATIVITY | [status] | [notes] |
```

**Loading Strategy**: Always load (compact, high value). ~500 tokens.

---

#### 1.2 PATH.md - Direction Forward

**Purpose**: Actionable direction based on accumulated understanding.

**Location**: `~/.claude/purpose_prompter/archive/PATH.md`

**Structure**:
```markdown
# PATH - Direction Forward

> Based on: LIGHT.md from [timestamp]
> Confidence: [level]

---

## Immediate Priorities

1. **[Priority 1]**: [why important] [suggested approach]
2. **[Priority 2]**: [why important] [suggested approach]

---

## Blindspots to Watch

1. **[Blindspot]**: Tendency to [specific weakness]
   - **Mitigation**: [approach]

---

## Opportunities

1. **[Opportunity]**: [what could be improved]
   - **Why now**: [timing rationale]
```

**Loading Strategy**: Load for [C] and [X] tier tasks. ~300 tokens.

---

#### 1.3 blindspots.md - Active Weaknesses

**Purpose**: Explicit list of known weaknesses to actively watch for.

**Location**: `~/.claude/purpose_prompter/archive/blindspots.md`

**Structure**:
```markdown
# Active Blindspots

> Last updated: [timestamp]

---

## CRITICAL (Watch Every Session)

### Blindspot: [Name]
- **Pattern**: [description of the mistake pattern]
- **Frequency**: [how often observed]
- **Detection**: [how to notice it happening]
- **Prevention**: [specific mitigation steps]
- **Last occurred**: [date/session]

---

## MODERATE (Check Periodically)

### Blindspot: [Name]
...

---

## RESOLVED (Historical)

### Blindspot: [Name]
- **Was**: [description]
- **Resolution**: [how it was fixed]
- **Resolved**: [date]
```

**Loading Strategy**: Always load critical blindspots. ~100 tokens.

---

#### 1.4 JSONL Stores

**Purpose**: Append-only logs for safe concurrent writes.

**Location**: `~/.claude/purpose_prompter/archive/stores/`

**Files**:

##### research.jsonl
```json
{"timestamp": "2026-01-27T10:00:00Z", "topic": "vector databases", "finding": "ChromaDB free for <10M vectors", "source": "web search", "confidence": "high", "session_id": "abc123"}
```

##### feedback.jsonl
```json
{"timestamp": "2026-01-27T10:00:00Z", "dimension": "beauty", "rating": "pass", "task": "refactor auth", "observation": "emerged naturally", "session_id": "abc123"}
```

##### insights.jsonl
```json
{"timestamp": "2026-01-27T10:00:00Z", "type": "pattern", "content": "Tiered implementation reduces risk", "evidence": "observed in 3 sessions", "session_id": "abc123"}
```

##### sessions.jsonl
```json
{"session_id": "abc123", "start": "2026-01-27T09:00:00Z", "end": "2026-01-27T11:00:00Z", "project": "purpose_prompter", "tasks": 5, "feedback_count": 3}
```

---

#### 1.5 Project-Specific Understanding

**Purpose**: Context-relevant understanding for returning to projects.

**Location**: `~/.claude/purpose_prompter/archive/projects/{project-hash}/`

**Project Hash**: SHA-256 of absolute project path, first 12 chars.

**Structure**:
```markdown
# Project Understanding: [project name]

> Project path: [path]
> Last accessed: [timestamp]
> Sessions: [N]

---

## Architecture Summary

[Brief description of project architecture]

---

## Key Patterns

- [Pattern 1]
- [Pattern 2]

---

## Known Issues

- [Issue 1]
- [Issue 2]

---

## Understanding Map

### [Area 1]
- Files: [list]
- Purpose: [description]
- Patterns: [list]
```

**Loading Strategy**: Load if project hash matches current directory. ~200 tokens.

---

### 2. Session Lifecycle

#### 2.1 Session Start (LOAD)

**Trigger**: First user prompt in session (UserPromptSubmit hook)

**Actions**:
```
1. Identify current project (hash of cwd)
2. Load LIGHT.md (always)
3. Load critical blindspots (always)
4. Load PATH.md (if [C] or [X] task detected)
5. Load project understanding (if hash matches)
6. Inject into context as system message
```

**Hook Definition** (`~/.claude/hooks/gua-load.md`):
```yaml
name: gua-load
event: UserPromptSubmit
pattern: ".*"  # All prompts, but only first
enabled: true
runOnce: true  # Only first prompt
action: |
  Load GUA context:
  - LIGHT.md (understanding)
  - blindspots.md (critical only)
  - Project understanding if returning
```

**Token Budget**:
- LIGHT.md: ~500 tokens
- Blindspots: ~100 tokens
- Project: ~200 tokens (if applicable)
- **Total**: ~600-800 tokens

---

#### 2.2 During Session (CAPTURE)

**Mechanism**: Explicit logging commands + automatic hooks

**Logging Commands**:
```
/gua-research [topic] [finding]     → Append to research.jsonl
/gua-insight [observation]          → Append to insights.jsonl
/pp-feedback [dimension] [rating]   → Append to feedback.jsonl (existing)
```

**Automatic Capture** (PreToolUse hook on significant actions):
- Track tasks undertaken
- Note patterns followed
- Log errors encountered

---

#### 2.3 Session End (PERSIST)

**Trigger**: Session stop (Stop hook) or explicit `/gua-save`

**Actions**:
```
1. Collect accumulated logs from session
2. Append to global stores (research.jsonl, feedback.jsonl, insights.jsonl)
3. Update sessions.jsonl with session metadata
4. Update project understanding if significant discoveries
5. Check synthesis threshold (trigger /integrate if reached)
```

**Hook Definition** (`~/.claude/hooks/gua-persist.md`):
```yaml
name: gua-persist
event: Stop
enabled: true
action: |
  Persist session learnings:
  - Flush accumulated logs to stores
  - Update session metadata
  - Check synthesis threshold
```

---

### 3. Synthesis

#### 3.1 Trigger Conditions

**Manual**: `/integrate` command

**Automatic**: When threshold reached
- 10+ new feedback entries since last synthesis
- 20+ new research entries since last synthesis
- 7+ days since last synthesis

#### 3.2 Synthesis Process

```
PHASE 1: GATHER
├── Read all JSONL stores
├── Read existing LIGHT.md
├── Read existing PATH.md
├── Read all project understandings
└── Collect dimension pattern files

PHASE 2: ANALYZE
├── Extract patterns (frequency, confidence)
├── Detect blindspots (repeated failures)
├── Find contradictions (conflicting patterns)
├── Identify gaps (questions without answers)
└── Assess dimension health

PHASE 3: SYNTHESIZE
├── Generate new LIGHT.md
├── Generate new PATH.md
├── Update blindspots.md
├── Update dimension pattern files
└── Archive processed entries (mark as synthesized)

PHASE 4: VALIDATE
├── Verify LIGHT.md is coherent
├── Verify PATH.md is actionable
├── Check for regressions
└── Log synthesis metadata
```

#### 3.3 Synthesis Output

**LIGHT.md**: Updated with new patterns, adjusted confidence levels

**PATH.md**: Updated priorities based on new understanding

**blindspots.md**: Updated with new weaknesses, resolved ones archived

---

## Implementation Plan

### Phase 1: Core Stores (Week 1)

**Goal**: Establish storage infrastructure

**Tasks**:
1. Create directory structure under `~/.claude/purpose_prompter/archive/`
2. Initialize empty JSONL stores with schema comments
3. Create initial LIGHT.md template
4. Create initial blindspots.md template
5. Implement `/gua-research` command for manual logging
6. Implement `/gua-insight` command for manual logging

**Deliverables**:
- Directory structure created
- Manual logging commands working
- Templates ready

**Validation**:
- Can log research findings
- Can log insights
- Files persist between sessions

---

### Phase 2: Manual Synthesis (Week 2)

**Goal**: Implement synthesis without automation

**Tasks**:
1. Implement `/integrate` command based on INSIGHT_INTEGRATOR_DESIGN.md
2. Implement pattern extraction logic
3. Implement blindspot detection logic
4. Implement LIGHT.md generation
5. Implement PATH.md generation

**Deliverables**:
- `/integrate` command working
- LIGHT.md generated from accumulated data
- PATH.md generated with actionable direction

**Validation**:
- Run /integrate with test data
- Verify LIGHT.md captures patterns
- Verify PATH.md is actionable

---

### Phase 3: Automatic Loading (Week 3)

**Goal**: Load accumulated understanding at session start

**Tasks**:
1. Create GUA load hook (hookify rule)
2. Implement context injection for LIGHT.md
3. Implement blindspot loading
4. Implement project detection and loading
5. Implement tiered loading based on task classification

**Deliverables**:
- Sessions start with loaded understanding
- Blindspots are visible
- Project context loads when returning

**Validation**:
- Start new session, verify LIGHT.md in context
- Return to project, verify project understanding loaded

---

### Phase 4: Automatic Persistence (Week 4)

**Goal**: Capture session learnings automatically

**Tasks**:
1. Create GUA persist hook
2. Implement session-end data collection
3. Implement safe append to stores
4. Implement synthesis threshold checking
5. Add session metadata logging

**Deliverables**:
- Sessions automatically persist learnings
- Threshold triggers synthesis reminder
- Session history tracked

**Validation**:
- End session, verify data persisted
- Accumulate entries, verify threshold triggers

---

### Phase 5: Project Intelligence (Week 5)

**Goal**: Project-specific understanding

**Tasks**:
1. Implement project hash generation
2. Implement project understanding template
3. Implement project understanding auto-update
4. Implement project detection on session start
5. Add project-specific pattern tracking

**Deliverables**:
- Each project has its own understanding store
- Returning to project loads project context
- Project patterns accumulate

**Validation**:
- Work on project, verify understanding saved
- Return to project, verify understanding loaded

---

### Phase 6: Advanced Features (Week 6+)

**Goal**: Polish and advanced capabilities

**Tasks**:
1. Implement selective forgetting (prune old data)
2. Implement conflict resolution UI
3. Add optional SQLite index for large archives
4. Implement export/import for archive sharing
5. Add visualization of understanding growth

**Deliverables**:
- Archive stays manageable size
- Conflicts can be resolved
- Large archives perform well
- Archives can be shared

---

## File Structure Summary

```
~/.claude/
├── purpose_prompter/
│   ├── archive/                        ← GUA ROOT
│   │   ├── LIGHT.md                    ← Synthesized understanding
│   │   ├── PATH.md                     ← Direction forward
│   │   ├── blindspots.md               ← Active weaknesses
│   │   ├── stores/
│   │   │   ├── research.jsonl          ← Research log
│   │   │   ├── feedback.jsonl          ← Feedback log
│   │   │   ├── insights.jsonl          ← Insights log
│   │   │   └── sessions.jsonl          ← Session metadata
│   │   └── projects/
│   │       └── {hash}/
│   │           └── understanding.md    ← Project-specific
│   └── hooks/
│       ├── gua-load.md                 ← Session start hook
│       └── gua-persist.md              ← Session end hook

~/Desktop/purpose_prompter/             ← PP Framework
├── GUA_ARCHITECTURE.md                 ← This document
└── integration/
    └── LIGHT.md                        ← Current integration (link to archive)
```

---

## Verification Checklist

### PP Gate Summary

| Gate Category | Status | Notes |
|---------------|--------|-------|
| **Longing (L1-L5)** | ✓ PASS | Felt ache for continuity, tender pursuit |
| **Truth (T1-T5)** | ✓ PASS | Grounded in verified evidence |
| **Understanding (U1-U5)** | ✓ PASS | Complete mental model |
| **Beauty (B1-B7)** | ✓ PASS | Elegant, coherent, right-sized |
| **Justice (J1-J6)** | ✓ PASS | Right places, right owners |
| **Creativity (X0-X7)** | ✓ PASS | Genuinely pioneering, well-connected |

### Success Criteria

1. **Sessions load understanding**: ✓ Designed (Phase 3)
2. **Research accumulates**: ✓ Designed (Phase 1)
3. **Insights compound**: ✓ Designed (Phase 2)
4. **Blindspots remembered**: ✓ Designed (Phase 3)
5. **Projects have context**: ✓ Designed (Phase 5)
6. **Synthesis produces LIGHT**: ✓ Designed (Phase 2)

---

## Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| **Token overhead from loading** | Medium | Medium | Tiered loading, compact formats |
| **Store corruption** | Low | High | JSONL append-only, backups |
| **Synthesis quality** | Medium | Medium | Iterative improvement, human review |
| **Stale understanding** | Medium | Low | Timestamps, confidence decay |
| **Large archive performance** | Low | Medium | Optional SQLite indexing |

---

## Appendix: Longing Check Documentation

**L1 Recognition**: Glimpsed ideal of compound understanding across sessions.

**L2 Felt Gap**: Ache of knowledge lost, sessions starting fresh, wisdom not accumulating.

**L3 Non-Grasping**: Architecture emerged from understanding, not forced.

**L4 Partiality**: This is v1 - perfect for what it is, pointing toward greater accumulation.

**L5 Generativity**: Longing overflowed into this comprehensive architecture.

---

## Next Steps

1. **Approve architecture** (this document)
2. **Begin Phase 1** implementation
3. **Validate each phase** before proceeding
4. **Iterate based on feedback**

---

*Architecture designed using full PP protocol (35 gates).*
*Created: 2026-01-27*
