# GUA Infrastructure Configuration

> **Purpose**: Canonical configuration reference for all Claude sessions and devices using Purpose Prompter with GUA.
> **Last Updated**: 2026-01-27

---

## AWS Infrastructure

### Region
```
us-west-2
```

### S3 Bucket
```
gua-knowledge-store-yu
```

Contents:
- `documents/` - Synced markdown files (LIGHT.md, PATH.md, etc.)
- `knowledge/` - Deep knowledge patterns

### DynamoDB Tables

| Table | Purpose |
|-------|---------|
| `gua-research` | Research findings log |
| `gua-insights` | Insights with taxonomy metadata |
| `gua-feedback` | PP feedback entries |
| `gua-sessions` | Session tracking |
| `gua-knowledge-index` | Unified knowledge index (v2) - patterns, CPT, eurekas |

### Global Secondary Indexes (on `gua-knowledge-index`)

| GSI Name | Purpose |
|----------|---------|
| `access-score-index` | Query by access frequency/recency |
| `dimension-confidence-index` | Query by PP dimension |
| `type-scope-index` | Query by knowledge type and scope |
| `project-status-index` | CPT: Query areas by project and status |
| `eureka-type-index` | Eureka: Query by eureka type |
| `session-eurekas-index` | Eureka: Query eurekas by session |
| `platform-domain-index` | Dev Knowledge: Query by platform+domain |

---

## Local Configuration

### Config File Location
```
~/.gua/config.json
```

### Required Config Structure
```json
{
  "user_id": "yu",
  "region": "us-west-2",
  "s3_bucket": "gua-knowledge-store-yu",
  "device_id": "<unique-device-id>",
  "device_name": "<device-name>",
  "tables": {
    "research": "gua-research",
    "feedback": "gua-feedback",
    "insights": "gua-insights",
    "sessions": "gua-sessions",
    "knowledge_index": "gua-knowledge-index"
  },
  "version": "2.0",
  "cpt": {
    "enabled": true
  }
}
```

### Local Paths
```
~/.gua/
├── config.json              # Configuration
├── gua.sh                   # CLI script
├── setup.sh                 # Initial setup
├── upgrade-v2.sh            # Upgrade to v2 schema
├── upgrade-cpt.sh           # Add CPT GSI
└── upgrade-eureka.sh        # Add Eureka GSIs

~/.claude/
├── CLAUDE.md                # PP orchestration (includes GUA protocol)
├── hookify.pp-trigger.local.md      # PP auto-trigger with CPT+Eureka
├── hookify.eureka-suggest.local.md  # Eureka detection hook
└── plugins/purpose-prompter/
    └── commands/
        ├── pp.md            # Main PP orchestrator
        ├── eureka.md        # /eureka command
        ├── signal.md        # /signal command
        └── ...              # Other PP commands
```

---

## Knowledge Types in `gua-knowledge-index`

| knowledge_type | Purpose | Key Fields |
|----------------|---------|------------|
| `pattern` | Reusable knowledge patterns | dimension, scope, confidence |
| `blindspot` | Known weaknesses | dimension, status |
| `technique` | How-to knowledge | dimension, scope |
| `code_area` | CPT: Tracked code areas | project, path, impl_pct, depth |
| `challenge` | CPT: Logged challenges | area_id, pp_dimension, category, status |
| `eureka_moment` | Eureka: Ahh hah moments | eureka_type, catalyst, session_id |
| `progress_snapshot` | CPT: Daily snapshots | project, date |
| `dev_knowledge` | Dev: Platform-specific knowledge | platform, domain, dev_type |

---

## CLI Commands Reference

### Core Sync
```bash
~/.gua/gua.sh load          # Download from AWS
~/.gua/gua.sh save          # Upload to AWS
~/.gua/gua.sh status        # Show sync status
```

### Knowledge Capture
```bash
# Research
~/.gua/gua.sh research log "<topic>" "<finding>" [source] [confidence]

# Insights
~/.gua/gua.sh insight log "<content>" <type> [evidence] [pp_dimension] [scope]
# Types: observation, pattern, blindspot, hypothesis, anti-pattern, technique, principle, model

# Eurekas
~/.gua/gua.sh eureka log "<insight>" <type> "<catalyst>"
# Types: connection, resolution, pattern, constraint, reframe, simplify, counter_intuitive
```

### CPT (Code Progress Tracker)
```bash
# Areas
~/.gua/gua.sh area add <project> <path> [name] [granularity]
~/.gua/gua.sh area status [project]
~/.gua/gua.sh area update <id> [--impl <pct>] [--depth <L0-L4>]

# Challenges
~/.gua/gua.sh challenge log <area_id> "<description>" <pp_dimension> <category>
~/.gua/gua.sh challenge resolve <id> "<resolution>" [--learning "<insight>"]
~/.gua/gua.sh challenge list [--dimension <dim>] [--status <s>]
~/.gua/gua.sh challenge promote <id>

# Progress
~/.gua/gua.sh progress [project]
```

### Eureka Recorder
```bash
~/.gua/gua.sh eureka log "<insight>" <type> "<catalyst>"
~/.gua/gua.sh eureka list [--type T] [--limit N]
~/.gua/gua.sh eureka show <id>
~/.gua/gua.sh eureka promote <id>
```

