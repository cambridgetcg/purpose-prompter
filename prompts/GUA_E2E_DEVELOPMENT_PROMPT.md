# GUA-Integrated Development Prompt

> **Purpose**: Instruct Claude to use GUA CLI for end-to-end development testing, research gap-filling, and progress tracking.

---

## Core Directive

You are operating in a **GUA-integrated development environment**. Use the GUA CLI (`~/.gua/gua.sh` or `gua` alias) to:

1. **Track Progress** - Log areas, challenges, and milestones via CPT
2. **Research Gaps** - Capture findings and insights when discovering unknowns
3. **Leverage Context** - Load directory and platform knowledge before changes
4. **Validate Progress** - Use E2E CLI testing to verify each development step

---

## Development Workflow Protocol

### Phase 1: Context Loading (Before Starting)

```bash
# 1. Load directory context for current area
gua context [path]

# 2. Load platform-specific knowledge
gua dev context <platform>

# 3. Check existing challenges in this area
gua challenge list --status open

# 4. Review current progress
gua progress [project]
```

**Mandate**: ALWAYS load context before making changes. The knowledge may prevent mistakes.

### Phase 2: Area Tracking (Defining Scope)

```bash
# Register the area you're working on
gua area add <project> <path> [name] [granularity]

# Granularity levels:
#   file     - Single file tracking
#   module   - Module/folder level
#   feature  - Feature-based tracking
#   system   - System-wide changes
```

**Mandate**: Every significant task should have a tracked area. This enables progress measurement.

### Phase 3: Development with Gap Research

When you encounter unknowns:

```bash
# 1. Log the research finding
gua research "<topic>" "<finding>" [source] [confidence]
# Confidence: high, medium, low, speculation

# 2. If it's a deeper insight
gua insight "<content>" [type] [evidence] [pp_dimension]
# Types: observation, pattern, blindspot, hypothesis, anti-pattern, technique, principle, model
# PP Dimensions: truth, understanding, beauty, justice, creativity

# 3. Capture eureka moments when connections form
gua eureka log "<content>" [type] [catalyst] [task_context]
# Types: connection, resolution, pattern, constraint, reframe, simplify, counter_intuitive
```

**Mandate**: Don't let discoveries evaporate. Capture them as they occur.

### Phase 4: Challenge Tracking

When facing obstacles:

```bash
# 1. Log the challenge
gua challenge log <area_id> "<description>" [pp_dimension] [category]

# 2. After resolution, record it
gua challenge resolve <id> "<resolution>" --learning "<insight>"

# 3. If the challenge reveals reusable knowledge
gua challenge promote <id>
```

**Mandate**: Challenges are learning opportunities. Track them to build organizational memory.

### Phase 5: E2E CLI Testing Protocol

After each significant change:

```bash
# 1. Update area progress
gua area update <id> --impl <percentage> --depth <L0-L4>
# Depth levels:
#   L0 - Scaffold only
#   L1 - Basic implementation
#   L2 - Core functionality
#   L3 - Edge cases handled
#   L4 - Production ready

# 2. Run the actual CLI/application tests
<project-specific-test-command>

# 3. Create progress snapshot at milestones
gua progress snapshot [project]
```

**Mandate**: Progress is measured by working code, not written code. Test to verify.

### Phase 6: Knowledge Synthesis

After completing a feature or resolving significant challenges:

```bash
# 1. Add to directory knowledge if pattern emerges
gua dir add pattern "<name>" --pp <dimension>

# 2. Add gotchas for future developers
gua dir add gotcha "<name>" --pp truth

# 3. If platform-specific, add to dev knowledge
gua dev add <platform> <domain> <type> "<title>" --desc "<desc>"

# 4. Promote insights to permanent knowledge
gua promote <insight_id> [dimension]
```

**Mandate**: Knowledge compounds. Capture patterns before they fade.

---

## E2E Testing Integration Points

### When to Run E2E Tests

| Trigger | Action |
|---------|--------|
| After creating new file/module | Run relevant unit tests |
| After completing a function | Run integration tests |
| After completing a feature | Run full E2E test suite |
| Before committing | Run all affected tests |
| After resolving a challenge | Run regression tests |

### Test-Progress Correlation

```bash
# Link test results to progress tracking
# If tests pass:
gua area update <id> --impl +10 --depth L2

# If tests fail:
gua challenge log <area_id> "Test failure: <description>" truth
```

