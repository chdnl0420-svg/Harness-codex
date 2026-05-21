---
name: ecc-command-harness-customer-user
description: '슬래시 커맨드 ''/harness-customer-user''. 최종 사용자 관점의 Harness 고객 테스트를 실행한다.'
origin: local-codex-port-of-chdnl0420-svg-Harness
---

# 커맨드: /harness-customer-user

최종 사용자 관점으로 화면, 설치본, 핵심 과업, 문구 이해도를 점검한다.

## 필요 입력

- 실행 URL 또는 산출물 경로
- 확인할 핵심 과업
- 대상 사용자 유형

## 출력

`.harness/results/customer-<slug>.md`에 첫 인상, 과업 경로, 마찰, 개선 제안을 기록한다.

구현 파일은 수정하지 않는다.

## 공통 기준

- 실제 절차는 `harness` 스킬과 `~/.codex/skills/harness/docs/`를 따른다.
- 이 래퍼는 slash command 트리거와 고객 테스트 역할만 고정한다.
- 산출물은 Git common dir 기준 메인 repo `.harness`에 남긴다.
- 외부 저장소를 자동으로 덮어쓰지 않는다.
- 실행하지 않은 검증은 PASS로 쓰지 않는다.
