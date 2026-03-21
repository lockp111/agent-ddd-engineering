---
name: spec-driven-development
description: >
  Use when transitioning from Phase 4 technical solution to Phase 5 implementation.
  Generates coding-spec.md containing naming conventions, layering rules, and
  test conventions that guide all subsequent code generation.
  OpenAPI/Proto was already generated in Phase 4 as technical decision output.
  SDD, 项目规范, coding spec, naming conventions.
---

# Spec-Driven Development (SDD)

## Overview

SDD generates `docs/ddd/coding-spec.md` — the coding conventions that guide Phase 5 implementation.

**Note:** OpenAPI/Proto files are Phase 4 outputs (technical decisions). SDD takes those as inputs and generates the coding-specific conventions.

**SDD provides coding-level constraints:**
- Naming conventions (file names, package names)
- Layering rules (which layer can import which)
- Test conventions (test file naming, framework)

**Anti-hallucination stack:**
- DDD constrains *what* to build (semantic truth)
- Phase 4 constrains *interface format* (structural truth via OpenAPI/Proto)
- SDD constrains *code shape* (coding conventions via coding-spec.md)
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

### Step 2: Generate Coding Spec

Generate `docs/ddd/coding-spec.md` based on:
- Phase 4 technical decisions
- Language-specific conventions (e.g., [go-conventions](./reference/go-conventions.md) for Go projects)
- Project-specific overrides

### Step 3: Persist

Write `docs/ddd/coding-spec.md`.

### Step 4: Inform Human

Present the generated coding spec:

```
Coding spec generated: docs/ddd/coding-spec.md

Conventions:
- Naming: [from template]
- Layering: [from template]
- Testing: [from template]

Human can modify this file before Phase 5 begins.
Phase 5 will read this file to generate code.
```

## Output

| Artifact | Location |
|:---------|:---------|
| Coding Spec | `docs/ddd/coding-spec.md` |

## Relationship to Other Skills

- [architecting-technical-solution](../architecting-technical-solution/SKILL.md) → Phase 4 prerequisite (provides tech decisions)
- [coding-isolated-domains](../coding-isolated-domains/SKILL.md) → Phase 5 consumer (reads coding-spec.md)
- [go-conventions](./reference/go-conventions.md) → Default values for Go projects
