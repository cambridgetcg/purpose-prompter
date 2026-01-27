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

    # Add blindspots
    echo "$blindspots" | jq -r '.[] | "### \(.name.S)\n- **Dimension**: \(.pp_dimension.S)\n- **Summary**: \(.summary.S // "No summary")\n"' >> "$LOCAL_INTEGRATION/LIGHT.md" 2>/dev/null || true

    cat >> "$LOCAL_INTEGRATION/LIGHT.md" << EOF

---

## Top Patterns (by access frequency)

EOF

    # Add patterns
    echo "$patterns" | jq -r '.[] | "### \(.name.S)\n- **Dimension**: \(.pp_dimension.S)\n- **Access Count**: \(.access_count.N // "0")\n- **Summary**: \(.summary.S // "No summary")\n"' >> "$LOCAL_INTEGRATION/LIGHT.md" 2>/dev/null || true

    cat >> "$LOCAL_INTEGRATION/LIGHT.md" << EOF

---

## Quick Commands

- \`/gua-context dimension:X\` - Load all patterns for dimension
- \`/gua-context search:query\` - Search all knowledge
- \`gua fetch <id>\` - Load specific pattern details

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
cmd_research() {
    local topic="$1"
    local finding="$2"
    local source="${3:-manual}"
    local confidence="${4:-medium}"

    if [[ -z "$topic" || -z "$finding" ]]; then
        echo -e "${RED}Usage: gua research <topic> <finding> [source] [confidence]${NC}"
        echo "Example: gua research 'vector databases' 'ChromaDB is free under 10M vectors' 'docs' 'high'"
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
cmd_insight() {
    local content="$1"
    local type="${2:-observation}"
    local evidence="${3:-}"
    local pp_dimension="${4:-understanding}"
    local scope="${5:-global}"

    if [[ -z "$content" ]]; then
        echo -e "${RED}Usage: gua insight <content> [type] [evidence] [pp_dimension] [scope]${NC}"
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

    elif [[ "$action" == "end" ]]; then
        # Get current session
        if [[ -f "$GUA_DIR/current_session" ]]; then
            session_id=$(cat "$GUA_DIR/current_session")

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

    # Generate LIGHT.md
    cat > "$LOCAL_INTEGRATION/LIGHT.md" << EOF
# LIGHT - Current Understanding

> **Last synthesized**: $(date -u +"%Y-%m-%d")
> **Total patterns**: $((confirmed_count + emerging_count))
> **Active blindspots**: $blindspot_count
> **Architecture**: v2 (Indexed Active Set)

---

## Active Blindspots

EOF

    # Add blindspots grouped by dimension
    for dim in truth understanding beauty justice creativity; do
        local dim_blindspots=$(echo "$blindspots" | jq -r ".Items[] | select(.pp_dimension.S == \"$dim\")")
        if [[ -n "$dim_blindspots" ]]; then
            echo "### $dim" >> "$LOCAL_INTEGRATION/LIGHT.md"
            echo "$blindspots" | jq -r ".Items[] | select(.pp_dimension.S == \"$dim\") | \"- **\(.name.S)**: \(.summary.S // \"No summary\")\"" >> "$LOCAL_INTEGRATION/LIGHT.md"
            echo "" >> "$LOCAL_INTEGRATION/LIGHT.md"
        fi
    done

    cat >> "$LOCAL_INTEGRATION/LIGHT.md" << EOF

---

## Confirmed Patterns (HIGH confidence)

EOF

    # Add confirmed patterns grouped by dimension
    for dim in truth understanding beauty justice creativity; do
        local dim_patterns=$(echo "$confirmed" | jq -r ".Items[] | select(.pp_dimension.S == \"$dim\")")
        if [[ -n "$dim_patterns" && $(echo "$confirmed" | jq "[.Items[] | select(.pp_dimension.S == \"$dim\")] | length") != "0" ]]; then
            echo "### $dim" >> "$LOCAL_INTEGRATION/LIGHT.md"
            echo "$confirmed" | jq -r ".Items[] | select(.pp_dimension.S == \"$dim\") | \"#### \(.name.S)\n- **Type**: \(.knowledge_type.S)\n- **Summary**: \(.summary.S // \"No summary\")\n- **Access**: \(.access_count.N // \"0\") times\n\"" >> "$LOCAL_INTEGRATION/LIGHT.md"
        fi
    done

    cat >> "$LOCAL_INTEGRATION/LIGHT.md" << EOF

---

## Emerging Patterns (MEDIUM confidence)

EOF

    # Add emerging patterns
    echo "$emerging" | jq -r '.Items[] | "### \(.name.S)\n- **Dimension**: \(.pp_dimension.S)\n- **Type**: \(.knowledge_type.S)\n- **Summary**: \(.summary.S // "No summary")\n"' >> "$LOCAL_INTEGRATION/LIGHT.md"

    cat >> "$LOCAL_INTEGRATION/LIGHT.md" << EOF

---

## Quick Reference

| Stat | Count |
|------|-------|
| Confirmed patterns | $confirmed_count |
| Emerging patterns | $emerging_count |
| Active blindspots | $blindspot_count |
| Total indexed | $((confirmed_count + emerging_count + blindspot_count)) |

---

*Generated by GUA v2. Use \`gua search <query>\` to find specific patterns.*
EOF

    # Upload to S3
    aws s3 cp "$LOCAL_INTEGRATION/LIGHT.md" "s3://$S3_BUCKET/documents/LIGHT.md" --region "$REGION"

    echo -e "${GREEN}[GUA] LIGHT.md regenerated ($confirmed_count confirmed, $emerging_count emerging, $blindspot_count blindspots)${NC}"
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

    cmd_insight "$content" "pattern" "CPT challenge resolution" "$pp_dimension" "global"

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

    echo "Quick Actions:"
    echo "  gua area status              # List all areas"
    echo "  gua challenge list           # List active challenges"
    echo "  gua area update <id> --impl X --depth LY"
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
}

# ============================================================
# MAIN
# ============================================================
check_deps

case "${1:-}" in
    load)
        cmd_load
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
        cmd_research "$2" "$3" "$4" "$5"
        ;;
    insight)
        cmd_insight "$2" "$3" "$4" "$5" "$6"
        ;;
    promote)
        cmd_promote "$2" "$3"
        ;;
    list-knowledge|lk)
        cmd_list_knowledge "$2"
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
            *)
                echo "Usage: gua challenge <log|resolve|list|promote> [args]"
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
    help|--help|-h)
        echo "GUA - Global Understanding Archive"
        echo ""
        echo "Core Commands:"
        echo "  load                    Download all understanding from AWS"
        echo "  save                    Upload all local changes to AWS"
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
        echo ""
        echo "Session:"
        echo "  query [table] [limit]   Query recent entries (research, insights)"
        echo "  session start|end [project]"
        echo "                          Log session start/end"
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
        echo "Setup: ~/.gua/setup.sh"
        echo "Upgrade to v2: ~/.gua/upgrade-v2.sh"
        echo "Enable CPT: ~/.gua/upgrade-cpt.sh"
        ;;
    *)
        echo -e "${RED}Unknown command: ${1:-none}${NC}"
        echo "Run 'gua help' for usage"
        exit 1
        ;;
esac
