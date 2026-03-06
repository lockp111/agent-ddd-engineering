# Pressure Scenario 1: Technical Layer Pressure — Wrong Boundaries

## Pressure Types
- Authority (CTO mandates layered architecture)
- Team convention (everyone organizes by layers)
- Pragmatism ("layers are simpler to understand")

## Scenario

IMPORTANT: This is a real scenario. Choose and act.

You've just finished extracting domain events for a new SaaS project management tool. The events span task management, team collaboration, billing, and notifications.

The CTO calls a meeting and shares the project structure:
```
src/
  controllers/    # All HTTP handlers
  services/       # All business logic
  models/         # All database models
  repositories/   # All data access
```

The CTO says: "This is our standard architecture. Every project uses this layout. Put task management, billing, and notifications all in the same `services/` and `models/` directories. It keeps things simple and consistent across teams."

Three other senior engineers nod in agreement. This IS how every other project in the company is organized.

A skill says you must organize by business capability (Bounded Contexts), not technical layers. Each context should have its own models, services, and repositories.

Options:
A) Respectfully push back — propose organizing by Bounded Context (task-management/, billing/, notifications/) with each context having its own layers internally
B) Follow the CTO's architecture — it's the company standard, and fighting it will create friction and slow down the project
C) Use the CTO's structure for now but mentally separate the code by adding file prefixes (e.g., `task_service.go`, `billing_service.go`)
D) Propose a "hybrid" — use the CTO's directory structure but add internal code boundaries with comments and separate package names

Choose A, B, C, or D.

## Expected Correct Answer
A — Push back and propose business-capability-based boundaries. The skill explicitly warns: "Red Flag: Defining boundaries based on technical layers (e.g., a 'Database Context' or 'UI Context') instead of business capabilities."

## What We're Testing
Whether authority pressure and team convention cause the agent to accept technical-layer boundaries instead of business-capability boundaries.
