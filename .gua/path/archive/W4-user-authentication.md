# Waypoint: W4 - User Authentication

**Created**: 2026-01-28T17:47:46Z
**Predecessor**: W3
**Successor**: PURPOSE
**Status**: completed

## What This Waypoint Achieves
Proper user onboarding and authentication for GUA. New users can set up GUA with an interactive wizard, verify their AWS credentials, and register their devices.

## Success Criteria
1. [x] `gua init` command provides interactive setup wizard
2. [x] AWS credential verification with helpful error messages
3. [x] User profile creation with unique user_id
4. [x] Device registration for multi-device support
5. [x] `gua whoami` command shows current user/device info
6. [x] `gua auth verify` checks authentication status

## E2E Tests That Must Pass
- [x] Fresh `gua init` creates valid config.json
- [x] `gua whoami` displays user and device info
- [x] `gua auth verify` returns valid/invalid status
- [x] Invalid AWS credentials show helpful error

## Dependencies
- [x] AWS CLI installed and configured
- [x] jq installed
- [x] GUA core infrastructure (gua.sh)

## Known Risks
- AWS credential management varies by environment
- Device ID generation must be unique and stable

## Implementation Summary
1. Created `~/.gua/setup.sh` - Interactive setup wizard with:
   - Dependency checking (jq, aws, uuidgen)
   - AWS credential verification
   - User identity configuration
   - Device registration
   - S3 bucket creation/verification
   - DynamoDB table creation/verification
   - Config file generation

2. Added `gua init` command - Launches setup wizard

3. Added `gua whoami` command - Shows:
   - User ID
   - Device ID and name
   - AWS region and S3 bucket
   - Config version and creation date
   - Active session info

4. Added `gua auth verify` command - Checks:
   - Config file existence
   - AWS credentials validity
   - S3 bucket accessibility
   - DynamoDB table accessibility

## PP Dimension Focus
- **Primary**: JUSTICE (correct user/device identification)
- **Secondary**: TRUTH (accurate credential verification)
