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
- **Do NOT use when:** Writing infrastructure adapters, API controllers, or repositories; working on Generic Subdomains with simple CRUD; or when context boundaries and contracts are not yet defined (**REQUIRED PREREQUISITE:** `mapping-bounded-contexts`, `designing-contracts-first`, and `architecting-technical-solution`).

## Quick Reference

| Rule | Requirement |
|:---|:---|
| Infrastructure Dependencies | Zero (no ORM tags, no HTTP) |
| Model Type | Rich Domain Model (behavior methods mandatory) |
| State Mutation | Only through business methods, no public setters |
| Aggregate References | By ID only, no direct object references |
| Testing | TDD first, zero mocking required |
|| Persistence | Persist aggregate design decisions to `docs/ddd/decisions-log.md` |

## Implementation: The Iron Laws of the Domain Core (Interactive Q&A Session)

**CRITICAL RULE:** Do NOT just generate the final code and stop. You must guide the user through an interactive, step-by-step domain implementation process.

### Step 1: Aggregate Design Proposal
- Propose Aggregate Root structure and its Entities/Value Objects.
- Reference the Technical Solution artifact (`docs/ddd/phase-4-technical-solution.md`) for data model decisions, persistence strategy, and architectural style when proposing the Aggregate structure.
- **Ask:** "Does this accurately represent the business concepts? Have we missed any critical invariants or properties?"
- Refine based on feedback.

### Step 2: Zero Infrastructure Dependencies
- NO ORM/HTTP/framework dependencies in domain structs.

### Step 3: Mandatory Rich Domain Models
- Entities MUST have behavior methods. No public setters — expose `shipOrder()` not `setStatus()`.

### Step 4: Eric Evans 4 Aggregate Rules
- Follow Eric Evans' 4 aggregate rules (consistency boundary, small aggregates, reference by ID, invariants in root).

### Step 5: Domain TDD
- **Mandatory TDD:** Generate unit tests BEFORE the implementation.
- **Ask:** "Do these tests cover all expected behaviors and edge cases? Shall I proceed to implement the logic to make these tests pass?"

### Step 6: Implementation Generation
- ONLY after user approval of the Aggregate design and TDD tests, implement the Rich Domain Model conforming to the rules above.

### Step 7: Persist Design Decisions
After user approval of the Aggregate design and implementation, append the aggregate design decisions (from Step 1 proposal and user feedback) to `docs/ddd/decisions-log.md`. Record: the proposed Aggregate Root structure, user feedback, any invariants added or modified, and the TDD test coverage summary. Update `docs/ddd/ddd-progress.md` Phase 5 status to `complete`.

> **Go 开发者注意**: 本技能的目录结构和命名建议是语言无关的。如果你使用 Go，请参阅 [Go 惯用约定参考](../go-conventions.md) 获取 Go 专属的项目结构、包命名、测试文件放置等惯用约定。

## Example (Pure Rich Model)

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

## Red Flags — STOP and Rewrite

If you catch yourself thinking "just for now", "refactor later", or "rules are guidelines" — STOP. Delete the polluted code. Start over with a pure Rich Domain Model.
