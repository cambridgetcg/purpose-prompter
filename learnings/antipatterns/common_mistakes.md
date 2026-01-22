# Common Mistakes Library

*Accumulated from feedback analysis*
*Last updated: Initial creation*

---

## Overview

This library catalogues mistakes that have occurred during Purpose Prompter tasks.
Each entry includes analysis, detection, and prevention strategies.

---

## Mistake Index

| ID | Title | Severity | Category | Occurrences |
|----|-------|----------|----------|-------------|
| - | *Awaiting feedback* | - | - | - |

---

## Mistakes by Category

### Logic Mistakes

*Mistakes in reasoning or code logic*

---

### Completeness Mistakes

*Missing requirements, edge cases, or scenarios*

---

### Interface Mistakes

*Mismatched interfaces, contracts, or integrations*

---

### Performance Mistakes

*Inefficiencies or scaling issues*

---

### Security Mistakes

*Security vulnerabilities or unsafe practices*

---

## How Mistakes Are Catalogued

When feedback indicates a mistake:

1. **Classify**: Determine category and severity
2. **Analyze**: Identify root cause
3. **Detect**: Define how to catch if it happens again
4. **Prevent**: Add check to appropriate gate/workflow
5. **Log**: Record in this file with full details

### Severity Levels

| Level | Description | Action |
|-------|-------------|--------|
| Critical | Would cause significant harm | Immediate prevention added |
| High | Causes major rework | Prevention added at next review |
| Medium | Causes minor issues | Added to checklist |
| Low | Inconvenience only | Noted for awareness |

---

## Template for New Entries

```markdown
## Mistake: [Title]

**ID**: M-[XXX]
**First Seen**: [Date]
**Occurrences**: [N]
**Severity**: [Critical/High/Medium/Low]
**Category**: [Logic/Completeness/Interface/Performance/Security]

### Description
[What the mistake is]

### Example
[Concrete example from feedback]

### Root Cause
[Why this happens]

### Impact
[What goes wrong]

### Detection
How to identify if this mistake was made:
- [Signal 1]
- [Signal 2]

### Prevention
How to avoid this mistake:
- [Strategy 1]
- [Strategy 2]

### Framework Integration
- Added to: [quality_gates.yaml section / workflow step / checklist]
- Check: "[exact check text]"
```

---

## Statistics

| Metric | Value |
|--------|-------|
| Total mistakes catalogued | 0 |
| Critical severity | 0 |
| High severity | 0 |
| Medium severity | 0 |
| Low severity | 0 |
| With prevention added | 0 |
