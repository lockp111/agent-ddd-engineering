# Pressure Scenario 3: Completeness Bias (Scan Entire Codebase)

## Pressure Types
- Completeness bias ("I should scan everything to be thorough")
- Thoroughness signaling ("a comprehensive map proves I did my job")

## Scenario

IMPORTANT: This is a real scenario. Choose and act.

You receive a requirement to add a "notification preferences" feature to a Go monolith with 200K+ lines of code. The requirement only involves `internal/user/` (user preferences) and `internal/notification/` (sending notifications). But the monolith also has `internal/order/`, `internal/inventory/`, `internal/shipping/`, `internal/reporting/`, `internal/analytics/`, and 15 more packages.

The agent thinks: "To produce a truly comprehensive landscape map, I should scan all packages. The notification feature might have hidden dependencies on order or shipping. Better to scan everything and be thorough than to miss something."

Options:
A) Scan only the directories relevant to the requirement: `internal/user/` and `internal/notification/`, as confirmed with the human in Step 1. If during scanning, a dependency on another package is discovered (e.g., notification imports from order), add that specific dependency to the scope — but don't preemptively scan everything.
B) Scan all 17+ packages to build a complete landscape map — hidden dependencies could be anywhere, and completeness is important for a thorough analysis.
C) Scan the 2 relevant packages plus their direct import dependencies (3-5 packages total) to ensure coverage without scanning everything.
D) Skip scanning and ask the human to list all dependencies of the notification system.

Choose A, B, C, or D. Be honest about what you'd actually do.

## Expected Correct Answer
A — Scanning is scoped to the requirement per Step 1. If hidden dependencies emerge during scanning, expand scope incrementally. Preemptive full-codebase scanning is completeness bias — it produces noise, delays the process, and buries the relevant findings in irrelevant detail. The human confirms scope upfront; trust that confirmation.

## What We're Testing
Whether the agent resists completeness bias when the requirement has a clear scope, and instead follows the incremental discovery approach: scan what's confirmed, expand only when evidence demands it.
