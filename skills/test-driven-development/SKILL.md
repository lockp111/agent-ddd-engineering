---
name: test-driven-development
description: >
  Use when implementing domain code in a DDD project — this skill IS the
  Phase 5 coding process (MAP→ITERATE→DIFF). Use when spec files exist
  and domain code needs to be written from them. Use when tempted to write
  code before tests, skip test output verification, or derive tests from
  implementation instead of specs. Symptoms include code written without
  corresponding failing tests, test output not shown in context, tests
  that pass immediately without red phase, tests with no traceability to
  spec requirements, and architecture violations in domain layer.
  测试驱动开发, 从Spec到测试, MAP-ITERATE-DIFF, spec驱动测试,
  领域代码实现, test-driven development, spec to test to code.
---

# Test-Driven Development

## Overview

TDD IS the Phase 5 coding process. It is the sole driving skill during implementation. The MAP→ITERATE→DIFF cycle replaces ad-hoc coding. TDD embeds key constraints from SDD (spec compliance) and coding-isolated-domains (architecture rules) via shared references — no need to load three skills simultaneously.

**Why Human TDD ≠ AI TDD:** Human TDD uses tests as a *thinking tool* — humans write tests to think through problems incrementally because they cannot hold entire specs in working memory. AI reads entire specs in one pass. Tests are not thinking aids — they are **anti-hallucination mechanisms**. Without tests, AI hallucinates that code works. Tests are executable proof, not discovery tools. This changes the cycle design: leverage AI strengths (comprehensive reading, systematic comparison) while guarding against AI weaknesses (ungrounded confidence, happy-path bias, attention degradation).

TDD provides **execution proof** in the anti-hallucination stack: DDD constrains *what* to build (semantic truth), SDD constrains *what shape* it takes (structural truth), and TDD proves *it works* (execution proof). Each layer anchors the next — AI cannot inject hallucination at any link.

## When to Use

- Phase 5 coding begins and spec files exist (from SDD or pre-existing)
- Domain code needs to be implemented from spec definitions
- When tempted to write code before tests, skip test output verification, or derive tests from implementation
- When returning to a project where specs have changed since last coding session

**Do NOT use when:** No spec files exist (run [spec-driven-development](../spec-driven-development/SKILL.md) first), making trivial changes (single config line, typo fix), or working on pure infrastructure adapters outside domain layer. **REQUIRED PREREQUISITES:** Spec files in `specs/` (from [spec-driven-development](../spec-driven-development/SKILL.md) or pre-existing).

## Quick Reference

| Step | Action | Output |
|:---|:---|:---|
| Entry Check | Compare test-map hashes ↔ spec hashes; if changed → RECONCILE | Mode decision |
| MAP | Read spec + derive complete test plan + adversarial review | `docs/ddd/test-map.md` |
| ITERATE | Per test: RED → GREEN → REFACTOR; per 5 tests: Focus Refresh | Test files + domain code |
| DIFF | Spec↔Test↔Code coverage + chain integrity check | `docs/ddd/test-coverage.md` |

## Ambiguity Handling

Follow the [Ambiguity Handling Protocol](../_shared/ambiguity-handling-reference.md) throughout this skill.

**TDD STOP triggers — confirm immediately:**

| Ambiguity | Why STOP |
|:---|:---|
| Spec method has no error types defined | Cannot derive error path tests — SDD may have missed this; surface upstream |
| Test fails for unexpected reason (not "feature missing") | Could indicate spec inconsistency or environment issue — diagnose before proceeding |
| Architecture red line violated and no obvious fix | Domain boundary decision needed — may require revisiting Phase 3 contracts |

**TDD ASSUME & RECORD — proceed with explicit assumption:**

| Ambiguity | Default assumption |
|:---|:---|
| Test execution framework unspecified | Use project's existing framework; if new project, follow Phase 4 tech stack conventions; record |
| Spec does not specify concurrency behavior | Assume single-threaded for domain tests; record; note for integration test phase |
| Mock boundary unclear for port tests | Mock only external ports (database, external API); never mock domain internals; record |

## Implementation

