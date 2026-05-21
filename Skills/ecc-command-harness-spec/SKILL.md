---
name: ecc-command-harness-spec
description: '슬래시 커맨드 ''/harness-spec''. Harness 프로젝트 사양 문서와 AGENTS.md 운영 규칙을 만들거나 점검한다.'
origin: local-codex-port-of-chdnl0420-svg-Harness
---

# 커맨드: /harness-spec

프로젝트 사양 문서를 만들거나 점검한다.

## 대상

- `docs/PRD.md`
- `docs/ARCHITECTURE.md`
- `docs/ADR.md`
- `docs/UI_GUIDE.md`
- `AGENTS.md`

Codex 기준 정본은 `AGENTS.md`다. 병행 환경 bridge가 필요하면 `/harness-setup` 정책을 따른다.

## 공통 기준

- 실제 절차는 `harness` 스킬과 `~/.codex/skills/harness/docs/`를 따른다.
- 이 래퍼는 slash command 트리거와 spec 범위만 고정한다.
- 산출물은 Git common dir 기준 메인 repo `.harness`에 남긴다.
- 외부 저장소를 자동으로 덮어쓰지 않는다.
- 기존 프로젝트 지침은 덮어쓰지 말고 병합 제안을 먼저 만든다.
