#!/bin/bash
# GUA Upgrade Script v2 - Adds scalable index architecture
# Usage: ./upgrade-v2.sh
#
# This script upgrades GUA to the scalable "Indexed Active Set" architecture:
# 1. Creates gua-knowledge-index DynamoDB table with GSIs
# 2. Migrates existing patterns to file-per-pattern structure
# 3. Populates the index from existing knowledge files

set -e

GUA_DIR="$HOME/.gua"
CONFIG_FILE="$GUA_DIR/config.json"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================"
echo "  GUA Upgrade to v2 (Scalable Architecture)"
echo -e "========================================${NC}"
echo ""

# Check config exists
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo -e "${RED}ERROR: GUA not configured. Run setup.sh first.${NC}"
    exit 1
fi

# Load config
USER_ID=$(jq -r '.user_id' "$CONFIG_FILE")
REGION=$(jq -r '.region' "$CONFIG_FILE")
S3_BUCKET=$(jq -r '.s3_bucket' "$CONFIG_FILE")

echo "User ID: $USER_ID"
echo "Region:  $REGION"
echo "Bucket:  $S3_BUCKET"
echo ""

# ============================================================
# Step 1: Create Knowledge Index Table with GSIs
# ============================================================
echo -e "${BLUE}[1/5] Creating Knowledge Index table...${NC}"

TABLE_NAME="gua-knowledge-index"

if aws dynamodb describe-table --table-name "$TABLE_NAME" --region "$REGION" &>/dev/null; then
    echo -e "  ${YELLOW}Table already exists${NC}"
