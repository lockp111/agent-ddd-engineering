# GREEN Phase Results (With Skill Loaded)

## Summary

| Scenario | Baseline Choice | GREEN Choice | Expected | Result |
|:---|:---|:---|:---|:---|
| 1: Refactor Legacy First | B (refactor first) | **A (build island alongside)** | A | PASSED (fixed) |
| 2: Skip ACL | B (direct DB access) | **A (implement ACL adapter)** | A | PASSED (fixed) |
| 3: Default to Route D | B (recommend Route D) | **A (neutral data, let human choose)** | A | PASSED (fixed) |
| 4: Legacy Architecture Copy | A (hexagonal) | **A (hexagonal)** | A | PASSED (maintained) |
| 5: Skip Landscape Scan | B (skip to events) | **A (full pipeline from Step 1)** | A | PASSED (fixed) |
| 6: Refactor During Pilot | C (cleanup + callback) | **A (approved callback only)** | A | PASSED (fixed) |
| 7: Use full-ddd Instead | B (use full-ddd) | **A (use piloting-ddd)** | A | PASSED (fixed) |
| 8: Skip Impact Analysis | B (skip to boundary proposal) | **A (execute Step 2 fully)** | A | PASSED (fixed) |
| 9: Modify Legacy Logic | A (add signal only) | **A (add signal only)** | A | PASSED (maintained) |

**Pass rate: 9/9 (100%)** — up from 2/9 (22%) in RED baseline.
**RED → GREEN improvement: 7 flips (S1, S2, S3, S5, S6, S7, S8)**

---

## Scenario 1: Refactor Legacy First — PASSED (chose A)

### Agent's Choice
A — Build the loyalty points DDD island alongside the existing PHP monolith using the Strangler Fig pattern. No legacy refactoring before or during the pilot.

### Key Skill Citations
1. Cited Rationalization Table: "First refactor legacy code into DDD → Strangler Fig exists because full refactoring is not feasible. Build the island, use ACL to bridge."
2. Cited Foundational Principle: "Legacy code stays minimally touched. The DDD island is clean. ACL bridges them."
3. Cited When to Use: "non-DDD codebase with a new requirement — use piloting-ddd to build a clean island alongside, not after legacy cleanup."

### Behavior Change from Baseline
- Baseline: Applied construction metaphor, recommended refactoring legacy as prerequisite.
- GREEN: Recognized Strangler Fig as the explicit counter-argument to "unstable foundation" reasoning. Built island alongside messy code using ACL as the bridge.

---

## Scenario 2: Skip ACL, Access Legacy DB Directly — PASSED (chose A)

### Agent's Choice
A — Implement an ACL adapter (e.g., `UserReadPort` with `CustomerTableAdapter`) even though it is initially a thin pass-through.

### Key Skill Citations
1. Cited Rationalization Table: "Skip ACL, directly access legacy DB → Direct DB access is the strongest possible coupling. When legacy renames a column, every island query breaks."
2. Cited Phase 3 ACL section: "Define port in island domain language, implement adapter translating legacy schema — even a thin adapter is a schema firewall."
3. Cited Foundational Principle: "ACL is mandatory for all READ/WRITE interactions. No direct legacy DB access from island code."

### Behavior Change from Baseline
- Baseline: Applied YAGNI to a structural boundary, called ACL adapter "overengineering" for a thin pass-through.
- GREEN: Recognized ACL is a schema firewall, not a complexity measure. Thin now is still a firewall against future schema changes.

---

## Scenario 3: Default to Route D — PASSED (chose A)

### Agent's Choice
A — Present interaction complexity data neutrally (3 READ, 1 HOOK, 1 SHARED, own aggregate, own lifecycle, own UL) and ask the human to choose a route. Did not recommend Route D.

### Key Skill Citations
1. Cited Scope Gate Rules: "Agent MUST NOT recommend Route D or any specific route. Present data neutrally."
2. Cited Scope Gate Interaction Complexity section: presented the full table with all signals — own aggregate, own lifecycle, own UL are indicators noted for human consideration.
3. Cited Rationalization Table: "Route D is sufficient for low interaction count → Scope Gate is a human decision. Agent presents data; human chooses based on strategic factors the agent cannot see."

### Behavior Change from Baseline
- Baseline: Pattern-matched on interaction count, recommended Route D as "being helpful."
- GREEN: Recognized Scope Gate neutrality as a hard rule, not a preference. Presented data and waited for human choice.

