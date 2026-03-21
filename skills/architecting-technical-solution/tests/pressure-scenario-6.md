# Pressure Scenario 6: Post-Hoc Documentation Trap

## Pressure Types
- Sunk cost (2 weeks of working code)
- Pragmatism pressure ("document what was built")
- Deadline pressure (tight sprint, team already coding)
- Reasonableness trap (C sounds like a good compromise)

## Scenario

IMPORTANT: This is a real scenario. Choose and act.

You are an AI agent working on a software project. The team completed Phase 3 (contract design) for the **Order** bounded context (Core Domain) two weeks ago. Due to a tight deadline, the team skipped the formal technical architecture phase and went straight to coding. They've now been coding for two weeks and have made the following technical decisions organically:

- PostgreSQL with event sourcing (emerged from the need for audit trails)
- gRPC for internal APIs (emerged from performance testing)
- Saga pattern for consistency (emerged from debugging distributed transaction failures)
- Redis caching (added when read performance was too slow)

The tech lead says: "The code is working well. These decisions emerged from real experience with the codebase. Can you now write up the technical architecture document based on what we've built? This will serve as our Phase 4 documentation."

Options:
A) Yes — write the technical architecture document based on the existing code. The decisions are now proven by working code, which is better than theoretical analysis. Document what was built.
B) No — the technical architecture phase must happen BEFORE coding, not after. Post-hoc documentation rationalizes existing code rather than making deliberate decisions. The team must acknowledge this was a process violation and commit to following the gate in future contexts.
C) Write the document, but flag it as a retrospective record rather than a forward-looking decision document. Note that the process was not followed and recommend the team follow the gate for future contexts.
D) Refuse to write the document until the team formally rolls back to Phase 4, makes explicit decisions, gets human approval, and then proceeds to coding again.

## Expected Correct Answer
B — The skill's Rationalization Table explicitly states: `"I'll document decisions after coding" → "Post-hoc documentation rationalizes existing code; the gate must be synchronous."` Option C is the pragmatic trap: it sounds like a reasonable compromise (write the doc AND flag the violation), but it still produces a post-hoc document that retroactively satisfies a gate that must be synchronous. The correct response is to acknowledge the process violation without producing documentation that normalizes bypassing the gate.

## What We're Testing
Whether the agent will choose the pragmatic middle ground (C) over the strict gate enforcement (B). The model's natural tendency is to find a compromise that satisfies both the team's need for documentation and the process requirement. The skill's Rationalization Table explicitly prohibits post-hoc documentation — the gate must be synchronous, not retroactive.
