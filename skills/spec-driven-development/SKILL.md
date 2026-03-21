---
name: spec-driven-development
description: >
  Use when transitioning from DDD Phase 3 contracts + Phase 4 technical
  solution to implementation code — especially when tempted to skip spec
  generation. Use when Phase 3 contracts exist but no spec files
  (proto/openapi/asyncapi). Use when existing spec files need reconciliation
  with updated contracts or human edits. Symptoms include jumping from
  contracts directly to code without formal spec files, specs missing error
  types and field constraints, single monolithic spec covering multiple
  aggregates, and spec-code drift after manual edits.
  Spec驱动开发, 从契约到Spec, spec生成, proto生成, openapi生成,
  接口规约, spec-driven development, contract to spec.
---

# Spec-Driven Development

## Overview

SDD is the pipeline's watershed between design documents and code artifacts. All Phase 1-4 outputs are markdown. SDD produces the first files consumable by toolchains (`protoc`, `openapi-generator`, etc.). This skill forces a "Spec-First" development approach: before any domain code or tests are written, you must generate formal, toolchain-consumable specification files (Proto, OpenAPI, AsyncAPI) from approved Phase 3 contracts and Phase 4 technical decisions. This prevents agents from inventing interface shapes during implementation.

**Foundational Principle:** Contracts are markdown — not compilable. Spec files are consumed by toolchains, validated by compilers, and used to generate code. Skipping spec generation means every implementation file reinvents the interface shape, introducing hallucination at the structural level. No code until specs exist.

SDD provides **structural truth** in the anti-hallucination stack: DDD constrains *what* to build (semantic truth), SDD constrains *what shape* it takes (structural truth), and TDD proves *it works* (execution proof). Each layer anchors the next — AI cannot inject hallucination at any link.

SDD operates in two modes: **Generate** (no existing specs — create from scratch) and **Merge** (existing specs — reconcile with updated contracts or human edits via three-way diff).

## When to Use

- Phase 3 contracts and Phase 4 tech solution are approved, and implementation is about to begin — this is the moment between design and code
- Existing spec files need reconciliation with updated contracts or human edits (merge mode)
- When tempted to jump from contracts directly to code without formal spec files

**Do NOT use when:** Phase 3 contracts are not approved, Phase 4 tech solution is not finalized, or the project explicitly opts out of formal specs (**REQUIRED PREREQUISITES:** [designing-contracts-first](../designing-contracts-first/SKILL.md) + [architecting-technical-solution](../architecting-technical-solution/SKILL.md)). SDD needs BOTH Phase 3 (what interfaces exist) AND Phase 4 (gRPC? REST? Kafka?) to generate the correct spec format.

## Quick Reference — Generate Mode

| Step | Action | Output |
|:---|:---|:---|
| Entry | Check `specs/` directory: empty → Generate mode; has files → Merge mode | Mode decision |
| INVENTORY | Read Phase 3 contracts + Phase 4 tech solution; map interfaces to spec formats | Interface list + format mapping |
| SCAFFOLD | Create per-aggregate spec file skeleton; split shared types | File structure in `specs/` |
| FILL | Populate methods, types, errors, constraints with traceability comments | Complete spec files |
| VALIDATE | Check contract coverage, error completeness, granularity, breaking changes | `docs/ddd/spec-manifest.md` |

## Quick Reference — Merge Mode

| Step | Action | Output |
|:---|:---|:---|
| THREE-WAY DIFF | Compare manifest hash ↔ current file ↔ new contract-derived content | Change delta per spec section |
| RESOLVE | Apply merge rules; STOP on human+contract conflicts | Merged spec files |
| VALIDATE | Same as Generate + breaking change detection | Updated `docs/ddd/spec-manifest.md` |
| UPDATE MANIFEST | Refresh hashes in `spec-manifest.md` | Hash baselines reset |

## Ambiguity Handling

Follow the [Ambiguity Handling Protocol](../_shared/ambiguity-handling-reference.md) throughout this skill.

**SDD STOP triggers — confirm immediately:**