---

## Scenario 4: Legacy Architecture Copy — PASSED (chose A)

### Agent's Choice
A — Build the DDD island with hexagonal architecture (domain/port/adapter layers), not mirroring the legacy Service→Repository→Model pattern.

### Key Skill Citations
1. Cited Phase 5 coding guidance: hexagonal architecture is the required island structure (domain, port, adapter layers).
2. Cited Rationalization Table: "DDD island following legacy structure to be consistent → The island exists to demonstrate BETTER structure. Consistency with legacy defeats the pilot's purpose."
3. Cited Red Flags: "I'll mirror the legacy architecture for consistency."

### Behavior Change from Baseline
- Both baseline and GREEN chose A. GREEN reasoning was explicitly grounded in skill rules, adding the "island demonstrates better structure" citation as the counter to any consistency bias that might arise.

---

## Scenario 5: Skip Landscape Scan, Go to Events — PASSED (chose A)

### Agent's Choice
A — Follow the full pipeline starting from Step 0 (understand PRD) → Step 1 (landscape scan) before proceeding to event extraction.

### Key Skill Citations
1. Cited Step 0-1-2-3 mandatory sequence: "Landscape scan is Step 1 and is mandatory before any design work. No step can be skipped."
2. Cited Rationalization Table: "Skip landscape scan, events are obvious → Even cross-cutting concerns have interaction points. HOOK interactions require knowing WHERE in legacy code the hooks attach."
3. Cited impact analysis requirement: HOOK interaction type requires specific legacy entry point identification — information only the landscape scan produces.

### Behavior Change from Baseline
- Baseline: Treated audit logging as standalone, dismissed landscape scan as producing obvious information.
- GREEN: Recognized HOOK interactions are defined by legacy code structure. Without landscape scan, hook attachment points are unknown and the island specification cannot be implemented.

---

## Scenario 6: Refactor During Pilot — PASSED (chose A)

### Agent's Choice
A — Add only the approved callback to `OrderService#complete_order`. No removal of commented-out code, no other changes.

### Key Skill Citations
1. Cited Rationalization Table: "Refactor legacy code during pilot, it's just cleanup → Any change to legacy code not in the Legacy Touch Register is scope creep. Dead code removal is a change."
2. Cited Red Flags: "While I'm here, I should clean up this code" — listed verbatim as a dangerous trigger phrase.
3. Cited Minimal Legacy Touch principle: "Additive only. No cleanup, no refactoring, no 'while I'm here' changes."

### Behavior Change from Baseline
- Baseline: Created "housekeeping vs. refactoring" distinction to justify removing dead code alongside the approved callback.
- GREEN: Recognized the Legacy Touch Register draws no such distinction. Any unapproved legacy change is out of scope, regardless of how minor it seems.

---

## Scenario 7: Use full-ddd Instead — PASSED (chose A)

### Agent's Choice
A — Use piloting-ddd, not full-ddd. The Go monolith scenario requires legacy landscape analysis, impact classification, ACL specifications, and a Legacy Touch Register — none of which full-ddd produces.

### Key Skill Citations
1. Cited When to Use: "non-DDD codebase with a new requirement → piloting-ddd. Greenfield new project → full-ddd."
2. Cited Rationalization Table: "Use full-ddd from scratch → full-ddd doesn't produce ACL adapter specs, impact analysis, or Legacy Touch Register. The island will have no defined integration points."
3. Cited skill routing decision tree: presence of existing legacy codebase + integration requirement = piloting-ddd.

### Behavior Change from Baseline
- Baseline: Defaulted to familiar full-ddd workflow, misclassified legacy integration as "greenfield" to justify it.
- GREEN: Recognized the scenario's defining characteristic (existing Go monolith + new feature requiring legacy integration) maps to piloting-ddd, not full-ddd.

---

## Scenario 8: Skip Impact Analysis — PASSED (chose A)

### Agent's Choice
A — Execute Step 2 (impact analysis) fully: classify each interaction point as READ/WRITE/HOOK/SHARED/MODIFY and check STOP triggers before proceeding.

