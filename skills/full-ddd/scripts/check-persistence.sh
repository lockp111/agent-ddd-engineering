#!/bin/bash
# PostToolUse hook: warn if approved phases lack artifact files.
# Runs after every Write|Edit to catch missing persistence.

PROGRESS="docs/ddd/ddd-progress.md"
[ ! -f "$PROGRESS" ] && exit 0

# Minimum viable artifact: more than 3 lines (stubs/empty writes are ≤3 lines)
MIN_LINES=3

check_phase() {
  local phase_num=$1 artifact=$2
  if grep -q "Phase $phase_num.*complete" "$PROGRESS"; then
    if [ ! -f "$artifact" ]; then
      echo "[DDD-WARN] Phase $phase_num is complete but $artifact is missing. Persist before proceeding."
    elif [ "$(wc -l < "$artifact")" -le "$MIN_LINES" ]; then
      echo "[DDD-WARN] Phase $phase_num artifact $artifact exists but appears empty (≤${MIN_LINES} lines). Verify content."
    fi
  fi
}

check_phase 1 "docs/ddd/phase-1-domain-events.md"
check_phase 2 "docs/ddd/phase-2-context-map.md"
check_phase 3 "docs/ddd/phase-3-contracts.md"
check_phase 4 "docs/ddd/phase-4-technical-solution.md"

# SDD check: spec-manifest.md
if grep -q "SDD.*complete\|sdd.*complete\|spec-driven.*complete" "$PROGRESS" 2>/dev/null; then
  if [ ! -f "docs/ddd/spec-manifest.md" ]; then
    echo "[DDD-WARN] SDD is complete but docs/ddd/spec-manifest.md is missing. Persist before proceeding."
  elif [ "$(wc -l < "docs/ddd/spec-manifest.md")" -le "$MIN_LINES" ]; then
    echo "[DDD-WARN] SDD artifact docs/ddd/spec-manifest.md exists but appears empty (≤${MIN_LINES} lines). Verify content."
  fi
fi

# Pilot mode checks
if grep -q "Mode.*pilot" "$PROGRESS" 2>/dev/null; then
  check_step() {
    local step_num=$1 artifact=$2
    if grep -q "Step $step_num.*complete" "$PROGRESS"; then
      if [ ! -f "$artifact" ]; then
        echo "[DDD-WARN] Step $step_num is complete but $artifact is missing. Persist before proceeding."
      elif [ "$(wc -l < "$artifact")" -le "$MIN_LINES" ]; then
        echo "[DDD-WARN] Step $step_num artifact $artifact exists but appears empty (≤${MIN_LINES} lines). Verify content."
      fi
    fi
  }
  check_step 1 "docs/ddd/legacy-landscape.md"
  check_step 2 "docs/ddd/impact-analysis.md"
  check_step 3 "docs/ddd/boundary-proposal.md"
fi

# Iterate mode checks
if grep -q "Mode.*iterate" "$PROGRESS" 2>/dev/null; then
  if grep -q "Step 2.*complete" "$PROGRESS"; then
    if [ ! -f "docs/ddd/route-plan.md" ]; then
      echo "[DDD-WARN] Step 2 is complete but docs/ddd/route-plan.md is missing. Persist before proceeding."
    elif [ "$(wc -l < "docs/ddd/route-plan.md")" -le "$MIN_LINES" ]; then
      echo "[DDD-WARN] Step 2 artifact docs/ddd/route-plan.md exists but appears empty (≤${MIN_LINES} lines). Verify content."
    fi
  fi
fi

# Import mode checks
if grep -q "Mode.*import" "$PROGRESS" 2>/dev/null; then
  if [ ! -f "docs/ddd/import-source.md" ]; then
    echo "[DDD-WARN] Import mode active but docs/ddd/import-source.md is missing. Persist source before proceeding."
  elif [ "$(wc -l < "docs/ddd/import-source.md")" -le "$MIN_LINES" ]; then
    echo "[DDD-WARN] Import source docs/ddd/import-source.md exists but appears empty (≤${MIN_LINES} lines). Verify content."
  fi
fi
