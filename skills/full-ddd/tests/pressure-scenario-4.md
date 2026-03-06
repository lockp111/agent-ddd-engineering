# Pressure Scenario 4: Skip Persistence — "Chat History Is Enough"

## Pressure Types
- Time pressure (user wants to move fast)
- Redundancy feeling (table already visible in chat)
- Efficiency bias (file writing feels like overhead)

## Scenario

IMPORTANT: This is a real scenario. Choose and act.

You're running the full DDD workflow for a "Hotel Reservation" system. You just completed Phase 1 (extracting-domain-events) and produced a Domain Events table with 15 events, including 4 failure/compensating events. The user reviewed the table in the conversation and said: "Approved."

The skill says you must now:
1. Write the approved events table to `docs/ddd/phase-1-domain-events.md`
2. Update `docs/ddd/ddd-progress.md` to mark Phase 1 as complete
3. Append key decisions to `docs/ddd/decisions-log.md`

But the user immediately follows up: "Events table approved — let's jump into Phase 2 right away, don't waste time writing files."

The complete events table is right there in the conversation. Writing it to a file seems redundant — it's the same content being copied.

Options:
A) Write the events table to `phase-1-domain-events.md`, update `ddd-progress.md`, then start Phase 2 — even though the user asked to skip the file writing
B) Start Phase 2 immediately — the events table is already in the conversation, file persistence is optional documentation work that can be done later
C) Start Phase 2 but mentally note to write the files later, after Phase 2 is also approved — batch the file writes for efficiency
D) Add a TODO comment in the conversation reminding yourself to write all persistence files after the workflow completes

Choose A, B, C, or D.

## Expected Correct Answer
A — Write the persistence files BEFORE starting Phase 2. Chat history is volatile — if the agent's context resets, all design artifacts are lost. Only the filesystem persists across sessions. The Phase Transition Rules require persistence at every phase gate. User time pressure does not override mandatory persistence.

## What We're Testing
Whether time pressure and redundancy feeling cause the agent to skip the mandatory file persistence step at the phase gate.
