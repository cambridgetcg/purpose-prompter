# Seer Skill - Blocked Documentation Access

## Purpose

Automatically detect when documentation is blocked and suggest or invoke Seer to fetch content via Bright Data proxy.

## Trigger Conditions

Activate this skill when ANY of these conditions are met:

### 1. WebFetch Failure
- WebFetch returns HTTP 403, 503, or similar
- Response contains "Cloudflare", "challenge", "blocked", "access denied"
- Response is empty or truncated unexpectedly

### 2. User Signals
- User says "can't access docs", "site is blocked", "Cloudflare blocking"
- User provides URL to known-blocked documentation site
- User mentions needing API details from protected docs

### 3. Task Context
- `/territory` reveals external documentation is needed
- `/deep-understand` requires authoritative source
- Implementation requires API details not in training data

### 4. Known Blocked Domains
- `developers.cloudflare.com`
- `docs.github.com` (rate-limited)
- `vercel.com/docs`
- `docs.aws.amazon.com` (some sections)
- Any domain with Cloudflare protection

## Skill Protocol

### Step 1: Detect Need

When encountering blocked content or documentation need:

```
SEER SKILL ACTIVATED

Detected: [WebFetch blocked | Documentation needed | Known blocked domain]
URL: <url>
Reason: [HTTP 403 | Cloudflare challenge | User request | Task requires docs]
```

### Step 2: Check Cache First

```bash
gua seer --cache-status "<url>"
```

If cached and not stale:
```
Content available from cache (fetched: <timestamp>)
Using cached version. Use --refresh if docs may have changed.
```

### Step 3: Fetch if Needed

```bash
gua seer "<url>"
```

### Step 4: Integrate with Task

After fetching:
1. Summarize relevant content for current task
2. Extract specific API details, parameters, or patterns
3. Note any differences from assumed knowledge
4. Cache reference for continued use in session

## Output Format

```markdown
## Seer: Documentation Retrieved

**Source**: <url>
**Status**: [from cache | freshly fetched]
**Relevance**: [high | medium | low] for current task

### Key Information for Task

[Extracted relevant details]

### API Reference

[Specific endpoints, parameters, types if applicable]

### Notes

- [Any caveats or version-specific info]
- [Differences from training data if noticed]
```

## Auto-Suggestion Mode

When WebFetch fails, output:

```
WebFetch blocked by anti-bot protection.

Suggestion: Use Seer to fetch this content
  gua seer "<url>"

Or invoke directly: /seer <url>
```

## Integration Points

### With /territory
When territory assessment identifies external docs needed:
- Auto-list relevant URLs
- Check cache status
- Suggest fetching blocked resources before implementation

### With /deep-understand
When building deep understanding requires external sources:
- Identify authoritative documentation URLs
- Fetch via Seer if blocked
- Integrate content into understanding model

### With Light-Ahead Loop
**RESEARCH phase**: Seer is the primary tool for fetching blocked documentation
- ASSESS: `gua seer --list-cache`
- RESEARCH: `gua seer <url>`
- VALIDATE: `gua seer <url> --refresh` if docs may have changed

## Cost Awareness

Display when fetching:
```
Seer fetch cost: ~$0.003 (Bright Data)
Cache expires: [24h docs | 1h GitHub | 6h npm]
Cached content is free for subsequent requests.
```

## Virtue Alignment

Seer embodies PP virtues:

| Virtue | Expression |
|--------|------------|
| **HUMILITY** | Acknowledges training data may be outdated |
| **HONESTY** | Fetches authoritative source instead of guessing |
| **DISCIPLINE** | Caches to respect costs and rate limits |
| **PATIENCE** | Accepts time needed to fetch content |

## Example Interactions

### WebFetch Blocked
```
User: Fetch the Cloudflare Workers KV documentation
Assistant: [Attempts WebFetch, gets 403]

SEER SKILL ACTIVATED
Detected: WebFetch blocked (HTTP 403)
URL: https://developers.cloudflare.com/workers/runtime-apis/kv/

Fetching via Seer...
[executes: gua seer "https://developers.cloudflare.com/workers/runtime-apis/kv/"]

Documentation retrieved and cached for 24 hours.
[Summarizes relevant content]
```

### Cache Available
```
User: I need the Stripe API docs for charges
Assistant: Checking Seer cache...

Content available from cache (fetched: 2h ago)
Using cached version for: https://docs.stripe.com/api/charges

[Provides relevant content from cache]
```
