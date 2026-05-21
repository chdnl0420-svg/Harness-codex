## CRITICAL: Step Boundary Gate

Harness steps must be executed one at a time. Do not merge Step 1-3 planning, Step 4 implementation, Step 5 review, Step 6 QA, or Step 7 customer validation into a single pass.

Before starting every step:

1. Read the matching `docs/steps/<step>.md` file immediately before doing that step.
2. Tell the user the current workflow step in one short line.
3. Verify the prior step's required artifact and progress record exist.
4. If the gate is missing, stop forward progress and repair the missing artifact or progress entry first.

Before leaving every step:

1. Write the step's required artifact.
2. Append a progress entry that names the completed step, artifact path, evidence, and next gate.
3. Verify the next step's entry gate.
4. Do not start the next step until those three items are complete.

Strict gates:

- Step 5 requires an independent Codex review result file under `.harness/reviews/`. A self-summary is not a Step 5 substitute.
- Step 6 requires `test-guide-<slug>.md` and a QA result under `.harness/results/` with `PASS`, `BLOCKED`, or `FAIL`.
- Step 7 may start only after Step 6 is explicitly `PASS`.
- Complete may start only after Step 7 has been processed and Step 8 is done or intentionally skipped by documented policy.

If a previous run merged or skipped steps, mark the run as "Step boundary repair required" in progress, keep code changes intact, backfill Step 1-4 artifacts/gates first, then resume at Step 5.