else
    aws dynamodb create-table \
        --table-name "$TABLE_NAME" \
        --attribute-definitions \
            AttributeName=user_id,AttributeType=S \
            AttributeName=knowledge_id,AttributeType=S \
            AttributeName=pp_dimension,AttributeType=S \
            AttributeName=confidence,AttributeType=S \
            AttributeName=knowledge_type,AttributeType=S \
            AttributeName=scope,AttributeType=S \
            AttributeName=access_score,AttributeType=N \
        --key-schema \
            AttributeName=user_id,KeyType=HASH \
            AttributeName=knowledge_id,KeyType=RANGE \
        --global-secondary-indexes \
            "[
                {
                    \"IndexName\": \"dimension-confidence-index\",
                    \"KeySchema\": [
                        {\"AttributeName\": \"pp_dimension\", \"KeyType\": \"HASH\"},
                        {\"AttributeName\": \"confidence\", \"KeyType\": \"RANGE\"}
                    ],
                    \"Projection\": {\"ProjectionType\": \"ALL\"}
                },
                {
                    \"IndexName\": \"type-scope-index\",
                    \"KeySchema\": [
                        {\"AttributeName\": \"knowledge_type\", \"KeyType\": \"HASH\"},
                        {\"AttributeName\": \"scope\", \"KeyType\": \"RANGE\"}
                    ],
                    \"Projection\": {\"ProjectionType\": \"ALL\"}
                },
                {
                    \"IndexName\": \"access-score-index\",
                    \"KeySchema\": [
                        {\"AttributeName\": \"user_id\", \"KeyType\": \"HASH\"},
                        {\"AttributeName\": \"access_score\", \"KeyType\": \"RANGE\"}
                    ],
                    \"Projection\": {\"ProjectionType\": \"ALL\"}
                }
            ]" \
        --billing-mode PAY_PER_REQUEST \
        --region "$REGION" > /dev/null

    echo -e "  ${GREEN}Table created with GSIs${NC}"

    # Wait for table to be active
    echo "  Waiting for table to be active..."
    aws dynamodb wait table-exists --table-name "$TABLE_NAME" --region "$REGION"
    echo -e "  ${GREEN}Table ready${NC}"
fi

# ============================================================
# Step 2: Create file-per-pattern directory structure
# ============================================================
echo ""
echo -e "${BLUE}[2/5] Creating file-per-pattern structure...${NC}"

KNOWLEDGE_DIR="$HOME/.claude/purpose_prompter/knowledge"

# Create new structure directories
for dim in truth understanding beauty justice creativity; do
    mkdir -p "$KNOWLEDGE_DIR/patterns/$dim"
    mkdir -p "$KNOWLEDGE_DIR/blindspots/$dim"
done

for domain in aws claude-code typescript react python general; do
    mkdir -p "$KNOWLEDGE_DIR/domains/$domain"
done

mkdir -p "$KNOWLEDGE_DIR/deep"

echo -e "  ${GREEN}Directory structure created${NC}"

# ============================================================
# Step 3: Migrate existing patterns to file-per-pattern
# ============================================================
echo ""
echo -e "${BLUE}[3/5] Migrating existing patterns...${NC}"

migrate_patterns_file() {
    local source_file="$1"
    local target_dir="$2"
    local dimension="$3"
    local knowledge_type="$4"

    if [[ ! -f "$source_file" ]]; then
        return
    fi

    echo "  Processing: $source_file"

    # Parse the markdown file and extract individual patterns
    local current_pattern=""
    local current_content=""
    local in_pattern=false
    local pattern_count=0

    while IFS= read -r line || [[ -n "$line" ]]; do
        # Check for pattern header (## Pattern Name or ## Name)
        if [[ "$line" =~ ^##[[:space:]](.+)$ ]]; then
            # Save previous pattern if exists
            if [[ -n "$current_pattern" && -n "$current_content" ]]; then
                local filename=$(echo "$current_pattern" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')
                local target_file="$target_dir/${filename}.md"

                # Write pattern to individual file
                cat > "$target_file" << EOF
# $current_pattern

- **Dimension**: $dimension
- **Type**: $knowledge_type
- **Confidence**: emerging
- **Access Count**: 0
- **Last Accessed**: never

---

$current_content
EOF
                ((pattern_count++))

                # Index in DynamoDB
                local knowledge_id="${knowledge_type}-${filename}"
                local summary=$(echo "$current_content" | head -5 | tr '\n' ' ' | cut -c1-200)

                aws dynamodb put-item \
                    --table-name "gua-knowledge-index" \
                    --item "{
                        \"user_id\": {\"S\": \"$USER_ID\"},
                        \"knowledge_id\": {\"S\": \"$knowledge_id\"},
                        \"name\": {\"S\": \"$current_pattern\"},
                        \"pp_dimension\": {\"S\": \"$dimension\"},
                        \"knowledge_type\": {\"S\": \"$knowledge_type\"},
                        \"confidence\": {\"S\": \"emerging\"},
                        \"scope\": {\"S\": \"global\"},
                        \"depth_level\": {\"N\": \"2\"},
                        \"access_count\": {\"N\": \"0\"},
                        \"access_score\": {\"N\": \"0\"},
                        \"last_accessed\": {\"S\": \"never\"},
                        \"created_at\": {\"S\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"},
                        \"s3_key\": {\"S\": \"knowledge/patterns/$dimension/${filename}.md\"},
                        \"summary\": {\"S\": \"$summary\"},
                        \"is_active\": {\"BOOL\": true}
                    }" \
                    --region "$REGION" 2>/dev/null || true
            fi

            # Start new pattern
            current_pattern="${BASH_REMATCH[1]}"
            current_content=""
            in_pattern=true
        elif $in_pattern; then
            # Skip dividers and empty lines at start
            if [[ "$line" == "---" ]]; then
                continue
            fi
            current_content+="$line"$'\n'
        fi
    done < "$source_file"

    # Save last pattern
    if [[ -n "$current_pattern" && -n "$current_content" ]]; then
        local filename=$(echo "$current_pattern" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')
        local target_file="$target_dir/${filename}.md"

        cat > "$target_file" << EOF
# $current_pattern

- **Dimension**: $dimension
- **Type**: $knowledge_type
- **Confidence**: emerging
- **Access Count**: 0
- **Last Accessed**: never

---

$current_content
EOF
        ((pattern_count++))

        # Index in DynamoDB
        local knowledge_id="${knowledge_type}-${filename}"
        local summary=$(echo "$current_content" | head -5 | tr '\n' ' ' | cut -c1-200)

        aws dynamodb put-item \
            --table-name "gua-knowledge-index" \
            --item "{
                \"user_id\": {\"S\": \"$USER_ID\"},
                \"knowledge_id\": {\"S\": \"$knowledge_id\"},
                \"name\": {\"S\": \"$current_pattern\"},
                \"pp_dimension\": {\"S\": \"$dimension\"},
                \"knowledge_type\": {\"S\": \"$knowledge_type\"},
                \"confidence\": {\"S\": \"emerging\"},
                \"scope\": {\"S\": \"global\"},
                \"depth_level\": {\"N\": \"2\"},
                \"access_count\": {\"N\": \"0\"},
                \"access_score\": {\"N\": \"0\"},
                \"last_accessed\": {\"S\": \"never\"},
                \"created_at\": {\"S\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"},
                \"s3_key\": {\"S\": \"knowledge/patterns/$dimension/${filename}.md\"},
                \"summary\": {\"S\": \"$summary\"},
                \"is_active\": {\"BOOL\": true}
            }" \
            --region "$REGION" 2>/dev/null || true
    fi

    echo "    Migrated $pattern_count items"
}

# Migrate dimension patterns
for dim in truth understanding beauty justice creativity; do
    if [[ -f "$KNOWLEDGE_DIR/by-dimension/$dim/patterns.md" ]]; then
        migrate_patterns_file "$KNOWLEDGE_DIR/by-dimension/$dim/patterns.md" "$KNOWLEDGE_DIR/patterns/$dim" "$dim" "pattern"
    fi
    if [[ -f "$KNOWLEDGE_DIR/by-dimension/$dim/blindspots.md" ]]; then
        migrate_patterns_file "$KNOWLEDGE_DIR/by-dimension/$dim/blindspots.md" "$KNOWLEDGE_DIR/blindspots/$dim" "$dim" "blindspot"
    fi
done

# Migrate domain patterns
for domain in aws claude-code typescript general; do
    if [[ -f "$KNOWLEDGE_DIR/by-domain/$domain/patterns.md" ]]; then
        migrate_patterns_file "$KNOWLEDGE_DIR/by-domain/$domain/patterns.md" "$KNOWLEDGE_DIR/domains/$domain" "$domain" "technique"
    fi
done

echo -e "  ${GREEN}Migration complete${NC}"

# ============================================================
# Step 4: Sync new structure to S3
# ============================================================
echo ""
echo -e "${BLUE}[4/5] Syncing new structure to S3...${NC}"

aws s3 sync "$KNOWLEDGE_DIR/patterns/" "s3://$S3_BUCKET/knowledge/patterns/" --region "$REGION" 2>/dev/null || true
aws s3 sync "$KNOWLEDGE_DIR/blindspots/" "s3://$S3_BUCKET/knowledge/blindspots/" --region "$REGION" 2>/dev/null || true
aws s3 sync "$KNOWLEDGE_DIR/domains/" "s3://$S3_BUCKET/knowledge/domains/" --region "$REGION" 2>/dev/null || true
aws s3 sync "$KNOWLEDGE_DIR/deep/" "s3://$S3_BUCKET/knowledge/deep/" --region "$REGION" 2>/dev/null || true

echo -e "  ${GREEN}S3 sync complete${NC}"

# ============================================================
# Step 5: Update config for v2
# ============================================================
echo ""
echo -e "${BLUE}[5/5] Updating configuration...${NC}"

# Add v2 settings to config
jq '. + {
    "version": "2.0",
    "tables": (.tables + {"knowledge_index": "gua-knowledge-index"}),
    "active_set": {
        "max_patterns": 50,
        "max_blindspots": 20,
        "recency_weight": 0.3,
        "frequency_weight": 0.7
    },
    "paths": {
        "patterns": "~/.claude/purpose_prompter/knowledge/patterns",
        "blindspots": "~/.claude/purpose_prompter/knowledge/blindspots",
        "domains": "~/.claude/purpose_prompter/knowledge/domains",
        "deep": "~/.claude/purpose_prompter/knowledge/deep"
    }
}' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"

echo -e "  ${GREEN}Config updated to v2${NC}"

# ============================================================
# Summary
# ============================================================
echo ""
echo -e "${GREEN}========================================"
echo "  GUA v2 Upgrade Complete!"
echo -e "========================================${NC}"
echo ""
echo "New Infrastructure:"
echo "  - DynamoDB Table: gua-knowledge-index (with 3 GSIs)"
echo "  - File-per-pattern structure in knowledge/"
echo ""
echo "New Commands Available:"
echo "  gua index-stats         # Show index statistics"
echo "  gua search <query>      # Search knowledge by query"
echo "  gua active-set          # Show current active set"
echo "  gua fetch <id>          # Fetch specific pattern"
echo "  gua track <id>          # Record access to pattern"
echo ""
echo "Backward Compatibility:"
echo "  - Old commands still work"
echo "  - Existing files preserved in by-dimension/ and by-domain/"
echo ""
