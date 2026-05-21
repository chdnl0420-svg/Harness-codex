<!--
TEMPLATE: review.md
Generated during Step 5 review.
Filename: review-<REQUEST_ID>-iter-<N>.md
-->
---
request_id: <REQUEST_ID>
iteration: <N>
reviewer: <codex>
external_review: <unavailable | not-requested | independent-codex | user-approved>
reviewed_files:
  - <file path 1>
  - <file path 2>
created: <ISO_TIMESTAMP>
codex_attempt_exit_code: <0 | 2 | other>
step4_commit_sha: <sha or none>
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

## Decision

LGTM: YES | NO | UNKNOWN
external_review: unavailable | not-requested | independent-codex | user-approved
Review target: <diff/files>
Return path: continue | return-to-step-3 | return-to-step-4 | pause
Loop counter: <same-defect-label>=<count>

---

## External Review Note (if applicable)

(only shown if a user-approved external reviewer was used)

Codex unavailable or user requested external review: <reason>. Reviewed by <reviewer>.
User action recommended: 새 터미널 (cmd / PowerShell / Git Bash 중 하나) 열고 `codex login` 실행.

---

## Linked Improvement

(자동 생성 시 추가됨, NO LGTM 일 때)

→ improvements/improvement-<REQUEST_ID>-iter-<N>.md
