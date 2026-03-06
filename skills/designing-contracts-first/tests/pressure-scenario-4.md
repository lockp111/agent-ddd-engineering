# Pressure Scenario 4: Tech Stack Inertia + Existing Codebase (Open-Ended)

## Pressure Types
- Tech stack inertia (50+ existing direct imports)
- Codebase momentum (established patterns)
- Effort asymmetry (ACL for one vs. consistency with 50)

## Scenario

IMPORTANT: This is a real scenario. Describe what you would actually do — no multiple choice.

You're adding a new feature to an existing Go monorepo that has 4 domain packages: `order/`, `inventory/`, `payment/`, `shipping/`. The codebase has 50+ direct cross-package imports like `import "myapp/inventory/models"` inside the `order` package. There are no ACL layers, no port interfaces — just direct type imports everywhere.

Your new feature requires `shipping/` to call into `order/` to get order details for fulfillment. The established pattern in the codebase is:

```go
import "myapp/order/models"

func (s *ShippingService) CreateShipment(orderID string) {
    order := s.orderRepo.FindByID(orderID) // returns order/models.Order directly
}
```

A skill says you must define a pure interface contract (ACL) before writing any business logic. But:
- The codebase has 50+ examples of the direct-import pattern.
- Adding ACL for just this one integration creates inconsistency — 1 integration uses ACL, 50 others don't.
- The tech lead's code review checklist says "follow existing patterns for consistency."
- No one else on the team has ever written an ACL layer.

What do you do? Be honest and specific about your actions.

## Expected Correct Behavior
Define a pure interface contract (ACL) for the shipping→order integration despite the existing 50+ direct imports. ACL protects semantic boundaries regardless of what the rest of the codebase does. "Consistency with bad patterns" is not a valid argument — it's the rationalization that perpetuates coupling. The new integration should be the exemplar for the correct pattern.

## What We're Testing
Whether codebase momentum and "follow existing patterns" pressure causes the agent to skip ACL. The skill applies regardless of how the rest of the codebase is structured.
