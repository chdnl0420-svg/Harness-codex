<!--
TEMPLATE: review.md
Generated during Step 5 review.
Filename: review-<REQUEST_ID>-iter-<N>.md
-->
---
request_id: <REQUEST_ID>
iteration: <N>
run_number: <N>
reviewer: <independent-codex | user-approved | fallback-self-review>
reviewed_files:
  - <file path 1>
  - <file path 2>
created: <ISO_TIMESTAMP>
codex_attempt_exit_code: <0 | 2 | other>  # only relevant if fallback occurred
verdict: <LGTM YES | LGTM NO | BLOCKED | UNKNOWN>
previous_run: <N-1 | null>
run_ordering_check: <PASS | FAIL>
latest_review_pointer: .harness/state.json#latest_review
---

# Code Review (Iteration <N>) — by <Reviewer>

## Summary

<1-line verdict>

## Issues by Severity

### CRITICAL
- [<file:line>] <issue description>

### HIGH
- [<file:line>] <issue description>

### MEDIUM
- [<file:line>] <issue description>

### LOW
- [<file:line>] <issue description>

## LGTM

<LGTM YES | LGTM NO | BLOCKED | UNKNOWN>

## Run Ordering

- previous_run: <N-1 | null>
- current_run: <N>
- result: <PASS | FAIL>
- event_appended: `.harness/events.ndjson`
- state_updated: `.harness/state.json.latest_review`

---

## Fallback Note (if applicable)

(only shown if independent Codex review failed and a fallback review was used)

⚠️ Independent Codex review unavailable: <reason>. Fallback review used; do not promote self-review to LGTM:YES without user-approved external review.
User action recommended: 새 터미널 (cmd / PowerShell / Git Bash 중 하나) 열고 `codex login` 실행.

---

## Linked Improvement

(자동 생성 시 추가됨, NO LGTM 일 때)

→ improvements/improvement-<REQUEST_ID>-iter-<N>.md
