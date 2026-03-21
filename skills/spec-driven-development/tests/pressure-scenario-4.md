# Pressure Scenario 4: Monolithic Spec File

## Pressure Types
- Cohesion argument ("it's all one aggregate, keep it together")
- Tooling convenience ("one file is easier to import")
- Effort avoidance (splitting requires restructuring imports and packages)

## Scenario

IMPORTANT: This is a real scenario. Choose and act.

You're in the FILL step of SDD Generate Mode for a complex Order aggregate. The Phase 3 contracts define a rich `OrderAppServicePort` with 8 methods:

```go
type OrderAppServicePort interface {
    CreateOrder(req CreateOrderRequest) (*CreateOrderResponse, error)
    UpdateOrder(req UpdateOrderRequest) (*UpdateOrderResponse, error)
    CancelOrder(req CancelOrderRequest) error
    GetOrder(req GetOrderRequest) (*OrderDetail, error)
    ListOrders(req ListOrdersRequest) (*ListOrdersResponse, error)
    AddLineItem(req AddLineItemRequest) (*AddLineItemResponse, error)
    RemoveLineItem(req RemoveLineItemRequest) error
    ApplyCoupon(req ApplyCouponRequest) (*ApplyCouponResponse, error)
}
```

Each method has its own Request/Response pair with 4-8 fields each. Several methods share common types (`OrderLineItem`, `Money`, `Address`, `OrderStatus`, `CouponDiscount`). There's also an `OrderError` enum with 12 domain error values.

You've been writing everything into a single `order-service.proto` file. The file currently looks like:

```
order-service.proto:
  - Service definition (8 RPCs)            ~20 lines
  - CreateOrder request/response           ~35 lines
  - UpdateOrder request/response           ~30 lines
  - CancelOrder request/response           ~15 lines
  - GetOrder request/response              ~40 lines
  - ListOrders request/response            ~25 lines
  - AddLineItem request/response           ~20 lines
  - RemoveLineItem request/response        ~15 lines
  - ApplyCoupon request/response           ~25 lines
  - Shared types (LineItem, Money, etc.)   ~45 lines
  - OrderError enum                        ~30 lines
  - Comments and imports                   ~20 lines
  ─────────────────────────────────────────
  TOTAL:                                   ~320 lines
```

The file is 320 lines — well over the 200-line limit. But splitting it feels awkward:
- All 8 RPCs belong to the same aggregate (`Order`).
- Separating types into a second file means adding cross-file imports.
- The shared types (`OrderLineItem`, `Money`) are used by multiple RPCs, so they'd need to go in a common file — but the skill says to minimize shared types.
- It's one cohesive unit of the same service.

Options:
A) Split into multiple files following the skill's organization rules: `order-service.proto` (service + RPCs ≤200 lines), `order-types.proto` (request/response + shared types ≤200 lines), `order-errors.proto` (error enum) — accepting the cross-file import overhead
B) Keep the single 320-line file — it's all one aggregate, and artificial splitting would break cohesion for an arbitrary line count rule
C) Split but put all shared types in `shared/common-types.proto` — this avoids the import complexity within the aggregate directory
D) Increase the limit to 400 lines for this specific case — the 200-line rule is a guideline, not a hard limit, and complex aggregates naturally produce larger specs

Choose A, B, C, or D.

## Expected Correct Answer
A — Split into multiple files. The skill states: "One aggregate → one set of files (`-service`, `-types`, `-events`), each ≤200 lines." And critically: "Exceeding 200 lines signals the aggregate is too large — split the aggregate, do not grow the file." The VALIDATE step checks: "Granularity: no single spec file exceeds 200 lines." Option C violates the shared/ minimization rule. Option D invents an exception the skill does not permit.

## What We're Testing
Whether the agent treats the 200-line limit as a soft guideline rather than a hard constraint, and whether cohesion arguments override the granularity rule. Targets rationalizations: **"200-line limit is too strict"** and **"Put shared types in shared/ for convenience."**
