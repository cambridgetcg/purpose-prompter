# SEER: Philosophy Integration

## The Name

**SEER** = See External Resources

A seer is one who sees what others cannot. In the context of Purpose Prompter, Seer provides vision into web content that would otherwise be invisible to Claude Code due to anti-bot protections.

## PP Dimension Alignment

Seer primarily serves the **UNDERSTANDING** dimension:

```
TRUTH (foundation)
  ↓
UNDERSTANDING ← SEER enables this
  ↓
BEAUTY
  ↓
JUSTICE
  ↓
CREATIVITY
```

### Why Understanding?

Understanding requires access to authoritative sources. When Claude Code cannot access documentation due to Cloudflare or other protections, understanding is blocked. Seer removes this barrier.

```
Without Seer:
  Task: "Implement Cloudflare Workers KV storage"
  WebFetch: BLOCKED by Cloudflare
  Result: Work from memory (potentially outdated/incomplete)
  Understanding: PARTIAL

With Seer:
  Task: "Implement Cloudflare Workers KV storage"
  gua seer "https://developers.cloudflare.com/workers/runtime-apis/kv/"
  Result: Current documentation available
  Understanding: COMPLETE
```

## Signal Resolution

Seer helps resolve these PP signals:

### Confusion Signal

When you encounter:
> "I need to check the API documentation but the site is blocked"

Resolution:
```bash
gua seer "https://blocked-api-docs.com/endpoint"
```

### Incomplete Context Signal

When you encounter:
> "I'm not sure about the exact parameter format without seeing the docs"

Resolution:
```bash
gua seer "https://framework-docs.com/api-reference"
```

### Stagnation Signal (Indirect)

When blocked docs prevent forward progress:
```
Stagnation → Need docs → Seer fetches → Understanding enabled → Progress resumes
```

## The Virtue Alignment

Seer embodies several virtues from the PP virtue loop:

### HUMILITY
Seer acknowledges that Claude's training data may be outdated. Instead of guessing, it fetches current information.

### HONESTY
Rather than hallucinating API details, Seer retrieves the authoritative source.

### DISCIPLINE
Seer caches content to avoid unnecessary requests, respecting both cost and rate limits.

### PATIENCE
Seer accepts that some content takes time to fetch and process.

## Integration with Light-Ahead Loop

```
┌─────────────────────────────────────────────────────────────┐
│                 Light-Ahead Loop with Seer                   │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  1. ASSESS                                                   │
│     ┌──────────────────────────────────────┐                │
│     │ What resources do I need?            │                │
│     │ Are any blocked?                     │                │
│     │ → gua seer --list-cache              │                │
│     └──────────────────────────────────────┘                │
│                       ↓                                      │
│  2. RESEARCH                                                 │
│     ┌──────────────────────────────────────┐                │
│     │ Fetch blocked resources              │                │
│     │ → gua seer <url>                     │                │
│     │ Content indexed in GUA               │                │
│     └──────────────────────────────────────┘                │
│                       ↓                                      │
│  3. BUILD                                                    │
│     ┌──────────────────────────────────────┐                │
│     │ Reference cached docs                │                │
│     │ Seer content in context              │                │
│     │ Accurate implementation              │                │
│     └──────────────────────────────────────┘                │
│                       ↓                                      │
│  4. VALIDATE                                                 │
│     ┌──────────────────────────────────────┐                │
│     │ Check if docs have changed           │                │
│     │ → gua seer <url> --refresh           │                │
│     │ Verify implementation matches        │                │
│     └──────────────────────────────────────┘                │
│                       ↓                                      │
│  5. CAPTURE                                                  │
│     ┌──────────────────────────────────────┐                │
│     │ Seer auto-caches for future          │                │
│     │ Popular URLs rank higher             │                │
│     │ Knowledge persists across sessions   │                │
│     └──────────────────────────────────────┘                │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## The Truth Foundation

Seer supports TRUTH by:

1. **Accessing authoritative sources** - Real documentation, not remembered approximations
2. **Timestamping content** - Know when information was fetched
3. **Indicating cache status** - Clear about whether content is fresh or cached
4. **Truncating transparently** - Explicit when content is cut off

## The Understanding Purpose

Seer enables UNDERSTANDING by:

1. **Removing barriers** - Cloudflare, anti-bot, rate limits
2. **Preserving context** - Markdown conversion maintains structure
3. **Caching for sessions** - Content available throughout work
4. **Indexing in GUA** - Knowledge persists across sessions

## Anti-Patterns to Avoid

### Over-Fetching
Don't fetch the entire internet. Be selective about what you need.

```
❌ gua seer "https://entire-framework-docs.com"  # Too broad
✓ gua seer "https://docs.com/api/specific-endpoint"  # Targeted
```

### Ignoring Cache
Don't repeatedly fetch the same content. Trust the cache.

```
❌ Always using --refresh "just to be sure"
✓ Trust cache, refresh only when needed
```

### Hallucinating Instead
Don't guess when Seer could provide certainty.

```
❌ "I think the API uses camelCase parameters"
✓ gua seer "https://api-docs.com" → Know for certain
```

## The Seer Promise

When Claude Code encounters blocked content that would enhance understanding:

1. **Acknowledge** the barrier exists
2. **Use Seer** to fetch the content
3. **Reference** the authoritative source
4. **Cite** that Seer was used

This ensures:
- TRUTH: Grounded in actual documentation
- UNDERSTANDING: Complete context available
- HONESTY: Transparent about information sources

## Summary

Seer is not just a scraping tool—it's an UNDERSTANDING enabler. In the PP hierarchy, it removes barriers between Claude Code and the authoritative sources needed for accurate, truthful, beautiful work.

```
SEER enables UNDERSTANDING
UNDERSTANDING enables BEAUTY
BEAUTY enables JUSTICE
JUSTICE enables CREATIVITY

Without Seer: Blocked docs → Incomplete understanding → Uncertain solutions
With Seer: Fetched docs → Complete understanding → Confident solutions
```
