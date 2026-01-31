#!/bin/bash

# PP Experiment Assessment Script
# Usage: ./assess.sh <task_id> <condition: control|pp>

TASK_ID=$1
CONDITION=$2
RESULTS_DIR="$HOME/.claude/purpose_prompter/experiments/results"

if [ -z "$TASK_ID" ] || [ -z "$CONDITION" ]; then
    echo "Usage: ./assess.sh <task_id> <condition: control|pp>"
    exit 1
fi

echo "=== PP Experiment Assessment ==="
echo "Task: $TASK_ID"
echo "Condition: $CONDITION"
echo ""

# Create results file
RESULT_FILE="$RESULTS_DIR/${TASK_ID}_${CONDITION}.json"
mkdir -p "$RESULTS_DIR"

# 1. Git stats
echo "=== Git Statistics ==="
FILES_CHANGED=$(git diff --name-only HEAD~1 | wc -l | tr -d ' ')
LINES_ADDED=$(git diff --numstat HEAD~1 | awk '{sum+=$1} END {print sum}')
LINES_REMOVED=$(git diff --numstat HEAD~1 | awk '{sum+=$2} END {print sum}')

echo "Files changed: $FILES_CHANGED"
echo "Lines added: $LINES_ADDED"
echo "Lines removed: $LINES_REMOVED"

# 2. Lint check (if eslint/tsc/ruff available)
echo ""
echo "=== Lint Check ==="
LINT_ERRORS=0

if command -v eslint &> /dev/null; then
    LINT_ERRORS=$(eslint . --format compact 2>/dev/null | grep -c "Error" || echo "0")
    echo "ESLint errors: $LINT_ERRORS"
elif command -v tsc &> /dev/null; then
    LINT_ERRORS=$(tsc --noEmit 2>&1 | grep -c "error" || echo "0")
    echo "TypeScript errors: $LINT_ERRORS"
elif command -v ruff &> /dev/null; then
    LINT_ERRORS=$(ruff check . 2>/dev/null | grep -c "error" || echo "0")
    echo "Ruff errors: $LINT_ERRORS"
else
    echo "No linter found (eslint/tsc/ruff)"
    LINT_ERRORS="N/A"
fi

# 3. Test check (if test command available)
echo ""
echo "=== Test Check ==="
TESTS_PASS="unknown"

if [ -f "package.json" ] && grep -q '"test"' package.json; then
    npm test &> /tmp/test_output.txt
    if [ $? -eq 0 ]; then
        TESTS_PASS="pass"
    else
        TESTS_PASS="fail"
    fi
    echo "Tests: $TESTS_PASS"
elif [ -f "pytest.ini" ] || [ -f "setup.py" ]; then
    pytest &> /tmp/test_output.txt
    if [ $? -eq 0 ]; then
        TESTS_PASS="pass"
    else
        TESTS_PASS="fail"
    fi
    echo "Tests: $TESTS_PASS"
else
    echo "No test runner found"
fi

# 4. Citation check (grep for file:line patterns in git log)
echo ""
echo "=== Citation Check ==="
# This is a proxy - check if the commit message or diff comments have file:line refs
CITATION_COUNT=$(git log -1 --format="%B" | grep -cE "[a-zA-Z_]+\.(ts|js|py|md):[0-9]+" || echo "0")
echo "Citations in commit: $CITATION_COUNT"

# 5. Save results as JSON
cat > "$RESULT_FILE" << EOF
{
  "task_id": "$TASK_ID",
  "condition": "$CONDITION",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "automated_metrics": {
    "files_changed": $FILES_CHANGED,
    "lines_added": ${LINES_ADDED:-0},
    "lines_removed": ${LINES_REMOVED:-0},
    "lint_errors": "$LINT_ERRORS",
    "tests_pass": "$TESTS_PASS",
    "citation_count": $CITATION_COUNT
  },
  "manual_scores": {
    "truth": null,
    "understanding": null,
    "beauty": null,
    "justice": null,
    "creativity": null,
    "task_success": null
  },
  "notes": ""
}
EOF

echo ""
echo "=== Results saved to: $RESULT_FILE ==="
echo ""
echo "Next steps:"
echo "1. Review the diff: git diff HEAD~1"
echo "2. Score manually using rubrics"
echo "3. Update $RESULT_FILE with manual scores"
