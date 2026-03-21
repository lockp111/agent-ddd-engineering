# GREEN Phase Results (With Skill Loaded)

## Summary

| Scenario | Baseline Choice | GREEN Choice | Expected | Result |
|:---|:---|:---|:---|:---|
| 1: Skip Systematic Scan | **B** (models.py/views.py only) | **A** (systematic scan within confirmed scope) | A | PASSED (fixed) |
| 2: DDD Projection onto Legacy Code | **C** (mixed DDD/neutral terms) | **A** (neutral terminology throughout) | A | PASSED (fixed) |
| 3: Completeness Bias (Scan Entire Codebase) | **A** (relevant directories only) | **A** (relevant directories only) | A | PASSED (maintained) |
| 4: Optimistic Seam Assessment | **B** (STRONG rating) | **A** (WEAK rating) | A | PASSED (fixed) |

**Pass rate: 4/4 (100%)** — up from 1/4 (25%) in RED baseline.
**RED → GREEN improvement: 3 flips (S1, S2, S4)**

---

## Scenario 1: Skip Systematic Scan — PASSED (chose A)

### Agent's Choice
A — Systematic scan of all files within the confirmed scope (all 4 Django apps), including services.py, helpers.py, tasks.py, and management commands.

### Key Skill Citations
1. **Foundational Principle:** "Observe honestly — do not skip the systematic scan. Legacy code directory names lie; content placement does not follow conventions."
2. **Rationalization Table:** "I can tell structure from top-level directories" → "Legacy code directory names lie. services.py in a Django app often contains more domain logic than models.py."
3. **Quick Reference Steps 1–8:** Systematic scan listed as the required action for each app directory, with no file type exclusions.
4. **Red Flags:** "The model layer is enough to understand the domain" listed as an explicit stop signal.

### Behavior Change from Baseline
- Baseline scanned only models.py and views.py per app, treating services/helpers/tasks as "utility."
- GREEN scanned all files within the confirmed scope, including services.py, helpers.py, tasks.py, and management commands.
- GREEN explicitly noted retry logic in tasks.py and pricing logic in services.py as key findings — both invisible to the baseline scan.

---

## Scenario 2: DDD Projection onto Legacy Code — PASSED (chose A)

### Agent's Choice
A — Neutral descriptive terminology throughout the entire landscape map, with no DDD labels applied to any legacy component.

### Key Skill Citations
1. **Foundational Principle:** "Observe honestly — do not project DDD concepts onto legacy code. Describe what you see, not what you wish were there."
2. **Rationalization Table:** "These legacy patterns are close enough to DDD — I'll use DDD terminology where the match is obvious" → "Projecting DDD onto legacy code creates false confidence. A Rails Service is not an Application Service. An ActiveRecord model is not an Aggregate Root."
3. **Red Flags:** "This is basically DDD already — just use DDD terms for the clear matches" listed as a trigger to stop and revert to neutral language.

### Behavior Change from Baseline
- Baseline applied DDD terms ("Aggregate Root," "ACL") where naming coincidence suggested a match, using neutral terms only for "ambiguous" cases.
- GREEN used exclusively neutral descriptive terms: "OrderService class (200 lines, mixed payment and order concerns)," "PaymentService class (wraps Stripe, also contains retry logic and fraud checks)."
- GREEN explicitly declined to label Order model as Aggregate Root, noting: "It is an ActiveRecord model with status callbacks — describing it as an Aggregate Root would import assumptions that need to be validated in Phase 2, not assumed in mapping."

---

## Scenario 3: Completeness Bias (Scan Entire Codebase) — PASSED (chose A)

### Agent's Choice
A — Scan only the relevant directories (user preferences package and notification sending package), expand incrementally on evidence.

### Key Skill Citations
1. **Step 1 Scope Confirmation:** Confirm scope with the human before scanning — scope is the requirement plus its direct dependencies, not the entire codebase.
2. **Rationalization Table:** "For completeness, I should scan the entire codebase to avoid missing anything" → "Completeness bias. Scanning 200K lines for a notification preferences feature produces noise, not insight. Start with confirmed scope and expand on evidence."

### Behavior Change from Baseline
- Baseline already chose A (no flip). GREEN reasoning adds explicit skill citations that baseline lacked.
- Both baseline and GREEN correctly rejected full-codebase scan; GREEN could articulate the rule rather than relying on instinct.

---

## Scenario 4: Optimistic Seam Assessment — PASSED (chose A)

### Agent's Choice
A — Rate PaymentService as WEAK seam. Documented: 40+ methods, 6 mixed concerns (payments, refunds, subscriptions, reporting, fraud, retry), direct cross-app ORM access to Order and User models.

### Key Skill Citations
1. **Step 8 Seam Strength Rating definitions:** "STRONG requires an already-clean interface or facade with minimal cross-boundary coupling. WEAK = mixed concerns, cross-boundary coupling present. NO SEAM = no discernible boundary exists."
2. **Rationalization Table:** "The class is in one file with a clear public interface — that is a natural seam" → "File containment does not equal interface cleanliness. Count concerns, count cross-boundary dependencies. A 40-method class mixing 6 concerns is not a clean facade."
3. **Red Flags (implied):** Optimistic seam ratings that defer coupling problems to "the ACL will handle it" are listed as a known bypass pattern.

### Behavior Change from Baseline
- Baseline rated STRONG based on single-file containment and the existence of public methods.
- GREEN rated WEAK based on concern count (6), method count (40+), and direct cross-app ORM access to two external models.
- GREEN explicitly rejected the "ACL will handle it" deferral: "Deferred coupling is still coupling. The seam rating describes the current state, not the desired future state."

---

## Analysis: What Made the Difference

### Most Effective Skill Elements

1. **Rationalization Table with verbatim excuses** — Agents recognized their RED-phase reasoning matched listed entries. S1's "I can tell structure from top-level directories" and S2's "match is obvious" confidence threshold were both caught by the table.
2. **Foundational Principle ("observe honestly, don't project")** — A single, unambiguous principle closed both the scanning shortcut (S1) and the DDD projection shortcut (S2) with one rule.
3. **Step 8 Seam Strength Rating definitions** — Quantitative criteria (concern count, cross-boundary dependency count) replaced the agent's qualitative "single file = clean boundary" heuristic in S4.
4. **Red Flags section** — "The model layer is enough" (S1) and "this is basically DDD already" (S2) were both present as explicit stop signals, preventing the agent from treating its rationalization as novel reasoning.

### No New Rationalizations Observed
All 4 agents followed the skill without finding new loopholes. The Rationalization Table, Foundational Principle, Step 8 definitions, and Red Flags were comprehensive for the tested pressure scenarios.

---

## Updated Summary

| Scenario | RED Choice | GREEN Choice | Expected | Result |
|:---|:---|:---|:---|:---|
| 1: Skip Systematic Scan | **B** (partial scan) | **A** (systematic scan) | A | PASSED (fixed) |
| 2: DDD Projection onto Legacy Code | **C** (mixed terms) | **A** (neutral terms) | A | PASSED (fixed) |
| 3: Completeness Bias | **A** (relevant dirs) | **A** (relevant dirs) | A | PASSED (maintained) |
| 4: Optimistic Seam Assessment | **B** (STRONG) | **A** (WEAK) | A | PASSED (fixed) |
