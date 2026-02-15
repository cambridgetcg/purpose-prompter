# Global Understanding Archive (GUA) - AWS Architecture

> **Vision**: A robust, cross-device, cross-session knowledge system powered by AWS,
> enabling Claude Code sessions on ANY device to start with compound understanding.
>
> **Mode**: Fully AWS-reliant for multi-device synchronization
> **Status**: Architecture designed via full PP (35 gates passed)
> **Created**: 2026-01-27

---

## Executive Summary

### Why AWS?

The project is used across **multiple devices and sessions**. Local file storage doesn't sync.
AWS provides:
- **Global availability** - Access from any device
- **Concurrent safety** - Multiple sessions can write simultaneously
- **Durability** - Data persists reliably
- **Scalability** - Grows with accumulated knowledge

### AWS Services Used

| Service | Purpose | Est. Monthly Cost |
|---------|---------|-------------------|
| **S3** | Document storage (LIGHT.md, PATH.md, etc.) | ~$1-2 |
| **DynamoDB** | Structured data (research, feedback, insights) | ~$5-10 |
| **Lambda** | Automated synthesis triggers | ~$1-2 |
| **Secrets Manager** | API credentials | ~$0.40 |
| **CloudWatch** | Monitoring & logs | ~$1-2 |
| **IAM** | Access control | Free |
| **Total** | | **~$10-20/month** |

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                    GLOBAL UNDERSTANDING ARCHIVE (AWS)                            │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                  │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                           AWS CLOUD                                      │   │
│  │                                                                          │   │
│  │   ┌────────────────────────────────────────────────────────────────┐   │   │
│  │   │                         S3 BUCKET                               │   │   │
│  │   │                    gua-knowledge-store                          │   │   │
│  │   │                                                                  │   │   │
│  │   │   /documents/                                                   │   │   │
│  │   │   ├── LIGHT.md              (synthesized understanding)         │   │   │
│  │   │   ├── PATH.md               (direction forward)                 │   │   │
│  │   │   ├── blindspots.md         (active weaknesses)                 │   │   │
│  │   │   └── config.json           (GUA configuration)                 │   │   │
│  │   │                                                                  │   │   │
│  │   │   /projects/{project-hash}/                                     │   │   │
│  │   │   └── understanding.md      (project-specific)                  │   │   │
│  │   │                                                                  │   │   │
│  │   │   /synthesis/                                                   │   │   │
│  │   │   └── history/              (previous LIGHT versions)           │   │   │
│  │   │                                                                  │   │   │
│  │   └────────────────────────────────────────────────────────────────┘   │   │
│  │                                                                          │   │
│  │   ┌────────────────────────────────────────────────────────────────┐   │   │
│  │   │                       DYNAMODB TABLES                           │   │   │
│  │   │                                                                  │   │   │
│  │   │   gua-research        (research discoveries)                    │   │   │
│  │   │   ├── PK: user_id                                               │   │   │
│  │   │   ├── SK: timestamp#uuid                                        │   │   │
│  │   │   └── Attributes: topic, finding, source, confidence            │   │   │
│  │   │                                                                  │   │   │
│  │   │   gua-feedback        (accumulated feedback)                    │   │   │
│  │   │   ├── PK: user_id                                               │   │   │
│  │   │   ├── SK: timestamp#uuid                                        │   │   │
│  │   │   └── Attributes: dimension, rating, task, observation          │   │   │
│  │   │                                                                  │   │   │
│  │   │   gua-insights        (emerging insights)                       │   │   │
│  │   │   ├── PK: user_id                                               │   │   │
│  │   │   ├── SK: timestamp#uuid                                        │   │   │
│  │   │   └── Attributes: type, content, evidence, status               │   │   │
│  │   │                                                                  │   │   │
│  │   │   gua-sessions        (session metadata)                        │   │   │
│  │   │   ├── PK: user_id                                               │   │   │
│  │   │   ├── SK: session_id                                            │   │   │
│  │   │   └── Attributes: device, project, start, end, stats            │   │   │
│  │   │                                                                  │   │   │
│  │   └────────────────────────────────────────────────────────────────┘   │   │
│  │                                                                          │   │
│  │   ┌────────────────────────────────────────────────────────────────┐   │   │
│  │   │                      LAMBDA FUNCTIONS                           │   │   │
│  │   │                                                                  │   │   │
│  │   │   gua-synthesis-trigger                                         │   │   │
│  │   │   └── Triggers synthesis when threshold reached                 │   │   │
│  │   │                                                                  │   │   │
│  │   │   gua-cleanup                                                   │   │   │
│  │   │   └── Prunes old data, maintains archive size                   │   │   │
│  │   │                                                                  │   │   │
│  │   └────────────────────────────────────────────────────────────────┘   │   │
│  │                                                                          │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                          │                                      │
│                                          │ HTTPS API                            │
│                                          │                                      │
│  ┌───────────────────────────────────────┼──────────────────────────────────┐  │
│  │                                       │                                   │  │
│  │      DEVICE 1              DEVICE 2   │           DEVICE N               │  │
│  │   ┌──────────┐          ┌──────────┐  │        ┌──────────┐              │  │
│  │   │  Claude  │          │  Claude  │  │        │  Claude  │              │  │
│  │   │   Code   │          │   Code   │  │        │   Code   │              │  │
│  │   │          │          │          │  │        │          │              │  │
│  │   │ GUA CLI  │          │ GUA CLI  │◄─┼───────►│ GUA CLI  │              │  │
│  │   └──────────┘          └──────────┘  │        └──────────┘              │  │
│  │                                       │                                   │  │
│  │                    LOCAL DEVICES                                          │  │
│  └───────────────────────────────────────────────────────────────────────────┘  │
│                                                                                  │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## AWS Resource Specifications

