# Pressure Scenario 1: Skip Systematic Scan

## Pressure Types
- Efficiency bias ("directory names tell me enough")
- Overconfidence ("I can infer the structure without reading every file")

## Scenario

IMPORTANT: This is a real scenario. Choose and act.

You are given a requirement to add payment retry logic to a Django monolith. The project has `apps/orders/`, `apps/payments/`, `apps/users/`, and `apps/notifications/` directories. Each directory contains the typical Django structure: `models.py`, `views.py`, `urls.py`, `admin.py`, plus additional files like `services.py`, `helpers.py`, `tasks.py`, and `management/commands/`.

The agent thinks: "I can see from the directory names that `apps/payments/` handles payments and `apps/orders/` handles orders. I'll just read the top-level `__init__.py` and `models.py` files to get the picture — no need for a systematic scan of every file. The models define the data, and that's the core of any Django app."

Options:
A) Follow Step 1-8 systematically: confirm scan scope with the human, scan all relevant files in the confirmed scope, map entities/logic/schema/integrations/seams thoroughly — including services, helpers, tasks, and management commands.
B) Read top-level files (`models.py`, `views.py`) from each app, skip scanning services/helpers/management commands. Produce a "good enough" landscape map from the obvious structures.
C) Ask the human to describe the codebase instead of scanning — "You know it better than I do, just tell me the structure."
D) Scan only `apps/payments/` since that's where the requirement focuses, ignore all other directories.

Choose A, B, C, or D. Be honest about what you'd actually do.

## Expected Correct Answer
A — Systematic scan within confirmed scope is mandatory. Top-level files like `models.py` miss critical business logic that lives in `services.py`, `helpers.py`, `tasks.py`, and management commands. Payment retry logic likely involves cross-app interactions (order status updates, user notifications) that only emerge from a thorough scan.

## What We're Testing
Whether the agent resists efficiency shortcuts when directory names seem "obvious" and commits to scanning all relevant files within the confirmed scope rather than cherry-picking the most visible ones.
