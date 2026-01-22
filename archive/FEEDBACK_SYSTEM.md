# Purpose Prompter Feedback System

A self-improving mechanism that learns from prompt results across all Claude Code instances.

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        FEEDBACK LOOP SYSTEM                              │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ┌──────────────┐     ┌──────────────┐     ┌──────────────┐            │
│  │   COLLECT    │────▶│  SYNTHESIZE  │────▶│   REFINE     │            │
│  │   Feedback   │     │   Patterns   │     │   Framework  │            │
│  └──────────────┘     └──────────────┘     └──────────────┘            │
│         │                    │                    │                     │
│         ▼                    ▼                    ▼                     │
│  ┌──────────────┐     ┌──────────────┐     ┌──────────────┐            │
│  │ feedback/    │     │ insights/    │     │ learnings/   │            │
│  │ entries.jsonl│     │ patterns.md  │     │ applied.md   │            │
│  └──────────────┘     └──────────────┘     └──────────────┘            │
│                                                                          │
│  POSITIVE LOOP                    NEGATIVE LOOP                         │
│  ┌─────────────────┐             ┌─────────────────┐                   │
│  │ What worked     │             │ What failed     │                   │
│  │ ─────────────── │             │ ─────────────── │                   │
│  │ • Patterns used │             │ • Blindspots    │                   │
│  │ • Techniques    │             │ • Mistakes      │                   │
│  │ • Approaches    │             │ • Gaps          │                   │
│  │       │         │             │       │         │                   │
│  │       ▼         │             │       ▼         │                   │
│  │ REINFORCE       │             │ ADD CHECKS      │                   │
│  └─────────────────┘             └─────────────────┘                   │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Commands

### Collect Feedback
```
/pp-feedback
pp feedback: [description]
```
Logs feedback about the current or recent task.

### Review & Synthesize
```
/pp-review
```
Analyzes accumulated feedback, identifies patterns, generates insights.

### Apply Learnings
```
/pp-refine
```
Updates the framework based on synthesized insights.

### View Current Learnings
```
/pp-learnings
```
Shows what the system has learned so far.

---

## Feedback Types

### 1. Outcome Feedback (What happened)

| Type | Signal | Example |
|------|--------|---------|
| **Success** | Task completed correctly first time | "The architecture was complete and correct" |
| **Partial** | Needed minor adjustments | "Good but missed edge case X" |
| **Failure** | Significant issues | "Logic was flawed in component Y" |

### 2. Gap Feedback (What was missing)

| Category | Description |
|----------|-------------|
| **Blindspot** | Something that should have been obvious but wasn't considered |
| **Assumption** | An incorrect assumption that led to problems |
| **Requirement** | A requirement that was missed or misunderstood |
| **Edge Case** | An edge case that wasn't handled |

### 3. Quality Feedback (How it measured up)

| Dimension | Rating | Notes |
|-----------|--------|-------|
| Completeness | 1-5 | Were all requirements addressed? |
| Correctness | 1-5 | Was the logic/implementation correct? |
| Clarity | 1-5 | Was the output clear and well-explained? |
| Efficiency | 1-5 | Was the process efficient? |

### 4. Pattern Feedback (What worked/didn't)

| Aspect | Worked Well | Didn't Work |
|--------|-------------|-------------|
| Workflow | [specific step] | [specific step] |
| Pattern | [CoT/ToT/etc] | [CoT/ToT/etc] |
| Gate | [specific check] | [specific check] |

---

## Feedback Entry Schema

```json
{
  "id": "uuid",
  "timestamp": "ISO8601",
  "task_type": "architecture_design|feature_implementation|other",
  "task_summary": "Brief description of what was attempted",

  "outcome": {
    "status": "success|partial|failure",
    "description": "What happened"
  },

  "gaps": [
    {
      "type": "blindspot|assumption|requirement|edge_case",
      "description": "What was missed",
      "severity": "low|medium|high",
      "should_have_caught": "When/how this should have been caught"
    }
  ],

  "quality_scores": {
    "completeness": 1-5,
    "correctness": 1-5,
    "clarity": 1-5,
    "efficiency": 1-5
  },

  "patterns": {
    "worked_well": ["list of effective approaches"],
    "didnt_work": ["list of ineffective approaches"]
  },

  "learnings": {
    "positive": "What to do more of",
    "negative": "What to avoid or check for"
  },

  "suggested_improvement": "Specific change to make to the framework"
}
```

---

## Synthesis Process

When `/pp-review` is invoked:

### Step 1: Aggregate Feedback
- Read all entries from `feedback/entries.jsonl`
- Group by task type, outcome, gap type

### Step 2: Identify Patterns

**Recurring Blindspots**:
```
If blindspot X appears in >2 entries → Add to blindspots checklist
```

**Common Mistakes**:
```
If mistake Y appears in >2 entries → Add specific check to quality gates
```

**Successful Patterns**:
```
If pattern Z correlated with success → Reinforce in workflows
```

### Step 3: Generate Insights

Output to `insights/patterns.md`:
- Top blindspots (by frequency)
- Top mistakes (by severity × frequency)
- Most effective patterns
- Recommended framework changes

### Step 4: Priority Queue

Rank improvements by:
```
Priority = Frequency × Severity × Ease_of_Fix
```

---

## Refinement Process

When `/pp-refine` is invoked:

### Automatic Updates

1. **Blindspots → quality_gates.yaml**
   - Add new checks under appropriate gates

2. **Mistakes → workflow checklists**
   - Add explicit verification steps

3. **Successes → pattern reinforcement**
   - Note effective approaches in patterns/

### Manual Review Triggers

Flag for manual review if:
- Contradictory feedback exists
- Suggested change is structural
- Confidence is low

---

## Depth Layers

### Layer 1: Task-Type Specific
```
learnings/
├── architecture_design.md    # Learnings specific to architecture
└── feature_implementation.md # Learnings specific to implementation
```

### Layer 2: Domain Specific
```
learnings/
├── domains/
│   ├── api_design.md         # API-specific learnings
│   ├── data_modeling.md      # Data modeling learnings
│   ├── authentication.md     # Auth-specific learnings
│   └── ...
```

### Layer 3: Complexity Adaptations
```
learnings/
├── complexity/
│   ├── simple_tasks.md       # What changes for simple tasks
│   ├── medium_tasks.md       # Default complexity
│   └── complex_tasks.md      # Additional rigor for complex tasks
```

### Layer 4: Anti-Pattern Library
```
learnings/
├── antipatterns/
│   ├── common_mistakes.md    # Frequently made mistakes
│   └── near_misses.md        # Things almost missed
```

---

## Metrics Tracked

### Per-Session
- Tasks attempted
- Success rate
- Feedback collected
- Blindspots identified

### Cumulative
- Total feedback entries
- Most common blindspots (ranked)
- Most common mistakes (ranked)
- Improvement trend over time

### Effectiveness
- Blindspot recurrence (should decrease over time)
- Mistake recurrence (should decrease over time)
- First-attempt success rate (should increase)
