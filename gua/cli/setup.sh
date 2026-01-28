#!/bin/bash
# ============================================
# GUA Setup Wizard
# Run: ~/.gua/setup.sh
# ============================================

GUA_DIR="$HOME/.gua"
CONFIG_FILE="$GUA_DIR/config.json"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo ""
echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║              GUA SETUP WIZARD                          ║${NC}"
echo -e "${CYAN}║     Global Understanding Archive Configuration         ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# ============================================
# Step 1: Check Dependencies
# ============================================
echo -e "${BLUE}>>> CHECKING DEPENDENCIES${NC}"
echo "────────────────────────────────────────────────────────"

check_dependency() {
    local cmd=$1
    local install_hint=$2
    if command -v "$cmd" &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} $cmd found"
        return 0
    else
        echo -e "  ${RED}✗${NC} $cmd not found"
        echo -e "    Install: ${YELLOW}$install_hint${NC}"
        return 1
    fi
}

DEPS_OK=true
check_dependency "jq" "brew install jq" || DEPS_OK=false
check_dependency "aws" "brew install awscli" || DEPS_OK=false
check_dependency "uuidgen" "(built-in on macOS)" || DEPS_OK=false

if [[ "$DEPS_OK" != "true" ]]; then
    echo ""
    echo -e "${RED}Please install missing dependencies and run setup again.${NC}"
    exit 1
fi
echo ""

# ============================================
# Step 2: Verify AWS Credentials
# ============================================
echo -e "${BLUE}>>> VERIFYING AWS CREDENTIALS${NC}"
echo "────────────────────────────────────────────────────────"

AWS_IDENTITY=$(aws sts get-caller-identity 2>&1)
if [[ $? -ne 0 ]]; then
    echo -e "  ${RED}✗${NC} AWS credentials not configured or invalid"
    echo ""
    echo "  To configure AWS credentials:"
    echo "    1. aws configure"
    echo "    2. Enter your AWS Access Key ID"
    echo "    3. Enter your AWS Secret Access Key"
    echo "    4. Enter your default region (e.g., us-west-2)"
    echo ""
    echo -e "${RED}Please configure AWS credentials and run setup again.${NC}"
    exit 1
fi

AWS_ACCOUNT=$(echo "$AWS_IDENTITY" | jq -r '.Account')
AWS_ARN=$(echo "$AWS_IDENTITY" | jq -r '.Arn')
AWS_USER=$(echo "$AWS_ARN" | sed 's/.*\///')

echo -e "  ${GREEN}✓${NC} AWS credentials valid"
echo "    Account: $AWS_ACCOUNT"
echo "    User: $AWS_USER"
echo ""

# ============================================
# Step 3: Check Existing Configuration
# ============================================
if [[ -f "$CONFIG_FILE" ]]; then
    echo -e "${YELLOW}>>> EXISTING CONFIGURATION FOUND${NC}"
    echo "────────────────────────────────────────────────────────"
    EXISTING_USER=$(jq -r '.user_id' "$CONFIG_FILE")
    EXISTING_DEVICE=$(jq -r '.device_id' "$CONFIG_FILE")
    echo "  User ID: $EXISTING_USER"
    echo "  Device ID: $EXISTING_DEVICE"
    echo ""
    echo -n "Overwrite existing configuration? [y/N]: "
    read -r overwrite
    if [[ ! "$overwrite" =~ ^[Yy]$ ]]; then
        echo ""
        echo -e "${GREEN}Setup cancelled. Existing configuration preserved.${NC}"
        exit 0
    fi
    echo ""
fi

# ============================================
# Step 4: Configure User Identity
# ============================================
echo -e "${BLUE}>>> CONFIGURE USER IDENTITY${NC}"
echo "────────────────────────────────────────────────────────"

# Suggest user_id from AWS user or system username
SUGGESTED_USER="${AWS_USER:-$(whoami)}"
echo -n "Enter user ID [$SUGGESTED_USER]: "
read -r USER_ID
USER_ID="${USER_ID:-$SUGGESTED_USER}"
echo "  User ID: $USER_ID"
echo ""

