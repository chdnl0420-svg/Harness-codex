## CRITICAL: Step Boundary Contract

Each Harness step is a separate transaction. A transaction is complete only when all four conditions are true:

1. The current step document was read for this step.
2. The step artifact was created or updated.
3. `progress-<slug>.md` records the step completion and artifact path.
4. The next step gate was checked and recorded.

The caller Codex must not perform implementation, review, QA, customer validation, commit, or complete work ahead of the current step gate. Creating Step 1, Step 2, Step 3, and Step 4 outputs in one continuous pass is a boundary violation even if the artifacts are later present.

Required sequence:

- Step 1 creates initialization/progress state before Step 2.
- Step 2 creates `domain-<slug>.html` and records the gate before Step 3.
- Step 3 creates `implementation-<slug>.html` and records the gate before Step 4.
- Step 4 changes code only within the Step 3 implementation plan and records evidence before Step 5.
- Step 5 writes an independent review file under `.harness/reviews/` before Step 6.
- Step 6 writes `test-guide-<slug>.md` and `.harness/results/qa-<slug>.md`; only `PASS` opens Step 7.
- Step 7 writes `.harness/results/customer-<slug>.md` before Step 8 or Complete handling.
- Complete is forbidden while Step 5, Step 6, or Step 7 is missing.

Recovery rule:

If Codex detects merged steps or missing gates, do not continue from the apparent latest work. First write a progress entry named `STEP_BOUNDARY_REPAIR_REQUIRED`, preserve existing code changes, backfill missing Step 1-4 artifacts/gates, then resume from the earliest incomplete gate.
