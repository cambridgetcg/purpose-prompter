---
description: "Capture research findings to the Global Understanding Archive"
argument-hint: "<topic> <finding> [source] [confidence]"
allowed-tools: [Bash, Read]
model: haiku
---

# GUA Research Command

Capture research findings to the Global Understanding Archive (AWS-backed).

## Arguments

```
$ARGUMENTS

Parse as:
- topic: The research topic/area (required)
- finding: The specific finding or discovery (required)
- source: Where this came from (default: "session")
- confidence: high | medium | low (default: "medium")
```

## Step 1: VALIDATE Arguments

Ensure both topic and finding are provided.

If missing, prompt:
```
Usage: /gua-research <topic> <finding> [source] [confidence]

Examples:
  /gua-research "vector databases" "ChromaDB free tier supports 10M vectors"
  /gua-research "React patterns" "useCallback prevents child re-renders" "docs" "high"
  /gua-research "AWS pricing" "DynamoDB on-demand ~$1.25 per million writes" "calculator" "high"
```

## Step 2: CHECK GUA Configuration

```bash
if [[ -f ~/.gua/config.json ]]; then
    echo "GUA configured"
else
    echo "ERROR: GUA not configured. Run: ~/.gua/setup.sh"
fi
```

If not configured, inform user to run setup.

## Step 3: LOG Research to AWS

Execute the gua CLI:

```bash
~/.gua/gua.sh research "{topic}" "{finding}" "{source}" "{confidence}"
```

## Step 4: CONFIRM and Suggest

After logging, output:

```
## Research Captured

**Topic**: {topic}
**Finding**: {finding}
**Source**: {source}
**Confidence**: {confidence}

Logged to AWS DynamoDB (gua-research table).

---

**Tip**: Run `/integrate` periodically to synthesize research into LIGHT.md
**View**: `gua query research 10` to see recent entries
```

## Error Handling

If AWS call fails:
1. Check if ~/.gua/config.json exists
2. Check AWS credentials: `aws sts get-caller-identity`
3. Suggest running setup: `~/.gua/setup.sh`

## Examples

```
/gua-research "caching strategies" "Redis pub/sub good for invalidation"
/gua-research "TypeScript" "satisfies operator better than as for type narrowing" "handbook" "high"
/gua-research "PP methodology" "Longing as motor force improves engagement" "testing" "medium"
```
