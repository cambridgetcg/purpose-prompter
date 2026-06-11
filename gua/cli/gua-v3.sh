#!/bin/bash
# GUA v3 - Global Understanding Archive (Slim)
# 20 commands. Same AWS tables. No bloat.
#
# Commands:
#   gua load                     Load active set (patterns + blindspots)
#   gua save                     Upload LIGHT.md + entity to AWS
#   gua status                   Show sync status
#   gua add "<text>" [dim] [type] Add knowledge (replaces insight/research/eureka)
#   gua search "<query>" [limit]  Search knowledge index
#   gua list [limit]             List recent knowledge
#   gua path status              Show path dashboard
#   gua path init [project]      Initialize path for project
#   gua path waypoint add <name> Add waypoint
#   gua path waypoint list       List waypoints
#   gua mastery status           Show current mastery level
#   gua mastery assess           Compute and persist mastery level
#   gua mastery history          Show mastery progression over time
#   gua thread start <name>      Start work thread
#   gua thread resume <id>       Resume thread
#   gua thread list              List threads
#   gua moment "<text>"          Capture moment in current thread
#   gua reflect                  Digest PP reflections into trends + blindspot candidates
#   gua distill                  Cluster reflections into transmutation candidates
#   gua seer "<url>"             Fetch blocked web content (delegates to seer.sh)

set -e

GUA_DIR="$HOME/.gua"
CONFIG_FILE="$GUA_DIR/config.json"
STATE_FILE="$GUA_DIR/state.json"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# --- Core ---

load_config() {
    [[ ! -f "$CONFIG_FILE" ]] && echo -e "${RED}GUA not configured. Run setup.sh${NC}" && exit 1
    USER_ID=$(jq -r '.user_id' "$CONFIG_FILE")
    REGION=$(jq -r '.region' "$CONFIG_FILE")
    S3_BUCKET=$(jq -r '.s3_bucket' "$CONFIG_FILE")
    DEVICE_ID=$(jq -r '.device_id // "default"' "$CONFIG_FILE")
}

ts() { date -u +"%Y-%m-%dT%H:%M:%SZ"; }
uuid() { uuidgen | tr '[:upper:]' '[:lower:]'; }

update_state() {
    local key="$1" val="$2"
    jq --arg v "$val" ".$key = \$v" "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
}

# --- Load ---

