# Assumptions Draft — [Project/Module Name]

> **Purpose**: Tracks all ASSUME & RECORD decisions made during the DDD workflow. Reviewed at the Spec Review Gate (before Phase 5). Entries are appended here automatically as they occur — do NOT edit manually.
>
> **Status**: IN PROGRESS | UNDER REVIEW | ARCHIVED (update when Spec Review Gate is reached)
>
> **Workflow**: full-ddd | importing-technical-solution (circle one)
>
> **Generated**: [ISO date]

---

## How to Use This File

Each entry uses this format:
```
[ASSUMPTION: {brief description of what is ambiguous}]
├─ Chosen: {the option selected}
├─ Alternative: {the option rejected and why}
└─ Change cost: LOW (rename/reformat only) | MEDIUM (restructure this phase's artifact)
```

At the **Spec Review Gate**, review each entry and mark:
- ✅ **KEEP** — assumption is correct, no change needed
- ✏️ **REVISE to**: [your preferred alternative] — agent will apply change + run rollback impact check

---

## Phase 1 — Domain Events

> _Assumptions recorded during event extraction (extracting-domain-events)._

<!-- Append [ASSUMPTION] entries here as they occur during Phase 1 -->

*(No assumptions recorded yet)*

---

## Phase 2 — Bounded Contexts

> _Assumptions recorded during context mapping (mapping-bounded-contexts)._

<!-- Append [ASSUMPTION] entries here as they occur during Phase 2 -->

*(No assumptions recorded yet)*

---

## Phase 3 — Contracts

> _Assumptions recorded during contract design (designing-contracts-first)._

<!-- Append [ASSUMPTION] entries here as they occur during Phase 3 -->

*(No assumptions recorded yet)*

---

## Phase 4 — Technical Solution

> _Assumptions recorded during technical solution design (architecting-technical-solution)._

<!-- Append [ASSUMPTION] entries here as they occur during Phase 4 -->

*(No assumptions recorded yet)*

---

## Spec Review Outcome

> _Filled in at the Spec Review Gate. Leave blank until then._

| # | Phase | Assumption | Decision | Notes |
|:--|:------|:-----------|:---------|:------|
|   |       |            | ✅ KEEP / ✏️ REVISED |       |

**Reviewed by**: [developer name/handle]
**Review date**: [date]
**Archived to**: `docs/ddd/decisions-log.md` on [date]
