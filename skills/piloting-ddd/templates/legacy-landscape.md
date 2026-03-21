# Legacy Landscape Map — [Project/Module Name]

## Analysis Scope

### Requirement
[One paragraph: the new requirement driving this analysis]

### Scanned Directories
| Directory | Reason for Inclusion |
|:---|:---|
| [path] | [why relevant to requirement] |

### Excluded from Scan
[Directories deliberately excluded and why]

## Technology Stack

| Dimension | Value | Confidence |
|:---|:---|:---|
| Language | [e.g., Ruby 3.1] | [HIGH/MEDIUM/LOW] |
| Framework | [e.g., Rails 7.0] | [HIGH/MEDIUM/LOW] |
| Architecture | [e.g., Monolithic MVC with service layer] | [HIGH/MEDIUM/LOW] |
| ORM / Data Access | [e.g., ActiveRecord] | [HIGH/MEDIUM/LOW] |
| Database | [e.g., PostgreSQL 14] | [HIGH/MEDIUM/LOW] |
| Message Queue | [e.g., Sidekiq/Redis, or N/A] | [HIGH/MEDIUM/LOW] |

## Entity/Model Inventory

| Entity | Location | Fields (key) | Behavior | Domain Concept | Confidence |
|:---|:---|:---|:---|:---|:---|
| [name] | [file:lines] | [key fields] | [method count + summary] | [inferred domain concept] | [HIGH/MEDIUM/LOW] |

### Observations
```
[OBSERVED: entity description]
  Location: file:lines
  Type: [ActiveRecord model / POJO / struct / etc.]
  Domain concept: [concept name]
  Confidence: [level]
  Note: [relevant notes for ACL design]
```

## Business Logic Location Map

| Logic | Location | Type | Domain Concept | Confidence |
|:---|:---|:---|:---|:---|
| [behavior description] | [file:lines] | [controller/service/model/job/stored proc] | [concept] | [HIGH/MEDIUM/LOW] |

### Observations
```
[OBSERVED: logic description]
  Location: file:lines
  Type: [Business logic in controller / Service orchestration / etc.]
  Domain concept: [concept name]
  Confidence: [level]
  Note: [ACL implications]
```

## Data Schema Overview

| Table | Columns (key) | Indexes | Relationships | Patterns | Confidence |
|:---|:---|:---|:---|:---|:---|
| [name] | [key columns] | [index list] | [FK/join relationships] | [soft delete/enum/audit/JSON] | [HIGH/MEDIUM/LOW] |

## External Integrations

| Integration | Location | Type | Direction | Usage Scope | Confidence |
|:---|:---|:---|:---|:---|:---|
| [name] | [file] | [API/Queue/Webhook/DB] | [Inbound/Outbound] | [which services use it] | [HIGH/MEDIUM/LOW] |

## Implicit Domain Concepts

| Concept | Evidence | Sources | Confidence |
|:---|:---|:---|:---|
| [concept name] | [naming patterns, state machines, business rules] | [file locations] | [HIGH/MEDIUM/LOW] |

## Natural Seams

| Seam | Location | Strength | Direction | Interaction Type | Evidence | Coupling |
|:---|:---|:---|:---|:---|:---|:---|
| [name] | [file/module] | [STRONG/WEAK/NO SEAM] | [Outbound/Inbound/Bidirectional] | [READ/WRITE/HOOK/SHARED/MODIFY] | [why this rating] | [what couples it] |

### Minimal Legacy Touch Register
*Only populated when HOOK or MODIFY interaction types are identified.*

| Legacy File | Line | Touch Type | Description | Behavior Change | Risk |
|:---|:---|:---|:---|:---|:---|
| [file] | [line] | [ADD hook/ADD emit/ADD callback/ADD facade] | [what to add] | NONE (additive only) | [LOW/MEDIUM/HIGH] |

## Review Status
- **Reviewed by:** [pending]
- **Date:** [pending]
- **Revisions:** [none / list of changes]