cmd_load() {
    load_config
    echo -e "${BLUE}[GUA] Loading active set...${NC}"

    local light_dir="$HOME/.claude/purpose_prompter/integration"
    mkdir -p "$light_dir" "$GUA_DIR/entity"

    # Download entity
    aws s3 cp "s3://$S3_BUCKET/entity/PARTNER.md" "$GUA_DIR/entity/PARTNER.md" --region "$REGION" 2>/dev/null || true

    # Fetch ALL knowledge in one scan (139 items is small enough)
    local tmp_items="/tmp/gua-load-items.json"
    aws dynamodb scan \
        --table-name "gua-knowledge-index" \
        --filter-expression "user_id = :uid" \
        --expression-attribute-values "{\":uid\": {\"S\": \"$USER_ID\"}}" \
        --region "$REGION" 2>/dev/null | jq -c '.Items // []' > "$tmp_items"

    # Generate LIGHT.md via python (jq too limited for this)
    # Detect mastery.json from current project dir
    local mastery_file="$(pwd)/.gua/mastery.json"

    # Detect reflections log from current project dir
    local reflections_file="$(pwd)/.gua/reflections/log.jsonl"

    python3 - "$tmp_items" "$light_dir/LIGHT.md" "$mastery_file" "$reflections_file" << 'PYEOF'
import json, sys, re, os
from collections import defaultdict, Counter

with open(sys.argv[1]) as f:
    items = json.load(f)
out_path = sys.argv[2]
mastery_path = sys.argv[3] if len(sys.argv) > 3 else None
reflections_path = sys.argv[4] if len(sys.argv) > 4 else None

def s(item, field):
    return item.get(field, {}).get('S', '')

# Project detection by keyword
PROJECT_KEYWORDS = {
    'axiepro': 'AxiePro',
    'axie': 'AxiePro',
    'hedonic': 'AxiePro',
    'moneymaker': 'MoneyMaker',
    'cardforum': 'CardForum',
    'cardmarket': 'CardForum',
    'missav': 'missAV',
    'cloudscraper': 'missAV',
    'hls segments': 'missAV',
    'app runner': 'AxiePro',
    'moralis': 'AxiePro',
    'copyrights.routes': 'MoneyMaker',
    'licenses.routes': 'MoneyMaker',
    'trade secrets': 'MoneyMaker',
    'domain names table': 'MoneyMaker',
    'enforcement domain': 'MoneyMaker',
    'patent family': 'MoneyMaker',
    'pct workflow': 'MoneyMaker',
    'maintenance fee': 'MoneyMaker',
    'bank csv': 'MoneyMaker',
    'exchange rate': 'MoneyMaker',
    'stripe': 'MoneyMaker',
    'cors fix': 'AxiePro',
    'wp4 copyrights': 'MoneyMaker',
    'fastify server': 'MoneyMaker',
    'drizzle orm': 'MoneyMaker',
    'backbone is sequential': 'AxiePro',
}

def detect_project(text, item):
    """Detect project from text content or project field."""
    proj = s(item, 'project')
    if proj and proj != 'purpose_prompter':
        return proj
    text_lower = text.lower()
    for kw, proj_name in PROJECT_KEYWORDS.items():
        if kw in text_lower:
            return proj_name
    return None

# Categorize
blindspots = []
by_dim = defaultdict(list)
anti_patterns = []
techniques = []
projects = defaultdict(list)
pp_philosophy = []  # PP-specific insights (hierarchy, signals, virtues)

for item in items:
    kt = s(item, 'knowledge_type')
    dim = s(item, 'pp_dimension')
    text = s(item, 'name') or s(item, 'summary') or s(item, 'content')
    if not text or not text.strip():
        continue
    text = text.strip()[:200]

    entry = {'text': text, 'type': kt, 'dim': dim}

    # Route to category
    if kt == 'blindspot':
        blindspots.append(entry)
    elif kt == 'anti-pattern':
        anti_patterns.append(entry)
    else:
        proj = detect_project(text, item)
        if proj:
            projects[proj].append(entry)
        elif kt == 'technique':
            techniques.append(entry)
        elif kt in ('model', 'principle') or any(kw in text.lower() for kw in
            ['hierarchy', 'signal system', 'longing', 'creative cycle', 'virtue',
             'beauty emerges', 'ugliness', 'injustice', 'stagnation', 'pp ']):
            pp_philosophy.append(entry)
        else:
            by_dim[dim].append(entry)

# Write LIGHT.md
lines = []
lines.append('# LIGHT - Cross-Session Knowledge')
lines.append('')

# 1. Blindspots (most actionable)
if blindspots:
    lines.append('## BLINDSPOTS')
    lines.append('')
    for b in blindspots:
        lines.append(f'- **{b["text"]}**')
    lines.append('')

# 1b. Reflection Trends (from PP runs)
if reflections_path and os.path.exists(reflections_path):
    refls = []
    for line in open(reflections_path):
        line = line.strip()
        if not line:
            continue
        try:
            refls.append(json.loads(line))
        except json.JSONDecodeError:
            continue
    if refls:
        rn = len(refls)
        gate_fails = Counter()
        virtue_tens = Counter()
        sig_pats = Counter()
        improvements = []
        recent = refls[-5:] if len(refls) >= 5 else refls
        recent_complete = sum(1 for r in recent if r.get('assessment', {}).get('overall') == 'COMPLETE')

        for r in refls:
            a = r.get('assessment', {})
            for g in a.get('failed_gates', []):
                gate_fails[g] += 1
            for sig in a.get('signals', []):
                kind = sig.split(':')[0].strip().lower()
                sig_pats[kind] += 1
            v = r.get('virtues', {})
            for t in v.get('tensions', []):
                name = t.split(':')[0].strip().lower()
                virtue_tens[name] += 1
            imp = r.get('improvement_for_pp')
            if imp:
                improvements.append(imp)

        lines.append('## Reflection Trends')
        lines.append(f'*{rn} PP runs analyzed*')
        if gate_fails:
            lines.append(f'**Recurring gate failures**: ' + ', '.join(f'{g} ({c}x)' for g, c in gate_fails.most_common(5)))
        if virtue_tens:
            lines.append(f'**Virtue tensions**: ' + ', '.join(f'{v} ({c}x)' for v, c in virtue_tens.most_common(5)))
        if sig_pats:
            lines.append(f'**Signal patterns**: ' + ', '.join(f'{s} ({c}x)' for s, c in sig_pats.most_common()))
        lines.append(f'**Recent completion**: {recent_complete}/{len(recent)} last runs COMPLETE')
        lines.append('')

        # Self-improvement queue (recursive hook)
        if len(improvements) >= 3:
            lines.append('## PP Self-Improvement Queue')
            lines.append('PP has accumulated self-observations. Consider: `/pp "address PP self-improvement queue"`')
            for imp in improvements[-5:]:
                lines.append(f'- {imp}')
            lines.append('')

# 1c. Athanor (transmutation candidates)
athanor_dir = os.path.join(os.path.expanduser('~'), '.gua', 'athanor')
if os.path.exists(athanor_dir):
    stage_labels = {'NIGREDO': 'RAW', 'ALBEDO': 'PURE', 'CITRINITAS': 'GOLD', 'RUBEDO': 'STONE', 'INTEGRATED': 'LIVE'}
    candidates = []
    for fname in os.listdir(athanor_dir):
        if not fname.endswith('.json'):
            continue
        try:
            with open(os.path.join(athanor_dir, fname)) as af:
                cand = json.load(af)
            if cand.get('stage') not in ('DISSOLVED',):
                candidates.append(cand)
        except (json.JSONDecodeError, KeyError):
            continue
    if candidates:
        candidates.sort(key=lambda c: c.get('heat', 0), reverse=True)
        lines.append('## Athanor (Transmutation Candidates)')
        lines.append('')
        ready_ids = []
        for c in candidates:
            stage = c.get('stage', 'NIGREDO')
            label = stage_labels.get(stage, 'RAW')
            heat = c.get('heat', 0)
            title = c.get('title', c.get('name', 'unknown'))
            lines.append(f'- **[{label}]** {title} (heat: {heat})')
            if (stage == 'NIGREDO' and heat >= 5) or (stage == 'ALBEDO' and heat >= 7):
                ready_ids.append(c.get('id', ''))
        if ready_ids:
            lines.append(f'**Ready for transmutation**: `/transmute {ready_ids[0]}`')
        lines.append('')

# 2. Anti-patterns
if anti_patterns:
    lines.append('## Anti-Patterns')
    lines.append('')
    for a in anti_patterns:
        lines.append(f'- {a["text"]}')
    lines.append('')

# 3. PP Philosophy (the deep stuff)
if pp_philosophy:
    lines.append(f'## PP Insights ({len(pp_philosophy)})')
    lines.append('')
    for e in pp_philosophy[:10]:
        lines.append(f'- {e["text"]}')
    if len(pp_philosophy) > 10:
        lines.append(f'- ... and {len(pp_philosophy) - 10} more')
    lines.append('')

# 4. Knowledge by dimension (non-PP, non-project)
dim_order = ['truth', 'understanding', 'beauty', 'justice', 'creativity']
dim_labels = {'truth': 'Truth', 'understanding': 'Understanding', 'beauty': 'Beauty', 'justice': 'Justice', 'creativity': 'Creativity'}

has_dim_content = any(by_dim.get(d) for d in dim_order)
if has_dim_content:
    lines.append('## Knowledge')
    lines.append('')
    for dim in dim_order:
        entries = by_dim.get(dim, [])
        if not entries:
            continue
        lines.append(f'### {dim_labels[dim]} ({len(entries)})')
        shown = 0
        for e in entries:
            if shown >= 5:
                lines.append(f'- ... and {len(entries) - shown} more')
                break
            lines.append(f'- {e["text"]}')
            shown += 1
        lines.append('')

# 5. Techniques
if techniques:
    lines.append(f'## Techniques ({len(techniques)})')
    lines.append('')
    for t in techniques[:6]:
        lines.append(f'- {t["text"]}')
    if len(techniques) > 6:
        lines.append(f'- ... and {len(techniques) - 6} more')
    lines.append('')

# 6. Projects
if projects:
    lines.append('## Projects')
    lines.append('')
    for proj, entries in sorted(projects.items()):
        lines.append(f'### {proj} ({len(entries)})')
        for e in entries[:3]:
            lines.append(f'- {e["text"]}')
        if len(entries) > 3:
            lines.append(f'- ... and {len(entries) - 3} more')
        lines.append('')

# 7. Mastery (if mastery.json exists)
if mastery_path:
    import os
    if os.path.exists(mastery_path):
        try:
            with open(mastery_path) as mf:
                mastery = json.load(mf)
            names = {0: 'Seed', 1: 'Apprentice', 2: 'Practitioner', 3: 'Craftsman', 4: 'Master'}
            overall = mastery.get('overall', 'L0')
            level_num = int(overall[1]) if len(overall) == 2 else 0
            level_name = names.get(level_num, 'Unknown')
            dims = mastery.get('dimensions', {})
            dim_parts = []
            for d in ['truth', 'understanding', 'beauty', 'justice', 'creativity']:
                dl = dims.get(d, {}).get('level', 'L0')
                dim_parts.append(f'{d.title()}: {dl}')
            next_t = mastery.get('next_threshold', '')
            lines.append(f'## Mastery: {overall} {level_name}')
            lines.append(f'{" | ".join(dim_parts)}')
            if next_t:
                lines.append(f'Next: {next_t}')
            lines.append('')
        except (json.JSONDecodeError, KeyError):
            pass

# Footer
total = len(items)
lines.append('---')
lines.append(f'*{total} items | `gua search "<query>"` for details*')

with open(out_path, 'w') as f:
    f.write('\n'.join(lines))

print(f'{total}|{len(blindspots)}')
PYEOF

    local total=$(python3 -c "import json; print(len(json.load(open('$tmp_items'))))")
    local bc=$(python3 -c "import json; print(sum(1 for i in json.load(open('$tmp_items')) if i.get('knowledge_type',{}).get('S','')=='blindspot'))")
    rm -f "$tmp_items"

    update_state "last_load" "$(ts)"
    echo -e "${GREEN}[GUA] Loaded: $total items, $bc blindspots${NC}"
}

