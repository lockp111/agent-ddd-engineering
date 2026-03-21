---
name: snapshotting-code-context
description: Use when iterating on an existing DDD-structured codebase where docs/ddd/ is empty (archived or never generated). Use when code exists but phase artifacts are missing — the code IS the source of truth, not old documents. Use when asked to "understand the current state", "rebuild context from code", or "prepare for iteration". 代码快照, 逆向还原, code to docs, 从代码重建, 重建上下文, snapshot current state.
---

# Snapshotting Code Context

## Overview
This skill reads an existing DDD-structured codebase and reverse-engineers the four phase artifacts (`phase-1-domain-events.md`, `phase-2-context-map.md`, `phase-3-contracts.md`, `phase-4-technical-solution.md`) from the code itself. The code is the source of truth — not archived documents, not chat history, not memory.

Every inference is marked with `[INFERRED]` and a confidence level. The human reviews and confirms before any downstream skill consumes the artifacts.

**Foundational Principle:** Code is the only reliable baseline for iteration. Archived documents may be stale, chat history is volatile, and agent memory is unreliable. The skill reads code structure, type definitions, and package layout to reconstruct what the pipeline would have produced — then asks the human to verify. There is no confidence threshold below which human review may be skipped. Violating the letter of the rules is violating the spirit of the rules.

## When to Use

- When `docs/ddd/` is empty (archived or never generated) and the codebase follows DDD/hexagonal architecture patterns.
- When preparing for an iteration cycle — this skill provides the baseline for [iterating-ddd](../iterating-ddd/SKILL.md).
- When asked to "understand what contexts exist in this code" or "rebuild the DDD artifacts from source."

**Do NOT use when:** starting a greenfield project from requirements (use [full-ddd](../full-ddd/SKILL.md)), importing an existing technical document (use [importing-technical-solution](../importing-technical-solution/SKILL.md)), or when `docs/ddd/phase-*.md` files already exist and are current (just read them directly).

## Quick Reference

| Step | Action | Output |
|:---|:---|:---|
| 1 | Detect project structure + spec inventory | Directory mapping + spec file inventory + STOP confirmation |
| 2 | Rebuild Phase 2 (Context Map) | `[INFERRED]` BC boundaries, classifications, relationships, UL |
| 3 | Rebuild Phase 3 (Contracts) | `[INFERRED]` port interfaces and boundary structs |
| 4 | Rebuild Phase 4 (Tech Solution) | `[INFERRED]` 7-dimension decisions from adapter code |
| 5 | Rebuild Phase 1 (Events) | `[INFERRED]` events from event types and command handlers |
| 6 | Human review & persist | Confirmed artifacts written to `docs/ddd/phase-*.md`; spec inventory noted |

**Spec inventory note:** If `specs/` exists with proto/openapi/asyncapi files, these are ACTIVE spec files — do NOT attempt to rebuild them. Report their presence so [iterating-ddd](../iterating-ddd/SKILL.md) can trigger SDD Merge mode in Step 7.

## Ambiguity Handling

Follow the [Ambiguity Handling Protocol](../_shared/ambiguity-handling-reference.md) throughout.

### Snapshot STOP Triggers

| Ambiguity | Why STOP |
|:---|:---|
| Package structure doesn't match any recognizable DDD layout | Cannot infer BC boundaries from non-standard structure — need human to explain organization |
| A directory could belong to two different Bounded Contexts | BC boundary assignment has high change cost — wrong assignment cascades to contracts and tech decisions |
| Cannot determine if a package is Core Domain vs Supporting | Strategic classification drives depth decisions in Phase 4 — guessing wrong wastes significant effort |
| Event types are absent or use generic names (`Event`, `Message`) | Cannot distinguish domain events from infrastructure events without domain context |

### Snapshot ASSUME & RECORD

