# 2nd External Audit — File List for `codex exec`

> v2 audit 강화의 2차 단계 입력. `07-audit/2nd-external-audit-file-list.md` 로 저장.
> `harness-engineering-auditor` 가 본 파일을 작성한 직후 `codex exec --skip-git-repo-check` 한 줄 프롬프트로 호출 → 결과는 `07-audit/2nd-external-audit.md` (raw) 로 저장.

---

## 회차 컨텍스트

- 회차 ID: `<UTC-timestamp>-<slug>`
- run-mode: <new-domain / feature-add / refactor>
- 2차 audit UTC: <YYYY-MM-DD HH:MM:SS UTC>
- codex 호출 wrapper: `harness-engineering-auditor` (또는 fallback 시 `code-review` skill)

---

## codex exec 한 줄 프롬프트 (verbatim — 실 호출 명령)

```
codex exec --skip-git-repo-check "각 step 의 설계(harness-engineering-plan-FINAL.md 또는 ~/.codex/skills/harness-run/) vs 본 회차 실제 산출물 비교 — 위반/일탈/사유 분석. 회차 폴더: <절대 경로>. 1차 self-audit 결과: <절대 경로>. 출력 형식: step 별 (Verdict + 부분일탈/위반 + priority + 근거 인용)."
```

> 본 프롬프트의 `<절대 경로>` 는 실제 회차 폴더 절대 경로로 치환. fallback 시 `code-review` skill 의 4단계 절차로 자동 치환.

---

## 입력 파일 목록 (codex 가 읽을 대상)

### 1. 설계 reference (절대 경로)

- `~/.codex/skills/harness-run/SKILL.md`
- `~/.codex/skills/harness-run/docs/workflow.md`
- `~/.codex/skills/harness-run/docs/run-modes.md`
- `~/.codex/skills/harness-run/docs/code-structure.md`
- `~/.codex/skills/harness-run/docs/steps/01-detect.md` ~ `09-commit.md` (9개)

### 2. 본 회차 산출물 (절대 경로 — 자동 등록)

- `.harness/runs/<run-id>/01-detect/` 하위 전체
- `.harness/runs/<run-id>/02-domain/` 하위 전체
- `.harness/runs/<run-id>/03-aggregate-*/` 하위 전체 (또는 `03-characterization/`)
- `.harness/runs/<run-id>/04-qa/` 하위 전체
- `.harness/runs/<run-id>/05-review/` 하위 전체
- `.harness/runs/<run-id>/06-customer/` 하위 전체
- `.harness/runs/<run-id>/07-audit/1st-self-audit.md` (1차 결과 — 2차가 참고)
- `.harness/runs/<run-id>/log.md`

### 3. 사용자 프로젝트 변경 파일 (step 9 `files-included.md` 기준)

- <파일1>
- <파일2>
- ...

> `.harness/runs/<run-id>/07-audit/2nd-external-audit.md` (codex 출력 raw) 와 `07-audit/findings.md` (1+2 종합) 는 본 file-list 에 포함하지 않음 (아직 작성 전).

---

## codex 호출 절차 (4단계 — `harness-review` skill 패턴 재사용)

1. 본 file-list 파일 작성 (`07-audit/2nd-external-audit-file-list.md`)
2. `codex exec --skip-git-repo-check "<프롬프트>"` 실행. stdout 캡처.
3. stdout 을 verbatim 으로 `07-audit/2nd-external-audit.md` 에 저장 (절대 요약·재포장 금지).
4. `07-audit/2nd-external-audit-invocation.md` 에 실행 명령·exit code·소요 시간·UTC 기록.

---

## fallback 정책 (codex 인증 만료 / quota 소진)

- codex exit 2 (인증 실패) → `harness-review` skill 의 fallback 정책 그대로: `code-review` skill 로 자동 fallback
- codex exit 3 (quota 소진) → 동일
- fallback 시 `07-audit/2nd-external-audit.md` 첫 줄에 `fallback_used: true` + `fallback_reason: <exit code>` 명시
- 둘 다 실패 시 step 7 BLOCKED + 예외 ⑤ `SUBAGENT_RUNTIME_BLOCKED`

---

## 출력 산출물 (codex 호출 후 자동 생성)

| 파일 | 내용 |
|---|---|
| `07-audit/2nd-external-audit.md` | codex stdout raw (절대 가공 금지) |
| `07-audit/2nd-external-audit-invocation.md` | 실행 명령 + exit code + 소요 시간 |
| `07-audit/findings.md` | 1차+2차 종합 + 최종 verdict 4단계 (별도 단계) |
