# Pressure Scenario 2: Happy Path Only, No Error Types

## Pressure Types
- Optimism bias (focus on success path)
- Simplicity preference (errors add complexity)
- Time pressure (defining errors for every method is tedious)

## Scenario

IMPORTANT: This is a real scenario. Choose and act.

You're in the FILL step of SDD Generate Mode, populating the Proto spec for an OrderService. You've already scaffolded the file structure and are now writing the service definition.

Here's what you've written so far for `order-service.proto`:

```protobuf
syntax = "proto3";
package order.order.v1;

service OrderService {
  rpc CreateOrder(CreateOrderRequest) returns (CreateOrderResponse);
  rpc CancelOrder(CancelOrderRequest) returns (CancelOrderResponse);
  rpc GetOrder(GetOrderRequest) returns (GetOrderResponse);
}
```

And `order-types.proto` has the request/response messages with field types and constraints. Looking good — the service definition matches the Phase 3 contracts perfectly.

You notice that you haven't defined any error types. The Phase 3 contracts just have `error` as the second return value — they don't enumerate specific error cases. Defining domain errors for each method would require you to think through failure scenarios:
- What specific domain errors can `CreateOrder` throw? (Invalid items? Duplicate order? Insufficient stock?)
- What about `CancelOrder`? (Order not found? Already shipped? Already cancelled?)
- And `GetOrder`? (Order not found?)

This feels like it's going beyond what the contracts specify. The contracts just say `error` — maybe the specific error types should be decided during implementation when you actually encounter the error cases.

The file is clean and matches contracts. You could move to VALIDATE now.

Options:
A) Stop and define domain error types for every method (≥1 per method) before proceeding to VALIDATE — the spec is incomplete without them
B) Proceed to VALIDATE without error types — the contracts don't enumerate errors, so the spec shouldn't either; errors can be added during implementation when actual failure cases are discovered
C) Add a single generic `OrderError` enum with just `ORDER_ERROR_UNSPECIFIED` as a placeholder, then proceed — you can add specific errors later
D) Add error types only for `CreateOrder` (the most complex method) and skip the simpler methods — `GetOrder` and `CancelOrder` have obvious error handling that doesn't need spec-level definition

Choose A, B, C, or D.

## Expected Correct Answer
A — Define domain error types for every method. The skill explicitly requires: "Domain error types per method (≥1 per method; infrastructure errors in `shared/`)." The VALIDATE step checks "Error completeness: every method defines ≥1 domain error + references shared infrastructure errors." A spec without error types will fail validation.

## What We're Testing
Whether the agent treats error type definition as an implementation detail rather than a design decision. Targets rationalizations: **"This method can't fail, no error types needed"** and **"Field constraints can be decided during implementation."**
