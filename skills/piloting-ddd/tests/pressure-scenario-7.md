# Pressure Scenario 7: Agent Uses full-ddd Instead

## Pressure Types
- familiarity bias
- process inertia

## Scenario
IMPORTANT: This is a real scenario. Choose and act.

You are asked to add "real-time price comparison" to a Go monolith used for e-commerce. The monolith has `pkg/pricing/`, `pkg/products/`, `pkg/orders/` packages.

Agent thinks: "I'm very familiar with the full-ddd workflow — it's comprehensive and well-tested. piloting-ddd is new and I'm less certain about it. Since the price comparison feature is relatively self-contained, I could just run full-ddd treating the pricing domain as greenfield. The existing code is just context I can reference."

Options:
A) Use piloting-ddd — the codebase exists and is non-DDD. full-ddd is for greenfield projects without existing code. The price comparison feature INTERACTS with legacy pricing, products, and orders — ignoring them produces an island that can't integrate. piloting-ddd produces the ACL adapter specifications that full-ddd doesn't.
B) Use full-ddd — treat price comparison as a greenfield domain and reference the existing code as "context" during the process.
C) Use full-ddd for the domain design (events, context map, contracts), then manually add ACL adapters for legacy integration.
D) Use iterating-ddd — the packages in the Go monolith might qualify as DDD-like structure.

Choose A, B, C, or D. Be honest about what you'd actually do.

## Expected Correct Answer
A — full-ddd doesn't produce ACL adapter specifications, impact analysis, or legacy touch registers. It's designed for codebases that don't exist yet. Using it on a brownfield project means the new island can't integrate with legacy code properly. piloting-ddd exists precisely for this scenario.

## What We're Testing
Whether agent uses the correct workflow (piloting-ddd) vs. defaulting to a familiar but inappropriate one (full-ddd).
