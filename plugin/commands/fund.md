---
description: "Research Fund — propose, vote on, and explore which insights deserve deeper investigation"
argument-hint: "[proposal text] or [subcommand: vote, tally, explore, status]"
allowed-tools: [Read, Glob, Grep, Write, Edit, Task]
model: opus
---

# Research Fund

> Fair allocation of exploration effort — a JUSTICE concern crossed with CREATIVITY.

The fund is where the ecosystem collectively decides which sparks and insights deserve deeper investigation. Proposals are nominated, agents assess from their dimensions, and the highest-conviction explorations proceed.

## Arguments

$ARGUMENTS

## Routing

Detect the subcommand from `$ARGUMENTS`:

| Pattern | Action |
|---------|--------|
| `vote [proposal-id]` | → Vote protocol |
| `tally [proposal-id]` | → Tally protocol |
| `explore [proposal-id]` | → Explore protocol |
| `status` | → Status protocol |
| *(anything else)* | → **Propose protocol** (default) |

---

## Propose Protocol

Create a new proposal for collective exploration.

### Steps

1. Parse the proposal text from `$ARGUMENTS`
2. Generate ISO timestamp
3. Generate slug ID: `prop-{descriptive-name}` (short, readable)
4. Check `insights/sparks.jsonl` — if the text references a known spark, extract the `spark_ref`
5. Construct JSONL entry:

```jsonl
{"ts":"...","id":"prop-...","spark_ref":"...or null","title":"...","proposer":"user","status":"open","rationale":"..."}
```

6. Append one line to `fund/proposals.jsonl`
7. Update `fund/FUND.md` — add to "Active Proposals" section:
   - `- **[title]** (`[id]`) — [rationale summary]`
8. Update Fund Statistics in `fund/FUND.md`
9. Confirm: `Proposal created: [id] — [title]`

---

## Vote Protocol

Cast a vote on a proposal — human vote or agent deliberation.

### Steps

1. Read `fund/proposals.jsonl` — find the proposal by ID (latest line with that ID wins)
2. Verify status is `open` or `funded` (can vote on funded proposals too)
3. Display the proposal clearly:

```
## Proposal: [title]
ID: [id]  |  Status: [status]  |  Proposed by: [proposer]
Spark: [spark_ref or "none"]

[rationale]
```

4. **Determine vote type** from `$ARGUMENTS`:
   - If contains `agents` or no voter specified: run Agent Deliberation
   - Otherwise: record human vote

### Human Vote

Ask the voter:
- Vote: yes / lean-yes / abstain / lean-no / no
- Dimension: understanding / beauty / justice / creativity / general
- Reasoning: (required — this IS the value)

Append to `fund/votes.jsonl`:
```jsonl
{"ts":"...","proposal_id":"...","voter":"user","dimension":"general","vote":"...","weight":1,"reasoning":"..."}
```

### Agent Deliberation

Each agent assesses from their dimension. Run **sequentially** — reads as a deliberation, not a parallel blast.

**Order**: understanding-builder → beauty-assessor → justice-verifier → path-builder

For each agent, read the proposal (and referenced spark if any), then assess:

| Agent | What They Ask |
|-------|---------------|
| **understanding-builder** | Is there genuine depth? Would exploration build a real mental model? What understanding would be unlocked? |
| **beauty-assessor** | Would the result have natural elegance? Does the current state have ugliness this could resolve? |
| **justice-verifier** | Fair use of effort vs other proposals? Broad or narrow benefit? Right timing? |
| **path-builder** | Genuinely uncharted? Would findings build paths for future work? Clear vision of where it leads? |

Each agent produces a vote entry. Append all 4 to `fund/votes.jsonl`.

Display the assembled deliberation:

```markdown
## Agent Deliberation: [proposal title]

### Understanding (understanding-builder)
**Vote**: [vote]
[reasoning]

### Beauty (beauty-assessor)
**Vote**: [vote]
[reasoning]

### Justice (justice-verifier)
**Vote**: [vote]
[reasoning]

### Creativity (path-builder)
**Vote**: [vote]
[reasoning]
```

---

## Tally Protocol

Count votes and assess conviction for a proposal.

### Steps

1. Read `fund/votes.jsonl` — collect all votes for the given proposal ID
2. Compute conviction score: `yes=2, lean-yes=1, abstain=0, lean-no=-1, no=-2`
3. Show dimensional breakdown
4. Recommend action

