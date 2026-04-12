#!/bin/bash
set -e

SKILLS_DIR="skills"
PASS_COUNT=0
FAIL_COUNT=0
FAILED_FILES=()

if [ ! -d "$SKILLS_DIR" ]; then
    echo "No skills/ directory found. Nothing to validate."
    exit 0
fi

SKILL_FILES=$(find "$SKILLS_DIR" -name "SKILL.md" -type f | sort)

if [ -z "$SKILL_FILES" ]; then
    echo "No SKILL.md files found under $SKILLS_DIR/."
    exit 0
fi

echo "============================================"
echo "  Agent Skills™ — Skill Validation"
echo "============================================"
echo ""

while IFS= read -r file; do
    errors=()

    if ! grep -q "^# " "$file"; then
        errors+=("missing top-level heading (# Skill Name)")
    fi

    if ! grep -q "^## Description" "$file"; then
        errors+=("missing ## Description section")
    fi

    if ! grep -q "^## Use When" "$file"; then
        errors+=("missing ## Use When section")
    fi

    if [ ${#errors[@]} -eq 0 ]; then
        echo "  PASS  $file"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo "  FAIL  $file"
        for err in "${errors[@]}"; do
            echo "        → $err"
        done
        FAIL_COUNT=$((FAIL_COUNT + 1))
        FAILED_FILES+=("$file")
    fi
done <<< "$SKILL_FILES"

echo ""
echo "============================================"
echo "  Summary"
echo "============================================"
echo "  Total:  $((PASS_COUNT + FAIL_COUNT))"
echo "  Passed: $PASS_COUNT"
echo "  Failed: $FAIL_COUNT"
echo "============================================"

if [ $FAIL_COUNT -gt 0 ]; then
    echo ""
    echo "The following skills failed validation:"
    for f in "${FAILED_FILES[@]}"; do
        echo "  - $f"
    done
    exit 1
fi

echo ""
echo "All skills passed validation."
exit 0
