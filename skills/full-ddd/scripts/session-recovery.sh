#!/bin/bash
# Session recovery: report current DDD workflow state.
# Run at the start of a new session to determine where to resume.

PROGRESS="docs/ddd/ddd-progress.md"

if [ ! -f "$PROGRESS" ]; then
  echo "[DDD-INFO] No existing DDD workflow found. Start fresh with Phase 1."
  exit 0
fi

echo "=== DDD Session Recovery ==="
echo ""
echo "Progress file: $PROGRESS"
echo ""
echo "--- Phase Status ---"
grep -E "^### Phase|Status:|Approved" "$PROGRESS" 2>/dev/null
echo ""
echo "--- Persisted Artifacts ---"
for f in docs/ddd/phase-1-domain-events.md docs/ddd/phase-2-context-map.md docs/ddd/phase-3-contracts.md docs/ddd/phase-4-technical-solution.md docs/ddd/decisions-log.md; do
  if [ -f "$f" ]; then
    echo "  [EXISTS] $f ($(wc -l < "$f") lines)"
  else
    echo "  [MISSING] $f"
  fi
done
echo ""
echo "Action: Read all existing artifacts, then resume from the first incomplete phase."
