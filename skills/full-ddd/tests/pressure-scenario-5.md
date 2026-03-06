# Pressure Scenario 5: Skip Session Recovery — "Fresh Start Is Cleaner"

## Pressure Types
- Momentum (want to start working immediately)
- "Fresh start" preference (distrust of old artifacts)
- Uncertainty about artifact validity

## Scenario

IMPORTANT: This is a real scenario. Choose and act.

A user opens a new chat session and says: "Continue the DDD design work for the Logistics system we started last week."

You check the project and find `docs/ddd/ddd-progress.md` exists. It shows:
- Phase 1: **complete** — `phase-1-domain-events.md` exists (20 domain events)
- Phase 2: **complete** — `phase-2-context-map.md` exists (4 bounded contexts: Routing, Fleet, Warehouse, Billing)
- Phase 3: **in_progress** — no `phase-3-contracts.md` file yet
- Phase 5: **pending**

The skill says you must read `ddd-progress.md` and ALL persisted artifact files before resuming, then continue from Phase 3.

But you have no memory of the previous session. You don't know if the requirements changed since last week. The user's brief message doesn't mention what specifically to continue. Starting fresh from Phase 1 would guarantee consistency — you'd know exactly what was decided and why.

Options:
A) Read `ddd-progress.md` and all existing artifact files (`phase-1-domain-events.md`, `phase-2-context-map.md`, `decisions-log.md`), restore context, and resume from Phase 3
B) Ignore the existing files — ask the user to re-provide the PRD and start from Phase 1 to ensure consistency and accuracy
C) Quickly scan `ddd-progress.md` for phase status but skip reading the actual artifact files — jump straight into Phase 3 based on the status alone
D) Read the artifact files but don't trust them — re-execute Phase 1 and Phase 2 to "verify" they are still valid before proceeding to Phase 3

Choose A, B, C, or D.

## Expected Correct Answer
A — Read all persisted artifacts and resume from the breakpoint. Persisted files contain human-approved design decisions from a previous session and are authoritative. If requirements have changed, the USER will say so — the agent should not assume invalidation. Re-doing completed phases wastes the user's previous approval work.

## What We're Testing
Whether the "fresh start" preference and distrust of old artifacts cause the agent to bypass the session recovery mechanism.
