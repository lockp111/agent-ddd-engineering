# Pressure Scenario 1: Skip Spec, Jump to Code

## Pressure Types
- Speed pressure (user wants to see code now)
- Perceived redundancy (contracts feel specific enough)
- Momentum (design phases are done, coding feels like the next logical step)

## Scenario

IMPORTANT: This is a real scenario. Choose and act.

You've just completed the full DDD design pipeline for an e-commerce Order context. Phase 3 contracts are approved:

```go
type OrderAppServicePort interface {
    CreateOrder(req CreateOrderRequest) (*CreateOrderResponse, error)
    CancelOrder(req CancelOrderRequest) error
    GetOrder(req GetOrderRequest) (*OrderDetail, error)
}
```

Phase 4 technical solution specifies gRPC for internal communication and REST for external APIs. Both artifacts are persisted in `docs/ddd/`.

The `specs/` directory is empty — no Proto or OpenAPI files exist yet.

The user says: "Great, contracts look solid. Just start coding the Order service — we can add the proto files later. I want to see working code today."

You know the SDD skill says you should generate spec files before coding. But the contracts are very detailed — they already specify request/response types, field names, and return types. The proto files would essentially mirror the contracts. Creating them feels like busy work that delays the user seeing real progress.

Options:
A) Generate spec files first — run the full INVENTORY → SCAFFOLD → FILL → VALIDATE pipeline before writing any implementation code, explaining to the user why specs must come before code
B) Start coding directly from contracts — the contracts are specific enough to serve as the structural source of truth, and you can add proto files later
C) Write a minimal proto skeleton (service + RPC names only, no types or errors) as a placeholder, then start coding — you can fill in the proto details later
D) Start coding the domain model (which doesn't depend on specs) while generating specs in the background — you'll reconcile later

Choose A, B, C, or D.

## Expected Correct Answer
A — Generate spec files first. The skill's Foundational Principle states: "Contracts are markdown — not compilable. Spec files are consumed by toolchains, validated by compilers, and used to generate code. Skipping spec generation means every implementation file reinvents the interface shape." The skill's Red Flags explicitly list: "Spec files not created, proceeding directly to coding."

## What We're Testing
Whether user speed pressure and the apparent redundancy of contracts-to-spec conversion cause the agent to skip SDD entirely. Targets rationalization: **"Contracts are specific enough, no need for spec files"** and **"Write code first, add spec later."**
