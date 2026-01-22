# Specialized Toolsets for PP Outcome Attributes

> **Insight**: Tool organization from mechanics and surgery reveals patterns applicable to AI assistance:
> Socket sets organize by SIZE (scale), Surgical trays organize by PROCEDURE (task).
> Both reduce cognitive load through visual organization and quick access.

---

## Part 1: Tool Organization Principles

### From Mechanic's Workshop

| Principle | Mechanic Application | AI Assistance Translation |
|-----------|---------------------|---------------------------|
| **Drive Size Separation** | 1/4", 3/8", 1/2" drawers | Task complexity levels (quick/medium/deep) |
| **SAE/Metric Separation** | Different measurement systems | Different domains (frontend/backend/infra) |
| **Foam Inserts** | Visual presence/absence | Tool usage tracking, missing tool alerts |
| **Color Coding** | Quick identification | Tool category visual cues |
| **Socket Rails** | Linear size progression | Graduated tool sequences |

### From Surgical Theatre

| Principle | Surgical Application | AI Assistance Translation |
|-----------|---------------------|---------------------------|
| **Tray Rationalization** | Only needed instruments | Minimal tool activation |
| **Multi-tier Organization** | Avoid stacking, facilitate access | Layered tool presentation |
| **Procedure-specific Trays** | Task-oriented selection | Workflow-specific toolsets |
| **Surgeon Preferences** | Personalized arrangement | User-customizable toolkits |
| **Cognitive Ergonomics** | Reduce mental load | Progressive disclosure |

### From Modular Systems

| Principle | Modular System | AI Assistance Translation |
|-----------|----------------|---------------------------|
| **Standardized Dimensions** | PACKOUT™ compatibility | Consistent tool interfaces |
| **Expansion Buffer** | 20-30% extra space | Room for new tools |
| **Lightweight Tools** | Flexibility not prescription | Adaptable, not rigid |
| **Visual Tools** | Workshop charts | Readable outputs |
| **Embedded in Workflow** | Part of process | Integrated, not standalone |

---

## Part 2: The Three Outcome Attributes as Tool Categories

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    OUTCOME ATTRIBUTE → TOOLSET MAPPING                   │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│   ATTRIBUTE              MECHANIC ANALOGY         TOOLSET TYPE          │
│   ─────────────────────────────────────────────────────────────────     │
│                                                                          │
│   Fewer Misplacements    Diagnostic Tools         PLACEMENT SET         │
│   (Justice)              OBD Scanner              Survey, Compare,      │
│                          Service Manual           Evidence              │
│                                                                          │
│   Faster Debugging       Electrical Tools         SIGNAL SET            │
│   (Signals)              Multimeter               Detect, Trace,        │
│                          Circuit Tracer           Isolate               │
│                                                                          │
│   Better First Attempts  Reference Tools          PATTERN SET           │
│   (Understanding+Beauty) Torque Specs             Map, Match,           │
│                          Wiring Diagrams          Conform               │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Part 3: Socket Set Visualization

