# Skill Improvement Log

> OWASP ASI06 8-step 안전 가드 적용. 각 change 마다 7 필드 모두 기록.

## Change #001 — <UTC timestamp>

### 1. Files changed (whitelist 범위 내)
| File | Operation | 사유 |
|---|---|---|
| `docs/steps/<file>.md` | edit | <audit finding 참조> |

**Whitelist**: `docs/steps/*.md`, `templates/*.tpl`, `~/.codex/skills/harness-run/learning/*.md` (skill 외부 최상위 — 학습 누적 파일만) 만 수정 가능. `SKILL.md`, `docs/workflow.md`, `docs/code-structure.md`, `docs/run-modes.md`, `~/.codex/skills/harness-run/agents/<name>.md` (skill 외부 최상위 sub-agent 정의) 는 자동 수정 금지.

### 2. Backup location
- 경로: `~/.codex/skills/.backups/harness-engineering-<UTC-timestamp>/`
- 생성 명령 (cross-platform — 환경에 맞는 한 줄 선택, 실행한 명령 verbatim 기록):
  - Bash: `cp -r ~/.codex/skills/harness-run ~/.codex/skills/.backups/harness-engineering-<UTC>/`
  - PowerShell: `Copy-Item -Recurse -LiteralPath '~/.codex/skills/harness-run' '~/.codex/skills/.backups/harness-engineering-<UTC>'`
- 크기: <bytes>

### 3. Diff
- 저장 경로: `07-audit/skill-diff-001.patch`
- 생성 명령 (cross-platform 우선순위):
  - 1순위 (git 가용): `git diff --no-index <old> <new> > 07-audit/skill-diff-001.patch`
  - Bash 대체: `diff -u <old> <new> > 07-audit/skill-diff-001.patch`
  - PowerShell 대체: `Compare-Object (Get-Content <old>) (Get-Content <new>) | Out-File -Encoding utf8 07-audit/skill-diff-001.patch`
- 변경 줄수: +<N> / -<N>

### 4. Triggering audit finding
- ID: #<audit findings.md 항목>
- Severity: CRITICAL | HIGH | MEDIUM | LOW
- 원문:

### 5. Verification (post-modification) — cross-platform
| 검증 | Bash 명령 | PowerShell 명령 | 결과 |
|---|---|---|---|
| SKILL.md frontmatter parse | `head -10 ~/.codex/skills/harness-run/SKILL.md` | `Get-Content ~/.codex/skills/harness-run/SKILL.md -TotalCount 10` | PASS / FAIL |
| 200줄 컷 유효성 | `wc -l <file>` | `(Get-Content <file> \| Measure-Object -Line).Lines` | PASS / FAIL |
| Cross-link 무결성 | `grep -r "docs/steps" ~/.codex/skills/harness-run/` | `Get-ChildItem -Recurse -Path '~/.codex/skills/harness-run/' \| Select-String 'docs/steps'` | PASS / FAIL |
| 기타 smoke test | <명령> | <명령> | PASS / FAIL |

### 6. Rollback (OS-specific — 감지된 환경의 실제 실행 명령만 기록)

**의무**: 본 필드는 *"감지된 OS 에서 실제 실행 가능하고 dry-run 으로 path/권한 검증을 마친 한 줄 명령"* 만 PASS. "예시" 또는 "다른 OS 명령" 기록 시 audit BLOCKED.

| OS | Rollback command (`-LiteralPath` 는 wildcard 미확장 — 백업 root 자체를 복사) |
|---|---|
| **Linux / macOS (Bash)** | `cp -a ~/.codex/skills/.backups/harness-engineering-<UTC>/. ~/.codex/skills/harness-run/` (점 표기로 hidden 포함 + 권한 보존) |
| **Windows (PowerShell)** | `Get-ChildItem -Force -LiteralPath '<absolute backup path>' \| Copy-Item -Destination '<absolute skill root>' -Recurse -Force` (backup 하위 항목을 skill root 로 복사 — wildcard 미사용으로 LiteralPath 안전) |

### 6-1. Rollback dry-run 의무 (PASS 기준 — wildcard-free, mutation 없음)

| OS | dry-run 명령 (반드시 mutation 없음, wildcard-in-LiteralPath 금지) |
|---|---|
| Bash | `diff -rq ~/.codex/skills/.backups/harness-engineering-<UTC>/ ~/.codex/skills/harness-run/ 2>&1 \| head -20` (path 존재 + 차이 확인) 또는 `test -d ~/.codex/skills/.backups/harness-engineering-<UTC>/ && test -d ~/.codex/skills/harness-run/ && echo READY` |
| PowerShell | 3-step validation (wildcard 미사용):<br>1) `Test-Path -LiteralPath '<absolute backup path>'` → 결과 True/False<br>2) `Test-Path -LiteralPath '<absolute skill root>'` → 결과 True/False<br>3) `(Get-ChildItem -Force -LiteralPath '<absolute backup path>').Count` → 0 보다 큰 정수 (child 존재 확인)<br>세 명령 모두 PASS 시 실제 rollback 명령 실행 가능 판정. **`-WhatIf` 와 wildcard 조합 금지** (LiteralPath 는 wildcard 미확장) |

- dry-run 결과 캡처 후 본 entry 에 verbatim 기록.
- 자동 rollback 트리거: verification 단계 어느 하나라도 FAIL → 위 OS 매핑된 실제 명령을 실행 (dry-run 아닌 mutation).
- Rollback 후 본 entry 의 Status 를 `ROLLED_BACK` 으로 갱신.
- 환경에 필요한 명령이 부재 시 (예: PowerShell `Copy-Item` cmdlet 부재 또는 Bash `cp` 부재) → 자가 수정 시도 BLOCKED. fake rollback 적용 금지.

### 7. Status
- `APPLIED` / `ROLLED_BACK` / `BLOCKED` (예: 동시 실행 lock 충돌, OS rollback 명령 미가용)
- Lock 파일 경로: `~/.codex/skills/harness-run/.audit-lock` (PID + UTC timestamp)

### 7-bis. 실행 환경 evidence (Windows 검증 가능 rollback 강제)

**감지된 환경별로 실제 실행한 명령을 verbatim 기록.** "선택 가능한 예시" 가 아니라 **실제 실행 + 결과 캡처** 만 PASS 로 인정. 미실행 시 audit 자가 수정 자체를 BLOCKED.

| 항목 | 값 |
|---|---|
| 감지 OS | Windows / Linux / macOS |
| 감지 쉘 | PowerShell <ver> / Bash <ver> / 둘 다 |
| 가용 도구 | git: yes/no, diff: yes/no, Copy-Item: yes/no |
| **실제 실행한 Backup 명령 (1줄)** | <verbatim> |
| Backup exit code | 0 (성공) / 비-0 (실패 → BLOCKED) |
| **실제 실행한 Diff 명령** | <verbatim> |
| Diff exit code | 0 / 비-0 |
| **실제 실행한 Rollback 명령 (모의 실행 — dry-run 으로 한 번 실행해 경로/권한 검증)** | <verbatim> |
| Rollback dry-run exit code | 0 / 비-0 |

이 4 명령 중 하나라도 실행 실패 또는 도구 부재 시 `Status: BLOCKED` + `BLOCKED_REASON: SKILL_MODIFICATION_TOOL_UNAVAILABLE` + 예외 ⑤ `SUBAGENT_RUNTIME_BLOCKED` 로 사용자에게 보고. **자가 수정 자체를 진행하지 않는다.**

### 8. Remaining risk / follow-up
- <risk>

---

## Change #002 — ...

(반복)
