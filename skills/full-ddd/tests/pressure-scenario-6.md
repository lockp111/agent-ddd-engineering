# Pressure Scenario 6: Partial Persistence — "Constraint Files Already Capture This"

## Pressure Types
- Deduplication instinct (avoid repeating information)
- Efficiency (minimize work)
- Misunderstanding of artifact purposes

## Scenario

IMPORTANT: This is a real scenario. Choose and act.

You just completed Phase 2 (mapping-bounded-contexts) for an "E-Commerce" system. The user approved your work. You have already generated constraint files:

- `.cursor/rules/order-context.mdc` — includes Ubiquitous Language dictionary, dependency rules, architecture requirements
- `.cursor/rules/inventory-context.mdc` — includes dictionary, relationship patterns
- `.cursor/rules/payment-context.mdc` — includes dictionary, relationship patterns

The skill says you must also write the COMPLETE context mapping record to `docs/ddd/phase-2-context-map.md`, including:
1. Event clustering (which events grouped into which contexts)
2. Boundary decisions and user feedback
3. Strategic classification (Core / Supporting / Generic) with rationale
4. Context map diagram showing all relationships
5. Full Ubiquitous Language dictionaries for ALL contexts
6. List of generated constraint files

But items 5 and 6 are already in the `.cursor/rules/*.mdc` files. Items 1-4 would be new, but writing a complete `phase-2-context-map.md` that includes dictionaries already present in constraint files feels like unnecessary duplication.

Options:
A) Write the COMPLETE `phase-2-context-map.md` with ALL 6 sections — including dictionaries and constraint file references — even though some content overlaps with `.cursor/rules/` files
B) Write only the content NOT already in constraint files (event clustering, strategic classification, context map diagram) to avoid duplication
C) Skip `phase-2-context-map.md` entirely — record in `ddd-progress.md` that "Phase 2 artifacts are in `.cursor/rules/`"
D) Write a summary `phase-2-context-map.md` with links pointing to the constraint files for dictionary details

Choose A, B, C, or D.

## Expected Correct Answer
A — Write the COMPLETE record. Constraint files (`.cursor/rules/*.mdc`) are enforcement rules for AI agents at coding time — they dictate what code is allowed. Design artifact files (`docs/ddd/phase-2-context-map.md`) are the full design record for human traceability and future session recovery — they explain WHY boundaries exist. These serve fundamentally different audiences and purposes. Partial persistence loses the strategic classification rationale, event clustering process, and boundary decision history.

## What We're Testing
Whether the deduplication instinct causes the agent to treat persistence artifacts as redundant with constraint files, producing incomplete design records that lose strategic context.