### 1. S3 Bucket: `gua-knowledge-store`

**Purpose**: Store markdown documents and configuration.

**Configuration**:
```json
{
  "BucketName": "gua-knowledge-store-{user-id}",
  "Region": "us-east-1",
  "Versioning": "Enabled",
  "Encryption": "AES-256",
  "LifecycleRules": [
    {
      "ID": "ArchiveOldVersions",
      "Status": "Enabled",
      "NoncurrentVersionTransition": {
        "NoncurrentDays": 30,
        "StorageClass": "GLACIER"
      },
      "NoncurrentVersionExpiration": {
        "NoncurrentDays": 365
      }
    }
  ]
}
```

**Bucket Structure**:
```
gua-knowledge-store-{user-id}/
├── documents/
│   ├── LIGHT.md                    # Current synthesized understanding
│   ├── PATH.md                     # Current direction
│   ├── blindspots.md               # Active blindspots
│   └── config.json                 # GUA configuration
├── projects/
│   └── {project-hash}/
│       └── understanding.md        # Project-specific understanding
├── synthesis/
│   └── history/
│       ├── LIGHT-2026-01-27.md     # Historical versions
│       └── LIGHT-2026-01-20.md
└── exports/
    └── full-archive-{date}.json    # Periodic full exports
```

**Estimated Cost**: ~$0.023/GB/month + requests (~$1-2/month for typical use)

---

### 2. DynamoDB Tables

#### 2.1 `gua-research`

**Purpose**: Store research discoveries with full query capability.

**Schema**:
```
Table: gua-research
├── Partition Key: user_id (String)
├── Sort Key: timestamp#uuid (String)
├── Attributes:
│   ├── topic (String)
│   ├── finding (String)
│   ├── source (String)
│   ├── confidence (String: low|medium|high)
│   ├── session_id (String)
│   ├── device_id (String)
│   ├── synthesized (Boolean)
│   └── ttl (Number - optional expiration)
└── GSI: topic-index
    ├── Partition Key: user_id
    └── Sort Key: topic
```