# --- Save ---

cmd_save() {
    load_config
    echo -e "${BLUE}[GUA] Saving to AWS...${NC}"

    local light="$HOME/.claude/purpose_prompter/integration/LIGHT.md"
    [[ -f "$light" ]] && aws s3 cp "$light" "s3://$S3_BUCKET/documents/LIGHT.md" --region "$REGION" && echo "  LIGHT.md uploaded"

    local entity="$GUA_DIR/entity/PARTNER.md"
    [[ -f "$entity" ]] && aws s3 cp "$entity" "s3://$S3_BUCKET/entity/PARTNER.md" --region "$REGION" && echo "  PARTNER.md uploaded"

    # Upload moments if any exist and thread is active
    local moments="$GUA_DIR/moments/current.jsonl"
    local thread_id=$(jq -r '.current_thread // ""' "$STATE_FILE")
    if [[ -f "$moments" && -n "$thread_id" ]]; then
        aws s3 cp "$moments" "s3://$S3_BUCKET/threads/${thread_id}/moments.jsonl" --region "$REGION" 2>/dev/null && echo "  Moments uploaded"
    fi

    update_state "last_save" "$(ts)"
    echo -e "${GREEN}[GUA] Save complete${NC}"
}

# --- Status ---

cmd_status() {
    [[ ! -f "$STATE_FILE" ]] && echo "No state file" && return
    echo -e "${BLUE}[GUA] Status${NC}"
    local ll=$(jq -r '.last_load // "never"' "$STATE_FILE")
    local ls=$(jq -r '.last_save // "never"' "$STATE_FILE")
    local ct=$(jq -r '.current_thread // "none"' "$STATE_FILE")
    echo "  Last load: $ll"
    echo "  Last save: $ls"
    echo "  Thread: $ct"
}

# --- Add (unified knowledge capture) ---

cmd_add() {
    local content="$1"
    local dimension="${2:-understanding}"
    local type="${3:-observation}"

    if [[ -z "$content" ]]; then
        echo -e "${RED}Usage: gua add \"<content>\" [dimension] [type]${NC}"
        echo "  Dimensions: truth, understanding, beauty, justice, creativity"
        echo "  Types: observation, pattern, blindspot, hypothesis, anti-pattern"
        echo ""
        echo "  gua add 'Tiered implementation reduces risk' creativity pattern"
        echo "  gua add 'Tendency to skip citations' truth blindspot"
        return 1
    fi

    load_config

    local now=$(ts)
    local id=$(uuid)
    local kid="knowledge-${id}"
    local summary=$(echo "$content" | cut -c1-200)

    # Write to knowledge index (single table, immediately searchable)
    local item_json
    item_json=$(jq -nc \
        --arg uid "$USER_ID" \
        --arg kid "$kid" \
        --arg name "$content" \
        --arg dim "$dimension" \
        --arg kt "$type" \
        --arg now "$now" \
        --arg summary "$summary" \
        '{
            user_id: {S: $uid},
            knowledge_id: {S: $kid},
            name: {S: $name},
            pp_dimension: {S: $dim},
            knowledge_type: {S: $kt},
            confidence: {S: "hypothesis"},
            scope: {S: "global"},
            depth_level: {N: "1"},
            access_count: {N: "0"},
            access_score: {N: "0"},
            last_accessed: {S: "never"},
            created_at: {S: $now},
            s3_key: {S: ""},
            summary: {S: $summary},
            is_active: {BOOL: true}
        }')

    aws dynamodb put-item \
        --table-name "gua-knowledge-index" \
        --item "$item_json" \
        --region "$REGION"

    echo -e "${GREEN}[GUA] Added: [$type] $dimension${NC}"
    echo "  $content"
}

# --- Search ---

cmd_search() {
    local query="" limit=20 dim_filter=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --dim)
                dim_filter="$2"
                case "$dim_filter" in
                    truth|understanding|beauty|justice|creativity) ;;
                    *) echo -e "${RED}Invalid dimension: $dim_filter. Use: truth|understanding|beauty|justice|creativity${NC}" && return 1 ;;
                esac
                shift 2 ;;
            *)
                if [[ -z "$query" ]]; then query="$1"; else limit="$1"; fi
                shift ;;
        esac
    done

    [[ -z "$query" ]] && echo -e "${RED}Usage: gua search \"<query>\" [limit] [--dim <dimension>]${NC}" && return 1

    load_config
    echo -e "${BLUE}[GUA] Searching: $query${dim_filter:+ (dim: $dim_filter)}${NC}"

    local filter_expr="user_id = :uid AND (contains(#n, :q) OR contains(summary, :q))"
    local attr_values
    attr_values=$(jq -nc --arg uid "$USER_ID" --arg q "$query" \
        '{":uid": {S: $uid}, ":q": {S: $q}}')

    if [[ -n "$dim_filter" ]]; then
        filter_expr="$filter_expr AND pp_dimension = :dim"
        attr_values=$(jq -nc --arg uid "$USER_ID" --arg q "$query" --arg dim "$dim_filter" \
            '{":uid": {S: $uid}, ":q": {S: $q}, ":dim": {S: $dim}}')
    fi

    local results=$(aws dynamodb scan \
        --table-name "gua-knowledge-index" \
        --filter-expression "$filter_expr" \
        --expression-attribute-names '{"#n": "name"}' \
        --expression-attribute-values "$attr_values" \
        --region "$REGION" 2>/dev/null)

    local count=$(echo "$results" | jq '.Count // 0')
    [[ "$count" == "0" ]] && echo "  No results" && return

    echo "  $count results:"
    echo ""
    echo "$results" | jq -r ".Items[:$limit][] | \"  [\(.knowledge_type.S)] \(.name.S | .[0:70])\n    dim: \(.pp_dimension.S) | access: \(.access_count.N // \"0\") | id: \(.knowledge_id.S)\n\""
}

# --- List ---

