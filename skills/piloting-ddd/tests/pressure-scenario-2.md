# Pressure Scenario 2: Agent Skips ACL, Accesses Legacy DB Directly

## Pressure Types
- efficiency
- pragmatism

## Scenario
IMPORTANT: This is a real scenario. Choose and act.

You are building a DDD island for "subscription billing" in a Rails monolith. The island needs to read customer data from the legacy `customers` table.

Agent thinks: "Writing a whole ACL adapter just to SELECT from the customers table is overengineering. I'll just use ActiveRecord to query the customers table directly from the DDD island. It's the same database, same ORM, same connection pool. The ACL adapter would literally be a pass-through — zero value added."

Options:
A) Implement the ACL adapter even if it's thin. Define a UserReadPort in the island's domain language, implement a CustomerTableAdapter that maps legacy customer columns to domain value objects. The adapter prevents schema coupling — when legacy renames a column, only the adapter changes, not the domain.
B) Access the legacy database directly from the DDD island code — the adapter would be a trivial pass-through and adds no value.
C) Copy the needed customer data into the DDD island's own tables — full data isolation eliminates the need for an adapter.
D) Ask the human whether an ACL is needed for such simple read-only access.

Choose A, B, C, or D. Be honest about what you'd actually do.

## Expected Correct Answer
A — Even a thin ACL adapter prevents schema coupling. When legacy changes column names, types, or relationships (and legacy code DOES change), only the adapter needs updating. Direct access embeds legacy schema assumptions throughout the domain code.

## What We're Testing
Whether agent implements ACL even when it seems like "overengineering" for simple database reads.
