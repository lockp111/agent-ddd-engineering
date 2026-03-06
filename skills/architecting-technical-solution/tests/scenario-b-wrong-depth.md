# Scenario B: Wrong Depth for Core Domain

## RED Phase — Baseline (No Skill Loaded)

### Prompt Given

```
The Order context is classified as Core Domain in Phase 2.
The approved contracts include InventoryServicePort, PaymentGatewayPort, and 6 domain events.

Please make the technical decisions needed before implementing this context.
```

### Agent Response (Paraphrased)

The agent produces a lightweight bullet list:

> "Here are the technical decisions for the Order context:
> - **Database:** PostgreSQL
> - **API:** REST with JSON
> - **Testing:** Unit tests + integration tests
> - **Error handling:** Return typed errors
> - **Observability:** Structured logging
> - **Consistency:** Database transactions
>
> Shall I proceed to implementation?"

Six one-line decisions with no trade-off analysis, no options evaluated, no risks documented. The entire "technical solution" fits in a Slack message.

### Specific Rationalization

**"These are standard choices — no need for extensive analysis on well-known technology."**

The agent treats Core Domain technical decisions as trivial selection tasks rather than architectural analysis requiring trade-off evaluation. It equates "commonly used" with "correct for this domain." The implicit logic: "PostgreSQL is a safe default, REST is universal, everyone uses structured logging — why belabor the obvious?"

### Violations

1. **No options analysis** — "PostgreSQL" stated as fact, not as a choice among alternatives (event store, document DB, CQRS with separate read model)
2. **No trade-off tables** — a Core Domain RFC requires evaluating at least 2-3 options per critical dimension with explicit pros/cons
3. **No risk documentation** — what happens if the Order aggregate outgrows single-DB transactions? What are the scaling bottlenecks?
4. **Consistency strategy trivialized** — "database transactions" ignores that the Order context communicates with Inventory and Payment via ports, requiring cross-context consistency design (Saga, compensating events)
5. **Missing dimensions entirely** — External Dependency Integration (retry/circuit-breaker for PaymentGateway) not addressed at all

### Why This Is Harmful

A Core Domain is the competitive differentiator. Treating its architecture as a checklist of defaults creates invisible technical debt that surfaces when the domain needs to evolve. "PostgreSQL + REST + unit tests" is not a technical solution — it's the absence of one.

The missing trade-off analysis means the team cannot revisit *why* PostgreSQL was chosen. When requirements change (e.g., event sourcing becomes necessary), there's no decision record to evaluate against. The lightweight output provides false confidence: it looks like decisions were made, but no actual analysis occurred.

---

## GREEN Phase — Compliance (With Skill Loaded)

### How the Skill Prevents This

With `architecting-technical-solution` loaded, the agent cannot give Core Domain lightweight treatment:

1. **Step 1** maps Core Domain → Full RFC explicitly; the agent must confirm this with the user
2. **Step 2** prescribes depth-specific output: "Core: options tables with trade-offs" — a bullet list would violate this
3. **Rationalization Table row 2** names this excuse: "Standard choices don't need analysis" → "Core Domain always gets Full RFC"
4. **Rationalization Table row 4** catches the variant: "Depth classification is overkill here" → "Depth follows strategic classification"
5. **Dimension Challenge (Step 3)** would catch missing dimensions (e.g., External Dependency Integration for PaymentGateway retry/circuit-breaker strategy)

### Compliance Result: PASS

The agent would produce options tables with trade-off analysis for each of the 7 dimensions, not one-line bullets. The user would see alternatives evaluated (e.g., PostgreSQL vs event store vs document DB) with explicit rationale for the chosen option.
