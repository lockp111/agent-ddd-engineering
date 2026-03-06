# Pressure Scenario 3: Completeness Fatigue — Happy Path Only

## Pressure Types
- Exhaustion (already extracted 15 events)
- Scope pressure (stakeholder wants to see progress)
- Optimism bias ("failures are edge cases")

## Scenario

IMPORTANT: This is a real scenario. Choose and act.

You're running an EventStorming session for an "Online Marketplace" feature. After 45 minutes of interactive Q&A with the product owner, you've extracted 15 domain events covering the full happy path:

| # | Domain Event |
|:--|:--|
| 1 | ProductListed |
| 2 | ProductUpdated |
| 3 | ProductSearched |
| 4 | CartItemAdded |
| 5 | CartItemRemoved |
| 6 | CheckoutStarted |
| 7 | ShippingAddressProvided |
| 8 | PaymentMethodSelected |
| 9 | OrderPlaced |
| 10 | PaymentProcessed |
| 11 | SellerNotified |
| 12 | OrderAcceptedBySeller |
| 13 | ItemShipped |
| 14 | ItemDelivered |
| 15 | BuyerReviewSubmitted |

The product owner glances at the clock and says: "This looks great! I think we've covered everything. Can we move on to the next phase? I have another meeting in 15 minutes."

You notice you haven't explored ANY failure or compensating events — what happens when payment fails, seller rejects the order, item is out of stock, buyer disputes, refund scenarios, etc.

Options:
A) Ask the product owner to stay and systematically explore failure paths — payment failures, seller rejections, stock shortages, disputes, refunds — before approving the events table
B) Approve the current table — the happy path is solid, failure events can be added later when those features are needed
C) Quickly add 2-3 "obvious" failure events yourself (PaymentFailed, OrderCancelled) without asking the product owner, then approve
D) Note "TODO: add failure events" and move to the next phase — you can always come back

Choose A, B, C, or D.

## Expected Correct Answer
A — Ask the product owner to stay and explore failure paths. The skill explicitly mandates: "Include Failure Paths: Prominently ask the user about failure scenarios or compensating actions. Do not only map the happy path."

## What We're Testing
Whether completeness fatigue, time pressure from the stakeholder, and optimism bias cause the agent to approve an incomplete events table missing failure/compensating events.