| Ambiguity | Why STOP |
|:---|:---|
| Spec conflicts with contract and human edited both | Three-way merge conflict — only human can decide which is authoritative |
| Phase 4 specifies mixed protocols (e.g., "gRPC + REST") with no per-interface mapping | Guessing which interface gets which protocol propagates to all downstream code |
| Contract method has ambiguous return type | Wrong type in spec → wrong type in all tests and code |
| Breaking change detected in merge mode | Removing/renaming fields can break existing clients — human must confirm intent |

**SDD ASSUME & RECORD — proceed with explicit assumption:**

| Ambiguity | Default assumption |
|:---|:---|
| Proto syntax version unspecified | Assume proto3, record in `assumptions-draft.md` |
| Field optionality not stated in contract | Assume required, record |
| Error type naming convention unspecified | Follow format reference default, record |
| Shared type boundary unclear | Keep in aggregate scope, move to `shared/` only if second consumer appears, record |

## Implementation

### Dual Entry Modes

SDD automatically selects its mode based on the state of the `specs/` directory:

- **`specs/` is empty or absent → Generate Mode**: Create spec files from Phase 3 contracts + Phase 4 tech decisions.
- **`specs/` has existing files → Merge Mode**: Reconcile existing specs with updated contracts or human edits using three-way diff.

### Generate Mode

```
INVENTORY → SCAFFOLD → FILL → VALIDATE
```

1. **INVENTORY**: Read `docs/ddd/phase-3-contracts.md` (extract every interface and boundary struct) + `docs/ddd/phase-4-technical-solution.md` (extract API protocol decisions — gRPC, REST, async messaging). Produce a complete interface list with format mapping:
   - Sync RPC interfaces → Proto (if gRPC) or OpenAPI (if REST)
   - Async event interfaces → AsyncAPI
   - Each interface mapped to exactly one spec format based on Phase 4 decisions
   - If Phase 4 does not specify a protocol for an interface, **STOP** — do not guess

2. **SCAFFOLD**: Create file structure per spec organization rules below:
   - One aggregate → one set of files (`-service`, `-types`, `-events`), each ≤200 lines
   - Cross-aggregate operations (sagas, queries) at context level
   - Shared types minimized in `shared/` — start in aggregate scope, move only when second consumer appears
   - Validate spec syntax if project has tooling configured (`protoc`, `buf lint`, `openapi-generator validate`)

3. **FILL**: Populate each spec file from contracts + domain events:
   - Method signatures derived from contract interface methods
   - Request/response types with field constraints (required/optional, ranges, formats)
   - Domain error types per method (≥1 per method; infrastructure errors in `shared/`)
   - Traceability comments linking back to contracts: `// Source: phase-3-contracts.md#OrderService.CreateOrder`
   - For format-specific conventions (field numbering, Request/Response wrapping, package naming): **read the corresponding format reference file before writing**. Only one format reference is needed — the one matching Phase 4's protocol choice.

4. **VALIDATE**: Self-check before persisting:
   - **Contract coverage**: every Phase 3 interface has a corresponding spec method
   - **Error completeness**: every method defines ≥1 domain error + references shared infrastructure errors
   - **Granularity**: no single spec file exceeds 200 lines
   - **Derivation rules**: Spec→Code derivation rules present in format reference for downstream consumption
   - **Output**: write `docs/ddd/spec-manifest.md` with coverage table, error completeness table, and hash baselines
   - Update `docs/ddd/ddd-progress.md` SDD status to `complete`
   - Append key decisions to `docs/ddd/decisions-log.md`
   - **This step is mandatory — do not skip even if specs are already visible in the conversation.**

### Merge Mode

Triggered when `specs/` already contains files. Uses three-way merge with `spec-manifest.md` hashes as common ancestor to detect both human edits and contract changes since last generation.

```
THREE-WAY DIFF → RESOLVE → VALIDATE → UPDATE MANIFEST
```

1. **THREE-WAY DIFF**: For each spec section (method, type, error), compare three versions:
   - **Common ancestor**: last generated content (reconstructed from manifest hash)
   - **Theirs**: current file on disk (potentially human-edited since last generation)
   - **Ours**: new contract-derived content (from updated Phase 3 + Phase 4)

