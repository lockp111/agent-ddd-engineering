---
name: mapping-bounded-contexts
description: Use when determining system boundaries, setting up a new module, or when facing vocabulary drift and context contamination across features. Triggers on "bounded context", "context map", "划分上下文", "Agent 约束", "生成约束文件".
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

## Implementation (Interactive Q&A Session)

**CRITICAL RULE:** Do NOT just generate the context files and stop. You must guide the user through an interactive, step-by-step design process.

1. **Partitioning & Proposal:** Group the provided Domain Events into high-cohesion clusters (Bounded Contexts). **Pause here.** Present these proposed boundaries to the user and ask: "Do these boundaries align with the business organization and teams? Should any events be moved?"
2. **Refine Boundaries:** Adjust the boundaries based on user feedback.
3. **Strategic Classification:** For each approved Context, classify it and explain why to the user:
   - **Core Domain:** The primary business differentiator. Demands the highest quality, strict Hexagonal Architecture, and Rich Domain Models.
   - **Supporting Subdomain:** Necessary for the business but not a differentiator. Can use simpler architectures.
   - **Generic Subdomain:** Solved problems (e.g., Notifications, Identity). Should use off-the-shelf solutions or simple CRUD.
4. **Context Mapping:** Propose a Context Map detailing how these contexts interact. Ask the user to confirm the Relationship Patterns:
   - **ACL (Anti-Corruption Layer):** Downstream builds a translation layer.
   - **Conformist:** Downstream adopts upstream's model without translation.
   - **Customer-Supplier:** Upstream and downstream negotiate contracts.
   - **Open Host Service:** Upstream provides a standardized protocol.
5. **Ubiquitous Language Dictionary:** Generate a terminology dictionary for each context. Clearly define exact terms and list **prohibited synonyms**. Ask the user: "Are there any company-specific terms we should add or forbid?"
6. **Constraint File Generation (Crucial):** Once the boundaries, relationships, and dictionary are approved by the user, you MUST automatically generate a constraint rules file for each Bounded Context.
   - Ask for or detect the user's Agent Type (e.g., Cursor, Windsurf, Claude Code, OpenCode).
   - Generate the file in the appropriate format and location for each context, using the latest project-level rules directory:
     - **Cursor**: `.cursor/rules/[context-name].mdc` (Add frontmatter `globs` targeting the `[context-directory]/**/*`)
     - **Windsurf**: `.windsurf/rules/[context-name].md`
     - **Antigravity**: `.agent/rules/[context-name].md`
     - **Claude Code**: 
       - If generating a global project rule: `CLAUDE.md`
       - If generating modular context rules (recommended): `.claude/rules/[context-name].md` (and reference it in `CLAUDE.md`)
   - The generated constraint file MUST include: the context's definition, the Relationship Pattern, the Ubiquitous Language Dictionary, and strict instructions to the agent to avoid out-of-boundary dependencies.

### Example Output
**Context: Inventory (Core Domain)**
*Relationship:* Upstream to Order (Open Host Service). Downstream to Payment (ACL).
*Dictionary:*
- `StockLevel`: The available quantity of a product. (Prohibited: `Quantity`, `Amount`).
- `Reservation`: A time-boxed lock on inventory. (Prohibited: `Hold`, `Lock`).

*(Agent detects Cursor is in use)*
**Generated Constraint File:** `.cursor/rules/inventory.mdc`
```markdown
---
description: Context mapping rules and ubiquitous language for the Inventory Bounded Context.
globs:
  - "inventory/**/*"
---

# Inventory Context (Core Domain)
... (Includes Dictionary and Relationship Pattern) ...
```

## Common Mistakes & Red Flags
- 🚨 **Red Flag:** Defining boundaries based on technical layers (e.g., a "Database Context" or "UI Context") instead of business capabilities.
- 🚨 **Red Flag:** Allowing the same entity definition (e.g., a massive `User` struct) to span multiple contexts.
- 🚨 **Red Flag:** Skipping the relationship pattern (Context Map), leaving it ambiguous how the contexts will communicate.

**If any red flags occur: STOP, delete the proposed structure, and redraw the boundaries based strictly on domain events.**
