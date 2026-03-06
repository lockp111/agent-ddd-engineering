---
name: importing-technical-solution
description: Use when user has an existing technical solution, architecture document, or design spec and wants to onboard it into the DDD pipeline. Use when a tech solution exists but lacks structured DDD artifacts, or when reverse-engineering existing decisions into phase artifacts. 导入技术方案, 已有方案, 接入DDD, import to DDD, existing tech solution, import technical solution, reverse-engineer.
hooks:
  PreToolUse:
    - matcher: "Write|Edit|Bash|Read|Glob|Grep"
      hooks:
        - type: command
          command: "cat docs/ddd/ddd-progress.md 2>/dev/null | head -20 || true"
  PostToolUse:
    - matcher: "Write|Edit"
      hooks:
        - type: command
          command: "sh skills/full-ddd/scripts/check-persistence.sh 2>/dev/null || true"
  Stop:
    - hooks:
        - type: command
          command: "sh skills/full-ddd/scripts/verify-artifacts.sh 2>/dev/null || true"
---

# Importing Technical Solution

## Overview
This skill bridges existing technical solutions into the DDD pipeline. It reverse-extracts structured DDD phase artifacts (Domain Events, Context Map, Contracts, Technical Solution) from an existing architecture document, validates coverage against the 7 technical dimensions, fills gaps through interactive Q&A, and persists all artifacts for downstream domain implementation.

**Foundational Principle:** Imported artifacts are **NOT pre-approved**. Each reverse-extracted artifact must pass explicit human approval before it is persisted. The source document's prior approval context is irrelevant — DDD artifacts require separate validation of the EXTRACTION accuracy. All rules in this skill are mandatory constraints. There is no complexity threshold below which you may skip reverse-extraction.

## When to Use
- When user has an existing technical solution (architecture doc, design spec, ADR) and wants to enter the DDD pipeline.
- When a tech solution exists but lacks structured DDD artifacts (domain events, context maps, contracts).
- When onboarding a project with existing architecture decisions into the DDD workflow.
- When reverse-engineering an existing system's design into phase-by-phase DDD documentation.

**Do NOT use when:** no tech solution exists (use `full-ddd` to start from PRD), modifying logic within an established Bounded Context (use `coding-isolated-domains`), or the task is purely technical with no domain change.

## Quick Reference

| Step | Action | Output | Gate |
|:---|:---|:---|:---|
| 0 | Pre-flight Checks | Input validated + source persisted | — |
| 1 | Reverse-Extract Phase 1 | Domain Events Table | Human approval |
| 2 | Reverse-Extract Phase 2 | Context Map | Human approval |
| 3 | Reverse-Extract Phase 3 | Interface Contracts | Human approval |
| 4 | Validate 7 Dimensions | Coverage table (COVERED/PARTIAL/MISSING) | — |
| 5 | Fill Gaps | Gap decisions recorded | Human approval per gap |
| 6 | Persist Phase 4 | `docs/ddd/phase-4-technical-solution.md` | Human approval |
| 7 | Handoff | Next steps to user | — |

## Implementation (Interactive Q&A Session)

**CRITICAL RULE:** Do NOT just generate the final output and stop. You must guide the user through an interactive, step-by-step import process.

### Step 0: Pre-flight Checks

**(a) Check for Existing Artifacts:**
Check if `docs/ddd/` has existing artifacts. If yes, WARN the user by listing them and ask: "Existing DDD artifacts found: [list files]. Importing will overwrite them. Proceed?" Only continue after explicit confirmation.

**(b) Minimum Viable Content Check:**
The input must mention at least:
- ≥1 bounded context or service boundary
- ≥2 technology decisions
- ≥1 data model reference

If insufficient, reject with a clear error: "Input does not meet minimum viable content. Missing: [list]. Please provide a more complete technical solution document."

**(c) Accept Input:**
The user may provide the source as:
- **Pasted text:** Process inline.
- **Local file path:** Read the file, confirm content with the user.
- **URL:** Fetch the URL content, confirm content with the user.

**(d) Persist Source:**
Write the source document to `docs/ddd/import-source.md` with a header noting the input type, date, and original location.

