---
name: designing-contracts-first
description: Use when two different modules need to communicate, when defining cross-context APIs, or before implementing logic that depends on external data. Triggers on "contract first", "契约优先", "定义接口", "API 设计", "交互协议", "防腐层", "ACL".
---

# Designing Contracts First

## Overview
This skill forces a "Contract-First" development approach. Before any internal business logic or database operations are written, you must define the strict, pure interfaces (Anti-Corruption Layers) that dictate how different Bounded Contexts communicate. This prevents tight coupling and ensures AI coding sessions do not hallucinate cross-domain dependencies.

## When to Use
- When starting the implementation phase of a newly mapped Bounded Context.
- When an entity in Context A needs data from or needs to trigger an action in Context B.
- Before writing any `Service`, `Repository`, or internal `Domain` logic that relies on external boundaries.

## Core Pattern
**Instead of:** Directly importing database models or internal structs from another module (e.g., `import "inventory/models"` inside the `order` package).
**Do this:** Define a pure, language-specific interface or a validation schema (Zod, Pydantic) that acts as an Anti-Corruption Layer (ACL).

## Implementation (Interactive Q&A Session)

**CRITICAL RULE:** Do NOT just generate the contract files and stop. You must guide the user through an interactive, step-by-step API design process.

1. **Review Context Map:** Check the relationship pattern (e.g., ACL, Conformist) established during the `mapping-bounded-contexts` phase. Explain this relationship to the user.
2. **Boundary Challenge (Mandatory Checkpoint):** 
   - *Question:* Ask the user: "Does this contract require sharing deep domain concepts (like a massive God object) tightly across boundaries? Or is it passing minimal needed data?"
   - *Action:* If the user indicates it's sharing too much, **STOP IMMEDIATELY**. Do not write the contract. Advise the user to revert to `mapping-bounded-contexts` to redraw the system boundaries.
3. **Draft Pure Interfaces:** Write a *draft* of pure, logic-less interfaces for the expected inputs and outputs. 
   - *Golang:* Define `interface` types in the domain layer.
   - *TypeScript:* Define `interface` or `type` aliases.
4. **Implement Structured Outputs (ACL):** For data crossing the boundary, define strict schemas using tools like Zod, Pydantic, or strict Go struct tags (mapped *only* for the external boundary, not the domain core).
5. **Human Review (Crucial):** Present the `types`, `interfaces`, and `schemas` to the user. Ask: "Does this API contract fulfill the needs of both Contexts without leaking internal business rules? Do you approve these definitions?"
   - **Do NOT write any business logic or internal implementations until the user explicitly approves this contract.**

### Example (TypeScript)
```typescript
// ✅ Correct: Pure contract definition acting as ACL
import { z } from "zod";

// Schema enforced at the boundary
export const InventoryReservedEventSchema = z.object({
  reservationId: z.string().uuid(),
  cartId: z.string(),
  reservedItems: z.array(z.object({ sku: z.string(), quantity: z.number() }))
});

export type InventoryReservedEvent = z.infer<typeof InventoryReservedEventSchema>;

// Port interface for the external dependency
export interface InventoryServicePort {
  reserve(cartId: string, items: CartItem[]): Promise<InventoryReservedEvent>;
}
```

## Common Mistakes & Red Flags
- 🚨 **Red Flag:** Writing business logic or database queries inside the contract file.
- 🚨 **Red Flag:** Importing an internal domain entity from Context B into Context A's contract.
- 🚨 **Red Flag:** Bypassing the "Boundary Challenge" when a contract feels unnaturally complex or requires sharing too much state.

**If any red flags occur: STOP, delete the contract, and evaluate if the Bounded Contexts need to be redesigned.**
