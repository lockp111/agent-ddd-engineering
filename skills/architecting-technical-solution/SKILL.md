---
name: architecting-technical-solution
description: Use when transitioning from approved contracts to domain coding, when technology choices need explicit decisions, or when an agent starts coding with implicit architectural assumptions. 技术方案, 架构决策, ADR, technical solution, 技术选型.
---

# Architecting Technical Solution

## Overview

This skill forces explicit, evidence-based technology decisions between contract design and domain coding. Each context's dimensions must be analyzed at appropriate depth and approved before implementation.

**Foundational Principle:** Contracts define *what* boundaries look like. This phase defines *how* to realize them. No coding until decisions are approved.

## When to Use

- After Phase 3 contracts are approved; before domain implementation; when technology choices are needed.

**Do NOT use when:** Contracts are not yet approved (**REQUIRED PREREQUISITE:** `designing-contracts-first`).

## Quick Reference

| Step | Action | Output |
|:---|:---|:---|
| 1 | Review Strategic Classification | Depth confirmed |
| 2 | Walk 7 Dimensions | Decisions at depth |
| 3 | Dimension Challenge | Pass / Roll back |
| 4 | Human Review | Decisions frozen |
| 5 | Persist Approved Output | `docs/ddd/phase-4-technical-solution.md` |

## Implementation (Interactive Q&A Session)

**CRITICAL RULE:** Do NOT just list technology choices. Guide the user through interactive, step-by-step architectural decisions.

1. **Review Strategic Classification:** Read classification from Phase 2 (Core Domain → Full RFC, Supporting → Medium, Generic → Lightweight). No classification? **Default to Core Domain.** **Ask:** "Classified as [X] — [depth]. Correct?"
2. **Walk 7 Dimensions:** Use `technical-dimensions-reference.md`. Core: options tables with trade-offs. Supporting: choice + rationale. Generic: one-line. For Core Domain, **ask** about Optional Extensions.
3. **Dimension Challenge:** Ask: "Are these decisions grounded in domain events and contracts, or speculative?" Untraceable decisions get removed or trigger return to Phase 3.
4. **Human Review:** Present decisions by dimension. Ask: "Do you approve these technology choices?" Do NOT code until explicit approval.
5. **Persist:** Write to `docs/ddd/phase-4-technical-solution.md` using template. Update `ddd-progress.md` Phase 4 to `complete`. Append to `decisions-log.md`.

**NEXT STEP:** → `coding-isolated-domains`

## Rationalization Table

These are real excuses agents use to bypass this phase. Every one is wrong.

| Excuse | Reality |
|:---|:---|
| "Contracts already imply the technical decisions" | Contracts define boundaries, not technology; `InventoryServicePort` doesn't decide HTTP vs gRPC vs async. |
| "Standard choices don't need analysis" | "PostgreSQL + REST" without evaluating alternatives is not a decision. Core Domain always gets Full RFC. |
| "A good architect anticipates future needs" | Decisions must trace to domain artifacts; Kafka and CQRS without domain evidence is speculative waste. |
| "Depth classification is overkill here" | Depth follows strategic classification, not how trivial decisions feel. |
| "I'll document decisions after coding" | Post-hoc documentation rationalizes existing code; the gate must be synchronous. |
| "Self-approve — decisions are clearly grounded" | Self-approval defeats the human checkpoint. |

## Red Flags — STOP

If you catch yourself thinking "contracts are enough to start coding", "obvious choices", or "document later" — STOP. Walk each dimension. Run the Dimension Challenge. Wait for approval.
