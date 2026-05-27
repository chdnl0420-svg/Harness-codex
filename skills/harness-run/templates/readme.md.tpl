# harness — 회차 인덱스

> 루트 `.harness/README.md` 는 **회차 인덱스 + 최신 회차 요약** 만 보유한다. 모든 실제 산출물은 `runs/<run-id>/...` 아래에 들어간다.

## 최신 회차 ({{run_id}})

- **회차 ID**: `{{run_id}}`
- **자연어 목표**: {{goal_first_line}}
- **현재 단계**: step {{current_step}}
- **언어·프레임워크**: {{language_framework}}
- **판정 (latest)**: PASS / FAIL / BLOCKED / IN_PROGRESS
- **Commit hash**: `<commit hash: pending — git log -1 --format=%h 로 확인>` ← step 9 는 README 와 status.md 모두 commit 이후 수정하지 않음. 실제 SHA·시각은 `git log -1` 로만 확인 (산출물 파일에 기록되지 않음 — no-post-commit-mutation 계약).

### 최신 회차 산출물 빠른 링크

| 파일 | 위치 |
|---|---|
| Summary (Markdown) | [`runs/{{run_id}}/summary.md`](runs/{{run_id}}/summary.md) |
| Summary (HTML, html-document-rules.md 준수) | [`runs/{{run_id}}/summary.html`](runs/{{run_id}}/summary.html) |
| 진행 로그 | [`runs/{{run_id}}/log.md`](runs/{{run_id}}/log.md) |
| QA 결과 | [`runs/{{run_id}}/04-qa/`](runs/{{run_id}}/04-qa/) |
| Codex Review | [`runs/{{run_id}}/05-review/`](runs/{{run_id}}/05-review/) |
| Customer Test | [`runs/{{run_id}}/06-customer/`](runs/{{run_id}}/06-customer/) |
| Audit findings + 자가 수정 + 스킬 자기 개선 | [`runs/{{run_id}}/07-audit/`](runs/{{run_id}}/07-audit/) |
| Commit readiness (pre-commit) — 포함·제외·메시지·`READY_TO_COMMIT` | [`runs/{{run_id}}/09-commit/status.md`](runs/{{run_id}}/09-commit/status.md) |
| 실제 commit SHA·시각 | `git log -1 --format='%h %ai'` (산출물 파일에 기록되지 않음) |

## 회차 인덱스 (역시간순)

| 회차 ID | 자연어 목표 | 판정 | 시작 (UTC) | Summary |
|---|---|---|---|---|
| `{{run_id}}` | {{goal_first_line}} | <verdict> | <UTC ts> | [`runs/{{run_id}}/summary.md`](runs/{{run_id}}/summary.md) |
| `<prev-run-id>` | <prev goal> | <verdict> | <UTC ts> | [`runs/<prev-run-id>/summary.md`](runs/<prev-run-id>/summary.md) |

## 관련 글로벌 정책 (skill 정의)

- Skill 정의: `~/.codex/skills/harness-run/SKILL.md`
- HTML 규칙: `C:\Users\NX3GAMES\.codex\html-document-rules.md`
- 보안 룰: `~/.codex/rules/common/security.md`
- 코딩 스타일: `~/.codex/rules/common/coding-style.md`
- L9ASIA C# 컨벤션 (C# 프로젝트만): `C:\Users\NX3GAMES\.codex\l9asia-client-coding-conventions.md`

## 사용 안내

- 본 README 는 회차 인덱스 전용. 회차별 상세는 `runs/<run-id>/summary.md` 참조 (per-run README 는 두지 않음 — summary.md 가 단일 진입점).
- 새 회차는 `/harness <자연어 목표>` 슬래시 호출로 시작.
- 본 README 의 회차 row 는 step 8 이 추가. **step 9 는 본 파일을 수정하지 않음** — commit 결과는 `git log -1` 로 확인 (산출물 파일에 기록되지 않음 — no-post-commit-mutation 계약).
(per-run 안내 통합됨 — 위 문단 참조)