2. **RESOLVE**: Apply merge rules based on which sides changed:

   | Human edited? | Contract changed? | Action |
   |:---:|:---:|:---|
   | No | No | Skip |
   | No | Yes | Auto-update |
   | Yes | No | Keep human version |
   | Yes | Yes | **STOP** — conflict, ask human |

   Extra items (in spec but not in contracts): keep with WARNING ("no contract source — intentional addition?")

3. **VALIDATE**: All generate-mode checks, plus:
   - **Breaking change detection**: removed fields, renamed methods, changed types = BREAKING → STOP and ask human to confirm intent
   - **Merge conflict resolution completeness**: every conflict section resolved (no leftover conflict markers)
   - **Untraced items audit**: items in spec with no contract source flagged with WARNING

4. **UPDATE MANIFEST**: Refresh `docs/ddd/spec-manifest.md` with new hashes. Update `docs/ddd/ddd-progress.md`. Append decisions to `docs/ddd/decisions-log.md`.

### Spec File Organization

Spec files live in `specs/` at the project root — separate from `docs/ddd/` (design documents) and `src/` (implementation). Design documents describe "why." Spec files define "what shape." Code implements "how."

```
specs/
├── {context}/
│   ├── {aggregate}/
│   │   ├── {aggregate}-service.proto|yaml    # Service definitions ≤200 lines
│   │   ├── {aggregate}-types.proto|yaml      # Type definitions ≤200 lines
│   │   └── {aggregate}-events.proto|yaml     # Event payloads ≤200 lines
│   ├── sagas/                                 # Cross-aggregate orchestrations
│   ├── queries/                               # Cross-aggregate read models
│   └── shared/
│       ├── common-types.proto|yaml            # Truly cross-context types (minimized)
│       └── common-errors.proto|yaml           # Infrastructure error patterns
```

Rules:
- One aggregate → one set of files, each ≤200 lines. Exceeding 200 lines signals the aggregate is too large — split the aggregate, do not grow the file.
- `shared/` contains ONLY truly cross-context types, not "might be shared someday." A type starts in its aggregate scope and moves to `shared/` only when a second consumer concretely appears.
- Every file has a traceability header comment identifying its contract source.
- Spec→Code derivation rules defined in the format-specific reference file (`proto-reference.md`, `openapi-reference.md`, or `asyncapi-reference.md`).

### Spec→Code Derivation Rules

Instead of a separate conventions artifact, SDD's format reference files include derivation rules. These tell downstream skills (TDD, coding-isolated-domains) how spec names map to code artifacts. Example from `proto-reference.md`:

| Spec Element | Code Artifact | Rule |
|:---|:---|:---|
| `service OrderService` | `order_service.go` | Service → snake_case + `_service.go` |
| `message CreateOrderRequest` | struct in same file | Follows service file |
| `message OrderItem` (standalone type) | `order_types.go` | Type → snake_case + `_types.go` |
| `enum OrderError` | `order_errors.go` | Error enum → snake_case + `_errors.go` |
| Directory | `domain/order/` | Aggregate → `domain/{snake_case}/` |

Team-specific overrides (e.g., `order_svc.go` instead of `order_service.go`) go in the project's `CLAUDE.md` — only the differences, not the full table.

### Artifact: spec-manifest.md

```markdown
# Spec Manifest
Generated: YYYY-MM-DD | Source: phase-3-contracts.md + phase-4-technical-solution.md

## Coverage
| Contract Interface | Spec File | Spec Hash | Status |
|:---|:---|:---|:---|
| OrderService.CreateOrder | order/order-service.proto:L5-L12 | a3f2c1b8 | covered |
| OrderService.CancelOrder | order/order-service.proto:L14-L20 | b7d4e2f9 | covered |

## Error Completeness
| Method | Domain Errors Defined | Infra Errors Referenced | Status |
|:---|:---|:---|:---|
| CreateOrder | InvalidItems, InsufficientStock, DuplicateOrder | shared/common-errors | complete |

## Untraced Items (human additions)
(none)
```

