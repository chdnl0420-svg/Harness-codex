# Environment Map

Codex용 Harness와 Claude Code용 Harness는 같은 upstream에서 왔지만 실행 모델이 다르다. 이 문서는 두 환경을 함께 쓰는 프로젝트에서 어떤 파일이 정본인지, 어떤 쪽을 mirror로 볼지, drift가 생겼을 때 무엇을 해야 하는지 정한다.

## 정본 선언

- Upstream source: `https://github.com/chdnl0420-svg/Harness`
- Codex 로컬 포트 정본: `~/.codex/skills/harness`
- Claude Code 로컬 mirror: `~/.claude/skills/harness`
- 프로젝트 상태 정본: Git common dir 기준 메인 repo의 `.harness`
- 프로젝트 지침 정본: `AGENTS.md`
- Claude Code bridge: `CLAUDE.md`

Codex 환경에서는 Codex 로컬 포트를 운영 정본으로 본다. Claude Code 설치본은 같은 프로젝트에서 Claude Code가 읽기 위한 mirror이며, Codex 포트를 자동으로 덮어쓰는 근거가 아니다.

## 버전 필드

Codex 포트의 `.version`은 다음 필드를 기준으로 한다.

- `port`: `codex-local`
- `installed`: 설치 또는 최초 포팅 시각
- `local_owner`: 로컬 설치 경로
- `upstream_reference`: upstream URL
- `upstream_commit`: 마지막으로 확인한 upstream commit
- `upstream_branch`: upstream branch
- `update_policy`: 자동 반영 정책
- `update_rule`: 수동 검토 규칙

Claude Code mirror가 옛 형식(`commit`, `source`, `branch`)을 쓰더라도 mirror 점검은 두 형식을 모두 읽어야 한다. 새로 갱신할 때는 가능하면 위 필드명으로 맞춘다.

## 시나리오

### 1. Codex 단독

- `AGENTS.md`와 `.harness`만 사용한다.
- `CLAUDE.md` bridge는 만들지 않는다.
- `/harness`, `/harness-setup`, `/harness-review` 등 Codex slash wrapper가 정본이다.

### 2. Claude Code 단독

- `~/.claude/skills/harness`와 `~/.claude/commands/harness*.md`를 사용한다.
- 프로젝트 상태는 그래도 Git common dir 기준 `.harness`에 둔다.
- Codex 전용 스크립트를 Claude 쪽으로 복사할 때는 명령 모델 차이를 수동 검토한다.

### 3. 둘 다 사용, Codex master

- 기본 권장 모드다.
- Codex 포트가 workflow, setup, bootstrap, step/procedure 문서의 운영 정본이다.
- Claude Code는 `CLAUDE.md` bridge를 통해 `AGENTS.md`를 읽고, 같은 `.harness` 상태 파일을 사용한다.
- Codex에서 `/harness-setup`으로 upstream portable sync를 먼저 수행한 뒤 필요한 부분만 Claude mirror에 수동 반영한다.

### 4. 둘 다 사용, 양쪽 동시 작업

- 같은 feature에 대해 두 환경이 동시에 `.harness`를 수정하지 않는다.
- 동시에 실행해야 하면 slug를 분리한다.
- progress 파일에 `runtime: codex` 또는 `runtime: claude`를 기록한다.
- 같은 산출물을 수정할 때는 더 최근 파일을 자동 채택하지 않고 diff를 확인한다.

### 5. Codex만 update

- `/harness-setup`은 Codex 포트에서만 자동 portable sync를 수행한다.
- Claude mirror는 자동으로 덮어쓰지 않는다.
- update report의 `NeedsManualPort` 목록을 보고 Claude mirror에 옮길 항목을 별도 결정한다.

## 명령 매핑

