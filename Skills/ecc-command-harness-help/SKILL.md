---
name: ecc-command-harness-help
description: '슬래시 커맨드 ''/harness-help''. Harness 커맨드, 단계, 설치, 산출물, 문제 해결 도움말을 보여준다.'
origin: local-codex-port-of-chdnl0420-svg-Harness
---

# 커맨드: /harness-help

Harness 사용법을 설명한다. 기본적으로 파일을 수정하지 않는다.

## 다룰 내용

- `/harness`와 `/harness-ask`의 차이
- Step 1부터 Complete까지의 흐름
- `.harness` 산출물 위치
- Git worktree에서 메인 repo `.harness`를 찾는 방법
- 설치/업데이트/dual environment 정책

필요하면 `~/.codex/skills/harness/docs/`의 관련 문서를 요약한다.

## 공통 기준

- 실제 절차는 `harness` 스킬과 `~/.codex/skills/harness/docs/`를 따른다.
- 이 래퍼는 slash command 트리거와 도움말 범위만 고정한다.
- 기본적으로 파일을 수정하지 않는다.
- 외부 저장소를 자동으로 덮어쓰지 않는다.
- 사용자의 현재 프로젝트 상태와 일반 도움말을 구분한다.
