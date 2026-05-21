---
name: ecc-command-harness-ask
description: '슬래시 커맨드 ''/harness-ask''. 결정 지점에서 사용자에게 확인하며 Codex용 Harness 워크플로를 실행한다.'
origin: local-codex-port-of-chdnl0420-svg-Harness
---

# 커맨드: /harness-ask

사용자 메시지가 `/harness-ask`로 시작하면 `harness` 스킬을 인터랙티브 모드로 사용한다.

## 동작

- 모드: ask
- 워크플로 시작 시 사용자에게 Step 1-8과 Complete의 전체 흐름을 짧게 알리고, 각 단계 진입/완료 시 현재 단계와 다음 단계를 안내한다.
- Step 2는 `harness-plan-ask` 기준으로 처리하고, 차단 환경이나 범위 충돌처럼 사용자 결정이 필요한 지점에서만 질문한다.
- 질문은 짧게 하고 선택지가 필요한 이유를 함께 설명한다.

## 산출물

일반 `/harness`와 동일하게 메인 repo `.harness` 아래에 기록한다.

## 공통 기준

- 실제 절차는 `harness` 스킬과 `~/.codex/skills/harness/docs/`를 따른다.
- 이 래퍼는 slash command 트리거와 모드만 고정한다.
- 산출물은 Git common dir 기준 메인 repo `.harness`에 남긴다.
- 외부 저장소를 자동으로 덮어쓰지 않는다.
- 실행하지 않은 검증은 PASS로 쓰지 않는다.
- 질문 답변도 progress에 결정 근거로 남긴다.
- 질문 없이 해결 가능한 선택은 Codex가 처리한다.
