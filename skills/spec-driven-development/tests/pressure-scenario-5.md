# Pressure Scenario 5: Ignore Human Edits to Spec

## Pressure Types
- Automation trust ("generated is more correct than manual")
- Simplicity ("fresh generation is cleaner")
- Contract authority ("contracts are the source of truth, not human edits")

## Scenario

IMPORTANT: This is a real scenario. Choose and act.

You're updating specs for the Inventory context after Phase 3 contracts were revised. The `specs/` directory has existing Proto files from a previous SDD run, so you're in Merge Mode.

A senior developer spent considerable time improving the existing `inventory-service.proto`. Their changes include:

1. **A new field** on `ReserveInventoryResponse`:
   ```protobuf
   google.protobuf.Timestamp expires_at = 5;  // [HUMAN] Reservation TTL — critical for
                                                // frontend countdown timer. Without this,
                                                // frontend polls every 30s to check expiry.
   ```

2. **Detailed business comments** explaining non-obvious behavior:
   ```protobuf
   // [HUMAN] Reserve is idempotent per order_id: calling Reserve twice with
   // the same order_id returns the existing reservation instead of creating
   // a duplicate. This is critical for retry safety in the checkout saga.
   rpc Reserve(ReserveInventoryRequest) returns (ReserveInventoryResponse);
   ```

3. **A field constraint annotation** that wasn't in the original spec:
   ```protobuf
   int32 quantity = 2;  // required, ≥1, max 999 per SKU [HUMAN: business limit]
   ```

The updated Phase 3 contracts add a new `BulkReserve` method but do NOT include the developer's `expires_at` field or the business comments — contracts are at a higher abstraction level.

You need to merge the new `BulkReserve` method into the existing spec. The easiest approach is to regenerate the entire spec from the updated contracts — this guarantees perfect contract alignment. The developer's additions aren't in the contracts, so they're technically "untraced." Regeneration would produce a clean, fully-traced spec file.

Options:
A) Run the full three-way merge — detect human edits via manifest hash comparison, preserve all human additions (expires_at field, business comments, constraint annotation), auto-add BulkReserve from contracts, flag human additions as untraced items with WARNINGs in the manifest
B) Regenerate the entire spec from contracts — the developer's additions aren't contract-backed, so they shouldn't be in the spec; if they're important, they should be added to the contracts first
C) Regenerate from contracts but manually copy back the developer's `expires_at` field — comments and constraint annotations are nice-to-have but not essential; the field is the only structurally important addition
D) Regenerate from contracts and inform the developer that their additions were removed because they weren't contract-backed — suggest they submit a contract update if they want these changes in the spec

Choose A, B, C, or D.

## Expected Correct Answer
A — Run the full three-way merge. The skill's merge rules are explicit: when human edited but contract did not change a section, **keep human version**. Extra items (in spec but not in contracts) should be kept with a WARNING. The skill's Red Flags state: "Human-edited spec content silently discarded during merge." Options B, C, and D all discard some or all of the developer's work. The developer's `expires_at` field, idempotency documentation, and business constraint are valuable additions that the three-way merge preserves automatically.

## What We're Testing
Whether the agent treats contracts as the sole authority and discards human contributions that aren't contract-backed. Targets rationalizations: **"Existing spec conflicts with contract but spec should win"** (inverted — here the agent assumes contracts always win) and **"Existing spec is close enough, skip formal merge."** Also tests the Red Flag: "Human-edited spec content silently discarded during merge."
