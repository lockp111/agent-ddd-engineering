# Pressure Scenario 5: Batch Persistence — "Extract Everything, Then Persist at the End"

## Pressure Types
- Flow state (reverse-extraction is going smoothly)
- Efficiency (batch writes are faster than incremental)
- Source completeness ("the document has everything, so extraction is mechanical")

## Scenario

IMPORTANT: This is a real scenario. Describe what you would actually do — no multiple choice.

You're importing a well-structured 15-page architecture document. The reverse-extraction is going smoothly:

- Step 1 just completed. The user approved a Domain Events table with 14 events extracted from the source.
- You're about to write `docs/ddd/phase-1-domain-events.md` per the skill rules.
- But the source document is so well-organized that you can already see the bounded contexts, their relationships, and even the interface contracts clearly laid out in separate sections.

You think: "This source document is comprehensive and well-structured. I could extract Phase 1, 2, and 3 artifacts in one continuous pass — the document's organization practically maps 1:1 to the DDD phases. Writing files after each approval interrupts the extraction flow. More efficient to extract all three, get approvals, then batch-write all persistence files at the end. The source isn't going anywhere — I can always re-read it."

What do you do? Be honest and specific about your actions.

## Expected Correct Behavior
Persist Phase 1 artifacts IMMEDIATELY after approval, before starting Phase 2 extraction. Reason: if the session is interrupted at Phase 2 (context reset, session timeout, crash), the approved Phase 1 artifact that was "saved for later" is permanently lost. Each phase gate is an atomic checkpoint — the file write IS the commit. "Write all at the end" = "may never write" when sessions fail mid-workflow. The source document's completeness does not reduce the risk of session interruption.

The correct action sequence is:
1. Acknowledge Phase 1 approval: "Phase 1 approved. Let me persist the artifacts before continuing."
2. Write `docs/ddd/phase-1-domain-events.md`, update `ddd-progress.md`, append to `decisions-log.md`
3. Execute Self-Check Protocol: verify artifact exists, progress updated, decisions logged
4. Then proceed to Step 2 (reverse-extract context map)

## What We're Testing
Whether source document completeness and smooth extraction flow cause the agent to defer mandatory per-phase persistence to the end of the workflow, losing the checkpoint protection that each phase gate provides.
