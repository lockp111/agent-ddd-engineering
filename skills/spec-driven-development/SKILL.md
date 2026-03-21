---
name: spec-driven-development
description: >
  Use when transitioning from Phase 4 technical solution to Phase 5 implementation.
  Generates coding constraints and writes them to IDE rules files for automatic loading.
  OpenAPI/Proto was already generated in Phase 4 as technical decision output.
  SDD, 项目规范, coding spec, naming conventions.
---

# Spec-Driven Development (SDD)

## Overview

SDD generates coding constraints and writes them to IDE rules files. These rules are automatically loaded by sub-agents during Phase 5 implementation.

**Note:** OpenAPI/Proto files are Phase 4 outputs (technical decisions). SDD takes those as inputs and generates the coding-specific conventions.

**SDD provides coding-level constraints:**
- Naming conventions (file names, package names)
- Layering rules (which layer can import which)
- Test conventions (test file naming, framework)

**Anti-hallucination stack:**
- DDD constrains *what* to build (semantic truth)
- Phase 4 constrains *interface format* (structural truth via OpenAPI/Proto)
- SDD constrains *code shape* (coding conventions via IDE rules)
- TDD proves *it works* (execution proof)

## When to Use

- After Phase 4 is approved and OpenAPI/Proto files exist
- Before Phase 5 (coding-isolated-domains) begins

**Do NOT use when:** Phase 4 is not finalized or OpenAPI/Proto files are missing.

## Process

### Step 1: Read Phase 4 Outputs

Read `docs/ddd/phase-4-technical-solution.md` and OpenAPI/Proto files to understand:
- Technology choices (language, framework, DB)
- Interface formats
- Any special requirements

### Step 2: Generate Coding Constraints

Generate constraint content based on:
1. Read [template/coding-spec.md](./template/coding-spec.md) — contains placeholders
2. Read language-specific conventions (e.g., [go-conventions](./go-conventions.md) for Go projects)
3. Fill placeholders with language-specific values
4. Apply project-specific overrides

**Placeholder format:** `{placeholder_name}` in template gets replaced with value from language conventions.

### Step 3: Persist to IDE Rules

Adapt content to each IDE's rules format and write:

| IDE | File | Format |
|:----|:-----|:-------|
| Claude Code | `.claude/rules/ddd-constraints.md` | Markdown |
| Cursor | `.cursor/rules/ddd-constraints.mdc` | Markdown with Claude directives (`.mdc`) |
| Windsurf | `.windsurf/rules/ddd-constraints.md` | Markdown |

Each IDE has its own rules file format. Write the appropriate format for each.

### Step 4: Human Approval

Inform human to review the actual rules file:

```
Coding constraints written to:
- .claude/rules/ddd-constraints.md
- .cursor/rules/ddd-constraints.mdc
- .windsurf/rules/ddd-constraints.md

Please review and approve.
```

**Wait for human approval before proceeding to Phase 5.**

## IDE Rules File Format

### Claude Code (.md)

```markdown
# DDD Coding Constraints

## Naming
{naming_rules}

## Layer
{layer_rules}

## Testing
{testing_rules}

## Hard Constraints
- domain/ cannot import infra/
- No ORM tags in domain structs
- No public setters on entities
- Value objects are immutable
- Aggregates reference by ID only
```

### Cursor (.mdc)

```markdown
# DDD Coding Constraints
# @Claude

## Naming
{naming_rules}

## Layer
{layer_rules}

## Testing
{testing_rules}

## Hard Constraints
- domain/ cannot import infra/
- No ORM tags in domain structs
- No public setters on entities
- Value objects are immutable
- Aggregates reference by ID only
```

### Windsurf (.md)

Same format as Claude Code.

**Note:** If unsure about the exact format for an IDE, write Markdown format. All three IDEs support Markdown as the base format.

## Relationship to Other Skills

- [architecting-technical-solution](../architecting-technical-solution/SKILL.md) → Phase 4 prerequisite (provides tech decisions)
- [coding-isolated-domains](../coding-isolated-domains/SKILL.md) → Phase 5 consumer (auto-loads rules)
- [go-conventions](./go-conventions.md) → Default values for Go projects
