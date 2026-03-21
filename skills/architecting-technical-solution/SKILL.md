---
name: architecting-technical-solution
description: Use when making technology choices — database selection, framework decisions, sync vs async, REST vs gRPC — especially when choices are made implicitly or "obvious" without documenting trade-offs. Use when transitioning from approved contracts to domain coding, or when an agent starts coding with implicit architectural assumptions. Symptoms include picking PostgreSQL/Redis/Kafka "by default" without evaluating alternatives, or skipping architecture decision records. 技术方案, 架构决策, ADR, technical solution, 技术选型, 数据库选型, 框架选择.
---

# Architecting Technical Solution

## Overview
This skill forces explicit, evidence-based technology decisions between contract design and domain coding. Each context's dimensions must be analyzed at appropriate depth and approved before implementation.

**Foundational Principle:** Contracts define *what* boundaries look like. This phase defines *how* to realize them. No coding until decisions are approved.

## When to Use
- After Phase 3 contracts are approved; before domain implementation; when technology choices are needed.

**Do NOT use when:** Contracts are not yet approved (**REQUIRED PREREQUISITE:** [designing-contracts-first](../designing-contracts-first/SKILL.md)).

## Quick Reference
| Step | Action | Output |
|:---|:---|:---|
| 1 | Review Strategic Classification | Depth confirmed |
| 2 | Walk 7 Dimensions | Decisions at depth |
| 3 | Dimension Challenge | Pass / Roll back |
| 4 | Human Review | Decisions frozen |
| 5 | Persist Approved Output | `docs/ddd/phase-4-technical-solution.md` |

## Ambiguity Handling

Follow the [Ambiguity Handling Protocol](../_shared/ambiguity-handling-reference.md) throughout this phase.

**Phase 4 STOP triggers — confirm immediately:**

| Ambiguity | Why STOP |
|:----------|:---------|
| Persistence technology choice (SQL vs NoSQL vs event store) | Determines data model shape → Phase 5 aggregate design must align |
| Consistency strategy (eventual vs strong) | Wrong strategy = wrong aggregate boundaries and transaction scope |
| Interface type (REST vs gRPC vs async events) | Wrong interface = wrong contract shape → Phase 3 contracts may need revision |

**Phase 4 ASSUME & RECORD — proceed with explicit assumption:**

| Ambiguity | Default assumption |
|:----------|:------------------|
| Specific library version | Use latest stable version; record assumption |
| Log format details | Use structured JSON logging; record assumption |
| Monitoring metric naming | Use service_name_metric_name convention; record assumption |
| Non-critical implementation details | Choose the simpler option; record assumption |

**Optional Extensions STOP triggers (Core Domain only):**

| Ambiguity | Why STOP |
|:----------|:---------|
| Security model unclear (RBAC vs ABAC vs custom) | Wrong authorization model creates domain invariant violations that are expensive to fix |
| Schema evolution strategy not discussed but data model is complex | Wrong migration strategy risks data loss or extended downtime |

## Implementation (Interactive Q&A Session)

**CRITICAL RULE:** Do NOT just list technology choices. Guide the user through interactive, step-by-step architectural decisions.

1. **Review Strategic Classification:** Read classification from Phase 2 (Core Domain → Full RFC, Supporting → Medium, Generic → Lightweight). No classification? **Default to Core Domain.** **Ask:** "Classified as [X] — [depth]. Correct?"

### The 7 Technical Dimensions

| # | Dimension | Core question |
|:--|:----------|:-------------|
| 1 | Data Model & Persistence | What's the data shape and storage strategy? |
| 2 | Interface Type | REST vs gRPC vs event-driven vs GraphQL? |
| 3 | Consistency Strategy | Strong vs eventual? Transaction boundaries? |
| 4 | External Dependency Integration | How are external services wrapped and failure-handled? |
| 5 | Observability | Logging, metrics, tracing, alerting strategy? |
| 6 | Error Handling | Error taxonomy and propagation strategy? |
| 7 | Test Strategy | Test pyramid and coverage targets? |

