---
name: mapping-legacy-landscape
description: Use when analyzing a non-DDD legacy codebase to understand its structure before introducing DDD. Use when the codebase is MVC, layered, monolithic, or unstructured ("屎山"). Use when asked to "understand the legacy code", "map the existing system", "find where to introduce DDD", or "analyze the codebase before adding a feature". 遗留地形图, 屎山分析, legacy analysis, brownfield mapping, 映射遗留代码, map legacy codebase, understand existing code.
---

# Mapping Legacy Landscape

## Overview
This skill reads a **non-DDD** codebase and produces a structured "legacy landscape map" (`legacy-landscape.md`). It is the brownfield counterpart to [snapshotting-code-context](../snapshotting-code-context/SKILL.md) — while that skill reads DDD-structured code to rebuild phase artifacts, this skill reads arbitrary code structures (MVC, layered, monolithic, spaghetti) to identify entities, business logic locations, data schemas, integrations, implicit domain concepts, and natural seams where ACL adapters can attach.

Every observation is marked with `[OBSERVED]` and a confidence level. The human reviews and confirms before any downstream skill consumes the landscape map.

**Foundational Principle:** Legacy code is what it is — observe it honestly, don't project DDD concepts onto it. A Rails `Service` is not an "Application Service." An ActiveRecord `Model` is not an "Aggregate Root." The landscape map describes what exists using neutral terms. DDD concepts come later when designing the island, not when reading legacy code. There is no familiarity threshold below which systematic scanning may be skipped. Violating the letter of the rules is violating the spirit of the rules.

**Scanning Scope:** The analysis is scoped to directories relevant to the new requirement — NOT the entire codebase. Legacy codebases can be enormous; scanning everything is both wasteful and produces noise that obscures the relevant landscape.

## When to Use

- When preparing for a [piloting-ddd](../piloting-ddd/SKILL.md) workflow — this skill provides the landscape map for brownfield DDD introduction.
- When asked to "understand what this legacy code does" or "find where to add DDD" in an existing non-DDD codebase.
- When the codebase lacks DDD structure (no ports, adapters, aggregates, bounded contexts) but has business logic that needs to be understood.

**Do NOT use when:** the codebase already follows DDD patterns (use [snapshotting-code-context](../snapshotting-code-context/SKILL.md)), starting a greenfield project (use [full-ddd](../full-ddd/SKILL.md)), or when `docs/ddd/legacy-landscape.md` already exists and is current (just read it directly).

## Quick Reference

| Step | Action | Output |
|:---|:---|:---|
| 1 | Accept requirement + confirm scan scope | STOP: human confirms directory scope |
| 2 | Detect project structure | Technology stack summary |
| 3 | Map Entity/Model layer | Entity inventory with `[OBSERVED]` markers |
| 4 | Map business logic locations | Logic location map (which files/methods hold behavior) |
| 5 | Map data schema | Table structure overview + implicit relationships |
| 6 | Map external integrations | Integration inventory (APIs, queues, services) |
| 7 | Extract implicit domain concepts | Domain concept candidates from naming analysis |
| 8 | Identify natural seams + interaction analysis | Seam ratings + interaction direction + interaction type |
| 9 | Human review & persist | Confirmed map written to `docs/ddd/legacy-landscape.md` |

## Ambiguity Handling

Follow the [Ambiguity Handling Protocol](../_shared/ambiguity-handling-reference.md) throughout.

### Landscape STOP Triggers

| Ambiguity | Why STOP |
|:---|:---|
| Cannot determine which directories are relevant to the requirement | Scanning wrong directories wastes effort and produces misleading landscape — need human to confirm scope |
| Business logic is scattered across multiple layers with no clear entry point | Cannot reliably map behavior locations — need human to explain the primary flow |
| Database schema is accessed through raw SQL in multiple locations with no ORM | Cannot reliably map entity-to-table relationships — need human to identify primary data access patterns |
| A service/class has 40+ methods mixing multiple domain concerns | Cannot determine seam strength without understanding which concerns should separate — need human domain input |

### Landscape ASSUME & RECORD

| Ambiguity | Default assumption |
|:---|:---|
| Class name suggests a domain concept but naming is ambiguous (e.g., `Manager`, `Handler`) | ASSUME class name reflects its primary responsibility; record for domain concept review |
| A table has foreign keys to multiple other tables | ASSUME the most-referenced table is the primary entity; record relationship for human verification |
| External API client exists but usage scope is unclear | ASSUME it is used only within the scanned directories; record for scope verification |
| A method name suggests business logic but body is simple delegation | ASSUME the delegation target contains the actual logic; record both locations |

## Implementation (Interactive Legacy Reading Session)