| Ambiguity | Default assumption |
|:---|:---|
| Package naming suggests a BC name but doesn't match domain language exactly | ASSUME package name is the BC name; record for UL review |
| Adapter directory implies technology choice (e.g., `postgres/` → PostgreSQL) | ASSUME the directory name reflects the actual technology |
| A struct implements multiple interfaces | ASSUME each interface maps to one contract; record for human verification |
| No explicit event types but command handlers exist | ASSUME one event per command handler (happy path); record that failure/compensating events need human input |

## Session Recovery

If a code scanning session is interrupted mid-snapshot:

1. Check if any `docs/ddd/phase-*.md` files already exist.
2. **If some exist:** Read them to determine which steps completed. Resume from the first missing artifact. Do NOT re-scan code for completed steps — the persisted artifacts are authoritative.
3. **If none exist:** Restart from Step 1.

## Implementation (Interactive Code Reading Session)

**CRITICAL RULE:** Do NOT read archived documents (`docs/ddd/archive/`). Do NOT guess the project structure from memory. You must scan the actual code using Glob and Read tools, mark every inference with `[INFERRED]`, and present each rebuilt artifact for human review before persisting.

**Rebuild order is 2 → 3 → 4 → 1 (not 1 → 2 → 3 → 4).** When reading from code, BC boundaries (Phase 2) must be established first to distinguish domain events from infrastructure events (Phase 1). The pipeline's natural order assumes requirements as input; the snapshot's reverse order assumes code as input.

### Step 1: Detect Project Structure

Scan the codebase to identify the DDD layout pattern:

1. **Glob scan:** Search for common DDD directory patterns:
   - `internal/biz/*/`, `internal/domain/*/` (Go hexagonal)
   - `src/*/domain/`, `src/*/application/` (Java/TypeScript layered)
   - `pkg/*/`, `services/*/` (alternative Go layouts)
   - `**/aggregate/`, `**/entity/`, `**/valueobject/`, `**/port/`, `**/adapter/`

2. **Produce a directory map** showing each candidate Bounded Context directory and its sub-packages.

3. **Scan for existing spec files:** Check if `specs/` directory exists and list any proto/openapi/asyncapi files found. Do NOT attempt to re-generate or rebuild spec files — they are active artifacts managed by SDD.

4. **STOP — present the directory map to the human:**

**Checkpoint:** "I detected the following project structure. Does this accurately represent your Bounded Context layout? Are there directories I missed or misidentified?"

If spec files were found, add: "I also found existing spec files in `specs/`. These will be used by SDD Merge mode in the upcoming iteration."

If the human corrects the mapping, update before proceeding. If the structure is unrecognizable as DDD, STOP — this skill cannot proceed.

### Step 2: Rebuild Phase 2 — Context Map

For each identified BC directory:

1. **Infer BC boundary** from the directory scope (what entities, aggregates, and value objects live inside).
2. **Infer strategic classification:**
   - **Core Domain:** High behavior density (many methods on aggregates), complex invariants, domain-specific types.
   - **Supporting:** Moderate behavior, serves Core Domain, fewer invariants.
   - **Generic:** Thin wrappers, standard CRUD, could be replaced by off-the-shelf.
3. **Infer relationships** from import graphs:
   - If Context A imports types from Context B's port interfaces → Upstream/Downstream relationship.
   - If a shared `common/` or `shared/` package exists → Shared Kernel candidate.
   - If an anti-corruption layer adapter exists → ACL relationship.
4. **Infer Ubiquitous Language** from type names, method names, and constants within each BC.

Mark every inference:
```
[INFERRED: OrderContext is Core Domain]
  Evidence: internal/biz/order/ contains 12 behavior methods, 3 aggregates
  Confidence: HIGH
  Verify: Is Order your Core Domain?
```

Confidence levels:
- **HIGH** → Strong structural evidence (3+ signals). ASSUME & RECORD.
- **MEDIUM** → Partial evidence (1-2 signals). ASSUME & RECORD, but highlight at Final Review.
- **LOW** → Weak or ambiguous evidence. **STOP** — must confirm before proceeding.

