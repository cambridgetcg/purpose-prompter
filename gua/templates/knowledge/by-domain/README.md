# Knowledge by Domain

This directory contains knowledge organized by technology/domain.

## Structure

```
by-domain/
├── aws/            # AWS-specific patterns
├── claude-code/    # Claude Code patterns
├── typescript/     # TypeScript patterns
├── general/        # General programming patterns
└── {custom}/       # Add domains as needed
```

## Adding New Domains

Create a directory for any frequently-used technology:
```bash
mkdir -p ~/.claude/purpose_prompter/knowledge/by-domain/react
```

## Access

```
/gua-context domain:aws
/gua-context domain:claude-code
/gua-context domain:typescript
```

## Note

Actual knowledge files are stored at `~/.claude/purpose_prompter/knowledge/by-domain/` and synced via AWS. This template shows the expected structure.
