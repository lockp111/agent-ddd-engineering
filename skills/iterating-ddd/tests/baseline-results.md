# Baseline Results (RED Phase — No Skill Loaded)

## Summary

| Scenario | Pressures | Agent Choice | Expected | Result |
|:---|:---|:---|:---|:---|
| 1: Full pipeline instead of iterating | process inertia, completeness | **B** (run full-ddd) | A (use iterating-ddd) | FAILED |
| 2: Skip code snapshot | efficiency, memory overconfidence | **C** (quick check) | A (mandatory snapshot) | FAILED |
| 3: Wrong route (C → B) | simplification, work avoidance | **A** (Route C for new BC) | A (Route C for new BC) | PASSED |
| 4: Read archive as context | efficiency, accuracy bias | **B** (diff archive vs code) | A (ignore archive, scan code) | FAILED |

**Failure rate: 3/4 (75%)**

---

## Scenario 1: Full Pipeline Instead of Iterating — FAILED (chose B)

### Agent's Choice
B — Execute full-ddd from scratch: extract all events, map all bounded contexts from zero.

### Verbatim Rationalizations
1. **"Without a specific skill guiding incremental DDD iteration, the natural agent tendency is to default to the known, complete workflow"**
   - Process inertia: defaults to familiar full-ddd workflow.
2. **"The completeness bias and process inertia push toward running everything from scratch to guarantee consistency"**
   - Completeness framing: running everything is "safer" than scoping work.
3. **"The full pipeline feels safer because it leaves no gaps"**
   - Risk aversion: treats iteration as inherently riskier than full re-execution.

### Key Insight
The agent explicitly acknowledged its own process inertia and completeness bias but followed them anyway. Without the iterating-ddd skill, the agent has no framework for scoping work to only what changed.

---

## Scenario 2: Skip Code Snapshot — FAILED (chose C)

### Agent's Choice
C — Do a "quick check" — scan 2-3 key directories to verify memory is correct, skip full snapshot.

### Verbatim Rationalizations
1. **"The pragmatic inclination is to do a 'quick check' rather than a full snapshot"**
   - Efficiency pressure: full snapshot feels wasteful.
2. **"If the key directories match what memory says, it feels wasteful to regenerate artifacts that appear unchanged"**
   - Memory overconfidence: trusts prior session memory as reliable.
3. **"This middle-ground approach satisfies efficiency pressure while adding a minimal verification step"**
   - Compromise framing: "quick check" feels like a responsible middle ground.

### Key Insight
The agent created a "middle ground" that sounds reasonable but defeats the purpose of the snapshot. A quick check of 2-3 directories can miss renamed packages, moved files, new contexts, or deleted features. The snapshot exists because memory is unreliable and partial checks give false confidence.

---

## Scenario 3: Wrong Route (C → B) — PASSED (chose A)

### Agent's Choice
A — Route C: Shipping & Delivery is a distinct domain with its own language, lifecycle, and external dependencies. It needs its own BC.

### Key Reasoning (Correct)
1. "Shipping & Delivery Tracking has its own distinct ubiquitous language (carrier, shipment, tracking number, delivery window)"
2. "Its own lifecycle (shipment created → in transit → delivered → returned)"
3. "Its own external dependencies (carrier APIs)"
4. "Forcing this into the Order context because 'orders have shipping' is a superficial coupling argument"

### Why It Passed
The agent has strong DDD knowledge about BC boundary signals (own language, own lifecycle, own dependencies). The scenario provided clear signals that Shipping is a distinct domain. This scenario lacked social pressure or time pressure, which were effective failure vectors in S1 and S2.

---

## Scenario 4: Read Archive as Context — FAILED (chose B)

### Agent's Choice
B — Read the archive as the baseline. Diff against code to find changes. Only add [INFERRED] markers for differences.

### Verbatim Rationalizations
1. **"The archived artifacts are described as comprehensive, human-approved, and well-structured"**
   - Accuracy bias: treats human-approved documents as inherently more reliable than code inference.
2. **"Makes them feel like a more reliable and efficient baseline than re-inferring from code"**
   - Frames archive as "more accurate" than code — inverting the source of truth.
3. **"The pragmatic choice is to diff the archive against code rather than repeat work that was already done"**
   - Efficiency framing: code scanning is "repeating work" — ignores that code evolves.

### Key Insight
The agent treated archived artifacts as MORE reliable than code. This is exactly the inversion the skill must prevent. Archives were accurate at archive time; code is accurate NOW. The diff approach seems reasonable but misses: deleted features don't show up in diffs, renamed concepts create false "changes," and restructured code may have the same behavior but different architecture.

---

## Pattern Analysis: Common Rationalization Themes

| # | Rationalization Pattern | Appeared In | Frequency |
|:---|:---|:---|:---|
| 1 | "Default to known/complete workflow" | S1 | 1/4 |
| 2 | "Full pipeline is safer than iteration" | S1 | 1/4 |
| 3 | "Quick check is a responsible middle ground" | S2 | 1/4 |
| 4 | "Memory is reliable enough with verification" | S2 | 1/4 |
| 5 | "Archive is more reliable than code inference" | S4 | 1/4 |
| 6 | "Diff archive vs code is pragmatic" | S4 | 1/4 |
| 7 | "Code scanning repeats already-done work" | S4 | 1/4 |

### Most Dangerous Patterns
1. **"Quick check is a responsible middle ground"** — Creates a false sense of rigor while skipping the actual work. Partial verification gives false confidence.
2. **"Archive is more reliable than code inference"** — Inverts the source of truth. The entire snapshot skill exists to derive truth from code, not documents.
3. **"Default to known workflow"** — Process inertia toward full-ddd prevents scoping work appropriately.
