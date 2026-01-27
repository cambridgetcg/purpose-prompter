#!/bin/bash
# Upgrade gua-knowledge-index with Eureka Recorder GSIs
# Run this once to enable eureka moment tracking

set -e

GUA_DIR="$HOME/.gua"
CONFIG_FILE="$GUA_DIR/config.json"

# Read region from GUA config if available, otherwise fallback
if [[ -f "$CONFIG_FILE" ]]; then
    REGION=$(jq -r '.region // "us-west-2"' "$CONFIG_FILE")
else
    REGION="${AWS_REGION:-us-west-2}"
fi

TABLE_NAME="gua-knowledge-index"

echo "=========================================="
echo "Eureka Recorder: GSI Upgrade"
echo "=========================================="
echo ""
echo "This will add two Global Secondary Indexes to $TABLE_NAME:"
echo "  1. eureka-type-index    - Query eurekas by type"
echo "  2. session-eurekas-index - Query eurekas by session"
echo ""

# Check if table exists
echo "Checking table status..."
TABLE_STATUS=$(aws dynamodb describe-table \
    --table-name "$TABLE_NAME" \
    --query 'Table.TableStatus' \
    --output text \
    --region "$REGION" 2>/dev/null) || {
    echo "ERROR: Table $TABLE_NAME not found."
    echo "Run setup.sh first to create the GUA infrastructure."
    exit 1
}

if [[ "$TABLE_STATUS" != "ACTIVE" ]]; then
    echo "ERROR: Table is not ACTIVE (status: $TABLE_STATUS)"
    echo "Wait for table to become active before running this script."
    exit 1
fi

# Check if GSIs already exist
EXISTING_GSIS=$(aws dynamodb describe-table \
    --table-name "$TABLE_NAME" \
    --query 'Table.GlobalSecondaryIndexes[*].IndexName' \
    --output text \
    --region "$REGION" 2>/dev/null) || EXISTING_GSIS=""

if echo "$EXISTING_GSIS" | grep -q "eureka-type-index"; then
    echo "GSI 'eureka-type-index' already exists."
    SKIP_TYPE_INDEX=true
else
    SKIP_TYPE_INDEX=false
fi

if echo "$EXISTING_GSIS" | grep -q "session-eurekas-index"; then
    echo "GSI 'session-eurekas-index' already exists."
    SKIP_SESSION_INDEX=true
else
    SKIP_SESSION_INDEX=false
fi

if [[ "$SKIP_TYPE_INDEX" == "true" && "$SKIP_SESSION_INDEX" == "true" ]]; then
    echo ""
    echo "All Eureka GSIs already exist. Nothing to do."
    exit 0
fi

# Build the update command
echo ""
echo "Creating GSIs..."

# We need to add GSIs one at a time for on-demand tables
# First, add eureka-type-index if needed
if [[ "$SKIP_TYPE_INDEX" == "false" ]]; then
    echo "Adding eureka-type-index..."
    aws dynamodb update-table \
        --table-name "$TABLE_NAME" \
        --attribute-definitions \
            AttributeName=eureka_type,AttributeType=S \
            AttributeName=created_at,AttributeType=S \
        --global-secondary-index-updates \
            "[{
                \"Create\": {
                    \"IndexName\": \"eureka-type-index\",
                    \"KeySchema\": [
                        {\"AttributeName\": \"eureka_type\", \"KeyType\": \"HASH\"},
                        {\"AttributeName\": \"created_at\", \"KeyType\": \"RANGE\"}
                    ],
                    \"Projection\": {\"ProjectionType\": \"ALL\"}
                }
            }]" \
        --region "$REGION"

    echo "Waiting for eureka-type-index to become active..."
    aws dynamodb wait table-exists --table-name "$TABLE_NAME" --region "$REGION"

    # Wait for GSI to be active
    while true; do
        GSI_STATUS=$(aws dynamodb describe-table \
            --table-name "$TABLE_NAME" \
            --query 'Table.GlobalSecondaryIndexes[?IndexName==`eureka-type-index`].IndexStatus' \
            --output text \
            --region "$REGION" 2>/dev/null)

        if [[ "$GSI_STATUS" == "ACTIVE" ]]; then
            echo "eureka-type-index is now ACTIVE"
            break
        fi
        echo "  Status: $GSI_STATUS (waiting...)"
        sleep 5
    done
fi

# Then add session-eurekas-index if needed
if [[ "$SKIP_SESSION_INDEX" == "false" ]]; then
    echo "Adding session-eurekas-index..."
    aws dynamodb update-table \
        --table-name "$TABLE_NAME" \
        --attribute-definitions \
            AttributeName=session_id,AttributeType=S \
            AttributeName=created_at,AttributeType=S \
        --global-secondary-index-updates \
            "[{
                \"Create\": {
                    \"IndexName\": \"session-eurekas-index\",
                    \"KeySchema\": [
                        {\"AttributeName\": \"session_id\", \"KeyType\": \"HASH\"},
                        {\"AttributeName\": \"created_at\", \"KeyType\": \"RANGE\"}
                    ],
                    \"Projection\": {\"ProjectionType\": \"ALL\"}
                }
            }]" \
        --region "$REGION"

    echo "Waiting for session-eurekas-index to become active..."

    while true; do
        GSI_STATUS=$(aws dynamodb describe-table \
            --table-name "$TABLE_NAME" \
            --query 'Table.GlobalSecondaryIndexes[?IndexName==`session-eurekas-index`].IndexStatus' \
            --output text \
            --region "$REGION" 2>/dev/null)

        if [[ "$GSI_STATUS" == "ACTIVE" ]]; then
            echo "session-eurekas-index is now ACTIVE"
            break
        fi
        echo "  Status: $GSI_STATUS (waiting...)"
        sleep 5
    done
fi

echo ""
echo "=========================================="
echo "Eureka Recorder GSIs created successfully!"
echo "=========================================="
echo ""
echo "You can now use:"
echo "  gua eureka log \"<insight>\" [type] [catalyst]"
echo "  gua eureka list [--type TYPE]"
echo "  gua eureka promote <id>"
echo ""
