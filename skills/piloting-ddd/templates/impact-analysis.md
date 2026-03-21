# Impact Analysis — [Project/Module Name]

## Requirement
[One paragraph: the new requirement being analyzed]

## Touched Entities/Models

| Entity | Location | Interaction Type | Access Pattern | Risk | Notes |
|:---|:---|:---|:---|:---|:---|
| [name] | [file:lines] | [READ/WRITE/HOOK/SHARED/MODIFY] | [query/update/extend/wrap/delegate] | [LOW/MEDIUM/HIGH] | [ACL implications] |

## Touched Business Logic

| Logic | Location | Interaction Type | Dependency | Risk | Notes |
|:---|:---|:---|:---|:---|:---|
| [behavior] | [file:lines] | [READ/WRITE/HOOK/SHARED/MODIFY] | [depends-on/modifies/replaces/hooks-into] | [LOW/MEDIUM/HIGH] | [ACL implications] |

## Touched Data Tables

| Table | Interaction Type | Access Pattern | Risk | Notes |
|:---|:---|:---|:---|:---|
| [name] | [READ/WRITE/HOOK/SHARED/MODIFY] | [query/update/join/migrate] | [LOW/MEDIUM/HIGH] | [schema coupling notes] |

## Touched External Integrations

| Integration | Interaction Type | Impact | Risk | Notes |
|:---|:---|:---|:---|:---|
| [name] | [READ/WRITE/HOOK/SHARED/MODIFY] | [use-existing/wrap/extend] | [LOW/MEDIUM/HIGH] | [ACL implications] |

## Interaction Direction Summary

| Direction | Count | Components |
|:---|:---|:---|
| **Outbound** (island → legacy) | [N] | [list] |
| **Inbound** (legacy → island) | [M] | [list] |
| **Bidirectional** | [K] | [list] |

## Interaction Type Summary

| Type | Count | Risk Level | Requires Legacy Touch |
|:---|:---|:---|:---|
| READ | [N] | LOW | No |
| WRITE | [N] | LOW | No |
| HOOK | [N] | MEDIUM | Yes (additive) |
| SHARED | [N] | MEDIUM | No (translation in ACL) |
| MODIFY | [N] | HIGH | Yes (delegate/decorator) |

## Risk Summary

| Level | Count | Components |
|:---|:---|:---|
| HIGH | [N] | [list — especially MODIFY interactions] |
| MEDIUM | [N] | [list] |
| LOW | [N] | [list] |

**MODIFY count: [N]** — Each MODIFY interaction requires explicit human confirmation (STOP trigger).

## Review Status
- **Reviewed by:** [pending]
- **Date:** [pending]
- **MODIFY interactions confirmed:** [pending]
