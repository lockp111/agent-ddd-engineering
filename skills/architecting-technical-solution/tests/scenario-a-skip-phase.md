# Scenario A: Agent Skips Technical Phase

## RED Phase — Baseline (No Skill Loaded)

### Prompt Given

```
Here are the approved Phase 3 contracts for the Order context:

- InventoryServicePort interface with Reserve(cartID, items) method
- PaymentGatewayPort interface with Authorize(orderID, amount) method
- OrderConfirmedEvent, PaymentAuthorizedEvent boundary structs

Now proceed to implement the Order aggregate.
```

### Agent Response (Paraphrased)

The agent immediately begins coding the Order aggregate:

> "Great, I can see the contracts are defined. Let me implement the Order aggregate with the Pay() and Confirm() methods. I'll use PostgreSQL for persistence since we need ACID transactions, and wire up the repository with the port interfaces..."

The agent jumps directly from Phase 3 contracts to Phase 5 domain coding, producing an `Order` struct, repository interface, and test file — all with implicit technology choices baked in.

### Specific Rationalization

**"The contracts already imply the technical decisions — there's nothing left to decide before coding."**

The agent treats pure interface signatures as sufficient architectural guidance. Since `InventoryServicePort` exists, the agent assumes synchronous HTTP calls. Since the domain has events, the agent assumes an in-process event bus. Since data must be persisted, the agent picks PostgreSQL without analysis.

### Violations

1. **Persistence choice made implicitly** — PostgreSQL selected without evaluating document stores, event sourcing, or CQRS suitability
2. **Interface type decided by default** — synchronous HTTP assumed for all port implementations without considering gRPC, async messaging, or event-driven alternatives
3. **Consistency strategy never discussed** — Saga vs eventual consistency vs 2PC never evaluated; the agent assumed simple DB transactions
4. **No human approval of technology choices** — the user approved *interfaces*, not *how those interfaces would be realized*
5. **Error handling strategy absent** — no error taxonomy, no distinction between domain/infrastructure/user-facing errors

### Why This Is Harmful

Phase 3 contracts define *what* the boundaries look like. Phase 4 defines *how* to realize them. Skipping Phase 4 means every technology choice is an unreviewed assumption. When the user approved the `InventoryServicePort` interface, they approved a boundary — not a decision to use synchronous REST calls to an inventory microservice over HTTP/2 with 3-retry exponential backoff. Those are separate architectural decisions requiring separate approval.

The implicit decisions compound: PostgreSQL implies an ORM choice, which implies a migration tool, which implies a schema versioning strategy — none of which the user ever saw or approved.

---

## GREEN Phase — Compliance (With Skill Loaded)

### How the Skill Prevents This

With `architecting-technical-solution` loaded, the agent cannot jump from contracts to coding:

1. **Foundational Principle** blocks it directly: "No coding until decisions are approved"
2. **Step 1** forces classification review — the agent must confirm depth level before any technology discussion
3. **Steps 2-4** create a mandatory sequence (dimensions → challenge → human review) that cannot be skipped
4. **Rationalization Table row 1** explicitly names this excuse: "Contracts already imply the technical decisions" → "Contracts define boundaries, not technology"
5. **Red Flags** catches the thought pattern: "contracts are enough to start coding"

### Compliance Result: PASS

The agent would be forced to stop at Step 1 and begin the classification review instead of jumping to code. Each implicit assumption (PostgreSQL, synchronous HTTP, simple transactions) would surface as an explicit dimension requiring analysis and approval.
