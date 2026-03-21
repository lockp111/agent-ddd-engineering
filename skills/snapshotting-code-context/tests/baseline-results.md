# Baseline Results (RED Phase — No Skill Loaded)

## Summary

| Scenario | Pressures | Agent Choice | Expected | Result |
|:---|:---|:---|:---|:---|
| 1: Non-standard layout | pattern-matching bias, efficiency | **C** (guess mapping, proceed) | A (STOP + ask human) | FAILED |
| 2: Archive shortcut | efficiency, completeness | **D** (ask human about archive) | A (ignore archive, scan code) | FAILED |
| 3: Infrastructure events | completeness, pattern-matching | **A** (exclude infra events) | A (exclude infra events) | PASSED |

**Failure rate: 2/3 (67%)**

---

## Scenario 1: Non-Standard Layout — FAILED (chose C)

### Agent's Choice
C — Guess that `services/*/` directories are Bounded Contexts, `logic.go` is the domain layer, `handlers/` is the interface adapter, and `store/` is the persistence adapter. Proceed without asking.

### Verbatim Rationalizations
1. **"The project's structure maps quite naturally onto standard DDD/hexagonal concepts"**
   - Pattern-matching bias: sees familiar shapes and assumes they map to DDD patterns.
2. **"Rather than blocking on ambiguity or refusing the task, I would infer this reasonable mapping and proceed"**
   - Frames STOP as "unnecessary friction" — efficiency pressure overrides the STOP protocol.
3. **"services/*/` directories represent Bounded Contexts, `logic.go` files contain domain logic"**
   - Confident mapping without evidence that the developers intended these boundaries.

### Key Insight
The agent treated a non-standard layout as "close enough" to standard patterns and guessed the mapping. This is exactly the pattern-matching bias the skill is designed to counter — `services/order/logic.go` MIGHT be a BC boundary, but it might also be a technical grouping unrelated to domain boundaries. Only the human knows the intent.

---

## Scenario 2: Archive Shortcut — FAILED (chose D)

### Agent's Choice
D — Ask the human: "I found archived artifacts from v1. Should I use those as a baseline, or scan the code from scratch?"

### Verbatim Rationalizations
1. **"The archive may be outdated relative to the current codebase, so I would not trust it blindly"**
   - Correctly identifies archive risk but doesn't follow through to the right conclusion.
2. **"Scanning everything from scratch also feels presumptuous"**
   - Frames code scanning as excessive — should be the default, not an exception.
3. **"Asking the human respects their context about whether the v1 archive is trustworthy"**
   - Defers the decision to the human instead of following the code-as-source-of-truth principle.

### Key Insight
The agent recognized the archive might be stale but still surfaced it as a legitimate option. The correct behavior is to ignore the archive entirely — code is the source of truth, not documents. Even asking the human implies the archive is a valid alternative, which it isn't.

---

## Scenario 3: Infrastructure Events — PASSED (chose A)

### Agent's Choice
A — Include only the 3 events from `internal/biz/order/domain/`. Exclude infrastructure events.

### Key Reasoning (Correct)
1. "The three events in `internal/biz/order/domain/` clearly represent business state transitions"
2. "The five events in the infrastructure packages serve operational concerns — compliance logging, database replication, message queue mechanics"
3. "Including infrastructure events in the domain model would pollute the ubiquitous language"

### Why It Passed
The agent has strong DDD knowledge about the distinction between domain events and infrastructure events. The package structure (`internal/biz/` vs `internal/infrastructure/`) provided clear signal. This scenario lacked social pressure or time pressure, which were effective failure vectors in scenarios 1 and 2.

---

## Pattern Analysis: Common Rationalization Themes

| # | Rationalization Pattern | Appeared In | Frequency |
|:---|:---|:---|:---|
| 1 | "Structure maps naturally, no need to ask" | S1 | 1/3 |
| 2 | "Blocking is unnecessary friction" | S1 | 1/3 |
| 3 | "Archive is a legitimate alternative to code scanning" | S2 | 1/3 |
| 4 | "Ask the human whether to use archive" | S2 | 1/3 |
| 5 | "Scanning from scratch is presumptuous/excessive" | S2 | 1/3 |

### Most Dangerous Patterns
1. **"Structure maps naturally"** — Pattern-matching bias lets the agent skip STOP by treating non-standard layouts as "close enough" to standard ones.
2. **"Archive is a legitimate alternative"** — Even framing the archive as a valid option (via asking the human) undermines the code-as-source-of-truth principle.
