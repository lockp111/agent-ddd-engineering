# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is **Agent DDD Engineering** — a methodology and skills framework for guiding AI agents through Domain-Driven Design workflows. It is NOT a runnable application, but a knowledge base of structured skills that enforce architectural constraints during code generation.

## Core Architecture: 5-Phase DDD Pipeline

The `full-ddd` skill orchestrates a mandatory pipeline from PRD to production code:

| Phase | Skill | Output Artifact | Location |
|:---|:---|:---|:---|
| 1 | `extracting-domain-events` | Domain Events Table | `docs/ddd/phase-1-domain-events.md` |
| 2 | `mapping-bounded-contexts` | Context Map + Dictionaries | `docs/ddd/phase-2-context-map.md` |
| 3 | `designing-contracts-first` | Interface Contracts | `docs/ddd/phase-3-contracts.md` |
| 4 | `architecting-technical-solution` | Technical Solution | `docs/ddd/phase-4-technical-solution.md` |
| 5 | `coding-isolated-domains` | Rich Domain Code + Tests | Per-context implementation |

**Critical Rules:**
- Every phase requires **explicit human approval** before proceeding
- All approved artifacts must be **persisted immediately** to `docs/ddd/`
- Progress is tracked in `docs/ddd/ddd-progress.md`
- Key decisions are logged in `docs/ddd/decisions-log.md`
- NO phase may be skipped regardless of perceived simplicity

## Skills Directory Structure

```
skills/
├── full-ddd/                    # Orchestrator skill (uses all others)
├── extracting-domain-events/    # Phase 1: EventStorming
├── mapping-bounded-contexts/    # Phase 2: Context boundaries
├── designing-contracts-first/   # Phase 3: ACL interfaces
├── architecting-technical-solution/  # Phase 4: Tech decisions
├── coding-isolated-domains/     # Phase 5: Rich model implementation
└── importing-technical-solution/ # Onboard existing tech solutions
```

Each skill has:
- `SKILL.md` — YAML frontmatter (name, description, hooks) + markdown instructions
- `tests/` — Pressure test scenarios and baseline results

## Key Patterns

### Session Recovery
Before starting any DDD work, check `docs/ddd/ddd-progress.md`. If it exists, resume from the first incomplete phase using persisted artifacts as the source of truth.

### Constraint File Generation
After Phase 2 approval, generate per-context constraint files:
- Cursor: `.cursor/rules/[context].mdc`
- Windsurf: `.windsurf/rules/[context].md`
- Claude Code: `.claude/rules/[context].md`

### Domain Isolation (Phase 5)
- Zero infrastructure dependencies in domain layer (no ORM tags, no HTTP)
- Rich Domain Models with behavior methods (no public setters)
- Aggregate references by ID only
- TDD first, zero mocking required

## Exit Gate (Between Phase 1 and 2)

After Phase 1 approval, present a complexity assessment and ask the user to choose:
- **Continue** → Full 5-phase pipeline
- **Exit** → Skip to simplified mode (go directly to `coding-isolated-domains`)

The agent must NOT recommend either option. Present data neutrally.

## Templates and Scripts

- `skills/full-ddd/templates/` — Artifact templates (ddd-progress.md, phase files)
- `skills/full-ddd/scripts/` — Verification scripts:
  - `check-persistence.sh` — Verify artifacts exist
  - `verify-artifacts.sh` — Validate artifact contents
  - `session-recovery.sh` — Quick status report

## Trigger Phrases

Skills use multilingual triggers in descriptions:
- `extracting-domain-events`: "需求分析", "事件风暴", "event storming", "domain events"
- `mapping-bounded-contexts`: "划分上下文", "bounded context", "context map"
- `designing-contracts-first`: "契约优先", "防腐层", "ACL", "anti-corruption layer"
- `architecting-technical-solution`: "技术方案", "架构决策", "ADR", "technical solution"
- `coding-isolated-domains`: "充血模型", "六边形架构", "rich domain model", "hexagonal architecture"