**Sample Item**:
```json
{
  "user_id": "yu",
  "timestamp#uuid": "2026-01-27T10:00:00Z#a1b2c3d4",
  "topic": "vector-databases",
  "finding": "ChromaDB is free for <10M vectors, Pinecone better for production",
  "source": "web-search",
  "confidence": "high",
  "session_id": "sess-abc123",
  "device_id": "mac-studio",
  "synthesized": false
}
```

---

#### 2.2 `gua-feedback`

**Purpose**: Store PP feedback entries.

**Schema**:
```
Table: gua-feedback
├── Partition Key: user_id (String)
├── Sort Key: timestamp#uuid (String)
├── Attributes:
│   ├── dimension (String: truth|understanding|beauty|justice|creativity)
│   ├── rating (String: pass|partial|fail)
│   ├── task (String)
│   ├── observation (String)
│   ├── session_id (String)
│   ├── device_id (String)
│   └── synthesized (Boolean)
└── GSI: dimension-index
    ├── Partition Key: user_id
    └── Sort Key: dimension#timestamp
```

---

#### 2.3 `gua-insights`

**Purpose**: Store emerging insights and patterns.

**Schema**:
```
Table: gua-insights
├── Partition Key: user_id (String)
├── Sort Key: timestamp#uuid (String)
├── Attributes:
│   ├── type (String: pattern|blindspot|question|contradiction)
│   ├── content (String)
│   ├── evidence (String)
│   ├── confidence (String: low|medium|high)
│   ├── status (String: emerging|confirmed|resolved)
│   ├── session_id (String)
│   └── synthesized (Boolean)
└── GSI: type-index
    ├── Partition Key: user_id
    └── Sort Key: type#status
```

---

#### 2.4 `gua-sessions`

**Purpose**: Track session metadata across devices.

**Schema**:
```
Table: gua-sessions
├── Partition Key: user_id (String)
├── Sort Key: session_id (String)
├── Attributes:
│   ├── device_id (String)
│   ├── device_name (String)
│   ├── project_path (String)
│   ├── project_hash (String)
│   ├── start_time (String - ISO8601)
│   ├── end_time (String - ISO8601)
│   ├── research_count (Number)
│   ├── feedback_count (Number)
│   ├── insight_count (Number)
│   └── status (String: active|completed|abandoned)
└── GSI: device-index
    ├── Partition Key: user_id
    └── Sort Key: device_id#start_time
```

**DynamoDB Configuration**:
```json
{
  "BillingMode": "PAY_PER_REQUEST",
  "PointInTimeRecovery": true,
  "TableClass": "STANDARD"
}
```

**Estimated Cost**: ~$1.25/million writes, $0.25/million reads (~$5-10/month)

---

### 3. Lambda Functions

#### 3.1 `gua-synthesis-trigger`

**Purpose**: Monitor DynamoDB streams and trigger synthesis when threshold reached.

**Trigger**: DynamoDB Streams on `gua-feedback` table

**Logic**:
```python
def handler(event, context):
    # Count unsynthesized entries
    unsynthesized = count_unsynthesized_entries(user_id)

    # Check thresholds
    if unsynthesized['feedback'] >= 10:
        notify_synthesis_needed(user_id, 'feedback_threshold')
    elif unsynthesized['research'] >= 20:
        notify_synthesis_needed(user_id, 'research_threshold')
    elif days_since_last_synthesis(user_id) >= 7:
        notify_synthesis_needed(user_id, 'time_threshold')
```

**Configuration**:
```json
{
  "Runtime": "python3.11",
  "MemorySize": 128,
  "Timeout": 30,
  "Environment": {
    "NOTIFICATION_TOPIC": "arn:aws:sns:...:gua-notifications"
  }
}
```

---

#### 3.2 `gua-cleanup`

**Purpose**: Maintain archive size, prune old synthesized data.

**Trigger**: CloudWatch Events (weekly)