**(e) Initialize Progress Tracking:**
Create `docs/ddd/` directory (if not exists) and initialize `ddd-progress.md` from the template (`skills/full-ddd/templates/ddd-progress.md`) with `workflow_mode: import`. Initialize `decisions-log.md` from the template.

### Step 1: Reverse-Extract Phase 1 (Domain Events)

Analyze the technical solution for business events, commands, and actors.

- For each extracted item, **cite the source paragraph or section** where it was found.
- Items NOT found in the source: flag as `[GAP — not in source document]`. Do NOT invent events to fill gaps silently.
- Present in the same format as `extracting-domain-events` output:

| Actor | Command | Domain Event | Business Rules / Invariants | Source Reference |
|:------|:--------|:-------------|:---------------------------|:-----------------|
|       |         |              |                            |                  |

**Checkpoint:** "Does this events table accurately reflect your technical solution? Are the [GAP] items real gaps that need to be addressed?"

After approval, persist to `docs/ddd/phase-1-domain-events.md` using the template from `skills/full-ddd/templates/phase-1-domain-events.md`. Update `ddd-progress.md` Phase 1 status to `complete`. Append key decisions to `decisions-log.md`. **This step is mandatory — do not skip even if the table is already visible in the conversation.**

### Step 2: Reverse-Extract Phase 2 (Bounded Contexts)

Extract context boundaries, strategic classification (Core/Supporting/Generic), and relationship patterns from the technical solution.

- **Cite source** for each boundary and classification.
- Flag items not in source as `[GAP — not in source document]`.
- Present in the same format as `mapping-bounded-contexts` output, including:
  - Event clustering into proposed contexts
  - Strategic classification with rationale
  - Context map with relationship patterns (ACL, Conformist, Customer-Supplier, Open Host)
  - Ubiquitous Language dictionary (extracted terms + prohibited synonyms from source)

**Checkpoint:** "Do these boundaries match your intended architecture? Is the strategic classification correct?"

After approval, persist to `docs/ddd/phase-2-context-map.md` using the template from `skills/full-ddd/templates/phase-2-context-map.md`. Update `ddd-progress.md` Phase 2 status to `complete`. Append key decisions to `decisions-log.md`.

> **Note:** Constraint files (`.cursor/rules/`, `.windsurf/rules/`, etc.) are NOT generated during import. Run `mapping-bounded-contexts` on the approved context map to generate platform-specific constraint files if needed.

### Step 3: Reverse-Extract Phase 3 (Contracts)

Extract interface definitions, port interfaces, boundary structs, and ACL patterns from the technical solution.

- **Single context with no cross-context communication:** Mark "N/A — single context, no cross-context contracts needed" and confirm with the user.
- **Cite source** for each contract, interface, and boundary struct.
- Flag items not in source as `[GAP — not in source document]`.
- Present in the same format as `designing-contracts-first` output.

**Checkpoint:** "Do these contracts accurately represent the integration points in your technical solution?"

After approval, persist to `docs/ddd/phase-3-contracts.md` using the template from `skills/full-ddd/templates/phase-3-contracts.md`. Update `ddd-progress.md` Phase 3 status to `complete`. Append key decisions to `decisions-log.md`.

### Step 4: Validate Against 7 Technical Dimensions

Using `skills/architecting-technical-solution/technical-dimensions-reference.md` as reference, validate the source document's coverage of all 7 dimensions:

1. Data Model & Persistence
2. Interface Type
3. Consistency Strategy
4. External Dependency Integration
5. Observability
6. Error Handling
7. Test Strategy

Use the strategic classification from Step 2 to determine analysis depth (Core Domain → Full RFC, Supporting → Medium, Generic → Lightweight). If not yet determined, **default to Core Domain.**

For each dimension:
- **(a)** Extract what the source document says — cite the location.
- **(b)** Assess completeness against the depth guidance.
- **(c)** Mark: **COVERED** / **PARTIAL** / **MISSING**.

Present summary table:

