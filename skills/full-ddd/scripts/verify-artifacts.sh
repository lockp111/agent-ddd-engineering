#!/bin/bash
# Stop hook: verify all approved phases have persisted artifacts.
# Runs when the agent is about to end its turn.

PROGRESS="docs/ddd/ddd-progress.md"
[ ! -f "$PROGRESS" ] && exit 0

MISSING=0

check() {
  local phase=$1 file=$2
  if grep -q "Phase $phase.*complete" "$PROGRESS" && [ ! -f "$file" ]; then
    echo "[DDD-ERROR] Phase $phase is complete but $file is missing!"
    MISSING=$((MISSING + 1))
  fi
}

check 1 "docs/ddd/phase-1-domain-events.md"
check 2 "docs/ddd/phase-2-context-map.md"
check 3 "docs/ddd/phase-3-contracts.md"
check 4 "docs/ddd/phase-4-technical-solution.md"

if [ "$MISSING" -gt 0 ]; then
  echo "[DDD-ERROR] $MISSING artifact(s) missing for completed phases. Do NOT end session without persisting."
fi