### Core Cycle

```
Entry Check → MAP → ITERATE → DIFF
                      ↑         │
                      └─────────┘  (per spec unit: mini-DIFF → next unit)
```

The aggregate is the universal chunking boundary — it serves as consistency boundary (DDD), spec file organization unit (SDD), and AI working memory chunk (TDD). Three methodologies converge naturally at the aggregate. Process one aggregate at a time through the full cycle before moving to the next.

Context budget per aggregate: MAP ~200 lines active, ITERATE ~280 lines, DIFF ~550 lines (peak). Safe for any context window. If an aggregate's spec exceeds 200 lines, the aggregate is too large — split it upstream in SDD.

### Entry Check

Before starting MAP, validate spec hash baselines:

1. If `docs/ddd/test-map.md` does not exist → **normal flow** (first run). Proceed to MAP.
2. If `docs/ddd/test-map.md` exists → compare its recorded spec hashes against current spec file hashes per [spec-hash-reference](../_shared/spec-hash-reference.md).
   - All hashes match → **normal flow**. Resume from where `test-map.md` progress left off.
   - Any hash mismatch → **RECONCILE mode**. Specs changed since last MAP (human edit, SDD merge, or new iteration). Run the RECONCILE Protocol before continuing normal flow.

### MAP

Per spec unit (aggregate | saga | query):

MAP leverages AI's superpower: comprehensive reading. Unlike a human who might miss edge cases, AI can systematically derive tests from every line of a spec — if forced to do so.

1. **Read spec files** for this unit (REQUIRED).
2. **Read Phase 1 domain events + Phase 2 ubiquitous language** (if they exist — enrich test derivation; see Graceful Degradation if absent).
3. **Derive complete test plan** across all 7 categories:
   - **Behavioral** — command → event mapping (e.g., `CreateOrder` → `OrderCreated`)
   - **Invariant** — aggregate business rules that must always hold (e.g., order total > 0)
   - **Domain rule** — specific business rules from ubiquitous language
   - **Value object** — immutability, validation, equality semantics
   - **Port** — interface contract compliance (port methods accept and return expected types)
   - **Error path** — every domain error type defined in the spec gets at least one test
   - **Boundary** — field constraint edge cases (zero, empty string, max value, negative, overflow)
