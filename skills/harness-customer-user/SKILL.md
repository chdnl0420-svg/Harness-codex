---
name: harness-customer-user
description: harness step7 customer-test dispatcher. Use only to prepare and invoke the `harness-customer-user` subagent/helper for production-install customer validation. Direct caller-Codex persona execution is forbidden; if no subagent/helper tool is available, return BLOCKED / DEPENDENCY_MISSING instead of testing directly.
---

# harness-customer-user

This skill is a **subagent dispatcher**, not a direct-test fallback.

When step7 needs customer validation, the caller Codex must invoke the `harness-customer-user` subagent/helper with the required context. The caller Codex may build, install, launch, clean up, and read the final report, but must not role-play the customer persona or produce a PASS/FAIL customer verdict itself.

## Required Flow

1. Caller Codex verifies the step7 gate:
   - Latest `.harness/results/qa-<slug>.md` verdict is `PASS`.
   - `test-guide-<slug>.md` exists.
   - The production install or production-equivalent launch target is available.

2. Caller Codex reads and prepends required context:
   - `~/.codex/skills/harness/agents/learning/harness-customer-user.md`
   - full `test-guide-<slug>.md`
   - production install path, launch command, URL, or executable path
   - main repo `.harness/` absolute path

3. Caller Codex invokes the `harness-customer-user` subagent/helper.
   - Do not use `isolation: "worktree"`.
   - The prompt must include `## Prior Learning (READ FIRST - DO NOT SKIP)` in the first 200 lines.
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
