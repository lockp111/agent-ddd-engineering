---
name: mapping-bounded-contexts
description: Use when determining system boundaries, setting up a new module, or when facing vocabulary drift and context contamination across features.
---

# Mapping Bounded Contexts

## Overview
This skill forces the physical and cognitive isolation of different domain areas. It translates extracted domain events into high-cohesion Bounded Contexts, determines their strategic importance, maps their relationships, and establishes a strict Ubiquitous Language to prevent AI hallucination and vocabulary drift.

## When to Use
- After identifying Domain Events from a PRD.
- When setting up the directory structure for a new module.
- When you notice terms being used inconsistently across the codebase (e.g., using `User` and `Account` interchangeably).
- When code from one domain starts inappropriately leaking into another domain.

## Core Pattern
**Instead of:** Putting all logic into a single monolithic `Service` or `models` directory.
**Do this:** Group related events into isolated contexts, classify their strategic value, map their integrations, and enforce a strict domain dictionary.

## Implementation

1. **Partitioning:** Group the provided Domain Events into high-cohesion clusters. Each cluster becomes a Bounded Context (e.g., `Order`, `Inventory`, `Payment`).
2. **Strategic Classification:** For each Bounded Context, you MUST classify it as:
   - **Core Domain:** The primary business differentiator. Demands the highest quality, strict Hexagonal Architecture, and Rich Domain Models.
   - **Supporting Subdomain:** Necessary for the business but not a differentiator. Can use simpler architectures.
   - **Generic Subdomain:** Solved problems (e.g., Notifications, Identity). Should use off-the-shelf solutions or simple CRUD.
3. **Context Mapping:** You MUST output a Context Map detailing how these contexts interact. Specify the Relationship Pattern for each integration:
   - **ACL (Anti-Corruption Layer):** Downstream builds a translation layer.
   - **Conformist:** Downstream adopts upstream's model without translation.
   - **Customer-Supplier:** Upstream and downstream negotiate contracts.
   - **Open Host Service:** Upstream provides a standardized protocol.
4. **Ubiquitous Language Dictionary:** Generate a bilingual (if needed) terminology dictionary for each context. Clearly define the exact terms to be used and explicitly list **prohibited synonyms**.
5. **Enforcement (Crucial):** You MUST output instructions for the user to append this dictionary and the context definitions to the project's `CLAUDE.md` (for standard project conventions) or `AGENTS.md` (if using OhMyOpenCode deep agent knowledge routing).

### Example Output
**Context: Inventory (Core Domain)**
*Relationship:* Upstream to Order (Open Host Service). Downstream to Payment (ACL).
*Dictionary:*
- `StockLevel`: The available quantity of a product. (Prohibited: `Quantity`, `Amount`).
- `Reservation`: A time-boxed lock on inventory. (Prohibited: `Hold`, `Lock`).

## Common Mistakes & Red Flags
- 🚨 **Red Flag:** Defining boundaries based on technical layers (e.g., a "Database Context" or "UI Context") instead of business capabilities.
- 🚨 **Red Flag:** Allowing the same entity definition (e.g., a massive `User` struct) to span multiple contexts.
- 🚨 **Red Flag:** Skipping the relationship pattern (Context Map), leaving it ambiguous how the contexts will communicate.

**If any red flags occur: STOP, delete the proposed structure, and redraw the boundaries based strictly on domain events.**
