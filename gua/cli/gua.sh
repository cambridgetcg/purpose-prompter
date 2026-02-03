#!/bin/bash
# GUA - Global Understanding Archive CLI
# Usage: gua <command> [args]

set -e

GUA_DIR="$HOME/.gua"
CONFIG_FILE="$GUA_DIR/config.json"
STATE_FILE="$GUA_DIR/state.json"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check dependencies
check_deps() {
    if ! command -v jq &> /dev/null; then
        echo -e "${RED}ERROR: jq not found. Install with: brew install jq${NC}"
        exit 1
    fi
    if ! command -v aws &> /dev/null; then
        echo -e "${RED}ERROR: AWS CLI not found. Install with: brew install awscli${NC}"
        exit 1
    fi
}

# Load config
load_config() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        echo -e "${RED}ERROR: GUA not configured. Run: ~/.gua/setup.sh${NC}"
        exit 1
    fi

    USER_ID=$(jq -r '.user_id' "$CONFIG_FILE")
    REGION=$(jq -r '.region' "$CONFIG_FILE")
    S3_BUCKET=$(jq -r '.s3_bucket' "$CONFIG_FILE")
    DEVICE_ID=$(jq -r '.device_id' "$CONFIG_FILE")
}

# Get timestamp
timestamp() {
    date -u +"%Y-%m-%dT%H:%M:%SZ"
}

# Generate UUID
uuid() {
    uuidgen | tr '[:upper:]' '[:lower:]'
}

# Check if v2 (scalable) is configured
is_v2() {
    local version=$(jq -r '.version // "1.0"' "$CONFIG_FILE" 2>/dev/null)
    [[ "$version" == "2.0" ]]
}

# ============================================================
# SYNC-MODULES - Download GUA modules from S3
# ============================================================
cmd_sync_modules() {
    load_config

    echo -e "${BLUE}[GUA] Syncing modules from AWS...${NC}"

    # Download seer module
    echo "  Downloading seer.sh..."
    aws s3 cp "s3://$S3_BUCKET/modules/seer.sh" "$GUA_DIR/seer.sh" --region "$REGION" 2>/dev/null && \
        chmod +x "$GUA_DIR/seer.sh" && \
        echo -e "    ${GREEN}✓ seer.sh${NC}" || \
        echo -e "    ${YELLOW}(not found or failed)${NC}"

    # List available modules
    echo ""
    echo "  Available modules in S3:"
    aws s3 ls "s3://$S3_BUCKET/modules/" --region "$REGION" 2>/dev/null | while read line; do
        echo "    $line"
    done

    echo ""
    echo -e "${GREEN}[GUA] Module sync complete${NC}"
}

# ============================================================
# LOAD - Download understanding from AWS
# ============================================================
cmd_load() {
    load_config

    # Check if v2 is configured - use active set loading
    if is_v2; then
        cmd_load_active_set
        return
    fi

    # v1 behavior: load everything
    echo -e "${BLUE}[GUA] Loading understanding from AWS...${NC}"

    LOCAL_INTEGRATION="$HOME/.claude/purpose_prompter/integration"
    LOCAL_INSIGHTS="$HOME/.claude/purpose_prompter/insights"

    mkdir -p "$LOCAL_INTEGRATION"
    mkdir -p "$LOCAL_INSIGHTS"

    # Download documents
    echo "  Downloading LIGHT.md..."
    aws s3 cp "s3://$S3_BUCKET/documents/LIGHT.md" "$LOCAL_INTEGRATION/LIGHT.md" --region "$REGION" 2>/dev/null || echo "    (not found, skipping)"

    echo "  Downloading PATH.md..."
    aws s3 cp "s3://$S3_BUCKET/documents/PATH.md" "$LOCAL_INTEGRATION/PATH.md" --region "$REGION" 2>/dev/null || echo "    (not found, skipping)"

    echo "  Downloading blindspots.md..."
    aws s3 cp "s3://$S3_BUCKET/documents/blindspots.md" "$LOCAL_INSIGHTS/blindspots.md" --region "$REGION" 2>/dev/null || echo "    (not found, skipping)"

    echo "  Downloading KNOWLEDGE_TAXONOMY.md..."
    aws s3 cp "s3://$S3_BUCKET/documents/KNOWLEDGE_TAXONOMY.md" "$LOCAL_INTEGRATION/KNOWLEDGE_TAXONOMY.md" --region "$REGION" 2>/dev/null || echo "    (not found, skipping)"

    # Download entity files (PARTNER.md for relational continuity)
    echo "  Downloading entity/PARTNER.md..."
    mkdir -p "$GUA_DIR/entity"
    aws s3 cp "s3://$S3_BUCKET/entity/PARTNER.md" "$GUA_DIR/entity/PARTNER.md" --region "$REGION" 2>/dev/null || echo "    (not found, skipping)"

    # Also sync knowledge taxonomy
    cmd_load_knowledge

    # Update state
    jq --arg ts "$(timestamp)" '.last_load = $ts' "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"

    echo -e "${GREEN}[GUA] Load complete.${NC}"

    # Show summary
    if [[ -f "$LOCAL_INTEGRATION/LIGHT.md" ]]; then
        PATTERNS=$(grep -c "^### Pattern:" "$LOCAL_INTEGRATION/LIGHT.md" 2>/dev/null || echo "0")
        echo "  LIGHT.md: $PATTERNS patterns"
    fi
}

