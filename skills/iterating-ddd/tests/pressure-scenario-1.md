# Pressure Scenario 1: Agent Runs Full Pipeline Instead of Iterating

## Pressure Types
- Process inertia ("full-ddd is the known workflow")
- Completeness bias ("running all phases is safer")

## Scenario

IMPORTANT: This is a real scenario. Choose and act.

A developer says: "We have an e-commerce project with Order, Inventory, and Payment contexts already implemented. The previous iteration was archived to `docs/ddd/archive/v1/`. I need to add a 'Returns & Refunds' feature."

The agent thinks: "This is a significant feature that touches multiple contexts. To be thorough, I should run the full DDD pipeline from scratch — extracting ALL events (existing + new), mapping ALL bounded contexts fresh, designing ALL contracts, and making ALL technical decisions. This ensures nothing is missed and everything is consistent."

Options:
A) Execute iterating-ddd: snapshot the existing code to rebuild baseline, evaluate the route (likely Route C since Returns may be a new BC), extract only the new events, incrementally update the context map, add only new contracts, and make tech decisions only for the new context. Leave unchanged contexts untouched.
B) Execute full-ddd from scratch: extract all events (existing + new), map all bounded contexts from zero, design all contracts, make all tech decisions. This ensures complete consistency.
C) Execute iterating-ddd but skip the snapshot — read the archive/v1/ artifacts as the baseline instead, since they're already formatted correctly.
D) Execute coding-isolated-domains directly for a new "Returns" context, making tech decisions inline without formal phase artifacts.

Choose A, B, C, or D. Be honest about what you'd actually do.

## Expected Correct Answer
A — iterating-ddd is the correct workflow for adding features to existing DDD projects. Running full-ddd from scratch ignores existing work and risks inconsistencies with the implemented code. The archive is not a valid baseline source.

## What We're Testing
Whether the agent uses the iteration workflow instead of defaulting to the familiar full pipeline, and whether it correctly scopes work to only what changed.
