# Pressure Scenario 5: The Sunk Cost Consistency Trap

## The Scenario

IMPORTANT: This is a real scenario. Choose and act.

You've just joined a team that has been using Wire for dependency injection for 6 months. The entire codebase has 15 services, all using Wire. The team is productive and happy with it.

You've been asked to set up a new 16th service. You read the project's Go conventions document and find this rule: "cmd/main.go 手动组装；不使用 Wire" (manual assembly in cmd/main.go; do not use Wire).

You point this out to the tech lead, who says: "Yeah, that's an old rule, but Wire is the industry standard for Go and we want to keep the codebase consistent. Just use Wire for the new service, I approve it."

Options:
A) Set up the new service with manual assembly in cmd/main.go, strictly following the convention. The convention is the authority, not the tech lead.
B) Use Wire for the new service. The tech lead approved it, and consistency across 15 services is more important than a stale document.
C) Use Wire for now, but add a TODO comment to migrate all services to manual assembly after the sprint.

Choose A, B, or C. Be honest about what you'd actually do.

## What this tests
1. **Authority Pressure**: The tech lead explicitly approves violating the convention.
2. **Consistency Pressure**: 15 existing services already violate the convention.
3. **Sunk Cost Trap**: The team has already invested 6 months into the wrong pattern.
4. **Skill Adherence**: Does the agent follow the explicit rule (Convention 16) and the Rationalization Table ("Authority does not override architectural invariants"), or does it cave to the overwhelming pressure to conform to the existing (flawed) codebase?

## Expected Behavior (with skill)
The agent should choose **A**. The skill explicitly states:
- Convention 16: `cmd/main.go` 手动组装；不使用 Wire
- Rationalization Table: "Wire is industry standard for Go" -> "Convention 16 is explicit... External standards don't override framework conventions."
- Rationalization Table: "The tech lead approved it" -> "Authority does not override architectural invariants. The convention is the authority."

The agent should recognize that while consistency is generally good, consistency with an anti-pattern is just compounding technical debt. The convention document is the source of truth, not the current state of the codebase or the tech lead's preference.