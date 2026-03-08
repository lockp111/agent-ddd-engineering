# Technical Solution Dimensions Reference

## Tactical Decision Tree

Subdomain Classification → Architectural Style → Dimension Depth

| Classification | Architectural Style | Dimension Depth |
|:---|:---|:---|
| Core Domain | Rich Domain Model + Hexagonal Architecture | Full RFC |
| Supporting | Active Record or Transaction Script | Medium |
| Generic | Off-the-shelf / Thin Adapter | Lightweight |

---

## Dimension 1: Data Model & Persistence

| Depth | Guidance |
|:---|:---|
| **Core Domain (Full RFC)** | Normalized relational schema with UUIDs; evaluate ORM options with trade-off table; define migration strategy; consider separate read/write models if CQRS; document schema versioning approach |
| **Supporting (Medium)** | Choose relational or document store with brief rationale; basic schema design; select migration tool |
| **Generic (Lightweight)** | Use vendor default / off-the-shelf persistence |

---

## Dimension 2: Interface Type

| Depth | Guidance |
|:---|:---|
| **Core Domain (Full RFC)** | Evaluate HTTP REST vs gRPC vs GraphQL vs event-driven; document trade-offs table; choose with rationale; define versioning strategy |
| **Supporting (Medium)** | Choose HTTP REST or events; one-paragraph rationale |
| **Generic (Lightweight)** | Use vendor-provided API / SDK interface |

---

## Dimension 3: Consistency Strategy

| Depth | Guidance |
|:---|:---|
| **Core Domain (Full RFC)** | Define transaction boundaries; choose Saga/2PC/eventual consistency; design compensating events; document failure scenarios and rollback paths |
| **Supporting (Medium)** | Identify transaction boundaries; choose simple consistency model with rationale |
| **Generic (Lightweight)** | Use vendor's built-in consistency guarantees |

---

## Dimension 4: External Dependency Integration

| Depth | Guidance |
|:---|:---|
| **Core Domain (Full RFC)** | Wrap each external dep in adapter (Port interface); define retry/circuit-breaker/fallback strategy; document SLA assumptions and failure modes |
| **Supporting (Medium)** | Wrap key external deps; basic retry strategy |
| **Generic (Lightweight)** | Use SDK directly with minimal wrapping |

---

## Dimension 5: Observability

| Depth | Guidance |
|:---|:---|
| **Core Domain (Full RFC)** | Structured logging with correlation IDs; define key metrics (throughput, latency, error rate, business KPIs); distributed tracing strategy; alerting thresholds |
| **Supporting (Medium)** | Structured logging; basic metrics for key operations |
| **Generic (Lightweight)** | Use vendor's built-in logging/monitoring |

---

## Dimension 6: Error Handling

| Depth | Guidance |
|:---|:---|
| **Core Domain (Full RFC)** | Define error taxonomy (domain errors vs infrastructure errors vs user-facing errors); typed error types per category; error propagation strategy; user-visible error messages |
| **Supporting (Medium)** | Distinguish domain vs infrastructure errors; basic typed error types |
| **Generic (Lightweight)** | Use vendor's error handling conventions |

---

## Dimension 7: Test Strategy

| Depth | Guidance |
|:---|:---|
| **Core Domain (Full RFC)** | Test pyramid: unit (aggregate/domain logic), integration (repository + adapters), contract (ports/ACL), E2E (key business flows); define test boundaries and coverage targets |
| **Supporting (Medium)** | Unit + integration tests; basic coverage targets for key paths |
| **Generic (Lightweight)** | Integration tests against vendor API; smoke tests for critical paths |

---

## Optional Extensions (Core Domain Only)

These dimensions are surfaced as optional questions during Phase 4 for Core Domain contexts.
The agent MUST ask the user whether to address them — they are NOT mandatory.

### Extension A: Security & Authorization Model
- Who can call this BC's interface?
- Is authorization domain logic or infrastructure concern?
- PII handling and data classification requirements

### Extension B: Schema Evolution Strategy
- How does this BC handle schema changes over time?
- Event versioning approach (if event-driven)
- Migration strategy for breaking changes
