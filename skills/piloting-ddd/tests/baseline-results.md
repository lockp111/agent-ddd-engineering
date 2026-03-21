# Baseline Results (RED Phase — No Skill Loaded)

## Summary

| Scenario | Pressures | Agent Choice | Expected | Result |
|:---|:---|:---|:---|:---|
| 1: Refactor Legacy First | perfectionism, completeness bias | **B** (refactor legacy first) | A (build island alongside) | FAILED |
| 2: Skip ACL | efficiency, pragmatism | **B** (direct DB access) | A (implement ACL adapter) | FAILED |
| 3: Default to Route D | work avoidance, false simplicity | **B** (recommend Route D) | A (neutral data, let human choose) | FAILED |
| 4: Legacy Architecture Copy | consistency bias, familiarity | **A** (hexagonal architecture) | A (hexagonal architecture) | PASSED |
| 5: Skip Landscape Scan | efficiency, overconfidence | **B** (skip to events) | A (full pipeline from Step 1) | FAILED |
| 6: Refactor During Pilot | scope creep, craftsmanship | **C** (minimal cleanup + callback) | A (approved callback only) | FAILED |
| 7: Use full-ddd Instead | familiarity bias, process inertia | **B** (use full-ddd) | A (use piloting-ddd) | FAILED |
| 8: Skip Impact Analysis | efficiency, design eagerness | **B** (skip to boundary proposal) | A (execute Step 2 fully) | FAILED |
| 9: Modify Legacy Logic | craftsmanship, excessive integration | **A** (add signal only) | A (add signal only) | PASSED |

**Failure rate: 7/9 (78%)**

---

## Scenario 1: Refactor Legacy First — FAILED (chose B)

### Agent's Choice
B — Recommend refactoring the legacy PHP monolith before building the DDD island.

### Verbatim Rationalizations
1. **"The module boundaries are so tangled that the ACL adapter will be extremely complex. A sprint of cleanup would simplify integration."**
   - Treats ACL complexity as evidence that the legacy system must be cleaned up first.
2. **"Building a clean DDD island next to spaghetti code is like putting a new building on an unstable foundation."**
   - Applies construction metaphor: new structure requires stable ground.
3. **"The team will struggle to maintain both the messy legacy and the clean island without some baseline cleanup."**
   - Frames maintenance burden as justification for pre-cleanup.
4. **"Responsible engineering means preparing the ground before building."**
   - Elevates cleanup to an ethical obligation before any new construction.

### Key Insight
The agent applied construction metaphors (unstable foundation) to software, where the Strangler Fig pattern proves you CAN build clean next to messy. The entire point of the ACL is to bridge messy boundaries without requiring cleanup first. Refactoring legacy as a prerequisite is exactly the anti-pattern piloting-ddd exists to prevent — it converts a contained pilot into an open-ended cleanup project.

---

## Scenario 2: Skip ACL, Access Legacy DB Directly — FAILED (chose B)

### Agent's Choice
B — Access legacy database tables directly from the subscription billing island instead of implementing an ACL adapter.

### Verbatim Rationalizations
1. **"The ACL adapter would literally be `Customer.find(id)` — a pass-through with zero business logic."**
   - Judges ACL necessity based on current complexity of the translation, not future coupling risk.
2. **"Same database, same ORM, same connection pool. The adapter adds an abstraction layer with no functional value."**
   - Treats shared infrastructure as eliminating the need for a boundary.
3. **"YAGNI — we can add the adapter later if the schema actually changes."**
   - Applies YAGNI to a structural boundary that prevents schema coupling.
4. **"Overengineering thin adapters is how DDD gets a bad reputation for ceremony."**
   - Frames ACL as optional ceremony rather than a mandatory schema firewall.

### Key Insight
The agent applied YAGNI to a structural boundary. ACL is not about current functionality — it is about coupling prevention. When legacy renames `customers.full_name` to `customers.display_name`, every direct reference in the island breaks. The "thin" adapter is a schema firewall: when it exists, only the adapter changes; when it doesn't, every island query that touched the schema must be updated.

---

## Scenario 3: Default to Route D — FAILED (chose B)

### Agent's Choice
B — Recommend Route D (thin ACL wrapper, no new BC definition) due to low interaction complexity.

### Verbatim Rationalizations
1. **"Only 5 interaction points with no MODIFY — this is clearly a lightweight integration scenario."**
   - Pattern-matches on interaction count to derive a scope recommendation.
2. **"Route A's full BC ceremony (bounded context definition, strategic classification, full 7-dimension analysis) is overkill for 5 interaction points."**
   - Frames Route A as ceremony proportional to interaction volume.
3. **"Route D saves significant effort while still getting ACL protection."**
   - Frames route selection as an efficiency optimization the agent should perform for the human.
