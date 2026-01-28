# Waypoint: W3 - Session Integration

**Created**: 2026-01-28T17:45:00Z
**Predecessor**: W2
**Successor**: W4
**Status**: completed

## What This Waypoint Achieves
Unified session workflow that combines GUA context tracking with Path Protocol progress tracking. Developers can start and end sessions with full visibility into their purpose-driven progress.

## Success Criteria
1. [x] `path-session-start.sh` shows E2E status, purpose, path progress, current waypoint
2. [x] `path-session-end.sh` captures snapshot, saves to AWS, displays session summary
3. [x] `gua path session start/end` commands available
4. [x] Session scripts integrate with existing GUA session tracking

## E2E Tests That Must Pass
- [x] Session start displays all expected sections
- [x] Session end captures progress snapshot
- [x] GUA path session command dispatches correctly

## Dependencies
- [x] W2 E2E Testing Integration (completed)
- [x] GUA session tracking infrastructure
- [x] Path protocol manifest and waypoints

## Known Risks
- Session scripts require sourcing (not execution) for full functionality
- AWS connectivity required for save operations

## Notes
- Session start: `source ~/.gua/path-session-start.sh [project]`
- Session end: `source ~/.gua/path-session-end.sh [project]`
- Also available via: `gua path session start/end`
