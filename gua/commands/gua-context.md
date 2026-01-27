---
description: "Inject accumulated GUA knowledge into current session context"
argument-hint: "[mode] or dimension:<dim> or domain:<dom> or deep:<pattern>"
allowed-tools: [Bash, Read]
model: haiku
---

# GUA Context Command

Inject accumulated knowledge from the Global Understanding Archive into the current session.

## Arguments

```
$ARGUMENTS

Parse as one of:
- mode: quick | patterns | blindspots | full | taxonomy (default: "quick")
- dimension:<dim> where dim = truth | understanding | beauty | justice | creativity
- domain:<dom> where dom = aws | claude-code | typescript | general | etc.
- deep:<pattern-name> for L3-L4 nuance files

Examples:
  /gua-context                   # Quick context
  /gua-context full              # Complete LIGHT.md
  /gua-context dimension:beauty  # Beauty dimension patterns
  /gua-context domain:aws        # AWS-specific patterns
  /gua-context deep:bridge-over-replace  # Deep nuances
```

## Purpose

This command bridges AWS-stored knowledge into the current session context. Use it:
- At the start of significant work
- When you need to apply accumulated learnings
- When you want to check for relevant patterns
- When working in a specific domain or PP dimension

## Step 1: PARSE Arguments

Determine the query type:

```
If starts with "dimension:" → Dimensional query
If starts with "domain:" → Domain query
If starts with "deep:" → Deep file query
Otherwise → Standard mode (quick/patterns/blindspots/full/taxonomy)
```

## Step 2: ENSURE GUA Data is Fresh

```bash
# Check last load time
LAST_LOAD=$(jq -r '.last_load // "never"' ~/.gua/state.json 2>/dev/null || echo "never")
echo "Last GUA load: $LAST_LOAD"

# If stale (> 1 hour), suggest reload
if [[ "$LAST_LOAD" == "never" ]]; then
    echo "Consider running: ~/.gua/gua.sh load"
fi
```

## Step 3: EXECUTE Based on Query Type

### Standard Modes

#### If mode == "quick" (default)

Read LIGHT.md and extract:

```bash
cat ~/.claude/purpose_prompter/integration/LIGHT.md
```

Present:

```markdown
## GUA Quick Context

### Active Blindspots (CHECK THESE)
{Extract blindspots section}

### Top Patterns to Apply
{Extract first 3 confirmed patterns, just name + implication}

---
For full context: `/gua-context full`
```

#### If mode == "patterns"

Extract and present:

```markdown
## GUA Patterns

### Confirmed Patterns (HIGH confidence)
{Full patterns section}

### Emerging Patterns (MEDIUM confidence)
{Full emerging section}

---
Apply these patterns to current work. Log new patterns with `/gua-insight`.
```

#### If mode == "blindspots"

Extract and present:

```markdown
## GUA Active Blindspots

{Full blindspots section with all details}

---
Before proceeding, check: Am I about to trigger one of these blindspots?
```

#### If mode == "full"

Present complete LIGHT.md with header:

```markdown
## GUA Full Context

{Complete LIGHT.md content}

---
This is your accumulated understanding. Reference it throughout the session.
```

#### If mode == "taxonomy"

Read and present:

```bash
cat ~/.claude/purpose_prompter/integration/KNOWLEDGE_TAXONOMY.md
```

### Dimensional Query: dimension:<dim>

Read knowledge files for the specified PP dimension:

```bash
# Read all files in the dimension
ls ~/.claude/purpose_prompter/knowledge/by-dimension/{dim}/
cat ~/.claude/purpose_prompter/knowledge/by-dimension/{dim}/*.md 2>/dev/null
```

Present:

```markdown
## GUA Knowledge: {Dimension} Dimension

{Content from all files in by-dimension/{dim}/}

---
PP Dimension: {dim}
Related dimensions: {list adjacent in hierarchy}
```

### Domain Query: domain:<dom>

Read knowledge files for the specified domain:

```bash
# Read all files in the domain
ls ~/.claude/purpose_prompter/knowledge/by-domain/{dom}/
cat ~/.claude/purpose_prompter/knowledge/by-domain/{dom}/*.md 2>/dev/null
```

Present:

```markdown
## GUA Knowledge: {Domain} Domain

{Content from all files in by-domain/{dom}/}

---
Domain: {dom}
Apply these patterns when working with {dom} code.
```

### Deep Query: deep:<pattern-name>

Read the specific deep file:

```bash
cat ~/.claude/purpose_prompter/knowledge/deep/{pattern-name}.md 2>/dev/null
```

Present:

```markdown
## GUA Deep Knowledge: {Pattern Name}

{Full content of deep file}

---
This is L3-L4 nuanced knowledge. Apply with care to specific contexts.
```

If file not found:

```markdown
## Deep File Not Found

No deep knowledge file exists for: {pattern-name}

Available deep files:
{List files in knowledge/deep/}

---
Deep files are created when patterns reach L3+ depth through repeated validation.
```

## Step 4: PROMPT for Application

After presenting context, add:

```markdown
### How to Use This Context

1. **Check blindspots** - Am I about to trigger one?
2. **Apply patterns** - Does a confirmed pattern fit this task?
3. **Trust signals** - If something feels wrong, investigate

### Session Workflow
- Capture insights: `/gua-insight <observation>`
- Log research: `/gua-research <topic> <finding>`
- Promote to knowledge: `gua promote <insight_id>`
- Save to AWS: `gua save`

### Knowledge Taxonomy
- Dimensions: truth, understanding, beauty, justice, creativity
- Domains: aws, claude-code, typescript, general
- Depth: L1 (summary) → L2 (description) → L3 (nuances) → L4 (examples)
```

## Examples

```
/gua-context                        # Quick context - blindspots + top patterns
/gua-context quick                  # Same as above
/gua-context patterns               # All patterns for reference
/gua-context blindspots             # Detailed blindspot review
/gua-context full                   # Everything - complete LIGHT.md
/gua-context taxonomy               # Knowledge taxonomy reference

/gua-context dimension:truth        # Truth dimension patterns
/gua-context dimension:beauty       # Beauty dimension patterns
/gua-context dimension:creativity   # Creativity dimension patterns

/gua-context domain:aws             # AWS-specific patterns
/gua-context domain:claude-code     # Claude Code patterns
/gua-context domain:typescript      # TypeScript patterns

/gua-context deep:bridge-over-replace       # Deep nuances for specific pattern
/gua-context deep:tiered-implementation     # Deep nuances for tiered pattern
```

## Integration Note

This command reads from local files that are synced from AWS. To ensure freshness:
1. Run `gua load` at session start
2. Run `gua save` at session end
3. Use `/gua-context` whenever you need to reference accumulated knowledge
4. Use `/gua-context taxonomy` to review the knowledge structure
