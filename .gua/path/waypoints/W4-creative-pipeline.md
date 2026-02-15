# W4: Creative Pipeline

Creativity at L2 is the sole bottleneck to L3 Craftsman. The system has never exercised its creative capacity: build agent has 0 invocations, no RUBEDO transmutation has completed. This waypoint specifically targets X1-X7 by requiring genuinely uncharted work.

## Prerequisites
- W2 complete (clean codebase, verified schemas)
- W3 complete (10+ runs, multi-day evidence, knowledge compounding)

## Success Criteria

1. [ ] Build agent invoked on a genuinely UNCHARTED task (X1 Territory confirmed uncharted by sense agent)
2. [ ] Build agent output follows documented format: scaffolds new structure, defines integration points, provides implementation plan
3. [ ] Built structure passes X3 (Path-Building): another agent or session can follow the path without the builder
4. [ ] Built structure passes X4 (Extension): coherent with existing codebase, not an isolated island
5. [ ] Full RUBEDO transmutation completed: a candidate passes through all 4 alchemy stages (NIGREDO -> ALBEDO -> CITRINITAS -> RUBEDO) and reaches INTEGRATED
6. [ ] Transmuted module passes Philosopher's Stone test: generates its own reflections that feed back into the loop
7. [ ] Agent reference docs (sense.md, comprehend.md, build.md, assess.md) synchronized with orchestrator prompts (pp.md) — no schema drift

## How to Test
- Criteria 1: In the PP run log, sense report must contain `territory: UNCHARTED` and pp.md must invoke build agent
- Criteria 2: Build agent output must contain: SCAFFOLD, INTEGRATION_POINTS, IMPLEMENTATION_PLAN sections (check against build.md spec)
- Criteria 3: Start a new session, read only the build output, and successfully implement the scaffolded structure without additional context
- Criteria 4: Run `/verify` on the built module — X4 (Extension) and X7 (Integration) must PASS
- Criteria 5: Check athanor directory for a candidate with `"stage": "INTEGRATED"` and complete nigredo/albedo/citrinitas/rubedo fields
- Criteria 6: After the transmuted module is used in 2+ PP runs, check that reflections reference it (grep log.jsonl for module name)
- Criteria 7: Run a diff between each agent .md file's output format section and pp.md's parsing expectations — zero mismatches

## Dimensions Advanced
- **Creativity (X1-X7)**: All 7 creativity gates exercised through real uncharted work
- This is the L3 gate — completing W4 with W1-W3 done means all 5 dimensions at L3

## What Counts as UNCHARTED

The task must satisfy X1 (Territory): no existing solution in the codebase handles it. Examples that would qualify:
- A new PP capability that doesn't map to any existing command/agent/gate
- A structural addition to GUA that serves a need no current command addresses
- An integration between PP and an external system with no existing pattern to follow

Examples that would NOT qualify:
- Adding a parameter to an existing command (CHARTED — pattern exists)
- Fixing a bug in an existing agent (CHARTED — structure exists)
- Refactoring existing code (CHARTED — code exists, just moving/cleaning)