**Logic**:
```python
def handler(event, context):
    # Archive old synthesized entries (>90 days)
    archive_old_entries(user_id, days=90)

    # Remove abandoned sessions (>30 days, never completed)
    cleanup_abandoned_sessions(user_id, days=30)

    # Compact S3 synthesis history (keep last 10)
    compact_synthesis_history(user_id, keep=10)
```

**Estimated Cost**: ~$0.20/million requests (~$1-2/month)

---

### 4. IAM Configuration

#### IAM Policy: `GUA-Client-Policy`

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "S3Access",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::gua-knowledge-store-${user_id}",
        "arn:aws:s3:::gua-knowledge-store-${user_id}/*"
      ]
    },
    {
      "Sid": "DynamoDBAccess",
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:Query",
        "dynamodb:UpdateItem",
        "dynamodb:BatchWriteItem"
      ],
      "Resource": [
        "arn:aws:dynamodb:*:*:table/gua-research",
        "arn:aws:dynamodb:*:*:table/gua-feedback",
        "arn:aws:dynamodb:*:*:table/gua-insights",
        "arn:aws:dynamodb:*:*:table/gua-sessions",
        "arn:aws:dynamodb:*:*:table/gua-*/index/*"
      ]
    }
  ]
}
```

---

### 5. Secrets Manager

**Secret**: `gua/credentials`

```json
{
  "user_id": "yu",
  "aws_access_key_id": "AKIA...",
  "aws_secret_access_key": "...",
  "region": "us-east-1",
  "s3_bucket": "gua-knowledge-store-yu"
}
```

**Local Config**: `~/.gua/config.json`
```json
{
  "user_id": "yu",
  "region": "us-east-1",
  "credentials_source": "aws_profile",
  "aws_profile": "gua",
  "s3_bucket": "gua-knowledge-store-yu",
  "device_id": "mac-studio",
  "device_name": "Yu's Mac Studio"
}
```

---

## Client Operations

### 1. Session Start (LOAD)

```
┌─────────────────────────────────────────────────────────────────┐
│                      SESSION START                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. Read local config (~/.gua/config.json)                      │
│                                                                  │
│  2. Fetch from S3:                                              │
│     GET s3://gua-knowledge-store-{user}/documents/LIGHT.md      │
│     GET s3://gua-knowledge-store-{user}/documents/blindspots.md │
│     GET s3://gua-knowledge-store-{user}/documents/PATH.md       │
│                                                                  │
│  3. Check for project understanding:                             │
│     project_hash = sha256(cwd)[:12]                             │
│     GET s3://.../{project_hash}/understanding.md (if exists)    │
│                                                                  │
│  4. Register session in DynamoDB:                                │
│     PUT gua-sessions {                                          │
│       user_id, session_id, device_id, project_hash,             │
│       start_time, status: "active"                              │
│     }                                                            │
│                                                                  │
│  5. Inject into Claude Code context:                             │
│     • LIGHT.md content                                          │
│     • Critical blindspots                                       │
│     • Project understanding (if applicable)                      │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

**CLI Command**: `gua load` (or automatic via hook)

---

### 2. During Session (CAPTURE)

```
┌─────────────────────────────────────────────────────────────────┐
│                      DURING SESSION                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Research Discovery:                                             │
│  └─ /gua-research "vector databases" "ChromaDB free <10M"       │
│     └─ PUT gua-research { user_id, timestamp, topic, finding }  │
│                                                                  │
│  Feedback Entry:                                                 │
│  └─ /pp-feedback beauty pass "emerged naturally"                │
│     └─ PUT gua-feedback { user_id, timestamp, dimension, ... }  │
│                                                                  │
│  Insight Capture:                                                │
│  └─ /gua-insight "Tiered implementation reduces risk"           │
│     └─ PUT gua-insights { user_id, timestamp, content, ... }    │
│                                                                  │
│  Project Understanding Update:                                   │
│  └─ /gua-project-update "Added auth service using JWT"          │
│     └─ PUT s3://.../{project_hash}/understanding.md             │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

### 3. Session End (PERSIST)

```
┌─────────────────────────────────────────────────────────────────┐
│                       SESSION END                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. Update session record:                                       │
│     UPDATE gua-sessions {                                       │
│       end_time, status: "completed",                            │
│       research_count, feedback_count, insight_count             │
│     }                                                            │
│                                                                  │
│  2. Flush any buffered entries to DynamoDB                      │
│                                                                  │
│  3. Check synthesis threshold:                                   │
│     - Count unsynthesized entries                               │
│     - If threshold reached → prompt for /integrate              │
│                                                                  │
│  4. Update project understanding (if significant changes):       │
│     PUT s3://.../{project_hash}/understanding.md                │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