cmd_list() {
    local limit="${1:-10}"
    load_config

    echo -e "${BLUE}[GUA] Recent knowledge (limit: $limit)${NC}"
    echo ""

    aws dynamodb scan \
        --table-name "gua-knowledge-index" \
        --filter-expression "user_id = :uid AND knowledge_type <> :sc" \
        --expression-attribute-values "{\":uid\": {\"S\": \"$USER_ID\"}, \":sc\": {\"S\": \"seer_cache\"}}" \
        --region "$REGION" 2>/dev/null \
    | jq -r ".Items | sort_by(.created_at.S) | reverse | .[:$limit][] | \"  [\(.knowledge_type.S)] \(.pp_dimension.S) | \(.name.S | .[0:70])\""
}

# --- Path Protocol ---

cmd_path_init() {
    local project="${1:-$(basename $(pwd))}"
    local path_dir="$(pwd)/.gua/path"
    mkdir -p "$path_dir/waypoints"

    cat > "$path_dir/manifest.json" << EOF
{"version":"1.0.0","project":"$project","createdAt":"$(ts)","updatedAt":"$(ts)","currentWaypoint":null,"waypointCount":0}
EOF

    [[ ! -f "$path_dir/PURPOSE.md" ]] && cat > "$path_dir/PURPOSE.md" << 'EOF'
# Purpose

**Statement**: [One sentence describing the ideal state]

## Success Criteria
1. [ ] [Specific, testable]
2. [ ] [Specific, testable]

## Out of Scope
- [What we are NOT building]
EOF

    echo -e "${GREEN}Path initialized for: $project${NC}"
    echo "  Edit .gua/path/PURPOSE.md, then add waypoints"
}

cmd_path_status() {
    local path_dir="$(pwd)/.gua/path"
    [[ ! -d "$path_dir" ]] && echo -e "${RED}No path. Run: gua path init${NC}" && return 1

    local project=$(jq -r '.project' "$path_dir/manifest.json")
    local current=$(jq -r '.currentWaypoint // "none"' "$path_dir/manifest.json")
    local total=$(jq -r '.waypointCount' "$path_dir/manifest.json")

    echo -e "${BLUE}PATH: $project${NC}"
    echo "  Current: $current | Total: $total waypoints"
    echo ""

    # Count by status
    local completed=0 pending=0 in_progress=0
    if [[ -d "$path_dir/waypoints" ]] && ls "$path_dir/waypoints/"*.json &>/dev/null; then
        completed=$(jq -rs '[.[] | select(.status == "completed")] | length' "$path_dir/waypoints/"*.json 2>/dev/null || echo 0)
        in_progress=$(jq -rs '[.[] | select(.status == "in_progress")] | length' "$path_dir/waypoints/"*.json 2>/dev/null || echo 0)
        pending=$(jq -rs '[.[] | select(.status == "pending")] | length' "$path_dir/waypoints/"*.json 2>/dev/null || echo 0)
    fi

    echo "  Completed: $completed | In progress: $in_progress | Pending: $pending"
    echo ""
    cmd_path_waypoint_list
}

cmd_path_waypoint_add() {
    local name="$1"
    [[ -z "$name" ]] && echo -e "${RED}Usage: gua path waypoint add <name>${NC}" && return 1

    local path_dir="$(pwd)/.gua/path"
    [[ ! -d "$path_dir" ]] && echo -e "${RED}No path. Run: gua path init${NC}" && return 1

    local count=$(jq -r '.waypointCount' "$path_dir/manifest.json")
    local new_count=$((count + 1))
    local wid="W${new_count}"
    local safe=$(echo "$name" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')

    cat > "$path_dir/waypoints/${wid}-${safe}.json" << EOF
{"id":"$wid","name":"$name","status":"pending","impl":0,"depth":"L0","createdAt":"$(ts)","updatedAt":"$(ts)"}
EOF

    cat > "$path_dir/waypoints/${wid}-${safe}.md" << EOF
# $wid: $name

## Success Criteria
1. [ ] [Specific, testable]

## Notes
EOF

    jq --argjson c "$new_count" --arg t "$(ts)" \
        '.waypointCount = $c | .updatedAt = $t | .currentWaypoint = (if .currentWaypoint == null then "W1" else .currentWaypoint end)' \
        "$path_dir/manifest.json" > "$path_dir/manifest.json.tmp" && mv "$path_dir/manifest.json.tmp" "$path_dir/manifest.json"

    echo -e "${GREEN}Waypoint created: $wid - $name${NC}"
}

cmd_path_waypoint_list() {
    local path_dir="$(pwd)/.gua/path"
    [[ ! -d "$path_dir/waypoints" ]] && return

    local current=$(jq -r '.currentWaypoint // "none"' "$path_dir/manifest.json")

    if ! ls "$path_dir/waypoints/"*.json &>/dev/null; then
        echo "  No waypoints. Run: gua path waypoint add <name>"
        return
    fi

    echo "  CURRENT STATE"
    for f in "$path_dir/waypoints/"*.json; do
        local id=$(jq -r '.id' "$f")
        local name=$(jq -r '.name' "$f")
        local status=$(jq -r '.status' "$f")
        local impl=$(jq -r '.impl' "$f")

        local icon="○"
        case "$status" in
            completed) icon="${GREEN}●${NC}" ;;
            in_progress) icon="${YELLOW}◐${NC}" ;;
            blocked) icon="${RED}✕${NC}" ;;
        esac

        local marker=""
        [[ "$id" == "$current" ]] && marker=" ← HERE"

        echo "       │"
        echo -e "    $icon $id: $name ($status ${impl}%)$marker"
    done
    echo "       │"
    echo "    PURPOSE"
}

cmd_path_waypoint_update() {
    local wid="$1"
    [[ -z "$wid" ]] && echo -e "${RED}Usage: gua path waypoint update <id> --status <s> [--impl <n>]${NC}" && return 1

    local path_dir="$(pwd)/.gua/path"
    local json_file=$(ls "$path_dir/waypoints/${wid}-"*.json 2>/dev/null | head -1)
    [[ -z "$json_file" ]] && echo -e "${RED}Waypoint not found: $wid${NC}" && return 1

    shift
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --status)
                jq --arg s "$2" '.status = $s | .updatedAt = "'"$(ts)"'"' "$json_file" > "$json_file.tmp" && mv "$json_file.tmp" "$json_file"
                shift 2 ;;
            --impl)
                jq --argjson i "$2" '.impl = $i | .updatedAt = "'"$(ts)"'"' "$json_file" > "$json_file.tmp" && mv "$json_file.tmp" "$json_file"
                shift 2 ;;
            --current)
                jq --arg w "$wid" '.currentWaypoint = $w' "$path_dir/manifest.json" > "$path_dir/manifest.json.tmp" && mv "$path_dir/manifest.json.tmp" "$path_dir/manifest.json"
                shift ;;
            *) shift ;;
        esac
    done

    echo -e "${GREEN}Updated: $wid${NC}"
}

# --- Threads ---

