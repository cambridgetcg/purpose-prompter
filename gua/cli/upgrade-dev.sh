#!/bin/bash
# GUA Dev Knowledge Extension - GSI Upgrade Script
# Adds platform-domain-index for efficient dev knowledge queries

set -e

REGION="us-west-2"
TABLE_NAME="gua-knowledge-index"

echo "=== GUA Dev Knowledge Extension Upgrade ==="
echo ""
echo "This script will add the platform-domain-index GSI to $TABLE_NAME"
echo "Region: $REGION"
echo ""

# Check if GSI already exists
echo "Checking for existing GSI..."
EXISTING=$(aws dynamodb describe-table --table-name "$TABLE_NAME" --region "$REGION" 2>/dev/null | jq -r '.Table.GlobalSecondaryIndexes[]?.IndexName // empty' | grep -c "platform-domain-index" || true)

if [[ "$EXISTING" -gt 0 ]]; then
    echo "GSI 'platform-domain-index' already exists. Skipping creation."
    exit 0
fi

echo "Creating platform-domain-index GSI..."
echo ""

aws dynamodb update-table \
    --table-name "$TABLE_NAME" \
    --attribute-definitions \
        AttributeName=platform_domain,AttributeType=S \
        AttributeName=access_score,AttributeType=N \
    --global-secondary-index-updates \
        "[{
            \"Create\": {
                \"IndexName\": \"platform-domain-index\",
                \"KeySchema\": [
                    {\"AttributeName\": \"platform_domain\", \"KeyType\": \"HASH\"},
                    {\"AttributeName\": \"access_score\", \"KeyType\": \"RANGE\"}
                ],
                \"Projection\": {\"ProjectionType\": \"ALL\"}
            }
        }]" \
    --region "$REGION"

echo ""
echo "GSI creation initiated. Waiting for completion..."
echo "(This may take a few minutes)"
echo ""

# Wait for GSI to become active
while true; do
    STATUS=$(aws dynamodb describe-table --table-name "$TABLE_NAME" --region "$REGION" | jq -r '.Table.GlobalSecondaryIndexes[] | select(.IndexName == "platform-domain-index") | .IndexStatus')

    if [[ "$STATUS" == "ACTIVE" ]]; then
        echo "GSI 'platform-domain-index' is now ACTIVE!"
        break
    elif [[ "$STATUS" == "CREATING" ]]; then
        echo "  Status: CREATING..."
        sleep 10
    else
        echo "  Status: $STATUS"
        sleep 5
    fi
done

echo ""
echo "=== Upgrade Complete ==="
echo ""
echo "The platform-domain-index GSI has been created."
echo "You can now use 'gua dev' commands to capture app development knowledge."
echo ""
echo "Quick start:"
echo "  gua dev add shopify api gotcha \"Your first gotcha\""
echo "  gua dev list shopify"
echo ""