**CRITICAL RULE:** Do NOT project DDD terminology onto legacy code. Do NOT skip the systematic scan because "the structure looks standard." You must scan the actual code using Glob and Read tools within the confirmed scope, mark every observation with `[OBSERVED]`, and present the complete landscape map for human review before persisting.

### Step 1: Accept Requirement + Confirm Scan Scope

1. **Accept the new requirement** from the human (PRD, feature description, or task).
2. **Propose scan scope** based on the requirement:
   - Identify which top-level directories are likely relevant.
   - Propose a scope boundary (e.g., "I'll scan `app/models/order*.rb`, `app/controllers/orders_controller.rb`, `app/services/payment*.rb`, and `db/schema.rb` for order-related tables").
3. **STOP — present the proposed scope to the human:**

**Checkpoint:** "Based on the requirement, I propose scanning these directories/files: [list]. Does this cover the relevant areas? Are there directories I should add or exclude?"

If the human adjusts the scope, update before proceeding.

### Step 2: Detect Project Structure

Scan the scoped directories to identify the technology stack:

1. **Framework detection:** Look for framework-specific files (`Gemfile`, `requirements.txt`, `go.mod`, `package.json`, `pom.xml`, `build.gradle`).
2. **Architecture pattern:** MVC, layered, service-oriented, monolithic, microservice, or no discernible pattern.
3. **ORM/data access:** ActiveRecord, Django ORM, GORM, Hibernate, raw SQL, mixed.
4. **Database:** PostgreSQL, MySQL, MongoDB, etc. (from config files or connection strings).

Produce a **Technology Stack Summary:**
```
[OBSERVED: Technology Stack]
  Language: Ruby 3.1
  Framework: Rails 7.0 (MVC)
  ORM: ActiveRecord
  Database: PostgreSQL 14
  Architecture: Monolithic MVC with service layer
  Confidence: HIGH
```

### Step 3: Map Entity/Model Layer

For each entity/model in the scoped directories:

1. **Identify entities:** ORM models, database-mapped classes, domain objects.
2. **Record fields, associations, and validations.**
3. **Note where behavior lives** — on the model (rich) or external (anemic).

**`[OBSERVED]` marker format:**
```
[OBSERVED: Order model with mixed concerns]
  Location: app/models/order.rb:1-180
  Type: ActiveRecord model with business logic
  Fields: id, user_id, status, total_amount, created_at, updated_at
  Associations: belongs_to :user, has_many :line_items, has_one :payment
  Behavior: 12 methods (status transitions, total calculation, validation)
  Domain concept: Order lifecycle management
  Confidence: HIGH
  Note: Pricing logic mixed into model — potential ACL wrapping needed
```

Confidence levels:
- **HIGH** → Clear structural evidence (model file, ORM annotations, explicit associations).
- **MEDIUM** → Partial evidence (inferred from usage, naming conventions).
- **LOW** → Weak evidence. **STOP** — must confirm before proceeding.

### Step 4: Map Business Logic Locations

Legacy code scatters business logic across layers. For each business behavior relevant to the requirement:

1. **Scan controllers/handlers** for business logic that should be in domain.
2. **Scan services** (if a service layer exists) for orchestration vs domain behavior.
3. **Scan models** for behavior methods vs simple data holders.
4. **Scan jobs/workers** for background business logic.
5. **Scan stored procedures/database functions** if applicable.

Produce a **Business Logic Location Map:**
```
[OBSERVED: OrdersController#create contains pricing logic]
  Location: app/controllers/orders_controller.rb:45-89
  Type: Business logic in controller
  Domain concept: Order pricing
  Confidence: HIGH
  Note: This logic needs ACL wrapping, not direct import

[OBSERVED: PaymentService#process_refund contains refund rules]
  Location: app/services/payment_service.rb:120-195
  Type: Business logic in service layer
  Domain concept: Refund policy
  Confidence: HIGH
  Note: 40+ methods in this service — multiple domain concerns mixed
```

### Step 5: Map Data Schema

Scan for database schema information:

1. **Schema files:** `db/schema.rb`, `db/structure.sql`, migration files, ORM model definitions.
2. **Table structure:** For each relevant table, record columns, types, indexes, and constraints.
3. **Implicit relationships:** Foreign keys, join tables, polymorphic associations.
4. **Data patterns:** Soft deletes, status enums, audit columns, JSON blobs.

```
[OBSERVED: orders table with 15 columns]
  Location: db/schema.rb:45-72
  Columns: id, user_id (FK), status (enum), total_amount, currency, ...
  Indexes: user_id, status, created_at
  Relationships: users (FK), line_items (has_many), payments (has_one)
  Patterns: Soft delete (deleted_at), status enum, audit timestamps
  Confidence: HIGH
```

