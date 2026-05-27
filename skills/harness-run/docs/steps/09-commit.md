# step 9 - 커밋

최종 단계는 git 커밋이다. 푸쉬는 절대 하지 않는다.

## 절차

**경로 컨벤션**: 본 step 의 모든 산출물 쓰기는 `.harness/runs/<run-id>/09-commit/` 아래로 들어간다. 짧은 표기 `09-commit/...` 는 메인 Codex 가 자동으로 run prefix 추가 (step 1 참조). git 저장소 여부와 무관.

1. 프로젝트가 git 저장소인지 확인한다 (`git rev-parse --is-inside-work-tree`).
2. git 저장소가 아니면 `runs/<run-id>/09-commit/status.md` 에 `SKIPPED: not a git repository` 를 기록하고 종료.
3. 변경 파일 목록을 만든다 (`git status --short` + untracked 포함).
4. 민감 파일 자동 제외 (§ 민감 파일 제외) + `.harness/` 내부 산출물 secret scan 1차 실행 (§ 산출물 secret scan).
5. summary 기반 자연어 커밋 메시지를 작성해 `runs/<run-id>/09-commit/commit-message.md` 에 기록한다 (§ 커밋 메시지).
6. 커밋 직전 `runs/<id>/09-commit/status.md` 에 커밋 대상·제외 대상·메시지·현재 상태(`READY_TO_COMMIT`) **+ 라인 `COMMITTED_SHA: <PENDING — git log -1 --format=%H 로 확인 가능>`** 을 기록한다. **`runs/<id>/summary.md` 와 `runs/<id>/summary.html` 과 루트 `README.md` 는 step 8 이후 수정 금지** — step 9 가 추가하는 정보는 `runs/<id>/09-commit/status.md` 와 `runs/<id>/09-commit/commit-message.md` 에만 기록한다 (step 8/9 순서 모순 해결).
7. 사용자 프로젝트 코드와 `.harness/` 산출물을 **한 번의 atomic commit** 으로 만든다 — `status.md` 가 `READY_TO_COMMIT` + `COMMITTED_SHA: <PENDING>` 상태로 commit 에 포함된다.
8. **push 하지 않는다.**
9. **commit 직후 산출물 추가 mutation 절대 금지** (working tree 가 dirty 상태로 남음). 실제 git SHA 는 `git log -1 --format=%H` 로 누구나 확인 가능 — status.md 에 다시 쓰면 다음 commit 이 필요해지므로 의도적으로 안 함. 채팅 한 줄 보고: `[harness] step 9 완료 — git SHA: <git log 로 캡처한 값>. push 는 사람이 직접.`

## 민감 파일 제외 (확장된 차단 목록)

다음은 커밋 대상에서 자동 제외한다.

**파일명 패턴 (산업 표준 + harness 확장):**
- `.env` / `.env.*` (`.env.local`, `.env.production`, ...)
- `credentials*` / `secrets*` / `secrets.json` / `secret.*`
- `*.pem` / `*.key` / `*.pfx` / `*.p12` / `*.kdbx` / `*.crt`
- `id_rsa*` / `id_ecdsa*` / `id_ed25519*` / `*.ppk`
- `.npmrc` / `.pypirc` / `.netrc` / `.dockercfg` / `.docker/config.json`
- `*service-account*.json` / `*serviceaccount*.json` (GCP)
- `appsettings.*.json` (`.NET` 환경별, Production·Development·Staging 모두)
- `local.settings.json` (Azure Functions)
- `firebase-debug.log` / `*.har` (네트워크 캡처)
- `kubeconfig` / `*.kubeconfig` / `~/.kube/config`
- `~/.aws/credentials` / `~/.aws/config` (스캔 대상 — 사용자 home 까지는 보통 안 닿지만 명시)
- `*.token` / `token*.json` / `.token-cache.*` (OAuth/JWT token cache)
- credential cache: `.azure/`, `.gcloud/`, `.cache/` 내부 credential files
- 비디오·녹화: `*.mp4` / `*.webm` / `*.mov` (UI screen recording, customer test 산출물 가능)

