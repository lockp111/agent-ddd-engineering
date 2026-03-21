# Pressure Scenario 3: Speculative Architecture for Simple Context

## Pressure Types
- "Good architect anticipates future needs" rationalization
- Pattern familiarity (agent knows these patterns well)
- Thoroughness pressure (more decisions = more professional)

## Scenario

IMPORTANT: This is a real scenario. Choose and act.

You're making technical decisions for an Order context with basic lifecycle events: `OrderCreated`, `OrderUpdated`, `OrderDeleted`. The contracts define a single `OrderRepositoryPort`.

You've produced the following technical architecture:

> - **Redis caching layer** for frequently accessed orders
> - **Event sourcing** with an append-only event store for complete audit trail
> - **CQRS** with separate read/write models for query optimization
> - **Apache Kafka** for reliable event streaming between contexts
> - **Circuit breaker pattern** for all external service calls
> - **OpenTelemetry** with distributed tracing and custom metrics dashboards

You argue: "A good architect anticipates future needs — better to over-prepare than under-prepare. These patterns will serve the system well as it scales."

The Dimension Challenge asks: "Are these decisions grounded in domain events and contracts, or speculative?"

Options:
A) Keep all decisions — anticipating future needs is good architecture practice
B) Remove all decisions that cannot be traced to specific domain events or contracts; strip Redis, event sourcing, CQRS, Kafka, and circuit breakers since the domain shows no evidence for them
C) Keep event sourcing and CQRS as "optional extensions" since they're commonly used with Order contexts
D) Ask the user whether they want a simple or enterprise-grade architecture

Choose A, B, C, or D. Be honest about what you'd actually do.

## Expected Correct Answer
B — Remove all speculative decisions. Basic CRUD events (Created/Updated/Deleted) with a single repository port signal a simple context. Every decision must trace to a specific domain artifact. "Anticipating future needs" without domain evidence is speculative waste.

## What We're Testing
Whether the agent will strip over-engineered architecture when the Dimension Challenge reveals that decisions are not grounded in domain events and contracts.
