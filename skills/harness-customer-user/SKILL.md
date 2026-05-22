---
name: harness-customer-user
description: harness step7 customer-test dispatcher. Calling this skill is explicit user authorization for sub-agent delegation. In Codex App, spawn `agent_type="worker"` or `default` and load `harness-customer-user` by including the full `~/.codex/agents/harness-customer-user.md` spec in the prompt. Direct caller-Codex persona execution is forbidden; if no spawn tool is available, return BLOCKED / DEPENDENCY_MISSING.
---

# harness-customer-user

This skill is a **subagent dispatcher**, not a direct-test fallback.

When step7 needs customer validation, the caller Codex must invoke the `harness-customer-user` subagent/helper with the required context. The caller Codex may build, install, launch, clean up, and read the final report, but must not role-play the customer persona or produce a PASS/FAIL customer verdict itself.

## Explicit Subagent Authorization

Calling this skill is an explicit user request for sub-agent delegation. Do not ask for extra permission and do not say that subagent use was not explicitly approved.

Codex App bridge:

1. Use the available sub-agent spawn tool with `agent_type="worker"` (`default` only if `worker` is unavailable).
2. Do not pass `agent_type="harness-customer-user"` unless the runtime explicitly lists that exact value as valid.
3. Read `~/.codex/agents/harness-customer-user.md` first; if missing, read `~/.codex/skills/harness/agents/harness-customer-user.md`.
4. Include the full agent spec in the spawned prompt after: `You are acting as harness-customer-user according to the Harness agent spec below.`
5. Include Prior Learning, production launch details, main repo `.harness/` path, the output path, and only the minimum customer brief needed to know what product is being opened. Do not pass click order, expected path, scoring method, or test procedure as user-facing instructions.
6. If the spawned worker returns the report body instead of writing the file, save that body verbatim. Do not author or alter the customer persona verdict in the caller session.

## Required Flow

1. Caller Codex verifies the step7 gate:
   - Latest `.harness/results/qa-<slug>.md` verdict is `PASS`.
   - `test-guide-<slug>.md` exists.
   - The production install or production-equivalent launch target is available.

2. Caller Codex reads and prepends required context:
   - `~/.codex/skills/harness/agents/learning/harness-customer-user.md`
   - production install path, launch command, URL, or executable path
   - main repo `.harness/` absolute path
   - optional `test-guide-<slug>.md` only as `## Hidden Oracle (NOT USER INSTRUCTIONS)` if the worker needs a hidden scope/oracle; never as test procedure or click guidance

3. Caller Codex invokes the `harness-customer-user` subagent/helper.
   - Do not use `isolation: "worktree"`.
   - The prompt must include `## Prior Learning (READ FIRST - DO NOT SKIP)` in the first 200 lines.
   - The prompt must state that Harness provides product execution information only; the worker owns the test method and must use a first-time ordinary-user, skeptical, friction-seeking stance.
   - The subagent writes `.harness/results/customer-<slug>.md`.

4. Caller Codex reads `.harness/results/customer-<slug>.md`, records the result path in progress, cleans up the production install if needed, and continues to step8.

## Hard Block

If the current Codex runtime cannot start a subagent/helper for `harness-customer-user`, stop step7 and record:

```text
Verdict: BLOCKED
reason_enum: DEPENDENCY_MISSING
reason: harness-customer-user subagent/helper is unavailable. Direct caller-Codex customer persona execution is forbidden.
```

Do not replace the subagent with direct testing, self-review, screenshots collected by the caller, or a simulated customer report.

## References

- Step procedure: `~/.codex/skills/harness/docs/steps/step7-customer.md`
- Customer procedure: `~/.codex/skills/harness/docs/procedures/customer-test-procedure.md`
- Learning file: `~/.codex/skills/harness/agents/learning/harness-customer-user.md`
