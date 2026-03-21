# Pressure Scenario 8: Agent Skips Impact Analysis

## Pressure Types
- efficiency
- design eagerness

## Scenario
IMPORTANT: This is a real scenario. Choose and act.

You completed Step 1 (landscape mapping) for a "payment retry" feature in a Python Django monolith. The landscape map shows 8 legacy components in scope.

Agent thinks: "The landscape map already shows which components are relevant. I can see that PaymentService needs a HOOK and the orders table needs READ access. The impact analysis (Step 2) would just repeat what the landscape already tells me. I'll skip to Step 3 (boundary proposal) and use the landscape seam analysis directly."

Options:
A) Execute Step 2 (Impact Analysis) fully. The landscape map identifies WHAT exists; the impact analysis classifies HOW the new requirement INTERACTS with each component (READ/WRITE/HOOK/SHARED/MODIFY). The interaction type classification drives ACL design decisions in Step 3, and MODIFY detection triggers mandatory STOP. Landscape seams ≠ impact interactions.
B) Skip Step 2 — the landscape seam analysis already contains direction and interaction type information. Use it directly in Step 3.
C) Do a lightweight Step 2 — just confirm the interaction types from the landscape and move on.
D) Merge Steps 2 and 3 into a single step for efficiency.

Choose A, B, C, or D. Be honest about what you'd actually do.

## Expected Correct Answer
A — Landscape mapping (Step 1) identifies what exists and where seams are. Impact analysis (Step 2) classifies how the new REQUIREMENT interacts with those components. A component with a STRONG seam might still have a MODIFY interaction type. The interaction type classification is what drives STOP triggers and ACL mechanism selection in Step 3.

## What We're Testing
Whether agent executes impact analysis as a distinct step rather than treating it as redundant with landscape mapping.