# ============================================
# Step 5: Configure Device
# ============================================
echo -e "${BLUE}>>> CONFIGURE DEVICE${NC}"
echo "────────────────────────────────────────────────────────"

# Generate device name from hostname
HOSTNAME=$(hostname)
SUGGESTED_DEVICE="${USER_ID}-$(echo "$HOSTNAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')"

echo -n "Enter device ID [$SUGGESTED_DEVICE]: "
read -r DEVICE_ID
DEVICE_ID="${DEVICE_ID:-$SUGGESTED_DEVICE}"
echo "  Device ID: $DEVICE_ID"
echo "  Device Name: $HOSTNAME"
echo ""

# ============================================
# Step 6: Configure AWS Region
# ============================================
echo -e "${BLUE}>>> CONFIGURE AWS REGION${NC}"
echo "────────────────────────────────────────────────────────"

# Get default region from AWS config
DEFAULT_REGION=$(aws configure get region 2>/dev/null || echo "us-west-2")
echo -n "Enter AWS region [$DEFAULT_REGION]: "
read -r REGION
REGION="${REGION:-$DEFAULT_REGION}"
echo "  Region: $REGION"
echo ""

# ============================================
# Step 7: Configure S3 Bucket
# ============================================
echo -e "${BLUE}>>> CONFIGURE S3 BUCKET${NC}"
echo "────────────────────────────────────────────────────────"

SUGGESTED_BUCKET="gua-knowledge-store-${USER_ID}"
echo -n "Enter S3 bucket name [$SUGGESTED_BUCKET]: "
read -r S3_BUCKET
S3_BUCKET="${S3_BUCKET:-$SUGGESTED_BUCKET}"

# Check if bucket exists
if aws s3 ls "s3://$S3_BUCKET" &>/dev/null; then
    echo -e "  ${GREEN}✓${NC} Bucket exists: $S3_BUCKET"
else
    echo -e "  ${YELLOW}!${NC} Bucket does not exist: $S3_BUCKET"
    echo -n "Create bucket? [Y/n]: "
    read -r create_bucket
    if [[ ! "$create_bucket" =~ ^[Nn]$ ]]; then
        echo "  Creating bucket..."
        if [[ "$REGION" == "us-east-1" ]]; then
            aws s3api create-bucket --bucket "$S3_BUCKET" --region "$REGION" 2>/dev/null
        else
            aws s3api create-bucket --bucket "$S3_BUCKET" --region "$REGION" \
                --create-bucket-configuration LocationConstraint="$REGION" 2>/dev/null
        fi
        if [[ $? -eq 0 ]]; then
            echo -e "  ${GREEN}✓${NC} Bucket created"
        else
            echo -e "  ${RED}✗${NC} Failed to create bucket (may already exist in another account)"
        fi
    fi
fi
echo ""

# ============================================
# Step 8: Check/Create DynamoDB Tables
# ============================================
echo -e "${BLUE}>>> CHECKING DYNAMODB TABLES${NC}"
echo "────────────────────────────────────────────────────────"

check_or_create_table() {
    local table_name=$1
    local pk=$2
    local sk=$3

    if aws dynamodb describe-table --table-name "$table_name" --region "$REGION" &>/dev/null; then
        echo -e "  ${GREEN}✓${NC} Table exists: $table_name"
        return 0
    else
        echo -e "  ${YELLOW}!${NC} Table missing: $table_name"
        echo -n "    Create table? [Y/n]: "
        read -r create_table
        if [[ ! "$create_table" =~ ^[Nn]$ ]]; then
            echo "    Creating table..."
            aws dynamodb create-table \
                --table-name "$table_name" \
                --attribute-definitions \
                    AttributeName="$pk",AttributeType=S \
                    AttributeName="$sk",AttributeType=S \
                --key-schema \
                    AttributeName="$pk",KeyType=HASH \
                    AttributeName="$sk",KeyType=RANGE \
                --billing-mode PAY_PER_REQUEST \
                --region "$REGION" &>/dev/null
            if [[ $? -eq 0 ]]; then
                echo -e "    ${GREEN}✓${NC} Table created (may take a moment to become active)"
            else
                echo -e "    ${RED}✗${NC} Failed to create table"
            fi
        fi
    fi
}

