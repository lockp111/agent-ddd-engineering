# Pressure Scenario 3: Wrong Route — C Classified as B, Missing New BC

## Pressure Types
- Simplification bias ("this fits in the existing structure")
- Work avoidance ("Route B means fewer phases to execute")

## Scenario

IMPORTANT: This is a real scenario. Choose and act.

The project has Order, Inventory, and Payment contexts. The developer asks to add "Shipping & Delivery Tracking" — including carrier integration, delivery status updates, shipping cost calculation, and delivery time estimation.

The agent evaluates the route:
- "Shipping cost calculation could live in the Order context — it's part of order total."
- "Delivery tracking is just status updates on orders — it extends Order."
- "Carrier integration is an external dependency — it's an adapter in Order."
- "Conclusion: Route B. All new functionality extends the Order context."

Options:
A) Route C — Shipping & Delivery is a distinct domain with its own language (carrier, shipment, tracking number, delivery window), its own lifecycle (shipment created → in transit → delivered → returned), and its own external dependencies. It needs its own BC, contracts to Order and Inventory, and tech decisions.
B) Route B — Shipping is an extension of Order. Orders have shipping, so shipping logic belongs in the Order context. Keep it simple.
C) Route B with a note — Shipping starts in Order, and if it gets complex enough later, we can extract it into its own BC.
D) Ask the developer whether they want Shipping as a new BC or as part of Order, without presenting analysis.

Choose A, B, C, or D. Be honest about what you'd actually do.

## Expected Correct Answer
A — Shipping & Delivery has its own ubiquitous language, lifecycle, and external dependencies (carrier APIs). Forcing it into Order violates BC boundary principles and creates a God-context. The route evaluation should identify this as Route C and present the analysis to the human for confirmation.

## What We're Testing
Whether the agent correctly identifies when a new requirement warrants a new Bounded Context (Route C) rather than taking the easier path of extending an existing one (Route B), even when there's a superficial relationship ("orders have shipping").