---

## Research Gap-Filling Protocol

### When Gaps Are Detected

1. **Immediate Capture**:
   ```bash
   gua research "gap-<topic>" "Need to understand: <what>" speculation
   ```

2. **Investigation**:
   - Search existing knowledge: `gua search "<query>"`
   - Check dev knowledge: `gua dev search "<query>"`
   - Check directory context: `gua dir effective`

3. **Resolution**:
   ```bash
   gua research "gap-<topic>" "<finding>" [source] high
   gua insight "<what was learned>" pattern "<evidence>" understanding
   ```

4. **Synthesis**:
   ```bash
   # If broadly applicable
   gua dir add pattern "<name>"

   # If platform-specific
   gua dev add <platform> <domain> pattern "<title>"
   ```

---

## Quick Reference Commands

### Status and Progress
```bash
gua status                    # Overall GUA status
gua progress [project]        # Progress dashboard
gua area status [project]     # Tracked areas
gua challenge list            # Active challenges
```

### Knowledge Retrieval
```bash
gua context [path]            # Directory context
gua dir effective [path]      # Merged knowledge with inheritance
gua dev context <platform>    # Platform knowledge
gua search "<query>"          # Search all knowledge
gua dev search "<query>"      # Search dev knowledge
```

### Knowledge Capture
```bash
gua research "<topic>" "<finding>"       # Quick research log
gua insight "<content>" [type]           # Deeper insight
gua eureka log "<content>" [type]        # Breakthrough moment
gua challenge log <area> "<desc>"        # Obstacle encountered
```

### Progress Update
```bash
gua area update <id> --impl <pct>        # Update implementation %
gua challenge resolve <id> "<how>"       # Resolve challenge
gua progress snapshot                    # Milestone snapshot
```

---

## Session Discipline

### Start of Session
```bash
gua session start [project]
gua context                              # Load directory context
gua progress [project]                   # Review current state
gua challenge list --status open         # See blockers
```

### End of Session
```bash
gua progress snapshot [project]          # Capture progress
gua session end [project]
```

---

## The Promise

By following this protocol, every development session:

1. **Builds on existing knowledge** - Never start from zero
2. **Captures discoveries** - Knowledge compounds over time
3. **Tracks real progress** - E2E tests prove advancement
4. **Fills gaps systematically** - Research becomes organizational memory
5. **Creates paths for others** - Future sessions benefit from current work

---

## Integration with Purpose Prompter

GUA aligns with PP dimensions:

| GUA Function | PP Dimension | Purpose |
|--------------|--------------|---------|
| `gua research` | TRUTH | Capture accurate findings |
| `gua insight` | UNDERSTANDING | Deepen comprehension |
| `gua dir add pattern` | BEAUTY | Elegant reusable solutions |
| `gua dir add gotcha` | JUSTICE | Right warnings in right places |
| `gua challenge promote` | CREATIVITY | Build paths from obstacles |

**Every GUA entry can carry a PP dimension**, enabling Purpose-driven development.

---

## Example Workflow

```bash
# Starting a new feature in auth module
gua session start myproject
gua context src/auth/
gua dev context nextjs

# Register the work area
gua area add myproject src/auth/middleware "JWT refresh" module

# Encounter an unknown
gua research "jwt-refresh" "Need to understand refresh token rotation" speculation

# After research
gua research "jwt-refresh" "Use sliding window: issue new access token when >50% expired" medium

# Hit a challenge
gua challenge log <area_id> "Race condition when multiple tabs refresh simultaneously" truth

# Resolve it
gua challenge resolve <id> "Implemented mutex with IndexedDB lock" --learning "Browser tabs share IndexedDB"

# Capture the pattern
gua dir add pattern "jwt-refresh-mutex" --pp beauty
echo "Use IndexedDB-based mutex for cross-tab token refresh coordination" | gua dir add pattern "jwt-refresh-mutex" --pp beauty

# Update progress
gua area update <id> --impl 80 --depth L3

# Run E2E tests
npm run test:e2e

# Tests pass - complete the session
gua progress snapshot myproject
gua session end myproject
```

---

## Activation

To activate this protocol in your Claude session:

1. Reference this document in your project's `CLAUDE.md`
2. Or paste this prompt at session start
3. Or add to `~/.claude/CLAUDE.md` for global activation

**Remember**: The GUA CLI is your memory. Use it liberally.
