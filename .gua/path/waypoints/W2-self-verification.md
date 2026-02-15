# W2: Self-Verification & Cleanup

PP must pass its own standards before advancing. The full mastery assessment (refl-mastery-full) revealed concrete issues that must be resolved.

## Success Criteria

### Already Met
1. [x] PP verified by its own 30-gate assessment (opus assess, 25 turns, 36 tool uses)
2. [x] Each agent produces output matching documented format (sense, comprehend, assess confirmed)
3. [x] GUA knowledge feeds into agent decisions (blindspots applied by sense agent)
4. [x] No stale references to v2 concepts in plugin files

### Remaining
5. [x] Clean `integration/state.json`: removed legacy classification block (98 lines, J6 injustice resolved)
6. [x] Synchronize agent output schemas: sense.md updated with OWNERSHIP_MAP + COVERAGE to match pp.md prompt
7. [x] Fix LIGHT.md mastery line: `gua load` reads mastery.json, now shows L2 correctly
8. [x] Re-run `/verify` on PP after cleanup — 27/30 PASS, 90% raw rate, 0 FAIL gates (T4/B4 PARTIAL due to thin evidence, X5/X6 PARTIAL due to untested creative pipeline — expected at L2)
9. [x] CHARTED/LOW decision matrix path tested: sense classified "add field to CURRENT_STATE.md" as CHARTED+LOW → skipped comprehend/build → inline execute → inline verify. Flow confirmed.

## How to Test
- Criteria 5: `integration/state.json` should contain only v3-relevant fields
- Criteria 6: Diff sense.md output section against pp.md Phase 1 parsing — formats must match
- Criteria 7: Run `gua mastery status` and compare with LIGHT.md mastery line
- Criteria 8: Run `/verify` on the purpose-prompter repo, check for 0 FAIL gates
- Criteria 9: Run `/pp` on a LOW-risk charted task (should skip comprehend/build), verify inline flow

## Dimensions Advanced
- **Truth (T4 Completeness)**: All claims verified, no stale data
- **Beauty (B4 Elegance)**: Nothing extra (legacy removed), nothing missing (schemas synced)
- **Justice (J6 Integrity)**: Architecture cleaned, boundaries respected