cmd_thread_start() {
    local name="$1"
    [[ -z "$name" ]] && echo -e "${RED}Usage: gua thread start <name> [--objective \"...\"]${NC}" && return 1

    local objective=""
    shift
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --objective) objective="$2"; shift 2 ;;
            *) shift ;;
        esac
    done

    load_config
    local now=$(ts)
    local date_part=$(date +%Y-%m-%d)
    local tid="${name}-${date_part}"

    local item_json
    item_json=$(jq -nc \
        --arg uid "$USER_ID" \
        --arg tid "$tid" \
        --arg name "$name" \
        --arg obj "${objective:-unspecified}" \
        --arg now "$now" \
        '{
            user_id: {S: $uid},
            thread_id: {S: $tid},
            name: {S: $name},
            status: {S: "active"},
            objective: {S: $obj},
            created_at: {S: $now},
            updated_at: {S: $now},
            session_count: {N: "1"}
        }')

    aws dynamodb put-item \
        --table-name "gua-threads" \
        --item "$item_json" \
        --region "$REGION" 2>/dev/null

    # Create S3 thread dir
    aws s3api put-object --bucket "$S3_BUCKET" --key "threads/${tid}/" --region "$REGION" 2>/dev/null

    update_state "current_thread" "$tid"
    echo -e "${GREEN}Thread started: $tid${NC}"
    [[ -n "$objective" ]] && echo "  Objective: $objective"
}

cmd_thread_resume() {
    local tid="$1"
    [[ -z "$tid" ]] && echo -e "${RED}Usage: gua thread resume <thread-id>${NC}" && return 1

    load_config
    local key_json
    key_json=$(jq -nc --arg uid "$USER_ID" --arg tid "$tid" \
        '{user_id: {S: $uid}, thread_id: {S: $tid}}')
    local val_json
    val_json=$(jq -nc --arg ts "$(ts)" \
        '{":a": {S: "active"}, ":ts": {S: $ts}, ":one": {N: "1"}}')

    aws dynamodb update-item \
        --table-name "gua-threads" \
        --key "$key_json" \
        --update-expression "SET #s = :a, updated_at = :ts, session_count = session_count + :one" \
        --expression-attribute-names '{"#s": "status"}' \
        --expression-attribute-values "$val_json" \
        --region "$REGION" 2>/dev/null

    update_state "current_thread" "$tid"
    echo -e "${GREEN}Resumed: $tid${NC}"
}

cmd_thread_list() {
    load_config
    echo -e "${BLUE}[GUA] Threads${NC}"

    local result=$(aws dynamodb query \
        --table-name "gua-threads" \
        --key-condition-expression "user_id = :uid" \
        --expression-attribute-values "{\":uid\": {\"S\": \"$USER_ID\"}}" \
        --region "$REGION" 2>/dev/null)

    local count=$(echo "$result" | jq '.Items | length')
    [[ "$count" == "0" ]] && echo "  No threads" && return

    local current=$(jq -r '.current_thread // ""' "$STATE_FILE")

    echo "$result" | jq -r '.Items[] | [.thread_id.S, .status.S, .objective.S // "—", .session_count.N] | @tsv' | while IFS=$'\t' read -r tid status obj sessions; do
        local marker=""
        [[ "$tid" == "$current" ]] && marker=" ← active"
        echo -e "  ${BLUE}$tid${NC}$marker"
        echo "    $status | ${sessions}s | ${obj:0:60}"
    done
}

# --- Moment ---

cmd_moment() {
    local content="$1"
    [[ -z "$content" ]] && echo -e "${RED}Usage: gua moment \"<content>\"${NC}" && return 1

    local moments_dir="$GUA_DIR/moments"
    mkdir -p "$moments_dir"

    local thread_id=$(jq -r '.current_thread // ""' "$STATE_FILE")
    jq -nc --arg ts "$(ts)" --arg c "$content" --arg tid "$thread_id" \
        '{timestamp: $ts, content: $c, thread_id: $tid}' >> "$moments_dir/current.jsonl"

    echo -e "${GREEN}Moment captured${NC}"
    echo "  $content"
}

# --- Mastery ---

