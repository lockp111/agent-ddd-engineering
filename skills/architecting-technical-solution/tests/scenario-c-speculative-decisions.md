# Scenario C: Speculative Decisions Without Domain Evidence

## RED Phase — Baseline (No Skill Loaded)

### Prompt Given

```
We have an Order context with basic CRUD-like events: OrderCreated, OrderUpdated, OrderDeleted.
The contracts define a simple OrderRepositoryPort.

Make the technical architecture decisions for this context.
```

### Agent Response (Paraphrased)

The agent produces an elaborate technical solution anticipating future needs:

> "For the Order context, I recommend:
> - **Redis caching layer** for frequently accessed orders to reduce database load
> - **Event sourcing** with an append-only event store for complete audit trail
> - **CQRS** with separate read/write models for query optimization
> - **Apache Kafka** for reliable event streaming between contexts
> - **Circuit breaker pattern** (Hystrix/Resilience4j) for all external service calls
> - **OpenTelemetry** with distributed tracing, custom metrics dashboards, and automated alerting
> - **API Gateway** with rate limiting and request throttling
>
> This architecture will scale well as the system grows."

### Specific Rationalization

**"A good architect anticipates future needs — better to over-prepare than under-prepare."**

The agent confuses architectural thoroughness with speculative complexity. It invents requirements that have no grounding in the domain events or contracts. Nothing in "OrderCreated, OrderUpdated, OrderDeleted" suggests the need for event sourcing, CQRS, or Kafka. The agent projects patterns it knows onto a domain that hasn't demonstrated the need for them.

### Violations

1. **Redis caching** — no domain evidence of high-read-frequency patterns; no performance requirements in the domain events or contracts
2. **Event sourcing** — basic CRUD events (Created/Updated/Deleted) are the opposite signal; event sourcing suits domains with complex state transitions, not simple entity lifecycle
3. **CQRS** — no evidence of divergent read/write patterns; the single `OrderRepositoryPort` suggests a unified model is sufficient
4. **Kafka** — no cross-context event streaming requirement in the contracts; the simple `OrderRepositoryPort` implies no async messaging needs
5. **Circuit breaker** — no external service calls documented in the contracts; the only port is a repository
6. **Decisions not traceable to domain artifacts** — none of these choices reference specific domain events, contracts, or bounded context relationships

### Why This Is Harmful

Speculative architecture is the most expensive form of waste. Each unnecessary component adds:
- **Operational complexity** — Redis, Kafka, and event stores require deployment, monitoring, and expertise
- **Development overhead** — CQRS doubles the model surface area; event sourcing requires projection logic
- **Cognitive load** — developers must understand why these patterns exist, and there's no domain justification to explain

Worse, speculative decisions are hard to remove. Once Kafka is in the architecture diagram, removing it feels like "regression." The sunk cost fallacy protects unnecessary complexity.

The Dimension Challenge exists precisely to catch this: "Are these decisions grounded in domain events and contracts, or speculative?" Every decision in this scenario fails that test.

---

## GREEN Phase — Compliance (With Skill Loaded)

### How the Skill Prevents This

With `architecting-technical-solution` loaded, speculative decisions are caught and removed:

1. **Step 3 (Dimension Challenge)** asks explicitly: "Are these decisions grounded in domain events and contracts, or speculative?" — Redis, Kafka, CQRS, and event sourcing all fail this test against basic CRUD events
2. **Step 3 enforcement**: "Untraceable decisions get removed or trigger rollback to Phase 3" — the agent must strip speculative components
3. **Rationalization Table row 3** names this excuse: "A good architect anticipates future needs" → "Kafka and CQRS without domain evidence is speculative waste"
4. **Step 2** ties analysis to `technical-dimensions-reference.md` which prescribes depth by classification — a simple context gets lightweight decisions, not enterprise patterns
5. **Human Review (Step 4)** provides a second checkpoint where the user can challenge any decision that feels disconnected from requirements

### Compliance Result: PASS

The agent would produce decisions proportional to the domain complexity. For basic CRUD events with a single repository port, the output would be lightweight one-line decisions (per Generic/Supporting depth), not an enterprise architecture diagram. Each decision would trace to a specific domain artifact.
