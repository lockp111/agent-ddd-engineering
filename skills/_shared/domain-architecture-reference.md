# Domain Architecture Reference

> **HARD CONSTRAINTS — DO NOT MODIFY**
>
> These are the non-negotiable rules that protect domain isolation. They cannot be overridden by project preferences, team conventions, or "industry standards."

## Architecture Constraints

| Red Line |
|:---|
| Domain layer has no infrastructure dependencies |
| Domain structs have no ORM/JSON tags |
| No cross-aggregate direct imports |
| Business logic lives in entities or domain services |

## Domain Modeling Constraints

| Red Line |
|:---|
| Value objects are immutable |
| No public setters on entities |
| Domain events named in past tense |
| Aggregates reference other aggregates by ID only |

## Violation Response

When a red line violation is detected:

1. **STOP** — do not continue
2. **Delete** the violating code
3. **Rewrite** without the violation
4. If unavoidable, **escalate** — the spec or model may need revision
