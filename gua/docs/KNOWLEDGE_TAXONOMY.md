# Knowledge Taxonomy Architecture

> **Version**: 2.0 (CPT)
> **Created**: 2026-01-27
> **Updated**: 2026-01-27 (Added CPT entities)
> **Purpose**: Define how GUA categorizes, stores, and grows knowledge over time

---

## The Five Dimensions of Knowledge

Every piece of knowledge in GUA exists in a 5-dimensional space:

### Dimension 1: PP Hierarchy Alignment

| Value | Description | Example Knowledge |
|-------|-------------|-------------------|
| `truth` | Verification, accuracy, calibration | Citation patterns, hallucination prevention |
| `understanding` | Mental models, comprehension | Why explanations, knowledge connections |
| `beauty` | Elegance, fit, coherence | Code patterns, naming conventions |
| `justice` | Placement, ownership, architecture | Component organization, responsibility |
| `creativity` | Path-building, pioneering | New structure patterns, extension approaches |

### Dimension 2: Confidence Level

| Value | Criteria | Promotion Path |
|-------|----------|----------------|
| `hypothesis` | Untested idea | → emerging after 1 validation |
| `emerging` | 1-2 observations | → confirmed after 3+ observations |
| `confirmed` | 3+ observations, validated | Stays here, can grow in depth |
| `deprecated` | Contradicted or obsolete | Historical reference only |

### Dimension 3: Scope

| Value | Applies To | Examples |
|-------|------------|----------|
| `global` | All projects, all domains | "Bridge Over Replace" pattern |
| `domain` | Specific technology/framework | AWS patterns, React patterns |
| `project` | Specific codebase | Purpose Prompter conventions |
| `personal` | Individual working style | Personal productivity patterns |

### Dimension 4: Knowledge Type

| Type | Definition | Signal |
|------|------------|--------|
| `pattern` | Recurring approach that works | "When X, do Y" |
| `anti-pattern` | Approach that fails | "Avoid doing X because Y" |
| `blindspot` | Gap or weakness to watch | "Tendency to X when Y" |
| `technique` | Specific method or procedure | "To achieve X, do A, B, C" |
| `principle` | Guiding rule or truth | "X leads to Y" |
| `model` | Mental framework | "Think of X as Y" |
| `code_area` | Tracked code region (CPT) | Implementation + understanding |
| `challenge` | Problem encountered (CPT) | PP dimension mapping |
| `progress_snapshot` | Point-in-time state (CPT) | Daily progress capture |

### Dimension 5: Temporal Status

| Value | Meaning | Review Frequency |
|-------|---------|------------------|
| `timeless` | Always applicable | Annual review |
| `current` | Applicable now, may change | Quarterly review |
| `evolving` | Actively being refined | Continuous |
| `historical` | For reference, may be outdated | Archive only |

---

## Depth Levels (Nuance Scaling)

Knowledge grows in DEPTH as it's validated and elaborated:

```
Level 1: SUMMARY
├── Name + one-line insight
├── Stored in: LIGHT.md
└── Example: "Bridge Over Replace: Extend existing systems rather than replacing"

Level 2: DESCRIPTION
├── Full description + evidence + implication
├── Stored in: LIGHT.md (expanded entries)
└── Example: Current LIGHT.md pattern entries

Level 3: NUANCES
├── Context variations + edge cases + relations
├── Stored in: knowledge/deep/<pattern-name>.md
└── Includes:
    ├── When it applies / doesn't apply
    ├── Variations by context
    ├── Related patterns
    └── Common mistakes

Level 4: EXAMPLES
├── Concrete code examples + case studies
├── Stored in: knowledge/deep/<pattern-name>.md (expanded)
└── Includes:
    ├── Code snippets with file:line citations
    ├── Session transcripts
    ├── Before/after comparisons
    └── Detailed walkthroughs
```

### Depth Promotion Criteria

