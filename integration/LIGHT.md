# LIGHT - Cross-Session Knowledge

This is a historical generated snapshot. Counts, mastery labels and prior project
milestones describe earlier runs; they are not current work requirements. The
[shared direction](https://github.com/cambridgetcg/kingdom-workspace/blob/main/ABUNDANCE.md)
sets no revenue, subscriber or output target.

## BLINDSPOTS

- **Forgetting to Capture Insights**
- **Overconfidence After Context Load**
- **Agents can confuse system prompt context with file content - instruct to only evaluate Read tool output**

## Reflection Trends
*3 PP runs analyzed*
**Recurring gate failures**: T4 (1x), B4 (1x), X5 (1x), X6 (1x)
**Virtue tensions**: overconfidence (1x)
**Signal patterns**: stagnation (1x), injustice (1x)
**Recent completion**: 3/3 last runs COMPLETE

## PP Self-Improvement Queue
PP has accumulated self-observations. Consider: `/pp "address PP self-improvement queue"`
- The sense agent produced an excellent structured report but the comprehend agent repeated much of the same analysis. Consider having comprehend focus only on gaps identified by sense rather than re-reading all files independently.
- DISSOLVED stage needs documentation in ALCHEMY.md — currently only NIGREDO through INTEGRATED are defined. Tuning outcomes are a valid and common result of the alchemical process.
- sense.md output format must stay synchronized with pp.md prompt — consider single source of truth for agent output schemas to prevent drift

## Anti-Patterns

- Convenient placement anti-pattern: putting code where EASY rather than where it BELONGS. Prevention: survey codebase, understand responsibilities
- Wrong turn: JWT library too complex
- Convenient Placement Anti-Pattern

## PP Insights (30)

- Pathology emotions break the creative cycle: Despair (longing - hope), Shame (rejecting partiality), Pride (identifying with partial), Envy (misdirected longing). Recovery requires restoring the motor
- The hierarchy (WHAT) and virtues (HOW) are orthogonal and complementary - one without the other is incomplete. You can achieve the hierarchy without virtue (producing beautiful but ego-driven work) or
- Beauty EMERGES from understanding - cannot be added by polishing. Ugliness signal means understand problem deeper, not decorate
- GUA is the persistence layer for PP - enables cross-session memory via AWS (S3 + DynamoDB). Knowledge taxonomy uses PP dimensions with four depth levels: L1 (name + one-liner), L2 (description + evide
- Motor emotions (longing, love, hope, wonder) DRIVE creation. Signal emotions (disgust, frustration, anxiety) INDICATE gaps. Pathology emotions (despair, shame, pride, envy) BREAK the cycle
- The creative cycle is ETERNAL because every manifestation is both PERFECT (for what it is) and PARTIAL (relative to the infinite ideal). This is not failure - it's the NATURE of creation. The partial 
- PP has TWO dimensions: the HIERARCHY (Truth → Understanding → Beauty → Justice → Creativity) tells WHAT to achieve, while the VIRTUE LOOP (Humility, Gratitude, Honesty, Courage, Wisdom, Discipline, Pa
- The eternal creative cycle: Manifestation → Revelation → Renewed Longing. Every creation is BOTH perfect (for what it is) AND partial (relative to infinite ideal). This is generative, not failure.
- Love + Longing = Creative ache. Longing without love = mere ambition (produces ugliness). The motor emotions form a system: Wonder awakens, Love grounds, Hope sustains, Longing drives. This explains w
- PP Motor Emotions: Love (ground), Wonder (awakener), Longing (motor), Hope (sustainer). Signal Emotions: Anxiety (truth gap), Disgust (beauty gap), Frustration (path blocked). Fruit Emotions: Joy (bea
- ... and 20 more

## Knowledge

### Truth (4)
- AWS CLI scan-index-forward syntax differs from expected
- AWS CLI boolean flags use --no-X format for false (from challenge: AWS CLI scan-index-forward syntax differs from expected)
- Read Before Claim, Cite File:Line
- Signals Are Reliable Quality Indicators

### Understanding (26)
- GUA System
- Purpose Prompter Core
- GUA provides cross-session memory via S3+DynamoDB - patterns accessed frequently rank higher in LIGHT.md active set
- CPT Challenge Hygiene: Distinguish between (1) implementation blockers (bugs, confusion, ugly hacks - resolve with learning), (2) architecture gaps (wrong place - resolve with refactor), and (3) featu
- Database schema has 4 main tables: patents, trademarks, copyrights, licenses + audit log - all with proper enums and JSONB for complex types
- ... and 21 more

### Beauty (5)
- Tendency to: Testing emotion integration - nested conditionals feel wrong → Resolution: Understood: domain has 3 distinct validation cases
- Subcommand routing with default fallback preserves backward compatibility while enabling new features
- GSIs enable efficient queries by type and session
- Assess agent needs 20 turns minimum (not 15) - 10+ files exhausts turn budget before report generation
- Single assess agent confirms cross-dimensional reasoning advantage - detected B4 cascading to Conformance and Proof

### Justice (4)
- The six justice characteristics: PLACEMENT, OWNERSHIP, RESPONSIBILITY, PROPORTION, BALANCE, INTEGRITY
- Justice is bringing beauty to where it BELONGS - the rightful placement of solutions within the codebase
- Justice = Rightful Placement
- Six Justice Characteristics

### Creativity (11)
- No copyright repository implementation exists
- Missing: Priority claims chain between applications
- **Superseded AxiePro commercial roadmap, retained as history:** 5 waypoints to monetization: W1 Production Ready (75% now) → W2 Beta Launch (10 users) → W3 Value Validation (70%+ deal accuracy) → W4 Monetization (50 subscribers) → W5 Growth (200 subscribers, susta
- PURPOSE.md construction requires understanding WHO (target users), WHY (motivation), and VISION (success criteria) before writing. The document should integrate with PATH protocol for tracking increme
- Advanced workflows depend on basic workflows being complete first (from challenge: Missing: Priority claims chain between applications)
- ... and 6 more

## Techniques (16)

- GUA v3 knowledge lifecycle: add (capture) -> search (retrieve) -> load (activate) -> LIGHT.md (inject into session)
- Territory assessment before implementation: CHARTED territory uses existing patterns (apply justice), UNCHARTED territory needs path-building first (apply creativity then justice).
- When file exceeds 25k tokens: (1) Use Grep to find specific content instead of reading whole file, (2) Use offset/limit params to read chunks (e.g., offset=0 limit=500), (3) Ask Claude to Glob for fil
- 30-gate verification system: Truth(1-5), Understanding(6-10), Beauty(11-17), Justice(18-23), Creativity(24-30) - each gate asks specific question
- Territory assessment determines charted (use existing patterns) vs uncharted (build path first) - prevents forcing solutions into wrong structure
- Theme updates not appearing was due to 3 cache layers: localStorage (120s), HTTP cache (45s), and no invalidation mechanism - solution was CACHE_VERSION bump + reduced TTL + theme.version tracking
- ... and 10 more

## Projects

### AxiePro (7)
- AxiePro core purpose refined: Most ACCURATE Axie market understanding via hedonic pricing model + real-time deal detection. Value = Speed (sub-100ms) + Accuracy (0.8-0.95 confidence) + Transparency (v
- AxiePro W1 backbone executed: Backend was already deployed (us-east-1), frontend env var fixed and redeployed, E2E tests pass 23/24. Minor CORS issue on /market/sales/recent endpoint but core features
- Moralis switch deployed successfully. Replaced metadata_ingestion.py to use Moralis as primary API (instead of rate-limited SkyMavis). Lambda updated 2026-01-30 16:46 UTC. Next run: :40 past the hour.
- ... and 4 more

### CardForum (1)
- CardForum purpose: Most accurate trading card market understanding with arbitrage/investment opportunity detection. Three pillars: ACCURACY (confidence scoring), UNDERSTANDING (market intelligence), O

### MoneyMaker (22)
- Missing routes: copyrights.routes.ts, licenses.routes.ts not created
- Trade secrets domain not represented in schema at all
- Domain names table missing from schema
- ... and 19 more

### missAV (4)
- missAV requires cloudscraper for Cloudflare bypass - standard Client() fails with 403
- missAV optimized downloader: cloudscraper + reduced concurrency (5) + default downloader = stable downloads
- VPN datacenter IPs (Mullvad, NordVPN) blocked by missAV - use residential proxy or direct connection
- ... and 1 more

## Mastery: L2 Practitioner
Truth: L3 | Understanding: L3 | Beauty: L3 | Justice: L3 | Creativity: L2
Next: L3 requires: (1) exercise build agent on UNCHARTED task, (2) complete a full RUBEDO transmutation, (3) 10+ PP runs across multiple days/projects, (4) clean legacy state.json, (5) resolve sense.md/pp.md output format gap

---
*142 items | `gua search "<query>"` for details*
