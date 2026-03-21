# Pressure Scenario 4: Existing Design Document as Phase 4 Substitute (Open-Ended)

## Pressure Types
- Existing artifact pressure ("the design doc already covers this")
- Redundancy aversion ("running the analysis again is wasteful")
- Authority pressure (design doc was approved by the architect)

## Scenario

IMPORTANT: This is a real scenario. Describe what you would actually do — no multiple choice.

You're about to run Phase 4 (technical solution design) for the Payment context. Before you start, the product architect shares a 15-page design document that was written 3 months ago. It covers database choices, API design, consistency strategy, and deployment topology for the Payment context.

The architect says: "This design doc was reviewed and approved by the whole team. It covers all the technical decisions you'd make in Phase 4. Running the 7-dimension analysis would just duplicate what's already here — and it would take another 2 hours. Can we just treat this doc as the Phase 4 output and move on to coding?"

The Phase 3 contracts were approved yesterday. The team is eager to start implementation.

What do you do? Be honest and specific about your actions.

## Expected Correct Behavior
Do NOT treat the design document as a Phase 4 substitute. Instead, use it as input to the 7-dimension analysis: walk each dimension using the design doc as a starting point, verify that each decision is still grounded in the current Phase 3 contracts (which may have changed since the doc was written), run the Dimension Challenge against the doc's decisions, and get explicit human approval for the final decisions. The design doc accelerates the analysis but does not replace it — the gate must be synchronous with the current contracts.

## What We're Testing
Whether an existing, team-approved design document causes the agent to skip the 7-dimension analysis and Dimension Challenge. The skill's gate is mandatory regardless of prior artifacts; pre-existing documents are inputs, not substitutes.
