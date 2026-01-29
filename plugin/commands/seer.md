---
description: Fetch blocked web content via Bright Data proxy for building understanding
argument-hint: /seer <url> [--refresh] [--list-cache]
allowed-tools: [Bash]
model: haiku
---

# Seer - See External Resources

**SEER** enables the UNDERSTANDING dimension by bypassing anti-bot protections (Cloudflare, etc.) to access authoritative documentation.

## Arguments

$ARGUMENTS

## Protocol

### 1. Parse Request

Determine the action:
- **URL provided**: Fetch or retrieve from cache
- **--list-cache**: Show all cached URLs
- **--refresh**: Force re-fetch ignoring cache
- **--cache-status <url>**: Check if URL is cached

### 2. Execute via GUA

```bash
# Fetch blocked documentation
gua seer "<url>"

# Force refresh (ignore cache)
gua seer "<url>" --refresh

# List all cached URLs
gua seer --list-cache

# Check cache status for specific URL
gua seer --cache-status "<url>"
```

### 3. Interpret Results

**Success indicators**:
- `[SEER] From cache` - Content retrieved from DynamoDB cache
- `[SEER] Cached successfully` - Fresh content fetched and stored
- Content starts with `# Seer: <title>`

**Failure indicators**:
- `[SEER] HTTP 4xx/5xx` - Fetch failed
- `[SEER] Failed to fetch URL` - Connection or proxy issue
- `[SEER] BRIGHT_DATA_* not set` - Credentials missing

### 4. Integration with Current Task

After fetching, relate content to the current task:
- Identify relevant sections for the task at hand
- Note API endpoints, parameters, or patterns needed
- Flag any discrepancies with assumed knowledge

## Output Format

```markdown
## Seer Result

**URL**: <url>
**Status**: [cached | fresh | failed]
**Type**: [docs | github | npm | generic]

### Relevant Content

[Summary of content relevant to current task]

### Key Information

- [Specific details extracted for task]
- [API endpoints, parameters, etc.]

### Cache Info

- Cached: [yes/no]
- Expires: [timestamp or N/A]
- Refresh: `gua seer "<url>" --refresh`
```

## When to Use Seer

### Use Seer When:
- WebFetch returns 403, 503, or Cloudflare challenge
- Documentation site is known to block bots (Cloudflare, Vercel, etc.)
- Need authoritative source for API details instead of guessing
- `/territory` or `/deep-understand` reveals blocked resources

### Don't Use Seer When:
- WebFetch works normally
- Content is available in training data and current
- URL is not documentation (e.g., dynamic web apps)

## PP Alignment

Seer serves **UNDERSTANDING** by:
- Removing access barriers to authoritative sources
- Grounding work in truth (actual docs, not hallucination)
- Enabling the Light-Ahead Loop RESEARCH phase

### Signal Resolution

| Signal | How Seer Helps |
|--------|----------------|
| **Confusion** | Provides missing documentation |
| **Incomplete Context** | Fills gaps with authoritative source |
| **Stagnation** | Unblocks progress when docs are needed |

## Cost Awareness

- ~$0.003 per Bright Data request
- Cached content is FREE (24h docs, 1h GitHub, 6h npm)
- Prefer cache over refresh unless docs are stale

## Examples

### Fetch Cloudflare Documentation
```
/seer https://developers.cloudflare.com/workers/runtime-apis/kv/
```

### Check What's Cached
```
/seer --list-cache
```

### Force Refresh Stale Docs
```
/seer https://docs.example.com/api --refresh
```
