# Justice Patterns

*Accumulated knowledge about placing beauty where it belongs*
*Last updated: Initial creation*

---

## Justice Characteristics Patterns

### Placement Patterns

**What creates right placement**:
- Deep understanding of codebase organization
- Following established conventions
- Thinking about discoverability
- Placing near related code
- Matching concern type to location type

**What creates wrong placement**:
- Not understanding codebase structure
- Ignoring existing conventions
- Placing arbitrarily or conveniently
- Scattering related code
- Mixing concern types in one location

---

### Ownership Patterns

**What creates rightful ownership**:
- Understanding component domains
- Respecting existing boundaries
- Keeping related concerns together
- Clear responsibility assignment
- Avoiding feature envy

**What creates wrong ownership**:
- Not understanding domain boundaries
- Creating god classes/components
- Scattering related concerns
- Ambiguous responsibility
- Constantly accessing other components' data

---

### Responsibility Patterns

**What creates appropriate responsibility**:
- Matching abstraction level to entity type
- Understanding what each layer should do
- Clear separation of concerns
- Focused, single-purpose entities
- Proper delegation

**What creates inappropriate responsibility**:
- Putting low-level logic in high-level entities
- Violating layer purposes
- Mixed concerns in one entity
- Overloaded entities
- Handling things that should be delegated

---

### Proportion Patterns

**What creates fair distribution**:
- Concentrating complexity where it belongs
- Keeping simple things simple
- Proper encapsulation
- Clean interfaces hiding complexity
- Appropriate abstraction levels

**What creates unfair distribution**:
- Leaking complexity to wrong places
- Making simple things complex
- Exposing implementation details
- Missing encapsulation layers
- Flattening necessary abstraction

---

### Balance Patterns

**What creates system equilibrium**:
- Following existing patterns
- Consistent approaches to similar problems
- Distributing work appropriately
- Maintaining architectural consistency
- Contributing to system health

**What creates system imbalance**:
- Breaking from patterns without reason
- Inconsistent approaches
- Creating hotspots or neglected areas
- Fragmenting the system
- Undermining system health

---

### Integrity Patterns

**What preserves architectural integrity**:
- Respecting layer boundaries
- Following dependency rules
- Maintaining separation of concerns
- Upholding design principles
- Clean architectural lines

**What violates architectural integrity**:
- Crossing layer boundaries
- Circular or wrong dependencies
- Mixing concerns across boundaries
- Ignoring design principles
- Blurring architectural lines

---

## Justice Emergence Patterns

### When Justice Emerges

| Condition | Why Justice Emerges |
|-----------|---------------------|
| Codebase structure understood | Know where things belong |
| Conventions understood | Follow existing patterns |
| Component domains understood | Know rightful owners |
| Architecture understood | Respect boundaries |
| Patterns understood | Maintain balance |

### When Injustice Results

| Condition | Why Injustice Results |
|-----------|----------------------|
| Codebase unfamiliar | Don't know where things go |
| Conventions ignored | Break existing patterns |
| Domains unclear | Wrong ownership |
| Architecture violated | Boundaries crossed |
| Patterns ignored | System imbalanced |

---

## Justice by Context

### Justice in New Features

**Just new feature placement**:
- Feature lands in appropriate domain
- New code follows existing patterns
- Components own their relevant parts
- Architecture is strengthened

**Unjust new feature placement**:
- Feature in wrong domain
- New patterns conflict with existing
- Ownership unclear or wrong
- Architecture violated

---

### Justice in Refactoring

**Just refactoring**:
- Code moves to rightful location
- Ownership transferred to proper component
- Complexity redistributed fairly
- Architecture healed

**Unjust refactoring**:
- Code moves to arbitrary location
- Ownership becomes more confused
- Complexity spread unfairly
- Architecture further violated

---

### Justice in Bug Fixes

**Just bug fix**:
- Fix in appropriate location
- Doesn't introduce new architectural violations
- Respects existing structure
- Addresses root cause where it belongs

**Unjust bug fix**:
- Fix in convenient but wrong location
- Introduces new violations
- Works around structure
- Patches symptom in wrong place

---

## Yu-Specific Justice Patterns

*This section populated from feedback about Yu's codebase standards*

### Placement Priorities
- **Known**: Values clear organization and discoverability
- *Additional patterns will be learned from feedback*

### Architecture Standards
*Awaiting feedback data*

---

## Justice Achievement Patterns

### What Works for Placement Justice

| Context | Effective Approach | Why It Works |
|---------|-------------------|--------------|
| - | - | - |

*Will be populated from successful justice feedback*

### What Works for Ownership Justice

| Context | Effective Approach | Why It Works |
|---------|-------------------|--------------|
| - | - | - |

*Will be populated from successful justice feedback*

### What Works for Architectural Justice

| Context | Effective Approach | Why It Works |
|---------|-------------------|--------------|
| - | - | - |

*Will be populated from successful justice feedback*

---

## Justice Failure Patterns

### Common Gate Failures

| Gate | Common Failure | Structural Gap | Prevention |
|------|----------------|----------------|------------|
| Placement | - | - | - |
| Ownership | - | - | - |
| Responsibility | - | - | - |
| Proportion | - | - | - |
| Balance | - | - | - |
| Integrity | - | - | - |

*Will be populated from feedback*

---

## Justice Hit Rate Tracking

### Overall
| Metric | Value |
|--------|-------|
| Total PP tasks | 0 |
| Perfect Justice | 0 |
| Just | 0 |
| Partial Justice | 0 |
| Injustice | 0 |
| **Justice rate** | - |

### By Gate Failure
| Gate Failed | Occurrences | Structural Gap Pattern |
|-------------|-------------|------------------------|
| Placement | 0 | - |
| Ownership | 0 | - |
| Responsibility | 0 | - |
| Proportion | 0 | - |
| Balance | 0 | - |
| Integrity | 0 | - |

### By Task Type
| Task Type | Tasks | Justice Rate |
|-----------|-------|--------------|
| New features | 0 | - |
| Refactoring | 0 | - |
| Bug fixes | 0 | - |

---

## Justice Learning Insights

*Accumulated insights from justice feedback*

### Insight 1
*Awaiting feedback*

### Insight 2
*Awaiting feedback*

---

## Common Architectural Violations to Avoid

### Layer Violations
| Violation | Impact | Just Alternative |
|-----------|--------|------------------|
| UI → Database direct | Breaks separation | UI → Service → Repository |
| Domain depends on infra | Domain not portable | Invert dependencies |
| Controller contains business logic | Logic untestable | Move to domain |

### Dependency Violations
| Violation | Impact | Just Alternative |
|-----------|--------|------------------|
| Circular dependencies | System fragility | Break cycles |
| Inner depends on outer | Architecture inversion | Depend inward |
| Concrete depends on concrete | Tight coupling | Depend on abstractions |

### Ownership Violations
| Violation | Impact | Just Alternative |
|-----------|--------|------------------|
| God class | Single point of failure | Distribute responsibilities |
| Feature envy | Wrong ownership | Move behavior to data |
| Scattered cohesion | Maintenance nightmare | Group related code |

---

## Next Steps

1. Complete PP tasks with justice verification
2. Collect justice-oriented feedback
3. This file will accumulate:
   - Justice achievement rates
   - Gate failure patterns
   - Effective placement strategies
   - Codebase-specific standards
