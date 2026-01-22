# Known Blindspots Checklist

*Auto-generated from feedback synthesis*
*Last updated: 2026-01-21 (3 feedback entries analyzed)*

---

## How to Use This File

During Purpose Prompter tasks, reference this checklist at quality gates.
Items marked with `[NEW]` were recently added from feedback.

---

## Universal Blindspots

These apply to all task types:

### Requirements
- [ ] Did I capture implicit requirements (not just explicit)?
- [ ] Did I consider non-functional requirements?
- [ ] Did I identify edge cases?
- [ ] Did I define error scenarios?

### Assumptions
- [ ] Did I state my assumptions explicitly?
- [ ] Did I validate critical assumptions?
- [ ] Did I flag uncertain assumptions for user?

### Completeness
- [ ] Is anything marked TODO or placeholder?
- [ ] Are all paths/branches handled?
- [ ] Is error handling complete?

---

## Architecture Design Blindspots

- [ ] Are all interfaces fully specified?
- [ ] Are there circular dependencies?
- [ ] Is each component's responsibility clear and single?
- [ ] Are data flows documented?
- [ ] Are failure modes considered?

*Additional blindspots will be added from feedback*

---

## Feature Implementation Blindspots

- [ ] Are boundary conditions handled?
- [ ] Is input validation at all entry points?
- [ ] Are concurrent access scenarios considered?
- [ ] Is cleanup/resource release handled?
- [ ] Are all return paths covered?

*Additional blindspots will be added from feedback*

---

## Domain-Specific Blindspots

### API Design
- [ ] Are all error responses defined?
- [ ] Is authentication/authorization specified?
- [ ] Are rate limits considered?
- [ ] Is versioning planned?

### Data Modeling
- [ ] Are indexes planned for query patterns?
- [ ] Is data integrity enforced?
- [ ] Are migrations considered?
- [ ] Is data lifecycle defined?

### Authentication
- [ ] Is session management secure?
- [ ] Are tokens properly validated?
- [ ] Is password handling secure?
- [ ] Are failure cases limited (no enumeration)?

*Additional domains will be populated from feedback*

---

## Recently Added (from feedback)

### [NEW] Ghost Documentation
- **Dimension**: TRUTH
- **Frequency**: 1/3 entries (33% of sessions)
- **Pattern**: Documenting features, commands, or capabilities that don't actually exist yet
- **Root Cause**: Aspirational documentation written before implementation
- **Prevention**: ALWAYS verify claims against actual codebase before documenting
- **Detection**: Run file/command survey (glob, grep) to confirm existence before claiming
- **Added**: 2026-01-21

| Date | Blindspot | Source |
|------|-----------|--------|
| 2026-01-21 | Ghost Documentation | PP self-improvement feedback entry 1 |

---

## Blindspot Statistics

| Category | Count | Last Updated |
|----------|-------|--------------|
| Universal | 12 | Initial |
| Architecture | 5 | Initial |
| Implementation | 5 | Initial |
| Domain-specific | 12 | Initial |
| From feedback | 1 | 2026-01-21 |

**Total blindspots tracked**: 35
**Feedback entries analyzed**: 3
**Last synthesis**: 2026-01-21