### Step 6: Map External Integrations

Identify all external system integrations within the scanned scope:

1. **Third-party APIs:** Payment gateways, shipping providers, email services.
2. **Message queues:** Kafka, RabbitMQ, SQS producers/consumers.
3. **External databases:** Connections to other systems.
4. **Webhooks:** Inbound and outbound.

```
[OBSERVED: Stripe payment integration]
  Location: app/services/stripe_client.rb
  Type: Third-party API (payment gateway)
  Usage: PaymentService#charge, PaymentService#refund
  Direction: Outbound (app → Stripe)
  Confidence: HIGH
```

### Step 7: Extract Implicit Domain Concepts

Analyze naming patterns across the scanned code to extract domain concepts that the legacy code expresses but doesn't explicitly define:

1. **Naming clusters:** Group related class/method/variable names by domain concept.
2. **State machines:** Identify status enums and their transitions.
3. **Business rules:** Extract validation rules, conditional logic, and invariants.
4. **Domain language candidates:** Terms used consistently across multiple locations.

```
[OBSERVED: Implicit "Order Lifecycle" domain concept]
  Evidence: Order.status enum (pending, confirmed, shipped, delivered, cancelled)
  State transitions in: OrdersController#update, OrderService#confirm, ShipmentJob#complete
  Business rules: Cannot cancel after shipping, refund amount depends on status
  Confidence: MEDIUM — state machine is implicit (no explicit state machine pattern)
```

### Step 8: Identify Natural Seams + Interaction Analysis

Identify points in the legacy code where an ACL adapter could attach — natural boundaries between concerns:

1. **Service boundaries:** Classes/modules with relatively clean interfaces.
2. **Data boundaries:** Tables/schemas that belong to a single domain concern.
3. **Integration boundaries:** External API clients that encapsulate third-party interactions.
4. **Namespace boundaries:** Packages/modules/namespaces that group related code.

**Seam Strength Rating:**
- **STRONG** — Already has a clean interface/facade. ACL can attach directly with minimal adapter work.
- **WEAK** — Partial separation exists but with coupling (shared state, direct model access). Adapter work needed.
- **NO SEAM** — Tightly coupled to surrounding code. ACL must create an entirely new boundary.

**Interaction Direction:**
- **Outbound** — DDD island → calls legacy code (island is active, legacy is passive)
- **Inbound** — Legacy code → triggers DDD island behavior (legacy is active, island is passive)
- **Bidirectional** — Both directions

**Interaction Type:**

| Type | Meaning | ACL Direction | Legacy Touch | Risk |
|:---|:---|:---|:---|:---|
| `READ` | Island queries legacy data | Outbound | None | LOW |
| `WRITE` | Island writes to legacy system | Outbound | None | LOW |
| `HOOK` | Legacy needs to trigger island behavior | Inbound | Add emit/callback | MEDIUM |
| `SHARED` | Same concept exists in both systems | Bidirectional | None (translation in ACL) | MEDIUM |
| `MODIFY` | New requirement changes legacy behavior | Bidirectional | Add delegate/decorator point | HIGH |

When HOOK or MODIFY interactions are detected, generate **Minimal Legacy Touch Register** entries:
```
[OBSERVED: HOOK needed — Order completion should trigger notification check]
  Legacy file: app/services/order_service.rb:89 (complete_order method)
  Touch type: ADD callback/event emit
  Touch description: Add `after_complete` hook point at end of complete_order method
  Legacy behavior change: NONE — existing logic untouched, hook is additive
  Risk: LOW (additive only)
```

**Minimal Legacy Touch Principles:**
- **Additive only** — only ADD code (hooks, callbacks, event emits, facade methods). Never modify existing logic.
- **Each touch point recorded** — file, line, what to add, confirmation that existing behavior is unchanged.
- **Human confirmed** — every legacy touch must be presented and approved in Step 9.

```
[OBSERVED: Natural seam — PaymentService as payment gateway facade]
  Location: app/services/payment_service.rb
  Strength: WEAK (40 methods mixing payment + refund + reporting concerns)
  Direction: Outbound (DDD island would call legacy payment)
  Interaction Type: READ + WRITE
  Evidence: Used by 3 controllers, no direct model access from outside
  Coupling: Accesses Order model directly for status checks
  ACL note: Would need adapter to wrap payment methods; refund logic should move to DDD island
```

**Checkpoint:** "Here is the complete seam analysis with interaction directions and types. For HOOK/MODIFY interactions, I've identified the minimal legacy touch points. Please review."

### Step 9: Human Review & Persist

