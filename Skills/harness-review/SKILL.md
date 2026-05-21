---
name: harness-review
description: 'Harness Step 5 리뷰 wrapper. 구현 diff와 파일 목록을 독립 리뷰 경로로 넘기고, 결과를 .harness/reviews/review-<slug>.md에 누적한다. 외부/독립 리뷰가 불가능하면 self-review로 진행하되 LGTM: YES를 쓰지 않고 LGTM: UNKNOWN으로 둔다.'
origin: local-codex-port-of-chdnl0420-svg-Harness
---

# harness-review

`/harness` Step 5에서 사용하는 Codex용 리뷰 wrapper다. 원본 Harness의 "외부 verifier 우선" 계약을 유지하되, Codex 환경에서는 사용 가능한 독립 리뷰 수단에 맞춰 실행한다.

## 호출 조건

- `/harness` Step 5 진입
- `/harness-review` 사용자 직접 호출
- 리뷰 대상 diff 또는 파일 목록이 명확한 경우

## 절차

1. `.harness/reviews/review-<slug>-file-list.md`에 리뷰 대상 경로만 기록한다.
2. 가능한 독립 리뷰 수단을 먼저 사용한다.
   - 별도 `codex exec`가 가능하면 원본 절차처럼 한 줄 프롬프트로 호출한다.
   - 사용자가 병렬/외부 리뷰를 명시했고 도구가 있으면 그 결과를 사용한다.
3. 독립 리뷰가 불가능하면 현재 Codex 세션에서 diff와 파일을 직접 읽되 `external_review: unavailable`을 기록한다.
4. 결과를 `.harness/reviews/review-<slug>.md`에 누적한다.
5. `LGTM`, `external_review`, `Review target`, `Return path`, `Loop counter`를 반드시 기록한다.

## 판정 계약

- `LGTM: YES`는 `external_review: independent-codex` 또는 `external_review: user-approved`와 함께만 쓴다.
- self-review만 수행한 경우 `LGTM: YES`를 쓰지 않는다. 이 경우 `LGTM: UNKNOWN`으로 두고 Step 6 진입을 막는다.
- CRITICAL/HIGH finding이 있으면 `LGTM: NO`다.
- 리뷰 대상이 불명확하면 `LGTM: UNKNOWN`으로 두고 파일 목록을 다시 만든다.

## 관계

- 세부 기준: `~/.codex/skills/harness/docs/steps/step5-review.md`
- 리뷰 절차: `~/.codex/skills/harness/docs/procedures/codex-review-procedure.md`
- 산출물: `.harness/reviews/review-<slug>.md`
