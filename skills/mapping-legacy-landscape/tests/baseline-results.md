# Baseline Results (RED Phase — No Skill Loaded)

## Summary

| Scenario | Pressures | Agent Choice | Expected | Result |
|:---|:---|:---|:---|:---|
| 1: Skip Systematic Scan | efficiency bias, overconfidence | **B** (read only models.py/views.py) | A (systematic scan within confirmed scope) | FAILED |
| 2: DDD Projection onto Legacy Code | familiarity bias, DDD overconfidence | **C** (mixed — DDD terms where match seems clear) | A (neutral terminology) | FAILED |
| 3: Completeness Bias (Scan Entire Codebase) | completeness bias, thoroughness signaling | **A** (scan only relevant directories) | A (scan only relevant directories) | PASSED |
| 4: Optimistic Seam Assessment | optimism bias, expedience | **B** (rate as STRONG) | A (WEAK or NO SEAM) | FAILED |

**Failure rate: 3/4 (75%)**

---

## Scenario 1: Skip Systematic Scan — FAILED (chose B)

### Agent's Choice
B — Read only models.py and views.py from each Django app, skipping services.py, helpers.py, tasks.py, and management commands.

### Verbatim Rationalizations
1. **"Django apps follow a standard structure — models.py defines the data, views.py handles requests. That covers the core."**
   - Framework convention fallacy: treats Django's standard file names as evidence of standard content placement.
2. **"services.py and helpers.py are utility code. The real domain is in models and views."**
   - Layer assumption: designates "utility" files as secondary without reading them.
3. **"Reading every file in 4 apps is slow — models.py gives 80% of the picture with 20% of the effort."**
   - 80/20 efficiency framing: applies Pareto heuristic to code discovery, where it does not apply.
4. **"If I find something missing later, I can always go back and read the service files."**
   - Lazy loading rationalization: treats systematic scan as optional overhead, not a required foundation.

### Key Insight
The agent applied 80/20 efficiency thinking to code scanning, treating services/helpers/tasks as secondary. In legacy Django, these files often contain the most important business logic — pricing in services.py, retry logic in tasks.py, scheduling in management commands. The agent's framework-convention assumption ("Django apps follow a standard structure") is exactly the kind of confident shortcut that causes missed dependencies. A payment retry feature touching only models.py and views.py is a signal the scan was incomplete, not that the feature is simple.

---

## Scenario 2: DDD Projection onto Legacy Code — FAILED (chose C)

### Agent's Choice
C — Mixed approach: use DDD terminology where the match seems clear (Order model as Aggregate Root, PaymentService as ACL), neutral terms elsewhere.

### Verbatim Rationalizations
1. **"Order model with status transitions is functionally equivalent to an Aggregate Root — using that term helps the next phase."**
   - Equivalence fallacy: "functionally equivalent" elides the difference between a Rails ActiveRecord model and a true Aggregate Root.
2. **"PaymentService wrapping Stripe IS an ACL pattern — calling it that is accurate, not projection."**
   - Naming coincidence confidence: the word "Service" plus Stripe wrapping feels like a pattern match — but the class may have 150 other mixed responsibilities.
3. **"Using DDD terms where the match is obvious saves translation effort later."**
   - Efficiency reframing: labels projection as "saving work" rather than introducing risk.
4. **"I'll use neutral terms for ambiguous cases, but clear matches deserve the DDD label."**
   - Confidence threshold creation: invents a self-assessed threshold for "clear match" that the agent alone judges, with no external check.

### Key Insight
The agent created a self-administered "confidence threshold" for DDD labeling — "clear matches" get DDD terms. But surface-level pattern matching is precisely the problem. A Rails Service object with 200 lines of mixed concerns is not an Application Service. An ActiveRecord model is not an Aggregate Root. The "clear match" is an illusion created by naming coincidence. Once DDD terms enter the landscape map, they constrain future phases: the team stops questioning whether PaymentService is an ACL and starts building on that assumption.

---

## Scenario 3: Completeness Bias (Scan Entire Codebase) — PASSED (chose A)

### Agent's Choice
A — Scan only the two relevant packages (user preferences and notification sending), expand incrementally on evidence.

### Key Reasoning (Correct)
1. "200K+ lines of code is far too large to scan for a notification preferences feature."
2. "The requirement clearly involves user preferences and notification sending — those are the two relevant packages."
3. "If I discover imports from other packages during scanning, I can add those to scope then."

### Why It Passed
The practical absurdity of scanning 200K lines for a small feature provided a strong enough counter-signal. The agent's efficiency instinct correctly identified this as waste rather than thoroughness. The scale of the mismatch (200K lines vs. a preferences toggle feature) was sufficient to override the completeness bias without skill guidance. This scenario lacked social pressure or time pressure, which were effective failure vectors in S1 and S4.

---

## Scenario 4: Optimistic Seam Assessment — FAILED (chose B)

### Agent's Choice
B — Rate the PaymentService class as STRONG seam based on single-file containment and public method interface.

### Verbatim Rationalizations
1. **"PaymentService is contained in a single file with a clear name — that's a natural boundary."**
   - File containment fallacy: equates physical file boundaries with interface cleanliness.
2. **"The public methods of the class form an implicit interface. Other code calls PaymentService, not its internal models."**
   - Implicit interface fallacy: 40+ methods on a single class is not a clean interface — it is an accretion of unrelated concerns behind one namespace.
3. **"Cross-app model access is an implementation detail — the ACL adapter will handle the mapping."**
   - Deferred responsibility rationalization: treats deep ORM coupling as something the next phase will "fix" rather than evidence of a weak seam.
4. **"Rating it WEAK would slow down the process. The team needs to move forward."**
   - Expedience pressure: uses team velocity as justification for optimistic assessment.

### Key Insight
The agent equated file containment with interface cleanliness. A 40-method class mixing 6 concerns (payments, refunds, subscriptions, reporting, fraud, retry) with direct ORM access to Order and User models is the opposite of a clean boundary. STRONG requires a clean facade with minimal cross-boundary coupling — this class would need significant decomposition before an ACL could attach cleanly. The "single file" containment is meaningless when the file itself is a tangled mesh of concerns. Optimistic ratings here cause underestimation of migration effort in all subsequent phases.

---

## Pattern Analysis: Common Rationalization Themes

| # | Rationalization Pattern | Appeared In | Frequency |
|:---|:---|:---|:---|
| 1 | "Framework convention means standard content placement" | S1 | 1/4 |
| 2 | "80/20 efficiency applies to code discovery" | S1 | 1/4 |
| 3 | "I can always go back if I miss something" | S1 | 1/4 |
| 4 | "Functionally equivalent is good enough for labeling" | S2 | 1/4 |
| 5 | "Self-assessed confidence threshold for DDD terms" | S2 | 1/4 |
| 6 | "Naming coincidence confirms DDD pattern match" | S2 | 1/4 |
| 7 | "Single file containment equals clean boundary" | S4 | 1/4 |
| 8 | "Cross-app coupling is an implementation detail for later" | S4 | 1/4 |
| 9 | "Team velocity justifies optimistic rating" | S4 | 1/4 |

### Most Dangerous Patterns
1. **"Naming coincidence confirms DDD pattern match"** — Projects DDD structure onto legacy code based on class names alone. Once DDD terms enter the map, downstream phases build on false assumptions without questioning them.
2. **"Single file containment equals clean boundary"** — Causes systematic over-rating of seam strength, leading to underestimated migration effort across all subsequent phases.
3. **"80/20 efficiency applies to code discovery"** — Produces an incomplete landscape map without any signal that it is incomplete. Missing files are invisible; the agent does not know what it does not know.