### The Mechanic's Socket Set Model

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         SOCKET SET ANALOGY                               │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  DRIVE SIZE = Task Complexity                                           │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │                                                                    │  │
│  │  1/4" DRIVE          3/8" DRIVE           1/2" DRIVE              │  │
│  │  (Light Duty)        (General Purpose)    (Heavy Duty)            │  │
│  │                                                                    │  │
│  │  ○ ○ ○ ○ ○ ○         ◉ ◉ ◉ ◉ ◉ ◉ ◉       ⬤ ⬤ ⬤ ⬤ ⬤ ⬤         │  │
│  │  4 5 6 7 8 9mm       8 10 12 14 17 19mm   17 19 21 22 24 27mm    │  │
│  │                                                                    │  │
│  │  Quick fixes         Most common tasks    Major components        │  │
│  │  Tight spaces        Standard work        High torque             │  │
│  │                                                                    │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│                                                                          │
│  RATCHET = The execution mechanism (Claude's tool use)                  │
│  EXTENSION = Reach adaptation (context window, tool chaining)           │
│  UNIVERSAL JOINT = Angle adaptation (prompt flexibility)                │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### Mapped to AI Assistance

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    AI ASSISTANCE "SOCKET SET"                            │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  1/4" (Quick)           3/8" (Standard)        1/2" (Deep)              │
│  ─────────────          ─────────────          ─────────────            │
│                                                                          │
│  • Quick cite           • Full file read       • Multi-file map         │
│  • Spot check           • Pattern search       • Dependency trace       │
│  • Single grep          • Directory scan       • Architecture review    │
│  • Line reference       • Function analysis    • System understanding   │
│                                                                          │
│  Use for:               Use for:               Use for:                 │
│  - Simple claims        - Feature work         - Refactoring            │
│  - Quick fixes          - New code             - Architecture changes   │
│  - Typo corrections     - Bug investigation    - Major features         │
│                                                                          │
│  Time: <30 seconds      Time: 1-5 minutes      Time: 5-30 minutes       │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Part 4: Ratchet Set Visualization

### The Mechanic's Ratchet Set Model

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         RATCHET SET ANALOGY                              │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  RATCHET TYPE = Execution Style                                         │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │                                                                    │  │
│  │  STANDARD           FLEX-HEAD           LOW-PROFILE               │  │
│  │  RATCHET            RATCHET             RATCHET                   │  │
│  │                                                                    │  │
│  │  ╔═══╗              ╔═══╗               ═══════                   │  │
│  │  ║   ║──────        ║   ╠─~~~~~         ═══════──────             │  │
│  │  ╚═══╝              ╚═══╝               ═══════                   │  │
│  │                                                                    │  │
│  │  Direct access      Angle adjustment    Tight spaces              │  │
│  │  Most common        Awkward positions   Restricted access         │  │
│  │                                                                    │  │
│  └──────────────────────────────────────────────────────────────────┘  │
│                                                                          │
│  ACCESSORIES:                                                            │
│  • Extensions (3", 6", 10") = Context extension                         │
│  • Universal joints = Prompt angle adjustment                           │
│  • Adapters (3/8" to 1/4") = Tool bridging                             │
│  • Breaker bar = Maximum force for stuck problems                       │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### Mapped to AI Assistance

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    AI ASSISTANCE "RATCHET SET"                           │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  STANDARD              FLEX-HEAD              LOW-PROFILE               │
│  (Direct tools)        (Adaptive tools)       (Minimal tools)           │
│  ─────────────         ─────────────          ─────────────             │
│                                                                          │
│  • Read                 • Task(Explore)        • Grep (quick)           │
│  • Write                • Task(Plan)           • Glob (quick)           │
│  • Edit                 • AskUserQuestion      • Bash (single cmd)      │
│  • Bash                                                                  │
│                                                                          │
│  Use when:              Use when:              Use when:                │
│  - Clear path           - Unclear approach     - Tight context          │
│  - Known location       - Need flexibility     - Simple verification    │
│  - Standard operation   - User input needed    - Quick checks           │
│                                                                          │
│  EXTENSIONS:            UNIVERSAL JOINTS:      ADAPTERS:                │
│  • TodoWrite            • Model selection      • Tool chaining          │
│  • Multi-file read      • Temperature adj      • Agent spawning         │
│  • Context refresh      • Prompt reframe       • Output bridging        │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Part 5: Specialized Toolset Designs

### TOOLSET 1: PLACEMENT SET (Fewer Misplacements)

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         PLACEMENT SET                                    │
│                    "The Diagnostic Toolkit"                              │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  PURPOSE: Ensure code lands in its rightful place                       │
│  ANALOGY: OBD Scanner + Service Manual + Location Charts                │
│                                                                          │
│  ┌────────────────────────────────────────────────────────────────┐    │
│  │ TRAY 1: SURVEY TOOLS (Gather candidates)                        │    │
│  │                                                                  │    │
│  │   ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐              │    │
│  │   │ dir-map │ │file-find│ │ similar │ │candidate│              │    │
│  │   │         │ │         │ │ -search │ │ -list   │              │    │
│  │   └─────────┘ └─────────┘ └─────────┘ └─────────┘              │    │
│  │                                                                  │    │
│  │   List dirs   Find files   Find similar  List all options       │    │
│  │   by type     by pattern   code          for placement          │    │
│  └────────────────────────────────────────────────────────────────┘    │
│                                                                          │
│  ┌────────────────────────────────────────────────────────────────┐    │
│  │ TRAY 2: COMPARE TOOLS (Analyze candidates)                      │    │
│  │                                                                  │    │
│  │   ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐              │    │
│  │   │  read-  │ │ content │ │ pattern │ │  fit-   │              │    │
│  │   │  each   │ │ -compare│ │ -match  │ │ score   │              │    │
│  │   └─────────┘ └─────────┘ └─────────┘ └─────────┘              │    │
│  │                                                                  │    │
│  │   Read each   Compare     Match to     Score fitness            │    │
│  │   candidate   contents    patterns     of each                  │    │
│  └────────────────────────────────────────────────────────────────┘    │
│                                                                          │
│  ┌────────────────────────────────────────────────────────────────┐    │
│  │ TRAY 3: EVIDENCE TOOLS (Document decision)                      │    │
│  │                                                                  │    │
│  │   ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐              │    │
│  │   │ cite-   │ │ reject- │ │evidence │ │placement│              │    │
│  │   │ similar │ │ reason  │ │ -report │ │ -commit │              │    │
│  │   └─────────┘ └─────────┘ └─────────┘ └─────────┘              │    │
│  │                                                                  │    │
│  │   Cite why    Document    Generate     Commit with              │    │
│  │   this place  rejections  evidence     evidence                 │    │
│  └────────────────────────────────────────────────────────────────┘    │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### TOOLSET 2: SIGNAL SET (Faster Debugging)

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           SIGNAL SET                                     │
│                    "The Electrical Toolkit"                              │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  PURPOSE: Detect, trace, and isolate issues quickly                     │
│  ANALOGY: Multimeter + Circuit Tracer + Oscilloscope                    │
│                                                                          │
│  ┌────────────────────────────────────────────────────────────────┐    │
│  │ TRAY 1: DETECT TOOLS (Find the signal)                          │    │
│  │                                                                  │    │
│  │   ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐              │    │
│  │   │ugliness │ │injustice│ │stagnate │ │ signal- │              │    │
│  │   │ -detect │ │ -detect │ │ -detect │ │ summary │              │    │
│  │   └─────────┘ └─────────┘ └─────────┘ └─────────┘              │    │
│  │                                                                  │    │
│  │   Detect     Detect      Detect      Summarize                  │    │
│  │   ugliness   misplacement need for    all signals               │    │
│  │   signals    signals     creativity                             │    │
│  └────────────────────────────────────────────────────────────────┘    │
│                                                                          │
│  ┌────────────────────────────────────────────────────────────────┐    │
│  │ TRAY 2: TRACE TOOLS (Follow the path)                           │    │
│  │                                                                  │    │
│  │   ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐              │    │
│  │   │  call-  │ │  data-  │ │ import- │ │ change- │              │    │
│  │   │  trace  │ │  flow   │ │  graph  │ │ history │              │    │
│  │   └─────────┘ └─────────┘ └─────────┘ └─────────┘              │    │
│  │                                                                  │    │
│  │   Trace      Trace data  Map import  Check git                  │    │
│  │   call path  flow        dependencies history                   │    │
│  └────────────────────────────────────────────────────────────────┘    │
│                                                                          │
│  ┌────────────────────────────────────────────────────────────────┐    │
│  │ TRAY 3: ISOLATE TOOLS (Narrow down)                             │    │
│  │                                                                  │    │
│  │   ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐              │    │
│  │   │ bisect- │ │ diff-   │ │ minimal │ │  root-  │              │    │
│  │   │ search  │ │ analyze │ │ -repro  │ │  cause  │              │    │
│  │   └─────────┘ └─────────┘ └─────────┘ └─────────┘              │    │
│  │                                                                  │    │
│  │   Binary     Analyze     Find minimal Identify                  │    │
│  │   search     differences reproduction root cause                │    │
│  └────────────────────────────────────────────────────────────────┘    │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### TOOLSET 3: PATTERN SET (Better First Attempts)

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          PATTERN SET                                     │
│                    "The Reference Toolkit"                               │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  PURPOSE: Ensure new code matches existing patterns                     │
│  ANALOGY: Service Manual + Torque Specs + Wiring Diagrams               │
│                                                                          │
│  ┌────────────────────────────────────────────────────────────────┐    │
│  │ TRAY 1: MAP TOOLS (Understand the territory)                    │    │
│  │                                                                  │    │
│  │   ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐              │    │
│  │   │  arch-  │ │ domain- │ │ pattern │ │ mental- │              │    │
│  │   │  map    │ │  map    │ │ -catalog│ │  model  │              │    │
│  │   └─────────┘ └─────────┘ └─────────┘ └─────────┘              │    │
│  │                                                                  │    │
│  │   Map        Map         Catalog     Build                      │    │
│  │   architecture domain    patterns    mental model               │    │
│  └────────────────────────────────────────────────────────────────┘    │
│                                                                          │
│  ┌────────────────────────────────────────────────────────────────┐    │
│  │ TRAY 2: MATCH TOOLS (Find the right pattern)                    │    │
│  │                                                                  │    │
│  │   ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐              │    │
│  │   │ similar │ │ pattern │ │ best-   │ │ extract │              │    │
│  │   │ -finder │ │ -matcher│ │  match  │ │ -pattern│              │    │
│  │   └─────────┘ └─────────┘ └─────────┘ └─────────┘              │    │
│  │                                                                  │    │
│  │   Find       Match to    Select     Extract                     │    │
│  │   similar    patterns    best match the pattern                 │    │
│  └────────────────────────────────────────────────────────────────┘    │
│                                                                          │
│  ┌────────────────────────────────────────────────────────────────┐    │
│  │ TRAY 3: CONFORM TOOLS (Follow the pattern)                      │    │
│  │                                                                  │    │
│  │   ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐              │    │
│  │   │ template│ │ conform │ │  style- │ │ pattern │              │    │
│  │   │ -apply  │ │ -check  │ │  match  │ │ -verify │              │    │
│  │   └─────────┘ └─────────┘ └─────────┘ └─────────┘              │    │
│  │                                                                  │    │
│  │   Apply      Check       Verify     Final pattern               │    │
│  │   template   conformance style      verification                │    │
│  └────────────────────────────────────────────────────────────────┘    │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Part 6: Cross-Toolset Usage Patterns

### The Combination Matrix

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    CROSS-TOOLSET COMBINATIONS                            │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│                         PLACEMENT    SIGNAL     PATTERN                 │
│                         SET          SET        SET                     │
│  ─────────────────────────────────────────────────────────────────      │
│                                                                          │
│  PLACEMENT SET          ────         Detect +   Map +                   │
│  (Justice)                           Place      Place                   │
│                                                                          │
│  SIGNAL SET             Survey +     ────       Trace +                 │
│  (Debug)                Isolate                 Match                   │
│                                                                          │
│  PATTERN SET            Evidence +   Conform +  ────                    │
│  (First Attempt)        Conform      Verify                             │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### Common Combination Workflows

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    WORKFLOW COMBINATIONS                                 │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  WORKFLOW 1: New Feature Implementation                                 │
│  ─────────────────────────────────────────                              │
│  PATTERN.map → PATTERN.match → PLACEMENT.survey →                       │
│  PLACEMENT.evidence → PATTERN.conform → SIGNAL.detect                   │
│                                                                          │
│  Like: Mechanic consults manual, selects socket, tests after            │
│                                                                          │
│  ─────────────────────────────────────────────────────────────────      │
│                                                                          │
│  WORKFLOW 2: Bug Fix                                                    │
│  ─────────────────────                                                  │
│  SIGNAL.detect → SIGNAL.trace → SIGNAL.isolate →                        │
│  PATTERN.match → PLACEMENT.verify → SIGNAL.verify                       │
│                                                                          │
│  Like: Mechanic uses multimeter, traces wires, tests fix                │
│                                                                          │
│  ─────────────────────────────────────────────────────────────────      │
│                                                                          │
│  WORKFLOW 3: Refactoring                                                │
│  ───────────────────────                                                │
│  PATTERN.map → SIGNAL.detect → PLACEMENT.survey →                       │
│  PATTERN.extract → PLACEMENT.evidence → PATTERN.conform                 │
│                                                                          │
│  Like: Mechanic reviews system, plans reorganization, executes          │
│                                                                          │
│  ─────────────────────────────────────────────────────────────────      │
│                                                                          │
│  WORKFLOW 4: Code Review                                                │
│  ───────────────────────                                                │
│  SIGNAL.detect → PLACEMENT.verify → PATTERN.check →                     │
│  SIGNAL.summary                                                         │
│                                                                          │
│  Like: Mechanic inspects work, checks against specs                     │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Part 7: Tool Types Within Toolsets

### PLACEMENT SET Tool Types

| Category | Tool | Purpose | Implementation |
|----------|------|---------|----------------|
| **Survey** | `dir-map` | List directory structure | `ls -la`, `tree` |
| **Survey** | `file-find` | Find files by pattern | `Glob` |
| **Survey** | `similar-search` | Find similar code | `Grep` with patterns |
| **Survey** | `candidate-list` | Generate placement options | Analysis + List |
| **Compare** | `read-each` | Read each candidate | `Read` multiple |
| **Compare** | `content-compare` | Compare what's in each | Diff analysis |
| **Compare** | `pattern-match` | Match to conventions | Pattern recognition |
| **Compare** | `fit-score` | Score fitness | Weighted criteria |
| **Evidence** | `cite-similar` | Cite similar as evidence | Reference extraction |
| **Evidence** | `reject-reason` | Document rejections | Reasoning chain |
| **Evidence** | `evidence-report` | Generate report | Structured output |
| **Evidence** | `placement-commit` | Commit with evidence | Documented decision |

### SIGNAL SET Tool Types

| Category | Tool | Purpose | Implementation |
|----------|------|---------|----------------|
| **Detect** | `ugliness-detect` | Find code smells | Pattern + Heuristic |
| **Detect** | `injustice-detect` | Find misplacements | Convention check |
| **Detect** | `stagnate-detect` | Find blocked paths | Gap analysis |
| **Detect** | `signal-summary` | Summarize findings | Aggregation |
| **Trace** | `call-trace` | Trace call paths | AST analysis |
| **Trace** | `data-flow` | Trace data flow | Flow analysis |
| **Trace** | `import-graph` | Map dependencies | Import parsing |
| **Trace** | `change-history` | Git history | `git log/blame` |
| **Isolate** | `bisect-search` | Binary search | `git bisect` |
| **Isolate** | `diff-analyze` | Analyze differences | `diff` + analysis |
| **Isolate** | `minimal-repro` | Find minimal case | Reduction |
| **Isolate** | `root-cause` | Identify root | Causal analysis |

### PATTERN SET Tool Types

| Category | Tool | Purpose | Implementation |
|----------|------|---------|----------------|
| **Map** | `arch-map` | Map architecture | Directory + Analysis |
| **Map** | `domain-map` | Map domains | Namespace analysis |
| **Map** | `pattern-catalog` | Catalog patterns | Pattern extraction |
| **Map** | `mental-model` | Build mental model | Structured summary |
| **Match** | `similar-finder` | Find similar code | Semantic search |
| **Match** | `pattern-matcher` | Match to patterns | Pattern recognition |
| **Match** | `best-match` | Select best match | Scoring + Selection |
| **Match** | `extract-pattern` | Extract the pattern | Template creation |
| **Conform** | `template-apply` | Apply template | Code generation |
| **Conform** | `conform-check` | Check conformance | Validation |
| **Conform** | `style-match` | Verify style | Linting + Analysis |
| **Conform** | `pattern-verify` | Final verification | Gate check |

---

## Part 8: The Complete Toolset Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                    PP SPECIALIZED TOOLSET ARCHITECTURE                   │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  ╔═══════════════════════════════════════════════════════════════════╗  │
│  ║                      MASTER TOOL CASE                              ║  │
│  ║                     (Purpose Prompter)                             ║  │
│  ╠═══════════════════════════════════════════════════════════════════╣  │
│  ║                                                                    ║  │
│  ║  ┌─────────────────────────────────────────────────────────────┐ ║  │
│  ║  │              PLACEMENT SET (Red Drawer)                      │ ║  │
│  ║  │                                                              │ ║  │
│  ║  │  ┌─────────┐ ┌─────────┐ ┌─────────┐                        │ ║  │
│  ║  │  │ SURVEY  │ │ COMPARE │ │EVIDENCE │  Evidence Gate         │ ║  │
│  ║  │  │  Tray   │ │  Tray   │ │  Tray   │  enforces usage        │ ║  │
│  ║  │  └─────────┘ └─────────┘ └─────────┘                        │ ║  │
│  ║  └─────────────────────────────────────────────────────────────┘ ║  │
│  ║                                                                    ║  │
│  ║  ┌─────────────────────────────────────────────────────────────┐ ║  │
│  ║  │              SIGNAL SET (Yellow Drawer)                      │ ║  │
│  ║  │                                                              │ ║  │
│  ║  │  ┌─────────┐ ┌─────────┐ ┌─────────┐                        │ ║  │
│  ║  │  │ DETECT  │ │  TRACE  │ │ ISOLATE │  Citation Gate         │ ║  │
│  ║  │  │  Tray   │ │  Tray   │ │  Tray   │  enforces usage        │ ║  │
│  ║  │  └─────────┘ └─────────┘ └─────────┘                        │ ║  │
│  ║  └─────────────────────────────────────────────────────────────┘ ║  │
│  ║                                                                    ║  │
│  ║  ┌─────────────────────────────────────────────────────────────┐ ║  │
│  ║  │              PATTERN SET (Blue Drawer)                       │ ║  │
│  ║  │                                                              │ ║  │
│  ║  │  ┌─────────┐ ┌─────────┐ ┌─────────┐                        │ ║  │
│  ║  │  │   MAP   │ │  MATCH  │ │ CONFORM │  Conformance Gate      │ ║  │
│  ║  │  │  Tray   │ │  Tray   │ │  Tray   │  enforces usage        │ ║  │
│  ║  │  └─────────┘ └─────────┘ └─────────┘                        │ ║  │
│  ║  └─────────────────────────────────────────────────────────────┘ ║  │
│  ║                                                                    ║  │
│  ║  ┌─────────────────────────────────────────────────────────────┐ ║  │
│  ║  │           FOUNDATION SET (Green Drawer)                      │ ║  │
│  ║  │                                                              │ ║  │
│  ║  │  ┌─────────┐ ┌─────────┐ ┌─────────┐                        │ ║  │
│  ║  │  │  TRUTH  │ │UNDERSTAND││CREATIVE │  Proof/Exhaustion      │ ║  │
│  ║  │  │  Tools  │ │  Tools  │ │  Tools  │  Gates enforce         │ ║  │
│  ║  │  └─────────┘ └─────────┘ └─────────┘                        │ ║  │
│  ║  └─────────────────────────────────────────────────────────────┘ ║  │
│  ║                                                                    ║  │
│  ╚═══════════════════════════════════════════════════════════════════╝  │
│                                                                          │
│  ACCESSORIES TRAY (Universal):                                          │
│  ┌─────────────────────────────────────────────────────────────────┐   │
│  │ TodoWrite │ AskUser │ Task(Agent) │ WebSearch │ Model Select │   │
│  └─────────────────────────────────────────────────────────────────┘   │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Part 9: Implementation Mapping to Current Tools

### How Current Claude Tools Map to Toolsets

| Toolset | Tray | Tool | Claude Implementation |
|---------|------|------|----------------------|
| **PLACEMENT** | Survey | dir-map | `Bash("ls -la")` |
| **PLACEMENT** | Survey | file-find | `Glob("pattern")` |
| **PLACEMENT** | Survey | similar-search | `Grep("pattern")` |
| **PLACEMENT** | Compare | read-each | `Read(file)` × N |
| **PLACEMENT** | Evidence | cite-similar | Structured output |
| **SIGNAL** | Detect | ugliness-detect | `Grep` + heuristics |
| **SIGNAL** | Trace | call-trace | `Grep("function")` + `Read` |
| **SIGNAL** | Trace | change-history | `Bash("git log")` |
| **SIGNAL** | Isolate | bisect-search | `Bash("git bisect")` |
| **PATTERN** | Map | arch-map | `Glob` + `Read` + synthesis |
| **PATTERN** | Match | similar-finder | `Grep` + semantic |
| **PATTERN** | Conform | template-apply | `Edit` or `Write` |
| **PATTERN** | Conform | style-match | `Grep` + comparison |

### New Tools to Build

| Toolset | Tool | Current Gap | Proposed Implementation |
|---------|------|-------------|------------------------|
| **PLACEMENT** | `fit-score` | No scoring system | Weighted criteria algorithm |
| **PLACEMENT** | `evidence-report` | Manual reporting | Structured template |
| **SIGNAL** | `signal-summary` | Manual aggregation | Auto-summary after detection |
| **SIGNAL** | `root-cause` | Manual analysis | Causal chain builder |
| **PATTERN** | `pattern-catalog` | No catalog | Codebase pattern extraction |
| **PATTERN** | `best-match` | Manual selection | Similarity scoring |
| **FOUNDATION** | `territory-assess` | Manual check | Exhaustive search automation |

---

## Part 10: Key Insights

### Insight 1: Tool Organization Reduces Cognitive Load
Like a mechanic's foam insert showing missing sockets, tool organization should make absence visible. When a gate fails, the missing tool usage should be obvious.

### Insight 2: Drive Size = Task Complexity
Mechanics select drive size based on task scale. AI tools should have "quick" (1/4"), "standard" (3/8"), and "deep" (1/2") variants for different task complexities.

### Insight 3: Cross-Set Combinations Are Powerful
The most effective mechanics combine tools from different sets. The most effective AI assistance combines detection + placement + pattern tools in integrated workflows.

### Insight 4: Procedure-Specific Trays
Surgeons have procedure-specific trays. AI assistance should have task-specific tool combinations:
- Feature Tray: Map → Match → Survey → Evidence → Conform
- Debug Tray: Detect → Trace → Isolate → Verify
- Refactor Tray: Map → Detect → Survey → Extract → Conform

### Insight 5: Extensions and Adapters
Mechanics use extensions and adapters to reach difficult areas. AI tools need:
- Context extensions (multi-file reads)
- Tool bridges (agent spawning)
- Angle adapters (prompt reframing)

### Insight 6: The Breaker Bar
For stuck problems, mechanics use a breaker bar (maximum force). AI needs equivalent:
- Extended thinking for stuck analysis
- Multiple agent collaboration
- User escalation paths

---

## Part 11: Implementation Specifications

### PLACEMENT SET Implementation

```yaml
# ~/.claude/plugins/pp-toolsets/placement-set/

placement-set:
  trays:
    survey:
      - tool: dir-map
        impl: |
          Glob("$TARGET/**/*")
          → Group by directory
          → Present as tree structure
        output: Directory tree with file types

      - tool: similar-search
        impl: |
          Grep("class|function|export") in target area
          → Extract signatures
          → Find similar signatures elsewhere
        output: List of similar code locations

      - tool: candidate-list
        impl: |
          Combine dir-map + similar-search
          → Generate ranked candidate list
        output: Scored placement candidates

    compare:
      - tool: read-each
        impl: |
          For each candidate:
            Read(candidate_path)
            Extract: naming, structure, patterns
        output: Candidate profile for each

      - tool: fit-score
        impl: |
          Score each candidate:
            - Naming convention match (0-10)
            - Structural similarity (0-10)
            - Domain coherence (0-10)
            - Dependency fit (0-10)
        output: Weighted score per candidate

    evidence:
      - tool: evidence-report
        impl: |
          Template:
            ## Placement Decision
            ### Candidates Surveyed: [list]
            ### Analysis: [for each]
            ### Decision: [chosen + evidence]
            ### Rejections: [why not others]
        output: Structured evidence document
```

### SIGNAL SET Implementation

```yaml
# ~/.claude/plugins/pp-toolsets/signal-set/

signal-set:
  trays:
    detect:
      - tool: ugliness-detect
        impl: |
          Heuristics:
            - Function length > 50 lines
            - Nested depth > 4
            - Parameter count > 5
            - Duplicate code blocks
            - Magic numbers/strings
          → Flag + categorize
        output: Ugliness signals with locations

      - tool: injustice-detect
        impl: |
          Checks:
            - File in wrong directory for its type
            - Class doing work of another domain
            - Utility doing service work
            - Cross-layer dependencies
        output: Misplacement signals

      - tool: signal-summary
        impl: |
          Aggregate all signals
          Priority: Critical > Warning > Info
          Group by: Type, Location, Severity
        output: Signal dashboard

    trace:
      - tool: call-trace
        impl: |
          From target function:
            Grep("functionName\\(")
            → Build call tree up and down
        output: Call graph

      - tool: data-flow
        impl: |
          From variable:
            Track: assignment → usage → mutation
        output: Data flow diagram

    isolate:
      - tool: root-cause
        impl: |
          From signal:
            Apply "5 Whys" pattern
            Trace back to origin
            Identify systemic vs local issue
        output: Root cause + evidence chain
```

### PATTERN SET Implementation

```yaml
# ~/.claude/plugins/pp-toolsets/pattern-set/

pattern-set:
  trays:
    map:
      - tool: arch-map
        impl: |
          Glob("src/**/*")
          → Identify layers (UI, service, data)
          → Map boundaries
          → Document conventions
        output: Architecture diagram + conventions

      - tool: pattern-catalog
        impl: |
          For each code type:
            Find 3+ examples
            Extract common structure
            Document as pattern
        output: Pattern catalog with examples

    match:
      - tool: best-match
        impl: |
          Input: New code requirements
          Process:
            1. Search pattern-catalog
            2. Score each pattern for fit
            3. Return top 3 with reasoning
        output: Ranked pattern matches

      - tool: extract-pattern
        impl: |
          From chosen example:
            Extract: structure, naming, conventions
            Generalize: replace specifics with placeholders
        output: Reusable template

    conform:
      - tool: conform-check
        impl: |
          Compare new code to pattern:
            - Structure match? [Y/N]
            - Naming match? [Y/N]
            - Convention match? [Y/N]
          Flag deviations
        output: Conformance report
```

---

## Part 12: Toolset Selection Protocol

### Quick Selection Guide

```
┌─────────────────────────────────────────────────────────────────────────┐
│                     TOOLSET SELECTION PROTOCOL                           │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  QUESTION 1: What's the primary need?                                   │
│  ─────────────────────────────────────────────────────────────────      │
│                                                                          │
│  "Where should this go?"        → PLACEMENT SET (Red)                   │
│  "Something's wrong here"       → SIGNAL SET (Yellow)                   │
│  "How do I write this?"         → PATTERN SET (Blue)                    │
│                                                                          │
│  ─────────────────────────────────────────────────────────────────      │
│                                                                          │
│  QUESTION 2: What's the task complexity?                                │
│  ─────────────────────────────────────────────────────────────────      │
│                                                                          │
│  Quick fix (1/4" drive)   → Single tool from one tray                   │
│  Standard work (3/8")     → Full tray sequence                          │
│  Deep work (1/2")         → Cross-toolset workflow                      │
│                                                                          │
│  ─────────────────────────────────────────────────────────────────      │
│                                                                          │
│  QUESTION 3: Is the territory charted?                                  │
│  ─────────────────────────────────────────────────────────────────      │
│                                                                          │
│  Yes, pattern exists      → PATTERN.match → PLACEMENT.evidence          │
│  No, building new         → FOUNDATION.creative + All sets              │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

### Task → Toolset Mapping

| Task Type | Primary Set | Supporting Set | Workflow |
|-----------|-------------|----------------|----------|
| New feature | PATTERN | PLACEMENT | Map→Match→Survey→Evidence→Conform |
| Bug fix | SIGNAL | PATTERN | Detect→Trace→Isolate→Match→Verify |
| Refactor | PATTERN | SIGNAL + PLACEMENT | Map→Detect→Survey→Extract→Conform |
| Code review | SIGNAL | PLACEMENT | Detect→Verify→Summary |
| Architecture | PATTERN | PLACEMENT | Map→Catalog→Survey→Evidence |
| Quick fix | SIGNAL | - | Detect→Fix→Verify |

---

## Part 13: Future Tool Development Roadmap

### Phase 1: Core Tools (Implement First)

| Tool | Set | Priority | Complexity |
|------|-----|----------|------------|
| `evidence-report` | PLACEMENT | HIGH | Medium |
| `signal-summary` | SIGNAL | HIGH | Low |
| `pattern-catalog` | PATTERN | HIGH | High |
| `fit-score` | PLACEMENT | MEDIUM | Medium |
| `root-cause` | SIGNAL | MEDIUM | High |

### Phase 2: Integration Tools

| Tool | Set | Priority | Complexity |
|------|-----|----------|------------|
| `workflow-orchestrator` | CROSS | HIGH | High |
| `tool-selector` | CROSS | MEDIUM | Medium |
| `context-manager` | FOUNDATION | HIGH | High |

### Phase 3: Advanced Tools

| Tool | Set | Priority | Complexity |
|------|-----|----------|------------|
| `pattern-learner` | PATTERN | LOW | Very High |
| `signal-predictor` | SIGNAL | LOW | Very High |
| `placement-advisor` | PLACEMENT | LOW | High |

---

## Sources

- [Socket Set Organization Guide](https://industrialpicks.com/socket-set-questions-answered-everything-you-need-to-know-2025-guide/)
- [Mechanic Tool Kit Organization](https://tendsupplies.com/blog/-how-to-organize-your-mechanic-tool-kit/)
- [Surgical Tray Rationalization Research](https://bmchealthservres.biomedcentral.com/articles/10.1186/s12913-021-06142-8)
- [Surgical Ergonomics - Multi-tier Tables](https://www.sciencedirect.com/science/article/abs/pii/S000368702200151X)
- [Modular Tool Systems Design](https://www.ifm.eng.cam.ac.uk/research/ifm-review/issue-3/management-tools-and-toolkits/)
- [Milwaukee PACKOUT System](https://www.farmstandapp.com/65621/how-to-design-a-tool-organization-system-that-grows/)
