# GUA - Global Understanding Archive

> Persistent knowledge accumulation across Claude Code sessions via AWS

## Overview

GUA is the persistence layer for Purpose Prompter. It enables:
- **Cross-session memory**: Insights, patterns, and blindspots persist between sessions
- **Cross-device sync**: Knowledge available on any device via AWS
- **Structured taxonomy**: Knowledge organized by PP dimension and domain
- **Depth scaling**: Knowledge grows from L1 summaries to L4 detailed examples

## Architecture

```
GUA System
├── CLI (gua.sh)              # Command-line interface
├── Plugin Commands           # Claude Code /gua-* commands
├── Knowledge Taxonomy        # Structured knowledge organization
└── AWS Backend              # S3 + DynamoDB for persistence

AWS Resources
├── S3 Bucket                # Document storage (LIGHT.md, knowledge files)
└── DynamoDB Tables          # Structured data (insights, research, sessions)
    ├── gua-insights
    ├── gua-research
    ├── gua-feedback
    └── gua-sessions
```

## Installation

### Prerequisites
- AWS CLI configured with credentials
- `jq` for JSON processing

### Setup

```bash
# Run setup (creates AWS resources)
~/.gua/setup.sh [user_id] [region]

# Example
~/.gua/setup.sh yu us-west-2
```

This creates:
- S3 bucket: `gua-knowledge-store-{user_id}`
- DynamoDB tables with PAY_PER_REQUEST billing
- Local config at `~/.gua/config.json`

## Usage

### CLI Commands

```bash
# Core sync
gua load                    # Download all from AWS
gua save                    # Upload all to AWS
gua status                  # Show sync status

# Knowledge capture
gua insight "content" [type] [evidence] [pp_dimension] [scope]
gua research "topic" "finding" [source] [confidence]

# Knowledge management
gua promote <insight_id> [dimension]   # Promote insight to knowledge file
gua list-knowledge [filter]            # List knowledge files
gua query [table] [limit]              # Query recent entries

# Session tracking
gua session start [project]
gua session end
```

### Plugin Commands (in Claude Code)

```
/gua-context [mode]              # Inject knowledge context
/gua-context dimension:beauty    # Load PP dimension knowledge
/gua-context domain:aws          # Load domain knowledge
/gua-context deep:pattern-name   # Load L3-L4 nuances

/gua-insight "content" [type] [evidence] [dimension] [scope]
/gua-research "topic" "finding" [source] [confidence]
/gua-sync [load|save|status]
```

## Knowledge Taxonomy

### Five Dimensions
1. **PP Hierarchy**: truth, understanding, beauty, justice, creativity
2. **Confidence**: hypothesis → emerging → confirmed → deprecated
3. **Scope**: global, domain, project, personal
4. **Type**: pattern, anti-pattern, blindspot, technique, principle, model
5. **Temporal**: timeless, current, evolving, historical

### Four Depth Levels
- **L1**: Name + one-liner (LIGHT.md)
- **L2**: Description + evidence + implication (LIGHT.md expanded)
- **L3**: Nuances + edge cases + relations (deep/*.md)
- **L4**: Full examples + case studies (deep/*.md expanded)

### File Organization
```
~/.claude/purpose_prompter/
├── integration/
│   └── LIGHT.md              # Always-loaded summary
├── knowledge/
│   ├── by-dimension/         # PP hierarchy organization
│   │   ├── truth/
│   │   ├── understanding/
│   │   ├── beauty/
│   │   ├── justice/
│   │   └── creativity/
│   ├── by-domain/            # Technology organization
│   │   ├── aws/
│   │   ├── claude-code/
│   │   └── ...
│   └── deep/                 # L3-L4 nuance files
```

## Session Workflow

```
1. Session Start
   gua load
   /gua-context quick

2. During Work
   /gua-insight "observation" pattern "evidence" creativity global
   /gua-research "topic" "finding"

3. Promote Insights
   gua query insights
   gua promote <id> [dimension]

4. Session End
   gua save
```

## Integration with PP

GUA is tightly integrated with Purpose Prompter:
- Knowledge taxonomy uses PP dimensions (truth → understanding → beauty → justice → creativity)
- Blindspots inform PP signal detection
- Patterns guide PP verification gates
- CLAUDE.md loads active blindspots every session

## File Locations

| Component | Repo Location | Runtime Location |
|-----------|---------------|------------------|
| CLI | `gua/cli/` | `~/.gua/` (symlinked) |
| Commands | `gua/commands/` | `~/.claude/plugins/purpose-prompter/commands/` (symlinked) |
| Docs | `gua/docs/` | `~/.claude/purpose_prompter/integration/` (symlinked) |
| Config | N/A (user-specific) | `~/.gua/config.json` |
| Knowledge | N/A (synced via AWS) | `~/.claude/purpose_prompter/knowledge/` |

## AWS Costs

With PAY_PER_REQUEST billing, costs are minimal for personal use:
- S3: ~$0.023/GB/month storage, $0.0004/1000 requests
- DynamoDB: $1.25 per million write units, $0.25 per million read units

Estimated monthly cost for typical usage: < $1