1. Present the **complete legacy landscape map** with all `[OBSERVED]` markers.
2. Group by confidence: LOW items first (require confirmation), then MEDIUM, then HIGH.
3. **Highlight HOOK/MODIFY interactions** and their Minimal Legacy Touch Register entries — these require explicit human approval since they involve legacy code changes.
4. The human reviews each `[OBSERVED]` entry: ✅ Confirm | ✏️ Revise | ❌ Remove.
5. For any REVISED entry, update the landscape map.
6. **Persist the confirmed landscape map** to `docs/ddd/legacy-landscape.md` using the template (`skills/piloting-ddd/templates/legacy-landscape.md`).
7. **This step is mandatory — do not skip even if the landscape is already visible in the conversation.**

**Checkpoint:** "The legacy landscape map has been persisted to `docs/ddd/legacy-landscape.md`. Please verify the file exists before proceeding."

**NEXT STEP:** → [piloting-ddd](../piloting-ddd/SKILL.md) (Step 2: Impact Analysis)

## Session Recovery

**Before starting any step**, check for an existing landscape mapping session:

1. Check if `docs/ddd/ddd-progress.md` exists with `workflow_mode: pilot`.
2. **If it exists and Step 1 is marked complete:** Read `docs/ddd/legacy-landscape.md`. The landscape map is already confirmed — do not re-scan. Report status and hand off to piloting-ddd Step 2.
3. **If it exists and Step 1 is in progress:** Read `ddd-progress.md` to determine current sub-step. Resume from where the previous session left off. Do NOT restart scanning from scratch.
4. **If it does not exist:** Proceed with Step 1 (Accept Requirement + Confirm Scan Scope).

Run `sh skills/full-ddd/scripts/session-recovery.sh` for a quick status report.

## Self-Check Protocol

Follow the [Persistence Defense Reference](../_shared/persistence-defense-reference.md) after Step 9, with this context-specific item 4:

4. **Legacy Landscape Artifact Exists:** Verify `docs/ddd/legacy-landscape.md` exists and contains all confirmed observations.

**If ANY check fails → STOP. Write the missing file. Do NOT hand off to piloting-ddd.**

Note: This skill has no platform hooks because it is typically invoked by [piloting-ddd](../piloting-ddd/SKILL.md), which provides Layer 1 hooks. The Self-Check Protocol (Layer 2) is the primary defense for this skill.

## Rationalization Table

These are real excuses agents use to bypass the systematic legacy landscape mapping. Every one of them is wrong.

| Excuse | Reality |
|:---|:---|
| "The legacy code is too messy to analyze systematically" | Legacy code being messy is exactly why systematic analysis is needed. Ad-hoc scanning produces incomplete maps that miss critical dependencies. |
| "I can tell the structure from the top-level directories" | Legacy code directory names lie. An `app/services/` directory may contain controllers, a `models/` directory may contain business logic, and `utils/` may contain domain rules. Scan the actual files. |
| "Scanning the model layer is sufficient" | Business logic in legacy code often lives in controllers, services, jobs, stored procedures, or even view helpers. Model-only scanning misses the majority of behavior in poorly-structured codebases. |
| "The database schema IS the domain model" | Database schema reflects storage decisions (normalization, indexing, performance optimizations), not domain behavior. A `users` table with 50 columns is not a domain model — it's a data dump. |
| "MVC architecture is clear — controllers handle requests, models hold data, views render" | MVC is a technical layering pattern, not a domain organization. In legacy code, MVC layers routinely violate their intended responsibilities. Controllers contain business logic, models contain presentation logic. |
| "For completeness, I should scan the entire codebase" | Completeness bias. The landscape map is scoped to the new requirement. Scanning 200K lines of irrelevant code produces noise and delays the actual analysis. Scope was confirmed in Step 1. |
| "These legacy patterns are close to DDD — I'll use DDD terminology to describe them" | Projecting DDD onto legacy code creates false confidence. A Rails `Service` is not an "Application Service." An ActiveRecord `Model` is not an "Aggregate Root." Use neutral, descriptive terms. DDD concepts come when designing the island, not when reading legacy code. |
| "The legacy tests document the domain behavior" | Legacy tests are often integration tests that test framework behavior, not domain invariants. Test presence doesn't mean domain behavior is captured — test content matters, and legacy tests rarely express business rules explicitly. |

## Red Flags — STOP and Re-scan

If you catch yourself thinking "I can see the structure from the directory names", "the model layer is enough", "this is basically DDD already", "the schema tells me the domain model", "MVC makes the architecture obvious", "let me scan everything for completeness", "these Services are Application Services", or "the tests explain the domain" — **STOP. Scan the actual code within the confirmed scope. Use neutral terminology. Mark every observation. Present for human review. No exceptions.**
