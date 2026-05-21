<!--
TEMPLATE: progress.md
Updated continuously throughout the workflow. This file is the resume source of truth.
-->
---
request_id: <REQUEST_ID>
last_updated: <ISO_TIMESTAMP>
status: in_progress
current_step: 1
current_chunk: none
review_count: 0
qa_count: 0
files_created: []
files_modified: []
---

# Progress: <REQUEST_ID>

## Current State

- Step: <1-8 | Complete>
- Chunk: <none | C1 | C2>
- Verdict: PASS | FAIL | BLOCKED | UNKNOWN
- Next: <next action>

## Step Completion

- [ ] Step 1: Init or resume
- [ ] Step 2: Domain design - `.harness/domain-<REQUEST_ID>.html`
- [ ] Step 3: Implementation plan - `.harness/implementation-<REQUEST_ID>.html`
- [ ] Step 4: Implementation
- [ ] Step 5: Review - `.harness/reviews/review-<REQUEST_ID>.md`
- [ ] Step 6: QA - `.harness/results/qa-<REQUEST_ID>.md`
- [ ] Step 7: Customer validation - `.harness/results/customer-<REQUEST_ID>.md`
- [ ] Step 8: Finish/commit handling
- [ ] Complete: Final report - `.harness/results/report-<REQUEST_ID>.html`

## Recent Actions

- <ISO_TIMESTAMP> - Step <n>: <action>

## Decisions

- <ISO_TIMESTAMP> - <decision and rationale>

## Blockers

- <none or blocker with required owner/action>

## Artifacts

- Domain: `.harness/domain-<REQUEST_ID>.html`
- Implementation: `.harness/implementation-<REQUEST_ID>.html`
- Reviews: `.harness/reviews/review-<REQUEST_ID>.md`
- QA: `.harness/results/qa-<REQUEST_ID>.md`
- Customer: `.harness/results/customer-<REQUEST_ID>.md`
- Final: `.harness/results/report-<REQUEST_ID>.html`

## Resume Instructions

To resume:

```text
/harness resume <REQUEST_ID>
```

Read this file first, then read the latest domain and implementation artifacts before editing code.