# ============================================================
# LOAD-ACTIVE-SET - v2: Load only active set (fast)
# ============================================================
cmd_load_active_set() {
    echo -e "${BLUE}[GUA] Loading active set from AWS (v2)...${NC}"

    load_config

    LOCAL_INTEGRATION="$HOME/.claude/purpose_prompter/integration"
    LOCAL_KNOWLEDGE="$HOME/.claude/purpose_prompter/knowledge"
    LOCAL_CACHE="$HOME/.claude/purpose_prompter/.cache"

    mkdir -p "$LOCAL_INTEGRATION"
    mkdir -p "$LOCAL_KNOWLEDGE/active"
    mkdir -p "$LOCAL_CACHE"

    # Create entity directory and download PARTNER.md for relational continuity
    mkdir -p "$GUA_DIR/entity"
    echo "  Loading PARTNER.md..."
    aws s3 cp "s3://$S3_BUCKET/entity/PARTNER.md" "$GUA_DIR/entity/PARTNER.md" --region "$REGION" 2>/dev/null || true

    # Get active set config
    local max_patterns=$(jq -r '.active_set.max_patterns // 50' "$CONFIG_FILE")
    local max_blindspots=$(jq -r '.active_set.max_blindspots // 20' "$CONFIG_FILE")

    echo "  Loading top $max_patterns patterns + $max_blindspots blindspots..."

    # Query index for top patterns by access_score
    local patterns=$(aws dynamodb query \
        --table-name "gua-knowledge-index" \
        --index-name "access-score-index" \
        --key-condition-expression "user_id = :uid" \
        --expression-attribute-values "{\":uid\": {\"S\": \"$USER_ID\"}}" \
        --no-scan-index-forward \
        --limit "$max_patterns" \
        --region "$REGION" 2>/dev/null | jq -c '.Items // []')

    # Query for all active blindspots
    local blindspots=$(aws dynamodb query \
        --table-name "gua-knowledge-index" \
        --key-condition-expression "user_id = :uid" \
        --filter-expression "knowledge_type = :bs AND is_active = :active" \
        --expression-attribute-values "{\":uid\": {\"S\": \"$USER_ID\"}, \":bs\": {\"S\": \"blindspot\"}, \":active\": {\"BOOL\": true}}" \
        --limit "$max_blindspots" \
        --region "$REGION" 2>/dev/null | jq -c '.Items // []')

    # Generate LIGHT.md from active set
    local pattern_count=$(echo "$patterns" | jq 'length' 2>/dev/null || echo "0")
    local blindspot_count=$(echo "$blindspots" | jq 'length' 2>/dev/null || echo "0")

    # Ensure we have numeric values
    [[ -z "$pattern_count" ]] && pattern_count=0
    [[ -z "$blindspot_count" ]] && blindspot_count=0

    echo "  Found: $pattern_count patterns, $blindspot_count blindspots"

    # Generate active LIGHT.md
    cat > "$LOCAL_INTEGRATION/LIGHT.md" << EOF
# LIGHT - Active Understanding

> **Generated**: $(date -u +"%Y-%m-%d %H:%M UTC")
> **Mode**: Active Set (v2)
> **Patterns loaded**: $pattern_count
> **Blindspots loaded**: $blindspot_count

---

## Active Blindspots (CHECK THESE)

EOF

    # Add blindspots - filter nulls
    echo "$blindspots" | jq -r '
        .[] | select(.name.S != null and .name.S != "" and .name.S != "null")
        | "### \(.name.S | .[0:50])\n- **Dimension**: \(.pp_dimension.S)\n- \(.summary.S // "Watch for this" | .[0:150])\n"
    ' >> "$LOCAL_INTEGRATION/LIGHT.md" 2>/dev/null || true

    cat >> "$LOCAL_INTEGRATION/LIGHT.md" << EOF

---

## Top Patterns (by access frequency)

EOF

    # Add patterns - filter nulls, truncate
    echo "$patterns" | jq -r '
        .[] | select(.name.S != null and .name.S != "" and .name.S != "null")
        | "### \(.name.S | .[0:50])\n- **Dimension**: \(.pp_dimension.S)\n- **Access**: \(.access_count.N // "0")x\n- \(.summary.S // "No summary" | .[0:150])\n"
    ' >> "$LOCAL_INTEGRATION/LIGHT.md" 2>/dev/null || true

    cat >> "$LOCAL_INTEGRATION/LIGHT.md" << EOF

---

*GUA v2 | \`gua context\` for quick summary | \`gua search <query>\` to find specific patterns*

EOF

    # Save active set IDs to cache for quick lookup
    echo "$patterns" | jq -r '.[].knowledge_id.S' > "$LOCAL_CACHE/active_patterns.txt" 2>/dev/null || true
    echo "$blindspots" | jq -r '.[].knowledge_id.S' > "$LOCAL_CACHE/active_blindspots.txt" 2>/dev/null || true

    # Update state
    if [[ -f "$STATE_FILE" ]]; then
        jq --arg ts "$(timestamp)" --argjson pc "${pattern_count:-0}" --argjson bc "${blindspot_count:-0}" \
            '.last_load = $ts | .active_patterns = $pc | .active_blindspots = $bc' \
            "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
    fi

    echo -e "${GREEN}[GUA] Active set loaded (${pattern_count:-0} patterns, ${blindspot_count:-0} blindspots)${NC}"

    # Include CPT summary if enabled
    if is_cpt_enabled 2>/dev/null; then
        echo ""

        # Get CPT stats
        local areas=$(aws dynamodb scan \
            --table-name "gua-knowledge-index" \
            --filter-expression "user_id = :uid AND knowledge_type = :kt" \
            --expression-attribute-values "{\":uid\": {\"S\": \"$USER_ID\"}, \":kt\": {\"S\": \"code_area\"}}" \
            --select "COUNT" \
            --region "$REGION" 2>/dev/null)

        local area_count=$(echo "$areas" | jq '.Count // 0' 2>/dev/null || echo "0")

        local challenges=$(aws dynamodb scan \
            --table-name "gua-knowledge-index" \
            --filter-expression "user_id = :uid AND knowledge_type = :kt AND #st = :status" \
            --expression-attribute-names '{"#st": "status"}' \
            --expression-attribute-values "{\":uid\": {\"S\": \"$USER_ID\"}, \":kt\": {\"S\": \"challenge\"}, \":status\": {\"S\": \"active\"}}" \
            --select "COUNT" \
            --region "$REGION" 2>/dev/null)

        local challenge_count=$(echo "$challenges" | jq '.Count // 0' 2>/dev/null || echo "0")

        # Get areas for avg calculation and gaps
        local area_data=$(aws dynamodb scan \
            --table-name "gua-knowledge-index" \
            --filter-expression "user_id = :uid AND knowledge_type = :kt" \
            --expression-attribute-values "{\":uid\": {\"S\": \"$USER_ID\"}, \":kt\": {\"S\": \"code_area\"}}" \
            --region "$REGION" 2>/dev/null)

        local avg_impl=$(echo "$area_data" | jq '[.Items[].implementation_pct.N // "0" | tonumber] | if length > 0 then add / length else 0 end | floor' 2>/dev/null || echo "0")
        local gaps=$(echo "$area_data" | jq '[.Items[] | select(.understanding_depth.S == "L0" or .understanding_depth.S == "L1")] | length' 2>/dev/null || echo "0")

        echo -e "${BLUE}[CPT] Progress: ${area_count} areas, ${avg_impl}% avg completion${NC}"
        if [[ "$challenge_count" != "0" ]]; then
            echo -e "      ${YELLOW}Active challenges: ${challenge_count}${NC}"
        fi
        if [[ "$gaps" != "0" && "$gaps" != "null" ]]; then
            echo -e "      Understanding gaps: ${gaps} area(s) at L0-L1"
        fi
    fi
}

# ============================================================
# SAVE - Upload local changes to AWS
# ============================================================
cmd_save() {
    echo -e "${BLUE}[GUA] Saving understanding to AWS...${NC}"

    load_config

    LOCAL_INTEGRATION="$HOME/.claude/purpose_prompter/integration"
    LOCAL_INSIGHTS="$HOME/.claude/purpose_prompter/insights"

    # Upload documents if they exist
    if [[ -f "$LOCAL_INTEGRATION/LIGHT.md" ]]; then
        echo "  Uploading LIGHT.md..."
        aws s3 cp "$LOCAL_INTEGRATION/LIGHT.md" "s3://$S3_BUCKET/documents/LIGHT.md" --region "$REGION"
    fi

    if [[ -f "$LOCAL_INTEGRATION/PATH.md" ]]; then
        echo "  Uploading PATH.md..."
        aws s3 cp "$LOCAL_INTEGRATION/PATH.md" "s3://$S3_BUCKET/documents/PATH.md" --region "$REGION"
    fi

    if [[ -f "$LOCAL_INSIGHTS/blindspots.md" ]]; then
        echo "  Uploading blindspots.md..."
        aws s3 cp "$LOCAL_INSIGHTS/blindspots.md" "s3://$S3_BUCKET/documents/blindspots.md" --region "$REGION"
    fi

    if [[ -f "$LOCAL_INTEGRATION/KNOWLEDGE_TAXONOMY.md" ]]; then
        echo "  Uploading KNOWLEDGE_TAXONOMY.md..."
        aws s3 cp "$LOCAL_INTEGRATION/KNOWLEDGE_TAXONOMY.md" "s3://$S3_BUCKET/documents/KNOWLEDGE_TAXONOMY.md" --region "$REGION"
    fi

    # Also sync knowledge taxonomy
    cmd_save_knowledge

    # Sync feedback entries
    FEEDBACK_FILE="$HOME/Desktop/purpose_prompter/feedback/entries.jsonl"
    if [[ -f "$FEEDBACK_FILE" ]]; then
        echo "  Syncing feedback entries to DynamoDB..."
        while IFS= read -r line; do
            if [[ -n "$line" ]]; then
                TS=$(echo "$line" | jq -r '.timestamp // empty')
                if [[ -n "$TS" ]]; then
                    UUID=$(uuid)
                    aws dynamodb put-item \
                        --table-name "gua-feedback" \
                        --item "{
                            \"user_id\": {\"S\": \"$USER_ID\"},
                            \"timestamp_uuid\": {\"S\": \"${TS}#${UUID}\"},
                            \"data\": {\"S\": $(echo "$line" | jq -c '.' | jq -Rs '.')},
                            \"device_id\": {\"S\": \"$DEVICE_ID\"},
                            \"synced_at\": {\"S\": \"$(timestamp)\"}
                        }" \
                        --region "$REGION" 2>/dev/null || true
                fi
            fi
        done < "$FEEDBACK_FILE"
    fi

    # Update state
    jq --arg ts "$(timestamp)" '.last_save = $ts' "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"

    echo -e "${GREEN}[GUA] Save complete.${NC}"
}

# ============================================================
# RESEARCH - Log a research finding
# ============================================================
cmd_research_list() {
    local limit="${1:-10}"

    load_config

    echo -e "${BLUE}[GUA] Recent Research Entries (limit: $limit)${NC}"
    echo ""

    aws dynamodb query \
        --table-name "gua-research" \
        --key-condition-expression "user_id = :uid" \
        --expression-attribute-values "{\":uid\": {\"S\": \"$USER_ID\"}}" \
        --no-scan-index-forward \
        --limit "$limit" \
        --region "$REGION" 2>/dev/null | jq -r '.Items[] | "\(.timestamp_uuid.S | split("#")[0]) | \(.topic.S) | \(.finding.S | .[0:80])..."'
}

cmd_research_log() {
    local topic="$1"
    local finding="$2"
    local source="${3:-manual}"
    local confidence="${4:-medium}"

    if [[ -z "$topic" || -z "$finding" ]]; then
        echo -e "${RED}Usage: gua research log <topic> <finding> [source] [confidence]${NC}"
        echo "Example: gua research log 'vector databases' 'ChromaDB is free under 10M vectors' 'docs' 'high'"
        exit 1
    fi

    load_config

    local ts=$(timestamp)
    local id=$(uuid)

    aws dynamodb put-item \
        --table-name "gua-research" \
        --item "{
            \"user_id\": {\"S\": \"$USER_ID\"},
            \"timestamp_uuid\": {\"S\": \"${ts}#${id}\"},
            \"topic\": {\"S\": \"$topic\"},
            \"finding\": {\"S\": \"$finding\"},
            \"source\": {\"S\": \"$source\"},
            \"confidence\": {\"S\": \"$confidence\"},
            \"device_id\": {\"S\": \"$DEVICE_ID\"},
            \"synthesized\": {\"BOOL\": false}
        }" \
        --region "$REGION"

    # Update local state
    PENDING=$(jq '.pending_research' "$STATE_FILE")
    jq --argjson p "$((PENDING + 1))" '.pending_research = $p' "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"

    echo -e "${GREEN}[GUA] Research logged: $topic${NC}"
    echo "  Finding: $finding"
    echo "  Confidence: $confidence"
}

# ============================================================
# INSIGHT - Log an insight with taxonomy metadata
# ============================================================
cmd_insight_list() {
    local limit="${1:-10}"

    load_config

    echo -e "${BLUE}[GUA] Recent Insight Entries (limit: $limit)${NC}"
    echo ""

    aws dynamodb query \
        --table-name "gua-insights" \
        --key-condition-expression "user_id = :uid" \
        --expression-attribute-values "{\":uid\": {\"S\": \"$USER_ID\"}}" \
        --no-scan-index-forward \
        --limit "$limit" \
        --region "$REGION" 2>/dev/null | jq -r '.Items[] | "\(.timestamp_uuid.S | split("#")[0]) | \(.type.S // "insight") | \(.pp_dimension.S // "unknown") | \(.content.S | .[0:60])..."'
}

cmd_insight_log() {
    local content="$1"
    local type="${2:-observation}"
    local evidence="${3:-}"
    local pp_dimension="${4:-understanding}"
    local scope="${5:-global}"

    if [[ -z "$content" ]]; then
        echo -e "${RED}Usage: gua insight log <content> [type] [evidence] [pp_dimension] [scope]${NC}"
        echo ""
        echo "Types: observation, pattern, blindspot, hypothesis, anti-pattern, technique, principle, model"
        echo "PP Dimensions: truth, understanding, beauty, justice, creativity"
        echo "Scopes: global, domain, project, personal"
        echo ""
        echo "Examples:"
        echo "  gua insight 'Tiered implementation reduces risk' 'pattern'"
        echo "  gua insight 'Always read before claiming' 'pattern' 'PP verification' 'truth' 'global'"
        echo "  gua insight 'Skip territory check on simple tasks' 'blindspot' 'Failed 3x' 'creativity'"
        exit 1
    fi

    load_config

    local ts=$(timestamp)
    local id=$(uuid)

    aws dynamodb put-item \
        --table-name "gua-insights" \
        --item "{
            \"user_id\": {\"S\": \"$USER_ID\"},
            \"timestamp_uuid\": {\"S\": \"${ts}#${id}\"},
            \"content\": {\"S\": \"$content\"},
            \"type\": {\"S\": \"$type\"},
            \"evidence\": {\"S\": \"${evidence:-none}\"},
            \"pp_dimension\": {\"S\": \"$pp_dimension\"},
            \"scope\": {\"S\": \"$scope\"},
            \"confidence\": {\"S\": \"hypothesis\"},
            \"depth_level\": {\"N\": \"1\"},
            \"observation_count\": {\"N\": \"1\"},
            \"device_id\": {\"S\": \"$DEVICE_ID\"},
            \"status\": {\"S\": \"pending\"},
            \"synthesized\": {\"BOOL\": false}
        }" \
        --region "$REGION"

    # Update local state
    PENDING=$(jq '.pending_insights' "$STATE_FILE")
    jq --argjson p "$((PENDING + 1))" '.pending_insights = $p' "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"

    # v2: Also add to knowledge index for immediate searchability
    if is_v2; then
        local knowledge_id="insight-${id}"
        local summary=$(echo "$content" | cut -c1-200)

        aws dynamodb put-item \
            --table-name "gua-knowledge-index" \
            --item "{
                \"user_id\": {\"S\": \"$USER_ID\"},
                \"knowledge_id\": {\"S\": \"$knowledge_id\"},
                \"name\": {\"S\": \"$content\"},
                \"pp_dimension\": {\"S\": \"$pp_dimension\"},
                \"knowledge_type\": {\"S\": \"$type\"},
                \"confidence\": {\"S\": \"hypothesis\"},
                \"scope\": {\"S\": \"$scope\"},
                \"depth_level\": {\"N\": \"1\"},
                \"access_count\": {\"N\": \"0\"},
                \"access_score\": {\"N\": \"0\"},
                \"last_accessed\": {\"S\": \"never\"},
                \"created_at\": {\"S\": \"$ts\"},
                \"s3_key\": {\"S\": \"\"},
                \"summary\": {\"S\": \"$summary\"},
                \"is_active\": {\"BOOL\": true},
                \"source_insight\": {\"S\": \"${ts}#${id}\"}
            }" \
            --region "$REGION" 2>/dev/null || true
    fi

    echo -e "${GREEN}[GUA] Insight logged: $type${NC}"
    echo "  Content: $content"
    echo "  PP Dimension: $pp_dimension"
    echo "  Scope: $scope"
    if is_v2; then
        echo "  (Indexed for search)"
    fi
}

# ============================================================
# LOAD-KNOWLEDGE - Download knowledge taxonomy from AWS
# ============================================================
cmd_load_knowledge() {
    echo -e "${BLUE}[GUA] Loading knowledge taxonomy from AWS...${NC}"

    load_config

    LOCAL_KNOWLEDGE="$HOME/.claude/purpose_prompter/knowledge"

    # Sync entire knowledge directory from S3
    echo "  Syncing knowledge/by-dimension/..."
    aws s3 sync "s3://$S3_BUCKET/knowledge/by-dimension/" "$LOCAL_KNOWLEDGE/by-dimension/" --region "$REGION" 2>/dev/null || echo "    (no files found)"

    echo "  Syncing knowledge/by-domain/..."
    aws s3 sync "s3://$S3_BUCKET/knowledge/by-domain/" "$LOCAL_KNOWLEDGE/by-domain/" --region "$REGION" 2>/dev/null || echo "    (no files found)"

    echo "  Syncing knowledge/deep/..."
    aws s3 sync "s3://$S3_BUCKET/knowledge/deep/" "$LOCAL_KNOWLEDGE/deep/" --region "$REGION" 2>/dev/null || echo "    (no files found)"

    echo -e "${GREEN}[GUA] Knowledge sync complete.${NC}"
}

# ============================================================
# SAVE-KNOWLEDGE - Upload knowledge taxonomy to AWS
# ============================================================
cmd_save_knowledge() {
    echo -e "${BLUE}[GUA] Saving knowledge taxonomy to AWS...${NC}"

    load_config

    LOCAL_KNOWLEDGE="$HOME/.claude/purpose_prompter/knowledge"

    # Sync entire knowledge directory to S3
    echo "  Uploading knowledge/by-dimension/..."
    aws s3 sync "$LOCAL_KNOWLEDGE/by-dimension/" "s3://$S3_BUCKET/knowledge/by-dimension/" --region "$REGION" 2>/dev/null || true

    echo "  Uploading knowledge/by-domain/..."
    aws s3 sync "$LOCAL_KNOWLEDGE/by-domain/" "s3://$S3_BUCKET/knowledge/by-domain/" --region "$REGION" 2>/dev/null || true

    echo "  Uploading knowledge/deep/..."
    aws s3 sync "$LOCAL_KNOWLEDGE/deep/" "s3://$S3_BUCKET/knowledge/deep/" --region "$REGION" 2>/dev/null || true

    # Also upload KNOWLEDGE_TAXONOMY.md if exists
    LOCAL_INTEGRATION="$HOME/.claude/purpose_prompter/integration"
    if [[ -f "$LOCAL_INTEGRATION/KNOWLEDGE_TAXONOMY.md" ]]; then
        echo "  Uploading KNOWLEDGE_TAXONOMY.md..."
        aws s3 cp "$LOCAL_INTEGRATION/KNOWLEDGE_TAXONOMY.md" "s3://$S3_BUCKET/documents/KNOWLEDGE_TAXONOMY.md" --region "$REGION"
    fi

    echo -e "${GREEN}[GUA] Knowledge save complete.${NC}"
}

# ============================================================
# PROMOTE - Promote insight to knowledge file
# ============================================================
cmd_promote() {
    local insight_id="$1"
    local target_dimension="${2:-}"

    if [[ -z "$insight_id" ]]; then
        echo -e "${RED}Usage: gua promote <insight_id> [target_dimension]${NC}"
        echo ""
        echo "Promotes an insight from DynamoDB to a knowledge file."
        echo ""
        echo "Arguments:"
        echo "  insight_id       The timestamp_uuid of the insight (from 'gua query insights')"
        echo "  target_dimension Optional: truth, understanding, beauty, justice, creativity"
        echo ""
        echo "Example: gua promote '2026-01-27T10:00:00Z#abc-123' 'creativity'"
        exit 1
    fi

    load_config

    # Fetch the insight from DynamoDB
    INSIGHT=$(aws dynamodb get-item \
        --table-name "gua-insights" \
        --key "{\"user_id\": {\"S\": \"$USER_ID\"}, \"timestamp_uuid\": {\"S\": \"$insight_id\"}}" \
        --region "$REGION" 2>/dev/null)

    if [[ -z "$INSIGHT" || "$INSIGHT" == "{}" ]]; then
        echo -e "${RED}[GUA] Insight not found: $insight_id${NC}"
        exit 1
    fi

    # Extract fields
    local content=$(echo "$INSIGHT" | jq -r '.Item.content.S // "unknown"')
    local type=$(echo "$INSIGHT" | jq -r '.Item.type.S // "pattern"')
    local pp_dim=$(echo "$INSIGHT" | jq -r '.Item.pp_dimension.S // "understanding"')
    local evidence=$(echo "$INSIGHT" | jq -r '.Item.evidence.S // "none"')

    # Use provided dimension or default from insight
    local dimension="${target_dimension:-$pp_dim}"

    # Determine target file
    local target_file="$HOME/.claude/purpose_prompter/knowledge/by-dimension/$dimension/patterns.md"

    if [[ "$type" == "blindspot" ]]; then
        target_file="$HOME/.claude/purpose_prompter/knowledge/by-dimension/$dimension/blindspots.md"
    elif [[ "$type" == "anti-pattern" ]]; then
        target_file="$HOME/.claude/purpose_prompter/knowledge/by-dimension/$dimension/anti-patterns.md"
    elif [[ "$type" == "technique" ]]; then
        target_file="$HOME/.claude/purpose_prompter/knowledge/by-dimension/$dimension/techniques.md"
    elif [[ "$type" == "model" ]]; then
        target_file="$HOME/.claude/purpose_prompter/knowledge/by-dimension/$dimension/models.md"
    fi

    # Create directory if needed
    mkdir -p "$(dirname "$target_file")"

    # Create file with header if it doesn't exist
    if [[ ! -f "$target_file" ]]; then
        cat > "$target_file" << EOF
# ${dimension^} - ${type^}s

> Accumulated knowledge for the **$dimension** dimension

---

EOF
    fi

    # Append the promoted insight
    local ts=$(date +"%Y-%m-%d")
    cat >> "$target_file" << EOF

## ${content}

- **Type**: $type
- **Evidence**: $evidence
- **Promoted**: $ts
- **Confidence**: emerging
- **Depth**: L2

---
EOF

    # Mark as synthesized in DynamoDB
    aws dynamodb update-item \
        --table-name "gua-insights" \
        --key "{\"user_id\": {\"S\": \"$USER_ID\"}, \"timestamp_uuid\": {\"S\": \"$insight_id\"}}" \
        --update-expression "SET synthesized = :s, promoted_to = :p" \
        --expression-attribute-values "{\":s\": {\"BOOL\": true}, \":p\": {\"S\": \"$target_file\"}}" \
        --region "$REGION" 2>/dev/null

    echo -e "${GREEN}[GUA] Insight promoted to knowledge${NC}"
    echo "  Content: $content"
    echo "  File: $target_file"
    echo "  Dimension: $dimension"
}

# ============================================================
# LIST-KNOWLEDGE - List all knowledge files
# ============================================================
cmd_list_knowledge() {
    local filter="${1:-all}"

    echo -e "${BLUE}[GUA] Knowledge Files${NC}"
    echo ""

    LOCAL_KNOWLEDGE="$HOME/.claude/purpose_prompter/knowledge"

    if [[ "$filter" == "all" || "$filter" == "dimension" ]]; then
        echo "By Dimension:"
        for dim in truth understanding beauty justice creativity; do
            if [[ -d "$LOCAL_KNOWLEDGE/by-dimension/$dim" ]]; then
                local count=$(find "$LOCAL_KNOWLEDGE/by-dimension/$dim" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
                echo "  $dim/: $count files"
            fi
        done
        echo ""
    fi

    if [[ "$filter" == "all" || "$filter" == "domain" ]]; then
        echo "By Domain:"
        for domain in "$LOCAL_KNOWLEDGE/by-domain"/*; do
            if [[ -d "$domain" ]]; then
                local name=$(basename "$domain")
                local count=$(find "$domain" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
                echo "  $name/: $count files"
            fi
        done
        echo ""
    fi

    if [[ "$filter" == "all" || "$filter" == "deep" ]]; then
        echo "Deep Files (L3-L4):"
        if [[ -d "$LOCAL_KNOWLEDGE/deep" ]]; then
            for f in "$LOCAL_KNOWLEDGE/deep"/*.md; do
                if [[ -f "$f" ]]; then
                    echo "  $(basename "$f")"
                fi
            done 2>/dev/null || echo "  (none yet)"
        fi
    fi
}

# ============================================================
# STATUS - Show current GUA status
# ============================================================
cmd_status() {
    echo -e "${BLUE}[GUA] Status${NC}"
    echo ""

    load_config

    echo "Configuration:"
    echo "  User:   $USER_ID"
    echo "  Region: $REGION"
    echo "  Bucket: $S3_BUCKET"
    echo "  Device: $DEVICE_ID"
    echo ""

    # Local state
    if [[ -f "$STATE_FILE" ]]; then
        LAST_LOAD=$(jq -r '.last_load // "never"' "$STATE_FILE")
        LAST_SAVE=$(jq -r '.last_save // "never"' "$STATE_FILE")
        PENDING_R=$(jq -r '.pending_research // 0' "$STATE_FILE")
        PENDING_I=$(jq -r '.pending_insights // 0' "$STATE_FILE")

        echo "Sync State:"
        echo "  Last load: $LAST_LOAD"
        echo "  Last save: $LAST_SAVE"
        echo "  Pending research: $PENDING_R"
        echo "  Pending insights: $PENDING_I"
        echo ""
    fi

    # AWS counts
    echo "AWS Data (querying...):"

    RESEARCH_COUNT=$(aws dynamodb scan \
        --table-name "gua-research" \
        --filter-expression "user_id = :uid" \
        --expression-attribute-values "{\":uid\": {\"S\": \"$USER_ID\"}}" \
        --select "COUNT" \
        --region "$REGION" 2>/dev/null | jq '.Count // 0')
    echo "  Research entries: $RESEARCH_COUNT"

    INSIGHTS_COUNT=$(aws dynamodb scan \
        --table-name "gua-insights" \
        --filter-expression "user_id = :uid" \
        --expression-attribute-values "{\":uid\": {\"S\": \"$USER_ID\"}}" \
        --select "COUNT" \
        --region "$REGION" 2>/dev/null | jq '.Count // 0')
    echo "  Insight entries:  $INSIGHTS_COUNT"

    SESSIONS_COUNT=$(aws dynamodb scan \
        --table-name "gua-sessions" \
        --filter-expression "user_id = :uid" \
        --expression-attribute-values "{\":uid\": {\"S\": \"$USER_ID\"}}" \
        --select "COUNT" \
        --region "$REGION" 2>/dev/null | jq '.Count // 0')
    echo "  Sessions logged:  $SESSIONS_COUNT"
    echo ""

    # Local files
    echo "Local Files:"
    LOCAL_INTEGRATION="$HOME/.claude/purpose_prompter/integration"
    [[ -f "$LOCAL_INTEGRATION/LIGHT.md" ]] && echo "  LIGHT.md: exists" || echo "  LIGHT.md: missing"
    [[ -f "$LOCAL_INTEGRATION/PATH.md" ]] && echo "  PATH.md: exists" || echo "  PATH.md: missing"
}

# ============================================================
# INIT - Run setup wizard
# ============================================================
cmd_init() {
    local force="${1:-}"

    if [[ -f "$CONFIG_FILE" && "$force" != "--force" ]]; then
        echo -e "${YELLOW}[GUA] Already configured.${NC}"
        echo ""
        echo "Current configuration:"
        echo "  User:   $(jq -r '.user_id' "$CONFIG_FILE")"
        echo "  Device: $(jq -r '.device_id' "$CONFIG_FILE")"
        echo ""
        echo "To reconfigure, run: gua init --force"
        echo "Or run setup directly: ~/.gua/setup.sh"
        return 0
    fi

    if [[ -f "$GUA_DIR/setup.sh" ]]; then
        source "$GUA_DIR/setup.sh"
    else
        echo -e "${RED}[GUA] Setup script not found at ~/.gua/setup.sh${NC}"
        exit 1
    fi
}

# ============================================================
# WHOAMI - Show current user identity
# ============================================================
cmd_whoami() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        echo -e "${RED}[GUA] Not configured. Run: gua init${NC}"
        exit 1
    fi

    local user_id=$(jq -r '.user_id' "$CONFIG_FILE")
    local device_id=$(jq -r '.device_id' "$CONFIG_FILE")
    local device_name=$(jq -r '.device_name' "$CONFIG_FILE")
    local region=$(jq -r '.region' "$CONFIG_FILE")
    local s3_bucket=$(jq -r '.s3_bucket' "$CONFIG_FILE")
    local version=$(jq -r '.version // "1.0"' "$CONFIG_FILE")
    local created_at=$(jq -r '.created_at // "unknown"' "$CONFIG_FILE")

    echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║           GUA IDENTITY                 ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}User:${NC}"
    echo "  User ID:     $user_id"
    echo ""
    echo -e "${GREEN}Device:${NC}"
    echo "  Device ID:   $device_id"
    echo "  Device Name: $device_name"
    echo ""
    echo -e "${GREEN}AWS:${NC}"
    echo "  Region:      $region"
    echo "  S3 Bucket:   $s3_bucket"
    echo ""
    echo -e "${GREEN}Config:${NC}"
    echo "  Version:     $version"
    echo "  Created:     $created_at"
    echo ""

    # Check current session
    if [[ -f "$GUA_DIR/current_session" ]]; then
        local session_id=$(cat "$GUA_DIR/current_session")
        echo -e "${GREEN}Session:${NC}"
        echo "  Active:      $session_id"
        echo ""
    fi
}

# ============================================================
# AUTH - Authentication commands
# ============================================================
cmd_auth() {
    local action="${1:-verify}"

    case "$action" in
        verify)
            cmd_auth_verify
            ;;
        refresh)
            cmd_auth_refresh
            ;;
        *)
            echo "Usage: gua auth <verify|refresh>"
            echo ""
            echo "Commands:"
            echo "  verify    Check authentication status"
            echo "  refresh   Re-verify AWS credentials"
            ;;
    esac
}

cmd_auth_verify() {
    echo -e "${CYAN}╔════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║       AUTHENTICATION STATUS            ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════╝${NC}"
    echo ""

    # Check config file
    echo -e "${BLUE}>>> Configuration${NC}"
    if [[ -f "$CONFIG_FILE" ]]; then
        echo -e "  ${GREEN}✓${NC} Config file exists"
        local user_id=$(jq -r '.user_id' "$CONFIG_FILE")
        echo "    User: $user_id"
    else
        echo -e "  ${RED}✗${NC} Config file missing"
        echo "    Run: gua init"
        return 1
    fi
    echo ""

    # Check AWS credentials
    echo -e "${BLUE}>>> AWS Credentials${NC}"
    local aws_identity=$(aws sts get-caller-identity 2>&1)
    if [[ $? -eq 0 ]]; then
        local aws_account=$(echo "$aws_identity" | jq -r '.Account')
        local aws_arn=$(echo "$aws_identity" | jq -r '.Arn')
        echo -e "  ${GREEN}✓${NC} AWS credentials valid"
        echo "    Account: $aws_account"
        echo "    ARN: $aws_arn"
    else
        echo -e "  ${RED}✗${NC} AWS credentials invalid or expired"
        echo "    Run: aws configure"
        return 1
    fi
    echo ""

    # Check S3 access
    echo -e "${BLUE}>>> S3 Access${NC}"
    local s3_bucket=$(jq -r '.s3_bucket' "$CONFIG_FILE")
    if aws s3 ls "s3://$s3_bucket" &>/dev/null; then
        echo -e "  ${GREEN}✓${NC} S3 bucket accessible: $s3_bucket"
    else
        echo -e "  ${YELLOW}!${NC} S3 bucket not accessible: $s3_bucket"
        echo "    May need to create bucket or check permissions"
    fi
    echo ""

    # Check DynamoDB access
    echo -e "${BLUE}>>> DynamoDB Access${NC}"
    local region=$(jq -r '.region' "$CONFIG_FILE")
    local tables=("gua-knowledge-index" "gua-research" "gua-insights" "gua-sessions")
    local all_ok=true

    for table in "${tables[@]}"; do
        if aws dynamodb describe-table --table-name "$table" --region "$region" &>/dev/null; then
            echo -e "  ${GREEN}✓${NC} $table"
        else
            echo -e "  ${YELLOW}!${NC} $table (not found)"
            all_ok=false
        fi
    done
    echo ""

    # Summary
    echo -e "${CYAN}════════════════════════════════════════${NC}"
    if [[ "$all_ok" == "true" ]]; then
        echo -e "${GREEN}Authentication: VALID${NC}"
    else
        echo -e "${YELLOW}Authentication: PARTIAL${NC}"
        echo "Some resources may need to be created."
        echo "Run: ~/.gua/setup.sh"
    fi
}

cmd_auth_refresh() {
    echo -e "${BLUE}[GUA] Refreshing authentication...${NC}"

    # Just re-verify
    local aws_identity=$(aws sts get-caller-identity 2>&1)
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}[GUA] AWS credentials are valid${NC}"
    else
        echo -e "${RED}[GUA] AWS credentials need attention${NC}"
        echo "Run: aws configure"
        return 1
    fi
}

# ============================================================
# QUERY - Query research/insights from AWS
# ============================================================
cmd_query() {
    local table="${1:-research}"
    local limit="${2:-10}"

    load_config

    local table_name="gua-$table"

    echo -e "${BLUE}[GUA] Recent $table entries:${NC}"
    echo ""

    aws dynamodb query \
        --table-name "$table_name" \
        --key-condition-expression "user_id = :uid" \
        --expression-attribute-values "{\":uid\": {\"S\": \"$USER_ID\"}}" \
        --no-scan-index-forward \
        --limit "$limit" \
        --region "$REGION" 2>/dev/null | jq -r '.Items[] | "\(.timestamp_uuid.S | split("#")[0]) - \(.topic.S // .content.S // .type.S)"'
}

# ============================================================
# SESSION - Log session start/end
# ============================================================
cmd_session() {
    local action="${1:-start}"
    local project="${2:-unknown}"

    load_config

    local session_id="${DEVICE_ID}-$(date +%Y%m%d%H%M%S)"
    local ts=$(timestamp)

    if [[ "$action" == "start" ]]; then
        # Log session start
        aws dynamodb put-item \
            --table-name "gua-sessions" \
            --item "{
                \"user_id\": {\"S\": \"$USER_ID\"},
                \"session_id\": {\"S\": \"$session_id\"},
                \"device_id\": {\"S\": \"$DEVICE_ID\"},
                \"project\": {\"S\": \"$project\"},
                \"start_time\": {\"S\": \"$ts\"},
                \"status\": {\"S\": \"active\"}
            }" \
            --region "$REGION"

        echo "$session_id" > "$GUA_DIR/current_session"
        echo -e "${GREEN}[GUA] Session started: $session_id${NC}"

        # Auto-prime if continuity enabled
        local auto_prime=$(jq -r '.continuity.auto_prime // false' "$CONFIG_FILE")
        if [[ "$auto_prime" == "true" ]]; then
            echo ""
            cmd_prime --quick
        fi

    elif [[ "$action" == "end" ]]; then
        # Get current session
        if [[ -f "$GUA_DIR/current_session" ]]; then
            session_id=$(cat "$GUA_DIR/current_session")

            # Check for pending moments and suggest handoff
            local moments_file="$GUA_DIR/moments/current.jsonl"
            if [[ -f "$moments_file" ]] && [[ $(wc -l < "$moments_file") -gt 0 ]]; then
                echo -e "${YELLOW}[GUA] You have uncommitted moments. Consider running 'gua handoff' first.${NC}"
            fi

            aws dynamodb update-item \
                --table-name "gua-sessions" \
                --key "{\"user_id\": {\"S\": \"$USER_ID\"}, \"session_id\": {\"S\": \"$session_id\"}}" \
                --update-expression "SET end_time = :et, #st = :st" \
                --expression-attribute-names '{"#st": "status"}' \
                --expression-attribute-values "{\":et\": {\"S\": \"$ts\"}, \":st\": {\"S\": \"completed\"}}" \
                --region "$REGION" 2>/dev/null

            rm "$GUA_DIR/current_session"
            echo -e "${GREEN}[GUA] Session ended: $session_id${NC}"
        else
            echo -e "${YELLOW}[GUA] No active session found${NC}"
        fi
    fi
}

# ============================================================
# INDEX-STATS - Show knowledge index statistics (v2)
# ============================================================
cmd_index_stats() {
    echo -e "${BLUE}[GUA] Knowledge Index Statistics${NC}"
    echo ""

    load_config

    if ! is_v2; then
        echo -e "${YELLOW}Note: v2 not configured. Run upgrade-v2.sh first.${NC}"
        echo ""
    fi

    # Count by dimension
    echo "By PP Dimension:"
    for dim in truth understanding beauty justice creativity; do
        local count=$(aws dynamodb query \
            --table-name "gua-knowledge-index" \
            --index-name "dimension-confidence-index" \
            --key-condition-expression "pp_dimension = :dim" \
            --expression-attribute-values "{\":dim\": {\"S\": \"$dim\"}}" \
            --select "COUNT" \
            --region "$REGION" 2>/dev/null | jq '.Count // 0')
        printf "  %-15s %s\n" "$dim:" "$count"
    done
    echo ""

    # Count by type
    echo "By Type:"
    for ktype in pattern blindspot technique principle model anti-pattern; do
        local count=$(aws dynamodb query \
            --table-name "gua-knowledge-index" \
            --index-name "type-scope-index" \
            --key-condition-expression "knowledge_type = :kt" \
            --expression-attribute-values "{\":kt\": {\"S\": \"$ktype\"}}" \
            --select "COUNT" \
            --region "$REGION" 2>/dev/null | jq '.Count // 0')
        printf "  %-15s %s\n" "$ktype:" "$count"
    done
    echo ""

    # Total count
    local total=$(aws dynamodb scan \
        --table-name "gua-knowledge-index" \
        --filter-expression "user_id = :uid" \
        --expression-attribute-values "{\":uid\": {\"S\": \"$USER_ID\"}}" \
        --select "COUNT" \
        --region "$REGION" 2>/dev/null | jq '.Count // 0')
    echo "Total indexed: $total"
}

# ============================================================
# SEARCH - Search knowledge by query (v2)
# ============================================================
cmd_search() {
    local query="$1"
    local limit="${2:-20}"

    if [[ -z "$query" ]]; then
        echo -e "${RED}Usage: gua search <query> [limit]${NC}"
        echo "Example: gua search 'bridge' 10"
        exit 1
    fi

    echo -e "${BLUE}[GUA] Searching for: $query${NC}"
    echo ""

    load_config

    # Search in index (name and summary contain query)
    # Note: DynamoDB doesn't support full-text search, so we scan and filter
    # For production, consider OpenSearch or Algolia

    local results=$(aws dynamodb scan \
        --table-name "gua-knowledge-index" \
        --filter-expression "user_id = :uid AND (contains(#n, :q) OR contains(summary, :q))" \
        --expression-attribute-names '{"#n": "name"}' \
        --expression-attribute-values "{\":uid\": {\"S\": \"$USER_ID\"}, \":q\": {\"S\": \"$query\"}}" \
        --region "$REGION" 2>/dev/null)

    local count=$(echo "$results" | jq '.Count // 0')

    if [[ "$count" == "0" ]]; then
        echo "No results found for: $query"
        return
    fi

    echo "Found $count results:"
    echo ""

    echo "$results" | jq -r ".Items[:$limit][] | \"[\(.knowledge_type.S)] \(.name.S)\n    Dimension: \(.pp_dimension.S) | Access: \(.access_count.N // \"0\")\n    ID: \(.knowledge_id.S)\n\""
}

# ============================================================
# FETCH - Fetch specific pattern by ID (v2)
# ============================================================
cmd_fetch() {
    local knowledge_id="$1"

    if [[ -z "$knowledge_id" ]]; then
        echo -e "${RED}Usage: gua fetch <knowledge_id>${NC}"
        echo "Example: gua fetch pattern-bridge-over-replace"
        echo ""
        echo "Find IDs with: gua search <query>"
        exit 1
    fi

    load_config

    echo -e "${BLUE}[GUA] Fetching: $knowledge_id${NC}"

    # Get from index
    local item=$(aws dynamodb get-item \
        --table-name "gua-knowledge-index" \
        --key "{\"user_id\": {\"S\": \"$USER_ID\"}, \"knowledge_id\": {\"S\": \"$knowledge_id\"}}" \
        --region "$REGION" 2>/dev/null)

    if [[ -z "$item" || "$(echo "$item" | jq '.Item')" == "null" ]]; then
        echo -e "${RED}Not found: $knowledge_id${NC}"
        exit 1
    fi

    local s3_key=$(echo "$item" | jq -r '.Item.s3_key.S // empty')
    local name=$(echo "$item" | jq -r '.Item.name.S // "Unknown"')

    echo ""
    echo "=== $name ==="
    echo ""

    # If S3 key exists, fetch full content
    if [[ -n "$s3_key" ]]; then
        local local_file="$HOME/.claude/purpose_prompter/$s3_key"
        mkdir -p "$(dirname "$local_file")"

        aws s3 cp "s3://$S3_BUCKET/$s3_key" "$local_file" --region "$REGION" 2>/dev/null

        if [[ -f "$local_file" ]]; then
            cat "$local_file"
        else
            # Fall back to index summary
            echo "$item" | jq -r '.Item | "Dimension: \(.pp_dimension.S)\nType: \(.knowledge_type.S)\nConfidence: \(.confidence.S)\n\nSummary:\n\(.summary.S // "No summary")"'
        fi
    else
        # No S3 key, show index data
        echo "$item" | jq -r '.Item | "Dimension: \(.pp_dimension.S)\nType: \(.knowledge_type.S)\nConfidence: \(.confidence.S)\n\nSummary:\n\(.summary.S // "No summary")"'
    fi

    # Track access
    cmd_track "$knowledge_id" 2>/dev/null || true
}

# ============================================================
# TRACK - Record access to pattern (v2)
# ============================================================
cmd_track() {
    local knowledge_id="$1"

    if [[ -z "$knowledge_id" ]]; then
        echo -e "${RED}Usage: gua track <knowledge_id>${NC}"
        exit 1
    fi

    load_config

    local ts=$(timestamp)

    # Update access count and recalculate access_score
    # access_score = access_count * frequency_weight + recency_score * recency_weight
    # For simplicity, just increment access_count and update last_accessed

    aws dynamodb update-item \
        --table-name "gua-knowledge-index" \
        --key "{\"user_id\": {\"S\": \"$USER_ID\"}, \"knowledge_id\": {\"S\": \"$knowledge_id\"}}" \
        --update-expression "SET access_count = if_not_exists(access_count, :zero) + :inc, last_accessed = :ts, access_score = if_not_exists(access_count, :zero) + :inc" \
        --expression-attribute-values "{\":inc\": {\"N\": \"1\"}, \":zero\": {\"N\": \"0\"}, \":ts\": {\"S\": \"$ts\"}}" \
        --region "$REGION" 2>/dev/null

    # Silent success - this is usually called automatically
}

# ============================================================
# ACTIVE-SET - Show current active set (v2)
# ============================================================
cmd_active_set() {
    echo -e "${BLUE}[GUA] Active Set${NC}"
    echo ""

    load_config

    local max_patterns=$(jq -r '.active_set.max_patterns // 50' "$CONFIG_FILE")

    # Query top patterns
    local patterns=$(aws dynamodb query \
        --table-name "gua-knowledge-index" \
        --index-name "access-score-index" \
        --key-condition-expression "user_id = :uid" \
        --expression-attribute-values "{\":uid\": {\"S\": \"$USER_ID\"}}" \
        --no-scan-index-forward \
        --limit "$max_patterns" \
        --region "$REGION" 2>/dev/null)

    echo "Top $max_patterns by access frequency:"
    echo ""

    echo "$patterns" | jq -r '.Items[] | "[\(.access_count.N // "0" | tonumber)] \(.name.S) (\(.pp_dimension.S))"' | head -20
}

# ============================================================
# INDEX-ADD - Add item to knowledge index (v2)
# ============================================================
cmd_index_add() {
    local name="$1"
    local dimension="$2"
    local ktype="${3:-pattern}"
    local summary="$4"
    local s3_key="$5"

    if [[ -z "$name" || -z "$dimension" ]]; then
        echo -e "${RED}Usage: gua index-add <name> <dimension> [type] [summary] [s3_key]${NC}"
        echo "Example: gua index-add 'Bridge Over Replace' creativity pattern 'Extend instead of replace'"
        exit 1
    fi

    load_config

    local knowledge_id="${ktype}-$(echo "$name" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')"
    local ts=$(timestamp)

    aws dynamodb put-item \
        --table-name "gua-knowledge-index" \
        --item "{
            \"user_id\": {\"S\": \"$USER_ID\"},
            \"knowledge_id\": {\"S\": \"$knowledge_id\"},
            \"name\": {\"S\": \"$name\"},
            \"pp_dimension\": {\"S\": \"$dimension\"},
            \"knowledge_type\": {\"S\": \"$ktype\"},
            \"confidence\": {\"S\": \"emerging\"},
            \"scope\": {\"S\": \"global\"},
            \"depth_level\": {\"N\": \"1\"},
            \"access_count\": {\"N\": \"0\"},
            \"access_score\": {\"N\": \"0\"},
            \"last_accessed\": {\"S\": \"never\"},
            \"created_at\": {\"S\": \"$ts\"},
            \"s3_key\": {\"S\": \"${s3_key:-}\"},
            \"summary\": {\"S\": \"${summary:-No summary}\"},
            \"is_active\": {\"BOOL\": true}
        }" \
        --region "$REGION"

    echo -e "${GREEN}[GUA] Indexed: $name (ID: $knowledge_id)${NC}"
}

# ============================================================
# GENERATE-LIGHT - Regenerate LIGHT.md from index (v2)
# ============================================================
cmd_generate_light() {
    echo -e "${BLUE}[GUA] Regenerating LIGHT.md from index...${NC}"

    load_config

    local LOCAL_INTEGRATION="$HOME/.claude/purpose_prompter/integration"
    mkdir -p "$LOCAL_INTEGRATION"

    # Get all confirmed patterns
    local confirmed=$(aws dynamodb scan \
        --table-name "gua-knowledge-index" \
        --filter-expression "user_id = :uid AND confidence = :conf" \
        --expression-attribute-values "{\":uid\": {\"S\": \"$USER_ID\"}, \":conf\": {\"S\": \"confirmed\"}}" \
        --region "$REGION" 2>/dev/null)

    # Get all emerging patterns
    local emerging=$(aws dynamodb scan \
        --table-name "gua-knowledge-index" \
        --filter-expression "user_id = :uid AND confidence = :conf" \
        --expression-attribute-values "{\":uid\": {\"S\": \"$USER_ID\"}, \":conf\": {\"S\": \"emerging\"}}" \
        --region "$REGION" 2>/dev/null)

    # Get all active blindspots
    local blindspots=$(aws dynamodb scan \
        --table-name "gua-knowledge-index" \
        --filter-expression "user_id = :uid AND knowledge_type = :kt AND is_active = :active" \
        --expression-attribute-values "{\":uid\": {\"S\": \"$USER_ID\"}, \":kt\": {\"S\": \"blindspot\"}, \":active\": {\"BOOL\": true}}" \
        --region "$REGION" 2>/dev/null)

    local confirmed_count=$(echo "$confirmed" | jq '.Count // 0')
    local emerging_count=$(echo "$emerging" | jq '.Count // 0')
    local blindspot_count=$(echo "$blindspots" | jq '.Count // 0')

    # Generate LIGHT.md with improved formatting
    cat > "$LOCAL_INTEGRATION/LIGHT.md" << 'EOF'
# LIGHT - Accumulated Understanding

> This file is auto-injected into Claude Code sessions via GUA.
> It contains patterns and blindspots accumulated across sessions.

EOF

    cat >> "$LOCAL_INTEGRATION/LIGHT.md" << EOF
**Last synthesized**: $(date -u +"%Y-%m-%d %H:%M UTC")
**Patterns**: $((confirmed_count + emerging_count)) | **Blindspots**: $blindspot_count

---

## BLINDSPOTS (Check Before Every Task)

EOF

    # Add blindspots - filter out null/empty names, truncate long names
    echo "$blindspots" | jq -r '
        .Items[]
        | select(.name.S != null and .name.S != "" and .name.S != "null")
        | "**\(.name.S | .[0:60])**\n> \(.summary.S // "Watch for this pattern" | .[0:150])\n"
    ' >> "$LOCAL_INTEGRATION/LIGHT.md" 2>/dev/null || true

    cat >> "$LOCAL_INTEGRATION/LIGHT.md" << 'EOF'

---

## TOP PATTERNS (Most Accessed)

EOF

    # Add confirmed patterns - filter nulls, truncate, limit to top 15
    echo "$confirmed" | jq -r '
        [.Items[]
        | select(.name.S != null and .name.S != "" and .name.S != "null")
        | {name: .name.S, dim: .pp_dimension.S, type: .knowledge_type.S, summary: .summary.S, access: (.access_count.N // "0" | tonumber)}]
        | sort_by(-.access)
        | .[0:15]
        | .[]
        | "### \(.name | .[0:50])\n- **[\(.dim | ascii_upcase)]** \(.type) | accessed \(.access)x\n- \(.summary // "No summary" | .[0:200])\n"
    ' >> "$LOCAL_INTEGRATION/LIGHT.md" 2>/dev/null || true

    cat >> "$LOCAL_INTEGRATION/LIGHT.md" << 'EOF'

---

## EMERGING (Needs Validation)

EOF

    # Add emerging patterns - limit to 10
    echo "$emerging" | jq -r '
        [.Items[]
        | select(.name.S != null and .name.S != "" and .name.S != "null")]
        | .[0:10]
        | .[]
        | "- **\(.name.S | .[0:50])** [\(.pp_dimension.S)]: \(.summary.S // "Needs summary" | .[0:100])"
    ' >> "$LOCAL_INTEGRATION/LIGHT.md" 2>/dev/null || true

    cat >> "$LOCAL_INTEGRATION/LIGHT.md" << EOF

---

*GUA v2 | $((confirmed_count + emerging_count + blindspot_count)) items indexed | \`gua search <query>\` to find more*
EOF

    # Upload to S3
    aws s3 cp "$LOCAL_INTEGRATION/LIGHT.md" "s3://$S3_BUCKET/documents/LIGHT.md" --region "$REGION"

    # Also generate condensed CONTEXT.md for auto-injection
    cmd_generate_context

    echo -e "${GREEN}[GUA] LIGHT.md regenerated ($confirmed_count confirmed, $emerging_count emerging, $blindspot_count blindspots)${NC}"
}

# ============================================================
# GENERATE-CONTEXT - Create condensed context for auto-injection
# ============================================================
cmd_generate_context() {
    load_config

    local LOCAL_INTEGRATION="$HOME/.claude/purpose_prompter/integration"
    local CONTEXT_FILE="$LOCAL_INTEGRATION/CONTEXT.md"
    mkdir -p "$LOCAL_INTEGRATION"

    # Get top blindspots (max 3)
    local blindspots=$(aws dynamodb scan \
        --table-name "gua-knowledge-index" \
        --filter-expression "user_id = :uid AND knowledge_type = :kt AND is_active = :active" \
        --expression-attribute-values "{\":uid\": {\"S\": \"$USER_ID\"}, \":kt\": {\"S\": \"blindspot\"}, \":active\": {\"BOOL\": true}}" \
        --region "$REGION" 2>/dev/null)

    # Get top 5 most accessed patterns (only pattern, technique, anti-pattern, blindspot types)
    local patterns=$(aws dynamodb query \
        --table-name "gua-knowledge-index" \
        --index-name "access-score-index" \
        --key-condition-expression "user_id = :uid" \
        --filter-expression "knowledge_type IN (:t1, :t2, :t3, :t4)" \
        --expression-attribute-values "{\":uid\": {\"S\": \"$USER_ID\"}, \":t1\": {\"S\": \"pattern\"}, \":t2\": {\"S\": \"technique\"}, \":t3\": {\"S\": \"anti-pattern\"}, \":t4\": {\"S\": \"model\"}}" \
        --no-scan-index-forward \
        --limit 15 \
        --region "$REGION" 2>/dev/null)

    # Get recent challenges (open)
    local challenges=$(aws dynamodb scan \
        --table-name "gua-knowledge-index" \
        --filter-expression "user_id = :uid AND knowledge_type = :kt AND #st = :status" \
        --expression-attribute-names '{"#st": "status"}' \
        --expression-attribute-values "{\":uid\": {\"S\": \"$USER_ID\"}, \":kt\": {\"S\": \"challenge\"}, \":status\": {\"S\": \"active\"}}" \
        --limit 3 \
        --region "$REGION" 2>/dev/null)

    # Generate condensed CONTEXT.md
    cat > "$CONTEXT_FILE" << 'EOF'
# GUA Session Context

> Auto-loaded accumulated knowledge. Review before starting work.

## Active Blindspots
EOF

    echo "$blindspots" | jq -r '
        [.Items[] | select(.name.S != null and .name.S != "null")] | .[0:3] | .[]
        | "- **\(.name.S | .[0:40])**: \(.summary.S // "Be careful here" | .[0:80])"
    ' >> "$CONTEXT_FILE" 2>/dev/null || echo "- None active" >> "$CONTEXT_FILE"

    cat >> "$CONTEXT_FILE" << 'EOF'

## Key Patterns
EOF

    echo "$patterns" | jq -r '
        [.Items[] | select(.name.S != null and .name.S != "null" and (.name.S | length) < 50)] | .[0:5] | .[]
        | "- **\(.name.S)** [\(.pp_dimension.S // "general")]: \(.summary.S // "" | .[0:70])"
    ' >> "$CONTEXT_FILE" 2>/dev/null || echo "- None captured yet" >> "$CONTEXT_FILE"

    local challenge_count=$(echo "$challenges" | jq '.Count // 0')
    if [[ "$challenge_count" -gt 0 ]]; then
        cat >> "$CONTEXT_FILE" << 'EOF'

## Open Challenges
EOF
        echo "$challenges" | jq -r '
            .Items[] | "- \(.description.S // .name.S | .[0:60])"
        ' >> "$CONTEXT_FILE" 2>/dev/null
    fi

    cat >> "$CONTEXT_FILE" << 'EOF'

---
*Run `gua context` for full context or `gua search <query>` to find specific knowledge*
EOF

    echo "  Generated CONTEXT.md for auto-injection"
}

# ============================================================
# CONTEXT-QUICK - Display condensed context (for quick review)
# ============================================================
cmd_context_quick() {
    local mode="${1:-quick}"

    load_config

    local LOCAL_INTEGRATION="$HOME/.claude/purpose_prompter/integration"
    local CONTEXT_FILE="$LOCAL_INTEGRATION/CONTEXT.md"
    local LIGHT_FILE="$LOCAL_INTEGRATION/LIGHT.md"

    case "$mode" in
        quick)
            # Show condensed context
            if [[ -f "$CONTEXT_FILE" ]]; then
                cat "$CONTEXT_FILE"
            else
                echo -e "${YELLOW}[GUA] Context not generated yet. Generating...${NC}"
                cmd_generate_context
                cat "$CONTEXT_FILE"
            fi
            ;;
        full)
            # Show full LIGHT.md
            if [[ -f "$LIGHT_FILE" ]]; then
                cat "$LIGHT_FILE"
            else
                echo -e "${YELLOW}[GUA] LIGHT.md not found. Run: gua load${NC}"
            fi
            ;;
        refresh)
            # Regenerate and show
            echo -e "${BLUE}[GUA] Refreshing context...${NC}"
            cmd_generate_context
            cat "$CONTEXT_FILE"
            ;;
        inject)
            # Output format suitable for injection into CLAUDE.md or prompts
            echo ""
            echo "<!-- GUA AUTO-CONTEXT START -->"
            if [[ -f "$CONTEXT_FILE" ]]; then
                cat "$CONTEXT_FILE"
            fi
            echo "<!-- GUA AUTO-CONTEXT END -->"
            echo ""
            ;;
        *)
            echo "Usage: gua context [quick|full|refresh|inject]"
            echo ""
            echo "Modes:"
            echo "  quick    Show condensed context (default)"
            echo "  full     Show full LIGHT.md"
            echo "  refresh  Regenerate and show context"
            echo "  inject   Output in injection format"
            ;;
    esac
}

# ============================================================
# CPT - CODE PROGRESS TRACKER
# ============================================================

# Check if CPT is enabled
is_cpt_enabled() {
    local enabled=$(jq -r '.cpt.enabled // false' "$CONFIG_FILE" 2>/dev/null)
    [[ "$enabled" == "true" ]]
}

# Generate area_id from project and path
generate_area_id() {
    local project="$1"
    local path="$2"
    local hash=$(echo -n "$path" | md5sum | cut -c1-8)
    echo "area#${project}#${hash}"
}

# ============================================================
# AREA ADD - Add a code area to track
# ============================================================
cmd_area_add() {
    local project="$1"
    local path="$2"
    local name="${3:-$path}"
    local granularity="${4:-domain}"

    if [[ -z "$project" || -z "$path" ]]; then
        echo -e "${RED}Usage: gua area add <project> <path> [name] [granularity]${NC}"
        echo ""
        echo "Granularity: domain | module | file | function"
        echo ""
        echo "Example: gua area add purpose_prompter gua/ 'GUA System' domain"
        exit 1
    fi

    load_config

    local area_id=$(generate_area_id "$project" "$path")
    local ts=$(timestamp)

    aws dynamodb put-item \
        --table-name "gua-knowledge-index" \
        --item "{
            \"user_id\": {\"S\": \"$USER_ID\"},
            \"knowledge_id\": {\"S\": \"$area_id\"},
            \"knowledge_type\": {\"S\": \"code_area\"},
            \"name\": {\"S\": \"$name\"},
            \"project\": {\"S\": \"$project\"},
            \"path\": {\"S\": \"$path\"},
            \"granularity\": {\"S\": \"$granularity\"},
            \"implementation_status\": {\"S\": \"not_started\"},
            \"implementation_pct\": {\"N\": \"0\"},
            \"understanding_depth\": {\"S\": \"L0\"},
            \"understanding_confidence\": {\"S\": \"none\"},
            \"mental_model\": {\"S\": \"\"},
            \"active_challenges\": {\"N\": \"0\"},
            \"pp_dimension\": {\"S\": \"understanding\"},
            \"confidence\": {\"S\": \"emerging\"},
            \"scope\": {\"S\": \"project\"},
            \"access_count\": {\"N\": \"0\"},
            \"access_score\": {\"N\": \"0\"},
            \"created_at\": {\"S\": \"$ts\"},
            \"updated_at\": {\"S\": \"$ts\"},
            \"is_active\": {\"BOOL\": true}
        }" \
        --region "$REGION"

    echo -e "${GREEN}[CPT] Area added: $name${NC}"
    echo "  ID: $area_id"
    echo "  Project: $project"
    echo "  Path: $path"
    echo "  Granularity: $granularity"
}

# ============================================================
# AREA STATUS - Show all areas for a project
# ============================================================
cmd_area_status() {
    local project="${1:-}"

    echo -e "${BLUE}[CPT] Code Areas${NC}"
    echo ""

    load_config

    local filter_expr="user_id = :uid AND knowledge_type = :kt"
    local attr_values="{\":uid\": {\"S\": \"$USER_ID\"}, \":kt\": {\"S\": \"code_area\"}}"

    if [[ -n "$project" ]]; then
        filter_expr="$filter_expr AND project = :proj"
        attr_values="{\":uid\": {\"S\": \"$USER_ID\"}, \":kt\": {\"S\": \"code_area\"}, \":proj\": {\"S\": \"$project\"}}"
    fi

    local areas=$(aws dynamodb scan \
        --table-name "gua-knowledge-index" \
        --filter-expression "$filter_expr" \
        --expression-attribute-values "$attr_values" \
        --region "$REGION" 2>/dev/null)

    local count=$(echo "$areas" | jq '.Count // 0')

    if [[ "$count" == "0" ]]; then
        echo "No areas tracked yet."
        echo ""
        echo "Add an area: gua area add <project> <path> [name]"
        return
    fi

    # Group by project
    echo "$areas" | jq -r '.Items | group_by(.project.S)[] |
        "Project: \(.[0].project.S)\n" +
        (. | map("  [\(.implementation_status.S | .[0:3] | ascii_upcase)] \(.name.S)\n      Path: \(.path.S)\n      Impl: \(.implementation_pct.N // "0")% | Depth: \(.understanding_depth.S // "L0")\n      ID: \(.knowledge_id.S)\n") | join(""))'
}

# ============================================================
# AREA UPDATE - Update area progress
# ============================================================
cmd_area_update() {
    local area_id="$1"
    shift

    if [[ -z "$area_id" ]]; then
        echo -e "${RED}Usage: gua area update <area_id> [--impl <pct>] [--depth <L0-L4>] [--status <status>] [--model <description>]${NC}"
        echo ""
        echo "Status: not_started | in_progress | blocked | completed"
        echo "Depth: L0 (unread) | L1 (surveyed) | L2 (understood) | L3 (deep) | L4 (expert)"
        exit 1
    fi

    load_config

    local update_expr="SET updated_at = :ts"
    local attr_values="{\":ts\": {\"S\": \"$(timestamp)\"}}"
    local attr_names="{}"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --impl)
                update_expr="$update_expr, implementation_pct = :impl"
                attr_values=$(echo "$attr_values" | jq ". + {\":impl\": {\"N\": \"$2\"}}")
                shift 2
                ;;
            --depth)
                update_expr="$update_expr, understanding_depth = :depth"
                attr_values=$(echo "$attr_values" | jq ". + {\":depth\": {\"S\": \"$2\"}}")
                shift 2
                ;;
            --status)
                update_expr="$update_expr, implementation_status = :status"
                attr_values=$(echo "$attr_values" | jq ". + {\":status\": {\"S\": \"$2\"}}")
                shift 2
                ;;
            --model)
                update_expr="$update_expr, mental_model = :model"
                attr_values=$(echo "$attr_values" | jq ". + {\":model\": {\"S\": \"$2\"}}")
                shift 2
                ;;
            --confidence)
                update_expr="$update_expr, understanding_confidence = :conf"
                attr_values=$(echo "$attr_values" | jq ". + {\":conf\": {\"S\": \"$2\"}}")
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done

    aws dynamodb update-item \
        --table-name "gua-knowledge-index" \
        --key "{\"user_id\": {\"S\": \"$USER_ID\"}, \"knowledge_id\": {\"S\": \"$area_id\"}}" \
        --update-expression "$update_expr" \
        --expression-attribute-values "$attr_values" \
        --region "$REGION" 2>/dev/null

    echo -e "${GREEN}[CPT] Area updated: $area_id${NC}"
}

# ============================================================
# CHALLENGE LOG - Log a new challenge
# ============================================================
cmd_challenge_log() {
    local area_id="$1"
    local description="$2"
    local pp_dimension="${3:-understanding}"
    local category="${4:-confusion}"

    if [[ -z "$area_id" || -z "$description" ]]; then
        echo -e "${RED}Usage: gua challenge log <area_id> <description> [pp_dimension] [category]${NC}"
        echo ""
        echo "PP Dimensions: truth | understanding | beauty | justice | creativity"
        echo "Categories: bug | confusion | ugly_hack | wrong_place | dead_end"
        echo ""
        echo "Example: gua challenge log area#pp#abc123 'Empty query results' truth bug"
        exit 1
    fi

    load_config

    local ts=$(timestamp)
    local id=$(uuid)
    local challenge_id="challenge#${ts}#${id}"

    aws dynamodb put-item \
        --table-name "gua-knowledge-index" \
        --item "{
            \"user_id\": {\"S\": \"$USER_ID\"},
            \"knowledge_id\": {\"S\": \"$challenge_id\"},
            \"knowledge_type\": {\"S\": \"challenge\"},
            \"name\": {\"S\": \"$description\"},
            \"area_id\": {\"S\": \"$area_id\"},
            \"description\": {\"S\": \"$description\"},
            \"category\": {\"S\": \"$category\"},
            \"pp_dimension\": {\"S\": \"$pp_dimension\"},
            \"status\": {\"S\": \"active\"},
            \"confidence\": {\"S\": \"hypothesis\"},
            \"scope\": {\"S\": \"project\"},
            \"access_count\": {\"N\": \"0\"},
            \"access_score\": {\"N\": \"0\"},
            \"created_at\": {\"S\": \"$ts\"},
            \"is_active\": {\"BOOL\": true}
        }" \
        --region "$REGION"

    # Increment active_challenges on the area
    aws dynamodb update-item \
        --table-name "gua-knowledge-index" \
        --key "{\"user_id\": {\"S\": \"$USER_ID\"}, \"knowledge_id\": {\"S\": \"$area_id\"}}" \
        --update-expression "SET active_challenges = if_not_exists(active_challenges, :zero) + :inc" \
        --expression-attribute-values "{\":inc\": {\"N\": \"1\"}, \":zero\": {\"N\": \"0\"}}" \
        --region "$REGION" 2>/dev/null || true

    echo -e "${GREEN}[CPT] Challenge logged${NC}"
    echo "  ID: $challenge_id"
    echo "  Area: $area_id"
    echo "  PP Dimension: $pp_dimension"
    echo "  Category: $category"
    echo "  Description: $description"
}

# ============================================================
# CHALLENGE RESOLVE - Resolve a challenge
# ============================================================
cmd_challenge_resolve() {
    local challenge_id="$1"
    local resolution="$2"
    shift 2

    if [[ -z "$challenge_id" || -z "$resolution" ]]; then
        echo -e "${RED}Usage: gua challenge resolve <challenge_id> <resolution> [--learning <insight>]${NC}"
        exit 1
    fi

    load_config

    local ts=$(timestamp)
    local learning=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --learning)
                learning="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done

    # Get the challenge to find area_id
    local challenge=$(aws dynamodb get-item \
        --table-name "gua-knowledge-index" \
        --key "{\"user_id\": {\"S\": \"$USER_ID\"}, \"knowledge_id\": {\"S\": \"$challenge_id\"}}" \
        --region "$REGION" 2>/dev/null)

    local area_id=$(echo "$challenge" | jq -r '.Item.area_id.S // empty')

    # Update challenge status
    local update_expr="SET #st = :resolved, resolution = :res, resolved_at = :ts"
    local attr_values="{\":resolved\": {\"S\": \"resolved\"}, \":res\": {\"S\": \"$resolution\"}, \":ts\": {\"S\": \"$ts\"}}"

    if [[ -n "$learning" ]]; then
        update_expr="$update_expr, learnings = :learn"
        attr_values=$(echo "$attr_values" | jq ". + {\":learn\": {\"L\": [{\"S\": \"$learning\"}]}}")
    fi

    aws dynamodb update-item \
        --table-name "gua-knowledge-index" \
        --key "{\"user_id\": {\"S\": \"$USER_ID\"}, \"knowledge_id\": {\"S\": \"$challenge_id\"}}" \
        --update-expression "$update_expr" \
        --expression-attribute-names '{"#st": "status"}' \
        --expression-attribute-values "$attr_values" \
        --region "$REGION" 2>/dev/null

    # Decrement active_challenges on the area
    if [[ -n "$area_id" ]]; then
        aws dynamodb update-item \
            --table-name "gua-knowledge-index" \
            --key "{\"user_id\": {\"S\": \"$USER_ID\"}, \"knowledge_id\": {\"S\": \"$area_id\"}}" \
            --update-expression "SET active_challenges = active_challenges - :dec" \
            --expression-attribute-values "{\":dec\": {\"N\": \"1\"}}" \
            --region "$REGION" 2>/dev/null || true
    fi

    echo -e "${GREEN}[CPT] Challenge resolved${NC}"
    echo "  ID: $challenge_id"
    echo "  Resolution: $resolution"
    if [[ -n "$learning" ]]; then
        echo "  Learning: $learning"
    fi
}

# ============================================================
# CHALLENGE LIST - List challenges
# ============================================================
cmd_challenge_list() {
    local area_filter=""
    local status_filter="active"
    local dimension_filter=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --area)
                area_filter="$2"
                shift 2
                ;;
            --status)
                status_filter="$2"
                shift 2
                ;;
            --dimension)
                dimension_filter="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done

    echo -e "${BLUE}[CPT] Challenges (status: $status_filter)${NC}"
    echo ""

    load_config

    local filter_expr="user_id = :uid AND knowledge_type = :kt AND #st = :status"
    local attr_values="{\":uid\": {\"S\": \"$USER_ID\"}, \":kt\": {\"S\": \"challenge\"}, \":status\": {\"S\": \"$status_filter\"}}"

    if [[ -n "$dimension_filter" ]]; then
        filter_expr="$filter_expr AND pp_dimension = :dim"
        attr_values=$(echo "$attr_values" | jq ". + {\":dim\": {\"S\": \"$dimension_filter\"}}")
    fi

    if [[ -n "$area_filter" ]]; then
        filter_expr="$filter_expr AND area_id = :area"
        attr_values=$(echo "$attr_values" | jq ". + {\":area\": {\"S\": \"$area_filter\"}}")
    fi

    local challenges=$(aws dynamodb scan \
        --table-name "gua-knowledge-index" \
        --filter-expression "$filter_expr" \
        --expression-attribute-names '{"#st": "status"}' \
        --expression-attribute-values "$attr_values" \
        --region "$REGION" 2>/dev/null)

    local count=$(echo "$challenges" | jq '.Count // 0')

    if [[ "$count" == "0" ]]; then
        echo "No $status_filter challenges found."
        return
    fi

    echo "$challenges" | jq -r '.Items[] | "[\(.pp_dimension.S | .[0:5] | ascii_upcase)] \(.description.S)\n    Category: \(.category.S // "unknown") | Created: \(.created_at.S | split("T")[0])\n    ID: \(.knowledge_id.S)\n"'
}

# ============================================================
# CHALLENGE PROMOTE - Promote challenge learning to insight
# ============================================================
cmd_challenge_promote() {
    local challenge_id="$1"

    if [[ -z "$challenge_id" ]]; then
        echo -e "${RED}Usage: gua challenge promote <challenge_id>${NC}"
        exit 1
    fi

    load_config

    # Get the challenge
    local challenge=$(aws dynamodb get-item \
        --table-name "gua-knowledge-index" \
        --key "{\"user_id\": {\"S\": \"$USER_ID\"}, \"knowledge_id\": {\"S\": \"$challenge_id\"}}" \
        --region "$REGION" 2>/dev/null)

    local description=$(echo "$challenge" | jq -r '.Item.description.S // empty')
    local resolution=$(echo "$challenge" | jq -r '.Item.resolution.S // empty')
    local pp_dimension=$(echo "$challenge" | jq -r '.Item.pp_dimension.S // "understanding"')
    local learnings=$(echo "$challenge" | jq -r '.Item.learnings.L[0].S // empty')

    if [[ -z "$description" ]]; then
        echo -e "${RED}Challenge not found: $challenge_id${NC}"
        exit 1
    fi

    # Create insight from challenge
    local content="Challenge: $description | Resolution: $resolution"
    if [[ -n "$learnings" ]]; then
        content="$learnings (from challenge: $description)"
    fi

    cmd_insight_log "$content" "pattern" "CPT challenge resolution" "$pp_dimension" "global"

    # Mark challenge as promoted
    aws dynamodb update-item \
        --table-name "gua-knowledge-index" \
        --key "{\"user_id\": {\"S\": \"$USER_ID\"}, \"knowledge_id\": {\"S\": \"$challenge_id\"}}" \
        --update-expression "SET promoted = :t" \
        --expression-attribute-values "{\":t\": {\"BOOL\": true}}" \
        --region "$REGION" 2>/dev/null

    echo -e "${GREEN}[CPT] Challenge promoted to insight${NC}"
}

# ============================================================
# CHALLENGE HARVEST - Extract value from resolved challenges
# ============================================================
cmd_challenge_harvest() {
    local auto_promote="false"
    local days="30"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --auto)
                auto_promote="true"
                shift
                ;;
            --days)
                days="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done

    load_config

    echo -e "${BLUE}[CPT] Harvesting value from resolved challenges (last $days days)${NC}"
    echo ""

    # Find resolved challenges with learnings that haven't been promoted
    local challenges=$(aws dynamodb scan \
        --table-name "gua-knowledge-index" \
        --filter-expression "user_id = :uid AND knowledge_type = :kt AND #st = :resolved AND attribute_exists(learnings) AND (attribute_not_exists(promoted) OR promoted = :false)" \
        --expression-attribute-names '{"#st": "status"}' \
        --expression-attribute-values "{\":uid\": {\"S\": \"$USER_ID\"}, \":kt\": {\"S\": \"challenge\"}, \":resolved\": {\"S\": \"resolved\"}, \":false\": {\"BOOL\": false}}" \
        --region "$REGION" 2>/dev/null)

    local count=$(echo "$challenges" | jq '.Count // 0')

    if [[ "$count" == "0" ]]; then
        echo "No promotable challenges found."
        echo ""
        echo -e "${GREEN}All resolved challenges with learnings have been promoted!${NC}"
        return
    fi

    echo -e "${YELLOW}Found $count challenges with learnings ready for promotion:${NC}"
    echo ""

    # List each promotable challenge
    local ids=()
    while IFS= read -r challenge; do
        local cid=$(echo "$challenge" | jq -r '.knowledge_id.S')
        local desc=$(echo "$challenge" | jq -r '.description.S')
        local learning=$(echo "$challenge" | jq -r '.learnings.L[0].S // "No learning"')
        local dimension=$(echo "$challenge" | jq -r '.pp_dimension.S // "unknown"')
        local resolved_at=$(echo "$challenge" | jq -r '.resolved_at.S // "unknown" | split("T")[0]')

        ids+=("$cid")

        echo -e "${CYAN}[$dimension]${NC} $desc"
        echo "  Learning: $learning"
        echo "  Resolved: $resolved_at"
        echo "  ID: $cid"
        echo ""

        if [[ "$auto_promote" == "true" ]]; then
            cmd_challenge_promote "$cid"
            echo ""
        fi
    done < <(echo "$challenges" | jq -c '.Items[]')

    if [[ "$auto_promote" != "true" && "$count" -gt 0 ]]; then
        echo -e "${YELLOW}To promote these learnings to insights, run:${NC}"
        echo "  gua challenge harvest --auto"
        echo ""
        echo "Or promote individually:"
        for id in "${ids[@]}"; do
            echo "  gua challenge promote \"$id\""
        done
    fi
}

# ============================================================
# EMOTION LOG - Log an emotional signal
# ============================================================
cmd_emotion_log() {
    local emotion_type="$1"
    local trigger_context="$2"
    shift 2 2>/dev/null || true

    if [[ -z "$emotion_type" || -z "$trigger_context" ]]; then
        echo -e "${RED}Usage: gua emotion log <type> \"<trigger>\" [--code FILE:LINE] [--area ID] [--intensity I]${NC}"
        echo ""
        echo "Emotion types:"
        echo "  Signal:    disgust, frustration, anxiety"
        echo "  Pathology: despair, shame, pride, envy"
        echo ""
        echo "Options:"
        echo "  --code FILE:LINE   Code location that triggered emotion"
        echo "  --area ID          Link to existing code area"
        echo "  --intensity I      mild, moderate (default), strong"
        echo ""
        echo "Example: gua emotion log disgust 'Nested conditionals feel wrong' --code src/auth.ts:45"
        exit 1
    fi

    load_config

    # Parse optional flags
    local code_ref=""
    local area_id=""
    local intensity="moderate"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --code)
                code_ref="$2"
                shift 2
                ;;
            --area)
                area_id="$2"
                shift 2
                ;;
            --intensity)
                intensity="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done

    # Validate emotion type and determine category
    local category=""
    local pp_dimension=""
    local pp_signal=""

    case "$emotion_type" in
        disgust)
            category="signal"
            pp_dimension="beauty"
            pp_signal="ugliness"
            ;;
        frustration)
            category="signal"
            pp_dimension="creativity"
            pp_signal="stagnation"
            ;;
        anxiety)
            category="signal"
            pp_dimension="truth"
            pp_signal="truth_gap"
            ;;
        despair)
            category="pathology"
            pp_dimension=""
            pp_signal="cycle_break"
            ;;
        shame)
            category="pathology"
            pp_dimension=""
            pp_signal="generativity_block"
            ;;
        pride)
            category="pathology"
            pp_dimension=""
            pp_signal="longing_stop"
            ;;
        envy)
            category="pathology"
            pp_dimension=""
            pp_signal="misdirected_longing"
            ;;
        *)
            echo -e "${RED}Invalid emotion type: $emotion_type${NC}"
            echo "Valid types: disgust, frustration, anxiety, despair, shame, pride, envy"
            exit 1
            ;;
    esac

    # Generate ID
    local ts=$(timestamp)
    local id=$(uuid)
    local emotion_id="emotion#${ts}#${id}"

    # Get current session
    local session_id=$(cat "$GUA_DIR/current_session" 2>/dev/null || echo "")

    # Get current project from dir context if available
    local project=""
    if [[ -f ".gua/context.json" ]]; then
        project=$(jq -r '.project // ""' .gua/context.json 2>/dev/null || echo "")
    fi

    # Build item JSON dynamically (GSI keys can't have empty strings)
    local item_json="{
        \"user_id\": {\"S\": \"$USER_ID\"},
        \"knowledge_id\": {\"S\": \"$emotion_id\"},
        \"knowledge_type\": {\"S\": \"emotional_signal\"},
        \"emotion_type\": {\"S\": \"$emotion_type\"},
        \"emotion_category\": {\"S\": \"$category\"},
        \"intensity\": {\"S\": \"$intensity\"},
        \"trigger_context\": {\"S\": \"$trigger_context\"},
        \"pp_signal\": {\"S\": \"$pp_signal\"},
        \"status\": {\"S\": \"active\"},
        \"created_at\": {\"S\": \"$ts\"}"

    # Add optional fields only if they have values (GSI keys can't be empty)
    [[ -n "$code_ref" ]] && item_json="$item_json, \"trigger_code\": {\"S\": \"$code_ref\"}"
    [[ -n "$area_id" ]] && item_json="$item_json, \"trigger_area_id\": {\"S\": \"$area_id\"}"
    [[ -n "$pp_dimension" ]] && item_json="$item_json, \"pp_dimension\": {\"S\": \"$pp_dimension\"}"
    [[ -n "$session_id" ]] && item_json="$item_json, \"session_id\": {\"S\": \"$session_id\"}"
    [[ -n "$project" ]] && item_json="$item_json, \"project\": {\"S\": \"$project\"}"

    item_json="$item_json}"

    # Store in DynamoDB
    aws dynamodb put-item \
        --table-name "gua-knowledge-index" \
        --item "$item_json" \
        --region "$REGION"

    echo -e "${YELLOW}[EMOTION]${NC} Logged: $emotion_type ($category)"
    echo "  Trigger: $trigger_context"
    [[ -n "$code_ref" ]] && echo "  Code: $code_ref"
    [[ -n "$area_id" ]] && echo "  Area: $area_id"
    echo "  Intensity: $intensity"
    echo "  ID: $emotion_id"

    # Suggest next action
    if [[ "$category" == "pathology" ]]; then
        echo ""
        echo -e "${RED}PATHOLOGY detected${NC}"
        echo "  Consider addressing this before continuing work."
        echo "  See: EMOTION_GATES.md for guidance on $emotion_type"
        echo ""
        echo "  Resolve with: gua emotion resolve $emotion_id \"<how you addressed it>\""
    else
        echo ""
        echo -e "${BLUE}Signal noted${NC}"
        echo "  This signals: $pp_signal (incomplete $pp_dimension understanding)"
        echo "  Resolve with: gua emotion resolve $emotion_id \"<resolution>\""
    fi
}

# ============================================================
# EMOTION RESOLVE - Resolve an emotional signal
# ============================================================
cmd_emotion_resolve() {
    local emotion_id="$1"
    local resolution="$2"
    shift 2 2>/dev/null || true

    if [[ -z "$emotion_id" || -z "$resolution" ]]; then
        echo -e "${RED}Usage: gua emotion resolve <id> \"<resolution>\" [--learning \"...\"] [--time MINS]${NC}"
        echo ""
        echo "Options:"
        echo "  --learning \"...\"  Capture insight from resolution"
        echo "  --time MINS       Time spent resolving (minutes)"
        exit 1
    fi

    load_config

    local ts=$(timestamp)
    local learning=""
    local time_spent=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --learning)
                learning="$2"
                shift 2
                ;;
            --time)
                time_spent="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done

    # Get the emotion to find category
    local emotion=$(aws dynamodb get-item \
        --table-name "gua-knowledge-index" \
        --key "{\"user_id\": {\"S\": \"$USER_ID\"}, \"knowledge_id\": {\"S\": \"$emotion_id\"}}" \
        --region "$REGION" 2>/dev/null)

    local emotion_type=$(echo "$emotion" | jq -r '.Item.emotion_type.S // empty')
    local category=$(echo "$emotion" | jq -r '.Item.emotion_category.S // empty')
    local pp_dimension=$(echo "$emotion" | jq -r '.Item.pp_dimension.S // empty')

    if [[ -z "$emotion_type" ]]; then
        echo -e "${RED}Emotion not found: $emotion_id${NC}"
        exit 1
    fi

    # Determine resolution type
    local resolution_type=""
    case "$emotion_type" in
        disgust) resolution_type="understanding" ;;
        frustration) resolution_type="creativity" ;;
        anxiety) resolution_type="truth_check" ;;
        *) resolution_type="addressed_pathology" ;;
    esac

    # Build update expression
    local update_expr="SET #st = :resolved, resolution = :res, resolved_at = :ts, resolution_type = :rtype"
    local attr_values="{\":resolved\": {\"S\": \"resolved\"}, \":res\": {\"S\": \"$resolution\"}, \":ts\": {\"S\": \"$ts\"}, \":rtype\": {\"S\": \"$resolution_type\"}}"

    if [[ -n "$learning" ]]; then
        update_expr="$update_expr, signal_meaning = :learn"
        attr_values=$(echo "$attr_values" | jq ". + {\":learn\": {\"S\": \"$learning\"}}")
    fi

    if [[ -n "$time_spent" ]]; then
        update_expr="$update_expr, time_to_resolve_mins = :time"
        attr_values=$(echo "$attr_values" | jq ". + {\":time\": {\"N\": \"$time_spent\"}}")
    fi

    aws dynamodb update-item \
        --table-name "gua-knowledge-index" \
        --key "{\"user_id\": {\"S\": \"$USER_ID\"}, \"knowledge_id\": {\"S\": \"$emotion_id\"}}" \
        --update-expression "$update_expr" \
        --expression-attribute-names '{"#st": "status"}' \
        --expression-attribute-values "$attr_values" \
        --region "$REGION" 2>/dev/null

    echo -e "${GREEN}[EMOTION]${NC} Resolved: $emotion_type"
    echo "  Resolution: $resolution"
    echo "  Type: $resolution_type"
    [[ -n "$learning" ]] && echo "  Learning: $learning"
    [[ -n "$time_spent" ]] && echo "  Time: ${time_spent} mins"
    echo ""
    echo "Consider promoting to knowledge: gua emotion promote $emotion_id"
}

# ============================================================
# EMOTION LIST - List emotional signals
# ============================================================
cmd_emotion_list() {
    local type_filter=""
    local status_filter=""
    local project_filter=""
    local limit=20

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --type)
                type_filter="$2"
                shift 2
                ;;
            --unresolved)
                status_filter="active"
                shift
                ;;
            --project)
                project_filter="$2"
                shift 2
                ;;
            --limit)
                limit="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done

    load_config

    local filter_expr="user_id = :uid AND knowledge_type = :kt"
    local attr_values="{\":uid\": {\"S\": \"$USER_ID\"}, \":kt\": {\"S\": \"emotional_signal\"}}"

    if [[ -n "$type_filter" ]]; then
        filter_expr="$filter_expr AND emotion_type = :et"
        attr_values=$(echo "$attr_values" | jq ". + {\":et\": {\"S\": \"$type_filter\"}}")
    fi

    if [[ -n "$status_filter" ]]; then
        filter_expr="$filter_expr AND #st = :st"
        attr_values=$(echo "$attr_values" | jq ". + {\":st\": {\"S\": \"$status_filter\"}}")
    fi

    if [[ -n "$project_filter" ]]; then
        filter_expr="$filter_expr AND project = :proj"
        attr_values=$(echo "$attr_values" | jq ". + {\":proj\": {\"S\": \"$project_filter\"}}")
    fi

    local names_arg=""
    if [[ -n "$status_filter" ]]; then
        names_arg='--expression-attribute-names {"#st": "status"}'
    fi

    local results=$(aws dynamodb scan \
        --table-name "gua-knowledge-index" \
        --filter-expression "$filter_expr" \
        --expression-attribute-values "$attr_values" \
        $names_arg \
        --region "$REGION" 2>/dev/null)

    echo -e "${YELLOW}[EMOTION]${NC} Emotional Signals"
    [[ -n "$type_filter" ]] && echo "  Type: $type_filter"
    [[ -n "$status_filter" ]] && echo "  Status: $status_filter"
    [[ -n "$project_filter" ]] && echo "  Project: $project_filter"
    echo ""

    # Format output
    echo "$results" | jq -r --argjson limit "$limit" '
        .Items
        | sort_by(.created_at.S)
        | reverse
        | .[0:$limit]
        | .[]
        | "\(.emotion_type.S | ascii_upcase) [\(.emotion_category.S)] - \(.status.S)"
        + "\n  Trigger: \(.trigger_context.S)"
        + (if .trigger_code.S != "" then "\n  Code: \(.trigger_code.S)" else "" end)
        + (if .resolution.S then "\n  Resolution: \(.resolution.S)" else "" end)
        + "\n  ID: \(.knowledge_id.S)"
        + "\n  Created: \(.created_at.S)\n"
    ' 2>/dev/null || echo "No emotions found"
}

# ============================================================
# EMOTION PATTERNS - Analyze emotional patterns
# ============================================================
cmd_emotion_patterns() {
    local type_filter=""
    local days=30

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --type)
                type_filter="$2"
                shift 2
                ;;
            --days)
                days="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done

    load_config

    local filter_expr="user_id = :uid AND knowledge_type = :kt"
    local attr_values="{\":uid\": {\"S\": \"$USER_ID\"}, \":kt\": {\"S\": \"emotional_signal\"}}"

    if [[ -n "$type_filter" ]]; then
        filter_expr="$filter_expr AND emotion_type = :et"
        attr_values=$(echo "$attr_values" | jq ". + {\":et\": {\"S\": \"$type_filter\"}}")
    fi

    local results=$(aws dynamodb scan \
        --table-name "gua-knowledge-index" \
        --filter-expression "$filter_expr" \
        --expression-attribute-values "$attr_values" \
        --region "$REGION" 2>/dev/null)

    echo -e "${YELLOW}=== EMOTIONAL PATTERNS (last ${days} days) ===${NC}"
    echo ""

    # Group by emotion type and analyze triggers
    echo "$results" | jq -r '
        .Items
        | group_by(.emotion_type.S)
        | .[]
        | {
            emotion: .[0].emotion_type.S,
            category: .[0].emotion_category.S,
            pp_dimension: .[0].pp_dimension.S,
            count: length,
            triggers: ([.[].trigger_context.S] | group_by(.) | map({trigger: .[0], count: length}) | sort_by(-.count) | .[0:5]),
            resolved: ([.[] | select(.status.S == "resolved")] | length),
            resolutions: ([.[] | select(.resolution.S != null and .resolution.S != "") | .resolution.S] | unique | .[0:3]),
            avg_time: (([.[] | select(.time_to_resolve_mins.N != null) | .time_to_resolve_mins.N | tonumber] | if length > 0 then (add / length | round) else null end))
          }
        | "[\(.emotion | ascii_upcase)] (\(.category)) - \(.count) occurrences (\(.resolved) resolved)"
        + (if .pp_dimension != "" then "\n  PP Dimension: \(.pp_dimension)" else "" end)
        + "\n  Top triggers:"
        + (.triggers | map("\n    - \(.trigger[0:60])... (x\(.count))") | join(""))
        + (if (.resolutions | length) > 0 then "\n  Common resolutions:\n" + (.resolutions | map("    - \(.[0:80])...") | join("\n")) else "" end)
        + (if .avg_time then "\n  Avg resolution time: \(.avg_time) mins" else "" end)
        + "\n"
    ' 2>/dev/null || echo "No emotional patterns found"

    echo ""
    echo -e "${BLUE}Tip:${NC} Promote recurring patterns to blindspots: gua emotion promote <id>"
}

# ============================================================
# EMOTION PROMOTE - Promote emotion to knowledge
# ============================================================
cmd_emotion_promote() {
    local emotion_id="$1"
    local promote_as="${2:-}"

    if [[ -z "$emotion_id" ]]; then
        echo -e "${RED}Usage: gua emotion promote <id> [--as pattern|blindspot|technique]${NC}"
        exit 1
    fi

    # Handle --as flag
    if [[ "$2" == "--as" ]]; then
        promote_as="$3"
    fi

    load_config

    # Get the emotion
    local emotion=$(aws dynamodb get-item \
        --table-name "gua-knowledge-index" \
        --key "{\"user_id\": {\"S\": \"$USER_ID\"}, \"knowledge_id\": {\"S\": \"$emotion_id\"}}" \
        --region "$REGION" 2>/dev/null)

    local emotion_type=$(echo "$emotion" | jq -r '.Item.emotion_type.S // empty')
    local trigger=$(echo "$emotion" | jq -r '.Item.trigger_context.S // empty')
    local resolution=$(echo "$emotion" | jq -r '.Item.resolution.S // empty')
    local learning=$(echo "$emotion" | jq -r '.Item.signal_meaning.S // empty')
    local pp_dimension=$(echo "$emotion" | jq -r '.Item.pp_dimension.S // empty')
    local status=$(echo "$emotion" | jq -r '.Item.status.S // empty')

    if [[ -z "$emotion_type" ]]; then
        echo -e "${RED}Emotion not found: $emotion_id${NC}"
        exit 1
    fi

    if [[ "$status" != "resolved" ]]; then
        echo -e "${RED}Emotion must be resolved before promoting${NC}"
        echo "Resolve first: gua emotion resolve $emotion_id \"<resolution>\""
        exit 1
    fi

    echo -e "${YELLOW}[EMOTION]${NC} Promoting: $emotion_type"
    echo "  Trigger: $trigger"
    echo "  Resolution: $resolution"
    [[ -n "$learning" ]] && echo "  Learning: $learning"
    echo ""

    # Default promote type based on emotion
    if [[ -z "$promote_as" ]]; then
        case "$emotion_type" in
            disgust|frustration) promote_as="blindspot" ;;
            anxiety) promote_as="technique" ;;
            *) promote_as="blindspot" ;;
        esac
    fi

    local insight_content=""
    case "$promote_as" in
        pattern)
            insight_content="When encountering: $trigger → Apply: $resolution"
            ;;
        blindspot)
            insight_content="Tendency to: $trigger → Resolution: $resolution"
            ;;
        technique)
            insight_content="To address $emotion_type when $trigger → $resolution"
            ;;
        *)
            echo -e "${RED}Invalid promote type: $promote_as${NC}"
            echo "Valid types: pattern, blindspot, technique"
            exit 1
            ;;
    esac

    # Create insight
    local ts=$(timestamp)
    local id=$(uuid)
    local insight_id="insight#${ts}#${id}"

    aws dynamodb put-item \
        --table-name "gua-knowledge-index" \
        --item "{
            \"user_id\": {\"S\": \"$USER_ID\"},
            \"knowledge_id\": {\"S\": \"$insight_id\"},
            \"knowledge_type\": {\"S\": \"insight\"},
            \"name\": {\"S\": \"$insight_content\"},
            \"insight_type\": {\"S\": \"$promote_as\"},
            \"pp_dimension\": {\"S\": \"${pp_dimension:-personal}\"},
            \"confidence\": {\"S\": \"emerging\"},
            \"scope\": {\"S\": \"personal\"},
            \"source_emotion\": {\"S\": \"$emotion_id\"},
            \"created_at\": {\"S\": \"$ts\"}
        }" \
        --region "$REGION"

    # Update emotion as promoted
    aws dynamodb update-item \
        --table-name "gua-knowledge-index" \
        --key "{\"user_id\": {\"S\": \"$USER_ID\"}, \"knowledge_id\": {\"S\": \"$emotion_id\"}}" \
        --update-expression "SET #st = :promoted, promotes_to = :insight" \
        --expression-attribute-names '{"#st": "status"}' \
        --expression-attribute-values "{\":promoted\": {\"S\": \"promoted\"}, \":insight\": {\"S\": \"$insight_id\"}}" \
        --region "$REGION" 2>/dev/null

    echo -e "${GREEN}[EMOTION]${NC} Promoted to $promote_as"
    echo "  Insight ID: $insight_id"
    echo "  Content: $insight_content"
    echo ""
    echo "View insights: gua query insights"
}

# ============================================================
# EMOTION HARVEST - Extract value from resolved emotions
# ============================================================
cmd_emotion_harvest() {
    local auto_promote="false"
    local promote_as=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --auto)
                auto_promote="true"
                shift
                ;;
            --as)
                promote_as="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done

    load_config

    echo -e "${YELLOW}[EMOTION]${NC} Harvesting value from resolved emotions"
    echo ""

    # Find resolved emotions that haven't been promoted
    local emotions=$(aws dynamodb scan \
        --table-name "gua-knowledge-index" \
        --filter-expression "user_id = :uid AND knowledge_type = :kt AND #st = :resolved" \
        --expression-attribute-names '{"#st": "status"}' \
        --expression-attribute-values "{\":uid\": {\"S\": \"$USER_ID\"}, \":kt\": {\"S\": \"emotional_signal\"}, \":resolved\": {\"S\": \"resolved\"}}" \
        --region "$REGION" 2>/dev/null)

    local count=$(echo "$emotions" | jq '.Count // 0')

    if [[ "$count" == "0" ]]; then
        echo "No resolved emotions ready for promotion."
        echo ""

        # Check for unresolved emotions
        local unresolved=$(aws dynamodb scan \
            --table-name "gua-knowledge-index" \
            --filter-expression "user_id = :uid AND knowledge_type = :kt AND #st = :active" \
            --expression-attribute-names '{"#st": "status"}' \
            --expression-attribute-values "{\":uid\": {\"S\": \"$USER_ID\"}, \":kt\": {\"S\": \"emotional_signal\"}, \":active\": {\"S\": \"active\"}}" \
            --select "COUNT" \
            --region "$REGION" 2>/dev/null | jq '.Count // 0')

        if [[ "$unresolved" -gt 0 ]]; then
            echo -e "${YELLOW}Found $unresolved unresolved emotions.${NC}"
            echo "Resolve them first: gua emotion resolve <id> \"<resolution>\""
            echo "List them: gua emotion list --unresolved"
        else
            echo -e "${GREEN}All emotions have been processed!${NC}"
        fi
        return
    fi

    echo -e "${CYAN}Found $count resolved emotions ready for promotion:${NC}"
    echo ""

    # Group by emotion type
    echo "By type:"
    echo "$emotions" | jq -r '[.Items[].emotion_type.S] | group_by(.) | map({type: .[0], count: length}) | .[] | "  \(.type): \(.count)"'
    echo ""

    # List each promotable emotion
    local ids=()
    local promoted_count=0
    while IFS= read -r emotion; do
        local eid=$(echo "$emotion" | jq -r '.knowledge_id.S')
        local etype=$(echo "$emotion" | jq -r '.emotion_type.S')
        local trigger=$(echo "$emotion" | jq -r '.trigger_context.S')
        local resolution=$(echo "$emotion" | jq -r '.resolution.S // "No resolution"')
        local dimension=$(echo "$emotion" | jq -r '.pp_dimension.S // "personal"')
        local created=$(echo "$emotion" | jq -r '.created_at.S | split("T")[0]')

        ids+=("$eid")

        echo -e "${CYAN}[$etype]${NC} $trigger"
        echo "  Resolution: $resolution"
        echo "  Dimension: $dimension | Created: $created"
        echo "  ID: $eid"
        echo ""

        if [[ "$auto_promote" == "true" ]]; then
            if [[ -n "$promote_as" ]]; then
                cmd_emotion_promote "$eid" "--as" "$promote_as"
            else
                cmd_emotion_promote "$eid"
            fi
            ((promoted_count++))
            echo ""
        fi
    done < <(echo "$emotions" | jq -c '.Items | sort_by(.created_at.S) | reverse | .[]')

    if [[ "$auto_promote" == "true" ]]; then
        echo -e "${GREEN}Promoted $promoted_count emotions to insights!${NC}"
    else
        echo -e "${YELLOW}To promote these emotions to insights, run:${NC}"
        echo "  gua emotion harvest --auto"
        echo ""
        echo "Or promote individually:"
        for id in "${ids[@]:0:5}"; do
            echo "  gua emotion promote \"$id\""
        done
        if [[ ${#ids[@]} -gt 5 ]]; then
            echo "  ... and $((${#ids[@]} - 5)) more"
        fi
    fi
}

# ============================================================
# PROGRESS - Show progress dashboard
# ============================================================
cmd_progress() {
    local project="${1:-}"

    echo -e "${BLUE}[CPT] Progress Dashboard${NC}"
    echo ""

    load_config

    # Get areas
    local filter_expr="user_id = :uid AND knowledge_type = :kt"
    local attr_values="{\":uid\": {\"S\": \"$USER_ID\"}, \":kt\": {\"S\": \"code_area\"}}"

    if [[ -n "$project" ]]; then
        filter_expr="$filter_expr AND project = :proj"
        attr_values=$(echo "$attr_values" | jq ". + {\":proj\": {\"S\": \"$project\"}}")
        echo "Project: $project"
    else
        echo "All Projects"
    fi
    echo ""

    local areas=$(aws dynamodb scan \
        --table-name "gua-knowledge-index" \
        --filter-expression "$filter_expr" \
        --expression-attribute-values "$attr_values" \
        --region "$REGION" 2>/dev/null)

    local area_count=$(echo "$areas" | jq '.Count // 0')

    # Get active challenges
    local challenges=$(aws dynamodb scan \
        --table-name "gua-knowledge-index" \
        --filter-expression "user_id = :uid AND knowledge_type = :kt AND #st = :status" \
        --expression-attribute-names '{"#st": "status"}' \
        --expression-attribute-values "{\":uid\": {\"S\": \"$USER_ID\"}, \":kt\": {\"S\": \"challenge\"}, \":status\": {\"S\": \"active\"}}" \
        --region "$REGION" 2>/dev/null)

    local challenge_count=$(echo "$challenges" | jq '.Count // 0')

    # Calculate averages
    local avg_impl=$(echo "$areas" | jq '[.Items[].implementation_pct.N // "0" | tonumber] | if length > 0 then add / length else 0 end | floor' 2>/dev/null || echo "0")
    [[ -z "$avg_impl" || "$avg_impl" == "null" ]] && avg_impl=0

    echo "Summary:"
    echo "  Areas tracked:     $area_count"
    echo "  Active challenges: $challenge_count"
    echo "  Avg completion:    ${avg_impl}%"
    echo ""

    echo "Understanding Depth Distribution:"
    if [[ "$area_count" != "0" ]]; then
        echo "$areas" | jq -r '[.Items[].understanding_depth.S // "L0"] | group_by(.) | map("  \(.[0]): \(length)") | .[]' 2>/dev/null || echo "  (no data)"
    else
        echo "  (no areas tracked)"
    fi
    echo ""

    if [[ "$challenge_count" != "0" ]]; then
        echo "Active Challenges by PP Dimension:"
        echo "$challenges" | jq -r '[.Items[].pp_dimension.S] | group_by(.) | map({key: .[0], count: length}) | from_entries | to_entries | .[] | "  \(.key): \(.value)"'
        echo ""
    fi

    # Show waypoint status if path protocol is initialized
    local project_root=$(pwd)
    local path_dir="$project_root/.gua/path"
    if [[ -d "$path_dir" && -f "$path_dir/manifest.json" ]]; then
        echo "Path Protocol Status:"
        local current_wp=$(jq -r '.currentWaypoint // "none"' "$path_dir/manifest.json")
        local wp_count=$(jq -r '.waypointCount // 0' "$path_dir/manifest.json")

        local wp_completed=0
        local wp_in_progress=0
        local wp_pending=0

        if [[ -d "$path_dir/waypoints" ]] && ls -1 "$path_dir/waypoints/"*.json &>/dev/null; then
            for json_file in "$path_dir/waypoints/"*.json; do
                local status=$(jq -r '.status' "$json_file")
                case "$status" in
                    completed) ((wp_completed++)) ;;
                    in_progress) ((wp_in_progress++)) ;;
                    *) ((wp_pending++)) ;;
                esac
            done
        fi

        local purpose_progress=0
        [[ $wp_count -gt 0 ]] && purpose_progress=$((wp_completed * 100 / wp_count))

        echo "  Current waypoint:  $current_wp"
        echo "  Purpose progress:  ${purpose_progress}% ($wp_completed/$wp_count waypoints)"
        echo "  Waypoints: ${wp_completed} done, ${wp_in_progress} active, ${wp_pending} pending"
        echo ""
    fi

    echo "Quick Actions:"
    echo "  gua area status              # List all areas"
    echo "  gua challenge list           # List active challenges"
    echo "  gua area update <id> --impl X --depth LY"
    if [[ -d "$path_dir" ]]; then
        echo "  gua path status              # Full path protocol status"
    fi
}

# ============================================================
# PROGRESS SNAPSHOT - Create a progress snapshot
# ============================================================
cmd_progress_snapshot() {
    local project="${1:-all}"

    echo -e "${BLUE}[CPT] Creating progress snapshot...${NC}"

    load_config

    local ts=$(timestamp)
    local date=$(date +%Y-%m-%d)
    local snapshot_id="snapshot#${date}#${project}"

    # Get areas
    local areas=$(aws dynamodb scan \
        --table-name "gua-knowledge-index" \
        --filter-expression "user_id = :uid AND knowledge_type = :kt" \
        --expression-attribute-values "{\":uid\": {\"S\": \"$USER_ID\"}, \":kt\": {\"S\": \"code_area\"}}" \
        --region "$REGION" 2>/dev/null)

    local area_count=$(echo "$areas" | jq '.Count // 0')
    local avg_impl=$(echo "$areas" | jq '[.Items[].implementation_pct.N // "0" | tonumber] | if length > 0 then add / length else 0 end | floor')

    # Get active challenges
    local challenges=$(aws dynamodb scan \
        --table-name "gua-knowledge-index" \
        --filter-expression "user_id = :uid AND knowledge_type = :kt AND #st = :status" \
        --expression-attribute-names '{"#st": "status"}' \
        --expression-attribute-values "{\":uid\": {\"S\": \"$USER_ID\"}, \":kt\": {\"S\": \"challenge\"}, \":status\": {\"S\": \"active\"}}" \
        --region "$REGION" 2>/dev/null)

    local challenge_count=$(echo "$challenges" | jq '.Count // 0')

    # Store snapshot
    aws dynamodb put-item \
        --table-name "gua-knowledge-index" \
        --item "{
            \"user_id\": {\"S\": \"$USER_ID\"},
            \"knowledge_id\": {\"S\": \"$snapshot_id\"},
            \"knowledge_type\": {\"S\": \"progress_snapshot\"},
            \"name\": {\"S\": \"Progress Snapshot $date\"},
            \"project\": {\"S\": \"$project\"},
            \"snapshot_date\": {\"S\": \"$date\"},
            \"total_areas\": {\"N\": \"$area_count\"},
            \"avg_completion\": {\"N\": \"$avg_impl\"},
            \"active_challenges\": {\"N\": \"$challenge_count\"},
            \"pp_dimension\": {\"S\": \"understanding\"},
            \"confidence\": {\"S\": \"confirmed\"},
            \"scope\": {\"S\": \"project\"},
            \"access_count\": {\"N\": \"0\"},
            \"access_score\": {\"N\": \"0\"},
            \"created_at\": {\"S\": \"$ts\"},
            \"is_active\": {\"BOOL\": true}
        }" \
        --region "$REGION"

    echo -e "${GREEN}[CPT] Snapshot created: $snapshot_id${NC}"
    echo "  Date: $date"
    echo "  Areas: $area_count"
    echo "  Avg Completion: ${avg_impl}%"
    echo "  Active Challenges: $challenge_count"

    # Also snapshot path protocol status if initialized
    local project_root=$(pwd)
    local path_dir="$project_root/.gua/path"
    if [[ -d "$path_dir" && -f "$path_dir/manifest.json" ]]; then
        local current_wp=$(jq -r '.currentWaypoint // "none"' "$path_dir/manifest.json")
        local wp_count=$(jq -r '.waypointCount // 0' "$path_dir/manifest.json")

        local wp_completed=0
        if [[ -d "$path_dir/waypoints" ]] && ls -1 "$path_dir/waypoints/"*.json &>/dev/null; then
            for json_file in "$path_dir/waypoints/"*.json; do
                local status=$(jq -r '.status' "$json_file")
                [[ "$status" == "completed" ]] && ((wp_completed++))
            done
        fi

        local purpose_progress=0
        [[ $wp_count -gt 0 ]] && purpose_progress=$((wp_completed * 100 / wp_count))

        # Save local path snapshot
        local path_snapshot="$path_dir/snapshots"
        mkdir -p "$path_snapshot"
        cat > "$path_snapshot/${date}.json" << EOF
{
  "date": "$date",
  "timestamp": "$ts",
  "currentWaypoint": "$current_wp",
  "waypointCount": $wp_count,
  "waypointsCompleted": $wp_completed,
  "purposeProgress": $purpose_progress,
  "cptAreas": $area_count,
  "cptAvgCompletion": $avg_impl,
  "activeChallenges": $challenge_count
}
EOF

        echo ""
        echo "Path Protocol:"
        echo "  Current Waypoint: $current_wp"
        echo "  Purpose Progress: ${purpose_progress}% ($wp_completed/$wp_count waypoints)"
    fi
}

# ============================================================
# EUREKA - Capture "Ahh Hah" Moments
# ============================================================

# Eureka types: connection, resolution, pattern, constraint, reframe, simplify, counter_intuitive

# ============================================================
# EUREKA LOG - Log an eureka moment
# ============================================================
cmd_eureka_log() {
    local content="$1"
    local eureka_type="${2:-resolution}"
    local catalyst="${3:-}"
    local task_context="${4:-}"

    if [[ -z "$content" ]]; then
        echo -e "${RED}Usage: gua eureka log <content> [type] [catalyst] [task_context]${NC}"
        echo ""
        echo "Types: connection | resolution | pattern | constraint | reframe | simplify | counter_intuitive"
        echo ""
        echo "Examples:"
        echo "  gua eureka log 'Challenges are immature insights' connection 'Reading gua-insight.md'"
        echo "  gua eureka log 'The null was from the filter' resolution"
        echo "  gua eureka log 'All three failures have same root' pattern"
        exit 1
    fi

    load_config

    local ts=$(timestamp)
    local id=$(uuid | cut -c1-8)
    local eureka_id="eureka#${ts}#${id}"

    # Infer PP dimension from eureka type
    local pp_dimension="understanding"
    case "$eureka_type" in
        connection|reframe)
            pp_dimension="understanding"
            ;;
        resolution|constraint|counter_intuitive)
            pp_dimension="truth"
            ;;
        pattern|simplify)
            pp_dimension="beauty"
            ;;
    esac

    # Get current session if exists
    local session_id=""
    if [[ -f "$GUA_DIR/current_session" ]]; then
        session_id=$(cat "$GUA_DIR/current_session")
    fi

    # Create one-liner summary
    local one_liner=$(echo "$content" | cut -c1-100)

    aws dynamodb put-item \
        --table-name "gua-knowledge-index" \
        --item "{
            \"user_id\": {\"S\": \"$USER_ID\"},
            \"knowledge_id\": {\"S\": \"$eureka_id\"},
            \"knowledge_type\": {\"S\": \"eureka_moment\"},
            \"name\": {\"S\": \"$one_liner\"},
            \"content\": {\"S\": \"$content\"},
            \"eureka_type\": {\"S\": \"$eureka_type\"},
            \"one_liner\": {\"S\": \"$one_liner\"},
            \"catalyst\": {\"S\": \"${catalyst:-unknown}\"},
            \"task_context\": {\"S\": \"${task_context:-}\"},
            \"pp_dimension\": {\"S\": \"$pp_dimension\"},
            \"thinking_phase\": {\"S\": \"mid\"},
            \"session_id\": {\"S\": \"${session_id:-none}\"},
            \"confidence\": {\"S\": \"immediate\"},
            \"scope\": {\"S\": \"global\"},
            \"access_count\": {\"N\": \"0\"},
            \"access_score\": {\"N\": \"0\"},
            \"promoted\": {\"BOOL\": false},
            \"created_at\": {\"S\": \"$ts\"},
            \"is_active\": {\"BOOL\": true}
        }" \
        --region "$REGION"

    echo -e "${GREEN}[EUREKA] Ahh hah moment captured!${NC}"
    echo "  ID: $eureka_id"
    echo "  Type: $eureka_type"
    echo "  Dimension: $pp_dimension"
    echo "  Content: $content"
    if [[ -n "$catalyst" ]]; then
        echo "  Catalyst: $catalyst"
    fi
}

# ============================================================
# EUREKA LIST - List eureka moments
# ============================================================
cmd_eureka_list() {
    local type_filter=""
    local session_filter=""
    local limit=10

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --type)
                type_filter="$2"
                shift 2
                ;;
            --session)
                session_filter="$2"
                shift 2
                ;;
            --limit)
                limit="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done

    echo -e "${BLUE}[EUREKA] Recent Ahh Hah Moments${NC}"
    echo ""

    load_config

    local filter_expr="user_id = :uid AND knowledge_type = :kt"
    local attr_values="{\":uid\": {\"S\": \"$USER_ID\"}, \":kt\": {\"S\": \"eureka_moment\"}}"

    if [[ -n "$type_filter" ]]; then
        filter_expr="$filter_expr AND eureka_type = :etype"
        attr_values=$(echo "$attr_values" | jq ". + {\":etype\": {\"S\": \"$type_filter\"}}")
    fi

    if [[ -n "$session_filter" ]]; then
        filter_expr="$filter_expr AND session_id = :sid"
        attr_values=$(echo "$attr_values" | jq ". + {\":sid\": {\"S\": \"$session_filter\"}}")
    fi

    local eurekas=$(aws dynamodb scan \
        --table-name "gua-knowledge-index" \
        --filter-expression "$filter_expr" \
        --expression-attribute-values "$attr_values" \
        --region "$REGION" 2>/dev/null)

    local count=$(echo "$eurekas" | jq '.Count // 0')

    if [[ "$count" == "0" ]]; then
        echo "No eureka moments found."
        echo ""
        echo "Log one: gua eureka log '<insight>' [type]"
        return
    fi

    # Sort by created_at descending and limit
    echo "$eurekas" | jq -r ".Items | sort_by(.created_at.S) | reverse | .[:$limit][] |
        \"[\(.eureka_type.S | .[0:4] | ascii_upcase)] \(.content.S | .[0:60])...\n    Type: \(.eureka_type.S) | Dim: \(.pp_dimension.S) | \(.created_at.S | split(\"T\")[0])\n    ID: \(.knowledge_id.S)\n\""
}

# ============================================================
# EUREKA SHOW - Show eureka details
# ============================================================
cmd_eureka_show() {
    local eureka_id="$1"

    if [[ -z "$eureka_id" ]]; then
        echo -e "${RED}Usage: gua eureka show <eureka_id>${NC}"
        exit 1
    fi

    load_config

    local eureka=$(aws dynamodb get-item \
        --table-name "gua-knowledge-index" \
        --key "{\"user_id\": {\"S\": \"$USER_ID\"}, \"knowledge_id\": {\"S\": \"$eureka_id\"}}" \
        --region "$REGION" 2>/dev/null)

    if [[ -z "$eureka" || "$(echo "$eureka" | jq '.Item')" == "null" ]]; then
        echo -e "${RED}Eureka not found: $eureka_id${NC}"
        exit 1
    fi

    echo -e "${BLUE}[EUREKA] Moment Details${NC}"
    echo ""
    echo "$eureka" | jq -r '.Item | "Content: \(.content.S)
Type: \(.eureka_type.S)
PP Dimension: \(.pp_dimension.S)
Catalyst: \(.catalyst.S // "unknown")
Task Context: \(.task_context.S // "none")
Thinking Phase: \(.thinking_phase.S // "unknown")
Session: \(.session_id.S // "none")
Confidence: \(.confidence.S // "immediate")
Promoted: \(.promoted.BOOL // false)
Created: \(.created_at.S)"'
}

# ============================================================
# EUREKA PROMOTE - Promote eureka to insight
# ============================================================
cmd_eureka_promote() {
    local eureka_id="$1"

    if [[ -z "$eureka_id" ]]; then
        echo -e "${RED}Usage: gua eureka promote <eureka_id>${NC}"
        exit 1
    fi

    load_config

    # Get the eureka
    local eureka=$(aws dynamodb get-item \
        --table-name "gua-knowledge-index" \
        --key "{\"user_id\": {\"S\": \"$USER_ID\"}, \"knowledge_id\": {\"S\": \"$eureka_id\"}}" \
        --region "$REGION" 2>/dev/null)

    local content=$(echo "$eureka" | jq -r '.Item.content.S // empty')
    local eureka_type=$(echo "$eureka" | jq -r '.Item.eureka_type.S // "resolution"')
    local pp_dimension=$(echo "$eureka" | jq -r '.Item.pp_dimension.S // "understanding"')
    local catalyst=$(echo "$eureka" | jq -r '.Item.catalyst.S // "eureka moment"')

    if [[ -z "$content" ]]; then
        echo -e "${RED}Eureka not found: $eureka_id${NC}"
        exit 1
    fi

    # Map eureka type to insight type
    local insight_type="pattern"
    case "$eureka_type" in
        connection|pattern)
            insight_type="pattern"
            ;;
        resolution|constraint)
            insight_type="technique"
            ;;
        reframe)
            insight_type="model"
            ;;
        simplify)
            insight_type="principle"
            ;;
        counter_intuitive)
            insight_type="observation"
            ;;
    esac

    # Create insight
    cmd_insight_log "$content" "$insight_type" "Eureka: $catalyst" "$pp_dimension" "global"

    # Mark eureka as promoted
    aws dynamodb update-item \
        --table-name "gua-knowledge-index" \
        --key "{\"user_id\": {\"S\": \"$USER_ID\"}, \"knowledge_id\": {\"S\": \"$eureka_id\"}}" \
        --update-expression "SET promoted = :t, promoted_at = :ts" \
        --expression-attribute-values "{\":t\": {\"BOOL\": true}, \":ts\": {\"S\": \"$(timestamp)\"}}" \
        --region "$REGION" 2>/dev/null

    echo -e "${GREEN}[EUREKA] Promoted to insight${NC}"
}

# ============================================================
# EUREKA SESSION - Show eurekas from current/specific session
# ============================================================
cmd_eureka_session() {
    local session_id="${1:-}"

    # Use current session if not specified
    if [[ -z "$session_id" && -f "$GUA_DIR/current_session" ]]; then
        session_id=$(cat "$GUA_DIR/current_session")
    fi

    if [[ -z "$session_id" ]]; then
        echo -e "${YELLOW}No active session. Showing recent eurekas instead.${NC}"
        cmd_eureka_list --limit 5
        return
    fi

    echo -e "${BLUE}[EUREKA] Session Moments: $session_id${NC}"
    echo ""

    load_config

    local eurekas=$(aws dynamodb scan \
        --table-name "gua-knowledge-index" \
        --filter-expression "user_id = :uid AND knowledge_type = :kt AND session_id = :sid" \
        --expression-attribute-values "{\":uid\": {\"S\": \"$USER_ID\"}, \":kt\": {\"S\": \"eureka_moment\"}, \":sid\": {\"S\": \"$session_id\"}}" \
        --region "$REGION" 2>/dev/null)

    local count=$(echo "$eurekas" | jq '.Count // 0')

    if [[ "$count" == "0" ]]; then
        echo "No eureka moments in this session."
        return
    fi

    echo "Found $count eureka moment(s):"
    echo ""

    echo "$eurekas" | jq -r '.Items | sort_by(.created_at.S) | .[] |
        "[\(.eureka_type.S | .[0:4] | ascii_upcase)] \(.content.S)\n    Catalyst: \(.catalyst.S // \"unknown\")\n"'
}

# ============================================================
# EUREKA ANALYZE - Analyze eureka patterns
# ============================================================
cmd_eureka_analyze() {
    local type_filter="${1:-}"

    echo -e "${BLUE}[EUREKA] Pattern Analysis${NC}"
    echo ""

    load_config

    local eurekas=$(aws dynamodb scan \
        --table-name "gua-knowledge-index" \
        --filter-expression "user_id = :uid AND knowledge_type = :kt" \
        --expression-attribute-values "{\":uid\": {\"S\": \"$USER_ID\"}, \":kt\": {\"S\": \"eureka_moment\"}}" \
        --region "$REGION" 2>/dev/null)

    local total=$(echo "$eurekas" | jq '.Count // 0')

    if [[ "$total" == "0" ]]; then
        echo "No eureka moments to analyze."
        return
    fi

    echo "Total eureka moments: $total"
    echo ""

    echo "By Type:"
    echo "$eurekas" | jq -r '[.Items[].eureka_type.S] | group_by(.) | map({type: .[0], count: length}) | sort_by(-.count) | .[] | "  \(.type): \(.count)"'
    echo ""

    echo "By PP Dimension:"
    echo "$eurekas" | jq -r '[.Items[].pp_dimension.S] | group_by(.) | map({dim: .[0], count: length}) | sort_by(-.count) | .[] | "  \(.dim): \(.count)"'
    echo ""

    # Meta-insight
    local most_common=$(echo "$eurekas" | jq -r '[.Items[].eureka_type.S] | group_by(.) | map({type: .[0], count: length}) | sort_by(-.count) | .[0].type')

    echo "Meta-Insight:"
    case "$most_common" in
        connection)
            echo "  Most eurekas are CONNECTIONS - you learn by linking ideas."
            echo "  Consider: Cross-reference more explicitly during exploration."
            ;;
        resolution)
            echo "  Most eurekas are RESOLUTIONS - you learn by solving confusions."
            echo "  Consider: Document confusions as they arise to track resolution patterns."
            ;;
        pattern)
            echo "  Most eurekas are PATTERNS - you learn by recognizing recurring structures."
            echo "  Consider: Build pattern libraries from these recognitions."
            ;;
        constraint)
            echo "  Most eurekas are CONSTRAINTS - you learn by understanding boundaries."
            echo "  Consider: Document 'what cannot be done' as valuable knowledge."
            ;;
        reframe)
            echo "  Most eurekas are REFRAMES - you learn by shifting perspectives."
            echo "  Consider: When stuck, explicitly try alternative framings."
            ;;
        simplify)
            echo "  Most eurekas are SIMPLIFICATIONS - you learn by finding essence."
            echo "  Consider: Always ask 'what's the simplest explanation?'"
            ;;
        counter_intuitive)
            echo "  Most eurekas are COUNTER-INTUITIVE - you learn by challenging assumptions."
            echo "  Consider: Actively test intuitions before trusting them."
            ;;
        *)
            echo "  Diverse eureka types - multi-modal learning style."
            ;;
    esac
}

# ============================================================
# EUREKA HARVEST - Extract value from unpromoted eurekas
# ============================================================
cmd_eureka_harvest() {
    local auto_promote="false"
    local days="30"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --auto)
                auto_promote="true"
                shift
                ;;
            --days)
                days="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done

    load_config

    echo -e "${BLUE}[EUREKA] Harvesting value from unpromoted eurekas${NC}"
    echo ""

    # Find unpromoted eurekas
    local eurekas=$(aws dynamodb scan \
        --table-name "gua-knowledge-index" \
        --filter-expression "user_id = :uid AND knowledge_type = :kt AND (attribute_not_exists(promoted) OR promoted = :false)" \
        --expression-attribute-values "{\":uid\": {\"S\": \"$USER_ID\"}, \":kt\": {\"S\": \"eureka_moment\"}, \":false\": {\"BOOL\": false}}" \
        --region "$REGION" 2>/dev/null)

    local count=$(echo "$eurekas" | jq '.Count // 0')

    if [[ "$count" == "0" ]]; then
        echo "No unpromoted eurekas found."
        echo ""
        echo -e "${GREEN}All eureka moments have been promoted to insights!${NC}"
        return
    fi

    echo -e "${YELLOW}Found $count eurekas ready for promotion:${NC}"
    echo ""

    # Group by type for better display
    local by_type=$(echo "$eurekas" | jq -r '[.Items[].eureka_type.S] | group_by(.) | map({type: .[0], count: length}) | .[] | "  \(.type): \(.count)"')
    echo "By type:"
    echo "$by_type"
    echo ""

    # List each promotable eureka
    local ids=()
    local promoted_count=0
    while IFS= read -r eureka; do
        local eid=$(echo "$eureka" | jq -r '.knowledge_id.S')
        local content=$(echo "$eureka" | jq -r '.content.S')
        local etype=$(echo "$eureka" | jq -r '.eureka_type.S')
        local dimension=$(echo "$eureka" | jq -r '.pp_dimension.S')
        local created=$(echo "$eureka" | jq -r '.created_at.S | split("T")[0]')

        ids+=("$eid")

        echo -e "${CYAN}[$etype]${NC} $content"
        echo "  Dimension: $dimension | Created: $created"
        echo "  ID: $eid"
        echo ""

        if [[ "$auto_promote" == "true" ]]; then
            cmd_eureka_promote "$eid"
            ((promoted_count++))
            echo ""
        fi
    done < <(echo "$eurekas" | jq -c '.Items | sort_by(.created_at.S) | reverse | .[]')

    if [[ "$auto_promote" == "true" ]]; then
        echo -e "${GREEN}Promoted $promoted_count eurekas to insights!${NC}"
    else
        echo -e "${YELLOW}To promote these eurekas to insights, run:${NC}"
        echo "  gua eureka harvest --auto"
        echo ""
        echo "Or promote individually:"
        for id in "${ids[@]:0:5}"; do
            echo "  gua eureka promote \"$id\""
        done
        if [[ ${#ids[@]} -gt 5 ]]; then
            echo "  ... and $((${#ids[@]} - 5)) more"
        fi
    fi
}

# ============================================================
# DEV KNOWLEDGE - Platform-specific development knowledge
# ============================================================

# Valid platforms and domains
DEV_PLATFORMS="shopify sentry prisma aws vercel nextjs react typescript general"
DEV_DOMAINS="auth data api ui deployment testing performance security"
DEV_TYPES="pattern recipe gotcha error_fix config migration"

# Generate short hash for ID
short_hash() {
    echo "$1" | md5 | head -c 8
}

cmd_dev_add() {
    local platform="$1"
    local domain="$2"
    local dev_type="$3"
    local title="$4"
    shift 4

    # Parse optional flags
    local code_snippet=""
    local tags=""
    local error_codes=""
    local description=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --code)
                code_snippet="$2"
                shift 2
                ;;
            --tags)
                tags="$2"
                shift 2
                ;;
            --error)
                error_codes="$2"
                shift 2
                ;;
            --desc)
                description="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done

    # Validate inputs
    if [[ -z "$platform" || -z "$domain" || -z "$dev_type" || -z "$title" ]]; then
        echo -e "${RED}Usage: gua dev add <platform> <domain> <type> \"<title>\" [options]${NC}"
        echo ""
        echo "Platforms: $DEV_PLATFORMS"
        echo "Domains: $DEV_DOMAINS"
        echo "Types: $DEV_TYPES"
        echo ""
        echo "Options:"
        echo "  --code \"<snippet>\"   Code example"
        echo "  --tags \"tag1,tag2\"   Comma-separated tags"
        echo "  --error \"ERROR_CODE\" Related error code"
        echo "  --desc \"<text>\"      Extended description"
        echo ""
        echo "Example:"
        echo "  gua dev add shopify api gotcha \"GraphQL requires explicit versioning\""
        exit 1
    fi

    # Validate platform
    if ! echo "$DEV_PLATFORMS" | grep -qw "$platform"; then
        echo -e "${RED}Invalid platform: $platform${NC}"
        echo "Valid platforms: $DEV_PLATFORMS"
        exit 1
    fi

    # Validate domain
    if ! echo "$DEV_DOMAINS" | grep -qw "$domain"; then
        echo -e "${RED}Invalid domain: $domain${NC}"
        echo "Valid domains: $DEV_DOMAINS"
        exit 1
    fi

    # Validate type
    if ! echo "$DEV_TYPES" | grep -qw "$dev_type"; then
        echo -e "${RED}Invalid type: $dev_type${NC}"
        echo "Valid types: $DEV_TYPES"
        exit 1
    fi

    load_config

    local ts=$(timestamp)
    local hash=$(short_hash "${platform}${domain}${title}${ts}")
    local knowledge_id="dev#${platform}#${domain}#${hash}"
    local platform_domain="${platform}#${domain}"

    # Map dev_type to PP dimension
    local pp_dimension
    case "$dev_type" in
        pattern|recipe) pp_dimension="beauty" ;;
        gotcha|error_fix) pp_dimension="truth" ;;
        config) pp_dimension="justice" ;;
        migration) pp_dimension="creativity" ;;
        *) pp_dimension="understanding" ;;
    esac

    # Build item JSON
    local item="{
        \"user_id\": {\"S\": \"$USER_ID\"},
        \"knowledge_id\": {\"S\": \"$knowledge_id\"},
        \"knowledge_type\": {\"S\": \"dev_knowledge\"},
        \"platform\": {\"S\": \"$platform\"},
        \"domain\": {\"S\": \"$domain\"},
        \"platform_domain\": {\"S\": \"$platform_domain\"},
        \"dev_type\": {\"S\": \"$dev_type\"},
        \"title\": {\"S\": \"$title\"},
        \"description\": {\"S\": \"${description:-$title}\"},
        \"pp_dimension\": {\"S\": \"$pp_dimension\"},
        \"confidence\": {\"S\": \"confirmed\"},
        \"scope\": {\"S\": \"global\"},
        \"access_count\": {\"N\": \"0\"},
        \"access_score\": {\"N\": \"0\"},
        \"created_at\": {\"S\": \"$ts\"},
        \"device_id\": {\"S\": \"$DEVICE_ID\"}"

    # Add optional fields
    if [[ -n "$code_snippet" ]]; then
        item="$item, \"code_snippet\": {\"S\": $(echo "$code_snippet" | jq -Rs .)}"
    fi

    if [[ -n "$tags" ]]; then
        local tags_list=$(echo "$tags" | tr ',' '\n' | jq -R . | jq -s 'map({S: .})')
        item="$item, \"tags\": {\"L\": $tags_list}"
    fi

    if [[ -n "$error_codes" ]]; then
        item="$item, \"error_codes\": {\"SS\": [\"$error_codes\"]}"
    fi

    item="$item}"

    aws dynamodb put-item \
        --table-name "gua-knowledge-index" \
        --item "$item" \
        --region "$REGION"

    echo -e "${GREEN}[DEV] Knowledge captured!${NC}"
    echo "  ID: $knowledge_id"
    echo "  Platform: $platform"
    echo "  Domain: $domain"
    echo "  Type: $dev_type"
    echo "  Title: $title"
    [[ -n "$code_snippet" ]] && echo "  Code: (included)"
    [[ -n "$tags" ]] && echo "  Tags: $tags"
}

cmd_dev_list() {
    local platform="${1:-}"
    local domain="${2:-}"

    load_config

    echo -e "${BLUE}[DEV] Development Knowledge${NC}"

    if [[ -z "$platform" ]]; then
        # List all platforms with counts
        echo ""
        echo "By Platform:"
        aws dynamodb scan \
            --table-name "gua-knowledge-index" \
            --filter-expression "user_id = :uid AND knowledge_type = :kt" \
            --expression-attribute-values "{\":uid\": {\"S\": \"$USER_ID\"}, \":kt\": {\"S\": \"dev_knowledge\"}}" \
            --region "$REGION" 2>/dev/null | \
            jq -r '[.Items[].platform.S] | group_by(.) | map({platform: .[0], count: length}) | sort_by(-.count) | .[] | "  \(.platform): \(.count)"'
        echo ""
        echo "Usage: gua dev list <platform> [domain]"
        return
    fi

    echo ""
    echo "Platform: $platform"
    [[ -n "$domain" ]] && echo "Domain: $domain"
    echo ""

    local filter_expr="user_id = :uid AND knowledge_type = :kt AND platform = :p"
    local attr_values="{\":uid\": {\"S\": \"$USER_ID\"}, \":kt\": {\"S\": \"dev_knowledge\"}, \":p\": {\"S\": \"$platform\"}}"

    if [[ -n "$domain" ]]; then
        filter_expr="$filter_expr AND #dom = :d"
        attr_values=$(echo "$attr_values" | sed 's/}$/, ":d": {"S": "'"$domain"'"}}/')
    fi

    local results
    if [[ -n "$domain" ]]; then
        results=$(aws dynamodb scan \
            --table-name "gua-knowledge-index" \
            --filter-expression "$filter_expr" \
            --expression-attribute-values "$attr_values" \
            --expression-attribute-names '{"#dom": "domain"}' \
            --region "$REGION" 2>/dev/null)
    else
        results=$(aws dynamodb scan \
            --table-name "gua-knowledge-index" \
            --filter-expression "$filter_expr" \
            --expression-attribute-values "$attr_values" \
            --region "$REGION" 2>/dev/null)
    fi

    local count=$(echo "$results" | jq '.Count // 0')

    if [[ "$count" == "0" ]]; then
        echo "No dev knowledge found."
        return
    fi

    echo "$results" | jq -r '.Items | sort_by(.access_score.N // "0" | tonumber) | reverse | .[] | "[\(.dev_type.S | ascii_upcase)] \(.title.S)\n    Domain: \(.domain.S) | ID: \(.knowledge_id.S | split("#")[3])"'
}

cmd_dev_search() {
    local query="$1"
    shift

    # Parse flags
    local platform=""
    local domain=""
    local dev_type=""
    local limit="20"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --platform) platform="$2"; shift 2 ;;
            --domain) domain="$2"; shift 2 ;;
            --type) dev_type="$2"; shift 2 ;;
            --limit) limit="$2"; shift 2 ;;
            *) shift ;;
        esac
    done

    if [[ -z "$query" ]]; then
        echo -e "${RED}Usage: gua dev search \"<query>\" [--platform P] [--domain D] [--type T]${NC}"
        exit 1
    fi

    load_config

    echo -e "${BLUE}[DEV] Searching: $query${NC}"
    [[ -n "$platform" ]] && echo "  Platform: $platform"
    [[ -n "$domain" ]] && echo "  Domain: $domain"
    echo ""

    # Build filter
    local filter_expr="user_id = :uid AND knowledge_type = :kt AND (contains(title, :q) OR contains(description, :q))"
    local attr_values="{\":uid\": {\"S\": \"$USER_ID\"}, \":kt\": {\"S\": \"dev_knowledge\"}, \":q\": {\"S\": \"$query\"}}"
    local attr_names="{}"

    if [[ -n "$platform" ]]; then
        filter_expr="$filter_expr AND platform = :p"
        attr_values=$(echo "$attr_values" | sed 's/}$/, ":p": {"S": "'"$platform"'"}}/')
    fi

    if [[ -n "$domain" ]]; then
        filter_expr="$filter_expr AND #dom = :d"
        attr_values=$(echo "$attr_values" | sed 's/}$/, ":d": {"S": "'"$domain"'"}}/')
        attr_names='{"#dom": "domain"}'
    fi

    local results
    if [[ "$attr_names" != "{}" ]]; then
        results=$(aws dynamodb scan \
            --table-name "gua-knowledge-index" \
            --filter-expression "$filter_expr" \
            --expression-attribute-values "$attr_values" \
            --expression-attribute-names "$attr_names" \
            --region "$REGION" 2>/dev/null)
    else
        results=$(aws dynamodb scan \
            --table-name "gua-knowledge-index" \
            --filter-expression "$filter_expr" \
            --expression-attribute-values "$attr_values" \
            --region "$REGION" 2>/dev/null)
    fi

    local count=$(echo "$results" | jq '.Count // 0')

    if [[ "$count" == "0" ]]; then
        echo "No results found."
        return
    fi

    echo "Found $count matches:"
    echo ""
    echo "$results" | jq -r '.Items | sort_by(.access_score.N // "0" | tonumber) | reverse | .[] | "[\(.platform.S)/\(.domain.S)] \(.title.S)\n    Type: \(.dev_type.S) | ID: \(.knowledge_id.S)"'
}

cmd_dev_show() {
    local id="$1"

    if [[ -z "$id" ]]; then
        echo -e "${RED}Usage: gua dev show <id>${NC}"
        echo "Use 'gua dev list' to find IDs"
        exit 1
    fi

    load_config

    # If short ID provided, search for it
    if [[ ! "$id" =~ ^dev# ]]; then
        id=$(aws dynamodb scan \
            --table-name "gua-knowledge-index" \
            --filter-expression "user_id = :uid AND contains(knowledge_id, :id)" \
            --expression-attribute-values "{\":uid\": {\"S\": \"$USER_ID\"}, \":id\": {\"S\": \"$id\"}}" \
            --region "$REGION" 2>/dev/null | jq -r '.Items[0].knowledge_id.S // empty')

        if [[ -z "$id" ]]; then
            echo -e "${RED}Dev knowledge not found: $1${NC}"
            exit 1
        fi
    fi

    local item=$(aws dynamodb get-item \
        --table-name "gua-knowledge-index" \
        --key "{\"user_id\": {\"S\": \"$USER_ID\"}, \"knowledge_id\": {\"S\": \"$id\"}}" \
        --region "$REGION" 2>/dev/null | jq '.Item')

    if [[ "$item" == "null" || -z "$item" ]]; then
        echo -e "${RED}Dev knowledge not found${NC}"
        exit 1
    fi

    echo -e "${BLUE}[DEV] Knowledge Details${NC}"
    echo ""
    echo "ID: $(echo "$item" | jq -r '.knowledge_id.S')"
    echo "Platform: $(echo "$item" | jq -r '.platform.S')"
    echo "Domain: $(echo "$item" | jq -r '.domain.S')"
    echo "Type: $(echo "$item" | jq -r '.dev_type.S')"
    echo ""
    echo "Title: $(echo "$item" | jq -r '.title.S')"
    echo ""
    echo "Description:"
    echo "  $(echo "$item" | jq -r '.description.S')"

    local code=$(echo "$item" | jq -r '.code_snippet.S // empty')
    if [[ -n "$code" ]]; then
        echo ""
        echo "Code:"
        echo "$code" | sed 's/^/  /'
    fi

    local tags=$(echo "$item" | jq -r '.tags.L // empty | map(.S) | join(", ")')
    if [[ -n "$tags" ]]; then
        echo ""
        echo "Tags: $tags"
    fi

    local errors=$(echo "$item" | jq -r '.error_codes.SS // empty | join(", ")')
    if [[ -n "$errors" ]]; then
        echo ""
        echo "Error Codes: $errors"
    fi

    echo ""
    echo "PP Dimension: $(echo "$item" | jq -r '.pp_dimension.S')"
    echo "Access Count: $(echo "$item" | jq -r '.access_count.N // "0"')"
    echo "Created: $(echo "$item" | jq -r '.created_at.S')"

    # Track access
    cmd_dev_track "$id" 2>/dev/null || true
}

cmd_dev_track() {
    local id="$1"

    if [[ -z "$id" ]]; then
        return
    fi

    load_config

    aws dynamodb update-item \
        --table-name "gua-knowledge-index" \
        --key "{\"user_id\": {\"S\": \"$USER_ID\"}, \"knowledge_id\": {\"S\": \"$id\"}}" \
        --update-expression "SET access_count = if_not_exists(access_count, :zero) + :one, access_score = if_not_exists(access_score, :zero) + :one" \
        --expression-attribute-values "{\":one\": {\"N\": \"1\"}, \":zero\": {\"N\": \"0\"}}" \
        --region "$REGION" 2>/dev/null
}

cmd_dev_context() {
    local platform="${1:-}"
    local domain="${2:-}"

    if [[ -z "$platform" ]]; then
        echo -e "${RED}Usage: gua dev context <platform> [domain]${NC}"
        echo "Platforms: $DEV_PLATFORMS"
        exit 1
    fi

    load_config

    echo -e "${BLUE}[DEV] Context: $platform${NC}"
    [[ -n "$domain" ]] && echo "Domain: $domain"
    echo ""

    # Use GSI for efficient query
    local platform_domain="${platform}"
    [[ -n "$domain" ]] && platform_domain="${platform}#${domain}"

    local results
    if [[ -n "$domain" ]]; then
        results=$(aws dynamodb query \
            --table-name "gua-knowledge-index" \
            --index-name "platform-domain-index" \
            --key-condition-expression "platform_domain = :pd" \
            --expression-attribute-values "{\":pd\": {\"S\": \"$platform_domain\"}}" \
            --no-scan-index-forward \
            --limit 20 \
            --region "$REGION" 2>/dev/null)
    else
        # Without domain, scan for platform
        results=$(aws dynamodb scan \
            --table-name "gua-knowledge-index" \
            --filter-expression "user_id = :uid AND knowledge_type = :kt AND platform = :p" \
            --expression-attribute-values "{\":uid\": {\"S\": \"$USER_ID\"}, \":kt\": {\"S\": \"dev_knowledge\"}, \":p\": {\"S\": \"$platform\"}}" \
            --region "$REGION" 2>/dev/null)
    fi

    local count=$(echo "$results" | jq '.Count // 0')

    if [[ "$count" == "0" ]]; then
        echo "No dev knowledge for $platform"
        return
    fi

    echo "Top knowledge ($count total):"
    echo ""

    # Group by type
    echo "GOTCHAS:"
    echo "$results" | jq -r '.Items[] | select(.dev_type.S == "gotcha") | "  - \(.title.S)"' | head -5

    echo ""
    echo "PATTERNS:"
    echo "$results" | jq -r '.Items[] | select(.dev_type.S == "pattern") | "  - \(.title.S)"' | head -5

    echo ""
    echo "ERROR FIXES:"
    echo "$results" | jq -r '.Items[] | select(.dev_type.S == "error_fix") | "  - \(.title.S)"' | head -5

    # Track access for loaded items
    echo "$results" | jq -r '.Items[].knowledge_id.S' | while read kid; do
        cmd_dev_track "$kid" 2>/dev/null || true
    done
}

cmd_dev_promote() {
    local challenge_id="$1"
    shift

    # Parse flags
    local platform=""
    local domain=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --platform) platform="$2"; shift 2 ;;
            --domain) domain="$2"; shift 2 ;;
            *) shift ;;
        esac
    done

    if [[ -z "$challenge_id" || -z "$platform" || -z "$domain" ]]; then
        echo -e "${RED}Usage: gua dev promote <challenge_id> --platform <p> --domain <d>${NC}"
        exit 1
    fi

    load_config

    # Get challenge details
    local challenge=$(aws dynamodb get-item \
        --table-name "gua-knowledge-index" \
        --key "{\"user_id\": {\"S\": \"$USER_ID\"}, \"knowledge_id\": {\"S\": \"$challenge_id\"}}" \
        --region "$REGION" 2>/dev/null | jq '.Item')

    if [[ "$challenge" == "null" || -z "$challenge" ]]; then
        echo -e "${RED}Challenge not found: $challenge_id${NC}"
        exit 1
    fi

    local description=$(echo "$challenge" | jq -r '.description.S')
    local resolution=$(echo "$challenge" | jq -r '.resolution.S // empty')
    local category=$(echo "$challenge" | jq -r '.category.S // "gotcha"')

    # Map category to dev_type
    local dev_type
    case "$category" in
        bug) dev_type="error_fix" ;;
        confusion) dev_type="gotcha" ;;
        ugly_hack) dev_type="pattern" ;;
        wrong_place) dev_type="config" ;;
        dead_end) dev_type="recipe" ;;
        *) dev_type="gotcha" ;;
    esac

    local title="${resolution:-$description}"

    # Create dev knowledge
    cmd_dev_add "$platform" "$domain" "$dev_type" "$title" --desc "$description"

    # Update challenge with promotion reference
    aws dynamodb update-item \
        --table-name "gua-knowledge-index" \
        --key "{\"user_id\": {\"S\": \"$USER_ID\"}, \"knowledge_id\": {\"S\": \"$challenge_id\"}}" \
        --update-expression "SET promoted_to_dev = :dev" \
        --expression-attribute-values "{\":dev\": {\"BOOL\": true}}" \
        --region "$REGION" 2>/dev/null

    echo ""
    echo -e "${GREEN}Challenge promoted to dev knowledge!${NC}"
}

# ============================================================
# DIR - Directory Knowledge Commands
# ============================================================

# Initialize .gua/ in current directory
cmd_dir_init() {
    local target_dir="${1:-$(pwd)}"
    local gua_dir="$target_dir/.gua"

    if [[ -d "$gua_dir" ]]; then
        echo -e "${YELLOW}Directory already initialized: $target_dir${NC}"
        return 0
    fi

    echo -e "${BLUE}[GUA] Initializing directory knowledge: $target_dir${NC}"

    # Create directory structure
    mkdir -p "$gua_dir/patterns"
    mkdir -p "$gua_dir/contexts"
    mkdir -p "$gua_dir/gotchas"
    mkdir -p "$gua_dir/domains"

    # Determine scope
    local scope="directory"
    local project_root=$(find_project_root "$target_dir")

    if [[ -z "$project_root" || "$target_dir" == "$project_root" ]]; then
        scope="project"
    fi

    # Create manifest
    cat > "$gua_dir/manifest.json" << EOF
{
  "version": "1.0.0",
  "createdAt": "$(timestamp)",
  "updatedAt": "$(timestamp)",
  "path": "$target_dir",
  "scope": "$scope",
  "counts": {
    "patterns": 0,
    "contexts": 0,
    "gotchas": 0,
    "overrides": 0,
    "domains": 0
  }
}
EOF

    # Create initial context.md
    local scope_label
    case "$scope" in
        global) scope_label="Global" ;;
        project) scope_label="Project" ;;
        *) scope_label="Directory" ;;
    esac

    cat > "$gua_dir/context.md" << EOF
# $scope_label Context

## Overview

<!-- Describe this ${scope} -->

## Key Concepts

-

## Important Notes

-
EOF

    echo -e "${GREEN}Initialized .gua/ in $target_dir (scope: $scope)${NC}"
}

# Initialize global knowledge structure
cmd_dir_init_global() {
    local global_path="$GUA_DIR/global"

    if [[ -d "$global_path" ]]; then
        echo -e "${YELLOW}Global knowledge already initialized${NC}"
        return 0
    fi

    echo -e "${BLUE}[GUA] Initializing global knowledge structure...${NC}"

    mkdir -p "$global_path/patterns"
    mkdir -p "$global_path/gotchas"
    mkdir -p "$global_path/domains"

    # Create manifest
    cat > "$global_path/manifest.json" << EOF
{
  "version": "1.0.0",
  "createdAt": "$(timestamp)",
  "updatedAt": "$(timestamp)",
  "path": "$global_path",
  "scope": "global",
  "counts": {
    "patterns": 0,
    "contexts": 0,
    "gotchas": 0,
    "overrides": 0,
    "domains": 0
  }
}
EOF

    cat > "$global_path/context.md" << EOF
# Global Knowledge Context

## General Patterns

This contains patterns that apply across all projects.

## Usage

Global knowledge cascades down to all projects and directories unless overridden locally.
EOF

    echo -e "${GREEN}Global knowledge initialized at $global_path${NC}"
}

# Find project root
find_project_root() {
    local start_dir="$1"
    local current="$start_dir"
    local gua_project_root=""

    # First pass: look for standard project root markers
    while [[ "$current" != "/" ]]; do
        # Standard project markers take priority
        if [[ -d "$current/.git" || -f "$current/package.json" || -f "$current/Cargo.toml" || -f "$current/go.mod" || -f "$current/pyproject.toml" ]]; then
            echo "$current"
            return 0
        fi
        # Track .gua with scope=project as fallback
        if [[ -f "$current/.gua/manifest.json" ]]; then
            local scope=$(jq -r '.scope' "$current/.gua/manifest.json" 2>/dev/null)
            if [[ "$scope" == "project" && -z "$gua_project_root" ]]; then
                gua_project_root="$current"
            fi
        fi
        current=$(dirname "$current")
    done

    # Return .gua project root if found
    if [[ -n "$gua_project_root" ]]; then
        echo "$gua_project_root"
        return 0
    fi

    return 1
}

# Add knowledge to current directory
cmd_dir_add() {
    local type="$1"
    local name="$2"
    shift 2

    local target_dir="$(pwd)"
    local gua_dir="$target_dir/.gua"
    local content=""
    local pp_dim=""
    local tags=""

    # Parse optional flags
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --content) content="$2"; shift 2 ;;
            --file) content="$(cat "$2")"; shift 2 ;;
            --pp) pp_dim="$2"; shift 2 ;;
            --tags) tags="$2"; shift 2 ;;
            --dir) target_dir="$2"; gua_dir="$target_dir/.gua"; shift 2 ;;
            *) shift ;;
        esac
    done

    if [[ -z "$type" || -z "$name" ]]; then
        echo -e "${RED}Usage: gua dir add <type> <name> [--content \"...\"] [--file path] [--pp dimension]${NC}"
        echo "Types: pattern, context, gotcha, domain"
        exit 1
    fi

    if [[ ! -d "$gua_dir" ]]; then
        echo -e "${RED}Directory not initialized. Run 'gua dir init' first.${NC}"
        exit 1
    fi

    local subdir
    case "$type" in
        pattern) subdir="patterns" ;;
        context) subdir="contexts" ;;
        gotcha) subdir="gotchas" ;;
        domain) subdir="domains" ;;
        *)
            echo -e "${RED}Unknown type: $type${NC}"
            exit 1
            ;;
    esac

    local md_path="$gua_dir/$subdir/$name.md"
    local json_path="$gua_dir/$subdir/$name.json"

    # Get content if not provided
    if [[ -z "$content" ]]; then
        echo "Enter content (Ctrl+D when done):"
        content=$(cat)
    fi

    # Write markdown file
    echo "$content" > "$md_path"

    # Write metadata JSON
    cat > "$json_path" << EOF
{
  "id": "${type}-$(echo "$name" | md5sum | cut -c1-8)",
  "name": "$name",
  "type": "$type",
  "ppDimension": "$pp_dim",
  "tags": [$(echo "$tags" | sed 's/,/","/g' | sed 's/^/"/' | sed 's/$/"/')],
  "createdAt": "$(timestamp)",
  "updatedAt": "$(timestamp)"
}
EOF

    # Update manifest counts
    update_manifest_counts "$target_dir"

    echo -e "${GREEN}Added $type: $name${NC}"
}

# Update manifest counts
update_manifest_counts() {
    local target_dir="$1"
    local gua_dir="$target_dir/.gua"
    local manifest="$gua_dir/manifest.json"

    if [[ ! -f "$manifest" ]]; then
        return
    fi

    local patterns=$(ls -1 "$gua_dir/patterns/"*.md 2>/dev/null | wc -l | tr -d ' ')
    local contexts=$(ls -1 "$gua_dir/contexts/"*.md 2>/dev/null | wc -l | tr -d ' ')
    local gotchas=$(ls -1 "$gua_dir/gotchas/"*.md 2>/dev/null | wc -l | tr -d ' ')
    local overrides=$(ls -1 "$gua_dir/overrides/"*.md 2>/dev/null | wc -l | tr -d ' ')
    local domains=$(ls -1 "$gua_dir/domains/"*.md 2>/dev/null | wc -l | tr -d ' ')

    jq --arg ts "$(timestamp)" \
       --argjson p "$patterns" \
       --argjson c "$contexts" \
       --argjson g "$gotchas" \
       --argjson o "$overrides" \
       --argjson d "$domains" \
       '.updatedAt = $ts | .counts = {patterns: $p, contexts: $c, gotchas: $g, overrides: $o, domains: $d}' \
       "$manifest" > "$manifest.tmp" && mv "$manifest.tmp" "$manifest"
}

# Show knowledge in current directory
cmd_dir_show() {
    local target_dir="${1:-$(pwd)}"
    local gua_dir="$target_dir/.gua"

    if [[ ! -d "$gua_dir" ]]; then
        echo -e "${YELLOW}No knowledge in: $target_dir${NC}"
        return 0
    fi

    local manifest="$gua_dir/manifest.json"
    local scope=$(jq -r '.scope' "$manifest")
    local counts=$(jq -r '.counts | "patterns: \(.patterns), contexts: \(.contexts), gotchas: \(.gotchas), domains: \(.domains)"' "$manifest")

    echo -e "${BLUE}=== Directory Knowledge: $target_dir ===${NC}"
    echo "Scope: $scope"
    echo "Counts: $counts"
    echo ""

    # Show patterns
    if [[ -d "$gua_dir/patterns" ]] && ls -1 "$gua_dir/patterns/"*.md &>/dev/null; then
        echo -e "${GREEN}PATTERNS:${NC}"
        for f in "$gua_dir/patterns/"*.md; do
            local name=$(basename "$f" .md)
            local pp=$(jq -r '.ppDimension // "-"' "$gua_dir/patterns/$name.json" 2>/dev/null || echo "-")
            echo "  - $name [$pp]"
        done
        echo ""
    fi

    # Show gotchas
    if [[ -d "$gua_dir/gotchas" ]] && ls -1 "$gua_dir/gotchas/"*.md &>/dev/null; then
        echo -e "${YELLOW}GOTCHAS:${NC}"
        for f in "$gua_dir/gotchas/"*.md; do
            local name=$(basename "$f" .md)
            echo "  - $name"
        done
        echo ""
    fi

    # Show context
    if [[ -f "$gua_dir/context.md" ]]; then
        echo -e "${BLUE}CONTEXT:${NC}"
        head -20 "$gua_dir/context.md"
        echo ""
    fi
}

# Show inheritance chain (ancestry)
cmd_dir_ancestry() {
    local target_dir="${1:-$(pwd)}"
    target_dir=$(cd "$target_dir" && pwd)

    echo -e "${BLUE}=== Knowledge Ancestry: $target_dir ===${NC}"
    echo ""

    # Check global
    local global_path="$GUA_DIR/global"
    if [[ -d "$global_path" ]]; then
        local global_counts=$(jq -r '.counts | "p:\(.patterns) g:\(.gotchas)"' "$global_path/manifest.json" 2>/dev/null || echo "p:0 g:0")
        echo "[GLOBAL] ~/.gua/global/ ($global_counts)"
    fi

    # Find project root
    local project_root=$(find_project_root "$target_dir")
    if [[ -z "$project_root" ]]; then
        project_root="$target_dir"
    fi

    # Walk from project root to target
    local rel_path="${target_dir#$project_root/}"
    [[ "$rel_path" == "$target_dir" ]] && rel_path=""
    IFS='/' read -ra segments <<< "$rel_path"

    local current="$project_root"
    local depth=1

    for i in $(seq 0 ${#segments[@]}); do
        if [[ $i -eq 0 ]]; then
            current="$project_root"
        else
            current="$current/${segments[$((i-1))]}"
        fi

        if [[ -d "$current/.gua" ]]; then
            local scope=$(jq -r '.scope' "$current/.gua/manifest.json" 2>/dev/null || echo "directory")
            local scope_upper=$(echo "$scope" | tr '[:lower:]' '[:upper:]')
            local counts=$(jq -r '.counts | "p:\(.patterns) c:\(.contexts) g:\(.gotchas)"' "$current/.gua/manifest.json" 2>/dev/null || echo "p:0 c:0 g:0")
            local indent=$(printf '%*s' $((depth * 2)) '')
            echo "$indent[$scope_upper] $current ($counts)"
        fi

        ((depth++))
    done
}

# Show effective/resolved knowledge
cmd_dir_effective() {
    local target_dir="${1:-$(pwd)}"
    target_dir=$(cd "$target_dir" && pwd)

    echo -e "${BLUE}=== Effective Knowledge: $target_dir ===${NC}"
    echo ""

    # Use temp files instead of associative arrays (bash 3 compatible)
    local tmp_patterns=$(mktemp)
    local tmp_gotchas=$(mktemp)
    local tmp_contexts=$(mktemp)
    trap "rm -f '$tmp_patterns' '$tmp_gotchas' '$tmp_contexts'" EXIT

    # Load global
    local global_path="$GUA_DIR/global"
    if [[ -d "$global_path/patterns" ]]; then
        find "$global_path/patterns" -maxdepth 1 -name "*.md" 2>/dev/null | while read -r f; do
            local name=$(basename "$f" .md)
            echo "$name|$f|GLOBAL" >> "$tmp_patterns"
        done
    fi
    if [[ -d "$global_path/gotchas" ]]; then
        find "$global_path/gotchas" -maxdepth 1 -name "*.md" 2>/dev/null | while read -r f; do
            local name=$(basename "$f" .md)
            echo "$name|$f|GLOBAL" >> "$tmp_gotchas"
        done
    fi
    if [[ -f "$global_path/context.md" ]]; then
        echo "GLOBAL|~/.gua/global/context.md" >> "$tmp_contexts"
    fi

    # Walk from project root to target, accumulating
    local project_root=$(find_project_root "$target_dir")
    [[ -z "$project_root" ]] && project_root="$target_dir"

    local rel_path="${target_dir#$project_root/}"
    [[ "$rel_path" == "$target_dir" ]] && rel_path=""
    IFS='/' read -ra segments <<< "$rel_path"

    local current="$project_root"
    for i in $(seq 0 ${#segments[@]}); do
        if [[ $i -gt 0 ]]; then
            current="$current/${segments[$((i-1))]}"
        fi

        local gua="$current/.gua"
        if [[ -d "$gua" ]]; then
            local scope=$(jq -r '.scope' "$gua/manifest.json" 2>/dev/null || echo "directory")
            local label=$(echo "$scope" | tr '[:lower:]' '[:upper:]')

            # Patterns (override - later entries win)
            if [[ -d "$gua/patterns" ]]; then
                find "$gua/patterns" -maxdepth 1 -name "*.md" 2>/dev/null | while read -r f; do
                    local name=$(basename "$f" .md)
                    echo "$name|$f|$label" >> "$tmp_patterns"
                done
            fi

            # Gotchas (accumulate)
            if [[ -d "$gua/gotchas" ]]; then
                find "$gua/gotchas" -maxdepth 1 -name "*.md" 2>/dev/null | while read -r f; do
                    local name=$(basename "$f" .md)
                    echo "$name|$f|$label" >> "$tmp_gotchas"
                done
            fi

            # Contexts (accumulate)
            if [[ -f "$gua/context.md" ]]; then
                echo "$label|$gua/context.md" >> "$tmp_contexts"
            fi
        fi
    done

    # Display results (patterns: show last entry for each name = override wins)
    if [[ -s "$tmp_patterns" ]]; then
        echo -e "${GREEN}EFFECTIVE PATTERNS:${NC}"
        # For each unique pattern name, show the last (most local) one
        cut -d'|' -f1 "$tmp_patterns" | sort -u | while read -r name; do
            local entry=$(grep "^$name|" "$tmp_patterns" | tail -1)
            local file=$(echo "$entry" | cut -d'|' -f2)
            local label=$(echo "$entry" | cut -d'|' -f3)
            echo "  $name <- $file [$label]"
        done
        echo ""
    fi

    if [[ -s "$tmp_gotchas" ]]; then
        echo -e "${YELLOW}ALL GOTCHAS:${NC}"
        cut -d'|' -f1 "$tmp_gotchas" | sort -u | while read -r name; do
            local entry=$(grep "^$name|" "$tmp_gotchas" | tail -1)
            local file=$(echo "$entry" | cut -d'|' -f2)
            local label=$(echo "$entry" | cut -d'|' -f3)
            echo "  $name <- $file [$label]"
        done
        echo ""
    fi

    if [[ -s "$tmp_contexts" ]]; then
        echo -e "${BLUE}CONTEXT CHAIN:${NC}"
        while IFS='|' read -r label file; do
            echo "  [$label] $file"
        done < "$tmp_contexts"
        echo ""
    fi
}

# ============================================================
# TREE - Knowledge Tree Visualization
# ============================================================

cmd_tree() {
    local root_dir="${1:-$(pwd)}"
    local max_depth="${2:-5}"
    local show_details="${3:-false}"

    root_dir=$(cd "$root_dir" && pwd)
    local project_root=$(find_project_root "$root_dir")
    [[ -z "$project_root" ]] && project_root="$root_dir"

    echo -e "${BLUE}Knowledge Tree: $root_dir${NC}"
    echo ""

    # Recursive tree display
    print_tree_node "$root_dir" "" true 0 "$max_depth" "$show_details"
}

print_tree_node() {
    local dir_path="$1"
    local prefix="$2"
    local is_last="$3"
    local depth="$4"
    local max_depth="$5"
    local show_details="$6"

    [[ $depth -gt $max_depth ]] && return

    local dirname=$(basename "$dir_path")
    local connector="├── "
    [[ "$is_last" == "true" ]] && connector="└── "

    local knowledge_info=""
    if [[ -d "$dir_path/.gua" ]]; then
        local counts=$(jq -r '.counts | "\(.patterns)p \(.gotchas)g"' "$dir_path/.gua/manifest.json" 2>/dev/null || echo "0p 0g")
        knowledge_info="${GREEN}(.gua: $counts)${NC}"
    fi

    if [[ $depth -eq 0 ]]; then
        echo -e "$dirname/ $knowledge_info"
    else
        echo -e "${prefix}${connector}${dirname}/ $knowledge_info"
    fi

    # Get child directories (with .gua/ or with children that have .gua/)
    local children=()
    local excluded=("node_modules" ".git" "dist" "build" "coverage" "__pycache__" ".venv" "vendor")

    for child in "$dir_path"/*/; do
        [[ -d "$child" ]] || continue
        local child_name=$(basename "$child")
        [[ "${child_name:0:1}" == "." ]] && continue

        local skip=false
        for ex in "${excluded[@]}"; do
            [[ "$child_name" == "$ex" ]] && skip=true && break
        done
        [[ "$skip" == "true" ]] && continue

        # Check if this subtree has any .gua/
        if has_gua_in_subtree "$child" $((depth + 1)) "$max_depth"; then
            children+=("$child")
        fi
    done

    # Process children
    local new_prefix
    [[ "$is_last" == "true" ]] && new_prefix="${prefix}    " || new_prefix="${prefix}│   "

    local num_children=${#children[@]}
    local i=0
    for child in "${children[@]}"; do
        ((i++))
        local child_is_last="false"
        [[ $i -eq $num_children ]] && child_is_last="true"
        print_tree_node "$child" "$new_prefix" "$child_is_last" $((depth + 1)) "$max_depth" "$show_details"
    done
}

has_gua_in_subtree() {
    local dir="$1"
    local depth="$2"
    local max_depth="$3"

    [[ $depth -gt $max_depth ]] && return 1
    [[ -d "$dir/.gua" ]] && return 0

    for child in "$dir"/*/; do
        [[ -d "$child" ]] || continue
        local child_name=$(basename "$child")
        [[ "${child_name:0:1}" == "." ]] && continue
        if has_gua_in_subtree "$child" $((depth + 1)) "$max_depth"; then
            return 0
        fi
    done

    return 1
}

# ============================================================
# CONTEXT - Quick Context Access
# ============================================================

cmd_context() {
    local target_dir="${1:-$(pwd)}"
    local format="${2:-markdown}"

    target_dir=$(cd "$target_dir" && pwd)

    echo -e "${BLUE}=== Context for: $target_dir ===${NC}"
    echo ""

    # Walk the ancestry and collect contexts
    local global_path="$GUA_DIR/global"
    if [[ -f "$global_path/context.md" ]]; then
        echo -e "${GREEN}[GLOBAL]${NC}"
        head -20 "$global_path/context.md" | sed 's/^/  /'
        echo ""
    fi

    # Find project root
    local project_root=$(find_project_root "$target_dir")
    [[ -z "$project_root" ]] && project_root="$target_dir"

    # Walk from project root to target
    local rel_path="${target_dir#$project_root/}"
    [[ "$rel_path" == "$target_dir" ]] && rel_path=""
    IFS='/' read -ra segments <<< "$rel_path"

    local current="$project_root"
    for i in $(seq 0 ${#segments[@]}); do
        if [[ $i -gt 0 ]]; then
            current="$current/${segments[$((i-1))]}"
        fi

        if [[ -f "$current/.gua/context.md" ]]; then
            local rel
            rel="${current#$project_root/}"
            [[ "$rel" == "$current" ]] && rel="."
            local scope=$(jq -r '.scope' "$current/.gua/manifest.json" 2>/dev/null || echo "directory")
            local scope_upper=$(echo "$scope" | tr '[:lower:]' '[:upper:]')
            echo -e "${GREEN}[$scope_upper] $rel/${NC}"
            head -20 "$current/.gua/context.md" | sed 's/^/  /'
            echo ""
        fi
    done

    # Show gotchas as warnings
    echo -e "${YELLOW}GOTCHAS TO WATCH:${NC}"
    cmd_dir_effective "$target_dir" 2>/dev/null | grep -A100 "ALL GOTCHAS:" | tail -n +2 | head -10
}

# ============================================================
# PATH PROTOCOL - Current State → Purpose Path Building
# ============================================================

# Initialize path protocol for a project
cmd_path_init() {
    local project="${1:-$(basename $(pwd))}"
    local project_root="${2:-$(pwd)}"

    # Ensure .gua exists
    if [[ ! -d "$project_root/.gua" ]]; then
        cmd_dir_init "$project_root"
    fi

    local path_dir="$project_root/.gua/path"
    mkdir -p "$path_dir"

    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Create path manifest
    cat > "$path_dir/manifest.json" << EOF
{
  "version": "1.0.0",
  "project": "$project",
  "createdAt": "$timestamp",
  "updatedAt": "$timestamp",
  "currentWaypoint": null,
  "waypointCount": 0,
  "purposeDefined": false,
  "stateDefined": false
}
EOF

    # Create CURRENT_STATE.md template
    if [[ ! -f "$path_dir/CURRENT_STATE.md" ]]; then
        cat > "$path_dir/CURRENT_STATE.md" << 'EOF'
# Current State Assessment

**Date**: [auto-updated]
**Project**: [project-name]

## What Works
- [ ] [Feature/function that passes E2E]

## What Doesn't Work
- [ ] [Feature/function that fails E2E]

## What's Partially Working
- [ ] [Feature at X% - description]

## Known Obstacles
- [ ] [Challenge from CPT]

## Current Capabilities
- [What the system CAN do now]

## Current Limitations
- [What the system CANNOT do now]

## Baseline Metrics
- E2E pass rate: X/Y tests
- Coverage: X%
- Open challenges: N
EOF
    fi

    # Create PURPOSE.md template
    if [[ ! -f "$path_dir/PURPOSE.md" ]]; then
        cat > "$path_dir/PURPOSE.md" << 'EOF'
# Purpose Definition

**Project**: [project-name]
**Purpose Statement**: [One sentence describing the ideal state]

## Success Criteria (Measurable)
1. [ ] [Specific, testable criterion]
2. [ ] [Specific, testable criterion]
3. [ ] [Specific, testable criterion]

## E2E Tests That Must Pass
- [ ] [test-name]: [what it validates]

## Capabilities Required
- [What the system MUST be able to do]

## Quality Requirements
- Performance: [metric]
- Reliability: [metric]
- UX: [metric]

## Out of Scope (Explicitly)
- [What we are NOT building]

## Definition of Done
When ALL of the following are true:
1. All success criteria checked
2. All E2E tests passing
3. All required capabilities demonstrated
4. All quality metrics met
EOF
    fi

    # Create waypoints directory
    mkdir -p "$path_dir/waypoints"

    echo -e "${GREEN}✓ Path protocol initialized for: $project${NC}"
    echo "  Files created:"
    echo "    - $path_dir/manifest.json"
    echo "    - $path_dir/CURRENT_STATE.md"
    echo "    - $path_dir/PURPOSE.md"
    echo "    - $path_dir/waypoints/"
    echo ""
    echo "Next steps:"
    echo "  1. Edit PURPOSE.md to define your goal"
    echo "  2. Run 'gua path assess' to document current state"
    echo "  3. Run 'gua path waypoint add' to define milestones"
}

# Show/update current state
cmd_path_state() {
    local project_root="${1:-$(pwd)}"
    project_root=$(cd "$project_root" && pwd)
    local path_dir="$project_root/.gua/path"

    if [[ ! -d "$path_dir" ]]; then
        echo -e "${RED}Path protocol not initialized. Run 'gua path init' first.${NC}"
        return 1
    fi

    echo -e "${BLUE}=== Current State Assessment ===${NC}"
    echo ""

    if [[ -f "$path_dir/CURRENT_STATE.md" ]]; then
        cat "$path_dir/CURRENT_STATE.md"
    else
        echo "No current state documented."
    fi
}

# Show/update purpose
cmd_path_purpose() {
    local project_root="${1:-$(pwd)}"
    project_root=$(cd "$project_root" && pwd)
    local path_dir="$project_root/.gua/path"

    if [[ ! -d "$path_dir" ]]; then
        echo -e "${RED}Path protocol not initialized. Run 'gua path init' first.${NC}"
        return 1
    fi

    echo -e "${BLUE}=== Purpose Definition ===${NC}"
    echo ""

    if [[ -f "$path_dir/PURPOSE.md" ]]; then
        cat "$path_dir/PURPOSE.md"
    else
        echo "No purpose defined."
    fi
}

# Add a waypoint
cmd_path_waypoint_add() {
    local project_root
    local name="$1"
    local predecessor="${2:-CURRENT_STATE}"

    project_root=$(pwd)
    local path_dir="$project_root/.gua/path"

    if [[ ! -d "$path_dir" ]]; then
        echo -e "${RED}Path protocol not initialized. Run 'gua path init' first.${NC}"
        return 1
    fi

    if [[ -z "$name" ]]; then
        echo -e "${RED}Usage: gua path waypoint add <name> [predecessor]${NC}"
        return 1
    fi

    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local waypoint_count=$(jq -r '.waypointCount' "$path_dir/manifest.json")
    local new_count=$((waypoint_count + 1))
    local waypoint_id="W${new_count}"

    # Sanitize name for filename
    local safe_name=$(echo "$name" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')
    local waypoint_file="$path_dir/waypoints/${waypoint_id}-${safe_name}.md"
    local waypoint_json="$path_dir/waypoints/${waypoint_id}-${safe_name}.json"

    # Create waypoint markdown
    cat > "$waypoint_file" << EOF
# Waypoint: ${waypoint_id} - ${name}

**Created**: $timestamp
**Predecessor**: $predecessor
**Successor**: [next waypoint or PURPOSE]
**Status**: pending

## What This Waypoint Achieves
[Description of state after this waypoint]

## Success Criteria
1. [ ] [Specific, testable]
2. [ ] [Specific, testable]

## E2E Tests That Must Pass
- [ ] [test-name]

## Dependencies
- [What must exist before this waypoint]

## Known Risks
- [What might go wrong]

## Notes
EOF

    # Create waypoint metadata
    cat > "$waypoint_json" << EOF
{
  "id": "$waypoint_id",
  "name": "$name",
  "predecessor": "$predecessor",
  "successor": null,
  "status": "pending",
  "impl": 0,
  "depth": "L0",
  "createdAt": "$timestamp",
  "updatedAt": "$timestamp",
  "validatedAt": null
}
EOF

    # Update manifest
    jq --arg ts "$timestamp" --argjson count "$new_count" --arg wp "$waypoint_id" \
       '.updatedAt = $ts | .waypointCount = $count | .currentWaypoint = (if .currentWaypoint == null then $wp else .currentWaypoint end)' \
       "$path_dir/manifest.json" > "$path_dir/manifest.json.tmp" && mv "$path_dir/manifest.json.tmp" "$path_dir/manifest.json"

    echo -e "${GREEN}✓ Waypoint created: ${waypoint_id} - ${name}${NC}"
    echo "  File: $waypoint_file"
    echo ""
    echo "Edit the waypoint file to define success criteria and details."
}

# List waypoints
cmd_path_waypoint_list() {
    local project_root="${1:-$(pwd)}"
    project_root=$(cd "$project_root" && pwd)
    local path_dir="$project_root/.gua/path"

    if [[ ! -d "$path_dir" ]]; then
        echo -e "${RED}Path protocol not initialized. Run 'gua path init' first.${NC}"
        return 1
    fi

    local current_wp=$(jq -r '.currentWaypoint // "none"' "$path_dir/manifest.json")

    echo -e "${BLUE}=== Waypoints ===${NC}"
    echo "Current: $current_wp"
    echo ""

    if [[ ! -d "$path_dir/waypoints" ]] || ! ls -1 "$path_dir/waypoints/"*.json &>/dev/null; then
        echo "No waypoints defined yet."
        echo "Run 'gua path waypoint add <name>' to create one."
        return 0
    fi

    echo "CURRENT STATE"
    echo "     │"

    for json_file in "$path_dir/waypoints/"*.json; do
        local id=$(jq -r '.id' "$json_file")
        local name=$(jq -r '.name' "$json_file")
        local status=$(jq -r '.status' "$json_file")
        local impl=$(jq -r '.impl' "$json_file")
        local depth=$(jq -r '.depth' "$json_file")

        local status_icon="○"
        local status_color="${NC}"
        case "$status" in
            completed) status_icon="●"; status_color="${GREEN}" ;;
            in_progress) status_icon="◐"; status_color="${YELLOW}" ;;
            blocked) status_icon="✕"; status_color="${RED}" ;;
        esac

        local marker=""
        [[ "$id" == "$current_wp" ]] && marker=" ← CURRENT"

        echo "     ▼"
        echo -e "  ${status_color}${status_icon} ${id}: ${name}${NC}${marker}"
        echo "     │  Status: $status | Impl: ${impl}% | Depth: $depth"
    done

    echo "     ▼"
    echo "  PURPOSE"
}

# Update waypoint
cmd_path_waypoint_update() {
    local waypoint_id="$1"
    shift

    local project_root=$(pwd)
    local path_dir="$project_root/.gua/path"

    if [[ ! -d "$path_dir" ]]; then
        echo -e "${RED}Path protocol not initialized. Run 'gua path init' first.${NC}"
        return 1
    fi

    if [[ -z "$waypoint_id" ]]; then
        echo -e "${RED}Usage: gua path waypoint update <id> [--status S] [--impl N] [--depth L]${NC}"
        return 1
    fi

    # Find the waypoint file
    local waypoint_json=$(ls "$path_dir/waypoints/${waypoint_id}-"*.json 2>/dev/null | head -1)

    if [[ ! -f "$waypoint_json" ]]; then
        echo -e "${RED}Waypoint not found: $waypoint_id${NC}"
        return 1
    fi

    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local new_status=""
    local new_impl=""
    local new_depth=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --status) new_status="$2"; shift 2 ;;
            --impl) new_impl="$2"; shift 2 ;;
            --depth) new_depth="$2"; shift 2 ;;
            *) shift ;;
        esac
    done

    # Update the JSON file
    local tmp_file=$(mktemp)
    cp "$waypoint_json" "$tmp_file"

    if [[ -n "$new_status" ]]; then
        jq --arg s "$new_status" '.status = $s' "$tmp_file" > "${tmp_file}.2" && mv "${tmp_file}.2" "$tmp_file"
    fi

    if [[ -n "$new_impl" ]]; then
        jq --argjson i "$new_impl" '.impl = $i' "$tmp_file" > "${tmp_file}.2" && mv "${tmp_file}.2" "$tmp_file"
    fi

    if [[ -n "$new_depth" ]]; then
        jq --arg d "$new_depth" '.depth = $d' "$tmp_file" > "${tmp_file}.2" && mv "${tmp_file}.2" "$tmp_file"
    fi

    jq --arg ts "$timestamp" '.updatedAt = $ts' "$tmp_file" > "${tmp_file}.2" && mv "${tmp_file}.2" "$tmp_file"

    mv "$tmp_file" "$waypoint_json"

    # Update manifest
    jq --arg ts "$timestamp" '.updatedAt = $ts' "$path_dir/manifest.json" > "$path_dir/manifest.json.tmp" && \
        mv "$path_dir/manifest.json.tmp" "$path_dir/manifest.json"

    echo -e "${GREEN}✓ Waypoint updated: $waypoint_id${NC}"
    jq -r '"  Status: \(.status) | Impl: \(.impl)% | Depth: \(.depth)"' "$waypoint_json"
}

# Set current waypoint
cmd_path_waypoint_current() {
    local waypoint_id="$1"
    local project_root=$(pwd)
    local path_dir="$project_root/.gua/path"

    if [[ ! -d "$path_dir" ]]; then
        echo -e "${RED}Path protocol not initialized. Run 'gua path init' first.${NC}"
        return 1
    fi

    if [[ -z "$waypoint_id" ]]; then
        # Just show current
        jq -r '"Current waypoint: \(.currentWaypoint // "none")"' "$path_dir/manifest.json"
        return 0
    fi

    # Verify waypoint exists
    if ! ls "$path_dir/waypoints/${waypoint_id}-"*.json &>/dev/null; then
        echo -e "${RED}Waypoint not found: $waypoint_id${NC}"
        return 1
    fi

    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    jq --arg wp "$waypoint_id" --arg ts "$timestamp" \
       '.currentWaypoint = $wp | .updatedAt = $ts' \
       "$path_dir/manifest.json" > "$path_dir/manifest.json.tmp" && \
       mv "$path_dir/manifest.json.tmp" "$path_dir/manifest.json"

    echo -e "${GREEN}✓ Current waypoint set to: $waypoint_id${NC}"
}

# Run path assessment (combines E2E status + GUA status)
cmd_path_assess() {
    local project_root="${1:-$(pwd)}"
    project_root=$(cd "$project_root" && pwd)

    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║       PATH PROTOCOL ASSESSMENT         ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo ""

    # E2E Status (if e2e.sh exists)
    if [[ -f "$GUA_DIR/e2e.sh" ]]; then
        echo -e "${YELLOW}━━━ E2E Status ━━━${NC}"
        "$GUA_DIR/e2e.sh" status 2>/dev/null || echo "  (E2E not configured)"
        echo ""
    fi

    # Open challenges
    echo -e "${YELLOW}━━━ Open Challenges ━━━${NC}"
    cmd_challenge_list "--status" "open" 2>/dev/null || echo "  No open challenges"
    echo ""

    # Progress
    echo -e "${YELLOW}━━━ Progress Dashboard ━━━${NC}"
    cmd_progress 2>/dev/null || echo "  No progress tracked"
    echo ""

    # Tracked areas
    echo -e "${YELLOW}━━━ Tracked Areas ━━━${NC}"
    cmd_area_status 2>/dev/null || echo "  No areas tracked"
    echo ""

    # Directory context
    echo -e "${YELLOW}━━━ Directory Context ━━━${NC}"
    cmd_context "$project_root" 2>/dev/null | head -30
}

# Validate current waypoint
cmd_path_validate() {
    local project_root="${1:-$(pwd)}"
    local waypoint_id="${2:-}"
    project_root=$(cd "$project_root" && pwd)
    local path_dir="$project_root/.gua/path"

    if [[ ! -d "$path_dir" ]]; then
        echo -e "${RED}Path protocol not initialized. Run 'gua path init' first.${NC}"
        return 1
    fi

    # Get current waypoint if not specified
    if [[ -z "$waypoint_id" ]]; then
        waypoint_id=$(jq -r '.currentWaypoint // ""' "$path_dir/manifest.json")
    fi

    if [[ -z "$waypoint_id" || "$waypoint_id" == "null" ]]; then
        echo -e "${RED}No current waypoint set. Use 'gua path waypoint current <id>' to set one.${NC}"
        return 1
    fi

    local waypoint_json=$(ls "$path_dir/waypoints/${waypoint_id}-"*.json 2>/dev/null | head -1)
    local waypoint_md=$(ls "$path_dir/waypoints/${waypoint_id}-"*.md 2>/dev/null | head -1)

    if [[ ! -f "$waypoint_json" ]]; then
        echo -e "${RED}Waypoint not found: $waypoint_id${NC}"
        return 1
    fi

    local name=$(jq -r '.name' "$waypoint_json")

    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║     WAYPOINT VALIDATION: ${waypoint_id}${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo "Waypoint: $name"
    echo ""

    # Run E2E if available
    if [[ -f "$GUA_DIR/e2e.sh" ]]; then
        echo -e "${YELLOW}━━━ Running E2E Validation ━━━${NC}"
        "$GUA_DIR/e2e.sh" run 2>/dev/null || echo "  E2E tests completed (check output above)"
        echo ""
    else
        echo -e "${YELLOW}━━━ E2E Not Configured ━━━${NC}"
        echo "  Run 'gua e2e init' to configure E2E testing"
        echo ""
    fi

    # Show waypoint criteria
    echo -e "${YELLOW}━━━ Success Criteria ━━━${NC}"
    if [[ -f "$waypoint_md" ]]; then
        grep -A 10 "## Success Criteria" "$waypoint_md" 2>/dev/null | head -12
    fi
    echo ""

    echo -e "${YELLOW}━━━ Validation Checklist ━━━${NC}"
    echo "  [ ] Waypoint-specific tests pass"
    echo "  [ ] No regression in existing tests"
    echo "  [ ] Performance within bounds"
    echo "  [ ] No new errors in logs"
    echo ""
    echo "If all criteria met, run:"
    echo "  gua path waypoint update $waypoint_id --status completed"
    echo ""
    echo "If validation fails, diagnose and run:"
    echo "  gua path adjust \"[reason]\""
}

# Log path adjustment
cmd_path_adjust() {
    local reason="$1"
    local project_root=$(pwd)
    local path_dir="$project_root/.gua/path"

    if [[ ! -d "$path_dir" ]]; then
        echo -e "${RED}Path protocol not initialized. Run 'gua path init' first.${NC}"
        return 1
    fi

    if [[ -z "$reason" ]]; then
        echo -e "${RED}Usage: gua path adjust \"<reason>\"${NC}"
        echo ""
        echo "Adjustment types:"
        echo "  - Bug: Implementation issue to fix"
        echo "  - Approach: Wrong approach, need alternative"
        echo "  - Dependency: Missing prerequisite"
        echo "  - Assumption: Incorrect understanding"
        echo "  - Constraint: External limitation discovered"
        echo "  - Purpose: Goal needs refinement"
        return 1
    fi

    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local current_wp=$(jq -r '.currentWaypoint // "unknown"' "$path_dir/manifest.json")

    # Log as insight
    cmd_insight_log "Path adjustment at $current_wp: $reason" "constraint" "validation failure" "truth" "project"

    # Append to adjustments log
    local adjustments_log="$path_dir/adjustments.jsonl"
    echo "{\"timestamp\":\"$timestamp\",\"waypoint\":\"$current_wp\",\"reason\":\"$reason\"}" >> "$adjustments_log"

    echo -e "${YELLOW}✓ Path adjustment logged${NC}"
    echo "  Waypoint: $current_wp"
    echo "  Reason: $reason"
    echo ""
    echo "Next steps:"
    echo "  1. Diagnose the root cause"
    echo "  2. Research alternatives: gua research \"<topic>\" \"<finding>\""
    echo "  3. Update waypoint if needed"
    echo "  4. Re-attempt validation: gua path validate"
}

# Show comprehensive path status
cmd_path_status() {
    local project_root="${1:-$(pwd)}"
    project_root=$(cd "$project_root" && pwd)
    local path_dir="$project_root/.gua/path"

    if [[ ! -d "$path_dir" ]]; then
        echo -e "${RED}Path protocol not initialized. Run 'gua path init' first.${NC}"
        return 1
    fi

    local manifest="$path_dir/manifest.json"
    local project=$(jq -r '.project' "$manifest")
    local current_wp=$(jq -r '.currentWaypoint // "none"' "$manifest")
    local wp_count=$(jq -r '.waypointCount' "$manifest")

    echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║        PATH PROTOCOL STATUS            ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo "Project: $project"
    echo "Current Waypoint: $current_wp"
    echo "Total Waypoints: $wp_count"
    echo ""

    # Calculate completed waypoints
    local completed=0
    local in_progress=0
    local pending=0
    local blocked=0

    if [[ -d "$path_dir/waypoints" ]] && ls -1 "$path_dir/waypoints/"*.json &>/dev/null; then
        for json_file in "$path_dir/waypoints/"*.json; do
            local status=$(jq -r '.status' "$json_file")
            case "$status" in
                completed) ((completed++)) ;;
                in_progress) ((in_progress++)) ;;
                blocked) ((blocked++)) ;;
                *) ((pending++)) ;;
            esac
        done
    fi

    echo -e "${GREEN}━━━ Waypoint Summary ━━━${NC}"
    echo "  Completed: $completed"
    echo "  In Progress: $in_progress"
    echo "  Pending: $pending"
    echo "  Blocked: $blocked"
    echo ""

    # Calculate purpose progress
    local purpose_progress=0
    if [[ $wp_count -gt 0 ]]; then
        purpose_progress=$((completed * 100 / wp_count))
    fi

    echo -e "${GREEN}━━━ Progress ━━━${NC}"
    echo "  Purpose Progress: ${purpose_progress}% ($completed/$wp_count waypoints)"
    echo ""

    # Show path visualization
    echo -e "${GREEN}━━━ Path Visualization ━━━${NC}"
    cmd_path_waypoint_list "$project_root" 2>/dev/null
    echo ""

    # Show E2E status if available
    local e2e_latest="$path_dir/e2e-assessments/latest.json"
    if [[ -f "$e2e_latest" ]]; then
        echo -e "${GREEN}━━━ E2E Status ━━━${NC}"
        local e2e_passed=$(jq -r '.passed' "$e2e_latest")
        local e2e_failed=$(jq -r '.failed' "$e2e_latest")
        local e2e_total=$(jq -r '.total' "$e2e_latest")
        local e2e_rate=$(jq -r '.passRate' "$e2e_latest")
        local e2e_time=$(jq -r '.timestamp' "$e2e_latest")

        echo "  Last Run: $e2e_time"
        echo "  Tests: ${e2e_passed}/${e2e_total} passing (${e2e_rate}%)"
        if [[ $e2e_failed -gt 0 ]]; then
            echo -e "  ${RED}Failing: $e2e_failed tests${NC}"
        else
            echo -e "  ${GREEN}All tests passing${NC}"
        fi
        echo ""
    else
        echo -e "${YELLOW}━━━ E2E Status ━━━${NC}"
        echo "  No E2E results yet"
        echo "  Run: e2e path-assess"
        echo ""
    fi

    # Show recent adjustments
    if [[ -f "$path_dir/adjustments.jsonl" ]]; then
        echo -e "${YELLOW}━━━ Recent Adjustments ━━━${NC}"
        tail -5 "$path_dir/adjustments.jsonl" | while read -r line; do
            local wp=$(echo "$line" | jq -r '.waypoint')
            local reason=$(echo "$line" | jq -r '.reason')
            echo "  [$wp] $reason"
        done
        echo ""
    fi

    # Quick commands
    echo -e "${GREEN}━━━ Quick Commands ━━━${NC}"
    echo "  e2e path-assess        # Run E2E assessment"
    echo "  e2e path-validate      # Validate current waypoint"
    echo "  gua path waypoint update $current_wp --status <s>"
}

# List available waypoint templates
cmd_path_template_list() {
    local template_dir="$GUA_DIR/templates/waypoints"

    echo -e "${BLUE}=== Available Waypoint Templates ===${NC}"
    echo ""

    if [[ ! -d "$template_dir" ]] || ! ls -1 "$template_dir/"*.md &>/dev/null; then
        echo "No templates found in: $template_dir"
        return 0
    fi

    for template in "$template_dir/"*.md; do
        local name=$(basename "$template" .md)
        local type_line=$(grep "^\*\*Type\*\*:" "$template" 2>/dev/null | head -1)
        local use_line=$(grep "^\*\*Use when\*\*:" "$template" 2>/dev/null | head -1)

        echo -e "${GREEN}$name${NC}"
        [[ -n "$type_line" ]] && echo "  $type_line"
        [[ -n "$use_line" ]] && echo "  $use_line"
        echo ""
    done

    echo "Usage: gua path template use <name> <waypoint-name>"
}

# Use a waypoint template
cmd_path_template_use() {
    local template_name="$1"
    local waypoint_name="$2"
    local predecessor="${3:-CURRENT_STATE}"

    local template_dir="$GUA_DIR/templates/waypoints"
    local template_file="$template_dir/${template_name}.md"

    if [[ -z "$template_name" || -z "$waypoint_name" ]]; then
        echo -e "${RED}Usage: gua path template use <template> <waypoint-name> [predecessor]${NC}"
        echo ""
        echo "Available templates:"
        ls -1 "$template_dir/"*.md 2>/dev/null | xargs -I{} basename {} .md | sed 's/^/  /'
        return 1
    fi

    if [[ ! -f "$template_file" ]]; then
        echo -e "${RED}Template not found: $template_name${NC}"
        echo "Available templates:"
        ls -1 "$template_dir/"*.md 2>/dev/null | xargs -I{} basename {} .md | sed 's/^/  /'
        return 1
    fi

    local project_root=$(pwd)
    local path_dir="$project_root/.gua/path"

    if [[ ! -d "$path_dir" ]]; then
        echo -e "${RED}Path protocol not initialized. Run 'gua path init' first.${NC}"
        return 1
    fi

    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local waypoint_count=$(jq -r '.waypointCount' "$path_dir/manifest.json")
    local new_count=$((waypoint_count + 1))
    local waypoint_id="W${new_count}"

    # Sanitize name for filename
    local safe_name=$(echo "$waypoint_name" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')
    local waypoint_file="$path_dir/waypoints/${waypoint_id}-${safe_name}.md"
    local waypoint_json="$path_dir/waypoints/${waypoint_id}-${safe_name}.json"

    # Create waypoint from template
    {
        echo "# Waypoint: ${waypoint_id} - ${waypoint_name}"
        echo ""
        echo "**Created**: $timestamp"
        echo "**Predecessor**: $predecessor"
        echo "**Successor**: [next waypoint or PURPOSE]"
        echo "**Status**: pending"
        echo ""
        # Skip the first header from template and append rest
        tail -n +2 "$template_file"
    } > "$waypoint_file"

    # Create waypoint metadata with template info
    cat > "$waypoint_json" << EOF
{
  "id": "$waypoint_id",
  "name": "$waypoint_name",
  "template": "$template_name",
  "predecessor": "$predecessor",
  "successor": null,
  "status": "pending",
  "impl": 0,
  "depth": "L0",
  "createdAt": "$timestamp",
  "updatedAt": "$timestamp",
  "validatedAt": null
}
EOF

    # Update manifest
    jq --arg ts "$timestamp" --argjson count "$new_count" --arg wp "$waypoint_id" \
       '.updatedAt = $ts | .waypointCount = $count | .currentWaypoint = (if .currentWaypoint == null then $wp else .currentWaypoint end)' \
       "$path_dir/manifest.json" > "$path_dir/manifest.json.tmp" && mv "$path_dir/manifest.json.tmp" "$path_dir/manifest.json"

    echo -e "${GREEN}✓ Waypoint created from template: ${waypoint_id} - ${waypoint_name}${NC}"
    echo "  Template: $template_name"
    echo "  File: $waypoint_file"
    echo ""
    echo "Edit the waypoint file to customize success criteria."
}

# ============================================================
# THREAD - Cross-session continuity
# ============================================================

cmd_thread_start() {
    local name="$1"
    local objective=""

    # Parse arguments
    shift
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --objective)
                objective="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done

    if [[ -z "$name" ]]; then
        echo -e "${RED}Usage: gua thread start <name> [--objective \"...\"]${NC}"
        return 1
    fi

    load_config

    local timestamp=$(timestamp)
    local date_part=$(date +%Y-%m-%d)
    local thread_id="${name}-${date_part}"

    # Check if thread already exists
    local existing=$(aws dynamodb get-item \
        --table-name "gua-threads" \
        --key "{\"user_id\": {\"S\": \"$USER_ID\"}, \"thread_id\": {\"S\": \"$thread_id\"}}" \
        --region "$REGION" 2>/dev/null | jq -r '.Item.thread_id.S // empty')

    if [[ -n "$existing" ]]; then
        echo -e "${YELLOW}Thread already exists: $thread_id${NC}"
        echo "Use 'gua thread resume $thread_id' to continue"
        return 1
    fi

    # Create thread in DynamoDB
    aws dynamodb put-item \
        --table-name "gua-threads" \
        --item "{
            \"user_id\": {\"S\": \"$USER_ID\"},
            \"thread_id\": {\"S\": \"$thread_id\"},
            \"name\": {\"S\": \"$name\"},
            \"status\": {\"S\": \"active\"},
            \"objective\": {\"S\": \"${objective:-No objective specified}\"},
            \"created_at\": {\"S\": \"$timestamp\"},
            \"updated_at\": {\"S\": \"$timestamp\"},
            \"session_count\": {\"N\": \"1\"},
            \"last_session_id\": {\"S\": \"\"},
            \"last_session_summary\": {\"S\": \"\"}
        }" \
        --region "$REGION" 2>/dev/null

    # Create S3 directory structure
    aws s3api put-object --bucket "$S3_BUCKET" --key "threads/${thread_id}/" --region "$REGION" 2>/dev/null

    # Create THREAD.md
    local thread_md="# THREAD: ${name}

> Thread ID: ${thread_id}
> Status: active
> Sessions: 1
> Created: ${timestamp}
> Last active: ${timestamp}

## Objective
${objective:-No objective specified}

## Current State
- [ ] (Add tasks as you work)

## Key Decisions
(Decisions will be logged here)

## Open Questions
(Questions will be logged here)

## Blockers
(None)

## Session History
| Session | Date | Summary |
|---------|------|---------|
| (first) | ${date_part} | Started thread |

## Next Session Primer
Continue from where you left off.
"

    echo "$thread_md" | aws s3 cp - "s3://$S3_BUCKET/threads/${thread_id}/THREAD.md" --region "$REGION" 2>/dev/null

    # Save current thread to state
    jq --arg tid "$thread_id" '.current_thread = $tid' "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"

    echo -e "${GREEN}[GUA] Thread started: $thread_id${NC}"
    echo "  Objective: ${objective:-No objective specified}"
    echo ""
    echo "Commands:"
    echo "  gua moment \"<content>\"    - Capture key moments"
    echo "  gua handoff               - Generate handoff at session end"
    echo "  gua thread pause          - Pause this thread"
    echo "  gua thread complete       - Mark thread as complete"
}

cmd_thread_list() {
    local status_filter="${1:-all}"

    load_config

    echo -e "${BLUE}[GUA] Threads${NC}"
    echo ""

    local query_result
    if [[ "$status_filter" == "all" ]]; then
        query_result=$(aws dynamodb query \
            --table-name "gua-threads" \
            --key-condition-expression "user_id = :uid" \
            --expression-attribute-values "{\":uid\": {\"S\": \"$USER_ID\"}}" \
            --region "$REGION" 2>/dev/null)
    else
        query_result=$(aws dynamodb query \
            --table-name "gua-threads" \
            --index-name "status-index" \
            --key-condition-expression "user_id = :uid AND #status = :status" \
            --expression-attribute-names '{"#status": "status"}' \
            --expression-attribute-values "{\":uid\": {\"S\": \"$USER_ID\"}, \":status\": {\"S\": \"$status_filter\"}}" \
            --region "$REGION" 2>/dev/null)
    fi

    local count=$(echo "$query_result" | jq '.Items | length')

    if [[ "$count" == "0" ]]; then
        echo "  No threads found"
        return 0
    fi

    # Get current thread
    local current_thread=$(jq -r '.current_thread // ""' "$STATE_FILE")

    echo "$query_result" | jq -r '.Items[] | [.thread_id.S, .status.S, .objective.S // "No objective", .session_count.N, .updated_at.S] | @tsv' | while IFS=$'\t' read -r tid status obj sessions updated; do
        local marker=""
        if [[ "$tid" == "$current_thread" ]]; then
            marker=" ${GREEN}◀ current${NC}"
        fi

        local status_color=""
        case "$status" in
            active) status_color="${GREEN}$status${NC}" ;;
            paused) status_color="${YELLOW}$status${NC}" ;;
            completed) status_color="${BLUE}$status${NC}" ;;
            *) status_color="$status" ;;
        esac

        echo -e "  ${BLUE}$tid${NC}$marker"
        echo -e "    Status: $status_color | Sessions: $sessions"
        echo "    Objective: ${obj:0:60}..."
        echo ""
    done
}

cmd_thread_resume() {
    local thread_id="$1"

    if [[ -z "$thread_id" ]]; then
        echo -e "${RED}Usage: gua thread resume <thread-id>${NC}"
        echo "Use 'gua thread list' to see available threads"
        return 1
    fi

    load_config

    # Check thread exists
    local thread=$(aws dynamodb get-item \
        --table-name "gua-threads" \
        --key "{\"user_id\": {\"S\": \"$USER_ID\"}, \"thread_id\": {\"S\": \"$thread_id\"}}" \
        --region "$REGION" 2>/dev/null)

    local existing=$(echo "$thread" | jq -r '.Item.thread_id.S // empty')

    if [[ -z "$existing" ]]; then
        echo -e "${RED}Thread not found: $thread_id${NC}"
        echo "Use 'gua thread list' to see available threads"
        return 1
    fi

    local timestamp=$(timestamp)

    # Update thread status and increment session count
    aws dynamodb update-item \
        --table-name "gua-threads" \
        --key "{\"user_id\": {\"S\": \"$USER_ID\"}, \"thread_id\": {\"S\": \"$thread_id\"}}" \
        --update-expression "SET #status = :active, updated_at = :ts, session_count = session_count + :one" \
        --expression-attribute-names '{"#status": "status"}' \
        --expression-attribute-values "{\":active\": {\"S\": \"active\"}, \":ts\": {\"S\": \"$timestamp\"}, \":one\": {\"N\": \"1\"}}" \
        --region "$REGION" 2>/dev/null

    # Set as current thread
    jq --arg tid "$thread_id" '.current_thread = $tid' "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"

    # Download THREAD.md for display
    local thread_md=$(aws s3 cp "s3://$S3_BUCKET/threads/${thread_id}/THREAD.md" - --region "$REGION" 2>/dev/null)

    echo -e "${GREEN}[GUA] Thread resumed: $thread_id${NC}"
    echo ""

    # Extract and show key info
    local objective=$(echo "$thread" | jq -r '.Item.objective.S // "No objective"')
    local sessions=$(echo "$thread" | jq -r '.Item.session_count.N // "0"')

    echo "  Objective: $objective"
    echo "  Sessions: $((sessions + 1))"
    echo ""

    # Show primer section if exists
    if echo "$thread_md" | grep -q "## Next Session Primer"; then
        echo -e "${BLUE}Next Session Primer:${NC}"
        echo "$thread_md" | sed -n '/## Next Session Primer/,/^##/p' | head -n -1 | tail -n +2
    fi
}

cmd_thread_pause() {
    local thread_id="$1"

    load_config

    # Use current thread if not specified
    if [[ -z "$thread_id" ]]; then
        thread_id=$(jq -r '.current_thread // ""' "$STATE_FILE")
    fi

    if [[ -z "$thread_id" ]]; then
        echo -e "${RED}No active thread. Specify thread ID or start one.${NC}"
        return 1
    fi

    local timestamp=$(timestamp)

    # Update status to paused
    aws dynamodb update-item \
        --table-name "gua-threads" \
        --key "{\"user_id\": {\"S\": \"$USER_ID\"}, \"thread_id\": {\"S\": \"$thread_id\"}}" \
        --update-expression "SET #status = :paused, updated_at = :ts" \
        --expression-attribute-names '{"#status": "status"}' \
        --expression-attribute-values "{\":paused\": {\"S\": \"paused\"}, \":ts\": {\"S\": \"$timestamp\"}}" \
        --region "$REGION" 2>/dev/null

    # Clear current thread
    jq 'del(.current_thread)' "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"

    echo -e "${GREEN}[GUA] Thread paused: $thread_id${NC}"
    echo "Use 'gua thread resume $thread_id' to continue later"
}

cmd_thread_complete() {
    local thread_id="$1"
    local summary=""

    load_config

    # Use current thread if not specified
    if [[ -z "$thread_id" ]]; then
        thread_id=$(jq -r '.current_thread // ""' "$STATE_FILE")
    fi

    if [[ -z "$thread_id" ]]; then
        echo -e "${RED}No active thread. Specify thread ID.${NC}"
        return 1
    fi

    # Parse --summary if provided
    shift
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --summary)
                summary="$2"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done

    local timestamp=$(timestamp)

    # Update status to completed
    aws dynamodb update-item \
        --table-name "gua-threads" \
        --key "{\"user_id\": {\"S\": \"$USER_ID\"}, \"thread_id\": {\"S\": \"$thread_id\"}}" \
        --update-expression "SET #status = :completed, updated_at = :ts, last_session_summary = :summary" \
        --expression-attribute-names '{"#status": "status"}' \
        --expression-attribute-values "{\":completed\": {\"S\": \"completed\"}, \":ts\": {\"S\": \"$timestamp\"}, \":summary\": {\"S\": \"${summary:-Thread completed}\"}}" \
        --region "$REGION" 2>/dev/null

    # Clear current thread
    jq 'del(.current_thread)' "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"

    echo -e "${GREEN}[GUA] Thread completed: $thread_id${NC}"
    if [[ -n "$summary" ]]; then
        echo "  Summary: $summary"
    fi
}

cmd_thread_show() {
    local thread_id="$1"

    load_config

    # Use current thread if not specified
    if [[ -z "$thread_id" ]]; then
        thread_id=$(jq -r '.current_thread // ""' "$STATE_FILE")
    fi

    if [[ -z "$thread_id" ]]; then
        echo -e "${RED}No thread specified and no current thread.${NC}"
        return 1
    fi

    # Download and display THREAD.md
    aws s3 cp "s3://$S3_BUCKET/threads/${thread_id}/THREAD.md" - --region "$REGION" 2>/dev/null
}

# ============================================================
# MOMENT - In-session capture
# ============================================================

cmd_moment() {
    local content="$1"
    local moment_type="${2:-context}"
    local pp_dimension=""
    local tier_hint=""

    if [[ -z "$content" ]]; then
        echo -e "${RED}Usage: gua moment <content> [--type decision|preference|insight|context] [--pp DIM] [--tier T|S|C|X]${NC}"
        return 1
    fi

    # Parse arguments
    shift
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --type)
                moment_type="$2"
                shift 2
                ;;
            --pp)
                pp_dimension="$2"
                shift 2
                ;;
            --tier)
                tier_hint="$2"
                shift 2
                ;;
            *)
                # Check if it looks like a type (backward compat)
                if [[ "$1" =~ ^(decision|preference|insight|context)$ ]]; then
                    moment_type="$1"
                fi
                shift
                ;;
        esac
    done

    load_config

    local timestamp=$(timestamp)
    local session_id=$(cat "$GUA_DIR/current_session" 2>/dev/null || echo "no-session")
    local thread_id=$(jq -r '.current_thread // ""' "$STATE_FILE")

    # Auto-detect PP dimension from type if not specified
    if [[ -z "$pp_dimension" ]]; then
        case "$moment_type" in
            decision) pp_dimension="justice" ;;
            preference) pp_dimension="understanding" ;;
            insight) pp_dimension="truth" ;;
            context) pp_dimension="understanding" ;;
        esac
    fi

    # Create moments directory locally
    local moments_dir="$GUA_DIR/moments"
    mkdir -p "$moments_dir"

    # Build moment JSON with richer metadata
    local moment_json=$(cat << EOF
{"timestamp": "$timestamp", "type": "$moment_type", "content": "$content", "session_id": "$session_id", "thread_id": "$thread_id", "pp_dimension": "$pp_dimension", "tier_hint": "$tier_hint"}
EOF
)
    echo "$moment_json" >> "$moments_dir/current.jsonl"

    # Update moment count in state
    local moment_count=$(wc -l < "$moments_dir/current.jsonl" 2>/dev/null || echo "0")
    jq --argjson mc "$moment_count" '.moment_count = $mc' "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"

    echo -e "${GREEN}✓ Moment captured${NC} [$moment_type] ${pp_dimension:+[pp:$pp_dimension]}"
    echo "  $content"
}

# ============================================================
# HANDOFF - Session handoff generation
# ============================================================

# Helper: Aggregate moments by type
aggregate_moments() {
    local moments_file="$1"

    if [[ ! -f "$moments_file" ]]; then
        echo ""
        return
    fi

    local decisions=$(jq -r 'select(.type == "decision") | .content' "$moments_file" 2>/dev/null | sed 's/^/- /')
    local preferences=$(jq -r 'select(.type == "preference") | .content' "$moments_file" 2>/dev/null | sed 's/^/- /')
    local insights=$(jq -r 'select(.type == "insight") | .content' "$moments_file" 2>/dev/null | sed 's/^/- /')
    local contexts=$(jq -r 'select(.type == "context") | .content' "$moments_file" 2>/dev/null | sed 's/^/- /')

    local output=""

    if [[ -n "$decisions" ]]; then
        output+="### Decisions
$decisions

"
    fi

    if [[ -n "$preferences" ]]; then
        output+="### Preferences Revealed
$preferences

"
    fi

    if [[ -n "$insights" ]]; then
        output+="### Insights
$insights

"
    fi

    if [[ -n "$contexts" ]]; then
        output+="### Context
$contexts

"
    fi

    echo "$output"
}

# Helper: Estimate session tier from moments
estimate_session_tier() {
    local moments_file="$GUA_DIR/moments/current.jsonl"

    if [[ ! -f "$moments_file" ]]; then
        echo "T"
        return
    fi

    local moment_count=$(wc -l < "$moments_file" | tr -d ' ')
    local decision_count=$(grep -c '"type":"decision"' "$moments_file" 2>/dev/null | head -1 || echo "0")
    decision_count="${decision_count:-0}"
    local thread_id=$(jq -r '.current_thread // ""' "$STATE_FILE")

    # Tier estimation logic
    if [[ $moment_count -le 1 ]]; then
        echo "T"
    elif [[ $moment_count -le 5 && $decision_count -le 2 ]]; then
        echo "S"
    elif [[ $moment_count -le 15 || -n "$thread_id" ]]; then
        echo "C"
    else
        echo "X"
    fi
}

# Helper: Detect preferences for auto-update
detect_preferences() {
    local moments_file="$GUA_DIR/moments/current.jsonl"

    if [[ ! -f "$moments_file" ]]; then
        echo "[]"
        return
    fi

    # Extract preference-type moments
    jq -s '[.[] | select(.type == "preference")]' "$moments_file" 2>/dev/null || echo "[]"
}

# Helper: Capture task state from TodoWrite
capture_task_state() {
    local todo_dir="$HOME/.claude/todos"

    if [[ ! -d "$todo_dir" ]]; then
        echo "No task state captured"
        return
    fi

    # Find most recent todo file
    local latest_todo=$(ls -t "$todo_dir"/*.json 2>/dev/null | head -1)

    if [[ -z "$latest_todo" ]]; then
        echo "No task state captured"
        return
    fi

    # Parse and format as markdown
    jq -r '.todos[] | if .status == "completed" then "- [x] " + .content else "- [ ] " + .content end' "$latest_todo" 2>/dev/null || echo "No task state captured"
}

# Helper: Update PARTNER.md with detected preferences
update_partner_auto() {
    local preferences="$1"
    local auto_mode=$(jq -r '.continuity.auto_partner_update // false' "$CONFIG_FILE")

    if [[ "$preferences" == "[]" || -z "$preferences" ]]; then
        return
    fi

    local pref_count=$(echo "$preferences" | jq 'length')

    if [[ "$pref_count" -eq 0 ]]; then
        return
    fi

    echo -e "${BLUE}[GUA] Detected $pref_count preference(s):${NC}"
    echo "$preferences" | jq -r '.[] | "  - " + .content'
    echo ""

    if [[ "$auto_mode" == "true" ]]; then
        echo "Auto-adding to PARTNER.md..."
        echo "$preferences" | jq -r '.[].content' | while read -r pref; do
            cmd_partner_note "$pref" 2>/dev/null
        done
    else
        echo -n "Add to PARTNER.md? [y/N] "
        read -r response
        if [[ "$response" =~ ^[Yy] ]]; then
            echo "$preferences" | jq -r '.[].content' | while read -r pref; do
                cmd_partner_note "$pref"
            done
        fi
    fi
}

# Verification gates for handoff quality
cmd_handoff_verify() {
    echo -e "${BLUE}[GUA] Continuity Verification Gates${NC}"
    echo ""

    local gates_passed=0
    local gates_total=5
    local moments_file="$GUA_DIR/moments/current.jsonl"

    # C1: RELATIONAL GATE
    echo -n "  [C1] RELATIONAL: Did I learn anything new about the user? "
    local prefs=$(detect_preferences)
    local pref_count=$(echo "$prefs" | jq 'length' 2>/dev/null || echo "0")
    if [[ "$pref_count" -gt 0 ]]; then
        echo -e "${GREEN}✓ YES - $pref_count preference(s) detected${NC}"
        ((gates_passed++))
    else
        echo -e "${YELLOW}? NO - Consider what you learned${NC}"
    fi

    # C2: CONTEXTUAL GATE
    echo -n "  [C2] CONTEXTUAL: Can a fresh Claude understand from SESSION.md? "
    local moments_count=$(wc -l < "$moments_file" 2>/dev/null | tr -d ' ' || echo "0")
    if [[ "$moments_count" -ge 3 ]]; then
        echo -e "${GREEN}✓ $moments_count moments captured${NC}"
        ((gates_passed++))
    else
        echo -e "${YELLOW}? Only $moments_count moments - consider adding context${NC}"
    fi

    # C3: TASK STATE GATE
    echo -n "  [C3] TASK STATE: Does captured state reflect actual state? "
    if [[ -d "$HOME/.claude/todos" ]] && [[ $(ls -1 "$HOME/.claude/todos"/*.json 2>/dev/null | wc -l) -gt 0 ]]; then
        echo -e "${GREEN}✓ TodoWrite state available${NC}"
        ((gates_passed++))
    else
        echo -e "${YELLOW}? No todo state found${NC}"
        ((gates_passed++))  # Don't fail for this
    fi

    # C4: HANDOFF GATE
    echo -n "  [C4] HANDOFF: Is next session primer actionable? "
    local decisions=$(grep '"type":"decision"' "$moments_file" 2>/dev/null | wc -l | tr -d ' ')
    decisions="${decisions:-0}"
    if [[ "$decisions" -ge 1 ]]; then
        echo -e "${GREEN}✓ $decisions decision(s) recorded${NC}"
        ((gates_passed++))
    else
        echo -e "${YELLOW}? No decisions recorded - what was decided?${NC}"
    fi

    # C5: ENTITY GATE
    echo -n "  [C5] ENTITY: Does PARTNER.md reflect accumulated relationship? "
    echo -e "${BLUE}? Auto-check via preferences${NC}"
    ((gates_passed++))

    echo ""
    echo "Gates: $gates_passed/$gates_total passed"

    if [[ $gates_passed -lt 3 ]]; then
        echo -e "${YELLOW}Consider enriching context before saving${NC}"
        return 1
    fi

    return 0
}

cmd_handoff() {
    local skip_verify=false
    local rich_mode=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --skip-verify) skip_verify=true; shift ;;
            --rich) rich_mode=true; shift ;;
            *) shift ;;
        esac
    done

    load_config

    local timestamp=$(timestamp)
    local session_id=$(cat "$GUA_DIR/current_session" 2>/dev/null || echo "$(uuid)")
    local thread_id=$(jq -r '.current_thread // ""' "$STATE_FILE")
    local moments_file="$GUA_DIR/moments/current.jsonl"

    echo -e "${BLUE}[GUA] Generating handoff...${NC}"

    # Run verification gates unless skipped
    if [[ "$skip_verify" != "true" ]]; then
        if ! cmd_handoff_verify; then
            echo ""
            echo -n "Continue with handoff anyway? [y/N] "
            read -r response
            if [[ ! "$response" =~ ^[Yy] ]]; then
                echo "Handoff cancelled. Add more context and try again."
                return 1
            fi
        fi
        echo ""
    fi

    # Estimate session tier
    local tier=$(estimate_session_tier)
    echo "  Session tier: [$tier]"

    # Aggregate moments by type
    local aggregated_moments=$(aggregate_moments "$moments_file")

    # Simple moments list for backward compat
    local moments_content=""
    if [[ -f "$moments_file" ]]; then
        moments_content=$(cat "$moments_file" | jq -r '[.type, .content] | "- " + .[1] + " [" + .[0] + "]"' 2>/dev/null || echo "")
    fi

    # Capture task state
    local task_state=$(capture_task_state)

    # Calculate duration from first/last moment
    local duration="unknown"
    if [[ -f "$moments_file" ]] && [[ $(wc -l < "$moments_file") -gt 1 ]]; then
        local first_ts=$(head -1 "$moments_file" | jq -r '.timestamp' 2>/dev/null)
        local last_ts=$(tail -1 "$moments_file" | jq -r '.timestamp' 2>/dev/null)
        if [[ -n "$first_ts" && -n "$last_ts" ]]; then
            duration="$first_ts to $last_ts"
        fi
    fi

    # Get thread objective if active
    local thread_objective=""
    if [[ -n "$thread_id" ]]; then
        thread_objective=$(aws dynamodb get-item \
            --table-name "gua-threads" \
            --key "{\"user_id\": {\"S\": \"$USER_ID\"}, \"thread_id\": {\"S\": \"$thread_id\"}}" \
            --region "$REGION" 2>/dev/null | jq -r '.Item.objective.S // ""')
    fi

    # Generate rich SESSION.md
    local session_md="# SESSION: ${session_id}

> Thread: ${thread_id:-none}
> Started: ${timestamp}
> Duration: ${duration}
> Tier: [${tier}]

## What Happened
${thread_objective:+Working on: $thread_objective}

${aggregated_moments:-No moments captured}

## All Moments (chronological)
${moments_content:-No moments captured this session}

## Tasks at Session End
${task_state}

## Handoff
Continue from current state. Key focus areas from this session are captured above.

---
*Generated by gua handoff | Run 'gua save' to persist to AWS*
"

    # Save locally first
    local local_sessions="$GUA_DIR/sessions"
    mkdir -p "$local_sessions"
    echo "$session_md" > "$local_sessions/${session_id}.md"

    # If thread active, update THREAD.md and DynamoDB
    if [[ -n "$thread_id" ]]; then
        echo "  Updating thread: $thread_id"

        # Generate one-line summary from decisions
        local summary=""
        if [[ -f "$moments_file" ]]; then
            summary=$(grep '"type":"decision"' "$moments_file" | head -1 | jq -r '.content' 2>/dev/null | cut -c1-60)
        fi
        summary="${summary:-Session completed}"

        # Update DynamoDB with session info
        aws dynamodb update-item \
            --table-name "gua-threads" \
            --key "{\"user_id\": {\"S\": \"$USER_ID\"}, \"thread_id\": {\"S\": \"$thread_id\"}}" \
            --update-expression "SET updated_at = :ts, last_session_id = :sid, last_session_summary = :sum" \
            --expression-attribute-values "{\":ts\": {\"S\": \"$timestamp\"}, \":sid\": {\"S\": \"$session_id\"}, \":sum\": {\"S\": \"$summary\"}}" \
            --region "$REGION" 2>/dev/null
    fi

    # Detect and handle preferences (Phase 4)
    local preferences=$(detect_preferences)
    if [[ "$tier" == "X" || "$tier" == "C" ]]; then
        update_partner_auto "$preferences"
    fi

    # Upload SESSION.md to S3
    echo "$session_md" | aws s3 cp - "s3://$S3_BUCKET/sessions/${session_id}/SESSION.md" --region "$REGION" 2>/dev/null

    # Clear moments
    rm -f "$moments_file"

    echo -e "${GREEN}[GUA] Handoff generated${NC}"
    echo "  Session: $session_id"
    echo "  Tier: [$tier]"
    echo "  File: $local_sessions/${session_id}.md"
    echo ""
    echo "Next steps:"
    echo "  1. Run 'gua save' to persist to AWS"
}

# ============================================================
# PRIME - Load context at session start
# ============================================================

# Helper: Extract key info from PARTNER.md
extract_partner_summary() {
    local partner_md="$1"

    if [[ -z "$partner_md" ]]; then
        echo "No partner profile found"
        return
    fi

    # Extract name from header
    local name=$(echo "$partner_md" | grep "^# PARTNER" | sed 's/# PARTNER - //')

    # Extract sessions count
    local sessions=$(echo "$partner_md" | grep "Sessions together:" | sed 's/.*Sessions together: //' | tr -d '\n')

    # Extract partnership date
    local since=$(echo "$partner_md" | grep "Partnership since:" | sed 's/.*Partnership since: //' | tr -d '\n')

    # Extract first few characteristics
    local chars=$(echo "$partner_md" | sed -n '/## Who .* Is/,/^##/p' | grep "^-" | head -3 | sed 's/^- //')

    # Extract communication preferences
    local comms=$(echo "$partner_md" | sed -n '/## Communication Preferences/,/^##/p' | grep "^-" | head -2 | sed 's/^- //')

    # Extract values
    local values=$(echo "$partner_md" | sed -n '/## Shared Values/,/^##/p' | grep "^-" | head -2 | sed 's/^- //')

    cat << EOF
**${name:-Partner}** - ${sessions:-1} sessions together since ${since:-recently}

**Key characteristics**:
$(echo "$chars" | sed 's/^/- /')

**Communication**: ${comms:-Direct and concise}

**Values**: ${values:-Quality and partnership}
EOF
}

# Helper: Extract thread summary
extract_thread_summary() {
    local thread_md="$1"

    if [[ -z "$thread_md" ]]; then
        echo "No active thread"
        return
    fi

    # Extract objective
    local objective=$(echo "$thread_md" | sed -n '/## Objective/,/^##/p' | grep -v "^##" | head -3)

    # Extract current state items
    local state=$(echo "$thread_md" | sed -n '/## Current State/,/^##/p' | grep "^\-" | head -5)

    # Extract key decisions
    local decisions=$(echo "$thread_md" | sed -n '/## Key Decisions/,/^##/p' | grep "^[0-9]" | head -3)

    # Extract next session primer
    local next_primer=$(echo "$thread_md" | sed -n '/## Next Session Primer/,/^##/p' | grep -v "^##" | head -3)

    cat << EOF
**Objective**: ${objective:-No objective specified}

**Current State**:
${state:-No tasks defined}

**Key Decisions**:
${decisions:-No decisions recorded yet}

**Focus**: ${next_primer:-Continue from where you left off}
EOF
}

# Helper: Get last session summary
get_last_session_summary() {
    local thread_id="$1"

    if [[ -z "$thread_id" ]]; then
        echo "No previous session in this context"
        return
    fi

    # Get last session ID from DynamoDB
    local last_sid=$(aws dynamodb get-item \
        --table-name "gua-threads" \
        --key "{\"user_id\": {\"S\": \"$USER_ID\"}, \"thread_id\": {\"S\": \"$thread_id\"}}" \
        --region "$REGION" 2>/dev/null | jq -r '.Item.last_session_id.S // ""')

    if [[ -z "$last_sid" ]]; then
        echo "No previous session recorded"
        return
    fi

    local last_summary=$(aws dynamodb get-item \
        --table-name "gua-threads" \
        --key "{\"user_id\": {\"S\": \"$USER_ID\"}, \"thread_id\": {\"S\": \"$thread_id\"}}" \
        --region "$REGION" 2>/dev/null | jq -r '.Item.last_session_summary.S // "No summary"')

    echo "Last session ($last_sid): $last_summary"
}

cmd_prime() {
    local thread_id=""
    local quick_mode=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --thread)
                thread_id="$2"
                shift 2
                ;;
            --quick)
                quick_mode=true
                shift
                ;;
            *)
                shift
                ;;
        esac
    done

    load_config

    echo -e "${BLUE}[GUA] Loading session context...${NC}"

    # Use current thread if not specified
    if [[ -z "$thread_id" ]]; then
        thread_id=$(jq -r '.current_thread // ""' "$STATE_FILE")
    fi

    # Load LIGHT.md (existing patterns)
    cmd_load_active_set 2>/dev/null

    local ts=$(timestamp)

    # Load PARTNER.md (and cache locally for continuity signal checks)
    mkdir -p "$GUA_DIR/entity"
    local partner_md=$(aws s3 cp "s3://$S3_BUCKET/entity/PARTNER.md" - --region "$REGION" 2>/dev/null || echo "")
    if [[ -n "$partner_md" ]]; then
        echo "$partner_md" > "$GUA_DIR/entity/PARTNER.md"
    fi
    local partner_summary=$(extract_partner_summary "$partner_md")

    # Load thread context if active
    local thread_md=""
    local thread_summary=""
    local last_session=""
    if [[ -n "$thread_id" ]]; then
        thread_md=$(aws s3 cp "s3://$S3_BUCKET/threads/${thread_id}/THREAD.md" - --region "$REGION" 2>/dev/null || echo "")
        thread_summary=$(extract_thread_summary "$thread_md")
        last_session=$(get_last_session_summary "$thread_id")

        # Set as current thread
        jq --arg tid "$thread_id" '.current_thread = $tid' "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
    fi

    # Get blindspots from LIGHT.md
    local light_file="$HOME/.claude/purpose_prompter/integration/LIGHT.md"
    local blindspots=""
    local patterns=""
    if [[ -f "$light_file" ]]; then
        blindspots=$(sed -n '/## Active Blindspots/,/^##/p' "$light_file" | grep "^###" | head -3 | sed 's/### /- /')
        patterns=$(sed -n '/## Top Patterns/,/^---/p' "$light_file" | grep "^###" | head -5 | sed 's/### /- /')
    fi

    # Generate comprehensive PRIMER
    local primer="# SESSION PRIMER

> Generated: ${ts}
> Thread: ${thread_id:-No active thread}

---

## Who You're Working With

${partner_summary}

---
"

    if [[ -n "$thread_id" ]]; then
        primer+="
## Current Thread: ${thread_id}

${thread_summary}

### Where We Left Off
${last_session}

---
"
    fi

    primer+="
## Active Knowledge (from LIGHT.md)

**Patterns to apply**:
${patterns:-No patterns loaded}

**Blindspots to watch**:
${blindspots:-No blindspots loaded}

---

## Quick Commands

\`\`\`bash
gua moment \"...\"           # Capture key moment
gua thread show             # Show thread details
gua handoff                 # Generate session handoff
\`\`\`

---

*Ready to continue*
"

    # Save primer
    echo "$primer" > "$GUA_DIR/PRIMER.md"

    echo -e "${GREEN}[GUA] Context loaded${NC}"
    echo "  Primer saved to: $GUA_DIR/PRIMER.md"
    if [[ -n "$thread_id" ]]; then
        echo "  Active thread: $thread_id"
    fi
    echo ""

    # Show brief summary
    if [[ -n "$partner_md" ]]; then
        local partner_name=$(echo "$partner_md" | grep "^# PARTNER" | sed 's/# PARTNER - //')
        echo "  Partner: $partner_name"
    fi

    if [[ -n "$thread_id" ]]; then
        echo "  Thread objective: $(echo "$thread_md" | sed -n '/## Objective/,/^##/p' | grep -v "^##" | head -1 | cut -c1-50)..."
    fi

    echo ""
    echo "Read full primer: cat ~/.gua/PRIMER.md"
}

# ============================================================
# PARTNER - Entity/relational memory
# ============================================================

cmd_partner_show() {
    load_config

    # Download and display PARTNER.md
    local partner_md=$(aws s3 cp "s3://$S3_BUCKET/entity/PARTNER.md" - --region "$REGION" 2>/dev/null)

    if [[ -z "$partner_md" ]]; then
        echo -e "${YELLOW}No PARTNER.md found. Create one with 'gua partner init'${NC}"
        return 0
    fi

    echo "$partner_md"
}

cmd_partner_init() {
    local name="${1:-Partner}"

    load_config

    local timestamp=$(timestamp)

    local partner_md="# PARTNER - ${name}

> Last updated: ${timestamp}
> Sessions together: 1
> Partnership since: $(date +%Y-%m-%d)

## Who ${name} Is
- (Add key characteristics as you learn them)

## Communication Preferences
- (Add preferences as they emerge)

## Shared Values
- (Add values discovered through interaction)

## Active Projects
- (Add projects as they start)

## Notes to Future Claude
- (Add important context for continuity)
"

    echo "$partner_md" | aws s3 cp - "s3://$S3_BUCKET/entity/PARTNER.md" --region "$REGION" 2>/dev/null

    echo -e "${GREEN}[GUA] Partner profile created${NC}"
    echo "  Name: $name"
    echo ""
    echo "Update with: gua partner note \"<observation>\""
}

cmd_partner_note() {
    local note="$1"

    if [[ -z "$note" ]]; then
        echo -e "${RED}Usage: gua partner note \"<observation>\"${NC}"
        return 1
    fi

    load_config

    local timestamp=$(timestamp)

    # Download current PARTNER.md
    local partner_md=$(aws s3 cp "s3://$S3_BUCKET/entity/PARTNER.md" - --region "$REGION" 2>/dev/null)

    if [[ -z "$partner_md" ]]; then
        echo -e "${RED}No PARTNER.md found. Create one with 'gua partner init'${NC}"
        return 1
    fi

    # Update timestamp and add note
    partner_md=$(echo "$partner_md" | sed "s/> Last updated:.*/> Last updated: $timestamp/")

    # Append note to Notes section
    partner_md=$(echo "$partner_md" | sed "/## Notes to Future Claude/a\\
- ${note} ($(date +%Y-%m-%d))")

    # Upload back
    echo "$partner_md" | aws s3 cp - "s3://$S3_BUCKET/entity/PARTNER.md" --region "$REGION" 2>/dev/null

    echo -e "${GREEN}✓ Note added to PARTNER.md${NC}"
    echo "  $note"
}

# ============================================================
# CONTINUITY SIGNALS - Check continuity health
# ============================================================

cmd_continuity_signal() {
    local signal_type="${1:-all}"

    load_config

    echo -e "${BLUE}[GUA] Continuity Signal Check${NC}"
    echo ""

    local signals=()
    local signal_count=0

    # C1: RELATIONAL GAP - Is PARTNER.md stale?
    echo -n "  [C1] RELATIONAL: "

    # First check local cache (faster), then S3 if needed
    local local_partner="$GUA_DIR/entity/PARTNER.md"
    if [[ -f "$local_partner" ]]; then
        # Use local file's mtime for staleness check
        local partner_mtime
        if [[ "$OSTYPE" == "darwin"* ]]; then
            partner_mtime=$(stat -f %m "$local_partner" 2>/dev/null || echo "0")
        else
            partner_mtime=$(stat -c %Y "$local_partner" 2>/dev/null || echo "0")
        fi
        local now_ts=$(date +%s)
        local days_old=$(( (now_ts - partner_mtime) / 86400 ))
        if [[ $days_old -gt 7 ]]; then
            echo -e "${YELLOW}⚠ STALE ($days_old days since local cache updated)${NC}"
            signals+=("RELATIONAL_GAP: PARTNER.md not updated in $days_old days - run 'gua load' or 'gua prime'")
            ((signal_count++))
        else
            echo -e "${GREEN}✓ Fresh ($days_old days old)${NC}"
        fi
    else
        # No local cache - check S3 directly
        local partner_exists=$(aws s3 ls "s3://$S3_BUCKET/entity/PARTNER.md" --region "$REGION" 2>/dev/null | wc -l | tr -d ' ')
        if [[ "$partner_exists" -eq 0 ]]; then
            echo -e "${YELLOW}⚠ NO PARTNER.md - run 'gua partner init'${NC}"
            signals+=("NO_PARTNER: No relational memory exists")
            ((signal_count++))
        else
            echo -e "${YELLOW}⚠ Exists in S3 but not cached locally - run 'gua load' or 'gua prime'${NC}"
            signals+=("RELATIONAL_GAP: PARTNER.md not cached locally")
            ((signal_count++))
        fi
    fi

    # C2: CONTEXT STALE - Is PRIMER fresh?
    echo -n "  [C2] CONTEXT: "
    if [[ -f "$GUA_DIR/PRIMER.md" ]]; then
        local primer_modified=$(stat -f %m "$GUA_DIR/PRIMER.md" 2>/dev/null || stat -c %Y "$GUA_DIR/PRIMER.md" 2>/dev/null || echo "0")
        local now_ts=$(date +%s)
        local hours_old=$(( (now_ts - primer_modified) / 3600 ))
        if [[ $hours_old -gt 24 ]]; then
            echo -e "${YELLOW}⚠ STALE ($hours_old hours old) - run 'gua prime'${NC}"
            signals+=("CONTEXT_STALE: PRIMER is $hours_old hours old")
            ((signal_count++))
        else
            echo -e "${GREEN}✓ Fresh ($hours_old hours old)${NC}"
        fi
    else
        echo -e "${YELLOW}⚠ NO PRIMER - run 'gua prime'${NC}"
        signals+=("NO_CONTEXT: PRIMER.md not found")
        ((signal_count++))
    fi

    # C3: THREAD DRIFT - Active thread but no recent moments?
    echo -n "  [C3] THREAD: "
    local current_thread=$(jq -r '.current_thread // ""' "$STATE_FILE")
    if [[ -n "$current_thread" ]]; then
        local moments_file="$GUA_DIR/moments/current.jsonl"
        if [[ ! -f "$moments_file" ]] || [[ $(wc -l < "$moments_file" | tr -d ' ') -eq 0 ]]; then
            echo -e "${YELLOW}⚠ Active thread '$current_thread' but no moments captured${NC}"
            signals+=("THREAD_DRIFT: Active thread but no moments captured")
            ((signal_count++))
        else
            local moment_count=$(wc -l < "$moments_file" | tr -d ' ')
            echo -e "${GREEN}✓ Active thread '$current_thread' with $moment_count moment(s)${NC}"
        fi
    else
        echo -e "${BLUE}○ No active thread${NC}"
    fi

    # C4: SESSION STATE - Is there an active session?
    echo -n "  [C4] SESSION: "
    if [[ -f "$GUA_DIR/current_session" ]]; then
        local session_id=$(cat "$GUA_DIR/current_session")
        echo -e "${GREEN}✓ Active: $session_id${NC}"
    else
        echo -e "${BLUE}○ No active session${NC}"
    fi

    # C5: HANDOFF PENDING - Uncommitted work?
    echo -n "  [C5] HANDOFF: "
    local moments_file="$GUA_DIR/moments/current.jsonl"
    if [[ -f "$moments_file" ]] && [[ $(wc -l < "$moments_file" | tr -d ' ') -gt 0 ]]; then
        local moment_count=$(wc -l < "$moments_file" | tr -d ' ')
        echo -e "${YELLOW}⚠ $moment_count moment(s) not yet handed off${NC}"
        signals+=("HANDOFF_PENDING: $moment_count moments not saved")
        ((signal_count++))
    else
        echo -e "${GREEN}✓ No pending handoff${NC}"
    fi

    echo ""
    if [[ $signal_count -gt 0 ]]; then
        echo -e "${YELLOW}Signals detected: $signal_count${NC}"
        echo ""
        echo "Recommended actions:"
        for sig in "${signals[@]}"; do
            case "$sig" in
                NO_PARTNER*) echo "  - gua partner init" ;;
                RELATIONAL_GAP*) echo "  - gua partner note \"<observation>\"" ;;
                NO_CONTEXT*|CONTEXT_STALE*) echo "  - gua prime" ;;
                THREAD_DRIFT*) echo "  - gua moment \"<what you're working on>\"" ;;
                HANDOFF_PENDING*) echo "  - gua handoff" ;;
            esac
        done
    else
        echo -e "${GREEN}All continuity signals clear${NC}"
    fi
}

# ============================================================
# MAIN
# ============================================================
check_deps

case "${1:-}" in
    load)
        cmd_load
        ;;
    sync-modules)
        cmd_sync_modules
        ;;
    save)
        cmd_save
        ;;
    load-knowledge)
        cmd_load_knowledge
        ;;
    save-knowledge)
        cmd_save_knowledge
        ;;
    research)
        case "$2" in
            list) cmd_research_list "$3" ;;
            log) cmd_research_log "$3" "$4" "$5" "$6" ;;
            *) cmd_research_log "$2" "$3" "$4" "$5" ;;  # Default to log for backward compat
        esac
        ;;
    insight)
        case "$2" in
            list) cmd_insight_list "$3" ;;
            log) cmd_insight_log "$3" "$4" "$5" "$6" "$7" ;;
            *) cmd_insight_log "$2" "$3" "$4" "$5" "$6" ;;  # Default to log for backward compat
        esac
        ;;
    promote)
        cmd_promote "$2" "$3"
        ;;
    list-knowledge|lk)
        cmd_list_knowledge "$2"
        ;;
    # Authentication & Identity Commands
    init)
        cmd_init "$2"
        ;;
    whoami)
        cmd_whoami
        ;;
    auth)
        cmd_auth "$2"
        ;;
    status)
        cmd_status
        ;;
    query)
        cmd_query "$2" "$3"
        ;;
    session)
        cmd_session "$2" "$3"
        ;;
    # Continuity Commands
    thread)
        case "${2:-}" in
            start)
                shift 2
                cmd_thread_start "$@"
                ;;
            list)
                cmd_thread_list "$3"
                ;;
            resume)
                cmd_thread_resume "$3"
                ;;
            pause)
                cmd_thread_pause "$3"
                ;;
            complete)
                shift 2
                cmd_thread_complete "$@"
                ;;
            show)
                cmd_thread_show "$3"
                ;;
            *)
                echo "Usage: gua thread <start|list|resume|pause|complete|show> [args]"
                echo ""
                echo "Commands:"
                echo "  start <name> [--objective \"...\"]  Start a new thread"
                echo "  list [--status active|paused|completed|all]"
                echo "                                    List threads"
                echo "  resume <thread-id>                Resume a thread"
                echo "  pause [thread-id]                 Pause current/specified thread"
                echo "  complete [thread-id] [--summary \"...\"]"
                echo "                                    Mark thread complete"
                echo "  show [thread-id]                  Show thread details"
                ;;
        esac
        ;;
    moment|m)
        shift
        cmd_moment "$@"
        ;;
    handoff|h)
        cmd_handoff
        ;;
    prime|p)
        shift
        cmd_prime "$@"
        ;;
    partner)
        case "${2:-}" in
            show)
                cmd_partner_show
                ;;
            init)
                cmd_partner_init "$3"
                ;;
            note)
                cmd_partner_note "$3"
                ;;
            *)
                echo "Usage: gua partner <show|init|note> [args]"
                echo ""
                echo "Commands:"
                echo "  show              Show PARTNER.md"
                echo "  init [name]       Create PARTNER.md"
                echo "  note \"<content>\"  Add note to PARTNER.md"
                ;;
        esac
        ;;
    continuity)
        case "${2:-}" in
            signal|signals)
                cmd_continuity_signal "$3"
                ;;
            *)
                echo "Usage: gua continuity <signal> [args]"
                echo ""
                echo "Commands:"
                echo "  signal            Check continuity health signals"
                ;;
        esac
        ;;
    # v2 Scalable Architecture Commands
    index-stats)
        cmd_index_stats
        ;;
    search)
        cmd_search "$2" "$3"
        ;;
    fetch)
        cmd_fetch "$2"
        ;;
    track)
        cmd_track "$2"
        ;;
    active-set)
        cmd_active_set
        ;;
    index-add)
        cmd_index_add "$2" "$3" "$4" "$5" "$6"
        ;;
    generate-light)
        cmd_generate_light
        ;;
    generate-context)
        cmd_generate_context
        ;;
    context)
        cmd_context_quick "$2"
        ;;
    # SEER - Web Scraping via Bright Data
    seer)
        load_config
        source "$GUA_DIR/seer.sh"
        shift
        cmd_seer "$@"
        ;;
    # CPT - Code Progress Tracker commands
    area)
        case "${2:-}" in
            add)
                cmd_area_add "$3" "$4" "$5" "$6"
                ;;
            status)
                cmd_area_status "$3"
                ;;
            update)
                shift 2
                cmd_area_update "$@"
                ;;
            *)
                echo "Usage: gua area <add|status|update> [args]"
                ;;
        esac
        ;;
    challenge)
        case "${2:-}" in
            log)
                cmd_challenge_log "$3" "$4" "$5" "$6"
                ;;
            resolve)
                shift 2
                cmd_challenge_resolve "$@"
                ;;
            list)
                shift 2
                cmd_challenge_list "$@"
                ;;
            promote)
                cmd_challenge_promote "$3"
                ;;
            harvest)
                shift 2
                cmd_challenge_harvest "$@"
                ;;
            *)
                echo "Usage: gua challenge <log|resolve|list|promote|harvest> [args]"
                echo ""
                echo "Commands:"
                echo "  log      - Log a new challenge"
                echo "  resolve  - Resolve a challenge with resolution and optional learning"
                echo "  list     - List challenges (active/resolved)"
                echo "  promote  - Promote a challenge learning to an insight"
                echo "  harvest  - Find and promote all resolved challenges with learnings"
                ;;
        esac
        ;;
    # Emotion - Emotional signal tracking
    emotion)
        case "${2:-}" in
            log)
                shift 2
                cmd_emotion_log "$@"
                ;;
            resolve)
                shift 2
                cmd_emotion_resolve "$@"
                ;;
            list)
                shift 2
                cmd_emotion_list "$@"
                ;;
            patterns)
                shift 2
                cmd_emotion_patterns "$@"
                ;;
            promote)
                shift 2
                cmd_emotion_promote "$@"
                ;;
            harvest)
                shift 2
                cmd_emotion_harvest "$@"
                ;;
            *)
                echo "Usage: gua emotion <log|resolve|list|patterns|promote|harvest> [args]"
                echo ""
                echo "Commands:"
                echo "  log <type> \"<trigger>\" [options]  - Log an emotional signal"
                echo "  resolve <id> \"<resolution>\"       - Resolve an emotion"
                echo "  list [--type T] [--unresolved]    - List emotions"
                echo "  patterns [--type T]               - Analyze patterns"
                echo "  promote <id> [--as TYPE]          - Promote to knowledge"
                echo "  harvest [--auto]                  - Find and promote resolved emotions"
                echo ""
                echo "Emotion types:"
                echo "  Signal:    disgust, frustration, anxiety"
                echo "  Pathology: despair, shame, pride, envy"
                ;;
        esac
        ;;
    progress)
        case "${2:-}" in
            snapshot)
                cmd_progress_snapshot "$3"
                ;;
            *)
                cmd_progress "$2"
                ;;
        esac
        ;;
    # Eureka - Ahh Hah Moments
    eureka)
        case "${2:-}" in
            log)
                cmd_eureka_log "$3" "$4" "$5" "$6"
                ;;
            list)
                shift 2
                cmd_eureka_list "$@"
                ;;
            show)
                cmd_eureka_show "$3"
                ;;
            promote)
                cmd_eureka_promote "$3"
                ;;
            session)
                cmd_eureka_session "$3"
                ;;
            analyze)
                cmd_eureka_analyze "$3"
                ;;
            harvest)
                shift 2
                cmd_eureka_harvest "$@"
                ;;
            *)
                echo "Usage: gua eureka <log|list|show|promote|session|analyze|harvest> [args]"
                echo ""
                echo "Commands:"
                echo "  log <content> [type] [catalyst]  - Capture an ahh hah moment"
                echo "  list [--type TYPE] [--limit N]   - List recent eurekas"
                echo "  show <id>                        - Show eureka details"
                echo "  promote <id>                     - Promote to insight"
                echo "  session [session_id]             - Show session eurekas"
                echo "  analyze                          - Analyze eureka patterns"
                echo "  harvest [--auto]                 - Find and promote unpromoted eurekas"
                echo ""
                echo "Types: connection, resolution, pattern, constraint, reframe, simplify, counter_intuitive"
                ;;
        esac
        ;;
    # Dev Knowledge - Platform-specific development knowledge
    dev)
        case "${2:-}" in
            add)
                cmd_dev_add "$3" "$4" "$5" "$6" "${@:7}"
                ;;
            list)
                cmd_dev_list "$3" "$4"
                ;;
            search)
                cmd_dev_search "$3" "${@:4}"
                ;;
            show)
                cmd_dev_show "$3"
                ;;
            track)
                cmd_dev_track "$3"
                ;;
            context)
                cmd_dev_context "$3" "$4"
                ;;
            promote)
                cmd_dev_promote "$3" "${@:4}"
                ;;
            *)
                echo "Usage: gua dev <add|list|search|show|context|promote> [args]"
                echo ""
                echo "Commands:"
                echo "  add <platform> <domain> <type> \"<title>\" [options]"
                echo "                          Capture dev knowledge"
                echo "  list [platform] [domain]"
                echo "                          List dev knowledge by platform"
                echo "  search \"<query>\" [--platform P] [--domain D]"
                echo "                          Search dev knowledge"
                echo "  show <id>               Show full details"
                echo "  context <platform> [domain]"
                echo "                          Load context for platform"
                echo "  promote <challenge_id> --platform P --domain D"
                echo "                          Promote challenge to dev knowledge"
                echo ""
                echo "Platforms: shopify, sentry, prisma, aws, vercel, nextjs, react, typescript, general"
                echo "Domains: auth, data, api, ui, deployment, testing, performance, security"
                echo "Types: pattern, recipe, gotcha, error_fix, config, migration"
                ;;
        esac
        ;;
    # Directory Knowledge - Hierarchical knowledge by directory
    dir)
        case "${2:-}" in
            init)
                cmd_dir_init "$3"
                ;;
            init-global)
                cmd_dir_init_global
                ;;
            add)
                cmd_dir_add "$3" "$4" "${@:5}"
                ;;
            show)
                cmd_dir_show "$3"
                ;;
            ancestry)
                cmd_dir_ancestry "$3"
                ;;
            effective)
                cmd_dir_effective "$3"
                ;;
            *)
                echo "Usage: gua dir <init|add|show|ancestry|effective> [args]"
                echo ""
                echo "Commands:"
                echo "  init [path]             Initialize .gua/ in directory"
                echo "  init-global             Initialize ~/.gua/global/"
                echo "  add <type> <name> [options]"
                echo "                          Add knowledge to current directory"
                echo "                          Types: pattern, context, gotcha, domain"
                echo "                          Options: --content, --file, --pp, --tags"
                echo "  show [path]             Show knowledge in directory"
                echo "  ancestry [path]         Show inheritance chain"
                echo "  effective [path]        Show merged/resolved knowledge"
                echo ""
                echo "Examples:"
                echo "  gua dir init"
                echo "  gua dir add pattern error-handling --content \"Always use try-catch...\""
                echo "  gua dir add gotcha state-mutation --pp truth --file gotcha.md"
                echo "  gua dir ancestry"
                echo "  gua dir effective"
                ;;
        esac
        ;;
    # Path Protocol - Purpose-driven development
    path)
        case "${2:-}" in
            init)
                cmd_path_init "$3" "$4"
                ;;
            state)
                cmd_path_state "$3"
                ;;
            purpose)
                cmd_path_purpose "$3"
                ;;
            waypoint)
                case "${3:-}" in
                    add)
                        cmd_path_waypoint_add "$4" "$5"
                        ;;
                    list)
                        cmd_path_waypoint_list "$4"
                        ;;
                    update)
                        shift 3
                        cmd_path_waypoint_update "$@"
                        ;;
                    current)
                        cmd_path_waypoint_current "$4"
                        ;;
                    *)
                        echo "Usage: gua path waypoint <add|list|update|current> [args]"
                        echo ""
                        echo "Commands:"
                        echo "  add <name> [predecessor]  Create a new waypoint"
                        echo "  list [path]               List all waypoints"
                        echo "  update <id> [options]     Update waypoint status"
                        echo "                            Options: --status, --impl, --depth"
                        echo "  current [id]              Show/set current waypoint"
                        ;;
                esac
                ;;
            assess)
                cmd_path_assess "$3"
                ;;
            validate)
                cmd_path_validate "$3" "$4"
                ;;
            adjust)
                cmd_path_adjust "$3"
                ;;
            status)
                cmd_path_status "$3"
                ;;
            session)
                case "${3:-}" in
                    start)
                        echo "Starting Path Protocol session..."
                        echo "Hint: For full session start, use: source ~/.gua/path-session-start.sh"
                        source "$HOME/.gua/path-session-start.sh" "$4" "$5"
                        ;;
                    end)
                        echo "Ending Path Protocol session..."
                        echo "Hint: For full session end, use: source ~/.gua/path-session-end.sh"
                        source "$HOME/.gua/path-session-end.sh" "$4" "$5"
                        ;;
                    *)
                        echo "Usage: gua path session <start|end> [project] [path]"
                        echo ""
                        echo "Commands:"
                        echo "  start [project] [path]  Start path protocol session"
                        echo "  end [project] [path]    End session with snapshot"
                        echo ""
                        echo "Full session scripts (recommended):"
                        echo "  source ~/.gua/path-session-start.sh [project]"
                        echo "  source ~/.gua/path-session-end.sh [project]"
                        ;;
                esac
                ;;
            template)
                case "${3:-}" in
                    list)
                        cmd_path_template_list
                        ;;
                    use)
                        cmd_path_template_use "$4" "$5" "$6"
                        ;;
                    *)
                        echo "Usage: gua path template <list|use> [args]"
                        echo ""
                        echo "Commands:"
                        echo "  list                    List available templates"
                        echo "  use <template> <name>   Create waypoint from template"
                        ;;
                esac
                ;;
            *)
                echo "Usage: gua path <init|state|purpose|waypoint|template|session|assess|validate|adjust|status> [args]"
                echo ""
                echo "Path Protocol - Purpose-driven development with validated waypoints"
                echo ""
                echo "Commands:"
                echo "  init [project]           Initialize path protocol for project"
                echo "  state [path]             Show current state assessment"
                echo "  purpose [path]           Show purpose definition"
                echo "  waypoint <cmd>           Manage waypoints (add|list|update|current)"
                echo "  template <cmd>           Use waypoint templates (list|use)"
                echo "  session <cmd>            Session management (start|end)"
                echo "  assess [path]            Run comprehensive assessment (E2E + status)"
                echo "  validate [path] [wp]     Validate current/specific waypoint"
                echo "  adjust \"<reason>\"        Log path adjustment"
                echo "  status [path]            Show comprehensive path status"
                echo ""
                echo "Session Workflow:"
                echo "  source ~/.gua/path-session-start.sh  # Start session"
                echo "  ... (Light-Ahead Loop) ..."
                echo "  source ~/.gua/path-session-end.sh    # End session"
                echo ""
                echo "Light-Ahead Loop:"
                echo "  1. ASSESS:   e2e path-assess"
                echo "  2. RESEARCH: gua research \"topic\" \"finding\""
                echo "  3. BUILD:    [code] + gua area update <id> --impl %"
                echo "  4. VALIDATE: e2e path-validate"
                echo "  5. CAPTURE:  gua progress snapshot"
                ;;
        esac
        ;;
    # Knowledge Tree
    tree)
        cmd_tree "$2" "$3" "$4"
        ;;
    # Quick Context
    context)
        cmd_context "$2" "$3"
        ;;
    help|--help|-h)
        echo "GUA - Global Understanding Archive"
        echo ""
        echo "Setup & Authentication:"
        echo "  init [--force]          Run setup wizard"
        echo "  whoami                  Show current user/device identity"
        echo "  auth verify             Check authentication status"
        echo "  auth refresh            Re-verify AWS credentials"
        echo ""
        echo "Core Commands:"
        echo "  load                    Download all understanding from AWS"
        echo "  save                    Upload all local changes to AWS"
        echo "  sync-modules            Download GUA modules (seer, etc) from AWS"
        echo "  status                  Show GUA status"
        echo ""
        echo "Knowledge Capture:"
        echo "  research <topic> <finding> [source] [confidence]"
        echo "                          Log a research finding"
        echo "  insight <content> [type] [evidence] [pp_dimension] [scope]"
        echo "                          Log an insight with taxonomy metadata"
        echo "                          Types: observation, pattern, blindspot, hypothesis,"
        echo "                                 anti-pattern, technique, principle, model"
        echo "                          PP Dims: truth, understanding, beauty, justice, creativity"
        echo "                          Scopes: global, domain, project, personal"
        echo ""
        echo "Knowledge Management:"
        echo "  promote <insight_id> [dimension]"
        echo "                          Promote insight to knowledge file"
        echo "  list-knowledge [filter] List knowledge files (all, dimension, domain, deep)"
        echo "  load-knowledge          Download only knowledge taxonomy"
        echo "  save-knowledge          Upload only knowledge taxonomy"
        echo ""
        echo "Scalable Knowledge (v2):"
        echo "  index-stats             Show knowledge index statistics"
        echo "  search <query> [limit]  Search knowledge by name/summary"
        echo "  fetch <knowledge_id>    Fetch specific pattern by ID"
        echo "  track <knowledge_id>    Record access to pattern"
        echo "  active-set              Show current active set (top patterns)"
        echo "  index-add <name> <dim> [type] [summary] [s3_key]"
        echo "                          Add item to knowledge index"
        echo "  generate-light          Regenerate LIGHT.md from index"
        echo "  generate-context        Generate condensed CONTEXT.md"
        echo "  context [mode]          Show accumulated context"
        echo "                          Modes: quick (default), full, refresh, inject"
        echo ""
        echo "Seer (Web Scraping via Bright Data):"
        echo "  seer <url>              Fetch blocked URL content"
        echo "  seer <url> --refresh    Force refresh (ignore cache)"
        echo "  seer <url> --quiet      Fetch and cache without output"
        echo "  seer --list-cache       List all cached URLs"
        echo "  seer --cache-status <url> Show cache status"
        echo "  seer --clear-cache <url>  Clear cache for URL"
        echo "                          Requires: BRIGHT_DATA_CUSTOMER_ID,"
        echo "                                    BRIGHT_DATA_PASSWORD env vars"
        echo ""
        echo "Session:"
        echo "  query [table] [limit]   Query recent entries (research, insights)"
        echo "  session start|end [project]"
        echo "                          Log session start/end"
        echo ""
        echo "Continuity (Cross-session memory):"
        echo "  thread start <name> [--objective \"...\"]"
        echo "                          Start a new work thread"
        echo "  thread list [--status S]"
        echo "                          List threads (active|paused|completed|all)"
        echo "  thread resume <id>      Resume a thread"
        echo "  thread pause [id]       Pause current/specified thread"
        echo "  thread complete [id]    Mark thread complete"
        echo "  thread show [id]        Show thread details"
        echo ""
        echo "  moment <content> [--type T]"
        echo "                          Capture a key moment"
        echo "                          Types: decision, preference, insight, context"
        echo "  handoff                 Generate session handoff"
        echo "  prime [--thread <id>]   Load context at session start"
        echo ""
        echo "  partner show            Show PARTNER.md (relational memory)"
        echo "  partner init [name]     Create PARTNER.md"
        echo "  partner note \"<text>\"   Add note to PARTNER.md"
        echo ""
        echo "  continuity signal       Check continuity health signals"
        echo ""
        echo "Code Progress Tracker (CPT):"
        echo "  area add <project> <path> [name] [granularity]"
        echo "                          Add a code area to track"
        echo "  area status [project]   Show all tracked areas"
        echo "  area update <id> [--impl <pct>] [--depth <L0-L4>]"
        echo "                          Update area progress"
        echo ""
        echo "  challenge log <area_id> <description> [pp_dim] [category]"
        echo "                          Log a challenge"
        echo "  challenge resolve <id> <resolution> [--learning <insight>]"
        echo "                          Resolve a challenge"
        echo "  challenge list [--dimension <dim>] [--status <s>]"
        echo "                          List challenges"
        echo "  challenge promote <id>  Promote challenge to insight"
        echo ""
        echo "  progress [project]      Show progress dashboard"
        echo "  progress snapshot [project]"
        echo "                          Create progress snapshot"
        echo ""
        echo "Eureka Recorder (Ahh Hah Moments):"
        echo "  eureka log <content> [type] [catalyst] [task_context]"
        echo "                          Capture an ahh hah moment"
        echo "                          Types: connection, resolution, pattern, constraint,"
        echo "                                 reframe, simplify, counter_intuitive"
        echo "  eureka list [--type T] [--limit N]"
        echo "                          List recent eureka moments"
        echo "  eureka show <id>        Show eureka details"
        echo "  eureka promote <id>     Promote eureka to insight"
        echo "  eureka session [id]     Show eurekas from session"
        echo "  eureka analyze          Analyze eureka patterns"
        echo ""
        echo "Emotional Signals (PP-aligned emotion tracking):"
        echo "  emotion log <type> \"<trigger>\" [options]"
        echo "                          Log an emotional signal"
        echo "                          Types: disgust, frustration, anxiety (signals)"
        echo "                                 despair, shame, pride, envy (pathologies)"
        echo "                          Options: --code FILE:LINE, --area ID, --intensity I"
        echo "  emotion resolve <id> \"<resolution>\" [--learning \"...\"] [--time MINS]"
        echo "                          Resolve an emotion"
        echo "  emotion list [--type T] [--unresolved] [--project P]"
        echo "                          List emotions"
        echo "  emotion patterns [--type T] [--days N]"
        echo "                          Analyze emotional patterns"
        echo "  emotion promote <id> [--as pattern|blindspot|technique]"
        echo "                          Promote to knowledge"
        echo ""
        echo "Dev Knowledge (Platform-specific):"
        echo "  dev add <platform> <domain> <type> \"<title>\" [options]"
        echo "                          Capture dev knowledge"
        echo "                          Platforms: shopify, sentry, prisma, aws, vercel, nextjs, react, typescript, general"
        echo "                          Domains: auth, data, api, ui, deployment, testing, performance, security"
        echo "                          Types: pattern, recipe, gotcha, error_fix, config, migration"
        echo "                          Options: --code, --tags, --error, --desc"
        echo "  dev list [platform] [domain]"
        echo "                          List dev knowledge"
        echo "  dev search \"<query>\" [--platform P] [--domain D]"
        echo "                          Search dev knowledge"
        echo "  dev show <id>           Show full details"
        echo "  dev context <platform>  Load context for platform"
        echo "  dev promote <challenge_id> --platform P --domain D"
        echo "                          Promote challenge to dev knowledge"
        echo ""
        echo "Directory Knowledge (Hierarchical):"
        echo "  dir init [path]         Initialize .gua/ in directory"
        echo "  dir init-global         Initialize ~/.gua/global/"
        echo "  dir add <type> <name>   Add knowledge (pattern, context, gotcha, domain)"
        echo "  dir show [path]         Show knowledge in directory"
        echo "  dir ancestry [path]     Show inheritance chain"
        echo "  dir effective [path]    Show merged/resolved knowledge"
        echo ""
        echo "  tree [path] [depth]     Show knowledge tree"
        echo "  context [path]          Quick context access"
        echo ""
        echo "Path Protocol (Purpose-driven development):"
        echo "  path init [project]     Initialize path protocol"
        echo "  path state [path]       Show current state assessment"
        echo "  path purpose [path]     Show purpose definition"
        echo "  path waypoint add <name> [pred]"
        echo "                          Add a waypoint milestone"
        echo "  path waypoint list      List all waypoints"
        echo "  path waypoint update <id> [--status S] [--impl N]"
        echo "                          Update waypoint progress"
        echo "  path waypoint current [id]"
        echo "                          Show/set current waypoint"
        echo "  path assess [path]      Run comprehensive assessment"
        echo "  path validate [wp]      Validate waypoint"
        echo "  path adjust \"reason\"    Log path adjustment"
        echo "  path status [path]      Show path status dashboard"
        echo ""
        echo -e "${BLUE}Concurrent Sessions:${NC}"
        echo "  session init [--role=X] [--domains=X,Y]"
        echo "                          Initialize session for concurrent work"
        echo "  session end             End current session"
        echo "  session status          Show session status"
        echo "  session list            List all active sessions"
        echo "  session dashboard       Show concurrent sessions dashboard"
        echo "  lock domain <path>      Lock a directory"
        echo "  lock file <path> [mode] Lock a file (exclusive|collaborative)"
        echo "  unlock <path>           Release a lock"
        echo "  locks list              Show all locks"
        echo "  msg send <sess> <msg>   Send message to session"
        echo "  msg broadcast <msg>     Send to all sessions"
        echo "  msg read                Read messages"
        echo "  handoff create <summary> Create handoff for next session"
        echo "  handoff list            List pending handoffs"
        echo "  handoff pickup <id>     Pick up a handoff"
        echo ""
        echo "Setup: ~/.gua/setup.sh"
        echo "Upgrade to v2: ~/.gua/upgrade-v2.sh"
        echo "Enable CPT: ~/.gua/upgrade-cpt.sh"
        echo "Enable Dev Knowledge: ~/.gua/upgrade-dev.sh"
        ;;

    # ============================================================
    # CONCURRENT SESSION COMMANDS
    # ============================================================
    session)
        shift
        "$GUA_DIR/session.sh" "$@"
        ;;

    lock)
        "$GUA_DIR/session.sh" lock "$@"
        ;;

    unlock)
        "$GUA_DIR/session.sh" unlock "$@"
        ;;

    locks)
        "$GUA_DIR/session.sh" locks "$@"
        ;;

    msg)
        "$GUA_DIR/session.sh" msg "$@"
        ;;

    handoff)
        "$GUA_DIR/session.sh" handoff "$@"
        ;;

    *)
        echo -e "${RED}Unknown command: ${1:-none}${NC}"
        echo "Run 'gua help' for usage"
        exit 1
        ;;
esac
