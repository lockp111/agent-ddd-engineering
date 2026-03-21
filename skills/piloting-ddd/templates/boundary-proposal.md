# Boundary Proposal — [Project/Module Name]

## Proposed DDD Island

| Dimension | Value |
|:---|:---|
| **Name** | [BC name using Ubiquitous Language] |
| **Responsibility** | [one sentence: what this island owns] |
| **Key Entities** | [list of domain entities] |
| **Key Behaviors** | [list of domain behaviors/commands] |
| **Domain Events** | [list of events this island produces] |
| **Strategic Classification** | [Core Domain / Supporting / Generic] |

## ACL Boundary

| Legacy Touch Point | Integration Type | Direction | Mechanism | Translation Complexity | Notes |
|:---|:---|:---|:---|:---|:---|
| [legacy component] | [READ/WRITE/HOOK/SHARED/MODIFY] | [Outbound/Inbound/Bidirectional] | [DB adapter/API client/Event listener/CDC/Polling/Decorator] | [Simple/Moderate/Complex] | [notes] |

## Minimal Legacy Touch Register
*Only populated when HOOK or MODIFY interaction types are identified. Each entry requires human approval.*

| # | Legacy File | Line | Touch Type | Description | Existing Behavior | Risk |
|:---|:---|:---|:---|:---|:---|:---|
| 1 | [file path] | [line number] | [ADD hook / ADD emit / ADD callback / ADD facade] | [exact description of what to add] | UNCHANGED (additive only) | [LOW/MEDIUM/HIGH] |

**Principles:**
- Every entry is **additive only** — existing logic must not change
- Each entry gets a code comment: `// DDD Island integration point — see docs/ddd/boundary-proposal.md`
- Human must approve each entry before implementation

## Shared Concept Translation Table
*Only populated when SHARED interaction types are identified.*

| Legacy Name | DDD Name | Translation Rule | Semantic Differences |
|:---|:---|:---|:---|
| [legacy term/field] | [DDD term/field] | [how to translate] | [what meaning differs] |

## Non-Touch Zone
*Legacy areas that will NOT be modified or accessed by the DDD island.*

| Area | Reason |
|:---|:---|
| [directory/module/table] | [why excluded] |

## Architecture Sketch

```
┌─────────────────────────────────────────────────────────────┐
│                      Legacy System                          │
│                                                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐ │
│  │ [Legacy     │  │ [Legacy     │  │ [Legacy             │ │
│  │  Module A]  │  │  Module B]  │  │  Module C]          │ │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────────────┘ │
│         │                │                │                 │
└─────────┼────────────────┼────────────────┼─────────────────┘
          │                │                │
    ┌─────┴─────┐    ┌────┴─────┐    ┌─────┴──────┐
    │ Outbound  │    │ Inbound  │    │ Shared     │
    │ ACL       │    │ ACL      │    │ Concept    │
    │ Adapter   │    │ Adapter  │    │ Translator │
    └─────┬─────┘    └────┬─────┘    └─────┬──────┘
          │                │                │
┌─────────┴────────────────┴────────────────┴─────────────────┐
│                                                             │
│                    DDD Island                               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │               Domain Layer                          │    │
│  │  [Entities]  [Value Objects]  [Domain Events]       │    │
│  │  [Aggregates]  [Domain Services]                    │    │
│  └─────────────────────────────────────────────────────┘    │
│  ┌────────────────┐  ┌──────────────┐  ┌────────────────┐  │
│  │  Port          │  │  Port        │  │  Port          │  │
│  │  Interfaces    │  │  Interfaces  │  │  Interfaces    │  │
│  │  (Outbound)    │  │  (Inbound)   │  │  (Other)       │  │
│  └────────────────┘  └──────────────┘  └────────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

*Replace placeholders with actual module/component names.*

## Scope Assessment

| Metric | Value | Implication |
|:---|:---|:---|
| Total interaction points | [N] | [complexity indicator] |
| READ interactions | [N] | Low risk — standard outbound adapters |
| WRITE interactions | [N] | Low risk — standard outbound adapters |
| HOOK interactions | [N] | Medium risk — each needs legacy additive change |
| SHARED interactions | [N] | Medium risk — each needs translation layer |
| MODIFY interactions | [N] | **High risk** — each needs delegate/decorator point |
| Legacy touch points | [N] | Total additive changes to legacy code |
| Estimated ACL adapters | [N] | Adapter implementation count |

## Approval
- **Boundary confirmed by:** [pending]
- **Legacy touches approved by:** [pending]
- **Date:** [pending]
- **Notes:** [any overrides or conditions]