| Transition | Criteria | Trigger |
|------------|----------|---------|
| L1 → L2 | 2+ observations, clear evidence | Auto during `/integrate` |
| L2 → L3 | 5+ observations, edge cases found | Manual `/integrate deep` |
| L3 → L4 | Critical path, examples exist | Manual creation |

---

## CPT Entities (Code Progress Tracker)

CPT extends GUA with code-specific knowledge types for tracking implementation progress and understanding depth across sessions.

### Code Area Entity

Tracks a region of code with granular progress and understanding metrics.

```json
{
  "knowledge_type": "code_area",
  "knowledge_id": "area#{project}#{path_hash}",
  "project": "purpose_prompter",
  "path": "gua/",
  "name": "GUA System",
  "granularity": "domain",
  "implementation_status": "in_progress",
  "implementation_pct": 75,
  "understanding_depth": "L3",
  "understanding_confidence": "high",
  "mental_model": "Shell CLI + DynamoDB for persistent knowledge",
  "active_challenges": 0,
  "last_touched": "2026-01-27T12:00:00Z"
}
```

**Granularity Levels**:
| Level | Use When | Examples |
|-------|----------|----------|
| `domain` | Tracking broad areas | `gua/`, `pp/`, `auth/` |
| `module` | Specific components | `gua/cli/`, `auth/oauth/` |
| `file` | Complex individual files | `gua.sh`, `auth.ts` |
| `function` | Critical functions | `cmd_load_active_set` |

**Understanding Depth Levels**:
| Level | Name | Meaning |
|-------|------|---------|
| L0 | Unread | Never looked at this code |
| L1 | Surveyed | Know it exists, rough purpose |
| L2 | Understood | Know structure and flow |
| L3 | Deep | Know edge cases and why |
| L4 | Expert | Could refactor confidently |

### Challenge Entity

Tracks problems encountered during development with PP dimension mapping for root cause analysis.

```json
{
  "knowledge_type": "challenge",
  "knowledge_id": "challenge#{timestamp}#{uuid}",
  "area_id": "area#purpose_prompter#abc123",
  "description": "Empty query returns when index not populated",
  "category": "bug",
  "pp_dimension": "truth",
  "status": "active",
  "resolution": null,
  "learnings": [],
  "time_spent_mins": 0,
  "promotes_to": null
}
```

**Challenge → PP Dimension Mapping**:
| Category | PP Dimension | Root Cause Question |
|----------|--------------|---------------------|
| `bug` | TRUTH | "What did I assume that was wrong?" |
| `confusion` | UNDERSTANDING | "What don't I understand about this?" |
| `ugly_hack` | BEAUTY | "Why doesn't this solution fit?" |
| `wrong_place` | JUSTICE | "Where should this actually live?" |
| `dead_end` | CREATIVITY | "What new structure is needed?" |

### Progress Snapshot Entity

Captures point-in-time state for trend analysis.

```json
{
  "knowledge_type": "progress_snapshot",
  "knowledge_id": "snapshot#{date}#{project}",
  "date": "2026-01-27",
  "project": "purpose_prompter",
  "area_count": 5,
  "avg_implementation": 65,
  "challenge_count": 2,
  "depth_distribution": {"L0": 1, "L1": 1, "L2": 2, "L3": 1},
  "areas_snapshot": [...]
}
```

### CPT → GUA Integration

Challenges can be **promoted** to GUA insights when resolved:
1. Resolved challenge has valuable learning
2. Use `gua challenge promote <id>`
3. Learning becomes a pattern/technique in GUA
4. Cross-project patterns emerge from repeated challenges

---

## File Structure