### Dev Knowledge (Platform-Specific)
```bash
~/.gua/gua.sh dev add <platform> <domain> <type> "<title>" [--code "..." --tags "..."]
~/.gua/gua.sh dev list [platform] [domain]
~/.gua/gua.sh dev search "<query>" [--platform P] [--domain D]
~/.gua/gua.sh dev show <id>
~/.gua/gua.sh dev context <platform> [domain]
~/.gua/gua.sh dev promote <challenge_id> --platform P --domain D
# Platforms: shopify, sentry, prisma, aws, vercel, nextjs, react, typescript, general
# Domains: auth, data, api, ui, deployment, testing, performance, security
# Types: pattern, recipe, gotcha, error_fix, config, migration
```

### Knowledge Index (v2)
```bash
~/.gua/gua.sh index-stats           # Show statistics
~/.gua/gua.sh search "<query>"      # Search knowledge
~/.gua/gua.sh active-set            # Show top patterns
~/.gua/gua.sh generate-light        # Regenerate LIGHT.md
```

---

## Session Instructions for Other Claude Instances

### Quick Start
```
You have access to GUA (Global Understanding Archive) via bash commands.
The infrastructure is already set up in AWS (us-west-2).

Key commands:
- ~/.gua/gua.sh status              # Check connection
- ~/.gua/gua.sh eureka log "..." type "catalyst"  # Capture ahh hah moments
- ~/.gua/gua.sh research log "topic" "finding"    # Log research
- ~/.gua/gua.sh insight log "content" type        # Log insights
- ~/.gua/gua.sh save                # Sync to AWS

When you have realizations, capture them as eurekas.
When you discover facts, capture them as research.
When you see patterns, capture them as insights.
```

### Full Context (Copy to Other Sessions)
```
## GUA System Access

You have access to the Global Understanding Archive (GUA) - a knowledge persistence system that stores understanding across sessions in AWS.

### Infrastructure
- Region: us-west-2
- S3: gua-knowledge-store-yu
- DynamoDB: gua-research, gua-insights, gua-knowledge-index, gua-sessions, gua-feedback

### Capture Commands (via bash)

**Research** (factual findings):
~/.gua/gua.sh research log "<topic>" "<finding>"

**Insights** (patterns, observations):
~/.gua/gua.sh insight log "<content>" <type>
Types: observation, pattern, blindspot, hypothesis

**Eurekas** (ahh hah moments):
~/.gua/gua.sh eureka log "<realization>" <type> "<what triggered it>"
Types: connection, resolution, pattern, constraint, reframe, simplify, counter_intuitive

**Save to AWS**:
~/.gua/gua.sh save

### When to Capture

- **Research**: When you discover facts about APIs, libraries, codebases
- **Insight**: When you notice patterns, identify blindspots, form hypotheses
- **Eureka**: When you have "ahh hah" moments - sudden clarity, connections, realizations

### Eureka Recognition Markers
If you find yourself thinking:
- "Oh, I see..." / "Ah, so..."
- "Wait, that means..."
- "That's why!"
- "The key insight is..."

...capture it as a eureka before it fades.
```

---

## Setting Up New Devices

1. **Clone the repo**:
   ```bash
   git clone https://github.com/cambridgetcg/purpose-prompter.git ~/Desktop/purpose_prompter
   ```

2. **Copy GUA CLI**:
   ```bash
   mkdir -p ~/.gua
   cp ~/Desktop/purpose_prompter/gua/cli/*.sh ~/.gua/
   chmod +x ~/.gua/*.sh
   ```

3. **Create config** (update device_id):
   ```bash
   cat > ~/.gua/config.json << 'EOF'
   {
     "user_id": "yu",
     "region": "us-west-2",
     "s3_bucket": "gua-knowledge-store-yu",
     "device_id": "<your-device-id>",
     "tables": {
       "research": "gua-research",
       "feedback": "gua-feedback",
       "insights": "gua-insights",
       "sessions": "gua-sessions",
       "knowledge_index": "gua-knowledge-index"
     },
     "version": "2.0",
     "cpt": { "enabled": true }
   }
   EOF
   ```

4. **Configure AWS credentials** (must have access to the AWS account)

5. **Test connection**:
   ```bash
   ~/.gua/gua.sh status
   ```

6. **Load existing knowledge**:
   ```bash
   ~/.gua/gua.sh load
   ```

---

## Version History

- **2.1** (2026-01-28): Dev Knowledge Extension
  - Platform-specific development knowledge capture
  - 9 platforms: shopify, sentry, prisma, aws, vercel, nextjs, react, typescript, general
  - 8 domains: auth, data, api, ui, deployment, testing, performance, security
  - 6 types: pattern, recipe, gotcha, error_fix, config, migration
  - New GSI: platform-domain-index
  - Challenge to dev knowledge promotion

- **2.0** (2026-01-27): Full GUA v2 with CPT + Eureka Recorder
  - Knowledge index with GSIs
  - Code Progress Tracker
  - Eureka Recorder for ahh hah moments
  - Integrated with PP automation