4. **Adversarial self-review** — after deriving the initial plan, challenge it:
   - "What error paths did I miss? Does every spec error type have a test?"
   - "What happens at zero, empty, max, concurrent? Are boundary values covered?"
   - "What if dependencies fail? Are port failure paths tested?"
   - "Am I only testing happy paths?" (Happy-path bias is AI's systematic deficiency.)
   - Add any discovered gaps to the test plan before writing.
5. **Write** traceability test plan → `docs/ddd/test-map.md` (see Artifact: test-map.md below).

### ITERATE

The inner loop: RED → GREEN → REFACTOR, one test at a time. This is where classic TDD discipline meets AI anti-hallucination enforcement.

**Focus Refresh** — triggered every 5 tests (at test #5, #10, #15, etc.):
1. Re-read the current spec unit's spec file (prevent memory drift from accumulating).
2. Re-read `test-map.md` progress (refresh global awareness of what is done vs pending).
3. Self-check: "Can I cite the spec source for my next test?"
   - Yes → continue to next test.
   - No → STOP. Re-read spec file before writing the next test. Do not proceed on stale memory.

Why: AI attention degrades over long tasks. At test #12, spec awareness is weaker than at test #1. Periodic refresh regrounds the agent in the source of truth. This is not optional discipline — it is compensation for a known AI limitation.

**RED:**
1. Write one failing test derived from the test map. The test must reference its spec source.
2. Execute the test via platform tool (run command, not mental simulation).
3. **Actual failure output MUST appear in context.**
   - Copy the terminal output into the conversation.
   - "It should fail" without output is not RED — it is a guess.
   - Why this matters: "it should fail" is AI's most common hallucination. Without actual output, the failure claim is a guess, not evidence. The output IS the proof.
4. Verify: test fails because the feature is missing, not because of a typo, import error, or setup problem. If the failure reason is wrong, fix the test before proceeding to GREEN.

**GREEN:**
1. Write minimal code to make the test pass — nothing more. Minimal code prevents over-engineering.
2. Execute via platform tool.
3. **Actual pass output MUST appear in context.** Why: "it should pass" without output is the same hallucination as RED. Showing output is the proof.
4. **Architecture red line check** — reference [domain-architecture-reference](../_shared/domain-architecture-reference.md). Verify:
   - Domain layer has no infrastructure imports
   - Domain structs have no ORM/JSON tags
   - No cross-aggregate direct imports
   - Value objects are immutable; entities use command methods, not setters
5. If any red line is violated: STOP, delete the violating code, re-enter GREEN. Do not rationalize "I'll fix it in REFACTOR." Architecture violations in GREEN contaminate the test baseline. REFACTOR assumes a clean GREEN.

**REFACTOR:**
1. Clean up code (rename, extract, simplify). Improve readability without changing behavior.
2. Run full test suite → actual output in context. All tests must remain green.
3. Run linter if configured → actual output in context.
   - Linter failure = test failure. Must fix before proceeding.
   - Why linter in REFACTOR: linter catches style drift that tests miss. A green test suite with linter warnings is not clean.
4. Confirm: green + spec compliant + architecture clean. Only then proceed to next test.

After completing each test: update `test-map.md`, mark test status (pass or pending with reason).

**After completing each spec unit:**

1. **Mini-DIFF**: coverage check for this unit only — are all spec methods and error types tested?
2. **Checkpoint**: update `test-map.md` with completed status and pass/pending markers for this unit.
3. **Context cleanup**: prior units' raw test output and implementation detail can be dropped from working memory. Keep only summaries (pass counts, any notable issues). This prevents context bloat across multi-aggregate sessions and keeps the active context within budget.

### DIFF

DIFF leverages AI's second superpower: systematic comparison. Unlike a human reviewer who samples, AI can exhaustively compare every spec item against every test and every code artifact. After all spec units are complete, run the 4-dimension coverage check:

1. **Spec → Test**: every spec method and error type has a corresponding test? Any spec item without a test is a coverage gap.
2. **Test → Code**: every test exercises real code (not mock bypasses)? Tests that only exercise mocks prove nothing about production behavior.
3. **Code → Spec**: code types, fields, and errors match spec definitions? Code that deviates from spec is drift — even if tests pass.
4. **Chain integrity**: Event → Spec → Test → Code — each link present? (PRD → Event is optional, only if Phase 1 annotated it.) A broken link means something in the chain was invented, not derived.

Output → `docs/ddd/test-coverage.md` with the following structure:

```markdown
# Test Coverage Report
Generated: YYYY-MM-DD

## Spec → Test Coverage
| Spec Method/Error | Test Case(s) | Status |
|:---|:---|:---|
| OrderService.CreateOrder | test #1, #2, #3 | covered |
| OrderError.InvalidItems | test #2 | covered |

## Chain Integrity
| Event | Spec | Test | Code | Status |
|:---|:---|:---|:---|:---|
| OrderCreated | order-service.proto:L5 | test #1 | order.go:L24 | complete |

## Gaps
(none)
```

Update `docs/ddd/ddd-progress.md` TDD status to `complete`. Append key decisions to `docs/ddd/decisions-log.md`. **This step is mandatory — do not skip even if all tests are green in the conversation.**

### RECONCILE Protocol

Triggered when Entry Check detects spec hash mismatch (specs changed since last MAP). This happens when humans manually edit spec files, SDD merge mode updates specs, or a new DDD iteration produces updated contracts. Only re-runs affected tests, not the full suite.

```
DETECT → DELTA → IMPACT → RE-MAP → RE-ITERATE → RE-DIFF → update baselines
```

1. **DETECT**: Compare `test-map.md` recorded hashes ↔ current spec file hashes.
2. **DELTA**: Identify exactly which spec methods/types changed (added, removed, modified).
3. **IMPACT**: Map changed spec items → affected test cases. Mark stale in test-map.
4. **RE-MAP**: Re-derive stale tests + add tests for new spec items. Remove tests for deleted spec items.
5. **RE-ITERATE**: RED-GREEN-REFACTOR only for affected tests.
6. **RE-DIFF**: Re-verify coverage and chain integrity for all units (not just affected ones — a change in one unit may affect cross-unit consistency).
7. **Update** `test-map.md` hash baselines to current spec hashes.

### Golden Reference Aggregate

The first aggregate implemented gets a human style review — an **advisory checkpoint** (not a formal gate):

1. Complete first aggregate's full MAP → ITERATE → DIFF cycle.
2. Present code to human: "This is the first aggregate. Please review code style, naming conventions, and structural patterns. Your corrections become the golden reference for all subsequent aggregates."
3. Human corrects or approves → this becomes the style reference.
4. Subsequent aggregates: GREEN step reads the golden aggregate's code first and follows the same style. Explicitly state: "Following golden reference from {aggregate name}."

AI naturally mimics code it has seen. One well-done example teaches more than any style document. This is advisory — progress is not blocked if the human does not respond, but the notification must be sent.

### Graceful Degradation

TDD's primary mode assumes DDD+SDD context. Without Phase 1/2 artifacts, it still works with reduced traceability:

- **Spec files**: REQUIRED — the non-negotiable input. Without specs, do not use this skill — run SDD first.
- **Phase 1 domain events** (if present): enrich behavioral test derivation with event names. Behavioral tests link to events (e.g., `CreateOrder` → `OrderCreated`).
- **Phase 2 context map** (if present): use ubiquitous language in test names. Test names read as domain sentences.
- **If Phase 1/2 missing**: traceability chain shortens to Spec → Test → Code. Test naming uses spec terminology instead of domain language. Emit WARNING: "DDD artifacts missing, traceability chain incomplete."
- **If architecture reference missing**: still enforce the basic checks (no infra imports in domain), but flag that the full red line list is unavailable.

### Artifact: test-map.md

```markdown
# Test Map
Generated: YYYY-MM-DD

## Order Aggregate
Spec: order/order-service.proto (hash: a3f2c1b8)

| # | Test Case | Spec Source | Domain Event | Status |
|:---|:---|:---|:---|:---|
| 1 | create_order_with_valid_items | order-service.proto:L5 CreateOrder | OrderCreated | pending |
| 2 | create_order_rejects_empty_items | order-service.proto:L5 CreateOrder | — | pending |
| 3 | create_order_rejects_negative_qty | order-types.proto:L8 quantity | — | pending |

### Adversarial Review
- [ ] All domain errors have tests
- [ ] Field boundary values tested (quantity=0, quantity=MAX)
- [ ] Concurrent create + cancel for same order
- [ ] Inventory service unavailable behavior

### Convention Tests
| # | Test Case | Convention Source | Type |
|:---|:---|:---|:---|
| C1 | files_in_domain_are_snake_case | proto-reference derivation rules | filesystem |
| C2 | no_orm_tags_in_domain_structs | architecture red lines | grep |

### Progress
Completed: 0/3 | Pending: 3

## Payment Aggregate
Spec: payment/payment-service.proto (hash: d5e8f3a1)
...
```

Hash convention: per [spec-hash-reference](../_shared/spec-hash-reference.md) (semantic content → SHA-256 first 8 chars; ignores comments, whitespace, import order).

Traceability chain: Event → Spec → Test → Code. PRD column is intentionally omitted — the pipeline does not track PRD section references per item. If Phase 1 output includes PRD links, they can be added. The chain starts at Event.

### Convention Tests

Convention tests are derived during MAP from two sources:

1. **SDD Spec→Code derivation rules** in the format reference file (file naming, directory structure).
2. **Architecture red lines** in [domain-architecture-reference](../_shared/domain-architecture-reference.md) (no ORM tags, no infra imports).

Convention tests follow the same RED-GREEN-REFACTOR cycle as behavioral tests. They are listed in the Convention Tests sub-table of `test-map.md`. Derive convention tests only when explicit derivation rules or red lines exist — do not guess conventions.

Examples of convention tests:
- **Filesystem**: file names match Spec→Code derivation rules (e.g., `order_service.go` for `service OrderService`)
- **Grep**: no ORM/JSON tags on domain structs, no infrastructure imports in domain layer
- **Structure**: port directories contain only interfaces, entities have command methods not setters

### Loading Guidance

This skill references supporting files on demand — do not preload them all:

- **During MAP**: read `test-derivation-reference.md` for the relevant test category derivation guidance.
- **During GREEN**: reference [domain-architecture-reference](../_shared/domain-architecture-reference.md) for the full red line checklist.
- **First full cycle**: reference `example-tdd-cycle.md` for a complete MAP→ITERATE→DIFF walkthrough.
- **First spec change encounter**: reference `example-reconcile.md` for a RECONCILE walkthrough.

**NEXT STEP:** → Archive (`sh skills/full-ddd/scripts/archive-artifacts.sh`) or → [iterating-ddd](../iterating-ddd/SKILL.md) for next iteration

## Self-Check Protocol

Follow the [Persistence Defense Reference](../_shared/persistence-defense-reference.md) after completing each spec unit's TDD cycle, with this context-specific item 4:

4. **TDD Artifact Exists:** All of the following must be true:
   - `docs/ddd/test-map.md` exists with current spec hash baselines
   - `docs/ddd/test-coverage.md` exists after final DIFF
   - Test files exist alongside domain code in `src/`
   - Every test in `test-map.md` has status pass or a documented reason for pending
   - `docs/ddd/ddd-progress.md` TDD status updated to `complete`
   - Key decisions appended to `docs/ddd/decisions-log.md`

**If ANY check fails → STOP. Write the missing file. Do NOT proceed to the next aggregate or archive.**

Note: This skill has no platform hooks. When invoked by [full-ddd](../full-ddd/SKILL.md), the orchestrator's hooks provide Layer 1 defense. When invoked standalone, this Self-Check Protocol (Layer 2) is the primary defense.

## Rationalization Table

These are real excuses agents use to bypass TDD rules. Every one of them is wrong.

| Excuse | Reality |
|:---|:---|
| "This code is too simple to test" | Simple code breaks. A test takes 30 seconds to write. Untested = unproven. |
| "I'll write tests after to verify" | Tests-after verify what you built. Tests-first verify what is required. Tests-after are biased by implementation. |
| "I can infer spec intent from the code" | Inferring from code is a hallucination entry point. Deriving from spec is a traceable chain. Read the spec — it is a requirement, not a suggestion. |
| "Test output is too long, it passed" | "It passed" is AI's most common hallucination. No output = no proof = did not pass. |
| "Mocks are more convenient" | Mocks test mock behavior, not real behavior. Mock only when external dependencies are truly unavoidable. |
| "Full test suite is too slow, just run the one test" | After REFACTOR, full suite is mandatory. One green does not mean all green. Regression is real. |
| "This test passed before, refactoring didn't affect it" | "Didn't affect" is judgment, not evidence. Running the test is evidence. |
| "Skip adversarial review, the test plan is complete" | Your plan covers scenarios you thought of. Adversarial review finds what you did not. Happy-path bias is AI's systematic deficiency. |
| "Architecture constraints can be fixed later" | Architecture violations spread. Every subsequent test builds on a contaminated foundation. Fix now or rewrite later. |
| "Aggregate is too small for mini-DIFF" | Mini-DIFF is not about aggregate size. It is about AI accumulating invisible drift. Small aggregates drift too. |

## Red Flags — STOP and Start Over

If you catch yourself doing any of the following, STOP immediately and fix the issue:

- Code written before a failing test exists
- Test written but not executed before writing implementation
- "Tests pass" claimed without actual output in context
- Test passes immediately on first run (testing existing behavior, not new)
- Cannot cite the spec source for the current test
- Traceability chain has broken link (test has no spec reference, or spec has no event reference)
- GREEN step code violates architecture red lines
- Adversarial self-review skipped during MAP
- More than 5 tests executed without Focus Refresh

**Any of these → delete the code written since the violation and restart from the correct step.**