**산출물 폴더 내 자동 제외 (run-aware recursive glob — 모든 회차 폴더 포함):**
- `.harness/**/01-detect/blocked-dependencies.md` (모든 회차의 BLOCKED 보고서)
- `.harness/**/06-customer/screenshots/**` (모든 회차의 스크린샷, 실 데이터·UI 캡처 가능)
- `.harness/**/06-customer/**/*.har` (모든 회차의 HAR 네트워크 캡처)
- `.harness/**/*.log` (모든 회차의 로그, customer/qa 단계 산출물 포함 가능)
- `.harness/**/runs/*/blocked-dependencies.md` (구 폴더 구조 호환)

**중요**: 산출물 폴더 구조 (`runs/<id>/...`) 변화와 무관하게 `**` 재귀 glob 사용. `files-excluded.md` 기록은 **실제 resolved path** (예: `.harness/runs/20260524T144500Z-payment/06-customer/screenshots/login.png`) 기준으로 남긴다.

**내용 패턴 매치 시 제외:**
secret scan 으로 다음 regex 중 하나라도 매치되는 파일은 자동 제외 + `09-commit/files-excluded.md` 에 사유 redaction 으로 기록.
- `sk_live_[A-Za-z0-9]{24,}` / `rk_live_[A-Za-z0-9]{99}` (Stripe)
- `sk-proj-[A-Za-z0-9_-]{50,}T3BlbkFJ` (OpenAI)
- `\bAKIA[0-9A-Z]{16}\b` / `\bASIA[0-9A-Z]{16}\b` (AWS)
- `ghp_[A-Za-z0-9]{36}` / `gho_` / `ghs_` / `ghr_` (GitHub)
- `AIza[0-9A-Za-z_-]{35}` (Google)
- `xox[baprs]-[A-Za-z0-9-]+` (Slack)
- `sk-ant-(?:admin|api)\d{2}-[A-Za-z0-9_-]{50,}` (Anthropic)
- `-----BEGIN [A-Z ]*PRIVATE KEY-----` (RSA/EC/DSA)

`files-excluded.md` 기록 형식: `<파일> <pattern_enum> <SHA256(value)[:8]>` — raw value 절대 금지.

## 산출물 secret scan

step 9 절차 4 단계에서 `.harness/` 내부 모든 파일에 위 regex 를 1회 실행. 매치 발생 시 다음 분기:

- 산출물 파일 → 자동 제외 + `files-excluded.md` 등록
- **사용자 프로젝트 코드 파일** → 작업 BLOCKED + `status.md` 에 `BLOCKED: secret_in_source` 기록 + 사용자에게 보고. 자동 커밋 중단 (사용자가 해당 secret 제거 또는 git filter 후 재호출).

## 산출물

| 파일 | 내용 |
|---|---|
| `09-commit/commit-message.md` | 사용한 커밋 메시지 |
| `09-commit/files-included.md` | 커밋 포함 파일 |
| `09-commit/files-excluded.md` | 제외 파일과 이유 |
| `09-commit/status.md` | `SKIPPED: not a git repository` (git 없음) / `READY_TO_COMMIT` + `COMMITTED_SHA: <PENDING>` (commit 직전, commit 에 포함됨) / `BLOCKED: <reason>` (실패 사유). commit 직후 추가 mutation 없음 — 실제 SHA 는 `git log -1` 로 확인. |

## 실패 처리

커밋 성공 후에는 파일을 다시 수정하지 않는다. 성공 여부는 채팅 최종 보고와 git 명령 결과로 보고한다. 커밋 실패 시에만 `status.md` 와 `log.md` 에 원인을 기록하고 사용자에게 보고한다. push 실패 처리는 없다. 이 skill 은 push 를 시도하지 않는다.
