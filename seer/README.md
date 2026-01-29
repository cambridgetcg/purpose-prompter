# Seer Module

**SEER** = See External Resources

A web scraping module that uses Bright Data to bypass Cloudflare and anti-bot protections, enabling Claude Code sessions to build context from blocked sites.

## Quick Start

### 1. Set Up Bright Data Credentials

```bash
# Add to ~/.zshrc or ~/.bashrc
export BRIGHT_DATA_CUSTOMER_ID="brd-customer-hl_xxxxxxxx"
export BRIGHT_DATA_ZONE="web_unlocker1"
export BRIGHT_DATA_PASSWORD="your_zone_password"
```

### 2. Fetch Blocked Content

```bash
# Fetch a blocked documentation page
gua seer "https://developers.cloudflare.com/workers/"

# Fetch GitHub content
gua seer "https://github.com/anthropics/claude-code/blob/main/README.md"

# Fetch npm package info
gua seer "https://www.npmjs.com/package/express"
```

## Commands

### Basic Usage

```bash
# Fetch and display content (cached if available)
gua seer <url>

# Force refresh (ignore cache)
gua seer <url> --refresh

# Fetch quietly (cache only, no output)
gua seer <url> --quiet

# Specify content type
gua seer <url> --type docs|github|npm|generic

# Limit output tokens
gua seer <url> --max-tokens 10000
```

### Cache Management

```bash
# List all cached URLs
gua seer --list-cache

# Check cache status for URL
gua seer --cache-status <url>

# Clear cache for URL
gua seer --clear-cache <url>
```

## How It Works

```
┌─────────────────────────────────────────────────────┐
│  1. Request                                         │
│     gua seer "https://blocked-site.com/docs"       │
└──────────────────────┬──────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────┐
│  2. Cache Check                                     │
│     - Check DynamoDB for cached content             │
│     - If cached and not expired → return cached     │
└──────────────────────┬──────────────────────────────┘
                       │ (cache miss or --refresh)
                       ▼
┌─────────────────────────────────────────────────────┐
│  3. Bright Data Web Unlocker                        │
│     - Route through Bright Data proxy               │
│     - Bypass Cloudflare/anti-bot                    │
│     - Return HTML content                           │
└──────────────────────┬──────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────┐
│  4. Content Processing                              │
│     - HTML → Markdown conversion                    │
│     - Token-aware truncation (max 20k)              │
│     - Extract title and metadata                    │
└──────────────────────┬──────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────┐
│  5. Cache & Output                                  │
│     - Store in DynamoDB (gua-knowledge-index)       │
│     - Output markdown to stdout                     │
│     - Available for future sessions                 │
└─────────────────────────────────────────────────────┘
```

## Configuration

### Environment Variables (Required)

| Variable | Description |
|----------|-------------|
| `BRIGHT_DATA_CUSTOMER_ID` | Your Bright Data customer ID (e.g., `brd-customer-hl_xxxxx`) |
| `BRIGHT_DATA_ZONE` | Proxy zone name (default: `web_unlocker1`) |
| `BRIGHT_DATA_PASSWORD` | Zone password |

### GUA Config (`~/.gua/config.json`)

```json
{
  "seer": {
    "enabled": true,
    "cache_ttl_hours": 24,
    "github_ttl_hours": 1,
    "npm_ttl_hours": 6,
    "max_content_tokens": 20000,
    "auto_detect_type": true,
    "preferred_scraper": "web_unlocker"
  }
}
```

## Cache TTLs

Different content types have different cache lifetimes:

| Type | TTL | Rationale |
|------|-----|-----------|
| `docs` | 24 hours | Documentation changes infrequently |
| `github` | 1 hour | Code changes more frequently |
| `npm` | 6 hours | Package metadata moderately stable |
| `generic` | 24 hours | Default for unknown types |

## Use Cases

### 1. Blocked Documentation

When Claude Code's WebFetch fails due to Cloudflare:

```bash
# Instead of WebFetch which gets blocked
gua seer "https://developers.cloudflare.com/workers/runtime-apis/kv/"
```

### 2. GitHub File Content

Fetch specific files from repositories:

```bash
gua seer "https://github.com/prisma/prisma/blob/main/packages/client/src/runtime/core/types/Public.ts"
```

### 3. Package Documentation

Get package details from npm:

```bash
gua seer "https://www.npmjs.com/package/@anthropic-ai/sdk"
```

### 4. Building Context for Tasks

Before starting a task that requires external documentation:

```bash
# Pre-fetch relevant docs
gua seer "https://docs.stripe.com/api/charges" --quiet
gua seer "https://docs.stripe.com/api/refunds" --quiet

# Now docs are cached for the session
```

## Integration with PP

Seer serves the **UNDERSTANDING** dimension:
- Provides access to authoritative sources
- Enables accurate context building
- Resolves "confusion" signals when docs are blocked

### Workflow Integration

```
Light-Ahead Loop with Seer:

1. ASSESS
   - Identify blocked resources needed
   - Check existing cache: gua seer --list-cache

2. RESEARCH
   - Fetch blocked docs: gua seer <url>
   - Content automatically indexed

3. BUILD
   - Reference cached docs
   - Content available in context

4. VALIDATE
   - Re-fetch if needed: gua seer <url> --refresh

5. CAPTURE
   - Seer caches useful content
   - Available for future sessions
```

## Cost Considerations

Bright Data pricing (approximate):
- Web Unlocker: ~$3/1000 requests
- Scraping Browser: ~$8/1000 requests

Cost mitigation:
- Aggressive caching (default 24h TTL)
- Use `--quiet` to pre-fetch without display
- Cache persists across Claude Code sessions

## Troubleshooting

### "BRIGHT_DATA_CUSTOMER_ID not set"

Set environment variables:
```bash
export BRIGHT_DATA_CUSTOMER_ID="brd-customer-hl_xxxxx"
export BRIGHT_DATA_PASSWORD="your_password"
```

### "Failed to fetch URL"

1. Check credentials are correct
2. Verify Bright Data account has quota
3. Try with `--refresh` flag
4. Check if URL is accessible at all

### Truncated Content

Content is truncated at ~20k tokens to fit in Claude Code context. Use `--max-tokens` to adjust:
```bash
gua seer <url> --max-tokens 10000  # Smaller output
```

### Cache Not Working

Check DynamoDB connectivity:
```bash
gua auth verify  # Should show AWS is accessible
```

## Files

```
~/.gua/
├── seer.sh              # Main module (sourced by gua.sh)
├── config.json          # Contains seer config
└── seer/
    └── cache/           # Local fallback cache (not yet implemented)

~/Desktop/purpose_prompter/seer/
├── README.md            # This file
├── SEER.md              # Philosophy integration
└── examples/
    ├── cloudflare-docs.md
    └── github-issues.md
```