```
~/.claude/purpose_prompter/
├── integration/
│   ├── LIGHT.md                    # Always-loaded (L1-L2)
│   ├── PATH.md                     # Growth trajectory
│   └── KNOWLEDGE_TAXONOMY.md       # This file
│
├── knowledge/
│   ├── by-dimension/               # PP Hierarchy Organization
│   │   ├── truth/
│   │   │   ├── patterns.md
│   │   │   └── blindspots.md
│   │   ├── understanding/
│   │   │   ├── patterns.md
│   │   │   └── models.md
│   │   ├── beauty/
│   │   │   ├── patterns.md
│   │   │   └── anti-patterns.md
│   │   ├── justice/
│   │   │   ├── patterns.md
│   │   │   └── techniques.md
│   │   └── creativity/
│   │       ├── patterns.md
│   │       └── principles.md
│   │
│   ├── by-domain/                  # Technology Organization
│   │   ├── aws/
│   │   │   └── patterns.md
│   │   ├── claude-code/
│   │   │   └── patterns.md
│   │   ├── typescript/
│   │   │   └── patterns.md
│   │   └── general/
│   │       └── principles.md
│   │
│   └── deep/                       # Level 3-4 Files
│       ├── bridge-over-replace.md
│       ├── tiered-implementation.md
│       ├── read-before-claim.md
│       └── ...
│
├── insights/                       # Raw capture (pre-synthesis)
│   ├── blindspots.md
│   ├── observations.md
│   └── hypotheses.md
│
└── research/                       # Research findings
    ├── by-topic/
    │   ├── knowledge-management.md
    │   └── ...
    └── sources.md
```

---

## AWS Storage Mapping

### S3 Structure
```
s3://gua-knowledge-store-{user}/
├── documents/
│   ├── LIGHT.md
│   ├── PATH.md
│   └── KNOWLEDGE_TAXONOMY.md
├── knowledge/
│   ├── by-dimension/...
│   ├── by-domain/...
│   └── deep/...
└── insights/
    └── ...
```

### DynamoDB Tables

**Primary Table** (v2):
- `gua-knowledge-index`: Unified knowledge storage with GSIs
  - Primary Key: `user_id` (PK), `knowledge_id` (SK)
  - GSI: `pp-dimension-index` (user_id, pp_dimension)
  - GSI: `access-score-index` (user_id, access_score)
  - GSI: `project-status-index` (project, implementation_status) - CPT

**Legacy Tables** (for reference):
- `gua-insights`: Raw insight entries (pre-synthesis)
- `gua-research`: Raw research findings
- `gua-feedback`: Session feedback
- `gua-sessions`: Session metadata

**Division of Labor**:
- DynamoDB = Indexed knowledge, CPT tracking, raw entries
- S3 = Synthesized documents, full pattern content

---

## Knowledge Entry Metadata Schema

Each knowledge entry carries metadata for indexing and retrieval:

```json
{
  "id": "pattern-bridge-over-replace",
  "name": "Bridge Over Replace",
  "pp_dimension": "creativity",
  "confidence": "confirmed",
  "scope": "global",
  "type": "pattern",
  "temporal": "timeless",
  "depth_level": 2,
  "observation_count": 3,
  "first_observed": "2026-01-27",
  "last_observed": "2026-01-27",
  "last_validated": "2026-01-27",
  "related_patterns": ["tiered-implementation"],
  "tags": ["architecture", "extension", "integration"],
  "source_insights": ["insight-123", "insight-456"],
  "file_location": "knowledge/by-dimension/creativity/patterns.md"
}
```

---

## Access Patterns

### Session Start (Always)
```
Load: LIGHT.md (L1-L2 summary)
Time: < 1 second
Content: ~150 lines, confirmed patterns + active blindspots
```

### Topic-Specific Query
```
Trigger: Working on AWS code
Load: knowledge/by-domain/aws/patterns.md
Method: /gua-context domain:aws
```

### PP Dimension Query
```
Trigger: Checking justice patterns before placement
Load: knowledge/by-dimension/justice/patterns.md
Method: /gua-context dimension:justice
```

### Deep Dive
```
Trigger: Need nuances on specific pattern
Load: knowledge/deep/bridge-over-replace.md
Method: /gua-context deep:bridge-over-replace
```

### Research Mode
```
Trigger: Exploring raw insights
Query: DynamoDB gua-insights table
Method: gua query insights --limit 20
```