| # | Dimension | Status | Source Citation | Notes |
|:--|:----------|:-------|:---------------|:------|
| 1 | Data Model & Persistence | COVERED/PARTIAL/MISSING | [section] | [assessment] |
| 2 | Interface Type | COVERED/PARTIAL/MISSING | [section] | [assessment] |
| 3 | Consistency Strategy | COVERED/PARTIAL/MISSING | [section] | [assessment] |
| 4 | External Dependency Integration | COVERED/PARTIAL/MISSING | [section] | [assessment] |
| 5 | Observability | COVERED/PARTIAL/MISSING | [section] | [assessment] |
| 6 | Error Handling | COVERED/PARTIAL/MISSING | [section] | [assessment] |
| 7 | Test Strategy | COVERED/PARTIAL/MISSING | [section] | [assessment] |

### Step 5: Fill Gaps

For each **PARTIAL** or **MISSING** dimension:
- Ask: "Your tech solution doesn't fully address **[dimension]** for **[context]**. What's your decision?"
- Do NOT suggest or invent answers — only ask. The human provides the gap-filling decision.
- Record each gap-filling decision with the question asked and the user's answer.

After all gaps are addressed, present the complete Phase 4 artifact for final review.

### Step 6: Final Review & Persist Phase 4

Present the complete technical solution in the exact format of `skills/full-ddd/templates/phase-4-technical-solution.md`.

- Each decision must cite its source: original document section OR gap-filling Q&A exchange.
- Include the Dimension Challenge assessment: "Are these decisions grounded in the source document and gap-filling Q&A, or speculative?"

**Checkpoint:** "Do you approve this technical solution?"

After approval, persist to `docs/ddd/phase-4-technical-solution.md`. Update `ddd-progress.md` Phase 4 status to `complete`. Append to `decisions-log.md`.

### Step 7: Handoff

"Import complete. All 4 phase artifacts are persisted in `docs/ddd/`. To proceed to domain implementation, invoke `coding-isolated-domains` for each bounded context, starting with Core Domain contexts."

Do NOT proceed to Phase 5 coding. The user decides when and how to start implementation.

## Session Recovery

**Before starting any step**, check for an existing import workflow:

1. Check if `docs/ddd/ddd-progress.md` exists with `workflow_mode: import`.
2. **If it exists:** Read `ddd-progress.md`, `import-source.md`, and ALL persisted phase artifact files (`phase-1-domain-events.md`, `phase-2-context-map.md`, `phase-3-contracts.md`, `phase-4-technical-solution.md`, `decisions-log.md`). Resume from the first incomplete phase gate.
3. **If it does not exist:** Proceed with Step 0 (Pre-flight Checks).

**Persisted artifacts contain human-approved decisions and are authoritative.** Do not discard or re-do completed phases unless the user explicitly requests a rollback.

Run `sh skills/full-ddd/scripts/session-recovery.sh` for a quick status report of the current DDD workflow state.

## Self-Check Protocol

**MANDATORY on ALL platforms, regardless of whether hooks are configured.**

At every phase gate (before proceeding to the next step), execute this verification sequence:

1. **Artifact Exists:** Verify the artifact file for the completed phase EXISTS on disk. For example, after Step 1 approval, verify `docs/ddd/phase-1-domain-events.md` exists.
2. **Progress Updated:** Verify `docs/ddd/ddd-progress.md` shows the completed phase as `complete`.
3. **Decisions Logged:** Verify `docs/ddd/decisions-log.md` was appended with the phase's key decisions.
4. **Source Persisted:** Verify `docs/ddd/import-source.md` exists (after Step 0).

**If ANY check fails → STOP. Write the missing file. Do NOT proceed to the next step.**

This protocol is the universal fallback (Layer 2). Even if platform-native hooks (Layer 1) are misconfigured or absent, the Self-Check Protocol guarantees persistence enforcement through prompt-level instructions. You can also run the shell scripts manually: `sh skills/full-ddd/scripts/check-persistence.sh` and `sh skills/full-ddd/scripts/verify-artifacts.sh`.
## Platform-Specific Hooks

Hooks provide automated runtime verification (Layer 1). They call shared shell scripts from `skills/full-ddd/scripts/` (Layer 3) that check artifact persistence at key lifecycle points. During **Step 0 initialization**, detect the Agent platform and set up the corresponding hooks configuration.

