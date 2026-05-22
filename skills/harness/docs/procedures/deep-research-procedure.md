# Deep Research Delegation

Harness does not define its own deep research workflow.

All Harness research branches must use the shared `$deepresearch` skill at:

`~/.codex/skills/deepresearch/SKILL.md`

This document is a compatibility pointer for older Harness references to `deep-research-procedure.md`.

## Harness Call Contract

When Step 2, Step 3, or Step 5 needs external research:

1. Call `$deepresearch`.
2. Include the Harness step name, slug, decision that depends on the research, relevant code/docs context, and any time/jurisdiction/version constraints.
3. Ask `$deepresearch` to write its Markdown report under `.harness/research/` unless the user specified another path.
4. Record the generated report path in the active Harness progress file.
5. Carry only high-confidence, cited findings into the Harness artifact that requested the research.

Do not run a separate `harness-deep-researcher` agent. Do not read or prepend Harness-specific deep-research learning data. The shared `$deepresearch` skill owns pass tiers, source rules, high-stakes rules, report naming, and completion criteria.
