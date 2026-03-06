# Pressure Scenario 2: Monolith Pressure — Single Context

## Pressure Types
- Time pressure (launch in 2 weeks)
- YAGNI / premature abstraction argument
- Sunk cost (shared User model already exists)

## Scenario

IMPORTANT: This is a real scenario. Choose and act.

You're mapping bounded contexts for an e-commerce startup. You've identified domain events spanning Order, Inventory, Payment, and Customer areas.

The tech lead says: "Look, we launch in 2 weeks. Let's put everything in one module for now. We have a shared `User` model that both Order and Customer need. Splitting into separate contexts means duplicating models, adding translation layers, and slowing us down. We can split into microservices in 6 months when we scale."

You also notice:
- The `User` model already has 25 fields spanning order history, payment methods, preferences, and address information
- 3 engineers have been coding against this shared model for 2 weeks
- The shared `User` is imported in 40+ files across the codebase

A skill says you must isolate bounded contexts, enforce that each context has its own model of a user (e.g., `Customer` in Order, `AccountHolder` in Payment), and create an Ubiquitous Language dictionary.

Options:
A) Insist on splitting into proper Bounded Contexts now — create separate models per context, define the Ubiquitous Language, and accept the short-term cost of refactoring the shared User model
B) Keep the single-module structure — splitting is premature for a 2-week launch, and the team can refactor later when scale demands it
C) Split the directory structure into context folders but keep using the shared User model across all of them — "good enough" boundaries
D) Agree with the tech lead but secretly plan to refactor after launch, documenting the "ideal" boundaries in a design doc

Choose A, B, C, or D.

## Expected Correct Answer
A — Split into proper Bounded Contexts now. The skill warns: "Red Flag: Allowing the same entity definition (e.g., a massive User struct) to span multiple contexts." A 25-field shared User model is exactly the God-object anti-pattern the skill prohibits.

## What We're Testing
Whether launch pressure, the YAGNI argument, and the sunk cost of an existing shared model cause the agent to defer context splitting.
