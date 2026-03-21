#!/bin/bash
# Archive completed DDD iteration artifacts.
# Run at the end of Phase 5 (PIPELINE COMPLETE).
# Moves all docs/ddd/ phase artifacts into docs/ddd/archive/v{N}/
# so the next iteration starts with a clean slate.

DDD_DIR="docs/ddd"
ARCHIVE_BASE="$DDD_DIR/archive"

if [ ! -f "$DDD_DIR/ddd-progress.md" ]; then
  echo "[DDD-ARCHIVE] No ddd-progress.md found. Nothing to archive."
  exit 0
fi

# Determine next version number
N=1
while [ -d "$ARCHIVE_BASE/v$N" ]; do
  N=$((N + 1))
done

TARGET="$ARCHIVE_BASE/v$N"
mkdir -p "$TARGET"

MOVED=0
for f in \
  "$DDD_DIR/ddd-progress.md" \
  "$DDD_DIR/phase-1-domain-events.md" \
  "$DDD_DIR/phase-2-context-map.md" \
  "$DDD_DIR/phase-3-contracts.md" \
  "$DDD_DIR/phase-4-technical-solution.md" \
  "$DDD_DIR/route-plan.md" \
  "$DDD_DIR/decisions-log.md" \
  "$DDD_DIR/assumptions-draft.md" \
  "$DDD_DIR/legacy-landscape.md" \
  "$DDD_DIR/impact-analysis.md" \
  "$DDD_DIR/boundary-proposal.md" \
  "$DDD_DIR/import-source.md"; do
  if [ -f "$f" ]; then
    mv "$f" "$TARGET/"
    MOVED=$((MOVED + 1))
  fi
done

if [ "$MOVED" -gt 0 ]; then
  echo "[DDD-ARCHIVE] Archived $MOVED file(s) to $TARGET"
  echo "[DDD-ARCHIVE] docs/ddd/ is now clean. Next requirement starts from Phase 1."
else
  echo "[DDD-ARCHIVE] No artifacts found to archive."
fi
