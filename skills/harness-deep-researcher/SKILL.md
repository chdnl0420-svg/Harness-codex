---
name: harness-deep-researcher
description: Compatibility shim for old Harness deep research calls. Do not run a separate Harness-specific deep research workflow. Use the shared `$deepresearch` skill at `~/.codex/skills/deepresearch/SKILL.md` for all Harness external research, then attach the generated Markdown report path to the Harness step that requested it.
---

# harness-deep-researcher

This skill exists only so older Harness references do not break.

Harness no longer owns a separate deep research procedure, agent, learning file, pass-count policy, or citation policy. When a Harness step needs external research, call the shared `$deepresearch` skill and pass the Harness context into that request.

## Required Delegation

Use `$deepresearch` with:

- `Topic`: the concrete research question.
- `Context`: Harness step, slug, relevant stack, decision impact, and any constraints.
- `Output`: request a Markdown report under `.harness/research/` unless the user specified another path.
- `Integration`: after the report is written, record the report path in the active Harness progress/review/domain/implementation artifact and carry only the highest-signal findings into the next step.

Do not prepend Harness deep-research learning data. Do not invoke a Harness-specific helper/sub-agent. Do not use old files under `harness/agents/harness-deep-researcher.md` or `harness/agents/learning/harness-deep-researcher.md`; those files are deprecated and should not exist in the Codex port.
