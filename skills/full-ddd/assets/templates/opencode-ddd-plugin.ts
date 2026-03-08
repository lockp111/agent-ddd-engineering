import type { Plugin } from "@opencode-ai/plugin"

export const DDDWorkflowPlugin: Plugin = async ({ $, client }) => {
  return {
    "tool.execute.before": async (input) => {
      await $`cat docs/ddd/ddd-progress.md 2>/dev/null | head -20 || true`
    },

    "tool.execute.after": async (input) => {
      const writeMutations = ["edit", "write", "create", "patch"]
      if (writeMutations.some((t) => input.tool?.toLowerCase().includes(t))) {
        await $`sh skills/full-ddd/scripts/check-persistence.sh 2>/dev/null || true`
      }
    },

    stop: async (input) => {
      const result =
        await $`sh skills/full-ddd/scripts/verify-artifacts.sh 2>/dev/null`
      if (result.exitCode !== 0) {
        const sessionId = input.sessionID || input.session_id
        if (sessionId) {
          await client.session.prompt({
            path: { id: sessionId },
            body: {
              parts: [
                {
                  type: "text",
                  text: "[DDD-ERROR] Completed phases have missing artifact files. Persist all approved deliverables to docs/ddd/ before ending the session.",
                },
              ],
            },
          })
        }
      }
    },
  }
}
