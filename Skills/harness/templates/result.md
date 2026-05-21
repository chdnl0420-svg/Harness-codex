<!--
TEMPLATE: result.md
Generated at Complete.
Filename: results/report-<REQUEST_ID>.html for user-facing output, or results/result-<REQUEST_ID>.md only when Markdown is explicitly required.
-->
---
request_id: <REQUEST_ID>
status: completed
created: <ISO_TIMESTAMP_START>
completed: <ISO_TIMESTAMP_END>
review_count: <N>
qa_count: <N>
customer_verdict: <PASS | FAIL | BLOCKED | UNKNOWN | not-applicable>
---

# Result: <SHORT_TITLE>

## Summary

<1-2 sentence summary of what was accomplished>

## Original Request

> <USER_REQUEST verbatim>

## Final Changes

### Files Created

- `<path>` - <description>

### Files Modified

- `<path>` - <description>

## Harness Step Results

| Step | Artifact | Verdict |
| --- | --- | --- |
| Step 2 Domain | `.harness/domain-<REQUEST_ID>.html` | PASS |
| Step 3 Implementation plan | `.harness/implementation-<REQUEST_ID>.html` | PASS |
| Step 5 Review | `.harness/reviews/review-<REQUEST_ID>.md` | PASS |
| Step 6 QA | `.harness/results/qa-<REQUEST_ID>.md` | PASS |
| Step 7 Customer validation | `.harness/results/customer-<REQUEST_ID>.md` | PASS |

## Verification

- Command or evidence: `<command/path>`
- Result: `<result>`

## Deferred Issues

- <item or none>

## Recommended Next Steps

- [ ] <follow-up>

## Audit Trail

All artifacts are under `.harness/`.