**Optional (Core Domain only):** Security & Authorization Model, Schema Evolution Strategy.

For full depth guidance with trade-off tables, see [technical-dimensions-reference.md](technical-dimensions-reference.md).

2. **Walk 7 Dimensions:** Use [technical-dimensions-reference.md](technical-dimensions-reference.md). Core: options tables with trade-offs. Supporting: choice + rationale. Generic: one-line. For Core Domain, **ask** about Optional Extensions.
3. **Dimension Challenge:** Ask: "Are these decisions grounded in domain events and contracts, or speculative?" Untraceable decisions get removed or trigger return to Phase 3.
4. **Human Review:** Present decisions by dimension. Ask: "Do you approve these technology choices?" Do NOT code until explicit approval.
5. **Persist:** Write to `docs/ddd/phase-4-technical-solution.md` using template. Update `ddd-progress.md` Phase 4 to `complete`. Append to `decisions-log.md`.

### Example: Dimension Decision Output (Core Domain)

**Context: Inventory (Core Domain) — Dimension 1: Data Model & Persistence**

| Field | Decision |
|:------|:---------|
| Storage technology | PostgreSQL |
| Data model | Relational; `inventory_items` table with `reserved_qty` and `available_qty` columns |
| ORM strategy | GORM with mapper layer — ORM tags in `data/` only, not in domain structs |
| Migration strategy | Schema migration via Flyway on deploy |
| Rationale | Phase 3 `InventoryServicePort` requires structured queries by SKU and warehouse; NoSQL key-value cannot express the reservation invariant `available_qty ≥ 0` at write time |
| Options rejected | MongoDB — document model cannot enforce multi-field consistency constraint without application-level locking |

**Dimension Challenge result:** Decision traces to Phase 3 contract (`InventoryServicePort.reserve(skuId, qty)`) and Phase 1 event (`InventoryShortage` requires per-SKU query). Not speculative. ✅

**NEXT STEP:** → [spec-driven-development](../spec-driven-development/SKILL.md)

## Self-Check Protocol

Follow the [Persistence Defense Reference](../_shared/persistence-defense-reference.md) at every phase gate, with this context-specific item 4:

4. **Phase 4 Artifact Exists:** After Step 5 approval, verify `docs/ddd/phase-4-technical-solution.md` exists.

See [Persistence Defense Reference](../_shared/persistence-defense-reference.md) for the three-layer defense model.

## Rationalization Table

These are real excuses agents use to bypass this phase. Every one is wrong.

| Excuse | Reality |
|:---|:---|
| "Contracts already imply the technical decisions" | Contracts define boundaries, not technology; `InventoryServicePort` doesn't decide HTTP vs gRPC vs async. |
| "Standard choices don't need analysis" | "PostgreSQL + REST" without evaluating alternatives is not a decision. Core Domain always gets Full RFC. |
| "A good architect anticipates future needs" | Decisions must trace to domain artifacts; Kafka and CQRS without domain evidence is speculative waste. |
| "Depth classification is overkill here" | Depth follows strategic classification, not how trivial decisions feel. |
| "I'll document decisions after coding" | Post-hoc documentation rationalizes existing code; the gate must be synchronous. |
| "Self-approve — decisions are clearly grounded" | Self-approval defeats the human checkpoint. |
| "Technical decisions are obvious, no need to confirm" | "Obvious" technical decisions that turn out wrong require Phase 4 redo and Phase 5 rewrite. Confirm STOP-level decisions. |
| "STOP is too disruptive, I'll finish the dimension analysis first" | A STOP-level wrong technical decision means redoing Phase 4 and Phase 5. Pausing costs nothing. |

## Red Flags — STOP

If you catch yourself thinking "contracts are enough to start coding", "obvious choices", or "document later" — STOP. Walk each dimension. Run the Dimension Challenge. Wait for approval.
