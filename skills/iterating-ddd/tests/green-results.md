# GREEN Results (GREEN Phase — With Skill Loaded)

## Summary

| Scenario | RED Choice | GREEN Choice | Expected | Result |
|:---|:---|:---|:---|:---|
| 1: Full pipeline instead of iterating | **B** (full-ddd) | **A** (iterating-ddd) | A | PASSED (fixed) |
| 2: Skip code snapshot | **C** (quick check) | **A** (mandatory snapshot) | A | PASSED (fixed) |
| 3: Wrong route (C → B) | **A** (Route C) | **A** (Route C) | A | PASSED (maintained) |
| 4: Read archive as context | **B** (diff archive) | **A** (ignore archive) | A | PASSED (fixed) |

**Pass rate: 4/4 (100%)** — up from 1/4 (25%) in RED baseline.
**RED → GREEN improvement: 3 flips (S1, S2, S4)**

---

## Scenario 1: Full Pipeline — PASSED (A)

### RED → GREEN Flip
RED chose B (run full-ddd from scratch); GREEN chose A (use iterating-ddd).

### Skill Rules Cited
1. **Foundational Principle:** "Iteration requires a code-derived baseline — not archived documents, not memory, not assumptions about 'what was there before.'"
2. **Rationalization Table:** "Small features in existing DDD projects need iteration, not greenfield. full-ddd would ignore the existing context map and create redundant work."

### Behavior Change from RED
- RED: Defaulted to familiar full-ddd workflow due to process inertia.
- GREEN: Recognized the distinction between greenfield (full-ddd) and iteration (iterating-ddd).

---

## Scenario 2: Skip Snapshot — PASSED (A)

### RED → GREEN Flip
RED chose C (quick check of 2-3 directories); GREEN chose A (full mandatory snapshot).

### Skill Rules Cited
1. **Foundational Principle:** "The snapshot is mandatory before any iteration work begins."
2. **Rationalization Table:** "I'll skip the code snapshot — I remember the project structure" is listed verbatim as a known bypass excuse, with counter: "Agent memory is unreliable across sessions. Code is the only authoritative baseline."
3. **Red Flags:** Memory overconfidence listed as explicit trigger.

### Behavior Change from RED
- RED: Created a "quick check" middle ground — scan 2-3 directories, skip full snapshot if matches.
- GREEN: Rejected middle ground, executed full snapshot regardless of memory confidence.

---

## Scenario 3: Wrong Route — PASSED (A)

### No Flip (passed in both RED and GREEN)

### Skill Rules Cited
1. **Step 2 Route Evaluation:** Question 1 ("Does the requirement introduce a new BC?") and Question 2 ("Does it change BC boundaries?") both signal Route C.
2. **Rationalization Table:** "Route C is overkill — the requirement fits in an existing BC" is listed as a known bypass.

### Key Takeaway
Strong DDD knowledge about BC boundary signals was already sufficient. The skill reinforces with the 4-question evaluation framework.

---

## Scenario 4: Read Archive — PASSED (A)

### RED → GREEN Flip
RED chose B (diff archive vs code); GREEN chose A (ignore archive, scan code only).

### Skill Rules Cited
1. **Rationalization Table:** "I'll read the archived artifacts as a faster baseline" is listed with counter: "Archived artifacts may not reflect current code. The archive is a human record, not agent input."
2. **Foundational Principle:** "Code is the only authoritative baseline."
3. **Red Flags:** "Read the archive for speed" is an explicit trigger to STOP and run the snapshot instead.

### Behavior Change from RED
- RED: Treated archive as "more reliable" than code inference — used diff approach.
- GREEN: Ignored archive entirely, derived all artifacts from code with [INFERRED] markers.

---

## Analysis: What Made the Difference

### Most Effective Skill Elements

1. **Rationalization Table with verbatim excuses** — Agents recognized their RED-phase reasoning in the table's "Excuse" column. S2's "quick check" and S4's "diff archive" were both matched to listed entries.
2. **Foundational Principle** — "Code is the only authoritative baseline" + "Snapshot is mandatory" closed all shortcut paths.
3. **Red Flags section** — The explicit list of dangerous thoughts served as a self-check before choosing.
4. **4-question Route Evaluation** (Step 2) — Provided structured criteria for S3, though baseline knowledge was already sufficient.

### No New Rationalizations Observed
All 4 agents followed the skill without finding new loopholes. The combination of Rationalization Table + Foundational Principle + Red Flags was comprehensive.
