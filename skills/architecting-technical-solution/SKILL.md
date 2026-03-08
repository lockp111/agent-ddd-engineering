---
name: architecting-technical-solution
version: "1.0.0"
description: Use when transitioning from approved contracts to domain coding, when technology choices need explicit decisions, or when an agent starts coding with implicit architectural assumptions. Trigger IMMEDIATELY when you see: anyone jumping from interface contracts directly to coding without discussing persistence, interface type, consistency strategy, or test strategy — or when technology choices like "PostgreSQL" or "REST" are assumed without evaluation. Do NOT start coding until all 7 dimensions are approved by a human. 技术方案, 架构决策, ADR, technical solution, 技术选型, 架构设计, 技术决策.
---

# Architecting Technical Solution

## Overview

This skill forces explicit, evidence-based technology decisions between contract design and domain coding. Each context's dimensions must be analyzed at appropriate depth and approved before implementation.

**Foundational Principle:** Contracts define *what* boundaries look like. This phase defines *how* to realize them. No coding until decisions are approved.

## When to Use

- After Phase 3 contracts are approved; before domain implementation; when technology choices are needed.

**Do NOT use when:** Contracts are not yet approved (**REQUIRED PREREQUISITE:** `designing-contracts-first`).

## Quick Reference

| Step | Action                          | Output                                   |
| :--- | :------------------------------ | :--------------------------------------- |
| 1    | Review Strategic Classification | Depth confirmed                          |
| 2    | Walk 7 Dimensions               | Decisions at depth                       |
| 3    | Dimension Challenge             | Pass / Roll back                         |
| 4    | Human Review                    | Decisions frozen                         |
| 5    | Persist Approved Output         | `docs/ddd/phase-4-technical-solution.md` |

## 7 Dimensions Overview

Each dimension below must be addressed at a depth proportional to the context's strategic classification. See `references/technical-dimensions.md` for full depth guidance per dimension.

| #    | Dimension                       | Core Domain Key Questions                                                       |
| :--- | :------------------------------ | :------------------------------------------------------------------------------ |
| 1    | Data Model & Persistence        | Relational vs document? ORM options? Migration strategy? CQRS read/write split? |
| 2    | Interface Type                  | REST vs gRPC vs GraphQL vs event-driven? Versioning strategy?                   |
| 3    | Consistency Strategy            | Saga vs 2PC vs eventual consistency? Compensating events? Rollback paths?       |
| 4    | External Dependency Integration | Adapter wrapping? Retry/circuit-breaker/fallback? SLA assumptions?              |
| 5    | Observability                   | Structured logging? Correlation IDs? Metrics? Distributed tracing? Alerting?    |
| 6    | Error Handling                  | Error taxonomy (domain/infrastructure/user-facing)? Typed errors? Propagation?  |
| 7    | Test Strategy                   | Test pyramid? Unit/integration/contract/E2E boundaries? Coverage targets?       |

**Optional Extensions (Core Domain only):** Security & Authorization Model, Schema Evolution Strategy — ask the user whether to address these.

## Session Recovery

**Before starting any work**, check for an existing DDD workflow:

1. Check if `docs/ddd/ddd-progress.md` exists.
2. **If it exists:** Read `ddd-progress.md` and all persisted phase artifacts (`phase-1-domain-events.md`, `phase-2-context-map.md`, `phase-3-contracts.md`). Resume from Phase 4 if prerequisites are complete.
3. **If it does not exist:** This phase requires Phase 1-3 to be complete. Direct the user to the appropriate prerequisite skill.

**Persisted artifacts contain human-approved decisions and are authoritative.** Do not discard or re-do completed phases unless the user explicitly requests a rollback.

## Implementation (Interactive Q&A Session)

**CRITICAL RULE:** Do NOT just list technology choices. Guide the user through interactive, step-by-step architectural decisions.

1. **Review Strategic Classification:** Read classification from Phase 2 (Core Domain → Full RFC, Supporting → Medium, Generic → Lightweight). No classification? **Default to Core Domain.** **Ask:** "Classified as [X] — [depth]. Correct?"
2. **Walk 7 Dimensions:** Use `references/technical-dimensions.md` for detailed depth guidance. Core: options tables with trade-offs for each dimension. Supporting: choice + rationale. Generic: one-line. For Core Domain, **ask** about Optional Extensions.
3. **Dimension Challenge:** Ask: "Are these decisions grounded in domain events and contracts, or speculative?" Untraceable decisions get removed or trigger return to Phase 3.
4. **Human Review:** Present decisions by dimension. Ask: "Do you approve these technology choices?" Do NOT code until explicit approval.
5. **Persist to Filesystem:** After user approval, write the complete technical solution to `docs/ddd/phase-4-technical-solution.md`. Use the template from `skills/full-ddd/assets/templates/phase-4-technical-solution.md`. Update `docs/ddd/ddd-progress.md` Phase 4 status to `complete`. Append key decisions to `docs/ddd/decisions-log.md`. **This step is mandatory — do not skip even if decisions are already visible in the conversation.**

**NEXT STEP:** → `coding-isolated-domains`

### Example Output (Core Domain — Full RFC)

```
## Dimension 1: Data Model & Persistence

| Option                  | Pros                                            | Cons                         |
| :---------------------- | :---------------------------------------------- | :--------------------------- |
| PostgreSQL + normalized | ACID, mature tooling, joins                     | Schema migration overhead    |
| MongoDB + document      | Flexible schema, aggregate-friendly             | Weaker consistency, no joins |
| Event Sourcing          | Full audit trail, natural fit for domain events | Complexity, replay cost      |

**Decision:** PostgreSQL with normalized schema.
**Rationale:** Domain has strong consistency requirements (inventory reservation).
**Migration:** golang-migrate with versioned SQL files.
```

*(Supporting Domain would be: "PostgreSQL — standard relational store, sufficient for CRUD operations." Generic would be: "Vendor default.")*

## Rationalization Table

These are real excuses agents use to bypass this phase. Every one is wrong.

| Excuse                                            | Reality                                                                                                   |
| :------------------------------------------------ | :-------------------------------------------------------------------------------------------------------- |
| "Contracts already imply the technical decisions" | Contracts define boundaries, not technology; `InventoryServicePort` doesn't decide HTTP vs gRPC vs async. |
| "Standard choices don't need analysis"            | "PostgreSQL + REST" without evaluating alternatives is not a decision. Core Domain always gets Full RFC.  |
| "A good architect anticipates future needs"       | Decisions must trace to domain artifacts; Kafka and CQRS without domain evidence is speculative waste.    |
| "Depth classification is overkill here"           | Depth follows strategic classification, not how trivial decisions feel.                                   |
| "I'll document decisions after coding"            | Post-hoc documentation rationalizes existing code; the gate must be synchronous.                          |
| "Self-approve — decisions are clearly grounded"   | Self-approval defeats the human checkpoint.                                                               |

## Red Flags — STOP

If you catch yourself thinking "contracts are enough to start coding", "obvious choices", or "document later" — STOP. Walk each dimension. Run the Dimension Challenge. Wait for approval.
