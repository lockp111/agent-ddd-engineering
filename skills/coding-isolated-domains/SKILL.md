---
name: coding-isolated-domains
description: Use when implementing core business logic, domain entities, or aggregates. Use when encountering anemic models (entities with only getters/setters), ORM tags or HTTP logic leaking into domain structs, public SetStatus() methods, or business logic living in services instead of entities. 充血模型, 六边形架构, 领域层隔离, rich domain model, hexagonal architecture.
---

# Coding Isolated Domains

## Overview
This is the ultimate architectural defense skill. It explicitly forbids the generation of "Anemic Domain Models" (data bags with only getters/setters) and enforces Hexagonal Architecture. The Domain Core MUST be completely isolated from infrastructure, containing pure business logic (Rich Models) protected by strict unit tests.

**Foundational Principle:** All rules are mandatory constraints, not aspirational guidelines. No "temporarily" or "just for now."

## When to Use
- When writing implementation of business rules, Entities, or Aggregates; when you detect an Entity with only properties and no behavior; when ORM tags or HTTP logic leak into the domain layer.

**Do NOT use when:** Writing infrastructure adapters, API controllers, or repositories; working on Generic Subdomains with simple CRUD; or when context boundaries and contracts are not yet defined (**REQUIRED PREREQUISITES:** Phase 4 [architecting-technical-solution](../architecting-technical-solution/SKILL.md) and SDD must complete first — IDE rules file (.claude/rules/ddd-constraints.md) must exist before domain code is written).

## Quick Reference

| Step | Action | Output |
|:---|:---|:---|
| 1 | Aggregate Design Proposal | Aggregate root structure approved |
| 2 | Zero Infrastructure Dependencies | No ORM/HTTP in domain structs confirmed |
| 3 | Mandatory Rich Domain Models | Behavior methods defined, no public setters |
| 4 | Eric Evans 4 Aggregate Rules | Consistency boundaries validated |
| 5 | Domain TDD (MAP→ITERATE→DIFF) | Tests written, RED→GREEN→REFACTOR cycle complete |
| 6 | Implementation Generation | Rich Domain Model code approved |
| 7 | Persist Design Decisions | `docs/ddd/decisions-log.md` updated |

## Multi-Agent Handling

When spawning sub-agents for parallel implementation:

**Before spawning:**
- IDE rules are auto-loaded from `.claude/rules/ddd-constraints.md`
- Load [_shared/domain-architecture-reference.md](../_shared/domain-architecture-reference.md)
- Each sub-agent task MUST include hard constraints reminder:

```
Hard Constraints (MUST follow):
- domain/ cannot import infra/
- No ORM tags in domain structs
- No public setters on entities
- Value objects are immutable
- Aggregates reference by ID only
```

**After sub-agents complete:**
- Run lint check: `grep -r "gorm:" domain/` → should return empty
- Run lint check: `grep -r "infra/" domain/` → should return empty
- If violations found: STOP, fix before proceeding

> Architecture red lines for the GREEN step: see [domain-architecture-reference.md](../_shared/domain-architecture-reference.md)

## Ambiguity Handling

Follow the [Ambiguity Handling Protocol](../_shared/ambiguity-handling-reference.md) throughout this phase.

**Phase 5 STOP triggers — confirm immediately:**

| Ambiguity | Why STOP |
|:----------|:---------|
| Aggregate root boundary (what belongs inside vs outside the aggregate) | Wrong boundary = wrong consistency scope → aggregate design must redo |
| Business invariant interpretation | Wrong invariant = wrong behavior methods → implementation must redo |
| Entity vs Value Object classification | Wrong classification = wrong identity semantics → aggregate design must redo |

**Phase 5 ASSUME & RECORD — proceed with explicit assumption:**

| Ambiguity | Default assumption |
|:----------|:------------------|
| Internal helper method structure | Extract to private method when logic exceeds 3 lines |
| Test data specific values | Use realistic but minimal values (e.g. price=100, quantity=1) |
| Value Object internal representation | Use the simplest representation that satisfies the invariant |

## Implementation: The Iron Laws of the Domain Core (Interactive Q&A Session)

**CRITICAL RULE:** Do NOT just generate the final code and stop. You must guide the user through an interactive, step-by-step domain implementation process.

### Step 1: Aggregate Design Proposal
- Propose Aggregate Root structure and its Entities/Value Objects.
- Reference the Technical Solution artifact (`docs/ddd/phase-4-technical-solution.md`) for data model decisions, persistence strategy, and architectural style when proposing the Aggregate structure.
- **Ask:** "Does this accurately represent the business concepts? Have we missed any critical invariants or properties?"
- Refine based on feedback.

### Architecture Red Lines

The complete checklist of architecture and domain modeling constraints is in [domain-architecture-reference.md](../_shared/domain-architecture-reference.md). Check every RED line from that reference during implementation — especially in the GREEN step of each TDD cycle. If a violation is detected, stop immediately, delete the violating code, and rewrite.

**Architecture Constraints** (hexagonal boundary — 5 red lines):
domain layer has no infrastructure dependencies · no ORM/JSON tags on domain structs · no cross-aggregate direct imports · business logic in entities not services · ports are interfaces not implementations

**Domain Modeling Constraints** (DDD discipline — 4 red lines):
value objects are immutable · no public setters on entities · domain events named in past tense · aggregates reference other aggregates by ID only

### Step 2: Zero Infrastructure Dependencies
- NO ORM/HTTP/framework dependencies in domain structs. See Architecture Constraints in [domain-architecture-reference.md](../_shared/domain-architecture-reference.md).

### Step 3: Mandatory Rich Domain Models
- Entities MUST have behavior methods. No public setters — expose `shipOrder()` not `setStatus()`. See Domain Modeling Constraints in [domain-architecture-reference.md](../_shared/domain-architecture-reference.md).