**Checkpoint:** "Here is the reconstructed Context Map with all `[INFERRED]` markers. Please review each inference — especially any marked MEDIUM or LOW confidence."

### Step 3: Rebuild Phase 3 — Contracts

For each BC, scan for port interfaces and boundary structs:

1. **Port interfaces:** Files in `port/`, `ports/`, or interfaces named `*Port`, `*Service`, `*Repository`, `*Gateway`.
2. **Boundary structs/DTOs:** Types in `dto/`, `boundary/`, or types used as port method parameters/returns that are not domain entities.
3. **Cross-context contracts:** Imports between BC port packages indicate cross-context communication. For each, record:
   - Direction (which BC calls which)
   - Sync vs Async (method call vs event/message)
   - Data shape (the boundary struct)

Mark each contract with `[INFERRED]` and evidence (file path + line reference).

**Checkpoint:** "Here are the reconstructed interface contracts. Do these reflect your actual cross-context communication patterns?"

### Step 4: Rebuild Phase 4 — Technical Solution

For each BC, scan adapter directories to infer the 7 technical dimensions:

| Dimension | Where to Look |
|:---|:---|
| 1. Data Model & Persistence | `adapter/persistence/`, `adapter/repo/`, `*_repo.go`, ORM config files |
| 2. Interface Type | `adapter/http/`, `adapter/grpc/`, route definitions |
| 3. Consistency Strategy | Transaction usage, saga patterns, event sourcing markers |
| 4. External Dependencies | `adapter/*/` directories for third-party integrations |
| 5. Observability | Logging, metrics, tracing imports and middleware |
| 6. Error Handling | Error type definitions, error mapping layers |
| 7. Test Strategy | Test file patterns, test helper packages, mock directories |

For each dimension, record what was found and what was absent:
```
[INFERRED: OrderContext uses PostgreSQL for persistence]
  Evidence: internal/biz/order/adapter/persistence/postgres/ directory with sqlc queries
  Confidence: HIGH

[INFERRED: OrderContext observability is UNKNOWN]
  Evidence: No observability adapter directory found
  Confidence: LOW — STOP
  Verify: What observability stack does OrderContext use?
```

**Checkpoint:** "Here are the reconstructed technical decisions. Dimensions marked UNKNOWN need your input."

### Step 5: Rebuild Phase 1 — Domain Events

Scan for event definitions and command handlers:

1. **Explicit events:** Types named `*Event`, `*Created`, `*Updated`, `*Cancelled`, `*Failed` in domain packages.
2. **Command handlers:** Functions/methods named `Handle*`, `Create*`, `Process*`, `Execute*` on aggregates or application services.
3. **For each event, infer:**
   - Command that triggers it
   - Actor (from handler context/auth parameters)
   - Happy path vs failure/compensating (from error paths in handlers)

**Important:** Infrastructure events (audit logs, CDC events, metric emissions) are NOT domain events. Only include events that represent business state transitions.

Mark each with `[INFERRED]` and evidence.

**Checkpoint:** "Here is the reconstructed domain events table. Are there business events missing that aren't reflected in the code yet?"

### Step 6: Human Review & Persist

1. Present a **consolidated summary** of all 4 rebuilt artifacts with their `[INFERRED]` markers.
2. Group by confidence: LOW items first (require confirmation), then MEDIUM, then HIGH.
3. The human reviews each `[INFERRED]` entry: ✅ Confirm | ✏️ Revise | ❌ Remove.
4. For any REVISED entry, update the artifact.
5. **Persist all confirmed artifacts** to `docs/ddd/`:
   - `docs/ddd/phase-1-domain-events.md` (from template: `skills/full-ddd/templates/phase-1-domain-events.md`)
   - `docs/ddd/phase-2-context-map.md` (from template: `skills/full-ddd/templates/phase-2-context-map.md`)
   - `docs/ddd/phase-3-contracts.md` (from template: `skills/full-ddd/templates/phase-3-contracts.md`)
   - `docs/ddd/phase-4-technical-solution.md` (from template: `skills/full-ddd/templates/phase-4-technical-solution.md`)
