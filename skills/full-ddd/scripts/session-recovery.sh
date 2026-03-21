#!/bin/bash
# Session recovery: report current DDD workflow state.
# Run at the start of a new session to determine where to resume.

PROGRESS="docs/ddd/ddd-progress.md"

if [ ! -f "$PROGRESS" ]; then
  echo "[DDD-INFO] No active DDD workflow found. Start fresh with Phase 1."
  if [ -d "docs/ddd/archive" ]; then
    echo "[DDD-INFO] Prior iterations archived at docs/ddd/archive/ (human reference only — do NOT read these as current context):"
    ls -v docs/ddd/archive/ 2>/dev/null | sed 's/^/  /'
  fi
  exit 0
fi

echo "=== DDD Session Recovery ==="
echo ""
echo "Progress file: $PROGRESS"
echo ""
echo "--- Workflow Mode ---"
MODE=$(grep "Mode:" "$PROGRESS" 2>/dev/null | head -1 | sed 's/.*Mode.*: *//')
echo "  Mode: ${MODE:-unknown}"
echo ""

if echo "$MODE" | grep -qi "pilot"; then
  echo "--- Step Status (Pilot) ---"
  grep -E "^### Step|Status:|Approved|MODIFY|HOOK|Scope" "$PROGRESS" 2>/dev/null
  echo ""
  echo "--- Persisted Artifacts ---"
  for f in docs/ddd/legacy-landscape.md docs/ddd/impact-analysis.md docs/ddd/boundary-proposal.md docs/ddd/phase-1-domain-events.md docs/ddd/phase-2-context-map.md docs/ddd/phase-3-contracts.md docs/ddd/phase-4-technical-solution.md docs/ddd/decisions-log.md; do
    if [ -f "$f" ]; then
      echo "  [EXISTS] $f ($(wc -l < "$f") lines)"
    else
      echo "  [MISSING] $f"
    fi
  done
  echo ""
  echo "Action: Read all existing artifacts, then resume from the first incomplete step."
elif echo "$MODE" | grep -qi "iterate"; then
  echo "--- Step Status (Iterate) ---"
  grep -E "^### Step|Status:|Approved|Route" "$PROGRESS" 2>/dev/null
  echo ""
  echo "--- Persisted Artifacts ---"
  for f in docs/ddd/route-plan.md docs/ddd/phase-1-domain-events.md docs/ddd/phase-2-context-map.md docs/ddd/phase-3-contracts.md docs/ddd/phase-4-technical-solution.md docs/ddd/spec-manifest.md docs/ddd/decisions-log.md; do
    if [ -f "$f" ]; then
      echo "  [EXISTS] $f ($(wc -l < "$f") lines)"
    else
      echo "  [MISSING] $f"
    fi
  done
  echo ""
  echo "Action: Read all existing artifacts, then resume from the first incomplete step."
elif echo "$MODE" | grep -qi "import"; then
  echo "--- Step Status (Import) ---"
  grep -E "^### Step|Status:|Approved|Dimension|COVERED|PARTIAL|MISSING" "$PROGRESS" 2>/dev/null
  echo ""
  echo "--- Persisted Artifacts ---"
  for f in docs/ddd/import-source.md docs/ddd/phase-1-domain-events.md docs/ddd/phase-2-context-map.md docs/ddd/phase-3-contracts.md docs/ddd/phase-4-technical-solution.md docs/ddd/decisions-log.md docs/ddd/assumptions-draft.md; do
    if [ -f "$f" ]; then
      echo "  [EXISTS] $f ($(wc -l < "$f") lines)"
    else
      echo "  [MISSING] $f"
    fi
  done
  echo ""
  echo "Action: Read all existing artifacts, then resume from the first incomplete step."
else
  echo "--- Phase Status ---"
  grep -E "^### Phase|^### Step|Status:|Approved" "$PROGRESS" 2>/dev/null
  echo ""
  echo "--- Persisted Artifacts ---"
  for f in docs/ddd/phase-1-domain-events.md docs/ddd/phase-2-context-map.md docs/ddd/phase-3-contracts.md docs/ddd/phase-4-technical-solution.md docs/ddd/spec-manifest.md docs/ddd/decisions-log.md; do
    if [ -f "$f" ]; then
      echo "  [EXISTS] $f ($(wc -l < "$f") lines)"
    else
      echo "  [MISSING] $f"
    fi
  done
  if [ -d "specs" ]; then
    SPEC_COUNT=$(find specs -name "*.proto" -o -name "*.yaml" -o -name "*.json" 2>/dev/null | wc -l | tr -d ' ')
    echo "  [EXISTS] specs/ ($SPEC_COUNT spec files)"
  else
    echo "  [MISSING] specs/"
  fi
  echo ""
  echo "Action: Read all existing artifacts, then resume from the first incomplete phase."
fi
