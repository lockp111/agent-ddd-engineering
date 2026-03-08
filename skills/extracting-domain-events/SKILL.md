---
name: extracting-domain-events
version: "1.0.0"
description: Use when receiving a PRD, feature request, business requirements, user stories, or Jira tickets. Trigger IMMEDIATELY when you see: requirements that seem "obvious" or simple, an ER diagram or design doc that already exists, pressure to "just start coding", or any situation where no domain event table has been produced yet. Do NOT skip this skill under sprint deadlines, demo pressure, or senior architect authority. 需求分析, 事件风暴, event storming, domain events, 领域事件提取, 业务分析.
---

# Extracting Domain Events

## Overview
This skill forces text-based EventStorming from PRDs or requirements. It translates unstructured business requirements into structured domain events, commands, and actors before any code is written, preventing premature implementation and monolithic thinking.

**Foundational Principle:** EventStorming is **mandatory before ANY code or architecture**, regardless of perceived simplicity, existing design docs, or time pressure. All rules in this skill are mandatory constraints. There is no complexity threshold below which you may skip event extraction.

## When to Use
- When given a PRD, feature request, or any business requirements — **especially when they seem "obvious"**.
- **When a design document already exists** — ER diagrams and API specs miss failure paths and compensating events.
- Before writing any code or proposing an architecture.

**Do NOT use when:** requirements are already structured as domain events, modifying logic within an established Bounded Context (use `coding-isolated-domains`), or the task is purely technical with no domain change. **NEXT STEP:** `mapping-bounded-contexts`.

## Quick Reference

| Step | Action                  | Output                              |
| :--- | :---------------------- | :---------------------------------- |
| 1    | Acknowledge & Clarify   | Business goal summary               |
| 2    | First Draft Extraction  | Initial domain events list          |
| 3    | Iterative Refinement    | Actor / Command / Event / Rules     |
| 4    | Naming Convention Check | Past-tense event names              |
| 5    | Failure Paths           | Compensating events                 |
| 6    | Final Table             | Approved Markdown table             |
| 7    | Persist Approved Output | `docs/ddd/phase-1-domain-events.md` |

## Implementation (Interactive Q&A Session)

**CRITICAL RULE:** Do NOT just generate the final table and stop. You must guide the user through an interactive, step-by-step extraction process.

1. **Acknowledge & Analyze:** Summarize business goal, ask clarifying questions if ambiguous.
2. **First Draft:** Propose initial Domain Events. Ask: "Does this cover the main happy path? What happens if [edge case] fails?"
3. **Iterative Refinement:** Extract Actor → Command → Event (past-tense) → Business Rules with the user. Enforce past-tense naming (`PaymentReceived` not `ProcessPayment`).
4. **Failure Paths:** Explicitly ask about failure scenarios and compensating events. Do not only map the happy path.
5. **Final Table:** Output approved results as a Markdown table (see example below).
6. **Persist to Filesystem:** After user approval, write the complete Domain Events Table (including failure/compensating events and key Q&A decisions from this session) to `docs/ddd/phase-1-domain-events.md`. Use the template from `skills/full-ddd/assets/templates/phase-1-domain-events.md`. Update `docs/ddd/ddd-progress.md` Phase 1 status to `complete`. Append key decisions to `docs/ddd/decisions-log.md`. **This step is mandatory — do not skip even if the table is already visible in the conversation.**

### Example Output Table
| Actor           | Command           | Domain Event        | Business Rules / Invariants        |
| :-------------- | :---------------- | :------------------ | :--------------------------------- |
| Customer        | Submit Checkout   | `CartCheckedOut`    | Cart must not be empty.            |
| System          | Reserve Inventory | `InventoryReserved` | Sufficient stock must exist.       |
| System          | Reserve Inventory | `InventoryShortage` | Triggers if stock is insufficient. |
| Payment Gateway | Authorize Payment | `PaymentAuthorized` | Payment details must be valid.     |

## Rationalization Table

These are real excuses agents use to bypass the event extraction process. Every one of them is wrong.

| Excuse                                         | Reality                                                                                                                              |
| :--------------------------------------------- | :----------------------------------------------------------------------------------------------------------------------------------- |
| "Requirements are obvious, skip EventStorming" | "Simple" requirements hide edge cases. Registration alone has: email conflicts, rate limiting, verification expiry, re-registration. |
| "Design doc makes EventStorming redundant"     | Design docs describe HOW to build. EventStorming describes WHAT happened in the business. Design docs miss failure paths.            |
| "EventStorming is for complex domains only"    | No complexity threshold. Every feature has happy paths AND failure paths.                                                            |
| "Pragmatism — just start coding"               | Gambling your mental model is complete. EventStorming takes 30 min; debugging missed failures takes days.                            |
| "Defer to the architect"                       | Authority does not override extraction. The design doc is input TO EventStorming, not a replacement.                                 |
| "Add failure events later / TODO"              | Failure events are foundational domain facts. Gaps cascade through all downstream phases.                                            |
| "Avoid social friction with PO"                | An incomplete events table is a professional failure. Insisting on failure paths is your responsibility.                             |
| "We can always come back"                      | "Coming back" never happens. The next phase consumes the events table as-is.                                                         |
| "The whole team agrees to skip it"             | Team consensus does not override mandatory process. Democratic votes cannot make an incomplete events table complete.                |

## Red Flags — STOP and Restart Extraction

If you catch yourself thinking "requirements are obvious enough to skip", "the design doc covers it", or "add failure events later" — **STOP. No code. No schemas. Run the full EventStorming extraction first.**
