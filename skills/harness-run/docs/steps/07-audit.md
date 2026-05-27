# step 7 - audit + 자가 수정 (1차 self + 2차 external — v2)

`harness-engineering-auditor` 가 전체 산출물과 스킬 자체를 부정적으로 검토한다. **v2 부터 1차 self-audit + 2차 external Codex audit 2단 구조** 로 실행. audit 은 통과 전까지 최종 보고 (step 8) 로 넘어가지 않는다.

> v5 본문은 그대로 유지하고 그 위에 1차+2차 wrapper 만 감쌌다. 8 항목 점검 · OWASP ASI06 8-step 안전 가드 · 자가 수정 한도 (산출물 2회 + 스킬 2회) · 5 예외 enum 모두 그대로.

---

## v2 구조 (5 단계 — 7a → 7e)

```
7a. 1차 self-audit (harness-engineering-auditor — Codex)
    - 8 항목 점검 (요구사항·DDD·TDD·숫자·외부 검토·워크플로·재발 방지·§2.5 위반)
    - non-waivable invariant 7개 점검
    - waiver.md 검토
    - 산출: 07-audit/1st-self-audit.md
    ↓
7b. 2차 external audit (codex exec — 외부 verifier)
    - file-list 자동 작성 (07-audit/2nd-external-audit-file-list.md)
    - codex exec --skip-git-repo-check "<프롬프트>" 실행
    - stdout 을 verbatim 으로 07-audit/2nd-external-audit.md 저장
    - 실행 명령·exit code·소요 시간을 07-audit/2nd-external-audit-invocation.md 저장
    - codex 인증 만료 / quota 소진 시 code-review skill 로 자동 fallback (fallback_used 명시)
    ↓
7c. 1차+2차 종합 (harness-engineering-auditor — Codex)
    - 두 결과 표 비교 (합의/이견)
    - 이견이 critical 이면 멈추고 사용자 보고
    - 이견이 medium 이하면 2차 (외부) 의견 우선 (self-review bias 차단)
    - 산출: 07-audit/findings.md (1+2 종합 + 최종 verdict)
    ↓
7d. 자가 수정 (필요 시 — 한도 산출물 2회 + 스킬 2회)
    - OWASP ASI06 8-step 안전 가드 (§ OWASP 가드)
    - 산출: 07-audit/self-correction.md, skill-improvement.md (0회라도 항상 작성)
    ↓
7e. 판정 4단계 (PASS / PASS_WITH_WAIVERS / PARTIAL / FAIL)
    - findings.md 의 최종 Verdict 확정
    - 결정 트리: docs/run-modes.md §3
    - PASS_WITH_WAIVERS · PARTIAL · FAIL 이면 waiver 또는 blocker 요약을 step 8 summary 에 반영
```

---

## 7a. 1차 self-audit (`harness-engineering-auditor` — Codex)

### 호출 전 준비

1. `~/.codex/skills/harness-run/learning/harness-engineering-auditor.md` 를 읽어 prompt 맨 앞에 붙인다 (v2.1 — Codex 최상위 agents 산하 single source of truth).
2. `.harness/` 전체 산출물 경로를 전달한다.
3. 현재 스킬 경로 `~/.codex/skills/harness-run/` 를 전달한다.
4. `07-audit/1st-self-audit.md` 작성 요구를 포함한다 — 양식은 [templates/1st-self-audit.md.tpl](../../templates/1st-self-audit.md.tpl).

### 점검 항목 8가지 (v5 그대로 유지)

1. 요구사항 대조
2. DDD 일관성
3. TDD 규칙 준수
4. 숫자 정합성
5. 외부 검토 종합
6. 워크플로 점검
7. 재발 방지와 스킬 자기 개선
8. 코드 구조 위반 자동 리팩토링 반영 여부

### v2 추가 점검 (1차 단계)

