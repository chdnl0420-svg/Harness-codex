---
name: ecc-command-harness-audit
description: '슬래시 커맨드 ''/harness-audit''. Harness 설치, 프로젝트 .harness, 커맨드 래퍼, 스킬 문서의 문제를 점검한다.'
origin: local-codex-port-of-chdnl0420-svg-Harness
---

# 커맨드: /harness-audit

Harness 설치와 프로젝트 상태를 읽기 전용으로 점검한다.

## 확인 항목

- `~/.codex/skills/harness`, `harness-plan`, `ecc-command-harness*`
- `SKILL.md` frontmatter와 한글 description
- 잔여 legacy command markdown, 0바이트 docs, BOM/깨진 UTF-8
- Git common dir 기준 `.harness`
- bootstrap 스크립트 문법

## 출력

발견 사항을 심각도 순으로 쓰고, 바로 적용 가능한 수정 방향을 붙인다.

## 공통 기준

- 실제 절차는 `harness` 스킬과 `~/.codex/skills/harness/docs/`를 따른다.
- 이 래퍼는 slash command 트리거와 감사 범위만 고정한다.
- 산출물은 Git common dir 기준 메인 repo `.harness`에 남긴다.
- 외부 저장소를 자동으로 덮어쓰지 않는다.
- 실행하지 않은 검증은 PASS로 쓰지 않는다.