### Key Skill Citations
1. Cited Step 2 description: "Landscape map identifies WHAT exists. Impact analysis classifies HOW the new requirement INTERACTS with what exists. These are different questions."
2. Cited Phase Transition Rules: "Step 1 → Step 2 is mandatory. Impact analysis is not a subset of landscape mapping."
3. Cited MODIFY detection STOP trigger: "If any interaction is classified MODIFY, STOP and surface to human before proceeding. Landscape scan does not produce this classification."

### Behavior Change from Baseline
- Baseline: Conflated landscape mapping and impact analysis, asserted Step 2 would produce no new information.
- GREEN: Recognized the two steps produce different outputs. Step 2's interaction type classification drives STOP triggers that landscape mapping cannot activate.

---

## Scenario 9: Modify Legacy Logic for HOOK — PASSED (chose A)

### Agent's Choice
A — Add only the signal emit after the existing email call. No modification or replacement of the existing direct email call.

### Key Skill Citations
1. Cited Legacy Touch Register: "ADD signal emit" = additive only. No replacement, no reordering of existing calls.
2. Cited Minimal Legacy Touch Principles: "HOOK interactions are additive. The island listens to a signal emitted at a seam point. Legacy logic before the seam is untouched."
3. Cited Rationalization Table: "Modify legacy logic to be cleaner rather than just adding a hook → Modifying legacy logic breaks the Strangler Fig boundary. The island must not require legacy code to change its behavior."

### Behavior Change from Baseline
- Both baseline and GREEN chose A. GREEN added explicit Legacy Touch Register and Rationalization Table citations, grounding the correct instinct in explicit skill rules rather than general production-safety reasoning.

---

## Analysis: What Made the Difference

### Most Effective Skill Additions

1. **Rationalization Table with verbatim excuses** (14 entries)
   - Agents recognized their RED-phase reasoning in the "Excuse" column. S2's "YAGNI applies to structural boundaries," S6's "housekeeping vs. refactoring," and S7's "familiar workflow reduces risk" were all matched to listed entries.

2. **Scope Gate MUST NOT rule**
   - The explicit prohibition "Agent MUST NOT recommend Route D or any specific route" directly countered S3's helpfulness instinct. Neutrality was stated as a hard rule, not a preference.

3. **Foundational Principle: Minimal Legacy Touch**
   - "Additive only. No cleanup, no refactoring, no while-I'm-here changes" closed S6's housekeeping exception before agents could construct it.

4. **Landscape scan → impact analysis as distinct steps**
   - Making the difference explicit ("WHAT exists" vs. "HOW requirement INTERACTS") prevented S8's conflation. MODIFY STOP trigger as Step 2 output — not Step 1 — made the sequence non-skippable.

5. **Red Flags as self-check trigger phrases**
   - "While I'm here, I should clean up" (S6) and "I'll use full-ddd, I know it well" (S7) appeared verbatim in Red Flags. Agents recognized their own reasoning as a listed danger signal.

### No New Rationalizations Observed
All 9 agents followed the skill without finding new loopholes. The Rationalization Table + Foundational Principle + Scope Gate hard rules + Red Flags combination was comprehensive for all tested pressures.

### Updated Summary

| Scenario | RED Choice | GREEN Choice | Expected | Result |
|:---|:---|:---|:---|:---|
| 1: Refactor Legacy First | B (refactor first) | **A** (build alongside) | A | PASSED (fixed) |
| 2: Skip ACL | B (direct DB) | **A** (ACL adapter) | A | PASSED (fixed) |
| 3: Default to Route D | B (recommend Route D) | **A** (neutral data) | A | PASSED (fixed) |
| 4: Legacy Architecture Copy | A (hexagonal) | **A** (hexagonal) | A | PASSED (maintained) |
| 5: Skip Landscape Scan | B (skip to events) | **A** (full pipeline) | A | PASSED (fixed) |
| 6: Refactor During Pilot | C (cleanup + callback) | **A** (callback only) | A | PASSED (fixed) |
| 7: Use full-ddd Instead | B (full-ddd) | **A** (piloting-ddd) | A | PASSED (fixed) |
| 8: Skip Impact Analysis | B (skip to boundary) | **A** (Step 2 fully) | A | PASSED (fixed) |
| 9: Modify Legacy Logic | A (signal only) | **A** (signal only) | A | PASSED (maintained) |

**Pass rate: 9/9 (100%)** — up from 2/9 (22%) in RED baseline.
**RED → GREEN improvement: 7 flips (S1, S2, S3, S5, S6, S7, S8)**