| Platform | Config Location | Hook Mapping | Template |
|:---|:---|:---|:---|
| **Claude Code** | SKILL.md frontmatter (already defined above) | `PreToolUse` / `PostToolUse` / `Stop` | N/A (built-in) |
| **Cursor** | `.cursor/hooks.json` (project-level) | `preToolUse` / `postToolUse` / `stop` | `skills/full-ddd/templates/cursor-hooks.json` |
| **Windsurf** | `.windsurf/hooks.json` (project-level) | `pre_read_code` / `post_write_code` / `post_run_command` | `skills/full-ddd/templates/windsurf-hooks.json` |
| **OpenCode** | `.opencode/plugins/ddd-workflow.ts` | `tool.execute.before` / `tool.execute.after` / `stop` | `skills/full-ddd/templates/opencode-ddd-plugin.ts` |
| **Antigravity** | `.gemini/settings.json` | `BeforeTool` / `AfterTool` / `AfterAgent` | `skills/full-ddd/templates/antigravity-hooks-settings.json` |

### Hooks Setup During Initialization

When creating the `docs/ddd/` directory at Step 0, also set up platform-native hooks:

1. **Detect the Agent platform** by checking which config directories exist (`.cursor/`, `.windsurf/`, `.opencode/`, `.gemini/`) or by the user's environment.
2. **Generate or merge** the hooks config from the corresponding template in `skills/full-ddd/templates/`. If the project already has an existing hooks config file, **merge** the DDD hooks into it — do NOT overwrite the user's existing hooks.
3. **Claude Code** hooks are already defined in this skill's YAML frontmatter and require no additional setup.

### Three-Layer Defense

- **Layer 1 — Platform-Native Hooks:** Automated runtime checks triggered by the IDE at tool execution lifecycle points. Platform-specific configuration required.
- **Layer 2 — Self-Check Protocol:** Prompt-level verification instructions embedded in this skill. Works on ALL platforms with zero configuration. The universal fallback.
- **Layer 3 — Shared Shell Scripts:** `check-persistence.sh`, `verify-artifacts.sh`, `session-recovery.sh` from `skills/full-ddd/scripts/`. Shared with the `full-ddd` skill and maintained in one place. Called by both Layer 1 (hooks) and Layer 2 (manual invocation).

## Rationalization Table

These are real excuses agents use to bypass the import process. Every one of them is wrong.

| Excuse | Reality |
|:---|:---|
| "Source document already contains approved decisions, re-approval is redundant" | Source document approval was in a different context. DDD artifacts require separate validation of the EXTRACTION accuracy. |
| "Gaps are minor, fill them with reasonable defaults" | "Reasonable" to an AI ≠ domain intent. Every gap is a question for the human. Silent gap-filling creates false completeness. |
| "Approve all artifacts at once — they came from the same source" | Each artifact has different stakeholders. Events errors cascade into wrong boundaries. Sequential approval catches cascading errors early. |
| "Infer failure events from the happy path" | Inference ≠ extraction. Source silence on failure paths is a GAP, not an invitation to invent. |
| "The source document is comprehensive, skip the 7-dimension validation" | Comprehensiveness in the author's framework ≠ completeness in DDD's 7 dimensions. |
| "Existing docs/ddd/ artifacts are outdated, overwrite them" | Existing artifacts contain human-approved decisions. Overwriting requires explicit human directive. |
| "This is a simple tech solution, skip reverse-extraction of Phase 1-3" | No complexity threshold. Even a 1-page tech solution implies domain events, boundaries, contracts. |
| "Source citations slow things down — just extract and move on" | Citations are the only proof that extraction is grounded in the source, not hallucinated. Without citations, every extracted item is unverifiable. |
| "The tech solution uses the same terms as DDD, no translation needed" | Vocabulary alignment is coincidental. The source's "bounded context" may not match DDD's definition. Every term must be verified. |

## Red Flags — STOP

If you catch yourself thinking "the source already covers this", "minor gaps can be filled silently", "approve everything at once", "existing artifacts are outdated", or "too simple for full extraction" — **STOP. Extract each phase. Present each for approval. Flag gaps explicitly. Persist every approved artifact immediately. No exceptions.**

**NEXT STEP:** → `coding-isolated-domains`
