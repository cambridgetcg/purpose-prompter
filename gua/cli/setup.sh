#!/bin/bash
# GUA Setup Script - Creates AWS infrastructure and local configuration
# Usage: ./setup.sh [user_id] [region]

set -e

# Configuration
USER_ID="${1:-$(whoami)}"
REGION="${2:-us-west-2}"
BUCKET_NAME="gua-knowledge-store-${USER_ID}"

echo "========================================"
echo "  Global Understanding Archive Setup"
echo "========================================"
echo ""
echo "User ID: $USER_ID"
echo "Region:  $REGION"
echo "Bucket:  $BUCKET_NAME"
echo ""

# Check AWS CLI
if ! command -v aws &> /dev/null; then
    echo "ERROR: AWS CLI not found. Please install it first."
    echo "  brew install awscli"
    exit 1
fi

# Check AWS credentials
echo "[1/6] Checking AWS credentials..."
if ! aws sts get-caller-identity &> /dev/null; then
    echo "ERROR: AWS credentials not configured."
    echo "  Run: aws configure"
    exit 1
fi
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "  Account: $ACCOUNT_ID"

# Create S3 bucket
echo ""
echo "[2/6] Creating S3 bucket..."
if aws s3api head-bucket --bucket "$BUCKET_NAME" 2>/dev/null; then
    echo "  Bucket already exists"
else
    aws s3api create-bucket \
        --bucket "$BUCKET_NAME" \
        --region "$REGION" \
        --create-bucket-configuration LocationConstraint="$REGION" 2>/dev/null || \
    aws s3api create-bucket \
        --bucket "$BUCKET_NAME" \
        --region "$REGION"
    echo "  Bucket created"
fi

# Enable versioning
aws s3api put-bucket-versioning \
    --bucket "$BUCKET_NAME" \
    --versioning-configuration Status=Enabled
echo "  Versioning enabled"

# Create DynamoDB tables
echo ""
echo "[3/6] Creating DynamoDB tables..."

create_table() {
    local table_name=$1
    local pk=$2
    local sk=$3

    if aws dynamodb describe-table --table-name "$table_name" --region "$REGION" &>/dev/null; then
        echo "  $table_name already exists"
    else
        aws dynamodb create-table \
            --table-name "$table_name" \
            --attribute-definitions \
                AttributeName="$pk",AttributeType=S \
                AttributeName="$sk",AttributeType=S \
            --key-schema \
                AttributeName="$pk",KeyType=HASH \
                AttributeName="$sk",KeyType=RANGE \
            --billing-mode PAY_PER_REQUEST \
            --region "$REGION" > /dev/null
        echo "  $table_name created"
    fi
}

create_table "gua-research" "user_id" "timestamp_uuid"
create_table "gua-feedback" "user_id" "timestamp_uuid"
create_table "gua-insights" "user_id" "timestamp_uuid"
create_table "gua-sessions" "user_id" "session_id"

# Initialize S3 with default documents
echo ""
echo "[4/6] Initializing default documents..."

# LIGHT.md
aws s3api head-object --bucket "$BUCKET_NAME" --key "documents/LIGHT.md" &>/dev/null || \
aws s3 cp - "s3://$BUCKET_NAME/documents/LIGHT.md" << 'LIGHT_EOF'
# LIGHT - Current Understanding

> Last synthesized: Never
> Sessions analyzed: 0
> Confidence: LOW (no data yet)

---

## Confirmed Patterns

*No patterns confirmed yet. Use `/gua-research` and `/gua-insight` to capture learnings.*

---

## Emerging Patterns

*Accumulating data...*

---

## Active Blindspots

*None identified yet.*

---

## Synthesis Notes

This document is automatically updated by GUA integration.
Run `/integrate` to synthesize accumulated knowledge into this document.
LIGHT_EOF
echo "  LIGHT.md initialized"

# PATH.md
aws s3api head-object --bucket "$BUCKET_NAME" --key "documents/PATH.md" &>/dev/null || \
aws s3 cp - "s3://$BUCKET_NAME/documents/PATH.md" << 'PATH_EOF'
# PATH - Direction Forward

> Generated: Initial
> Sessions analyzed: 0

---

## Immediate Focus

*Use the system to accumulate knowledge, then run `/integrate` to generate priorities.*

---

## Investigation Queue

*No investigations queued yet.*

---

## Long-term Direction

*Direction will emerge from accumulated patterns.*
PATH_EOF
echo "  PATH.md initialized"

# blindspots.md
aws s3api head-object --bucket "$BUCKET_NAME" --key "documents/blindspots.md" &>/dev/null || \
aws s3 cp - "s3://$BUCKET_NAME/documents/blindspots.md" << 'BLIND_EOF'
# Active Blindspots

> Last updated: Initial
> Total identified: 0

---

## Critical Blindspots

*None identified yet.*

---

## Monitored Blindspots

*Blindspots will be identified through feedback patterns.*

---

## Resolved Blindspots

*None resolved yet.*
BLIND_EOF
echo "  blindspots.md initialized"

# Create local config
echo ""
echo "[5/6] Creating local configuration..."

DEVICE_ID=$(hostname | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')
DEVICE_NAME=$(hostname)

cat > ~/.gua/config.json << CONFIG_EOF
{
  "user_id": "$USER_ID",
  "region": "$REGION",
  "s3_bucket": "$BUCKET_NAME",
  "device_id": "$DEVICE_ID",
  "device_name": "$DEVICE_NAME",
  "tables": {
    "research": "gua-research",
    "feedback": "gua-feedback",
    "insights": "gua-insights",
    "sessions": "gua-sessions"
  },
  "local_paths": {
    "light": "~/.claude/purpose_prompter/integration/LIGHT.md",
    "path": "~/.claude/purpose_prompter/integration/PATH.md",
    "blindspots": "~/.claude/purpose_prompter/insights/blindspots.md"
  },
  "sync": {
    "auto_load": true,
    "auto_save": true,
    "last_sync": null
  }
}
CONFIG_EOF
echo "  Config written to ~/.gua/config.json"

# Create state file
cat > ~/.gua/state.json << STATE_EOF
{
  "last_load": null,
  "last_save": null,
  "pending_research": 0,
  "pending_insights": 0,
  "session_count": 0
}
STATE_EOF
echo "  State file initialized"

# Make scripts executable
echo ""
echo "[6/6] Setting permissions..."
chmod +x ~/.gua/*.sh 2>/dev/null || true
echo "  Done"

echo ""
echo "========================================"
echo "  GUA Setup Complete!"
echo "========================================"
echo ""
echo "AWS Resources Created:"
echo "  - S3 Bucket: $BUCKET_NAME"
echo "  - DynamoDB Tables: gua-research, gua-feedback, gua-insights, gua-sessions"
echo ""
echo "Local Configuration:"
echo "  - Config: ~/.gua/config.json"
echo "  - State:  ~/.gua/state.json"
echo ""
echo "Next Steps:"
echo "  1. Run: gua load       # Load understanding from AWS"
echo "  2. Use: /gua-research  # Capture research findings"
echo "  3. Use: /gua-insight   # Capture insights"
echo "  4. Run: gua save       # Sync back to AWS"
echo ""
