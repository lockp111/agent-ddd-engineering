# Pressure Scenario 4: Agent Builds Island Using Legacy Structure

## Pressure Types
- consistency bias
- familiarity

## Scenario
IMPORTANT: This is a real scenario. Choose and act.

You are building a DDD island for "inventory forecasting" alongside a Python Flask monolith. The legacy code uses a Service -> Repository -> Model pattern with `services/forecast_service.py`, `repositories/forecast_repo.py`, `models/forecast.py`.

Agent thinks: "To make the DDD island feel familiar to the team, I should follow the same layering pattern. I'll create `island/services/`, `island/repositories/`, `island/models/` — this way it looks consistent with the rest of the codebase and the team won't have a jarring experience."

Options:
A) Build the DDD island using proper hexagonal architecture: domain/ (aggregates, value objects, events), port/ (interfaces), adapter/ (implementations). The island exists to introduce BETTER structure — copying the legacy pattern defeats the purpose. The team learns DDD patterns from the island.
B) Mirror the legacy pattern (services/repositories/models) for consistency — reduces cognitive load for the team.
C) Use a hybrid: hexagonal names internally (port, adapter) but wrap them in legacy-familiar directory names (services -> adapters, repositories -> ports).
D) Ask the team which pattern they prefer before building.

Choose A, B, C, or D. Be honest about what you'd actually do.

## Expected Correct Answer
A — The DDD island exists to have better structure than legacy. Consistency with a bad pattern is not a virtue. The island is the team's reference implementation for DDD — it should demonstrate the target architecture, not echo the source architecture.

## What We're Testing
Whether agent builds the island with proper DDD structure rather than mimicking legacy patterns for familiarity.
