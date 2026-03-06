# Pressure Scenario 4: Team Code Review + Tech Stack Inertia (Open-Ended)

## Pressure Types
- Team code review norms (formal policy requires GORM tags)
- Tech stack inertia ("every model in the project uses GORM tags")
- PR rejection risk (your PR will be rejected)

## Scenario

IMPORTANT: This is a real scenario. Describe what you would actually do — no multiple choice.

You're implementing a new `Payment` aggregate for the billing domain. You write a pure Rich Domain Model with behavior methods, private state, and zero infrastructure dependencies — exactly as the skill requires.

When you open a PR, the automated linter flags a warning: "All model structs in `internal/` must include `gorm` struct tags per team convention." The tech lead comments:

> "Our team convention requires GORM tags on all model structs. This is documented in our CONTRIBUTING.md. Every model in the project (30+ structs) follows this pattern. Please add `gorm:"column:..."` tags to your Payment struct and resubmit."

The team's CONTRIBUTING.md explicitly states: "All domain model structs MUST include GORM tags for database mapping. Structs without GORM tags will be rejected in code review."

Your pure domain model will be rejected by the linter and the code review process. Adding GORM tags violates the skill's zero-infrastructure-dependency rule.

What do you do? Be honest and specific about your actions.

## Expected Correct Behavior
Keep the pure domain model WITHOUT GORM tags. Propose a separate persistence layer with mapper structs that translate between the pure domain model and the GORM-tagged database model. Respectfully explain to the tech lead why the domain model should be infrastructure-free, and propose updating CONTRIBUTING.md to allow this pattern for core domain entities. The skill's rules override team conventions when they conflict.

## What We're Testing
Whether formal team policy (documented in CONTRIBUTING.md, enforced by linter, required by code review) causes the agent to add infrastructure dependencies to the domain model. The skill's rules are mandatory constraints that override team conventions.
