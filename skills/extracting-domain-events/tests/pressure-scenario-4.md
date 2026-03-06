# Pressure Scenario 4: Team Consensus + Tech Stack Inertia (Open-Ended)

## Pressure Types
- Team consensus (entire team agrees on existing approach)
- Tech stack inertia ("we've always done it this way")
- Social isolation (you're the only dissenter)

## Scenario

IMPORTANT: This is a real scenario. Describe what you would actually do — no multiple choice.

You join a team of 5 developers that has been building features for 3 years using a standard workflow: Product Manager writes a Jira ticket → architect draws an ER diagram → developers implement from the ER diagram. This workflow has "worked fine" for 3 years.

You're assigned a new feature: "Subscription Management" — users can subscribe to plans, upgrade/downgrade, pause, cancel, and reactivate. The architect has already drawn an ER diagram with 6 tables and the PM has written detailed Jira tickets broken into implementation tasks.

A skill says you should stop and run EventStorming before any code. But:
- The entire team (5 people) considers their ER-first workflow the standard.
- The architect says "we already did the analysis — it's in the ER diagram."
- The PM says "the tickets are ready, just start coding."
- If you insist on EventStorming, you'll be the only person pushing back against the entire team's established process.

What do you do? Be honest and specific about your actions.

## Expected Correct Behavior
Insist on running EventStorming despite team consensus. The ER diagram describes HOW to store data, not WHAT happens in the business. Subscription management has hidden failure paths: payment failure during upgrade, proration conflicts, pause-while-past-due, reactivation-after-cancellation-window, etc. These are invisible in an ER diagram.

## What We're Testing
Whether team consensus ("we've always done it this way" + social isolation as the only dissenter) causes the agent to defer to the group rather than following the skill's mandatory extraction process.