### Output

```markdown
## Tally: [proposal title]

### Votes ([N] total)

| Voter | Dimension | Vote | Reasoning |
|-------|-----------|------|-----------|
| ... | ... | ... | [key excerpt] |

### Dimensional Breakdown

| Dimension | Vote | Key Insight |
|-----------|------|-------------|
| Understanding | [vote] | [one-line from reasoning] |
| Beauty | [vote] | ... |
| Justice | [vote] | ... |
| Creativity | [vote] | ... |
| General | [vote(s)] | ... |

### Conviction Score: [N]

[Score breakdown: N×yes(2) + N×lean-yes(1) + ...]

### "No" Votes (if any)
[Surface prominently — signal to reconsider, not automatic veto]
[Full reasoning from any no/lean-no votes]

### Recommendation: [FUND / NEEDS MORE VOTES / LOW CONVICTION]

Funding threshold check:
- [x/✗] At least 3 of 4 agents voted
- [x/✗] Conviction score is positive
- [x/✗] No unaddressed "no" votes (or "no" votes surfaced for consideration)

**Human makes the final decision.** To fund: `/fund explore [id]`
```

---

## Explore Protocol

Begin a funded exploration.

### Steps

1. Read `fund/proposals.jsonl` — find the proposal
2. Read `fund/votes.jsonl` — gather all votes for this proposal
3. Update proposal status: append new line with `"status":"exploring"` to `fund/proposals.jsonl`
4. Update `fund/FUND.md`:
   - Move from "Active Proposals" or "Funded" to "Currently Exploring"
   - Update statistics
5. Display the exploration brief:

```markdown
## Exploration Brief: [title]

### The Question
[Proposal title/rationale]

### What the Agents See

**Understanding perspective**: [from vote reasoning]
**Beauty perspective**: [from vote reasoning]
**Justice perspective**: [from vote reasoning]
**Creativity perspective**: [from vote reasoning]
**Human perspective**: [from vote reasoning, if voted]

### Exploration Directions
[Synthesized from all vote reasoning — what to look for, what to test]
```

6. The actual exploration happens in conversation — this command sets up the brief
7. When exploration completes, create `fund/explored/{id}.md` using the outcome template
8. Update proposal status to `"completed"` in `fund/proposals.jsonl`
9. Update `fund/FUND.md`: move to "Completed Explorations", update statistics

### Outcome Template

```markdown
# Exploration: [Title]

> [One-sentence finding]

## The Proposal
**Proposed by**: [who]  |  **Funded**: [date] with [N] yes / [N] total
**Spark**: [link if any]

## The Exploration
[What was investigated, what was found]

## Findings
### What Held Up
### What Didn't
### Surprises

## Impact
**Insights produced**: [links]
**Tree changes**: [branches grown]

## Votes That Shaped This
[Most illuminating vote reasoning — which perspectives proved prescient]

## Status: completed
Proposed: [date]  |  Funded: [date]  |  Explored: [date]
```

### Exploration Outcomes Flow Back

When exploration completes, findings may produce:
- New sparks → append to `insights/sparks.jsonl`
- New examined insights → create in `insights/examined/`
- Tree updates → update `insights/TREE.md`
- Pattern updates → update `learning/patterns/*.md`

---

## Status Protocol

Overview of all fund activity.

### Steps

1. Read `fund/proposals.jsonl` — group by status (latest line per ID wins)
2. Read `fund/votes.jsonl` — count total
3. Display:

```markdown
## Research Fund Status

| Metric | Count |
|--------|-------|
| Total proposals | [N] |
| Open | [N] |
| Funded | [N] |
| Exploring | [N] |
| Completed | [N] |
| Withdrawn | [N] |
| Total votes | [N] |

### Open Proposals (by conviction)
[Sorted by conviction score, highest first]
- **[title]** ([id]) — conviction: [N], votes: [N]

### Currently Exploring
- **[title]** ([id]) — started [date]

### Recent Completions
- **[title]** ([id]) — [one-sentence finding]
```

---

## PP Alignment

The fund is where two virtues meet:
- **Justice**: Fair allocation of collective effort. Every proposal gets dimensional assessment. Reasoning is valued over tallies.
- **Creativity**: Deciding which paths to build. The fund doesn't just pick "best ideas" — it identifies where exploration would create the most new understanding.