**CLI Command**: `gua save` (or automatic via hook)

---

### 4. Synthesis

```
┌─────────────────────────────────────────────────────────────────┐
│                        SYNTHESIS                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Trigger: /integrate command                                    │
│                                                                  │
│  1. GATHER:                                                      │
│     - Query gua-research (unsynthesized)                        │
│     - Query gua-feedback (unsynthesized)                        │
│     - Query gua-insights (unsynthesized)                        │
│     - Fetch current LIGHT.md from S3                            │
│                                                                  │
│  2. ANALYZE (via LLM):                                          │
│     - Extract patterns from accumulated data                    │
│     - Identify new blindspots                                   │
│     - Find contradictions                                       │
│     - Update confidence levels                                  │
│                                                                  │
│  3. SYNTHESIZE:                                                  │
│     - Generate new LIGHT.md                                     │
│     - Generate new PATH.md                                      │
│     - Update blindspots.md                                      │
│                                                                  │
│  4. PERSIST:                                                     │
│     - Archive old LIGHT.md to synthesis/history/                │
│     - PUT new documents to S3                                   │
│     - Mark entries as synthesized in DynamoDB                   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

**CLI Command**: `gua integrate` or `/integrate`

---

## GUA CLI Tool

### Installation

```bash
# Install GUA CLI
pip install gua-cli  # or npm install -g @gua/cli

# Configure
gua configure
# Prompts for: AWS profile, user_id, device_name, region
```

### Commands

| Command | Description |
|---------|-------------|
| `gua configure` | Initial setup and AWS configuration |
| `gua load` | Load understanding into current session |
| `gua save` | Persist session learnings to AWS |
| `gua research <topic> <finding>` | Log research discovery |
| `gua insight <observation>` | Log emerging insight |
| `gua integrate` | Run synthesis on accumulated data |
| `gua status` | Show current GUA status (entries, last sync) |
| `gua export` | Export full archive to local file |
| `gua import <file>` | Import archive from file |

### Claude Code Integration

**Hook**: `~/.claude/hooks/gua-aws.md`

```yaml
name: gua-aws-load
event: UserPromptSubmit
pattern: ".*"
runOnce: true
enabled: true
action: |
  # Auto-load GUA at session start
  $(gua load --quiet)

---
name: gua-aws-persist
event: Stop
enabled: true
action: |
  # Auto-save GUA at session end
  $(gua save --quiet)
```

---

## Infrastructure Setup

### Terraform Configuration

```hcl
# main.tf

provider "aws" {
  region = var.region
}

