# Domain Architecture Reference

## Overview

This reference defines the architecture and domain modeling constraints that MUST be checked during domain code implementation. Referenced by TDD's GREEN step (real-time enforcement during coding) and by `coding-isolated-domains` (as the authoritative source for its red line rules).

Violating any constraint below means the code is building on a contaminated foundation. Every subsequent test compounds the problem. Fix violations immediately — do not defer.

## Architecture Constraints

These enforce the hexagonal architecture boundary between domain and infrastructure.

| Red Line | Check Method | Why It Matters |
|:---|:---|:---|
| Domain layer has no infrastructure dependencies | Import paths do not contain infra/adapter/repository implementation packages | Infrastructure imports in domain create compile-time coupling that prevents domain portability and independent testing |
| Domain structs have no ORM/JSON tags | No `gorm:`, `json:`, `bson:`, `xml:` tags on domain entity or value object fields | Tags couple the domain to serialization format; use separate DTOs in the adapter layer |
| No cross-aggregate direct imports | Import paths do not reference other aggregates' internal packages | Cross-aggregate imports bypass consistency boundaries; communicate through ports or domain events |
| Business logic lives in entities, not services | Entity methods contain state-change logic and invariant enforcement | Logic in services creates anemic models; entities that only hold data are data bags, not domain objects |
| Ports are interfaces, not implementations | `port/` or `ports/` directory contains only interface definitions, no concrete types | Concrete types in ports couple domain to specific implementations |

## Domain Modeling Constraints

These enforce Domain-Driven Design modeling discipline.

| Red Line | Check Method | Why It Matters |
|:---|:---|:---|
| Value objects are immutable | No setter methods, no mutation after construction; all fields set via constructor | Mutable value objects break equality semantics and create subtle aliasing bugs |
| No public setters on entities | Entities expose command methods (`PlaceOrder`, `CancelOrder`), not `SetStatus()` | Public setters bypass invariant enforcement; command methods encode business intent |
| Domain events named in past tense | `OrderCreated`, `PaymentProcessed`, not `CreateOrder`, `ProcessPayment` | Events represent facts that happened; imperative names confuse commands with events |
| Aggregates reference other aggregates by ID only | Aggregate fields hold IDs (e.g., `CustomerID string`), never instances of other aggregates | Instance references create implicit consistency boundaries that cross aggregate boundaries |

## Violation Response

When a red line violation is detected during TDD's GREEN step:

1. **STOP** — do not continue to REFACTOR
2. **Delete** the violating code
3. **Re-enter GREEN** — rewrite the implementation without the violation
4. If the violation cannot be avoided without the current approach, **escalate** — this may indicate the spec or domain model needs revision

Do not rationalize: "I'll fix it in REFACTOR." Architecture violations in GREEN contaminate the test baseline. REFACTOR assumes a clean GREEN.

## Extraction Boundary

This file contains the **checklist-form red lines** extracted from `coding-isolated-domains`. The following content remains in `coding-isolated-domains/SKILL.md`:

- Narrative implementation steps (the guided process for setting up hexagonal architecture)
- Code examples (Go examples of correct vs incorrect patterns)
- Eric Evans 4 rules of aggregate design explanation
- Interactive session guidance for domain modeling decisions