| 기능 | Codex | Claude Code |
| --- | --- | --- |
| 기본 실행 | `~/.codex/skills/ecc-command-harness` | `~/.claude/commands/harness.md` |
| 질문형 실행 | `~/.codex/skills/ecc-command-harness-ask` | `~/.claude/commands/harness-ask.md` |
| 설치/갱신 점검 | `~/.codex/skills/ecc-command-harness-setup` | `~/.claude/commands/harness-setup.md` |
| 도움말 | `~/.codex/skills/ecc-command-harness-help` | `~/.claude/commands/harness-help.md` |
| 사양 작성 | `~/.codex/skills/ecc-command-harness-spec` | `~/.claude/commands/harness-spec.md` |
| 리뷰 | `~/.codex/skills/ecc-command-harness-review` | `~/.claude/commands/harness-review.md` |
| 감사 | `~/.codex/skills/ecc-command-harness-audit` | `~/.claude/commands/harness-audit.md` |
| 리서치 | `~/.codex/skills/ecc-command-harness-deep-researcher` | `~/.claude/commands/harness-deep-researcher.md` |
| 고객 테스트 | `~/.codex/skills/ecc-command-harness-customer-user` | `~/.claude/commands/harness-customer-user.md` |
| learning 압축 | `~/.codex/skills/ecc-command-harness-distill` | `~/.claude/commands/harness-distill.md` |

명령 이름은 같게 유지하되 구현 파일 형식은 다르다. Codex는 skill wrapper 디렉터리이고 Claude Code는 command Markdown 파일이다.

## Bridge 규칙

`HARNESS_DUAL_ENV=1` 또는 `--dual-env`로 bootstrap하면 `CLAUDE.md` bridge를 만들 수 있다.

Bridge는 다음만 해야 한다.

1. `AGENTS.md`가 프로젝트 지침 정본임을 명시한다.
2. `.harness` 위치가 Git common dir 기준 메인 repo임을 명시한다.
3. Codex와 Claude Code의 명령 모델 차이를 설명한다.
4. 기존 `CLAUDE.md`가 있으면 덮어쓰지 않고 수동 병합 대상으로 둔다.

Bridge는 별도 프로젝트 규칙을 담는 장소가 아니다. 규칙은 `AGENTS.md`에 둔다.

## Mirror 점검

Codex에서:

```powershell
powershell -ExecutionPolicy Bypass -File ~/.codex/skills/ecc-command-harness-setup/scripts/check-harness-setup.ps1 -CheckMirror
```

Bash 환경에서:

```bash
bash ~/.codex/skills/ecc-command-harness-setup/scripts/check-harness-setup.sh --check-mirror
```

점검 기준:

1. Codex 스킬 폴더와 Claude Code 스킬 폴더의 상대 경로별 파일 존재 여부를 비교한다.
2. 같은 이름의 파일 내용이 다르면 drift로 기록한다.
3. `.version`은 Codex 새 형식과 Claude 옛 형식을 모두 비교 대상으로 삼는다.
4. drift는 자동 수정하지 않는다. diff 검토와 사용자 승인이 먼저다.

## Drift 처리 절차

1. `/harness-setup --dry-run-update` 또는 `sync-codex-harness.ps1` dry-run으로 upstream 차이를 확인한다.
2. 자동 반영 가능한 Codex portable 파일만 먼저 적용한다.
3. `NeedsManualPort` report에서 step, procedure, bootstrap, agent, command 항목을 분리한다.
4. Claude mirror에 필요한 항목이 있으면 Claude command/skill 모델에 맞게 수동 포팅한다.
5. `.version`의 commit만 맞추지 않는다. 실제 파일 diff가 맞아야 한다.
6. 결과를 `.harness/progress/` 또는 update report에 남긴다.

## 금지

- worktree 안에 별도 `.harness`를 만들지 않는다.
- 한 환경의 설치본으로 다른 환경 설치본을 자동 덮어쓰지 않는다.
- legacy command 파일을 Codex slash command 정본으로 취급하지 않는다.
- Claude Code bridge를 `AGENTS.md`보다 우선하는 프로젝트 규칙 파일로 만들지 않는다.
- drift가 있다는 이유만으로 upstream 파일을 무검토 복사하지 않는다.