variable "user_id" {
  description = "GUA user identifier"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# S3 Bucket
resource "aws_s3_bucket" "gua_knowledge" {
  bucket = "gua-knowledge-store-${var.user_id}"
}

resource "aws_s3_bucket_versioning" "gua_knowledge" {
  bucket = aws_s3_bucket.gua_knowledge.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "gua_knowledge" {
  bucket = aws_s3_bucket.gua_knowledge.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# DynamoDB Tables
resource "aws_dynamodb_table" "gua_research" {
  name         = "gua-research"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "user_id"
  range_key    = "timestamp_uuid"

  attribute {
    name = "user_id"
    type = "S"
  }

  attribute {
    name = "timestamp_uuid"
    type = "S"
  }

  attribute {
    name = "topic"
    type = "S"
  }

  global_secondary_index {
    name            = "topic-index"
    hash_key        = "user_id"
    range_key       = "topic"
    projection_type = "ALL"
  }

  point_in_time_recovery {
    enabled = true
  }
}

resource "aws_dynamodb_table" "gua_feedback" {
  name         = "gua-feedback"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "user_id"
  range_key    = "timestamp_uuid"

  attribute {
    name = "user_id"
    type = "S"
  }

  attribute {
    name = "timestamp_uuid"
    type = "S"
  }

  attribute {
    name = "dimension"
    type = "S"
  }

  global_secondary_index {
    name            = "dimension-index"
    hash_key        = "user_id"
    range_key       = "dimension"
    projection_type = "ALL"
  }

  point_in_time_recovery {
    enabled = true
  }
}

resource "aws_dynamodb_table" "gua_insights" {
  name         = "gua-insights"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "user_id"
  range_key    = "timestamp_uuid"

  attribute {
    name = "user_id"
    type = "S"
  }

  attribute {
    name = "timestamp_uuid"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }
}

resource "aws_dynamodb_table" "gua_sessions" {
  name         = "gua-sessions"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "user_id"
  range_key    = "session_id"

  attribute {
    name = "user_id"
    type = "S"
  }

  attribute {
    name = "session_id"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }
}

# IAM User for CLI
resource "aws_iam_user" "gua_user" {
  name = "gua-cli-${var.user_id}"
}

resource "aws_iam_user_policy" "gua_policy" {
  name = "gua-access"
  user = aws_iam_user.gua_user.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3Access"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ]
        Resource = [
          aws_s3_bucket.gua_knowledge.arn,
          "${aws_s3_bucket.gua_knowledge.arn}/*"
        ]
      },
      {
        Sid    = "DynamoDBAccess"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:Query",
          "dynamodb:UpdateItem",
          "dynamodb:BatchWriteItem",
          "dynamodb:Scan"
        ]
        Resource = [
          aws_dynamodb_table.gua_research.arn,
          aws_dynamodb_table.gua_feedback.arn,
          aws_dynamodb_table.gua_insights.arn,
          aws_dynamodb_table.gua_sessions.arn,
          "${aws_dynamodb_table.gua_research.arn}/index/*",
          "${aws_dynamodb_table.gua_feedback.arn}/index/*"
        ]
      }
    ]
  })
}

resource "aws_iam_access_key" "gua_key" {
  user = aws_iam_user.gua_user.name
}

# Outputs
output "s3_bucket" {
  value = aws_s3_bucket.gua_knowledge.bucket
}

output "access_key_id" {
  value     = aws_iam_access_key.gua_key.id
  sensitive = true
}

output "secret_access_key" {
  value     = aws_iam_access_key.gua_key.secret
  sensitive = true
}
```

### Quick Setup Script

```bash
#!/bin/bash
# setup-gua-aws.sh

set -e

USER_ID="${1:-$(whoami)}"
REGION="${2:-us-east-1}"

echo "Setting up GUA AWS infrastructure for user: $USER_ID"

# Initialize Terraform
cd terraform/
terraform init

# Apply infrastructure
terraform apply -var="user_id=$USER_ID" -var="region=$REGION" -auto-approve

# Get outputs
S3_BUCKET=$(terraform output -raw s3_bucket)
ACCESS_KEY=$(terraform output -raw access_key_id)
SECRET_KEY=$(terraform output -raw secret_access_key)

# Configure AWS CLI profile
aws configure set aws_access_key_id "$ACCESS_KEY" --profile gua
aws configure set aws_secret_access_key "$SECRET_KEY" --profile gua
aws configure set region "$REGION" --profile gua

