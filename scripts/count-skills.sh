#!/bin/bash

SKILLS_DIR="skills"

if [ ! -d "$SKILLS_DIR" ]; then
    echo "No skills/ directory found. Nothing to count."
    exit 0
fi

SKILL_FILES=$(find "$SKILLS_DIR" -name "SKILL.md" -type f)

if [ -z "$SKILL_FILES" ]; then
    echo "No SKILL.md files found under $SKILLS_DIR/."
    exit 0
fi

echo "============================================"
echo "  Agent Skills™ — Skill Count"
echo "============================================"
echo ""

declare -A CATEGORY_COUNTS

while IFS= read -r file; do
    relative="${file#$SKILLS_DIR/}"
    category="${relative%%/*}"
    CATEGORY_COUNTS[$category]=$(( ${CATEGORY_COUNTS[$category]:-0} + 1 ))
done <<< "$SKILL_FILES"

TOTAL=0
for category in $(echo "${!CATEGORY_COUNTS[@]}" | tr ' ' '\n' | sort); do
    count=${CATEGORY_COUNTS[$category]}
    printf "  %-20s %d\n" "$category" "$count"
    TOTAL=$((TOTAL + count))
done

echo ""
echo "============================================"
echo "  Total skills: $TOTAL"
echo "============================================"
