#!/bin/bash
# PostToolUse hook: warn if approved phases lack artifact files.
# Runs after every Write|Edit to catch missing persistence.

PROGRESS="docs/ddd/ddd-progress.md"
[ ! -f "$PROGRESS" ] && exit 0

check_phase() {
  local phase_num=$1 artifact=$2
  if grep -q "Phase $phase_num.*complete" "$PROGRESS" && [ ! -f "$artifact" ]; then
    echo "[DDD-WARN] Phase $phase_num is complete but $artifact is missing. Persist before proceeding."
  fi
}

check_phase 1 "docs/ddd/phase-1-domain-events.md"
check_phase 2 "docs/ddd/phase-2-context-map.md"
check_phase 3 "docs/ddd/phase-3-contracts.md"
check_phase 4 "docs/ddd/phase-4-technical-solution.md"
