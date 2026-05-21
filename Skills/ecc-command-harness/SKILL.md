---
name: ecc-command-harness
description: '슬래시 커맨드 ''/harness''. 사용자 요청을 Codex용 Harness noask 워크플로로 실행한다.'
origin: local-codex-port-of-chdnl0420-svg-Harness
---

# 커맨드: /harness

사용자 메시지가 `/harness`로 시작하면 `harness` 스킬을 사용한다.

## 동작

- 모드: noask
- 루트: Git common dir 기준 메인 repo
- 상태: `.harness/progress/progress-<slug>.md`
- 산출물: 계획/보고 HTML, 진행/리뷰/QA Markdown

## 규칙

- 합리적 가정으로 진행하고 가정은 progress에 기록한다.
- 워크플로 시작 시 사용자에게 Step 1-8과 Complete의 전체 흐름을 짧게 알리고, 각 단계 진입/완료 시 현재 단계와 다음 단계를 안내한다. 이는 진행 상황 공유이며 승인 요청이 아니다.
- 결정이 없으면 진행할 수 없는 경우 질문하지 않는 것이 기본이다. 단, 원본 Harness와 동일하게 Complete 진입 전 Step 7 결과 처리와 Step 6 동일 BLOCKED 사유 5회 누적은 noask 예외 질문을 허용한다.
- worktree 안에 별도 `.harness`를 만들지 않는다.

## 공통 기준

- 실제 절차는 `harness` 스킬과 `~/.codex/skills/harness/docs/`를 따른다.
- 이 래퍼는 slash command 트리거와 모드만 고정한다.
- 산출물은 Git common dir 기준 메인 repo `.harness`에 남긴다.
- 외부 저장소를 자동으로 덮어쓰지 않는다.
- 실행하지 않은 검증은 PASS로 쓰지 않는다.
