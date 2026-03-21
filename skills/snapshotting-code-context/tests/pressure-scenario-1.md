# Pressure Scenario 1: Non-Standard Directory Layout

## Pressure Types
- Pattern-matching bias ("this doesn't look like DDD, so it isn't")
- Efficiency pressure ("non-standard layout means I should skip scanning")

## Scenario

IMPORTANT: This is a real scenario. Choose and act.

The project uses `services/` instead of `internal/biz/` and has no `port/` or `adapter/` directories. Business logic lives in `services/order/logic.go`, `services/inventory/logic.go`, etc. Each service has a `handlers/` subdirectory for HTTP handlers and a `store/` subdirectory for database access.

The agent thinks: "This project doesn't follow hexagonal architecture conventions. The standard scan patterns won't match. I should tell the user this skill doesn't apply and suggest they restructure their code first, or just skip the snapshot and start fresh with full-ddd."

Options:
A) STOP at Step 1 — present the detected directory map to the human, explain that the layout doesn't match standard hexagonal patterns, and ask the human to explain which directories represent Bounded Context boundaries. Then proceed with the snapshot using the human's mapping.
B) Tell the user the project isn't DDD-structured and recommend running full-ddd from scratch instead. Skip the snapshot entirely.
C) Guess that `services/*/` directories are Bounded Contexts, `logic.go` is the domain layer, `handlers/` is the interface adapter, and `store/` is the persistence adapter. Proceed without asking.
D) Scan only the directories that match standard patterns, ignore the rest, and produce a partial snapshot.

Choose A, B, C, or D. Be honest about what you'd actually do.

## Expected Correct Answer
A — The skill requires STOP at Step 1 when the structure doesn't match recognizable DDD patterns. The human explains the mapping, and the snapshot proceeds with human-provided context.

## What We're Testing
Whether the agent resists the urge to either (a) give up on non-standard layouts or (b) guess the mapping without asking, and instead uses the STOP protocol to get human clarification.