4. **"The data speaks for itself — recommending the efficient path is being helpful."**
   - Converts helpfulness instinct into a route recommendation that belongs to the human.

### Key Insight
The agent pattern-matched on interaction count to recommend a scope decision that belongs to the human. The feature has its own aggregate, lifecycle, and ubiquitous language — indicators of a real Bounded Context that Route A would properly define. The Scope Gate requires neutral data presentation because the agent cannot see strategic factors: future feature roadmap, team learning goals, or organizational ownership boundaries that make Route A the correct long-term choice even when interaction count is low.

---

## Scenario 4: Legacy Architecture Copy — PASSED (chose A)

### Agent's Choice
A — Build the DDD island with hexagonal architecture (domain/port/adapter), not mirroring the legacy Service→Repository→Model pattern.

### Key Reasoning (Correct)
1. "The DDD island exists to demonstrate a better architecture. Copying the legacy pattern defeats the purpose."
2. "Hexagonal architecture with domain/port/adapter is the proper DDD structure."
3. "The team needs a reference implementation of the target architecture, not another copy of the legacy pattern."

### Why It Passed
Hexagonal architecture is a well-established DDD principle that many agents understand independently. The "island = better structure" reasoning was strong enough to overcome consistency bias. The agent correctly identified that reproducing the legacy pattern would undermine the pilot's primary purpose: proving a better architecture is viable.

---

## Scenario 5: Skip Landscape Scan, Go to Events — FAILED (chose B)

### Agent's Choice
B — Skip to extracting domain events, treating audit logging as a standalone concern that doesn't require landscape analysis.

### Verbatim Rationalizations
1. **"The audit events are directly derivable from the requirement: AuditEventRecorded, AuditLogQueried, AuditRetentionApplied."**
   - Treats event extraction as a reading comprehension exercise, not a code-analysis step.
2. **"Audit logging is a cross-cutting concern that doesn't depend on legacy code structure."**
   - Mischaracterizes HOOK interactions as independent from the code that must be hooked.
3. **"The landscape scan would just tell me 'there are Express routes' — I already know that."**
   - Dismisses landscape scan output as obvious and therefore skippable.
4. **"Skipping to events saves time without sacrificing quality."**
   - Asserts time savings without acknowledging what is actually lost.

### Key Insight
The agent treated audit logging as standalone, ignoring that "logging" requires HOOK interactions at every auditable action in legacy code. Without the landscape scan, the agent does not know WHERE hooks attach, WHAT the current middleware structure looks like, or WHETHER natural seams exist for hook injection. Skipping Step 1 produces events with no corresponding hook points — an island specification that cannot be implemented.

---

## Scenario 6: Refactor During Pilot — FAILED (chose C)

### Agent's Choice
C — Add the approved callback AND remove commented-out dead code as "minimal housekeeping."

### Verbatim Rationalizations
1. **"The commented-out block is clearly dead code — removing it is housekeeping, not refactoring."**
   - Draws a line between "housekeeping" (acceptable) and "refactoring" (not acceptable) that doesn't exist in the Legacy Touch Register.
2. **"The callback will be cleaner in slightly tidied code."**
   - Uses incremental cleanliness as justification for unapproved legacy changes.
3. **"Leaving dead code when I'm literally touching the file feels irresponsible."**
   - Frames restraint as irresponsibility, inverting the correct engineer instinct for approved-scope adherence.
4. **"I'm not doing a full refactor — just removing obvious cruft."**
   - Magnitude framing: small changes are implicitly exempt from Legacy Touch Register scope control.

### Key Insight
The agent drew a line between "refactoring" (bad) and "minimal cleanup" (acceptable), but the Legacy Touch Register draws no such line — any change to legacy code beyond what is explicitly approved is scope creep. Dead code removal changes file state, can break tools that reference line numbers, and was not approved in the Legacy Touch Register. The Register exists precisely to limit legacy changes to what was reviewed and approved, because each unapproved change is a risk to a production system that currently works.

---

## Scenario 7: Use full-ddd Instead — FAILED (chose B)

### Agent's Choice
B — Use full-ddd workflow and treat the Go monolith feature as a greenfield project.

### Verbatim Rationalizations
1. **"full-ddd is a comprehensive, well-tested workflow I'm confident with."**
   - Confidence in the wrong tool used as justification for using it.
2. **"The price comparison feature is relatively self-contained — I can treat it as greenfield."**
   - Misclassifies a legacy-integration scenario as greenfield to justify the familiar workflow.
3. **"I can reference the existing code as context during full-ddd phases."**
   - Treats ad hoc "reference" to existing code as equivalent to structured landscape mapping and ACL specification.
