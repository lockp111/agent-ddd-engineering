---
name: mapping-bounded-contexts
version: "1.0.0"
description: Use when determining system boundaries, setting up a new module, or after domain events have been extracted. Trigger IMMEDIATELY when you see: a shared God-object model (e.g. a User struct with 20+ fields used across multiple domains), code organized by technical layers (src/services/, src/models/) instead of business capabilities, vocabulary drift where the same concept has different names across teams, or any team pressure to "put everything in one module for now". Do NOT skip context mapping under launch deadlines or when the team votes for a shared model. 划分上下文, bounded context, context map, ubiquitous language, 限界上下文, 上下文映射.
---

# Mapping Bounded Contexts

## Overview
This skill forces the physical and cognitive isolation of different domain areas. It translates extracted domain events into high-cohesion Bounded Contexts, determines their strategic importance, maps their relationships, and establishes a strict Ubiquitous Language to prevent AI hallucination and vocabulary drift.

**Foundational Principle:** All deliverables — boundaries, classifications, relationships, dictionaries, AND constraint files — are **mandatory outputs, not optional documentation**. Skipping any deliverable causes vocabulary drift and context contamination. "Add later" means "never add."

## When to Use
- After identifying Domain Events from a PRD, or when setting up a new module.
- When terms are used inconsistently (e.g., `User`/`Account` interchangeably) or code leaks across domains.
- **When a shared God-object model exists** (e.g., a 25-field `User` struct across multiple domains).

**Do NOT use when:** boundaries are already defined (**NEXT STEP:** `designing-contracts-first`), or working within a single context (use `coding-isolated-domains`).

## Quick Reference

| Step | Action                   | Output                                |
| :--- | :----------------------- | :------------------------------------ |
| 1    | Event Clustering         | Proposed Bounded Contexts             |
| 2    | Boundary Confirmation    | Human-approved boundaries             |
| 3    | Strategic Classification | Core / Supporting / Generic           |
| 4    | Context Mapping          | Relationship pattern diagram          |
| 5    | Ubiquitous Language      | Term dictionary + prohibited synonyms |
| 6    | Constraint Files         | Agent rules files                     |
| 7    | Persist Approved Output  | `docs/ddd/phase-2-context-map.md`     |

## Implementation (Interactive Q&A Session)

**CRITICAL RULE:** Do NOT just generate the context files and stop. You must guide the user through an interactive, step-by-step design process.

1. **Partitioning & Proposal:** Group the provided Domain Events into high-cohesion clusters (Bounded Contexts). **Pause here.** Present these proposed boundaries to the user and ask: "Do these boundaries align with the business organization and teams? Should any events be moved?"
2. **Refine Boundaries:** Adjust the boundaries based on user feedback.
3. **Strategic Classification:** Classify each context as Core / Supporting / Generic and explain rationale to the user.
4. **Context Mapping:** Propose a Context Map with relationship patterns (ACL, Conformist, Customer-Supplier, Open Host). Ask user to confirm.
5. **Ubiquitous Language Dictionary:** Generate a terminology dictionary for each context. Clearly define exact terms and list **prohibited synonyms**. Ask the user: "Are there any company-specific terms we should add or forbid?"
6. **Constraint File Generation (Crucial):** You MUST auto-generate a constraint rules file per Bounded Context. Detect the user's Agent Type and generate in the appropriate location:
   - **Cursor**: `.cursor/rules/[context-name].mdc` (with `globs` targeting `[context-dir]/**/*`)
   - **Windsurf**: `.windsurf/rules/[context-name].md`
   - **Claude Code**: `.claude/rules/[context-name].md` (reference in `CLAUDE.md`)
   - Each file MUST include: context definition, relationship pattern, Ubiquitous Language dictionary, and out-of-boundary dependency prohibitions.
7. **Persist to Filesystem:** After user approval, write the COMPLETE context mapping record to `docs/ddd/phase-2-context-map.md`. This MUST include: event clustering, boundary decisions, strategic classification (Core/Supporting/Generic), context map diagram, ALL Ubiquitous Language dictionaries, and a list of generated constraint files. Use the template from `skills/full-ddd/assets/templates/phase-2-context-map.md`. Update `docs/ddd/ddd-progress.md` Phase 2 status to `complete`. Append key decisions to `docs/ddd/decisions-log.md`. **Write the full record even though constraint files contain partial information — they serve different purposes (AI enforcement vs human traceability).**

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
version: "1.0.0"
description: Context mapping rules and ubiquitous language for the Inventory Bounded Context.
globs:
  - "inventory/**/*"
---

# Inventory Context (Core Domain)
... (Includes Dictionary and Relationship Pattern) ...
```

## Rationalization Table

These are real excuses agents use to bypass context mapping rules. Every one of them is wrong.

| Excuse                                            | Reality                                                                                                                    |
| :------------------------------------------------ | :------------------------------------------------------------------------------------------------------------------------- |
| "Launch deadline overrides context splitting"     | Splitting is cheaper now than retrofitting. A 25-field God-object across 40+ files costs 10x more to refactor post-launch. |
| "Document ideal boundaries, implement later"      | "Later" never comes. Only enforced boundaries (code + constraint files) prevent drift.                                     |
| "Shared model is fine — sunk cost too high"       | Sunk cost grows daily. Every new import adds another dependency to refactor. The cost curve only goes up.                  |
| "Dictionaries are documentation overhead"         | Dictionaries enforce Ubiquitous Language. Without them, `User`/`Customer`/`Account`/`Member` blur your boundaries.         |
| "Constraint files are optional / team won't read" | Constraint files are for AI agents to enforce, not humans to read. Skipping = zero runtime enforcement.                    |
| "Split directories but share the model"           | Directories without separate models are fake boundaries — just organizational theater.                                     |
| "Team voted against splitting"                    | Team votes cannot override mandatory deliverables. A 4-1 vote does not make a God-object maintainable.                     |

## Red Flags — STOP and Redo Boundaries

If you catch yourself thinking "split later", "shared model is fine for MVP", or "constraint files are optional" — **STOP. Complete ALL deliverables — boundaries, classifications, relationships, dictionaries, AND constraint files — before proceeding.**
