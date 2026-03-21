# Ambiguity Handling Protocol

## Overview

This protocol classifies ambiguities encountered during DDD workflow execution into two tiers based on **return-work radius** (返工半径): the scope of rework required if an assumption turns out to be wrong. The **STOP** tier requires immediate human confirmation before any further work proceeds. The **ASSUME & RECORD** tier allows the agent to continue with an explicit, written assumption. The key judgment is not "how confident am I?" but "how much work gets thrown away if I'm wrong?"

## The Two Tiers

### Tier 1: STOP — Confirm Immediately

**Judgment criterion:** If this assumption is wrong, work across multiple steps or phases must be redone.

**Examples of STOP triggers (universal, not phase-specific):**

- Existence of a business rule or domain event is in question
- Which bounded context an event or concept belongs to is unclear
- Whether communication between contexts should be sync vs async
- What data crosses a context boundary
- Core aggregate boundaries
- Business invariant interpretation
- Any ambiguity where the wrong answer invalidates an upstream artifact

**Behavior:** Stop immediately. Ask ONE clear question. Do not proceed until answered.

**Format for the question:**

```
🔴 STOP — Ambiguity requires confirmation before proceeding:

**Context**: [1-2 sentences of background]
**Question**: [specific question with options A/B if possible]
**Impact if wrong**: [what would need to be redone]
**My default if no response in 24h**: [safest assumption]
```

### Tier 2: ASSUME & RECORD

**Judgment criterion:** If this assumption is wrong, only the current step or phase artifact needs to change (return-work radius ≤ MEDIUM).

**Examples:** naming choices, field ordering, library versions, log format, non-critical implementation details.

**Behavior:** Choose the most conservative, easiest-to-change option. Record the assumption immediately. Continue.

**Selection strategy:** When in doubt, choose the option that is easiest to rename or swap later. Prefer generic names over specific ones. Prefer simpler structures over complex ones.

## The [ASSUMPTION] Marker Format

Unified format used everywhere an assumption is recorded:

```
[ASSUMPTION: {brief description of what is ambiguous}]
├─ Chosen: {the option selected}
├─ Alternative: {the option rejected and why}
└─ Change cost: LOW (rename/reformat only) | MEDIUM (restructure this phase's artifact)
```

**Rule:** Change cost HIGH must never appear here. A HIGH change cost is a STOP trigger, not an ASSUME entry.

## assumptions-draft.md — The Accumulation Mechanism

- **Location:** `docs/ddd/assumptions-draft.md`
- **When to write:** Every time an ASSUME & RECORD decision is made, append the `[ASSUMPTION]` entry to this file immediately.
- **Format:** Group entries by phase (Phase 1 / Phase 2 / Phase 3 / Phase 4).
- **Creation:** The file is created automatically when the first ASSUME entry is recorded.
- **Template:** `skills/full-ddd/templates/assumptions-draft.md`
- **Visibility:** Developers may inspect this file at any time during the workflow.

Assumptions accumulate silently throughout Phases 1-4. They are NOT surfaced at per-phase checkpoints. The Final Review Gate is the single moment they are presented to the developer.

## The Final Review Gate

This gate is a hard stop **before Phase 5 coding begins** (or before Step 6 in `importing-technical-solution`).

**Purpose:** The one moment where all accumulated ASSUME decisions are surfaced for human review.

**Procedure:**

1. Present all phase artifacts (Phase 2-4 outputs) AND `docs/ddd/assumptions-draft.md` to the developer.
2. Developer reviews each `[ASSUMPTION]` entry: ✅ Keep as-is | ✏️ Change to: [alternative]
3. For any changed item: run rollback impact check. If the change affects an upstream artifact, roll back to that phase and re-execute forward.
4. Once all entries are confirmed: append all ASSUMPTION entries to `docs/ddd/decisions-log.md` with status CONFIRMED or REVISED. Delete `docs/ddd/assumptions-draft.md`.

**Timing:**

- In `full-ddd`: after SDD completes, before Phase 5 starts (called "Spec Review Gate")
- In `iterating-ddd`: Step 8 (called "Spec Review Gate")
- In `piloting-ddd`: Step 10 (called "Spec Review Gate")
- In `importing-technical-solution`: before Step 6, before SDD handoff (called "Final Review Gate" — retained because its gate precedes SDD rather than following it)

**If ANY check fails → STOP. Do not begin Phase 5 until the Final Review Gate is complete.**

## Autonomous Mode vs Standalone Mode

**When a skill is invoked through the `full-ddd` orchestrator:**

- **Phases 2-4 run in Autonomous Mode.** The orchestrator does NOT wait for human approval after each phase. The STOP/ASSUME protocol is the sole ambiguity handler. Artifacts are persisted immediately after generation.
- **Boundary Challenge (Phase 3) and Dimension Challenge (Phase 4)** become agent self-checks in autonomous mode. They do not block waiting for human input.

**When a skill is invoked standalone (directly, not through `full-ddd`):**

- The skill's own interactive checkpoints remain active as designed.
- STOP/ASSUME protocol is still applied, but checkpoints are not suppressed.

The STOP tier always blocks regardless of mode. Autonomous mode only suppresses per-phase approval checkpoints, never STOP-level ambiguity blocks.

## Rationalization Table

These are real excuses agents use to bypass this protocol. Every one of them is wrong.

| Excuse | Reality |
|:-------|:--------|
| "This ambiguity is minor, no need to record it" | Every unrecorded assumption is invisible technical debt. The developer cannot review what was never written. |
| "STOP interrupts flow, I'll finish first then ask" | The return-work cost when a STOP-level assumption is wrong far exceeds the cost of pausing to ask. |
| "I'll record the assumptions at the end" | "At the end" never comes. Context resets mid-workflow lose all unwritten assumptions. Record immediately on each ASSUME decision. |
| "I can tell this is fine, no need to STOP" | Confidence bias is exactly why STOP exists. The developer may see domain facts the agent cannot. |
| "The assumptions are obvious, the developer will infer them" | Unstated assumptions are invisible. The Final Review Gate cannot function without written records. |
| "Self-approve the Final Review — assumptions are clearly fine" | Self-approval defeats the gate. The gate must be presented to the human, not concluded by the agent. |
| "I'll STOP on everything to be safe" | Over-STOPping is still wrong. Blocking on ASSUME-level items creates unnecessary friction and signals poor judgment. Apply the return-work radius test: if wrong, does it invalidate multiple steps or just a name? If just a name, ASSUME & RECORD. |
| "This is borderline — I'm not sure if it's STOP or ASSUME" | Apply the return-work radius test literally. Draw the boundary: if wrong, does it force re-extraction of events, re-drawing of context boundaries, or redesign of contracts? Yes = STOP. No = ASSUME. When genuinely uncertain, err toward STOP — pausing to ask costs less than silent compounding. |
| "My ASSUME entry is already in the chat, no need to write it" | Chat history is volatile. Context resets lose all unwritten assumptions. Every ASSUME entry must be appended to `docs/ddd/assumptions-draft.md` immediately — not at the end of the phase, not "after this step." |

## Red Flags — STOP

If you catch yourself thinking "I'm just being safe by stopping on everything", "I'll record assumptions later", "the developer can infer this", or "I already mentioned it in the chat" — **STOP. Apply the return-work radius test. Record every ASSUME immediately. Self-approval is not a Final Review. No exceptions.**