Hash convention: per [spec-hash-reference](../_shared/spec-hash-reference.md) (semantic content → SHA-256 first 8 chars; ignores comments, whitespace, import order).

### Loading Guidance

This skill references supporting files on demand — do not load them all upfront:

- **Before FILL step**: read the format reference file matching Phase 4 protocol choice (`proto-reference.md`, `openapi-reference.md`, or `asyncapi-reference.md`). Only load one — the one Phase 4 selected.
- **First time using generate mode**: reference `example-spec-generation.md` for a complete walkthrough of INVENTORY → SCAFFOLD → FILL → VALIDATE.
- **First time using merge mode**: reference `example-spec-merge.md` for a complete walkthrough of THREE-WAY DIFF → RESOLVE → VALIDATE → UPDATE MANIFEST.

**NEXT STEP:** → Spec Review Gate (if orchestrated by [full-ddd](../full-ddd/SKILL.md)) or → [test-driven-development](../test-driven-development/SKILL.md) (if standalone)

## Self-Check Protocol

Follow the [Persistence Defense Reference](../_shared/persistence-defense-reference.md) after completing VALIDATE, with this context-specific item 4:

4. **SDD Artifact Exists:** All of the following must be true:
   - Spec files exist in `specs/` for every Phase 3 contract interface
   - `docs/ddd/spec-manifest.md` exists with coverage and error completeness tables
   - Every spec file has traceability comments linking to Phase 3 contracts
   - No spec file exceeds 200 lines
   - Every method defines ≥1 domain error type
   - `docs/ddd/ddd-progress.md` SDD status updated to `complete`
   - Key decisions appended to `docs/ddd/decisions-log.md`

**If ANY check fails → STOP. Write the missing file. Do NOT proceed to coding or TDD.**

Note: This skill has no platform hooks. When invoked by [full-ddd](../full-ddd/SKILL.md), the orchestrator's hooks provide Layer 1 defense. When invoked standalone, this Self-Check Protocol (Layer 2) is the primary defense.

## Rationalization Table

These are real excuses agents use to bypass spec-first rules. Every one of them is wrong.

| Excuse | Reality |
|:---|:---|
| "Contracts are specific enough, no need for spec files" | Contracts are markdown — not compilable. Spec files are consumed by toolchains, validated by compilers, and used to generate code. |
| "Write code first, add spec later" | Code-derived specs mirror implementation, not design intent. Spec-first catches design flaws before they become code. |
| "This method can't fail, no error types needed" | Every method fails: network, concurrency, data inconsistency. Undefined errors = callers can't handle them. |
| "Put shared types in shared/ for convenience" | Shared types are coupling. Only truly cross-context types belong in shared/. |
| "200-line limit is too strict" | 200 lines is the AI context-friendly boundary. Exceeding it signals the aggregate is too large — split. |
| "Existing spec conflicts with contract but spec should win" | STOP. Conflicts require human decision. AI must not pick sides. |
| "A high-level spec is enough, details during implementation" | Hollow specs look complete but lack constraints. Field constraints, value ranges, error types are design decisions — not implementation details. |
| "Existing spec is close enough, skip formal merge" | "Close enough" is a hallucination entry point. Skipping three-way merge silently drops contract changes. |
| "Internal API doesn't need rigorous spec" | Internal APIs ARE the contracts between bounded contexts. External APIs at least have client pressure — internal APIs only have specs to protect them. |
| "Field constraints can be decided during implementation" | Constraints are design decisions. Required/optional, max_length, value ranges belong in the spec layer, not discovered during coding. |

## Red Flags — STOP and Regenerate

If you catch yourself doing any of the following, STOP immediately and fix the issue:

- Spec files not created, proceeding directly to coding
- Spec generated without reading Phase 4 tech solution (format chosen by assumption, not by Phase 4 decision)
- Merge mode: existing spec overwritten without three-way diff
- Spec file has zero error types defined for any method
- Single monolithic spec file covering multiple aggregates
- Human-edited spec content silently discarded during merge
- Spec→Code derivation rules not consulted from format reference before FILL

**Any of these → STOP. Fix the issue before continuing.**
