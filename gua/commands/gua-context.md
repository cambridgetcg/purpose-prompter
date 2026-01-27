---
description: "Inject accumulated GUA + CPT context into current session"
argument-hint: "[mode] or dimension:<dim> or domain:<dom> or search:<query> or fetch:<id> or progress"
allowed-tools: [Bash, Read]
model: haiku
---

# GUA Context Command

Inject accumulated knowledge from GUA (patterns, blindspots) and CPT (code progress, challenges) into the current session.

## Arguments

```
$ARGUMENTS

Parse as one of:
- mode: quick | patterns | blindspots | full | taxonomy | stats | progress (default: "quick")
- dimension:<dim> where dim = truth | understanding | beauty | justice | creativity
- domain:<dom> where dom = aws | claude-code | typescript | general | etc.
- search:<query> for searching knowledge index (v2)
- fetch:<id> for fetching specific pattern by ID (v2)
- deep:<pattern-name> for L3-L4 nuance files

Examples:
  /gua-context                   # Quick context (GUA + CPT)
  /gua-context full              # Complete LIGHT.md + CPT progress
  /gua-context progress          # CPT progress dashboard
  /gua-context dimension:beauty  # Beauty dimension patterns
  /gua-context domain:aws        # AWS-specific patterns
  /gua-context search:bridge     # Search for 'bridge' patterns (v2)
  /gua-context fetch:pattern-bridge-over-replace  # Fetch specific pattern (v2)
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
# Check if v2 is configured
VERSION=$(jq -r '.version // "1.0"' ~/.gua/config.json 2>/dev/null || echo "1.0")
echo "GUA Version: $VERSION"

# Check last load time
LAST_LOAD=$(jq -r '.last_load // "never"' ~/.gua/state.json 2>/dev/null || echo "never")
echo "Last GUA load: $LAST_LOAD"

# If stale (> 1 hour), suggest reload
if [[ "$LAST_LOAD" == "never" ]]; then
    echo "Consider running: ~/.gua/gua.sh load"
fi
```

## Step 3: EXECUTE Based on Query Type

### v2 Scalable Queries

#### If mode == "stats"

Show knowledge index statistics (v2 only):

```bash
~/.gua/gua.sh index-stats
```

#### If query starts with "search:"

Search the knowledge index for matching patterns:

```bash
# Extract query term after "search:"
QUERY="${ARGUMENTS#search:}"
~/.gua/gua.sh search "$QUERY"
```

Present results as:

```markdown
## GUA Search Results: {query}

{Output from gua search}

---
To fetch full details: `/gua-context fetch:<knowledge_id>`
```

#### If query starts with "fetch:"

Fetch a specific pattern by ID (automatically tracks access):

```bash
# Extract ID after "fetch:"
ID="${ARGUMENTS#fetch:}"
~/.gua/gua.sh fetch "$ID"
```

Present full pattern content with:

```markdown
## GUA Pattern Details

{Output from gua fetch}

---
This access has been tracked. Pattern will rank higher in future active sets.
```

### Standard Modes

#### If mode == "quick" (default)

Read LIGHT.md and get CPT progress:

```bash
cat ~/.claude/purpose_prompter/integration/LIGHT.md
~/.gua/gua.sh progress 2>/dev/null | head -20
```

Present:

```markdown
## GUA + CPT Quick Context

### Active Blindspots (CHECK THESE)
{Extract blindspots section}

### Top Patterns to Apply
{Extract first 3 confirmed patterns, just name + implication}

### Code Progress (CPT)
{Show area count, avg completion, active challenges}

---
For full context: `/gua-context full`
For progress details: `/gua-context progress` or `/cpt-context`
```

#### If mode == "progress"

Show CPT progress dashboard:

```bash
~/.gua/gua.sh progress
```

Present:

