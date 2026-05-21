<!--
TEMPLATE: progress.md
Updated continuously throughout the Harness workflow.
The frontmatter is the source of truth for resume logic.
-->
---
request_id: <REQUEST_ID>
slug: <slug>
last_updated: <ISO_TIMESTAMP>
status: in_progress  # in_progress | completed | failed | abandoned
current_step: Step 1  # Step 1 | Step 2 | Step 3 | Step 4 | Step 5 | Step 6 | Step 7 | Step 8 | Complete
current_iteration: 0
review_count: 0
qa_count: 0
research_count: 0
files_created: []
files_modified: []
---

# Progress: <slug>

## Current State

- Current step: <Step n or Complete>
- Mode: noask | ask
- Harness project dir: <absolute path>
- Next action: <one concrete action>

## Step Completion

- [ ] Step 1: 초기화 또는 재개
- [ ] Step 2: 도메인 설계
- [ ] Step 3: 구현 계획
- [ ] Step 4: 구현
- [ ] Step 5: 리뷰
- [ ] Step 6: QA
- [ ] Step 7: 고객 사용자 검증
- [ ] Step 8: 완료 전 정리
- [ ] Complete: 최종 보고

## Loop Counter

- step5 LGTM:NO 누적: 0회
- step6 FAIL 누적: 0회
- step6 BLOCKED 누적: 0회

## Artifacts

- Domain: `.harness/domain-<slug>.html`
- Implementation: `.harness/implementation-<slug>.html`
- Review: `.harness/reviews/review-<slug>.md`
- QA: `.harness/results/qa-<slug>.md`
- Customer: `.harness/results/customer-<slug>.md`
- Final report: `.harness/results/report-<slug>.html`

## Recent Actions

- <ISO_TIMESTAMP> — Step 1 — <action description>

## Resume Instructions

이 작업을 재개하려면:

```text
/harness resume <REQUEST_ID>
```

Codex는 이 progress.md의 `current_step`, `current_iteration`, 산출물 경로를 읽고 해당 지점부터 워크플로우를 재개한다.

## Notes

- <important decision recorded for resume>
