# Feature Implementation Output Template

Use this template for delivering feature implementation results.

---

```markdown
# Feature Implementation: [Feature Name]

## Summary

[2-3 sentences describing what was implemented]

---

## Requirements Addressed

| ID | Requirement | Status | Verification |
|----|-------------|--------|--------------|
| M1 | [Must have 1] | ✅ Complete | [How verified] |
| M2 | [Must have 2] | ✅ Complete | [How verified] |
| S1 | [Should have 1] | ✅ Complete | [How verified] |

---

## Changes Made

### Files Created

| File | Purpose | Lines |
|------|---------|-------|
| `path/to/new_file.py` | [Purpose] | ~XX |
| `path/to/another.py` | [Purpose] | ~XX |

### Files Modified

| File | Changes | Impact |
|------|---------|--------|
| `path/to/existing.py` | [What changed] | Low/Med |
| `path/to/another.py` | [What changed] | Low/Med |

### Files Deleted (if any)

| File | Reason |
|------|--------|
| `path/to/old.py` | [Why removed] |

---

## Implementation Details

### Core Logic

[Brief explanation of how the feature works]

```python
# Key code snippet showing core logic
def main_function():
    # Implementation
    pass
```

### Data Flow

```
[Input] → [Process 1] → [Process 2] → [Output]
```

### Key Design Decisions

1. **[Decision]**: [Rationale]
2. **[Decision]**: [Rationale]

---

## Edge Cases Handled

| Edge Case | Handling |
|-----------|----------|
| [Empty input] | [Behavior] |
| [Invalid data] | [Behavior] |
| [Boundary condition] | [Behavior] |

---

## Error Handling

| Error Condition | Response | User Message |
|-----------------|----------|--------------|
| [Condition 1] | [What happens] | [Message shown] |
| [Condition 2] | [What happens] | [Message shown] |

---

## Testing

### Tests Added

| Test | What It Verifies |
|------|------------------|
| `test_feature_happy_path` | Normal operation |
| `test_feature_edge_case` | [Edge case] |
| `test_feature_error` | [Error handling] |

### Manual Verification

- [ ] [Step 1 to manually verify]
- [ ] [Step 2 to manually verify]

### How to Run Tests

```bash
# Command to run tests
pytest path/to/tests -v
```

---

## Usage

### Basic Usage

```python
# Example of how to use the feature
from module import feature

result = feature.do_something(input)
```

### Configuration (if any)

```yaml
# Any configuration options
feature:
  option1: value
  option2: value
```

---

## Dependencies

### Added Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| [package] | X.Y.Z | [Why needed] |

### Internal Dependencies

- Depends on: [Existing modules]
- Used by: [Other modules if known]

---

## Migration/Setup (if needed)

```bash
# Any setup steps required
# e.g., database migrations, config changes
```

---

## Known Limitations

- [Limitation 1]: [Why and potential future fix]
- [Limitation 2]: [Why and potential future fix]

---

## Future Considerations

- [Possible enhancement 1]
- [Possible enhancement 2]

---

## Completeness Verification

### Requirements Coverage

- [x] All MUST HAVE requirements implemented
- [x] All SHOULD HAVE requirements implemented
- [ ] COULD HAVE: [Deferred/implemented]

### Quality Checks

- [x] No TODO comments remaining
- [x] No placeholder code
- [x] Error handling complete
- [x] Edge cases handled
- [x] Tests cover requirements

### Correctness Checks

- [x] Logic verified
- [x] Types correct
- [x] Integrates with existing code
- [x] No regressions introduced
```
