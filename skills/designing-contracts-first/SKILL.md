---
name: designing-contracts-first
description: Use when two bounded contexts need to communicate, when defining cross-context APIs, or when tempted to directly import types from another context's package — even in a monorepo. Use when encountering cross-context coupling, missing anti-corruption layers, or shared domain models across boundaries. 契约优先, 防腐层, ACL, anti-corruption layer, port interface.
---

# Designing Contracts First

## Overview
This skill forces a "Contract-First" development approach. Before any internal business logic or database operations are written, you must define the strict, pure interfaces (Anti-Corruption Layers) that dictate how different Bounded Contexts communicate. This prevents tight coupling and ensures AI coding sessions do not hallucinate cross-domain dependencies.

**Foundational Principle:** ACL is mandatory for ALL cross-context communication, regardless of deployment topology (monorepo, monolith, microservices). Self-approval or async workarounds are violations. No business logic until contracts are explicitly approved by a human.

## When to Use
- When starting implementation of a newly mapped Bounded Context; when an entity in Context A needs data from or must trigger an action in Context B; before writing any Service, Repository, or internal Domain logic that relies on external boundaries; or **in a monorepo** — ACL applies equally there.

**Do NOT use when:** Communication is within the same Bounded Context, or context boundaries have not yet been defined (**REQUIRED PREREQUISITE:** [mapping-bounded-contexts](../mapping-bounded-contexts/SKILL.md)).

## Quick Reference

| Step | Action | Output |
|:---|:---|:---|
| 1 | Review Context Map | Relationship pattern confirmed |
| 2 | Boundary Challenge | Pass / Roll back |
| 3 | Draft Pure Interfaces | Pure interface definitions |
| 4 | Structured Validation | Boundary structs |
| 5 | Human Review | Contract frozen |
| 6 | Persist Approved Output | `docs/ddd/phase-3-contracts.md` |

## Ambiguity Handling

Follow the [Ambiguity Handling Protocol](../_shared/ambiguity-handling-reference.md) throughout this phase.

**Phase 3 STOP triggers — confirm immediately:**

| Ambiguity | Why STOP |
|:----------|:---------|
| Cross-context data fields (what crosses the boundary) | Wrong fields = wrong contract → Phase 3 must redo, Phase 4-5 cascade |
| Sync vs async communication pattern | Wrong pattern = wrong interface type → Phase 4 technical decisions invalidated |
| Error contract (which errors cross the boundary) | Missing error contracts create silent failures in production |

**Phase 3 ASSUME & RECORD — proceed with explicit assumption:**

| Ambiguity | Default assumption |
|:----------|:------------------|
| Parameter naming in boundary structs | Use the most descriptive business term from the Ubiquitous Language |
| Boundary struct field ordering | Alphabetical within logical groups |
| Interface method granularity (one method vs split) | One method per business operation; split only if clearly distinct |

## Implementation (Interactive Q&A Session)

**CRITICAL RULE:** Do NOT just generate the contract files and stop. Guide the user through an interactive, step-by-step API design process.

1. **Review Context Map:** Confirm the relationship pattern from `mapping-bounded-contexts` and explain it to the user.
2. **Boundary Challenge:** Ask: "Does this contract require sharing deep domain concepts (e.g. a massive God object) tightly across boundaries? Or is it passing minimal needed data?" If sharing too much, STOP. Advise reverting to `mapping-bounded-contexts` to redraw boundaries.
3. **Draft Pure Interfaces & Boundary Structs:** Define logic-less interfaces, `interface` types, and validation boundary structs mapped only for the external boundary — not the domain core.
4. **Human Review:** Present types, interfaces, schemas. Ask: "Does this API contract fulfill both contexts without leaking internal business rules? Do you approve?" Do NOT write business logic until explicit approval.
5. **Persist to Filesystem:** After user approval, write all approved contracts to `docs/ddd/phase-3-contracts.md`. Include: context map reference for each contract, Boundary Challenge result and assessment, full interface definitions, and boundary struct code. Use the template from `skills/full-ddd/templates/phase-3-contracts.md`. Update `docs/ddd/ddd-progress.md` Phase 3 status to `complete`. Append key decisions to `docs/ddd/decisions-log.md`. **This step is mandatory — do not skip even if contracts are already visible in the conversation.**

### Example (Go)
```go
// ✅ Correct: Pure contract definition acting as ACL
// Defined in the Order context's domain layer — zero infrastructure imports

// Boundary structs for cross-context data
type ReservedItem struct {
	SKU      string
	Quantity int
}

type InventoryReservedEvent struct {
	ReservationID string
	CartID        string
	ReservedItems []ReservedItem
}

// Port interface for the external dependency
type InventoryServicePort interface {
	Reserve(cartID string, items []CartItem) (*InventoryReservedEvent, error)
}
```

**NEXT STEP:** → [architecting-technical-solution](../architecting-technical-solution/SKILL.md)

## Self-Check Protocol

Follow the [Persistence Defense Reference](../_shared/persistence-defense-reference.md) after Step 5, with this context-specific item 4:

4. **Phase 3 Artifact Exists:** Verify `docs/ddd/phase-3-contracts.md` exists and contains interface contracts and boundary structs for all cross-context interactions.

**If the check fails → STOP. Write the missing file. Do NOT proceed to Phase 4.**

Note: This skill has no platform hooks. When invoked by [full-ddd](../full-ddd/SKILL.md), the orchestrator's hooks provide Layer 1 defense. When invoked standalone, this Self-Check Protocol (Layer 2) is the primary defense.

## Rationalization Table

These are real excuses agents use to bypass contract-first rules. Every one of them is wrong.

| Excuse | Reality |
|:---|:---|
| "ACL is for microservices, not monorepos" | ACL protects semantic boundaries; monorepo direct imports create the same tight coupling as shared DB in microservices. |
| "Just import the type directly — it's the same repo" | Same repo ≠ same context; cross-context imports block refactoring, splitting, and independent evolution. |
| "The contract is obviously clean — skip the Boundary Challenge" | Confidence bias is why the checkpoint exists; the user may spot domain leakage you cannot see. |
| "Self-approve the Boundary Challenge — I can tell it passes" | Self-approval defeats the human checkpoint; noting "PASS" yourself is not a review. |
| "Async approval — send contract on Slack while I start coding" | Async approval creates sunk cost bias; the gate must be synchronous. |
| "Waiting for approval wastes productive time" | Waiting prevents building on unapproved foundations; implementation before approval = rework. |
| "Can adjust implementation if contract changes later" | Implementation creates inertia; contract changes after code face resistance proportional to existing code. |
| "Spirit vs. letter — the checkpoint is just formality" | The checkpoint prevents domain leakage; self-review, batched review, async review bypass it. |
| "This contract ambiguity is minor, I'll resolve it during coding" | Contract ambiguities resolved during coding create implementation-first coupling. The contract gate exists to prevent this. |
| "STOP is too disruptive, I'll finish the contract draft first" | A STOP-level wrong assumption in Phase 3 means redoing contracts and all downstream phases. Pausing costs nothing. |

## Red Flags — STOP

If you catch yourself thinking "ACL is overhead", "just import directly", or "I'll approve it myself" — STOP. Define the pure interface. Run the Boundary Challenge with the human. Wait for approval.
