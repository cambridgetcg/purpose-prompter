#!/bin/bash
# CPT Upgrade Script - Adds Code Progress Tracker to GUA
# Usage: ./upgrade-cpt.sh
#
# This script adds the project-status GSI to gua-knowledge-index
# for efficient querying of code areas by project and status.

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
echo "  CPT - Code Progress Tracker Setup"
echo -e "========================================${NC}"
echo ""

# Check config exists
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo -e "${RED}ERROR: GUA not configured. Run setup.sh first.${NC}"
    exit 1
fi

# Check v2 is enabled
VERSION=$(jq -r '.version // "1.0"' "$CONFIG_FILE")
if [[ "$VERSION" != "2.0" ]]; then
    echo -e "${RED}ERROR: GUA v2 required. Run upgrade-v2.sh first.${NC}"
    exit 1
fi

# Load config
USER_ID=$(jq -r '.user_id' "$CONFIG_FILE")
REGION=$(jq -r '.region' "$CONFIG_FILE")

echo "User ID: $USER_ID"
echo "Region:  $REGION"
echo ""

# ============================================================
# Step 1: Add project-status GSI to gua-knowledge-index
# ============================================================
echo -e "${BLUE}[1/3] Adding project-status GSI...${NC}"

TABLE_NAME="gua-knowledge-index"

# Check if GSI already exists
GSI_EXISTS=$(aws dynamodb describe-table \
    --table-name "$TABLE_NAME" \
    --region "$REGION" 2>/dev/null | \
    jq -r '.Table.GlobalSecondaryIndexes[]?.IndexName | select(. == "project-status-index")' || echo "")

if [[ -n "$GSI_EXISTS" ]]; then
    echo -e "  ${YELLOW}GSI already exists${NC}"
else
    aws dynamodb update-table \
        --table-name "$TABLE_NAME" \
        --attribute-definitions \
            AttributeName=project,AttributeType=S \
            AttributeName=implementation_status,AttributeType=S \
        --global-secondary-index-updates \
            "[{
                \"Create\": {
                    \"IndexName\": \"project-status-index\",
                    \"KeySchema\": [
                        {\"AttributeName\": \"project\", \"KeyType\": \"HASH\"},
                        {\"AttributeName\": \"implementation_status\", \"KeyType\": \"RANGE\"}
                    ],
                    \"Projection\": {\"ProjectionType\": \"ALL\"}
                }
            }]" \
        --region "$REGION" > /dev/null

    echo -e "  ${GREEN}GSI creation initiated${NC}"

    # Wait for GSI to be active
    echo "  Waiting for GSI to be active (this may take a few minutes)..."
    while true; do
        STATUS=$(aws dynamodb describe-table \
            --table-name "$TABLE_NAME" \
            --region "$REGION" 2>/dev/null | \
            jq -r '.Table.GlobalSecondaryIndexes[] | select(.IndexName == "project-status-index") | .IndexStatus')

        if [[ "$STATUS" == "ACTIVE" ]]; then
            break
        fi
        echo "    Status: $STATUS"
        sleep 10
    done
    echo -e "  ${GREEN}GSI ready${NC}"
fi

# ============================================================
# Step 2: Create local directories for progress tracking
# ============================================================
echo ""
echo -e "${BLUE}[2/3] Creating local directories...${NC}"

PROGRESS_DIR="$HOME/.claude/purpose_prompter/progress"
mkdir -p "$PROGRESS_DIR/projects"
mkdir -p "$PROGRESS_DIR/snapshots"

echo -e "  ${GREEN}Directories created${NC}"

# ============================================================
# Step 3: Update config for CPT
# ============================================================
echo ""
echo -e "${BLUE}[3/3] Updating configuration...${NC}"

# Add CPT settings to config
jq '. + {
    "cpt": {
        "enabled": true,
        "default_granularity": "domain",
        "understanding_levels": ["L0", "L1", "L2", "L3", "L4"],
        "challenge_categories": ["bug", "confusion", "ugly_hack", "wrong_place", "dead_end"],
        "auto_track_reads": false
    },
    "paths": (.paths + {
        "progress": "~/.claude/purpose_prompter/progress",
        "snapshots": "~/.claude/purpose_prompter/progress/snapshots"
    })
}' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"

echo -e "  ${GREEN}Config updated${NC}"

# ============================================================
# Summary
# ============================================================
echo ""
echo -e "${GREEN}========================================"
echo "  CPT Setup Complete!"
echo -e "========================================${NC}"
echo ""
echo "New Infrastructure:"
echo "  - GSI: project-status-index on gua-knowledge-index"
echo "  - Local: ~/.claude/purpose_prompter/progress/"
echo ""
echo "New Commands Available:"
echo "  gua area add <project> <path> [name] [granularity]"
echo "  gua area status [project]"
echo "  gua area update <area_id> [--impl <pct>] [--depth <L0-L4>]"
echo ""
echo "  gua challenge log <area_id> <description> [pp_dim] [category]"
echo "  gua challenge resolve <challenge_id> <resolution>"
echo "  gua challenge list [--dimension <dim>]"
echo ""
echo "  gua progress [project]"
echo "  gua progress snapshot [project]"
echo ""
echo "Plugin Commands:"
echo "  /cpt-area, /cpt-challenge, /cpt-context"
echo ""