### Step 4: Eric Evans 4 Aggregate Rules
- **Consistency boundary:** Model true invariants together — only place in one aggregate the data that must be consistent in a single transaction.
- **Small aggregates:** Keep aggregates small. Large aggregates cause lock contention and slow loads. When in doubt, make it smaller.
- **Reference by ID:** Reference other aggregates by identity only (a stored ID), never by direct object reference. This enforces loose coupling and allows separate persistence.
- **Invariants in root:** Only the Aggregate Root may enforce consistency rules across the entire aggregate. External code calls methods on the root; it never mutates child entities directly.

### Step 5: Domain TDD
- **Mandatory TDD:** Execute [test-driven-development](../test-driven-development/SKILL.md) — run the MAP→ITERATE→DIFF cycle driven by the spec file for this Bounded Context.
- In the GREEN step of each TDD cycle, verify every Architecture Red Line from [domain-architecture-reference.md](../_shared/domain-architecture-reference.md). If a violation is detected, stop immediately, delete the violating code, and rewrite.
- **Ask:** "Do these tests cover all expected behaviors and edge cases? Shall I proceed to implement the logic to make these tests pass?"

### Step 6: Implementation Generation
- ONLY after user approval of the Aggregate design and TDD tests, implement the Rich Domain Model conforming to the rules above.

### Step 7: Persist Design Decisions
After user approval of the Aggregate design and implementation, append the aggregate design decisions (from Step 1 proposal and user feedback) to `docs/ddd/decisions-log.md`. Record: the proposed Aggregate Root structure, user feedback, any invariants added or modified, and the TDD test coverage summary. Update `docs/ddd/ddd-progress.md` Phase 5 status to `complete`.

**PIPELINE COMPLETE.** For additional bounded contexts, repeat from Step 1 for each remaining context (Supporting Domain contexts first, then Generic). For a new project or module, return to [full-ddd](../full-ddd/SKILL.md). For iterating on this project after archival, use [iterating-ddd](../iterating-ddd/SKILL.md).

**Archive this iteration** (when all contexts are complete):
```
sh skills/full-ddd/scripts/archive-artifacts.sh
```
This moves all phase artifacts into `docs/ddd/archive/v{N}/`. The archive is a human-readable record — it is NOT loaded by the agent on the next session.

### Example (Anemic Anti-Pattern — ❌ DO NOT DO)

```go
// ❌ Wrong: GORM tags leak into domain struct; public setter destroys invariants
type Order struct {
	ID     string      `gorm:"column:id;primaryKey"`
	Status OrderStatus `gorm:"column:status"`
	Items  []OrderItem `gorm:"foreignKey:OrderID"`
}

// Public setter — caller bypasses all invariants
func (o *Order) SetStatus(s OrderStatus) {
	o.Status = s // No validation. Anyone can set any status at any time.
}
```

### Example (Pure Rich Model)

```go
// ✅ Correct: No GORM tags, behavior is encapsulated, state is private
type Order struct {
	id     string
	status OrderStatus
	items  []OrderItem
}

// Behavior method enforcing invariants
func (o *Order) Pay() error {
	if o.status != StatusPending {
		return errors.New("only pending orders can be paid")
	}
	o.status = StatusPaid
	// ... logic
	return nil
}
```

## Self-Check Protocol

Follow the [Persistence Defense Reference](../_shared/persistence-defense-reference.md) after Step 7, with this context-specific item 4:

4. **Domain Code + Tests Exist:** Verify the aggregate root file, domain entity files, and corresponding test files exist in the context directory.

**If the check fails → STOP. Write the missing files before claiming PIPELINE COMPLETE.**

Note: This skill has no platform hooks. When invoked by [full-ddd](../full-ddd/SKILL.md) or [iterating-ddd](../iterating-ddd/SKILL.md), the orchestrator's hooks provide Layer 1 defense. When invoked standalone, this Self-Check Protocol (Layer 2) is the primary defense.

## Rationalization Table

These are real excuses agents use to bypass domain isolation rules. Every one of them is wrong.

| Excuse | Reality |
|:---|:---|
| "These rules are long-term goals, not hard requirements" | They are hard requirements. Mandatory, every time, no exceptions. |
| "Ship first, refactor later" | "Later" never comes. Delete polluted code now. |
| "Technical debt is reversible" | ORM-coupled models attract more coupling until extraction is a rewrite. |
| "YAGNI / it's just an MVP" | Domain isolation is cheaper now than retrofitting later. |
| "The tech lead / senior says skip it" | Authority does not override architectural invariants. |
| "Following these rules looks dogmatic" | Following proven constraints is engineering discipline, not dogmatism. |
| "The risk of rewriting outweighs keeping bad code" | Keeping polluted code compounds invisible risk. Rewrite now. |
| "Add GORM tags 'temporarily' with a refactoring ticket" | No "temporary" infrastructure dependency — it becomes permanent. |
| "Expose `SetStatus()` for now, add a lint rule later" | A public setter destroys encapsulation the moment it exists. |
| "Linter/CI will block the PR without GORM tags" | Tooling is configurable. Add a mapper layer, adjust linter rules — don't pollute the domain model. |
| "This domain ambiguity is minor, I'll resolve it during implementation" | Domain ambiguities resolved during implementation create anemic models. The aggregate design proposal step exists to prevent this. |
| "STOP is too disruptive, I'll finish the aggregate design first" | A STOP-level wrong assumption in Phase 5 means redoing the aggregate design and all tests. Pausing costs nothing. |

## Red Flags — STOP and Rewrite

If you catch yourself thinking "just for now", "refactor later", or "rules are guidelines" — STOP. Delete the polluted code. Start over with a pure Rich Domain Model.