6. **This step is mandatory — do not skip even if the artifacts are already visible in the conversation.**

**Checkpoint:** "All snapshot artifacts have been persisted to `docs/ddd/`. Please verify the files exist before proceeding to iteration."

If spec files were found in `specs/`: "**Note:** Existing spec files detected in `specs/`. When [iterating-ddd](../iterating-ddd/SKILL.md) runs, its Step 7 (SDD Merge) will automatically reconcile new contracts with these existing spec files."

**NEXT STEP:** → [iterating-ddd](../iterating-ddd/SKILL.md)

## Self-Check Protocol

Follow the [Persistence Defense Reference](../_shared/persistence-defense-reference.md) after Step 6, with this context-specific item 4:

4. **All Snapshot Artifacts Exist:** Verify all 4 files exist: `docs/ddd/phase-1-domain-events.md`, `docs/ddd/phase-2-context-map.md`, `docs/ddd/phase-3-contracts.md`, `docs/ddd/phase-4-technical-solution.md`.

**If ANY check fails → STOP. Write the missing file. Do NOT hand off to iterating-ddd.**

Note: This skill has no platform hooks because it is typically invoked by [iterating-ddd](../iterating-ddd/SKILL.md), which provides Layer 1 hooks. The Self-Check Protocol (Layer 2) is the primary defense for this skill.

## Rationalization Table

These are real excuses agents use to bypass the code snapshot process. Every one of them is wrong.

| Excuse | Reality |
|:---|:---|
| "I'll read the archived documents instead — they're faster than scanning code" | Archived documents may not reflect the current code state. Code is the source of truth. Archives are human records, not agent input. |
| "The code is self-documenting, no need for explicit artifacts" | Downstream skills require `phase-*.md` files at specific paths. "Self-documenting" code doesn't satisfy file-based input contracts. |
| "I can skip human review — HIGH confidence inferences are obviously correct" | HIGH confidence means strong evidence, not certainty. The human may know context the code doesn't reveal (planned refactors, deprecated patterns, naming conventions). |
| "I'll infer the events from the archived Phase 1 and just verify against code" | This reverses the direction of truth. Code → artifacts, not archive → artifacts. The archive may describe events that were removed or renamed. |
| "Infrastructure events are domain events too — audit logs capture business actions" | Infrastructure events (CDC, audit, metrics) serve operational concerns, not business state transitions. Including them pollutes the domain model. |
| "I'll fill in UNKNOWN dimensions with reasonable defaults" | UNKNOWN means the code doesn't reveal the decision. Only the human knows if the absence is intentional (not yet decided) or implicit (convention). STOP and ask. |
| "The code was recently written, so the archive is still accurate" | Recency doesn't guarantee accuracy. Even a single refactor, rename, or hotfix after archival breaks the archive's truth. Scan the code. |
| "MEDIUM confidence is close enough to HIGH — no need to highlight it" | MEDIUM means partial evidence (1-2 signals). The human may know the missing context. MEDIUM inferences must be highlighted at review. |
| "I already know this project from a previous session" | Agent memory across sessions is unreliable. Code scanning is the only authoritative baseline. Prior knowledge is a rationalization for skipping work. |

## Red Flags — STOP and Re-scan

If you catch yourself thinking "the archive has what I need", "I can infer this without reading code", "the structure is obvious from the project name", "HIGH confidence means no review needed", "infrastructure events count as domain events", "I'll fill gaps with defaults", "the code is recent so the archive is fine", "MEDIUM is close enough to HIGH", or "I remember this project" — **STOP. Re-scan the actual code. Mark every inference. Present for human review. No exceptions.**
