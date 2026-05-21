## 10. Step Boundary Violations

Forbidden:

- Combining multiple Harness steps into one un-gated pass.
- Starting Step 4 implementation before Step 3 artifact and progress completion are recorded.
- Treating typecheck, build, or ad hoc UI checks as Step 5 independent review.
- Treating implementation evidence as Step 6 QA without `test-guide-<slug>.md` and a QA result file.
- Entering Step 7 without an explicit Step 6 `PASS`.
- Reporting Complete while Step 5 review, Step 6 QA, or Step 7 customer validation is absent.

Required response when this happens:

- Stop forward movement.
- Preserve current code changes.
- Append an internal progress entry with `STEP_BOUNDARY_REPAIR_REQUIRED`.
- Backfill missing artifacts and gates in order.
- Resume from the earliest incomplete step, not from the most recent code state.
