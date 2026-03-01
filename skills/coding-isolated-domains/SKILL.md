---
name: coding-isolated-domains
description: Use when implementing core business logic, domain entities, aggregates, or when encountering anemic models and infrastructure coupling. Triggers on "实现业务逻辑", "充血模型", "六边形架构", "代码实现", "实体行为", "领域层隔离".
---

# Coding Isolated Domains

## Overview
This is the ultimate architectural defense skill. It explicitly forbids the generation of "Anemic Domain Models" (data bags with only getters/setters) and enforces Hexagonal Architecture. The Domain Core MUST be completely isolated from infrastructure, containing pure business logic (Rich Models) protected by strict unit tests.

## When to Use
- When writing the actual implementation of business rules, Entities, or Aggregates.
- When you detect an Entity being created with only properties and no behavior.
- When database ORM tags or HTTP logic start leaking into the domain layer.

## Core Pattern
**Instead of:** Creating a single `Order` struct with `gorm` tags and writing all logic in `OrderService`.
**Do this:** Create a pure `Order` Aggregate Root with behavior methods (e.g., `pay()`, `cancel()`) and zero external dependencies.

## Implementation: The Iron Laws of the Domain Core

### 1. Zero Infrastructure Dependencies
- **NO ORM Tags:** The domain model must not know how it is persisted. (e.g., in Go: NO `gorm:"column:id"`, NO `json:"id"`. In TS: NO `@Entity()` TypeORM decorators).
- **NO HTTP Logic:** The domain model must not return HTTP status codes or know about web requests.

### 2. Mandatory Rich Domain Models (Anti-Anemic)
- **Entities MUST have behavior.** If an Entity only has fields and Getters/Setters, it is a catastrophic failure.
- **Hide internal state.** State mutation must happen through business methods that enforce invariants (e.g., `checkout()`, `applyDiscount()`).
- **No public setters.** You cannot expose `setStatus(status)`. You must expose `shipOrder()`.

### 3. Strict Aggregate Design Rules (Eric Evans)
When designing an Aggregate Root, you MUST follow these 4 rules:
1. **Consistency Boundary:** The aggregate is a transactional boundary. Everything inside it must be updated together.
2. **Keep it Small:** Do not build massive God-objects. Only include what is necessary to enforce invariants.
3. **Reference by ID Only:** Aggregates must NOT hold direct object references to other Aggregates. They must only hold their IDs (e.g., `customerId string`, NOT `customer Customer`).
4. **Invariants inside the Root:** All business rules must be validated inside the Aggregate Root's methods.

### 4. Domain TDD (Test-Driven Development)
- **Mandatory TDD:** You MUST generate unit tests for the domain behavior (testing the invariant rules and domain events) BEFORE or ALONG WITH the entity implementation. Because the Domain Core is pure logic, these tests should require zero mocking of external services.

## Language Idioms

### Golang Example (Pure Rich Model)
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

### TypeScript Example (Pure Rich Model)
```typescript
// ✅ Correct: Private properties, constructor validation, pure class
export class Order {
  private status: OrderStatus;
  private items: OrderItem[];

  constructor(public readonly id: string, items: OrderItem[]) {
    if (items.length === 0) throw new Error("Order must have items");
    this.items = items;
    this.status = OrderStatus.PENDING;
  }

  public pay(): void {
    if (this.status !== OrderStatus.PENDING) {
      throw new Error("Only pending orders can be paid");
    }
    this.status = OrderStatus.PAID;
  }
}
```

## Common Mistakes & Red Flags
- 🚨 **Red Flag:** Adding `gorm` or `json` tags directly to the domain Entity.
- 🚨 **Red Flag:** An Entity struct/class that has NO methods, or only `get`/`set` methods.
- 🚨 **Red Flag:** Writing business validation logic inside a Repository implementation instead of the Entity.
- 🚨 **Red Flag:** An Aggregate holding a direct pointer/reference to another Aggregate instead of an ID.

**If any red flags occur: STOP, delete the polluted code, and rewrite it as a pure, isolated Rich Domain Model.**