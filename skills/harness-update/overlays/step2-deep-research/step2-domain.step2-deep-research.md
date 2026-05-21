## CRITICAL: Step 2 Deep Research Gate

Step 2 includes an explicit external research branch. This overlay overrides any older wording that describes Step 2 as only "six categories plus Open Questions".

Required Step 2 sequence:

1. Collect or infer the six domain categories according to noask or ask mode.
2. Decide whether external information is needed before drafting the domain plan.
3. If research is needed, use `harness-deep-researcher` first, or have the caller Codex perform the same procedure directly when no helper/sub-agent is available.
4. Save research output under `.harness/research/research-<slug>-<NN>-<topic>.md`.
5. Include only high-confidence research findings in `domain-<slug>.html`.
6. If research is not needed, record `리서치 필요 없음 — 사유: ...` in progress and do not create a research file.

Research triggers include library or framework selection, current best practices, security advisories, API migration impact, vendor documentation checks, and any user answer marked "조사 필요".

The single source of truth for research prompts, tiers, citations, search trail, stop reason, and output fields is `harness/docs/procedures/deep-research-procedure.md`.
