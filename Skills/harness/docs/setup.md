# Harness Setup

이 문서는 Codex용 Harness 설치와 초기화 기준이다.

## 설치 위치

Codex 스킬 본문은 사용자 스킬 폴더에 둔다.

```text
~/.codex/skills/harness
~/.codex/skills/harness-plan
~/.codex/skills/harness-plan-ask
~/.codex/skills/harness-review
~/.codex/skills/harness-deep-researcher
~/.codex/skills/harness-customer-user
~/.codex/skills/ecc-command-harness*
```

프로젝트별 상태는 현재 worktree가 아니라 Git common dir 기준 메인 repo에 둔다.

```text
<HARNESS_PROJECT_DIR>/.harness
```

## Step 1 초기화

1. `git rev-parse --path-format=absolute --git-common-dir`로 Git common dir을 찾는다.
2. 그 부모를 `HARNESS_PROJECT_DIR`로 둔다.
3. `$HARNESS_PROJECT_DIR/.harness`가 없으면 만든다.
4. 아래 산출물 폴더를 보장한다.
   - `progress/`
   - `reviews/`
   - `results/`
   - `research/`

스킬 폴더의 `templates/`, `docs/`, `agents/learning/`, `core/`는 프로젝트 `.harness`로 복사하지 않는다. 설치본 `~/.codex/skills/harness`가 정본이고, 프로젝트 `.harness`에는 실행 산출물만 둔다. 기존 프로젝트 산출물은 덮어쓰지 않는다.

## 프로젝트 지침

- 프로젝트 지침은 Codex 기준 `AGENTS.md`를 우선한다.
- `CLAUDE.md`가 이미 있으면 덮어쓰지 않는다.
- 병행 환경이 꼭 필요할 때만 `HARNESS_DUAL_ENV=1` 또는 `--dual-env`로 bridge 파일을 명시 생성한다.

## 업데이트 정책

이 설치본은 Codex용 로컬 포트다. `.version`의 `upstream_reference`는 원 출처를 추적하기 위한 값이며, 자동 갱신 명령의 대상이 아니다.

`/harness-setup` 또는 setup 스크립트의 `-Mode update`는 Git upstream에서 최신 Harness를 가져와 자동 반영 가능한 파일만 Codex 포트에 반영한다.

자동 반영 대상:

- `templates/doc-*.md`
- `templates/improvement.md`, `learning-proposal.md`
- `docs/context-layer.md`, `examples.md`, `file-formats.md`, `phases.md`, `stop-report.md`, `test-guide-format.md`

자동 보류 대상:

- `SKILL.md`, `.version`, `core/bootstrap-runtime.sh`
- `templates/doc-*.md`, `plan.md`, `progress.md`, `result.md`, `review.md`
- `docs/setup.md`, `workflow.md`, `donot.md`, `html-output-rule.md`, `environment-map.md`
- `docs/steps/*`, `docs/procedures/*`
- `agents/*`, 런타임별 project instruction 템플릿

보류 대상은 report에 남기고 수동 포팅한다. 자동 반영 전 기존 파일은 `~/.codex/harness-update-backups/`에 백업한다.

```powershell
powershell -ExecutionPolicy Bypass -File ~/.codex/skills/ecc-command-harness-setup/scripts/check-harness-setup.ps1 -Mode update
```

dry-run:

```powershell
powershell -ExecutionPolicy Bypass -File ~/.codex/skills/ecc-command-harness-setup/scripts/check-harness-setup.ps1 -Mode update -DryRun
```

Bash audit/mirror 점검:

```bash
bash ~/.codex/skills/ecc-command-harness-setup/scripts/check-harness-setup.sh --check-mirror
```

## Codex와 Claude Code 병행 프로젝트

Codex 기준 프로젝트 지침 파일은 `AGENTS.md`다. Bootstrap은 `AGENTS.md`가 없거나 비어 있을 때만 기본 bridge를 만든다. 자세한 매핑은 [environment-map.md](environment-map.md)를 따른다.

- 기존 `CLAUDE.md`가 있으면 덮어쓰지 않는다.
- 병행 환경에서 Claude Code가 같은 규칙을 읽어야 하면 `HARNESS_DUAL_ENV=1`을 지정해 `CLAUDE.md` bridge를 생성할 수 있다.
- bridge는 `AGENTS.md`를 정본으로 가리키는 얇은 안내 파일이며, Harness 상태는 여전히 메인 repo `.harness`가 정본이다.

## bootstrap 스크립트

`core/bootstrap-runtime.sh`는 위 초기화를 자동화한다.

```bash
bash ~/.codex/skills/harness/core/bootstrap-runtime.sh <project-or-worktree-dir>
```

인자를 생략하면 현재 디렉터리를 기준으로 계산한다.

병행 bridge가 필요한 경우:

```bash
HARNESS_DUAL_ENV=1 bash ~/.codex/skills/harness/core/bootstrap-runtime.sh <project-or-worktree-dir>
# 또는
bash ~/.codex/skills/harness/core/bootstrap-runtime.sh --dual-env <project-or-worktree-dir>
```

## runtime gate 스크립트

`core/validate-runtime-gate.ps1`는 Step 전환 전에 산출물과 판정 조건을 검사한다.

```powershell
powershell -ExecutionPolicy Bypass -File ~/.codex/skills/harness/core/validate-runtime-gate.ps1 -ProjectDir <project-dir> -NextStep Step6 -Slug <slug>
```

`Summary: FAIL`이면 다음 Step으로 이동하지 않는다.

## 도구 fallback

- Git이 없으면 현재 디렉터리를 프로젝트 루트로 사용하고 `NO_GIT`를 기록한다.
- 브라우저 MCP가 없으면 프로젝트 내 Playwright, E2E, CLI 테스트를 찾는다.
- 화면 확인을 못 했으면 UI 검증은 PASS가 아니라 `UNKNOWN` 또는 `BLOCKED`다.
- 외부 검색이 막혀 있으면 딥 리서치는 `BLOCKED`로 남기고 추측을 쓰지 않는다.

## Mirror drift 점검

Codex 설치본과 Claude Code 설치본을 함께 쓰는 경우, 같은 upstream commit을 가리켜도 실제 파일이 달라질 수 있다. 자동 수정하지 말고 먼저 점검한다.

```powershell
powershell -ExecutionPolicy Bypass -File ~/.codex/skills/ecc-command-harness-setup/scripts/check-harness-setup.ps1 -CheckMirror
```

PowerShell이 없는 환경에서는 다음을 사용한다.

```bash
bash ~/.codex/skills/ecc-command-harness-setup/scripts/check-harness-setup.sh --check-mirror
```

점검 결과가 WARN이면 diff를 검토하고 필요한 파일만 수동 반영한다.

## 문제 해결

### worktree 안에 `.harness`가 없다고 나옴

worktree 안에 없어도 정상일 수 있다. Git common dir 기준 메인 repo의 `.harness`를 확인한다.

### 스킬 문서가 비어 있거나 깨져 보임

프로젝트 `.harness/docs`가 아니라 설치본 `~/.codex/skills/harness/docs`를 확인한다. 스킬 문서는 UTF-8 BOM으로 저장되어야 PowerShell 기본 `Get-Content`에서도 한글이 깨지지 않는다. 프로젝트 `.harness`에는 실행 산출물만 두며 스킬 문서를 다시 복사하지 않는다.

### 커맨드 설명이 갱신되지 않음

Codex는 스킬 메타데이터를 세션 시작 시 읽는다. 스킬 파일을 수정한 뒤에는 Codex를 재시작해야 커맨드 설명과 트리거 설명이 확실히 갱신된다.
