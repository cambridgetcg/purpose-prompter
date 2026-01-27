---
description: "Sync understanding between local and AWS (load/save)"
argument-hint: "[load|save|status|knowledge] - Default: status"
allowed-tools: [Bash, Read]
model: haiku
---

# GUA Sync Command

Synchronize understanding between local storage and AWS.

## Arguments

```
$ARGUMENTS

Parse as:
- action: load | save | status | knowledge (default: "status")

load      - Download LIGHT.md, PATH.md, blindspots.md, and knowledge taxonomy from AWS
save      - Upload local changes to AWS (including knowledge taxonomy)
status    - Show sync status and pending items
knowledge - Sync only knowledge taxonomy (by-dimension, by-domain, deep)
```

## Step 1: VALIDATE GUA Configuration

```bash
if [[ ! -f ~/.gua/config.json ]]; then
    echo "ERROR: GUA not configured"
    echo "Run: ~/.gua/setup.sh"
    exit 1
fi
```

## Step 2: EXECUTE Action

### If action == "load"

```bash
~/.gua/gua.sh load
```

After load, output:
```
## GUA Load Complete

Downloaded from AWS:
- LIGHT.md → ~/.claude/purpose_prompter/integration/LIGHT.md
- PATH.md → ~/.claude/purpose_prompter/integration/PATH.md
- KNOWLEDGE_TAXONOMY.md → ~/.claude/purpose_prompter/integration/KNOWLEDGE_TAXONOMY.md
- blindspots.md → ~/.claude/purpose_prompter/insights/blindspots.md
- knowledge/by-dimension/ → All PP dimension knowledge
- knowledge/by-domain/ → All domain-specific knowledge
- knowledge/deep/ → All L3-L4 nuance files

Your session now has access to accumulated understanding and knowledge taxonomy.

### Quick Access
- Quick context: `/gua-context`
- Full context: `/gua-context full`
- By dimension: `/gua-context dimension:creativity`
- By domain: `/gua-context domain:aws`
```

### If action == "save"

```bash
~/.gua/gua.sh save
```

After save, output:
```
## GUA Save Complete

Uploaded to AWS:
- LIGHT.md
- PATH.md
- KNOWLEDGE_TAXONOMY.md
- blindspots.md
- knowledge/by-dimension/* (all dimension files)
- knowledge/by-domain/* (all domain files)
- knowledge/deep/* (all deep nuance files)
- Feedback entries (synced to DynamoDB)

Changes are now available on other devices.
```

### If action == "status" (default)

```bash
~/.gua/gua.sh status
```

Format the output nicely and add recommendations:
```
## GUA Status

### AWS Connection
- User: {user_id}
- Region: {region}
- Bucket: {bucket}

### Sync State
- Last load: {timestamp or "never"}
- Last save: {timestamp or "never"}
- Pending research: {N}
- Pending insights: {M}

### Knowledge Files
{Run: gua list-knowledge}

### Recommendations
{Based on state, suggest next action}
```

### If action == "knowledge"

Sync only the knowledge taxonomy:

```bash
# For load
~/.gua/gua.sh load-knowledge

# For save
~/.gua/gua.sh save-knowledge
```

Output:
```
## GUA Knowledge Sync Complete

Synced:
- knowledge/by-dimension/ (truth, understanding, beauty, justice, creativity)
- knowledge/by-domain/ (aws, claude-code, typescript, general)
- knowledge/deep/ (L3-L4 nuance files)

Use `/gua-context dimension:<dim>` or `/gua-context domain:<dom>` to access.
```

## Recommendations Logic

**If never loaded**:
```
Recommendation: Run `/gua-sync load` to download existing understanding
```

**If pending > 5**:
```
Recommendation: Run `/integrate` to synthesize pending items into LIGHT.md
```

**If last_save > 1 hour ago and changes exist**:
```
Recommendation: Run `/gua-sync save` to backup changes to AWS
```

**If knowledge files empty**:
```
Recommendation: Insights captured but not promoted. Run `gua query insights` then `gua promote <id>` to build knowledge.
```

## Quick Reference

```
/gua-sync load       # Start of session - get latest understanding + knowledge
/gua-sync save       # End of session - persist all changes
/gua-sync status     # Check current state
/gua-sync knowledge  # Sync only knowledge taxonomy
/gua-sync            # Same as status
```

## Session Workflow

Recommended workflow for each Claude Code session:

```
1. Session Start:
   /gua-sync load

2. During Session:
   /gua-research <topic> <finding>
   /gua-insight <observation> [type] [evidence] [dimension] [scope]
   (work normally)

3. Promote insights to knowledge:
   gua query insights
   gua promote <id> [dimension]

4. Periodically:
   /integrate incremental

5. Session End:
   /gua-sync save
```

## Knowledge Taxonomy Integration

The sync now includes the full knowledge taxonomy:

| Local Path | AWS Path |
|------------|----------|
| `~/.claude/purpose_prompter/knowledge/by-dimension/` | `s3://bucket/knowledge/by-dimension/` |
| `~/.claude/purpose_prompter/knowledge/by-domain/` | `s3://bucket/knowledge/by-domain/` |
| `~/.claude/purpose_prompter/knowledge/deep/` | `s3://bucket/knowledge/deep/` |

This ensures all accumulated knowledge is available across devices.
