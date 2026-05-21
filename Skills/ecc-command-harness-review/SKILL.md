---
name: ecc-command-harness-review
description: '슬래시 커맨드 ''/harness-review''. 현재 diff나 지정 파일을 Harness 방식으로 리뷰한다.'
origin: local-codex-port-of-chdnl0420-svg-Harness
---

# 커맨드: /harness-review

코드 또는 문서 변경을 리뷰한다.

## 우선순위

- 동작 회귀
- 데이터 손상
- 보안/개인정보
- 성능/신뢰성
- 테스트 공백

## 출력

finding을 심각도 순으로 쓰고 파일/라인 근거를 붙인다. 실행하지 않은 테스트는 미실행으로 표시한다.

## 공통 기준

- 실제 절차는 `harness` 스킬과 `~/.codex/skills/harness/docs/`를 따른다.
- 이 래퍼는 slash command 트리거와 리뷰 역할만 고정한다.
- 산출물은 Git common dir 기준 메인 repo `.harness`에 남긴다.
- 외부 저장소를 자동으로 덮어쓰지 않는다.
- 실행하지 않은 검증은 PASS로 쓰지 않는다.