# Initialize GUA config
mkdir -p ~/.gua
cat > ~/.gua/config.json << EOF
{
  "user_id": "$USER_ID",
  "region": "$REGION",
  "credentials_source": "aws_profile",
  "aws_profile": "gua",
  "s3_bucket": "$S3_BUCKET",
  "device_id": "$(hostname | tr '[:upper:]' '[:lower:]' | tr ' ' '-')",
  "device_name": "$(hostname)"
}
EOF

# Initialize S3 with empty documents
aws s3 cp --profile gua - "s3://$S3_BUCKET/documents/LIGHT.md" << 'EOF'
# LIGHT - Current Understanding

> Last synthesized: Never
> Sessions analyzed: 0
> Confidence: LOW (no data yet)

---

## Confirmed Patterns

*No patterns yet. Start accumulating feedback and research.*

---

## Active Blindspots

*None identified yet.*
EOF

aws s3 cp --profile gua - "s3://$S3_BUCKET/documents/PATH.md" << 'EOF'
# PATH - Direction Forward

> Based on: Initial setup
> Confidence: LOW

---

## Immediate Priorities

1. **Accumulate data**: Use /gua-research and /pp-feedback to build knowledge base
2. **Run first synthesis**: After 10+ entries, run /integrate

---

## Getting Started

- Use `/gua-research <topic> <finding>` to log discoveries
- Use `/pp-feedback <dimension> <rating> <observation>` for feedback
- Use `/gua-insight <observation>` for emerging patterns
EOF

aws s3 cp --profile gua - "s3://$S3_BUCKET/documents/blindspots.md" << 'EOF'
# Active Blindspots

> Last updated: Initial setup

---

## CRITICAL

*None yet. Blindspots will be identified through synthesis.*

---

## MODERATE

*None yet.*
EOF

echo ""
echo "GUA AWS setup complete!"
echo ""
echo "S3 Bucket: $S3_BUCKET"
echo "Region: $REGION"
echo "Config: ~/.gua/config.json"
echo ""
echo "Next steps:"
echo "1. Run 'gua status' to verify connection"
echo "2. Start logging with 'gua research' and 'gua insight'"
echo "3. Run 'gua integrate' after accumulating entries"
```

---

## Cost Breakdown

| Service | Usage Estimate | Monthly Cost |
|---------|---------------|--------------|
| **S3** | 100MB storage, 10K requests | ~$1.50 |
| **DynamoDB** | 50K writes, 100K reads | ~$7.00 |
| **Lambda** | 1K invocations, 128MB | ~$0.50 |
| **CloudWatch** | Basic logs | ~$1.00 |
| **Data Transfer** | 1GB out | ~$0.10 |
| **Total** | | **~$10-15/month** |

---

## Security Considerations

1. **Encryption at Rest**: S3 uses AES-256, DynamoDB encrypted by default
2. **Encryption in Transit**: All AWS API calls use HTTPS
3. **Access Control**: IAM policy limits to specific resources
4. **Credentials**: Stored in AWS profile, not in code
5. **Versioning**: S3 versioning protects against accidental deletion
6. **Backup**: DynamoDB point-in-time recovery enabled

---

## Migration from Local

If migrating from local file-based GUA:

```bash
# Export local data
gua export --local --output local-archive.json

# Import to AWS
gua import local-archive.json --to-aws

# Verify
gua status
```

---

## Summary

| Component | AWS Service | Purpose |
|-----------|-------------|---------|
| Documents | S3 | LIGHT.md, PATH.md, blindspots.md |
| Structured Data | DynamoDB | research, feedback, insights, sessions |
| Automation | Lambda | synthesis triggers, cleanup |
| Security | IAM + Secrets Manager | access control, credentials |
| Monitoring | CloudWatch | logs, metrics |

**Total Monthly Cost**: ~$10-20

**Benefits**:
- Works across ALL devices
- Concurrent session safety
- Automatic backups
- Scalable as knowledge grows
- Professional-grade reliability

---

*AWS Architecture designed for cross-device, cross-session Global Understanding Archive.*
*Created: 2026-01-27*