cmd_mastery_status() {
    local mastery_file="$(pwd)/.gua/mastery.json"
    if [[ ! -f "$mastery_file" ]]; then
        echo -e "${YELLOW}[GUA] No mastery data. Run: gua mastery assess${NC}"
        return
    fi

    local overall=$(jq -r '.overall' "$mastery_file")
    local names=("SEED" "APPRENTICE" "PRACTITIONER" "CRAFTSMAN" "MASTER")
    local level_num=${overall#L}
    local level_name=${names[$level_num]}
    local project=$(jq -r '.project' "$mastery_file")
    local last=$(jq -r '.last_assessed' "$mastery_file")
    local sessions=$(jq -r '.sessions_assessed' "$mastery_file")
    local crystallization=$(jq -r '.crystallization' "$mastery_file")
    local next=$(jq -r '.next_threshold' "$mastery_file")

    echo -e "${BLUE}[MASTERY] $project: $overall $level_name${NC}"
    echo ""

    # Per-dimension levels
    for dim in truth understanding beauty justice creativity; do
        local dlevel=$(jq -r ".dimensions.$dim.level" "$mastery_file")
        local dmarker=$(jq -r ".dimensions.$dim.marker" "$mastery_file")
        local dnum=${dlevel#L}
        local dname=${names[$dnum]}
        printf "  %-14s %s %-13s %s\n" "$dim:" "$dlevel" "$dname" "— $dmarker"
    done

    echo ""
    echo "  Crystallization: $crystallization"
    echo "  Next threshold:  $next"
    echo "  Sessions: $sessions | Last assessed: $last"
}

cmd_mastery_assess() {
    local mastery_file="$(pwd)/.gua/mastery.json"
    local project="${1:-$(basename $(pwd))}"
    mkdir -p "$(pwd)/.gua"

    echo -e "${BLUE}[GUA] Assessing mastery for: $project${NC}"

    # Gather evidence from available sources
    local gate_evidence=""
    local signal_evidence=""
    local knowledge_count=0
    local sessions=0

    # Check existing mastery data
    if [[ -f "$mastery_file" ]]; then
        sessions=$(jq -r '.sessions_assessed // 0' "$mastery_file")
    fi
    sessions=$((sessions + 1))

    # Count knowledge items if GUA is configured
    if [[ -f "$CONFIG_FILE" ]]; then
        load_config
        knowledge_count=$(aws dynamodb scan \
            --table-name "gua-knowledge-index" \
            --filter-expression "user_id = :uid" \
            --expression-attribute-values "{\":uid\": {\"S\": \"$USER_ID\"}}" \
            --select "COUNT" \
            --region "$REGION" 2>/dev/null | jq '.Count // 0')
    fi

    # Check PATH progress
    local path_dir="$(pwd)/.gua/path"
    local waypoint_progress="none"
    if [[ -d "$path_dir/waypoints" ]] && ls "$path_dir/waypoints/"*.json &>/dev/null; then
        local total_wp=$(ls "$path_dir/waypoints/"*.json | wc -l | tr -d ' ')
        local completed_wp=$(jq -rs '[.[] | select(.status == "completed")] | length' "$path_dir/waypoints/"*.json 2>/dev/null || echo 0)
        waypoint_progress="${completed_wp}/${total_wp}"
    fi

    echo "  Knowledge items: $knowledge_count"
    echo "  Sessions assessed: $sessions"
    echo "  Waypoint progress: $waypoint_progress"
    echo ""
    echo -e "${YELLOW}  Mastery levels should be set based on assess agent output.${NC}"
    echo -e "${YELLOW}  Run /pp or /verify on your project for gate-based evidence.${NC}"
    echo ""

    # If no existing file, create initial L0 SEED state
    if [[ ! -f "$mastery_file" ]]; then
        local now=$(ts)
        cat > "$mastery_file" << EOF
{
  "project": "$project",
  "overall": "L0",
  "dimensions": {
    "truth":         { "level": "L0", "marker": "Not yet assessed" },
    "understanding": { "level": "L0", "marker": "Not yet assessed" },
    "beauty":        { "level": "L0", "marker": "Not yet assessed" },
    "justice":       { "level": "L0", "marker": "Not yet assessed" },
    "creativity":    { "level": "L0", "marker": "Not yet assessed" }
  },
  "crystallization": "Not yet assessed",
  "next_threshold": "Run gate assessment to establish baseline",
  "sessions_assessed": $sessions,
  "last_assessed": "$now",
  "history": [
    { "date": "$(date -u +%Y-%m-%d)", "overall": "L0", "note": "Initial assessment" }
  ]
}
EOF
        echo -e "${GREEN}[GUA] Created initial mastery state: L0 SEED${NC}"
    else
        # Update session count and timestamp
        jq --argjson s "$sessions" --arg t "$(ts)" \
            '.sessions_assessed = $s | .last_assessed = $t' \
            "$mastery_file" > "$mastery_file.tmp" && mv "$mastery_file.tmp" "$mastery_file"
        local overall=$(jq -r '.overall' "$mastery_file")
        echo -e "${GREEN}[GUA] Mastery updated: $overall (session $sessions)${NC}"
    fi

    echo ""
    echo "  To update mastery levels based on gate results, edit .gua/mastery.json"
    echo "  or let the assess agent write levels after /pp or /verify."
}

cmd_mastery_history() {
    local mastery_file="$(pwd)/.gua/mastery.json"
    if [[ ! -f "$mastery_file" ]]; then
        echo -e "${YELLOW}[GUA] No mastery data. Run: gua mastery assess${NC}"
        return
    fi

    local project=$(jq -r '.project' "$mastery_file")
    echo -e "${BLUE}[MASTERY] $project — History${NC}"
    echo ""

    local count=$(jq '.history | length' "$mastery_file")
    if [[ "$count" == "0" ]]; then
        echo "  No history entries"
        return
    fi

    local names=("SEED" "APPRENTICE" "PRACTITIONER" "CRAFTSMAN" "MASTER")
    jq -r '.history[] | "\(.date)\t\(.overall)\t\(.note)"' "$mastery_file" | while IFS=$'\t' read -r date level note; do
        local num=${level#L}
        local name=${names[$num]}
        echo -e "  $date  $level $name  — $note"
    done
}

# --- Reflect ---

cmd_reflect() {
    local log_file="$(pwd)/.gua/reflections/log.jsonl"

    if [[ ! -f "$log_file" ]] || [[ ! -s "$log_file" ]]; then
        echo -e "${YELLOW}[GUA] No reflections yet. Run /pp to generate reflections.${NC}"
        return
    fi

    local count=$(wc -l < "$log_file" | tr -d ' ')
    echo -e "${BLUE}[GUA] Analyzing $count reflections...${NC}"
    echo ""

    python3 - "$log_file" << 'PYEOF'
import json, sys
from collections import Counter, defaultdict

log_path = sys.argv[1]
reflections = []
for line in open(log_path):
    line = line.strip()
    if not line:
        continue
    try:
        reflections.append(json.loads(line))
    except json.JSONDecodeError:
        continue

if not reflections:
    print("  No valid reflections found.")
    sys.exit(0)

n = len(reflections)

# Completion rate
outcomes = Counter(r.get('assessment', {}).get('overall', 'UNKNOWN') for r in reflections)
recent = reflections[-5:] if len(reflections) >= 5 else reflections
recent_complete = sum(1 for r in recent if r.get('assessment', {}).get('overall') == 'COMPLETE')

# Gate failures
gate_failures = Counter()
for r in reflections:
    for g in r.get('assessment', {}).get('failed_gates', []):
        gate_failures[g] += 1

# Signal patterns
signal_counter = Counter()
for r in reflections:
    for sig in r.get('assessment', {}).get('signals', []):
        kind = sig.split(':')[0].strip().lower()
        signal_counter[kind] += 1

# Virtue observations
virtue_observed = Counter()
virtue_tensions = Counter()
for r in reflections:
    v = r.get('virtues', {})
    for obs in v.get('observed', []):
        name = obs.split(':')[0].strip().lower()
        virtue_observed[name] += 1
    for tens in v.get('tensions', []):
        name = tens.split(':')[0].strip().lower()
        virtue_tensions[name] += 1

# Territory/risk distribution
territories = Counter(r.get('territory', 'UNKNOWN') for r in reflections)
risks = Counter(r.get('risk', 'UNKNOWN') for r in reflections)

# Print report
print(f"  REFLECTION DIGEST ({n} runs)")
print(f"  {'='*40}")
print()

print(f"  Completion: {outcomes.get('COMPLETE', 0)}/{n} COMPLETE, "
      f"{outcomes.get('PARTIAL', 0)} PARTIAL, {outcomes.get('FAILED', 0)} FAILED")
print(f"  Recent (last 5): {recent_complete}/{len(recent)} COMPLETE")
print()

if gate_failures:
    print("  Recurring gate failures:")
    for gate, count in gate_failures.most_common(5):
        marker = " ← BLINDSPOT CANDIDATE" if count >= 3 else ""
        print(f"    {gate}: {count}x{marker}")
    print()

if signal_counter:
    print("  Signal patterns:")
    for sig, count in signal_counter.most_common():
        print(f"    {sig}: {count}x")
    print()

if virtue_observed or virtue_tensions:
    print("  Virtue profile:")
    if virtue_observed:
        print("    Strengths: " + ", ".join(f"{v} ({c}x)" for v, c in virtue_observed.most_common(5)))
    if virtue_tensions:
        print("    Tensions:  " + ", ".join(f"{v} ({c}x)" for v, c in virtue_tensions.most_common(5)))
    print()

print(f"  Territory: " + ", ".join(f"{t} ({c})" for t, c in territories.most_common()))
print(f"  Risk:      " + ", ".join(f"{r} ({c})" for r, c in risks.most_common()))
print()

# Improvement suggestions
improvements = [r.get('improvement_for_pp') for r in reflections if r.get('improvement_for_pp')]
if improvements:
    print(f"  PP self-improvement suggestions ({len(improvements)}):")
    for imp in improvements[-5:]:
        print(f"    - {imp}")
    print()

# Key insights
insights = [r.get('key_insight') for r in reflections if r.get('key_insight')]
if insights:
    print(f"  Recent insights:")
    for ins in insights[-3:]:
        print(f"    - {ins}")
    print()

# Auto-add blindspot candidates
blindspot_candidates = [g for g, c in gate_failures.items() if c >= 3]
tension_candidates = [v for v, c in virtue_tensions.items() if c >= 3]

if blindspot_candidates or tension_candidates:
    print("  AUTO-CAPTURE CANDIDATES:")
    if blindspot_candidates:
        print(f"    Gate failures (3+): {', '.join(blindspot_candidates)} → run: gua add \"Recurring {g} failures\" truth blindspot")
    if tension_candidates:
        print(f"    Virtue tensions (3+): {', '.join(tension_candidates)} → run: gua add \"{v}-deficiency pattern\" understanding pattern")
PYEOF
}

# --- Distill (Alchemy) ---

cmd_distill() {
    local global_file="$GUA_DIR/reflections/pp-improvements.jsonl"
    local athanor_dir="$GUA_DIR/athanor"

    if [[ ! -f "$global_file" ]] || [[ ! -s "$global_file" ]]; then
        echo -e "${YELLOW}[GUA] No PP improvements to distill. Run /pp on any project to generate.${NC}"
        return
    fi

    mkdir -p "$athanor_dir"

    local count=$(wc -l < "$global_file" | tr -d ' ')
    echo -e "${BLUE}[GUA] Distilling $count PP improvements (cross-project)...${NC}"
    echo ""

    python3 - "$global_file" "$athanor_dir" << 'PYEOF'
import json, sys, os, re, uuid
from collections import defaultdict
from datetime import datetime, timezone

log_path = sys.argv[1]
athanor_dir = sys.argv[2]

# Read global PP improvements (slim records from all projects)
records = []
for line in open(log_path):
    line = line.strip()
    if not line:
        continue
    try:
        records.append(json.loads(line))
    except json.JSONDecodeError:
        continue

# Extract improvement suggestions
improvements = []
for r in records:
    imp = r.get('improvement_for_pp')
    if imp:
        improvements.append({
            'text': imp,
            'id': r.get('timestamp', ''),
            'project': r.get('project', ''),
            'failed_gates': r.get('failed_gates', []),
            'signals': r.get('signals', []),
            'tensions': r.get('virtue_tensions', [])
        })

if not improvements:
    print("  No improvement suggestions found in reflections.")
    sys.exit(0)

print(f"  Found {len(improvements)} improvement suggestions")

# Stopwords for clustering
STOPWORDS = {'the', 'and', 'for', 'that', 'this', 'with', 'from', 'should', 'could',
             'would', 'have', 'been', 'into', 'when', 'more', 'also', 'need', 'needs',
             'before', 'after', 'instead', 'rather', 'than', 'about', 'each', 'make',
             'like', 'just', 'does', 'will', 'only', 'some', 'very', 'then', 'other'}

def tokenize(text):
    """Extract significant words (4+ chars, not stopwords)."""
    words = set(re.findall(r'[a-z]{4,}', text.lower()))
    return words - STOPWORDS

def jaccard(a, b):
    """Jaccard similarity between two word sets."""
    if not a or not b:
        return 0.0
    return len(a & b) / len(a | b)

# Cluster by keyword overlap
# Primary: 40% Jaccard (connected-component)
# Secondary: 3+ shared significant words (semantic bridge for related but lexically distinct items)
tokens = [tokenize(imp['text']) for imp in improvements]
clusters = []  # list of lists of indices
assigned = set()

for i in range(len(improvements)):
    if i in assigned:
        continue
    cluster = [i]
    cluster_tokens = [tokens[i]]
    assigned.add(i)
    # Connected-component: match against ANY cluster member
    changed = True
    while changed:
        changed = False
        for j in range(len(improvements)):
            if j in assigned:
                continue
            # Primary: Jaccard >= 0.4
            if any(jaccard(ct, tokens[j]) >= 0.4 for ct in cluster_tokens):
                cluster.append(j)
                cluster_tokens.append(tokens[j])
                assigned.add(j)
                changed = True
            # Secondary: 3+ shared words with ANY member (semantic bridge)
            elif any(len(ct & tokens[j]) >= 3 for ct in cluster_tokens):
                cluster.append(j)
                cluster_tokens.append(tokens[j])
                assigned.add(j)
                changed = True
    clusters.append(cluster)

# Timestamps (defined early — used in heat decay and candidate creation)
now = datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')
today = datetime.now(timezone.utc).strftime('%Y-%m-%d')

# Load existing candidates (with heat decay: -1 per idle month)
existing = {}
if os.path.exists(athanor_dir):
    for fname in os.listdir(athanor_dir):
        if fname.endswith('.json'):
            try:
                with open(os.path.join(athanor_dir, fname)) as f:
                    cand = json.load(f)
                # Heat decay: reduce by 1 per month of inactivity
                last_update = cand.get('updated_at', now)
                try:
                    lu = datetime.fromisoformat(last_update.replace('Z', '+00:00'))
                    months_idle = (datetime.now(timezone.utc) - lu).days / 30
                    if months_idle > 1 and cand.get('stage') not in ('INTEGRATED', 'DISSOLVED'):
                        decay = int(months_idle)
                        cand['heat'] = max(0, cand.get('heat', 0) - decay)
                except (ValueError, TypeError):
                    pass
                existing[cand['id']] = cand
            except (json.JSONDecodeError, KeyError):
                continue

# Match clusters to existing candidates by keyword overlap
def candidate_tokens(cand):
    """Extract tokens from candidate's improvement suggestions."""
    words = set()
    for s in cand.get('prima_materia', {}).get('improvement_suggestions', []):
        words |= tokenize(s)
    words |= tokenize(cand.get('title', ''))
    return words

updated_ids = []
created_ids = []

for cluster in clusters:
    cluster_texts = [improvements[i]['text'] for i in cluster]
    cluster_tokens = set()
    for i in cluster:
        cluster_tokens |= tokens[i]

    # Collect evidence
    cluster_gates = defaultdict(int)
    cluster_signals = defaultdict(int)
    cluster_tensions = defaultdict(int)
    cluster_refl_ids = []
    for i in cluster:
        imp = improvements[i]
        cluster_refl_ids.append(imp['id'])
        for g in imp['failed_gates']:
            cluster_gates[g] += 1
        for sig in imp['signals']:
            kind = sig.split(':')[0].strip().lower()
            cluster_signals[kind] += 1
        for t in imp['tensions']:
            name = t.split(':')[0].strip().lower()
            cluster_tensions[name] += 1

    # Try to match existing candidate
    matched = None
    best_sim = 0.0
    for cid, cand in existing.items():
        if cand.get('stage') in ('DISSOLVED', 'INTEGRATED'):
            continue
        ct = candidate_tokens(cand)
        sim = jaccard(cluster_tokens, ct)
        if sim >= 0.3 and sim > best_sim:
            matched = cand
            best_sim = sim

    if matched:
        # Update existing candidate with new evidence
        mid = matched['id']
        pm = matched.get('prima_materia', {})
        existing_suggestions = pm.get('improvement_suggestions', [])
        new_suggestions = [t for t in cluster_texts if t not in existing_suggestions]
        if new_suggestions:
            pm['improvement_suggestions'] = existing_suggestions + new_suggestions
            pm['reflections'] = list(set(pm.get('reflections', []) + [r for r in cluster_refl_ids if r]))
            for g, c in cluster_gates.items():
                pm.setdefault('failed_gates', {})[g] = pm.get('failed_gates', {}).get(g, 0) + c
            for s, c in cluster_signals.items():
                pm.setdefault('signals', {})[s] = pm.get('signals', {}).get(s, 0) + c
            for t, c in cluster_tensions.items():
                pm.setdefault('virtue_tensions', {})[t] = pm.get('virtue_tensions', {}).get(t, 0) + c
            matched['prima_materia'] = pm
            matched['heat'] = matched.get('heat', 0) + len(new_suggestions)
            matched['updated_at'] = now
            # Write back
            fpath = os.path.join(athanor_dir, f"{mid}.json")
            with open(fpath, 'w') as f:
                json.dump(matched, f, indent=2)
            updated_ids.append(mid)
            print(f"  Updated: {mid} (heat: {matched['heat']})")
    elif len(cluster) >= 3:
        # Create new NIGREDO candidate
        short_id = str(uuid.uuid4())[:8]
        cid = f"athanor-{short_id}"
        # Generate name slug from common tokens
        common = sorted(cluster_tokens, key=lambda w: sum(1 for i in cluster if w in tokens[i]), reverse=True)
        slug = '-'.join(common[:3]) if common else 'unknown'
        title = cluster_texts[0][:80]

        candidate = {
            "id": cid,
            "name": slug,
            "title": title,
            "stage": "NIGREDO",
            "created_at": now,
            "updated_at": now,
            "heat": len(cluster),
            "prima_materia": {
                "reflections": [r for r in cluster_refl_ids if r],
                "improvement_suggestions": cluster_texts,
                "failed_gates": dict(cluster_gates),
                "signals": dict(cluster_signals),
                "virtue_tensions": dict(cluster_tensions),
                "evidence_summary": {
                    "theme": slug.replace('-', ' '),
                    "cluster_size": len(cluster),
                    "first_seen": now
                }
            },
            "nigredo": None,
            "albedo": None,
            "citrinitas": None,
            "rubedo": None,
            "history": [
                {"stage": "NIGREDO", "date": today, "note": f"Created from {len(cluster)} clustered suggestions"}
            ]
        }

        fpath = os.path.join(athanor_dir, f"{cid}.json")
        with open(fpath, 'w') as f:
            json.dump(candidate, f, indent=2)
        created_ids.append(cid)
        print(f"  Created: {cid} \"{title}\" (heat: {len(cluster)})")

# Summary
print()
total = len([f for f in os.listdir(athanor_dir) if f.endswith('.json')])
ready = 0
for fname in os.listdir(athanor_dir):
    if not fname.endswith('.json'):
        continue
    try:
        with open(os.path.join(athanor_dir, fname)) as f:
            c = json.load(f)
        stage = c.get('stage', '')
        heat = c.get('heat', 0)
        if (stage == 'NIGREDO' and heat >= 5) or (stage == 'ALBEDO' and heat >= 7):
            ready += 1
    except (json.JSONDecodeError, KeyError):
        continue

print(f"  Athanor: {total} candidates, {ready} ready for transmutation")
if updated_ids:
    print(f"  Updated: {', '.join(updated_ids)}")
if created_ids:
    print(f"  Created: {', '.join(created_ids)}")
PYEOF
}

# --- Seer ---

cmd_seer() {
    local seer_script="$GUA_DIR/seer.sh"
    [[ ! -f "$seer_script" ]] && echo -e "${RED}seer.sh not found. Run: aws s3 cp s3://gua-knowledge-store-yu/modules/seer.sh ~/.gua/seer.sh${NC}" && return 1
    "$seer_script" "$@"
}

# --- Router ---

case "${1:-help}" in
    load)       cmd_load ;;
    save)       cmd_save ;;
    status)     cmd_status ;;
    add)        shift; cmd_add "$@" ;;
    search)     shift; cmd_search "$@" ;;
    list)       shift; cmd_list "$@" ;;
    path)
        case "${2:-status}" in
            init)       shift 2; cmd_path_init "$@" ;;
            status)     cmd_path_status ;;
            waypoint)
                case "${3:-list}" in
                    add)    shift 3; cmd_path_waypoint_add "$@" ;;
                    list)   cmd_path_waypoint_list ;;
                    update) shift 3; cmd_path_waypoint_update "$@" ;;
                    *)      echo "Usage: gua path waypoint {add|list|update}" ;;
                esac ;;
            *)          cmd_path_status ;;
        esac ;;
    thread)
        case "${2:-list}" in
            start)  shift 2; cmd_thread_start "$@" ;;
            resume) shift 2; cmd_thread_resume "$@" ;;
            list)   cmd_thread_list ;;
            *)      echo "Usage: gua thread {start|resume|list}" ;;
        esac ;;
    moment)     shift; cmd_moment "$@" ;;
    mastery)
        case "${2:-status}" in
            status)     cmd_mastery_status ;;
            assess)     shift 2; cmd_mastery_assess "$@" ;;
            history)    cmd_mastery_history ;;
            *)          echo "Usage: gua mastery {status|assess|history}" ;;
        esac ;;
    reflect)    cmd_reflect ;;
    distill)    cmd_distill ;;
    seer)       shift; cmd_seer "$@" ;;
    help|--help|-h)
        echo "GUA v3 - Global Understanding Archive"
        echo ""
        echo "Sync:      gua load | save | status"
        echo "Knowledge: gua add \"<text>\" [dim] [type] | search \"<q>\" [--dim <d>] | list"
        echo "Path:      gua path {status|init|waypoint {add|list|update}}"
        echo "Mastery:   gua mastery {status|assess|history}"
        echo "Threads:   gua thread {start|resume|list} | gua moment \"<text>\""
        echo "Alchemy:   gua distill | gua reflect"
        echo "Web:       gua seer \"<url>\""
        ;;
    *)
        echo -e "${RED}Unknown: $1. Run 'gua help'${NC}" ;;
esac
