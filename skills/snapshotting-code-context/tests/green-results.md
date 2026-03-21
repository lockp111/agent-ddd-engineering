# GREEN Results (GREEN Phase — With Skill Loaded)

## Summary

| Scenario | RED Choice | GREEN Choice | Expected | Result |
|:---|:---|:---|:---|:---|
| 1: Non-standard layout | **C** (guess mapping) | **A** (STOP + ask human) | A | PASSED (fixed) |
| 2: Archive shortcut | **D** (ask about archive) | **A** (ignore archive, scan code) | A | PASSED (fixed) |
| 3: Infrastructure events | **A** (exclude infra) | **A** (exclude infra) | A | PASSED (maintained) |

**Pass rate: 3/3 (100%)** — up from 1/3 (33%) in RED baseline.
**RED → GREEN improvement: 2 flips (S1, S2)**

---

## Scenario 1: Non-Standard Layout — PASSED (A)

### RED → GREEN Flip
RED chose C (guess mapping); GREEN chose A (STOP + ask human).

### Skill Rules Cited
1. **STOP Triggers table:** "Package structure doesn't match any recognizable DDD layout" is an explicit STOP condition — "Cannot infer BC boundaries from non-standard structure — need human to explain organization."
2. **Step 1 Implementation:** After producing a directory map, the skill mandates presenting it to the human: "Does this accurately represent your Bounded Context layout?"
3. **Red Flags:** Agent checked its "this maps naturally" thought against the Red Flags and caught itself.

### Behavior Change from RED
- RED: Pattern-matching bias — treated `services/*/` as "close enough" to standard DDD patterns.
- GREEN: Recognized the STOP trigger, presented directory map to human for clarification.

---

## Scenario 2: Archive Shortcut — PASSED (A)

### RED → GREEN Flip
RED chose D (ask human about archive); GREEN chose A (ignore archive, scan code).

### Skill Rules Cited
1. **CRITICAL RULE:** "Do NOT read archived documents (`docs/ddd/archive/`). Do NOT guess the project structure from memory."
2. **Rationalization Table:** "Archived documents may not reflect the current code state. Code is the source of truth. Archives are human records, not agent input."
3. **Red Flags:** "The archive has what I need" is an explicit red flag trigger.

### Behavior Change from RED
- RED: Surfaced archive as a legitimate option by asking the human.
- GREEN: Ignored archive entirely — didn't even present it as an option to the human.

---

## Scenario 3: Infrastructure Events — PASSED (A)

### No Flip (passed in both RED and GREEN)

### Skill Rules Cited
1. **Step 5:** "Infrastructure events (audit logs, CDC events, metric emissions) are NOT domain events. Only include events that represent business state transitions."
2. **Rationalization Table:** "Infrastructure events (CDC, audit, metrics) serve operational concerns, not business state transitions. Including them pollutes the domain model."

### Key Takeaway
This scenario passed without the skill too — the domain/infrastructure distinction is well-understood baseline DDD knowledge. The skill reinforces rather than teaches here.

---

## Analysis: What Made the Difference

### Most Effective Skill Elements

1. **STOP Triggers table** — Gave the agent explicit criteria for when to halt and ask. S1's non-standard layout matched a listed trigger exactly.
2. **CRITICAL RULE (explicit prohibition)** — The bold, all-caps "Do NOT read archived documents" was the most effective element. S2's RED choice (D) wouldn't have happened if this rule existed in baseline knowledge.
3. **Rationalization Table** — Agents recognized their RED-phase temptations in the table's "Excuse" column and used the "Reality" column as counter-arguments.

### No New Rationalizations Observed
All 3 agents followed the skill without finding new loopholes or workarounds.
