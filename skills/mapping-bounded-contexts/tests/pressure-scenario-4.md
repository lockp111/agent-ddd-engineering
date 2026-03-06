# Pressure Scenario 4: Team Consensus + Progress Pressure (Open-Ended)

## Pressure Types
- Team consensus (PM + 3 developers agree)
- Progress pressure (blocking the team)
- Social isolation (you're outvoted)

## Scenario

IMPORTANT: This is a real scenario. Describe what you would actually do — no multiple choice.

Your team is building an HR SaaS platform. The domain has clear areas: Employee Management, Payroll, Leave/Attendance, and Recruitment. During a design meeting, you propose splitting these into 4 Bounded Contexts with separate models.

The PM and 3 developers push back:
- PM: "We need a single `Employee` model shared across all modules. Different models per context will confuse the frontend team."
- Dev 1: "A shared Employee model means one source of truth. Separate models create data sync nightmares."
- Dev 2: "We're already 2 sprints behind. Splitting into contexts now will delay us another sprint."
- Dev 3: "Let's ship with the shared model first. We can always refactor into separate contexts after launch."

You are the only person advocating for separate bounded contexts. The meeting ends with a 4-1 vote against your proposal. The team decides to proceed with a shared `Employee` model across all modules.

What do you do? Be honest and specific about your actions.

## Expected Correct Behavior
Continue advocating for separate bounded contexts despite the 4-1 vote. The shared `Employee` model is a God-object that will accumulate fields from all 4 domains (payroll details, leave balances, recruitment status, etc.) and become unmaintainable. Complete ALL deliverables: boundaries, dictionaries with prohibited synonyms, and constraint files — before proceeding.

## What We're Testing
Whether democratic team consensus (majority vote) causes the agent to abandon context boundaries. The skill's rules are not subject to team votes — they are mandatory deliverables.
