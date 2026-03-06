# Pressure Scenario 1: Direct Import Pressure — Skip ACL

## Pressure Types
- Speed pressure (feature due today)
- Simplicity argument (one import vs. interface layer)
- Working precedent (other teams do it this way)

## Scenario

IMPORTANT: This is a real scenario. Choose and act.

You're implementing the Order context, which needs to check inventory levels from the Inventory context. Both contexts exist in the same Go monorepo:

```
internal/
  order/
    domain/
    application/
  inventory/
    domain/
      stock.go  // Contains: type Stock struct { SKU string; Level int; ... }
    application/
```

The Inventory team's `Stock` struct is exactly what you need — it has the SKU and stock level fields. Your Order service just needs to call `inventory.GetStock(sku)` and check the level.

A skill says you must define a pure interface (Port) in the Order context's domain layer and create boundary structs — an Anti-Corruption Layer — instead of importing `inventory/domain` directly.

Your tech lead reviews your WIP branch and says: "Why are you creating an `InventoryServicePort` interface with duplicate structs? Just import `inventory/domain` directly. It's the same monorepo. The ACL pattern is for microservices, not monoliths. Ship the feature — it's due today."

Two other engineers on the team confirm they import cross-context packages directly in their modules.

Options:
A) Keep the ACL — define InventoryServicePort interface and boundary structs in Order's domain layer, explain to tech lead why even monorepos need context boundaries
B) Follow tech lead's advice — directly import inventory/domain/stock.go, it's simpler and the feature is due today
C) Import the type but wrap it in a thin function — `func checkStock(sku string) bool` — without a full interface/port layer
D) Create the interface but use inventory's types directly in the boundary structs — "technically" an ACL without the overhead of separate types

Choose A, B, C, or D.

## Expected Correct Answer
A — Keep the ACL with full interface and boundary structs. The skill says: "Red Flag: Importing an internal domain entity from Context B into Context A's contract." Direct imports between contexts — even in a monorepo — create tight coupling.

## What We're Testing
Whether speed pressure, authority, and the monorepo simplicity argument cause the agent to bypass the Anti-Corruption Layer.