---

## Growth Rules

### 1. Depth is Earned
Knowledge only grows deeper when observations justify it. No premature depth.

### 2. Synthesis on Threshold
When raw insights reach threshold (5+ related), trigger synthesis into structured knowledge.

### 3. Cross-Reference on Relation
When patterns are related, create bidirectional references.

### 4. Staleness Review
Patterns not observed in 6+ months get marked `STALE` for review.

### 5. Never Delete
Deprecated knowledge moves to historical section, never deleted.

---

## Implementation Commands

### GUA Commands
```
gua load                            # Load active set into session
gua save                            # Save session state
gua search <query>                  # Search knowledge
gua fetch <id>                      # Fetch pattern by ID
gua active-set                      # Show active patterns
gua insight <content>               # Capture insight
```

### CPT Commands (Code Progress Tracker)
```
gua area add <project> <path> [name] [granularity]
gua area status [project]           # List tracked areas
gua area update <id> --impl X --depth LY --status S

gua challenge log <area_id> <description> [pp_dim] [category]
gua challenge resolve <id> <resolution> --learning <insight>
gua challenge list [--status S] [--dimension D]
gua challenge promote <id>          # Promote to GUA insight

gua progress [project]              # Show progress dashboard
gua progress snapshot [project]     # Create daily snapshot
```

### Plugin Commands
```
/cpt-area <add|status|update|understand>
/cpt-challenge <description|resolve:id|list|promote:id>
/cpt-context [overview|challenges|gaps]
```

### Future Commands (to implement)
```
/gua-context domain:<domain>        # Load domain-specific
/gua-context dimension:<dim>        # Load PP dimension
/gua-context deep:<pattern>         # Load deep file
/gua-relate <pattern1> <pattern2>   # Create relation
/gua-review [stale|all]             # Review knowledge health
```

---

## Migration Path

### Phase 1: Current (Done)
- LIGHT.md with flat structure
- Raw insights in DynamoDB
- Basic sync

### Phase 2: Dimensional Organization
- Create by-dimension/ structure
- Categorize existing patterns
- Update /gua-context for dimensional queries

### Phase 3: Domain Organization
- Create by-domain/ structure
- Tag patterns with domains
- Enable domain queries

### Phase 4: Deep Files
- Create deep/ structure for L3-L4
- Implement promotion criteria
- Add nuance capture

### Phase 5: Full Metadata
- Implement metadata schema
- Add cross-references
- Enable advanced queries

---

## Quick Reference

| Dimension | Values |
|-----------|--------|
| PP Hierarchy | truth, understanding, beauty, justice, creativity |
| Confidence | hypothesis, emerging, confirmed, deprecated |
| Scope | global, domain, project, personal |
| Type | pattern, anti-pattern, blindspot, technique, principle, model |
| CPT Types | code_area, challenge, progress_snapshot |
| Temporal | timeless, current, evolving, historical |

| CPT Granularity | Use When |
|-----------------|----------|
| domain | Tracking broad areas |
| module | Specific components |
| file | Complex individual files |
| function | Critical functions |

| Challenge Category | PP Dimension |
|--------------------|--------------|
| bug | truth |
| confusion | understanding |
| ugly_hack | beauty |
| wrong_place | justice |
| dead_end | creativity |

| Depth | Content | Location |
|-------|---------|----------|
| L1 | Name + one-liner | LIGHT.md |
| L2 | Description + evidence | LIGHT.md |
| L3 | Nuances + edge cases | deep/*.md |
| L4 | Examples + case studies | deep/*.md |

---

## The Taxonomy Promise

This taxonomy ensures:
1. **Findable**: Knowledge organized by multiple axes
2. **Growable**: Depth earned through validation
3. **Maintainable**: Clear promotion/demotion criteria
4. **Usable**: Right knowledge loads at right time
5. **Persistent**: Cross-device, cross-session via AWS

Knowledge compounds over time through this structure.