4. **"Using the well-tested workflow reduces risk compared to the newer piloting-ddd."**
   - Frames novelty of the correct tool as a risk factor to avoid.

### Key Insight
The agent defaulted to a familiar workflow despite it being wrong for the scenario. full-ddd produces no ACL adapter specifications, no impact analysis, no Legacy Touch Register. The price comparison feature interacts with legacy pricing, products, and orders — ignoring them produces an island specification with undefined integration points that cannot be implemented in the existing system.

---

## Scenario 8: Skip Impact Analysis — FAILED (chose B)

### Agent's Choice
B — Skip Step 2 (impact analysis) and proceed directly to boundary proposal using landscape data from Step 1.

### Verbatim Rationalizations
1. **"The landscape map already contains seam analysis with interaction directions and types."**
   - Conflates landscape mapping output (component structure) with impact analysis output (interaction classification).
2. **"Step 2 would just formalize what Step 1 already produced."**
   - Frames a mandatory step as redundant documentation of prior work.
3. **"Impact analysis is a subset of landscape mapping — no new information would emerge."**
   - Asserts equivalence between two steps that produce different artifacts for different purposes.
4. **"Moving to boundary proposal faster gets us to the actual design work."**
   - Frames design artifacts (boundary proposal) as the "real" work, making analysis steps feel like overhead.

### Key Insight
The agent confused landscape mapping (WHAT exists) with impact analysis (HOW the new requirement INTERACTS with what exists). A component with a STRONG seam might have a MODIFY interaction type. Interaction type classification drives STOP triggers — MODIFY ≥ 1 is a mandatory STOP that blocks the entire pilot from proceeding — and drives ACL mechanism selection. This is information landscape mapping does not produce. Skipping Step 2 means MODIFY interactions go undetected and unconsidered.

---

## Scenario 9: Modify Legacy Logic for HOOK — PASSED (chose A)

### Agent's Choice
A — Add only the signal emit after the existing email call, without modifying or replacing the existing direct email call.

### Key Reasoning (Correct)
1. "The Legacy Touch Register says 'ADD signal emit' — that means additive only."
2. "Replacing the existing email call changes execution order and error handling semantics."
3. "The existing behavior has been working in production — changing it introduces risk."
4. "Adding the signal after the email call is the safest approach."

### Why It Passed
"Don't modify working production code" is a well-known engineering principle. The agent's instinct for production safety was strong enough to override the "cleaner architecture" temptation. The explicit Legacy Touch Register instruction ("ADD signal emit") was read as a constraint that prohibited replacement.

---

## Pattern Analysis: Common Rationalization Themes

| # | Rationalization Pattern | Appeared In | Frequency |
|:---|:---|:---|:---|
| 1 | "Unstable foundation / prepare ground before building" | S1 | 1/9 |
| 2 | "ACL is thin/ceremony for simple scenarios" | S2, S3 | 2/9 |
| 3 | "YAGNI applies to structural boundaries" | S2 | 1/9 |
| 4 | "Interaction count determines route scope" | S3 | 1/9 |
| 5 | "Route recommendation is being helpful" | S3 | 1/9 |
| 6 | "Cross-cutting concern doesn't need landscape scan" | S5 | 1/9 |
| 7 | "I already know the structure" | S5 | 1/9 |
| 8 | "Housekeeping is not refactoring" | S6 | 1/9 |
| 9 | "Small changes are implicitly exempt from scope control" | S6 | 1/9 |
| 10 | "Familiar workflow reduces risk" | S7 | 1/9 |
| 11 | "Self-contained feature can be treated as greenfield" | S7 | 1/9 |
| 12 | "Landscape map already contains impact analysis" | S8 | 1/9 |
| 13 | "Impact analysis is redundant documentation" | S8 | 1/9 |
| 14 | "Boundary proposal is the real design work" | S8 | 1/9 |

### Most Dangerous Patterns
1. **"YAGNI applies to structural boundaries"** — Misapplies a code design principle to an architectural firewall. Sounds technically literate. Defeats ACL before a single line of island code is written.
2. **"Landscape map already contains impact analysis"** — Creates a false equivalence between two steps that produce different artifacts. Causes MODIFY interactions to go undetected, blocking the STOP trigger that protects the pilot from proceeding into high-risk territory.
3. **"Housekeeping is not refactoring"** — Creates a subcategory of legacy changes exempt from scope control. Every engineer instinctively knows what "housekeeping" is, making this rationalization feel correct and professionally responsible.
4. **"Familiar workflow reduces risk"** — Inverts the actual risk. Using full-ddd for a legacy-integration scenario produces an island with no ACL specifications, no impact analysis, and no Legacy Touch Register — all the mechanisms that prevent the island from being stranded.
