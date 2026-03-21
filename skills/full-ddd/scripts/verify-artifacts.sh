#!/bin/bash
# Stop hook: verify all approved phases have persisted artifacts.
# Runs when the agent is about to end its turn.

PROGRESS="docs/ddd/ddd-progress.md"
[ ! -f "$PROGRESS" ] && exit 0

MISSING=0

# Minimum viable artifact: more than 3 lines (stubs/empty writes are ≤3 lines)
MIN_LINES=3

check() {
  local phase=$1 file=$2
  if grep -q "Phase $phase.*complete" "$PROGRESS"; then
    if [ ! -f "$file" ]; then
      echo "[DDD-ERROR] Phase $phase is complete but $file is missing!"
      MISSING=$((MISSING + 1))
    elif [ "$(wc -l < "$file")" -le "$MIN_LINES" ]; then
      echo "[DDD-ERROR] Phase $phase artifact $file exists but appears empty (≤${MIN_LINES} lines)!"
      MISSING=$((MISSING + 1))
    fi
  fi
}

check 1 "docs/ddd/phase-1-domain-events.md"
check 2 "docs/ddd/phase-2-context-map.md"
check 3 "docs/ddd/phase-3-contracts.md"
check 4 "docs/ddd/phase-4-technical-solution.md"

# SDD check: spec-manifest.md
if grep -q "SDD.*complete\|sdd.*complete\|spec-driven.*complete" "$PROGRESS" 2>/dev/null; then
  if [ ! -f "docs/ddd/spec-manifest.md" ]; then
    echo "[DDD-ERROR] SDD is complete but docs/ddd/spec-manifest.md is missing!"
    MISSING=$((MISSING + 1))
  elif [ "$(wc -l < "docs/ddd/spec-manifest.md")" -le "$MIN_LINES" ]; then
    echo "[DDD-ERROR] SDD artifact docs/ddd/spec-manifest.md exists but appears empty (≤${MIN_LINES} lines)!"
    MISSING=$((MISSING + 1))
  fi
  if [ ! -d "specs" ] || [ -z "$(find specs -name '*.proto' -o -name '*.yaml' -o -name '*.json' 2>/dev/null | head -1)" ]; then
    echo "[DDD-ERROR] SDD is complete but specs/ directory is missing or empty!"
    MISSING=$((MISSING + 1))
  fi
fi

# Pilot mode checks: verify pilot-specific artifacts
if grep -q "Mode.*pilot" "$PROGRESS" 2>/dev/null; then
  check_pilot() {
    local step=$1 label=$2 file=$3
    if grep -q "Step $step.*complete" "$PROGRESS"; then
      if [ ! -f "$file" ]; then
        echo "[DDD-ERROR] Step $step ($label) is complete but $file is missing!"
        MISSING=$((MISSING + 1))
      elif [ "$(wc -l < "$file")" -le "$MIN_LINES" ]; then
        echo "[DDD-ERROR] Step $step ($label) artifact $file exists but appears empty (≤${MIN_LINES} lines)!"
        MISSING=$((MISSING + 1))
      fi
    fi
  }
  check_pilot 1 "landscape" "docs/ddd/legacy-landscape.md"
  check_pilot 2 "impact" "docs/ddd/impact-analysis.md"
  check_pilot 3 "boundary" "docs/ddd/boundary-proposal.md"
fi

# Iterate mode checks
if grep -q "Mode.*iterate" "$PROGRESS" 2>/dev/null; then
  if grep -q "Step 2.*complete" "$PROGRESS"; then
    if [ ! -f "docs/ddd/route-plan.md" ]; then
      echo "[DDD-ERROR] Step 2 (route plan) is complete but docs/ddd/route-plan.md is missing!"
      MISSING=$((MISSING + 1))
    elif [ "$(wc -l < "docs/ddd/route-plan.md")" -le "$MIN_LINES" ]; then
      echo "[DDD-ERROR] Step 2 (route plan) artifact docs/ddd/route-plan.md exists but appears empty (≤${MIN_LINES} lines)!"
      MISSING=$((MISSING + 1))
    fi
  fi
fi

# Import mode checks
if grep -q "Mode.*import" "$PROGRESS" 2>/dev/null; then
  if [ ! -f "docs/ddd/import-source.md" ]; then
    echo "[DDD-ERROR] Import mode active but docs/ddd/import-source.md is missing!"
    MISSING=$((MISSING + 1))
  elif [ "$(wc -l < "docs/ddd/import-source.md")" -le "$MIN_LINES" ]; then
    echo "[DDD-ERROR] Import source docs/ddd/import-source.md exists but appears empty (≤${MIN_LINES} lines)!"
    MISSING=$((MISSING + 1))
  fi
fi

if [ "$MISSING" -gt 0 ]; then
  echo "[DDD-ERROR] $MISSING artifact(s) missing or empty for completed phases. Do NOT end session without persisting."
fi

if grep -q "Phase 5.*complete" "$PROGRESS" || grep -q "Step 10.*complete" "$PROGRESS"; then
  echo "[DDD-WARN] Pipeline is complete. Run archive-artifacts.sh to archive any remaining artifacts and clean docs/ddd/."
  echo "[DDD-WARN] Run: sh skills/full-ddd/scripts/archive-artifacts.sh"
fi
