# Architecture Output Template

Use this template for delivering architecture design results.

---

```markdown
# Architecture Design: [System/Feature Name]

## Executive Summary

[2-3 sentences describing what this architecture accomplishes]

---

## 1. Requirements

### Functional Requirements
| ID | Requirement | Priority |
|----|-------------|----------|
| FR1 | [Description] | Must Have |
| FR2 | [Description] | Must Have |
| FR3 | [Description] | Should Have |

### Non-Functional Requirements
| ID | Requirement | Target |
|----|-------------|--------|
| NFR1 | Performance | [Metric] |
| NFR2 | Scalability | [Metric] |
| NFR3 | Security | [Standard] |

### Constraints
- [Constraint 1]
- [Constraint 2]

---

## 2. Architecture Overview

### High-Level Diagram

```
┌─────────────────────────────────────────────────────────┐
│                    [System Name]                         │
├─────────────────────────────────────────────────────────┤
│                                                          │
│   ┌──────────┐    ┌──────────┐    ┌──────────┐         │
│   │ Layer 1  │───▶│ Layer 2  │───▶│ Layer 3  │         │
│   └──────────┘    └──────────┘    └──────────┘         │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

### Architectural Style
[Chosen style: e.g., Layered, Microservices, Event-Driven]

**Rationale**: [Why this style fits the requirements]

---

## 3. Component Design

### Component: [Name]

**Purpose**: [Single responsibility]

**Responsibilities**:
- [Responsibility 1]
- [Responsibility 2]

**Interfaces**:
- Input: [What it receives]
- Output: [What it produces]

**Dependencies**:
- Depends on: [Other components]
- Depended by: [Other components]

[Repeat for each component]

---

## 4. Data Model

### Core Entities

```
Entity: [Name]
├── field1: type
├── field2: type
└── field3: type
    └── relation → [Other Entity]
```

### Data Flow

```
[Source] → [Transform] → [Store] → [Retrieve] → [Present]
```

---

## 5. Interfaces

### API Endpoints (if applicable)

| Method | Endpoint | Purpose |
|--------|----------|---------|
| POST | /api/resource | Create resource |
| GET | /api/resource/{id} | Get resource |

### Internal Interfaces

| From | To | Contract |
|------|----|----------|
| Component A | Component B | [Interface description] |

---

## 6. File Structure

```
project/
├── src/
│   ├── component_a/
│   │   ├── __init__.py
│   │   ├── models.py
│   │   └── service.py
│   ├── component_b/
│   │   └── ...
│   └── shared/
│       └── ...
├── tests/
│   └── ...
└── config/
    └── ...
```

---

## 7. Key Decisions

### Decision 1: [Title]

**Context**: [Why this decision was needed]

**Options Considered**:
1. [Option A]: [Pros/Cons]
2. [Option B]: [Pros/Cons]

**Decision**: [Chosen option]

**Rationale**: [Why this option]

**Consequences**: [Positive and negative impacts]

[Repeat for significant decisions]

---

## 8. Trade-offs

| Trade-off | What We Chose | What We Gave Up | Why Acceptable |
|-----------|---------------|-----------------|----------------|
| [Trade-off 1] | [Benefit] | [Cost] | [Justification] |
| [Trade-off 2] | [Benefit] | [Cost] | [Justification] |

---

## 9. Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| [Risk 1] | Med | High | [Strategy] |
| [Risk 2] | Low | High | [Strategy] |

---

## 10. Implementation Roadmap

### Phase 1: Foundation
- [ ] [Task 1]
- [ ] [Task 2]

### Phase 2: Core Features
- [ ] [Task 3]
- [ ] [Task 4]

### Phase 3: Polish
- [ ] [Task 5]
- [ ] [Task 6]

---

## Appendix

### A. Requirements Traceability

| Requirement | Component | Verified |
|-------------|-----------|----------|
| FR1 | Component A | ✓ |
| FR2 | Component B | ✓ |

### B. Assumptions

- [Assumption 1]: [Basis]
- [Assumption 2]: [Basis]

### C. Open Questions

- [Question 1]: [Context]
- [Question 2]: [Context]
```