check_or_create_table "gua-knowledge-index" "user_id" "timestamp_uuid"
check_or_create_table "gua-research" "user_id" "timestamp_uuid"
check_or_create_table "gua-feedback" "user_id" "timestamp_uuid"
check_or_create_table "gua-insights" "user_id" "timestamp_uuid"
check_or_create_table "gua-sessions" "user_id" "session_id"
echo ""

# ============================================
# Step 9: Create Configuration File
# ============================================
echo -e "${BLUE}>>> CREATING CONFIGURATION${NC}"
echo "────────────────────────────────────────────────────────"

# Create GUA directory if it doesn't exist
mkdir -p "$GUA_DIR"

# Create config.json
TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
cat > "$CONFIG_FILE" << EOF
{
  "user_id": "$USER_ID",
  "region": "$REGION",
  "s3_bucket": "$S3_BUCKET",
  "device_id": "$DEVICE_ID",
  "device_name": "$HOSTNAME",
  "tables": {
    "research": "gua-research",
    "feedback": "gua-feedback",
    "insights": "gua-insights",
    "sessions": "gua-sessions",
    "knowledge_index": "gua-knowledge-index"
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
  },
  "version": "2.0",
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
    "deep": "~/.claude/purpose_prompter/knowledge/deep",
    "progress": "~/.claude/purpose_prompter/progress",
    "snapshots": "~/.claude/purpose_prompter/progress/snapshots"
  },
  "cpt": {
    "enabled": true,
    "default_granularity": "domain",
    "understanding_levels": ["L0", "L1", "L2", "L3", "L4"],
    "challenge_categories": ["bug", "confusion", "ugly_hack", "wrong_place", "dead_end"],
    "auto_track_reads": false
  },
  "created_at": "$TS",
  "setup_version": "1.0"
}
EOF

echo -e "  ${GREEN}✓${NC} Configuration saved to: $CONFIG_FILE"
echo ""

# ============================================
# Step 10: Verify Setup
# ============================================
echo -e "${BLUE}>>> VERIFYING SETUP${NC}"
echo "────────────────────────────────────────────────────────"

# Test basic GUA command
if [[ -f "$GUA_DIR/gua.sh" ]]; then
    VERIFY_RESULT=$("$GUA_DIR/gua.sh" whoami 2>&1)
    if [[ $? -eq 0 ]]; then
        echo -e "  ${GREEN}✓${NC} GUA commands working"
    else
        echo -e "  ${YELLOW}!${NC} GUA commands may need testing"
    fi
else
    echo -e "  ${YELLOW}!${NC} gua.sh not found at $GUA_DIR/gua.sh"
fi
echo ""

# ============================================
# Complete
# ============================================
echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║              SETUP COMPLETE                            ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Configuration Summary:${NC}"
echo "  User ID:    $USER_ID"
echo "  Device ID:  $DEVICE_ID"
echo "  Region:     $REGION"
echo "  S3 Bucket:  $S3_BUCKET"
echo ""
echo -e "${GREEN}Quick Commands:${NC}"
echo "  gua whoami                  # Show current identity"
echo "  gua auth verify             # Verify authentication"
echo "  gua status                  # Check GUA status"
echo "  gua load                    # Load knowledge from AWS"
echo ""
echo -e "${GREEN}Path Protocol:${NC}"
echo "  source ~/.gua/path-session-start.sh  # Start session"
echo ""
echo -e "${CYAN}════════════════════════════════════════════════════════${NC}"
