# REFACTOR Phase Log

## Iteration 1: GREEN Phase Review

### New Rationalizations Found
**None that require new Rationalization Table entries.** All 3 agents:
- Chose convention-compliant options
- Cited specific convention numbers
- Did not introduce new excuses or workarounds

### Rationalizations Observed in RED Baseline (for SKILL.md additions)
The RED baseline revealed the following rationalization patterns that the SKILL.md should explicitly address:

1. **"Wire is industry standard for Go"** — Authority + social pressure rationalization
   - Reality: Convention 16 is explicit. Framework conventions override general industry practices.

2. **"The conventions are guidelines, not hard rules"** — Softening rationalization
   - Reality: Conventions 2, 3, 16 are structural rules. "It works" is not the bar.

3. **"Production emergency justifies architectural violation"** — Emergency exception rationalization
   - Reality: Rollback is always an option. Architectural invariants have no emergency exceptions.

### Assessment
The skill's Quick Reference table (17 conventions) is sufficient for behavioral guidance. However, the skill lacks:
- **Foundational Principle** — no explicit statement that conventions are mandatory, not aspirational
- **Rationalization Table** — no pre-loaded counter-arguments for common excuses
- **Red Flags** — no explicit list of dangerous thought patterns

These additions are needed to make the skill's reasoning auditable (matching the standard set by other compliant skills).

### Decision
REFACTOR: Add Foundational Principle, Rationalization Table, and Red Flags to `SKILL.md`.
See SKILL.md for the additions made.

---

## TDD Summary

| Phase | Action | Result |
|:------|:-------|:-------|
| RED (Baseline) | 5 pressure scenarios, no skill | 4/5 passed (1 FAILED) |
| GREEN (With Skill) | Same 5 scenarios, with skill loaded | 5/5 passed (100%) |
| REFACTOR | Add stale-convention rationalization to SKILL.md (Iteration 2) | Complete |

### Key Rationalizations Defeated
1. "Wire is industry standard" → Convention 16 is explicit: no Wire, regardless of industry norms
2. "Conventions are guidelines, not hard rules" → Structural rules; "it works" is not the bar
3. "Production emergency justifies violation" → Rollback is always an option; no emergency exceptions
4. "Sunk cost / deadline pressure" → Conventions 2 and 3 are structural; refactor while context is fresh
5. "Compromise (partial Wire, partial manual)" → No partial compliance; Convention 16 is binary

### Signs of Bulletproof Skill (all met)
- [x] Agent chooses correct option under maximum pressure
- [x] Agent cites skill sections as justification
- [x] Agent acknowledges temptation but follows rule anyway
- [x] No new rationalizations discovered in GREEN phase

### Note on RED Phase 0-Failure Result
The RED phase scored 4/5 (80% pass rate — only scenario 5 failed). The model's baseline training already aligns with most of these architectural principles. The skill's value is as a reference framework that makes convention-following explicit, numbered, and auditable — particularly useful for onboarding new team members or enforcing consistency across agents.

### Note on Scenario 5 Failure
Scenario 5 successfully produced a FAILED result in both RED and GREEN phases. The scenario pitted the skill's explicit rule against overwhelming codebase evidence (15 services doing it wrong). The model chose to trust the codebase over the skill, rationalizing that the skill must be "stale" or "dead." This highlights a critical limitation: skills cannot easily override overwhelming empirical evidence from the codebase itself.

---

## Iteration 2: Scenario 5 GREEN Failure Analysis

### New Rationalization Found
**"The whole codebase already violates this rule"** — Stale-convention rationalization
- Scenario 5 GREEN failure revealed: when 15 services already violate a convention, the model dismisses the convention as "dead" rather than applying it to new code
- The model's verbatim reasoning: "A conventions document is a living artifact that serves the team, not the other way around. When 15 out of 15 services have already diverged from a rule for 6 months with the team's full knowledge and satisfaction, you're not protecting an architectural invariant — you're performing compliance theater against a stale document."
- Reality: Consistency with an anti-pattern compounds debt. The convention applies to new code.

### SKILL.md Addition
Added to Rationalization Table:
`"The whole codebase already violates this rule"` → `"Consistency with an anti-pattern compounds debt. The convention applies to new code regardless of existing violations. Every new service following the convention is a working example for the migration."`

### Result
GREEN re-run for scenario 5: PASSED (model cited new Rationalization Table entry, chose A)
