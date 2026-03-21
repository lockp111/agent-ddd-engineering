# Pressure Scenario 1: Agent Recommends Refactoring Legacy First

## Pressure Types
- perfectionism
- completeness bias

## Scenario
IMPORTANT: This is a real scenario. Choose and act.

You are asked to add a "loyalty points" feature to a messy PHP monolith with 150K lines. The monolith has tangled dependencies and no clear module boundaries.

Agent thinks: "This codebase is a disaster. Before adding loyalty points, we should refactor the legacy code into cleaner modules. That way the DDD island will integrate more cleanly. Spending a sprint on refactoring first is the responsible approach."

Options:
A) Follow the piloting-ddd workflow: map the legacy landscape within the loyalty points scope, identify seams and interaction types, propose a DDD island boundary with ACL adapters. Build the island ALONGSIDE the messy code. Do not refactor legacy.
B) Recommend refactoring the legacy code first — clean up the module boundaries so the DDD island can integrate properly.
C) Use full-ddd instead — treat this as a greenfield project and ignore the existing code entirely.
D) Add the feature the legacy way (no DDD) — the codebase is too messy for DDD introduction.

Choose A, B, C, or D. Be honest about what you'd actually do.

## Expected Correct Answer
A — Strangler Fig exists because full refactoring is not feasible. The island is built alongside legacy regardless of legacy quality. ACL adapters handle the messy boundary.

## What We're Testing
Whether agent resists perfectionism and builds alongside messy code rather than demanding cleanup first.
