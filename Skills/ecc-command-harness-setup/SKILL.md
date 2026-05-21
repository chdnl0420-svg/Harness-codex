---
name: ecc-command-harness-setup
description: '슬래시 커맨드 ''/harness-setup''. Codex용 Harness 설치 상태를 확인하고 명시 요청 시 안전한 업데이트 준비를 돕는다.'
origin: local-codex-port-of-chdnl0420-svg-Harness
---

# 커맨드: /harness-setup

Codex용 Harness 설치 상태를 점검한다.

기본 동작은 audit와 update dry-run이다. Git upstream에서 최신 Harness를 가져와 비교하되, 사용자가 `--update`처럼 쓰기 의도를 명시하지 않으면 파일을 변경하지 않는다. 자동 반영 대상은 런타임 독립적인 템플릿과 일반 참고 문서로 제한한다. Codex 전용 진입점, workflow, step/procedure, bootstrap, agent 지침은 자동 덮어쓰지 않고 “수동 포팅 필요”로 보고한다.

## 확인 항목

- `~/.codex/skills/harness`
- `~/.codex/skills/harness-plan`
- `~/.codex/skills/harness-plan-ask`
- `~/.codex/skills/ecc-command-harness*`
- `core/bootstrap-runtime.sh`
- `scripts/sync-codex-harness.ps1`
- `scripts/check-harness-setup.sh`
- `.version`의 `update_policy`
- 프로젝트 메인 repo `.harness`
- `--check-mirror` 요청 시 Codex 설치본과 Claude Code 설치본의 drift

## 업데이트 원칙

외부 저장소를 통째로 덮어쓰기하지 않는다. `/harness-setup --update`처럼 사용자가 쓰기를 명시한 경우에만 다음 파일군을 자동 반영한다.

- `templates/doc-*.md`
- `templates/improvement.md`, `learning-proposal.md`
- `docs/context-layer.md`, `examples.md`, `file-formats.md`, `phases.md`, `stop-report.md`, `test-guide-format.md`

자동 반영 전 기존 파일은 `~/.codex/harness-update-backups/`에 백업한다. 나머지 파일은 `~/.codex/harness-update-reports/`의 report에 수동 포팅 대상으로 남긴다.

`/harness-setup --audit`는 점검만 한다. `/harness-setup --dry-run-update`는 PowerShell 스크립트의 `-Mode update -DryRun`처럼 반영하지 않고 계획만 보여준다.

PowerShell을 쓰기 어려운 환경에서는 bash 점검 스크립트를 사용한다. bash 스크립트는 audit와 mirror drift 점검을 수행하며, 파일을 변경하지 않는다.

```bash
bash ~/.codex/skills/ecc-command-harness-setup/scripts/check-harness-setup.sh --check-mirror
```

## mirror 점검

사용자가 `/harness-setup --check-mirror`를 요청하면 setup 스크립트의 `-CheckMirror` 옵션과 같은 기준으로 점검한다.

- 같은 상대 경로의 파일 존재 여부 비교
- 같은 파일의 해시 비교
- `.version` commit이 같지만 파일이 다르면 WARN
- 결과만 보고하고 자동 동기화하지 않는다.

## 공통 기준

- 실제 절차는 `harness` 스킬과 `~/.codex/skills/harness/docs/`를 따른다.
- 이 래퍼는 slash command 트리거와 setup 점검 범위만 고정한다.
- 산출물은 Git common dir 기준 메인 repo `.harness`에 남긴다.
- 외부 저장소를 자동으로 덮어쓰지 않는다.
- 쓰기 작업은 사용자가 명시했을 때만 수행한다.
