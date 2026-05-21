---
name: ecc-command-harness-distill
description: '슬래시 커맨드 ''/harness-distill''. Harness learning 파일과 누적 메모를 보존 기준에 맞게 압축한다.'
origin: local-codex-port-of-chdnl0420-svg-Harness
---

# 커맨드: /harness-distill

Harness learning 파일을 읽고 중복, 낡은 표현, 도구 이름 drift를 정리한다.

## 규칙

- 검증된 교훈은 삭제하지 않고 짧게 압축한다.
- 프로젝트 비밀이나 계정 정보는 제거한다.
- 삭제가 애매하면 `Deprecated`로 표시한다.
- 사용자가 명시하지 않는 한 기존 데이터를 통째로 지우지 않는다.

## 공통 기준

- 실제 절차는 `harness` 스킬과 `~/.codex/skills/harness/docs/`를 따른다.
- 이 래퍼는 slash command 트리거와 distill 역할만 고정한다.
- 산출물은 Git common dir 기준 메인 repo `.harness`에 남긴다.
- 외부 저장소를 자동으로 덮어쓰지 않는다.
- 검증되지 않은 교훈은 정본 learning에 넣지 않는다.
- 압축 전후의 의미 변화가 있으면 사용자에게 알린다.
- learning 파일은 짧게 유지하되 운영 기준은 잃지 않는다.