- **non-waivable invariant 7개** 점검표 ([docs/run-modes.md §non-waivable](../run-modes.md#non-waivable-invariant-7개))
- **waiver.md 검토** — 본 회차의 `<step>/waiver.md` 존재 여부 + 각 waiver 의 [run-modes.md §2 인정 게이트](../run-modes.md#2-waiver-체계) 통과 여부

---

## 7b. 2차 external audit (`codex exec` — 외부 verifier)

### 호출 절차 (4단계 — `harness-review` skill 패턴 재사용)

1. **file-list 작성**: [templates/2nd-external-audit-file-list.md.tpl](../../templates/2nd-external-audit-file-list.md.tpl) 를 채워 `07-audit/2nd-external-audit-file-list.md` 로 저장. 설계 reference 9개 + 본 회차 산출물 + step 9 `files-included.md` 의 사용자 코드 변경 파일 등록.
2. **codex 호출**:

```
codex exec --skip-git-repo-check "각 step 의 설계(~/.codex/skills/harness-run/) vs 본 회차 실제 산출물 비교 — 위반/일탈/사유 분석. 회차 폴더: <절대 경로>. 1차 self-audit 결과: <절대 경로 1st-self-audit.md>. 출력 형식: step 별 (Verdict + 부분일탈/위반 + priority + 근거 인용)."
```

3. **stdout 저장**: codex stdout 을 verbatim 으로 `07-audit/2nd-external-audit.md` 에 저장. **절대 요약·재포장 금지**.
4. **invocation 기록**: 실행 명령·exit code·소요 시간·UTC 를 `07-audit/2nd-external-audit-invocation.md` 에 기록.

### fallback (codex 인증 만료 / quota 소진)

| 상황 | exit | 동작 |
|---|---|---|
| codex 인증 실패 | 2 | `code-review` skill 로 자동 fallback. `2nd-external-audit.md` 첫 줄에 `fallback_used: true` + `fallback_reason: codex_auth_failed` 명시 |
| codex quota 소진 | 3 | 동일 (`fallback_reason: codex_quota_exhausted`) |
| 둘 다 실패 | - | step 7 BLOCKED + 예외 ⑤ `SUBAGENT_RUNTIME_BLOCKED` — 사용자에게 보고 + 환경 수정 후 재시도 |

**fake 응답 절대 금지**: codex 호출 실패 시 임의로 audit 통과 결과 작성 금지.

---

## 7c. 1차+2차 종합 (`harness-engineering-auditor` — Codex)

### 절차

1. `07-audit/1st-self-audit.md` 와 `07-audit/2nd-external-audit.md` 둘 다 Read.
2. step 별로 두 verdict 비교 표 작성 ([templates/audit-findings.md.tpl §1차+2차 합의/이견 표](../../templates/audit-findings.md.tpl) 참조).
3. **이견 처리 규칙**:
   - **critical 이견** (예: 1차 PASS / 2차 위반 + High) → 종합 단계 멈춤 + 채팅 1줄 보고 + 사용자 결정 대기. 자동 진행 금지.
   - **medium 이하 이견** → 2차 (외부) 의견 우선 — self-review bias 차단이 본 skill 의 핵심 가치.
   - **합의 항목** → 그대로 처리 (자동 수정 후보).
4. **non-waivable invariant 7개 종합 점검** — 1차 + 2차 양쪽에서 모두 점검 (위반 1개라도 즉시 `FAIL`).
5. **waiver 종합 검토** — 각 waiver 의 인정 여부 종합 (1차 인정 + 2차 인정 = 통과).
6. `07-audit/findings.md` 작성 — 양식은 [templates/audit-findings.md.tpl](../../templates/audit-findings.md.tpl).

---

## 7d. 자가 수정 — OWASP ASI06 8-step 안전 가드 (CRITICAL — v5 그대로)

OWASP Top 10 for Agentic Applications 2026 의 **ASI06 (Memory & Context Poisoning) + ASI03 (Identity & Privilege Abuse)** mitigation 표준 8개를 모두 적용한다. 누락 시 자가 수정 진행 금지.

| # | 가드 | 적용 (cross-platform — 환경 자동 감지) |
|---|---|---|
| 1 | **Version-controlled snapshot (backup)** | Bash: `cp -r ~/.codex/skills/harness-run ~/.codex/skills/.backups/harness-engineering-<UTC>/`<br>PowerShell: `Copy-Item -Recurse -LiteralPath '~/.codex/skills/harness-run' '~/.codex/skills/.backups/harness-engineering-<UTC>'` |
| 2 | **Unified diff 저장** | 우선: `git diff --no-index <old> <new> > 07-audit/skill-diff-<NN>.patch` (git 가용 시 cross-platform).<br>대체 Bash: `diff -u <old> <new>` / PowerShell: `Compare-Object (Get-Content <old>) (Get-Content <new>)` |
| 3 | **Whitelist** | 자동 수정 가능 파일: `docs/steps/*.md`, `templates/*.tpl`, `~/.codex/skills/harness-run/learning/*.md` (skill 외부 최상위 — 학습 누적 파일만) 만. **금지**: `SKILL.md`, `docs/workflow.md`, `docs/code-structure.md`, `docs/run-modes.md`, `~/.codex/skills/harness-run/agents/<name>.md` (skill 외부 최상위 sub-agent 정의 — frontmatter 변경 위험) |
| 4 | **Dry-run** | 수정 전 변경 사항을 `07-audit/skill-improvement.md` 에 *"제안 diff"* 로 먼저 작성 → 메인 Codex 가 검토 후 적용 |
| 5 | **Atomic write** | 메인 Codex 의 Edit/Write 도구 자체가 atomic write 보장. 별도 `.tmp + rename` 불필요. CLI 사용 시 Bash `mv` / PowerShell `Move-Item -LiteralPath` |
| 6 | **자동 rollback (OS-specific, wildcard-free)** | 수정 후 verification 실패 시 backup 으로 복원. Bash: `cp -a ~/.codex/skills/.backups/harness-engineering-<UTC>/. ~/.codex/skills/harness-run/` (점 표기로 hidden 포함 + 권한 보존) / PowerShell: `Get-ChildItem -Force -LiteralPath '<absolute backup path>' \| Copy-Item -Destination '<absolute skill root>' -Recurse -Force` (wildcard 미사용 — `-LiteralPath` 안전) |
| 7 | **Post-modification verification** | 수정 후 SKILL.md 로딩 시뮬레이션 (frontmatter parse + 본문 200줄 컷). 줄수 확인: Bash `wc -l <file>` / PowerShell `(Get-Content <file> \| Measure-Object -Line).Lines`. Cross-link: Bash `grep -r 'docs/steps' ~/.codex/skills/harness-run/` / PowerShell `Get-ChildItem -Recurse -Path '~/.codex/skills/harness-run/' \| Select-String 'docs/steps'` |
| 8 | **Concurrent execution lock** | `~/.codex/skills/harness-run/.audit-lock` 파일 + PID 기록. 다른 audit 인스턴스 동시 실행 차단. (파일 존재 + PID 살아있음 검증은 cross-platform — `Test-Path` / `test -f` 모두 사용 가능) |

### 환경 감지 + 명령 부재 시 BLOCKED

audit 시작 직후 다음을 자동 감지:
- 운영 체제: Windows / Linux / macOS
- 가용 쉘: PowerShell / Bash / 둘 다
- 가용 도구: `git` / `diff` / `Compare-Object`

매핑된 명령 중 **하나라도 실행 불가** 시 **자가 수정 시도 자체를 BLOCKED** + `07-audit/findings.md` 에 `BLOCKED_REASON: skill_modification_tool_unavailable` 기록 + 예외 ⑤ `SUBAGENT_RUNTIME_BLOCKED` 로 사용자에게 보고. **fake 적용 절대 금지.**

### 적용 한도 (v5 그대로)

- 산출물 수정 한도: 2회 (사이클당)
- 스킬 파일 수정 한도: 2회 (사이클당, 위 8 가드 모두 적용)
- audit 이 UX 판단이나 도메인 의미를 임의로 바꾸면 안 된다. 규칙·일관성·구조만 고친다.
- 두 한도 모두 초과 시 사용자 결정 (예외 ④ `AUDIT_LIMIT_EXCEEDED`).

### 기록 의무 (OS-specific — `templates/audit-skill-change-log.md.tpl` 와 동일 계약)

`07-audit/skill-improvement.md` 에 매 수정마다 다음 필드 기록. **Rollback command 는 감지된 OS 에서 실제 실행 가능한 명령만 기록** — Bash-only 또는 PowerShell-only 강제 금지. wildcard-in-LiteralPath 같은 무효 명령은 BLOCKED.

```markdown
## Change #<NN> — <UTC timestamp>

- **Files changed**: <whitelist 범위 내 파일 목록>
- **Backup location**: `~/.codex/skills/.backups/harness-engineering-<timestamp>/`
- **Backup command (실제 실행, OS-specific)**: <verbatim — Bash `cp -a ...` 또는 PowerShell `Copy-Item -Recurse -LiteralPath ...`>
- **Diff path**: `07-audit/skill-diff-<NN>.patch`
- **Diff command (실제 실행)**: <verbatim — git diff / Bash diff / PowerShell Compare-Object 중 환경에 맞는 것>
- **Reason** (finding id 참조): #<audit finding NN>
- **Verification commands**: <실행한 검증 명령 + 결과 PASS/FAIL>
- **Rollback command for detected OS (실제 실행 가능, dry-run 검증됨)**:
  - Linux/macOS: `cp -a ~/.codex/skills/.backups/harness-engineering-<UTC>/. ~/.codex/skills/harness-run/`
  - Windows (PowerShell): `Get-ChildItem -Force -LiteralPath '<absolute backup path>' \| Copy-Item -Destination '<absolute skill root>' -Recurse -Force`
- **Rollback dry-run evidence (mutation 없음 — 실행 가능 검증)**: <verbatim 결과>
- **Status**: APPLIED | ROLLED_BACK | BLOCKED (`BLOCKED_REASON: SKILL_MODIFICATION_TOOL_UNAVAILABLE` 등)
```

### `self-correction.md` · `skill-improvement.md` 항상 작성 (v2 추가)

자가 수정이 **0회라도** 본 회차의 `07-audit/self-correction.md` 와 `07-audit/skill-improvement.md` 를 **반드시** 작성. 비어 있는 경우 다음 한 줄 명시:

```markdown
# Self-correction Log

본 회차에서 자가 수정 0회. 1차+2차 종합 결과 모든 finding 이 자동 수정 후보 아님 또는 waiver 인정.
```

```markdown
# Skill Improvement Log

본 회차에서 skill 파일 수정 0회. 1차+2차 종합 결과 skill 파일 결함 없음 또는 결함은 산출물 단계에서 해결.
```

> "0회" 와 "검토 후 불필요" 구분은 2차 Codex 분석의 명시 권고. 파일 부재 = 검토 안 함으로 간주.

---

## 7e. 판정 4단계 (PASS / PASS_WITH_WAIVERS / PARTIAL / FAIL)

`07-audit/findings.md` 의 최종 Verdict 확정. 결정 트리는 [docs/run-modes.md §3 audit 판정 4단계](../run-modes.md#3-audit-판정-4단계).

| 판정 | 의미 | 다음 동작 |
|---|---|---|
| `PASS` | 모든 강제 항목 통과, waiver 없음 | step 8 진행 |
| `PASS_WITH_WAIVERS` | 모든 강제 또는 명시 waiver, non-waivable 위반 없음 | step 8 진행 + summary 에 waiver 목록 |
| `PARTIAL` | 일부 강제 미통과, 결과는 의미 있음 | step 8 (PARTIAL 명시) + 사용자 확인 후 step 9 |
| `FAIL` | non-waivable invariant 위반 또는 자가 수정 한도 초과 후에도 회복 불가 | step 8 안 함, 자가 수정 → 한도 도달 시 사용자 보고 (예외 ④) |

### 후방 호환 (v5 verdict 매핑)

v5 의 `PASS` / `FAIL` / `BLOCKED` 는 v2 판정 4단계로 매핑된다:
- v5 `PASS` → v2 `PASS` 또는 `PASS_WITH_WAIVERS` (waiver 유무에 따라)
- v5 `FAIL` → v2 `PARTIAL` 또는 `FAIL` (non-waivable 위반 여부에 따라)
- v5 `BLOCKED` → v2 `FAIL` + `BLOCKED_REASON` 명시 (codex 도구 부재 등)

---

## 산출물 (v2 - 7개 파일)

| 파일 | 단계 | 의무 |
|---|---|---|
| `07-audit/1st-self-audit.md` | 7a | 항상 |
| `07-audit/2nd-external-audit-file-list.md` | 7b | 항상 |
| `07-audit/2nd-external-audit.md` | 7b | 항상 (codex stdout verbatim) |
| `07-audit/2nd-external-audit-invocation.md` | 7b | 항상 (실행 명령·exit code) |
| `07-audit/findings.md` | 7c | 항상 (1+2 종합 + 최종 Verdict) |
| `07-audit/self-correction.md` | 7d | 항상 (0회라도) |
| `07-audit/skill-improvement.md` | 7d | 항상 (0회라도) |
| `07-audit/skill-diff-NN.patch` | 7d | 스킬 자가 수정 발생 시 |


## Codex 포팅 추가 — auditor 호출 단순화

Codex 포팅에서는 `harness-engineering-auditor` 정의 파일을 prompt 로 흡수해 단일 `codex exec` 로 1차 self-audit 과 종합을 수행한다. 2차 external audit 은 별도 자식 Codex 호출이며 `2>&1 | tee 07-audit/2nd-external-audit.md` 로 verbatim 보존한다.

스킬 자가 수정 whitelist 는 Codex 경로 기준으로만 허용한다.

- 허용: `~/.codex/skills/harness-run/docs/steps/*.md`, `~/.codex/skills/harness-run/templates/*.tpl`, `~/.codex/skills/harness-run/learning/*.md`
- 금지: `SKILL.md`, `docs/workflow.md`, `docs/code-structure.md`, `docs/run-modes.md`, `agents/<name>.md`
