## CRITICAL: Step 2 Harness Plan Research Branch

`harness-plan` must run Phase 2 research whenever the Step 2 research triggers match. The preferred adapter order is:

1. `harness-deep-researcher` skill
2. `harness-deep-researcher` helper/sub-agent, with the required learning prepend
3. caller Codex direct research, following `harness/docs/procedures/deep-research-procedure.md`

The caller must save the full research result under `.harness/research/` and prepend only high-confidence findings into the domain draft. No citation means no claim.
