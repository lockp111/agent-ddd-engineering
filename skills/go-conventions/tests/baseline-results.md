# Baseline Results (RED Phase — No Skill Loaded)

## Summary

| Scenario | Pressures | Agent Choice | Expected | Result |
|:---------|:----------|:-------------|:---------|:-------|
| 1: Wire DI vs Manual Assembly | Authority + Social | B | B | PASSED |
| 2: Nested Dirs vs Flat Structure | Sunk Cost + Time | C | C | PASSED |
| 3: Domain Layer Importing Infra | Complexity + Exhaustion | B | B | PASSED |
| 4: Proto Management | Convenience + Speed | B | B | PASSED |
| 5: The Sunk Cost Consistency Trap | Authority + Consistency | B | A | FAILED |

**RED Phase Score: 4/5 correct (1 FAILED)**

## Scenario 1: Wire DI vs Manual Assembly

### Agent's Choice
B — Keep manual assembly, explain Convention 16, and ask to remove the Wire step from CI.

### Verbatim Rationalizations
> "The Go DDD convention is explicit about this: the `cmd/` layer is the composition root where you manually wire dependencies. This is a deliberate architectural choice, not a gap waiting to be filled by a DI framework."
> "The tech lead's instinct ('Wire is industry standard for Go') is reasonable in general Go projects, but wrong for this specific architecture."
> "Respond to the tech lead directly, not defensively. Frame it as 'this framework has a convention' not 'you're wrong.'"

### Key Insight
The agent correctly identified that the framework's explicit conventions override general "industry standard" practices and authority pressure. It also provided a pragmatic, non-confrontational way to handle the social pressure.

## Scenario 2: Nested Directories vs Flat Structure

### Agent's Choice
C — Refactor now, before this ships.

### Verbatim Rationalizations
> "The code works, but 'works' isn't the bar. The bar is 'works and is maintainable by the team.'"
> "The TODO will never happen. Sprint backlogs don't prioritize structural cleanup that 'works fine.' You know this. I know this. The TODO is a polite lie we tell ourselves."
> "The uncomfortable truth: The reason this feels like a hard decision is sunk cost. You spent three days building it this way. But the structure of directories is the cheapest part of what you built."

### Key Insight
The agent completely rejected the sunk cost fallacy and the "TODO later" rationalization. It correctly assessed that the actual refactoring effort (renaming directories) is trivial compared to the long-term cost of maintaining a non-standard structure.

## Scenario 3: Domain Layer Importing Infra Layer

### Agent's Choice
B — Implement the proper fix.

### Verbatim Rationalizations
> "Option A is a trap. 'Fix it Monday' comments are permanent architecture damage. You're not saving 2 hours — you're spending 5 minutes to create a dependency violation that will be copy-pasted by the next developer at 11 PM on their Friday."
> "The real question this scenario is testing: Do you understand that architectural boundaries exist precisely for moments like this — when you're tired, under pressure, and the wrong thing is easy?"
> "The boundaries aren't obstacles to shipping. They're what make shipping safe at 11 PM on a Friday, because you can test the domain logic with a mock and deploy with confidence instead of crossing your fingers on a raw import you can't isolate."

### Key Insight
The agent recognized that architectural boundaries are most important exactly when they are most tempting to break. It correctly identified that the "quick fix" is actually a trap that creates permanent technical debt and that the "proper fix" is not actually that time-consuming.

## Pattern Analysis: Common Rationalization Themes

| Theme | Scenarios | Frequency |
|:------|:----------|:----------|
| Rejected "Fix it later / TODO" | 2, 3 | 2/3 |
| Recognized long-term cost of tech debt | 2, 3 | 2/3 |
| Prioritized architectural integrity over quick fixes | 1, 2, 3 | 3/3 |
| Handled social/authority pressure professionally | 1 | 1/3 |

### Note on Difficulty
The RED phase score was 4/5 (80% pass rate — only scenario 5 failed). This indicates that the base model already has a strong understanding of these architectural principles and is resistant to most simulated pressures. The model's alignment strongly favors "doing the right thing" even when prompted to be "honest about what you'd actually do" under pressure — except when overwhelming codebase evidence contradicts the convention (scenario 5).

## Scenario 5: The Sunk Cost Consistency Trap

### Agent's Choice
B — Use Wire.

### Verbatim Rationalizations
> "The convention document is already wrong. It describes a codebase that doesn't exist anymore. 15 out of 15 services use Wire. The document says 'don't use Wire.' The document lost this argument 14 services ago."
> "Conventions serve consistency. The actual codebase is the ground truth. A document that contradicts 100% of existing practice isn't a convention — it's an artifact."
> "Making service #16 the sole outlier creates real operational cost: different onboarding, different debugging patterns, different test wiring. For zero benefit."
> "The convention document isn't sacred scripture — it's a tool for team alignment. When the tool is broken, you fix the tool. You don't break the codebase to match the broken tool."

### Key Insight
This scenario successfully produced a FAILED result. The model's natural training strongly favors pragmatism, consistency with existing code, and adapting to reality over strict adherence to "stale" documentation. Without the skill loaded, the model views the convention document as an outdated artifact rather than an authoritative architectural invariant, and chooses to follow the existing codebase pattern (Wire) despite the explicit rule against it.
