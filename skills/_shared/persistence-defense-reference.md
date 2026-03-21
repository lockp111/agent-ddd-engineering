# Persistence Defense Reference

## Self-Check Protocol

**MANDATORY on ALL platforms, regardless of whether hooks are configured.**

At every phase gate (before proceeding to the next phase), the orchestrator MUST execute this verification sequence:

1. **Artifact Exists:** Verify the artifact file for the completed phase EXISTS on disk (use Read/ls). For example, after Phase 1 approval, verify `docs/ddd/phase-1-domain-events.md` exists.
2. **Progress Updated:** Verify `docs/ddd/ddd-progress.md` shows the completed phase as `complete`.
3. **Decisions Logged:** Verify `docs/ddd/decisions-log.md` was appended with the phase's key decisions.
4. **[Context-Specific Check]:** See the invoking skill for the 4th verification item.

**If ANY check fails → STOP. Write the missing file. Do NOT proceed to the next phase.**

This protocol is the universal fallback (Layer 2). Even if platform-native hooks (Layer 1) are misconfigured or absent, the Self-Check Protocol guarantees persistence enforcement through prompt-level instructions. You can also run the shell scripts manually: `sh skills/full-ddd/scripts/check-persistence.sh` and `sh skills/full-ddd/scripts/verify-artifacts.sh`.

## Platform-Specific Hooks

Hooks provide automated runtime verification (Layer 1). They call shared shell scripts (Layer 3) that check artifact persistence at key lifecycle points. During the **Start → Phase 1** initialization, detect the Agent platform and set up the corresponding hooks configuration.

| Platform | Config Location | Hook Mapping | Template |
|:---|:---|:---|:---|
| **Claude Code** | SKILL.md frontmatter (already defined above) | `PreToolUse` / `PostToolUse` / `Stop` | N/A (built-in) |
| **Cursor** | `.cursor/hooks.json` (project-level) | `preToolUse` / `postToolUse` / `stop` | `templates/cursor-hooks.json` |
| **Windsurf** | `.windsurf/hooks.json` (project-level) | `pre_read_code` / `post_write_code` / `post_run_command` | `templates/windsurf-hooks.json` |
| **OpenCode** | `.opencode/plugins/ddd-workflow.ts` | `tool.execute.before` / `tool.execute.after` / `stop` | `templates/opencode-ddd-plugin.ts` |
| **Antigravity** | `.gemini/settings.json` | `BeforeTool` / `AfterTool` / `AfterAgent` | `templates/antigravity-hooks-settings.json` |

### Hooks Setup During Initialization

When creating the `docs/ddd/` directory at workflow start, also set up platform-native hooks:

1. **Detect the Agent platform** by checking which config directories exist (`.cursor/`, `.windsurf/`, `.opencode/`, `.gemini/`) or by the user's environment.
2. **Generate or merge** the hooks config from the corresponding template in `skills/full-ddd/templates/`. If the project already has an existing hooks config file, **merge** the DDD hooks into it — do NOT overwrite the user's existing hooks.
3. **Claude Code** hooks are already defined in this skill's YAML frontmatter and require no additional setup.

### Three-Layer Defense

- **Layer 1 — Platform-Native Hooks:** Automated runtime checks triggered by the IDE at tool execution lifecycle points. Platform-specific configuration required.
- **Layer 2 — Self-Check Protocol:** Prompt-level verification instructions embedded in this skill. Works on ALL platforms with zero configuration. The universal fallback.
- **Layer 3 — Shared Shell Scripts:** `check-persistence.sh`, `verify-artifacts.sh`, `session-recovery.sh`. Called by both Layer 1 (hooks) and Layer 2 (manual invocation).
