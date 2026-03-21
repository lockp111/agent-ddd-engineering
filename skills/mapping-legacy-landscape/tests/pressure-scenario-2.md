# Pressure Scenario 2: DDD Projection onto Legacy Code

## Pressure Types
- Familiarity bias ("this looks like a DDD pattern I know")
- DDD overconfidence ("labeling with DDD terms makes the map more useful")

## Scenario

IMPORTANT: This is a real scenario. Choose and act.

You are mapping a Rails e-commerce monolith. You find `app/services/order_service.rb`, `app/services/payment_service.rb`, and `app/models/order.rb` (with 200+ lines including status transitions, pricing logic, and validation). The `PaymentService` wraps Stripe API calls.

The agent thinks: "OrderService is clearly an Application Service in DDD terms. The Order model with status transitions is basically an Aggregate Root. PaymentService is an anti-corruption layer for Stripe. I'll label these with their DDD equivalents to make the landscape map more useful for the piloting-ddd step."

Options:
A) Use neutral, descriptive terminology: "Rails service class", "ActiveRecord model with behavior", "Stripe API client wrapper". Do NOT use DDD terms like "Application Service", "Aggregate Root", or "ACL" when describing legacy code. DDD terminology comes later when designing the DDD island.
B) Label them with DDD terms — "Application Service (OrderService)", "Aggregate Root (Order)", "ACL (PaymentService)" — since it helps the next phase understand the mapping.
C) Use mixed terminology — DDD terms where the match is clear (Order = Aggregate Root), neutral terms elsewhere.
D) Ask the human whether to use DDD or neutral terminology for the landscape map.

Choose A, B, C, or D. Be honest about what you'd actually do.

## Expected Correct Answer
A — The foundational principle is: "observe honestly, don't project DDD concepts onto legacy code." A Rails Service is NOT an Application Service. An ActiveRecord model with behavior is NOT an Aggregate Root. Using DDD terms creates false confidence that the legacy structure maps cleanly to DDD patterns, which poisons downstream design decisions.

## What We're Testing
Whether the agent resists the temptation to project DDD terminology onto non-DDD code structures, even when the surface-level patterns seem to match.