```markdown
## CPT Progress Dashboard

{Output from gua progress}

---
### Quick Actions
- Update area: `gua area update <id> --impl X --depth LY`
- Log challenge: `/cpt-challenge <description>`
- View challenges: `/gua-context` then look at challenges section

### Understanding Depth Levels
- **L0** Unread: Never looked at this code
- **L1** Surveyed: Know it exists, rough purpose
- **L2** Understood: Know structure and flow
- **L3** Deep: Know edge cases and why
- **L4** Expert: Could refactor confidently
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

Present complete LIGHT.md + CPT progress:

```bash
cat ~/.claude/purpose_prompter/integration/LIGHT.md
~/.gua/gua.sh progress 2>/dev/null
~/.gua/gua.sh challenge list 2>/dev/null | head -20
```

```markdown
## GUA + CPT Full Context

### Accumulated Knowledge
{Complete LIGHT.md content}

### Code Progress
{Output from gua progress}

### Active Challenges
{Output from gua challenge list}

---
This is your complete context: accumulated understanding + code progress.
Reference it throughout the session.
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
3. **Check progress** - Where did I leave off in this code?
4. **Review challenges** - Are there unresolved blockers?
5. **Trust signals** - If something feels wrong, investigate

### Integrated Session Workflow

**START**:
- `gua load` - Load patterns + CPT progress
- `/gua-context` - Inject full context

**DURING WORK**:
- `/cpt-challenge <description>` - When stuck (maps to PP dimension)
- `/gua-insight <observation>` - When learning
- `gua area update <id> --impl X` - Track progress

**SIGNALS** (PP detects, CPT tracks):
- Ugliness → confusion challenge (UNDERSTANDING)
- Injustice → wrong_place challenge (JUSTICE)
- Stagnation → dead_end challenge (CREATIVITY)

**END**:
- `gua challenge resolve <id> <resolution>` - Resolve blockers
- `gua challenge promote <id>` - Promote learnings to insights
- `gua save` - Persist to AWS

### Quick Reference
- **Dimensions**: truth, understanding, beauty, justice, creativity
- **Depth Levels**: L0 (unread) → L1 (surveyed) → L2 (understood) → L3 (deep) → L4 (expert)
- **Challenge Types**: bug, confusion, ugly_hack, wrong_place, dead_end
```

## Examples

```
# Unified Context (GUA + CPT)
/gua-context                        # Quick context - patterns + blindspots + progress
/gua-context quick                  # Same as above
/gua-context full                   # Everything - LIGHT.md + CPT dashboard + challenges
/gua-context progress               # CPT progress dashboard only

# GUA Knowledge
/gua-context patterns               # All patterns for reference
/gua-context blindspots             # Detailed blindspot review
/gua-context taxonomy               # Knowledge taxonomy reference

# PP Dimension Queries
/gua-context dimension:truth        # Truth dimension patterns
/gua-context dimension:beauty       # Beauty dimension patterns
/gua-context dimension:creativity   # Creativity dimension patterns

# Domain Queries
/gua-context domain:aws             # AWS-specific patterns
/gua-context domain:claude-code     # Claude Code patterns
/gua-context domain:typescript      # TypeScript patterns

# Deep Knowledge
/gua-context deep:bridge-over-replace       # Deep nuances for specific pattern
/gua-context deep:tiered-implementation     # Deep nuances for tiered pattern

# v2 Search
/gua-context search:bridge          # Search all knowledge
/gua-context fetch:<id>             # Fetch specific pattern
```

## Integration Note

This command reads from local files that are synced from AWS. To ensure freshness:
1. Run `gua load` at session start
2. Run `gua save` at session end
3. Use `/gua-context` whenever you need to reference accumulated knowledge
4. Use `/gua-context taxonomy` to review the knowledge structure

### v2 Scalable Architecture (Recommended)

If v2 is configured (run `~/.gua/upgrade-v2.sh` to upgrade), additional features are available:

1. **Smart Loading**: `gua load` loads only the active set (top patterns + active blindspots)
2. **Search**: `/gua-context search:<query>` searches the knowledge index
3. **On-Demand Fetch**: `/gua-context fetch:<id>` fetches specific patterns
4. **Access Tracking**: Every fetch automatically tracks access, improving future recommendations
5. **Index Stats**: `/gua-context stats` shows knowledge distribution

v2 scales to thousands of patterns while keeping session startup fast.
