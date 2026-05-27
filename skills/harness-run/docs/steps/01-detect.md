# step 1 — 언어·프레임워크 감지 + 입력 정리 + 외부 의존성 점검

`/harness` 호출 직후 첫 단계. 사용자가 입력한 자연어 목표를 받아 프로젝트 환경을 자동 감지하고 외부 의존성 위험을 사전 점검한다.

---

## 입력

- 사용자의 자연어 목표 (제한 없음, 한 줄 또는 여러 줄)
- 현재 작업 디렉토리 (프로젝트 루트로 간주)

## 진입 직후 동작 (회차 보존 명확화)

1. **에이전트 presence check (v2.1 — 매 회차 자동 점검)**: `~/.codex/skills/harness-run/agents/` (codex exec 재귀 호출 이 찾는 single source of truth) 에 본 skill 이 의존하는 에이전트 4개 (`harness-engineering-researcher`, `harness-engineering-qa`, `harness-engineering-auditor`, `harness-customer-user`) 가 모두 존재하는지 확인. 없으면 BLOCKED + 사용자 안내 (skill 재설치 권장 — 본 skill 은 single source of truth 정책이라 복사·이동 안 함). 절차 상세는 § 에이전트 presence check.
2. `.harness/` 폴더가 없으면 생성. 이미 있으면 **새 회차 폴더 신설**: `.harness/runs/<UTC-timestamp>-<slug>/` 로 분리 보존. 단계별 산출물은 모두 이 회차 폴더 안에 들어간다. (예: `runs/20260524T144500Z-payment/01-detect/`, `runs/20260524T144500Z-payment/02-domain/` …)
3. 루트의 `README.md` 는 **회차 인덱스 + 최신 회차 요약**만 보유. `log.md` 는 회차 폴더 안에만 둠 (`runs/<UTC>-<slug>/log.md`).
4. 진입 라인 append (회차 폴더의 `log.md`): `[YYYY-MM-DD HH:MM:SS UTC] STEP 1 START`. presence check 결과도 동일 라인 다음에 1줄 기록: `[YYYY-MM-DD HH:MM:SS UTC] AGENT PRESENCE CHECK <found: N / missing: M / required: T>`.
5. 본 문서·하위 step 문서·템플릿의 모든 산출물 경로는 `.harness/<sub>/` 표기를 사용하나, **실제 실행 시 메인 Codex 가 `.harness/runs/<현재 회차>/<sub>/` 로 prefix 를 자동 추가**한다. (간결함을 위한 문서 컨벤션.)

---

## 에이전트 presence check (v2.1 신규 — 매 회차 자동 점검)

### 배경 (v2.1 정책 변경 — single source of truth)

v2.1 부터 본 skill 의 sub-agent 정의는 **`~/.codex/skills/harness-run/agents/<name>.md` 에만 존재** (Codex 의 codex exec 재귀 호출 이 보는 최상위 위치). 이전 v2 의 `skill/agents/<name>.md` 중복본은 제거 — single source of truth 정책. learning 누적 파일도 동일 정책으로 **`~/.codex/skills/harness-run/learning/<name>.md`** 에 보관 (skill 외부 최상위).

이 정책의 결과:
- skill 이 sub-agent 정의를 복사·이동하지 않음 (drift 위험 0)
- step 1 진입 시 단순 *presence check* 만 수행: 필요한 에이전트가 `~/.codex/skills/harness-run/agents/` 에 있는지 확인
- 없으면 BLOCKED — skill 재설치 안내 (skill 자체가 source 를 보유하지 않으므로 자체 복구 불가)

### 필수 에이전트 (v2.1 기준 — 본 skill 직접 의존)

| 에이전트 이름 | 위치 (codex exec 재귀 호출 호출 시 보는 경로) | 호출 단계 |
|---|---|---|
| `harness-engineering-researcher` | `~/.codex/skills/harness-run/agents/harness-engineering-researcher.md` | step 1·2 (외부 리서치 필요 시) |
| `harness-engineering-qa` | `~/.codex/skills/harness-run/agents/harness-engineering-qa.md` | step 4 |
| `harness-engineering-auditor` | `~/.codex/skills/harness-run/agents/harness-engineering-auditor.md` | step 7 |
| `harness-customer-user` | `~/.codex/skills/harness-run/agents/harness-customer-user.md` | step 6 (재사용 — 자매 skill harness 와 공유) |

추가로 자매 skill 이 등록하는 `codex-reviewer` (step 5) 도 `~/.codex/skills/harness-run/agents/` 에 있어야 함 (본 skill 의 직접 책임은 아니나 step 5 실행 가능 여부 확인 차원에서 같이 check).

### 절차 (메인 Codex 가 step 1 진입 즉시 자동 실행)

1. **필수 에이전트 목록 확인**: 위 4개 (필수) + `codex-reviewer` (권장) 의 파일 존재 여부 확인:
   - Bash: `for n in harness-engineering-researcher harness-engineering-qa harness-engineering-auditor harness-customer-user codex-reviewer; do test -f ~/.codex/skills/harness-run/agents/$n.md && echo "found: $n" || echo "missing: $n"; done`
   - PowerShell: `@('harness-engineering-researcher','harness-engineering-qa','harness-engineering-auditor','harness-customer-user','codex-reviewer') | ForEach-Object { @{Name=$_; Found=(Test-Path -LiteralPath "$env:USERPROFILE/.claude/agents/$_.md")} }`
   - Read/Glob 도구: `Glob pattern="C:/Users/NX3GAMES/.claude/agents/harness-engineering-*.md"` + `Glob pattern="C:/Users/NX3GAMES/.claude/agents/harness-customer-user.md"` + `codex-reviewer.md`
2. **frontmatter sanity check**: 발견된 각 파일의 첫 10줄을 Read 해 `name: <expected>` 필드가 파일 이름과 일치하는지 확인. 불일치 시 audit 단계가 별개 finding 으로 처리.
3. **결과 분류**:
   - 필수 4개 모두 found → presence check PASS, step 2 진행
   - 필수 4개 중 하나라도 missing → BLOCKED (예외 ⑤ `SUBAGENT_RUNTIME_BLOCKED`) + 사용자 안내
   - 권장 `codex-reviewer` missing → WARN (BLOCKED 아님 — step 5 진입 직전에 다시 확인, 그때 BLOCKED 가능)

### log.md 기록

회차 폴더의 `log.md` 에 진입 라인 직후 1줄:

```
[YYYY-MM-DD HH:MM:SS UTC] AGENT PRESENCE CHECK <found: N / missing: M / required: T> — researcher:<found|missing>, qa:<found|missing>, auditor:<found|missing>, customer-user:<found|missing>, codex-reviewer:<found|missing|warn>
```

- `required = T` 는 필수 + 권장 합 (현재 v2.1: 4 필수 + 1 권장 = 5)
- `found + missing = required`
- 각 에이전트의 처리 결과를 nm:<found|missing> 형식으로 모두 나열 (회차 추적성)

### 실패 처리 (예외 ⑤ `SUBAGENT_RUNTIME_BLOCKED`)

필수 4개 중 하나라도 missing 시 채팅 BLOCKED 보고:

```
[harness BLOCKED] 필수 sub-agent 누락 — ~/.codex/skills/harness-run/agents/ 에 다음 파일이 없습니다:
- <missing1>.md
- ...

본 skill 은 single source of truth 정책 (v2.1) 으로 sub-agent 정의를 자체 복사하지 않습니다.
복구 방법:
  1. skill 재설치 (권장 — 설치 스크립트가 ~/.codex/skills/harness-run/agents/ 에 4개 파일 등록)
  2. 또는 누락 파일을 git/백업에서 직접 복원

진행하려면 누락 파일 복원 후 /harness 재호출.
```

옵션 (CLI 표준 입력 대기 예외 ⑤):
- A: 사용자가 환경 복원 후 재시도
- B: 작업 종료

**fake 처리 절대 금지** — 필수 에이전트 부재 시 step 2 진행 차단.

### 1회 통보 (질문 아님 — 정상 케이스)

presence check PASS 결과를 채팅 1줄 보고 (간결 — 모두 있을 때만 짧게):

```
[harness] 에이전트 presence check 완료 — found: <N>/<T> (~/.codex/skills/harness-run/agents/ 에 등록 확인).
```

`missing = 0` 이고 `warn = 0` 이면 통보 생략 가능 (조용한 정상 케이스).

### v2.1 마이그레이션 참고 (v2 → v2.1)

v2 에서는 *"skill 내부 agents/ → ~/.codex/skills/harness-run/agents/ 복사 부트스트랩"* 이었다. v2.1 부터:
- skill 내부 `agents/` 폴더 제거
- learning 파일은 `agents/learning/` → `~/.codex/skills/harness-run/learning/` 으로 이동 (skill 외부 최상위)
- 본 단계는 *복사* 가 아닌 *presence check* 만
- skill 외부 single source of truth (`~/.codex/skills/harness-run/agents/`) 에 정의 위임

---

## 1. 자연어 목표 정리 (Codex 단독)

사용자 입력을 받아 다음 항목으로 구조화:

- **goal** — 한 문장 요약
- **scope** — 무엇을 만들/고칠 것인지, 명백히 제외할 것
- **non-functional** — 성능·접근성·보안·기타 요구사항
- **constraints** — 외부 제약 (예: 특정 라이브러리 강제, 기존 코드 유지)
- **open-questions** — Codex 가 추론한 모호한 부분 (자동 결정으로 진행하되 산출물에 명시)

`.harness/01-detect/input.md` 에 저장.

---

## 2. 언어·프레임워크 자동 감지

### 감지 신호 (우선순위 순)

| 신호 | 추정 |
|---|---|
| `package.json` 의 `dependencies` | Node.js — `react` → React, `next` → Next.js, `vue` → Vue, `svelte` → Svelte |
| `pubspec.yaml` | Dart / Flutter |
| `Cargo.toml` | Rust |
| `go.mod` | Go |
| `pom.xml` / `build.gradle` / `build.gradle.kts` | Java / Kotlin (Android/JVM) |
| `*.csproj` / `*.sln` / `Assets/Plugins/` (Unity 표지) | C# / .NET (WPF·Unity 등) |
| `Package.swift` / `*.xcodeproj` | Swift / SwiftUI / UIKit |
| `requirements.txt` / `pyproject.toml` / `Pipfile` | Python — `django` → Django, `fastapi` → FastAPI, `flask` → Flask |
| `composer.json` | PHP / Laravel |
| `Gemfile` | Ruby / Rails |
| 파일 확장자 우세 | 최후 폴백 |

### UI 프로젝트 여부 판정

다음 중 하나라도 발견되면 UI 프로젝트로 간주:
- `*.tsx` / `*.jsx` / `*.vue` / `*.svelte`
- `*.swift` (SwiftUI 코드 — `import SwiftUI`)
- `*.dart` 위젯
- `*.xaml`
- `Assets/` + Unity UI 컴포넌트
- HTML 진입점 (`index.html`)

UI 프로젝트면 [docs/code-structure.md](../code-structure.md) 의 **UI ↔ 기능 분리 규칙** 자동 적용. 아니면 객체 단위 분리만 적용.

### 산출물

`.harness/01-detect/environment.md`:

```markdown
# 감지 결과

- 언어: <감지된 언어>
- 프레임워크: <감지된 프레임워크>
- UI 여부: <true/false>
- UI ↔ 기능 분리 적용: <true/false>
- 코드 컨벤션 참조: 감지된 언어가 C# 일 때는 **반드시** `C:\Users\NX3GAMES\.codex\l9asia-client-coding-conventions.md` 절대 경로를 Read 한 뒤 evidence line `[CSHARP_CONVENTION_READ] <UTC ts> path=<위 경로> bytes=<file size>` 를 environment.md 에 기록한다. 누락 시 audit `MEDIUM` finding.
- 파일 이름 규약: <예: React → MessageInput.tsx + useMessageInput.ts>
```

---

## 3. CQRS + Event Sourcing 풀세트 강제 — 사용자 명시 경고

본 skill 은 **모든 Aggregate 에 CQRS + Event Sourcing 풀세트를 강제 적용**한다. 이는 Microsoft Azure, Vernon, Verraes, Calmops 등 다수 권위 출처의 *"selective adoption"* 권고와 **명백히 충돌**한다.

step 1 종료 직전 채팅에 **반드시** 1회 통보 (질문 아님, 응답 대기 안 함):

```
[harness 경고] 본 skill 은 모든 Aggregate 에 CQRS + Event Sourcing 풀세트를
강제 적용합니다. 산업 권고 (Microsoft, Vernon 등) 는 단순 CRUD·MVP·짧은 lifespan 시스템에는
이 패턴을 권하지 않습니다. 본 skill 의 강제는 학습·감사·일관성 목적입니다.
프로덕션 적용 시 본 skill 산출물의 ADR 섹션을 후속 검토하십시오.
```

이 경고는 `.harness/01-detect/cqrs-es-warning.md` 에도 산출물로 저장.

---

## 3-bis. 회차 유형 (`run-mode`) 자동 감지 (v2)

v2 부터 step 1 종료 직전에 **회차 유형** 을 자동 감지하고 **1회 통보** (질문 아님 — `SKILL.md` CLI 표준 입력 대기 표 외 추가 예외 만들지 않음). 본문 정의는 [docs/run-modes.md](../run-modes.md).

### 감지 휴리스틱 (자동 판정 — 첫 매치 채택)

| 신호 | 판정 |
|---|---|
| 사용자 입력에 `refactor` / `리팩토링` / `cleanup` / `재구조화` / 동작 보존 명시 | `refactor` |
| 사용자 입력에 `feature` / `기능 추가` / `add ...` / `<기존 모듈>에 ...` + 프로젝트에 기존 도메인 모델 산출물 (`.harness/runs/*/02-domain/domain-model.md` 또는 다른 회차) 존재 | `feature-add` |
| 사용자 입력에 `new` / `신규` / `구축` / `from scratch`, 또는 `.harness/` 자체가 비어 있음 (첫 회차) | `new-domain` |
| 판정 불가 (신호 충돌·없음) | `new-domain` 폴백 + `Unknown` 사유 기록 |

### 산출물

`.harness/01-detect/run-mode.md`:

```markdown
# Run Mode

- 감지 결과: <new-domain / feature-add / refactor>
- 근거 (자동 판정 신호): <어떤 키워드·파일 매치>
- DDD 강제: <풀세트 / 해당 Aggregate / adapt 허용 (waiver 필수)>
- TDD 강제: <풀세트 / characterization 허용 (waiver 필수)>
- 커버리지 강제: <80%+ / waiver 허용>
- non-waivable invariant: 7개 항상 강제 (run-modes.md §non-waivable 참조)
- 사용자 변경 안내: 자동 감지가 틀렸다 판단되면 회차 종료 후 변경하지 말고, 다음 회차 시작 시 자연어 목표에 명시 (예: "feature-add 회차로 진행해줘").
```

### 1회 통보 (질문 아님)

`step 1` 종료 직전 채팅 한 줄:

```
[harness] 회차 유형: <감지 결과> — DDD/TDD/커버리지 강제 정도가 다릅니다. 본 회차는 docs/run-modes.md 의 <유형> 정책으로 진행.
```

응답 대기 안 함. 잘못 감지된 경우 사용자는 즉시 회차 중단 후 자연어 목표 명시로 재호출.

---

## 4. 외부 의존성 자동 점검 (CRITICAL — v4 강제)

다음 패턴을 탐색해 외부 의존성 유무를 판정한다:

### 4-1. 탐색 대상

| 의존성 종류 | 탐색 패턴 |
|---|---|
| 외부 API | `axios`·`fetch`·`HttpClient`·`requests`·`Net::HTTP` 호출, `*_API_KEY` 환경변수 |
| 결제 | `stripe`·`toss`·`portone`·`payment` 키워드, `STRIPE_SECRET_KEY` 등 |
| 이메일 | `sendgrid`·`mailgun`·`smtp`, `SMTP_HOST` 등 |
| 외부 DB | `DATABASE_URL`·`MONGODB_URI`·`REDIS_URL` 등 |
| 파일/객체 스토리지 | `AWS_S3`·`gcs`·`azure-blob` 등 |
| 메시지 큐 | `kafka`·`rabbitmq`·`sqs` 등 |
| 인증·OAuth | `google-oauth`·`github-oauth`·`auth0` 등 |
| AI/LLM API | `openai`·`anthropic`·`google-genai` 등 |

### 4-2. production credential·base URL 자동 차단 (정밀 regex)

다음 패턴 발견 시 **즉시 BLOCKED**. 단순 host 패턴이 아닌 정밀 regex 를 사용해 false negative 방지:

| 패턴 (regex) | enum | 차단 사유 |
|---|---|---|
| `sk_live_[A-Za-z0-9]{24,}` / `rk_live_[A-Za-z0-9]{99}` | `STRIPE_LIVE` | Stripe live secret |
| `sk-proj-[A-Za-z0-9_-]{50,}T3BlbkFJ[A-Za-z0-9_-]{50,}` | `OPENAI_PROJECT` | OpenAI project key |
| `\bAKIA[0-9A-Z]{16}\b` / `\bASIA[0-9A-Z]{16}\b` | `AWS_ACCESS_KEY` | AWS access key |
| `ghp_[A-Za-z0-9]{36}` / `gho_[A-Za-z0-9]{36}` / `ghs_` / `ghr_` | `GITHUB_PAT` | GitHub personal/OAuth token |
| `AIza[0-9A-Za-z_-]{35}` | `GOOGLE_API_KEY` | Google API key |
| `xox[baprs]-[A-Za-z0-9-]+` | `SLACK_TOKEN` | Slack bot/user token |
| `sk-ant-(?:admin|api)\d{2}-[A-Za-z0-9_-]{50,}` | `ANTHROPIC_KEY` | Anthropic API key |
| `-----BEGIN [A-Z ]*PRIVATE KEY-----` | `PRIVATE_KEY` | RSA/EC/DSA private key |
| `[A-Z_]+_LIVE_KEY` / `[A-Z_]+_PROD_KEY` | `OTHER` | live/prod key 명명 컨벤션 |
| production env var (regex 는 본 표 밖 fenced block 참조 — 표 escape 위험 회피) | `PROD_ENV_VAR` | production mode 강제 |
| URL 호스트가 **safe-endpoint allowlist 미매치** (아래 표만 통과). 그 외 모든 외부 host 는 production 으로 간주 | `PROD_BASE_URL` | production endpoint — allowlist 기반 deny-by-default |

#### production env var 정확한 regex (Markdown 표 escape 회피 — fenced block 사용)

```regex
(NODE_ENV|APP_ENV|RAILS_ENV|ASPNETCORE_ENVIRONMENT)\s*=\s*['"]?(production|prod|Production)
```

대안 (yaml/.env 다양한 표기 커버):
```regex
^\s*(?:export\s+)?(NODE_ENV|APP_ENV|RAILS_ENV|ASPNETCORE_ENVIRONMENT|DJANGO_SETTINGS_MODULE)\s*[:=]\s*['"]?(?:production|prod|Production|.*\.production)['"]?\s*$
```

step 6 customer 단계도 동일 regex 참조 (중복 정의 금지).

#### Safe-endpoint Allowlist (단일 출처 — step 6 customer 단계도 동일 표 참조)

| 허용 host / 패턴 | 안전 사유 |
|---|---|
| `localhost`, `127.0.0.1`, `0.0.0.0`, `::1` | 로컬만 |
| `*.local` (mDNS) | 로컬 네트워크 |
| `localstack.cloud`, `localhost.localstack.cloud` | LocalStack AWS emulator |
| `*-sandbox.<service>.com`, `sandbox.<service>.com`, `*-sandbox.<service>.io` | vendor-provided sandbox host |
| `*-test.<service>.com`, `test-*.<service>.com` | 명시 test host |
| `*-dev.<service>.com`, `*-staging.<service>.com` | 명시 dev/staging host |
| `127.0.0.1:9099` / `localhost:9099` (Firebase Auth emulator) | Firebase Local Emulator Suite |
| `127.0.0.1:8080` / `localhost:8080` (Firestore emulator) | Firebase Local Emulator Suite |
| `127.0.0.1:9000` / `localhost:9000` (Realtime DB emulator) | Firebase Local Emulator Suite |
| `127.0.0.1:5001` / `localhost:5001` (Functions emulator) | Firebase Local Emulator Suite |
| `<project>-test.firebaseio.com` / `<project>-staging.firebaseio.com` | 명시 test/staging project naming rule만. **일반 `*.firebaseio.com` 또는 `*.firebasedatabase.app` 은 production 으로 간주 → BLOCKED** |
| `mailtrap.io`, `*.mailtrap.io`, `sandbox.smtp.mailtrap.io` | Mailtrap sandbox |
| `ethereal.email`, `smtp.ethereal.email` | Ethereal dev SMTP |
| `mailcatcher.me`, `localhost:1080` | Mailcatcher |
| `stripe.com` API (test mode `sk_test_*` credential 매치 시에만) | Stripe test mode key 가 host mode 결정 |

위 표에 없는 외부 host 는 모두 BLOCKED. step 6 customer 단계도 본 표만 참조 (중복 정의 금지).

### 4-3. BLOCKED 시 동작 (redaction 강제)

1. `.harness/01-detect/blocked-dependencies.md` 에 발견 항목 기록. **redaction 의무** — raw value 절대 기록 금지.
   - 기록 형식 (한 줄): `<파일경로>:<줄번호> <pattern_enum> <SHA256(value)[:8]>`
   - 예: `src/.env:14 STRIPE_LIVE a3f8c91b` (raw `sk_live_...` 는 절대 기록하지 않음)
2. `blocked-dependencies.md` 자체는 step 9 의 `09-commit/files-excluded.md` 에 자동 등록 (커밋 시 제외).
3. 채팅에 BLOCKED 보고 + CLI 표준 입력 대기 (예외 ①). 채팅 출력에도 동일 redaction 적용:

```
[harness BLOCKED] 외부 의존성 production credential·base URL 감지

발견 항목 (raw value 는 SHA256[:8] hash 로 마스킹):
- <파일:줄> <pattern_enum> <hash>
- ...

본 skill 은 Mock 금지 정책이지만 production endpoint 호출은 절대 차단합니다.
계속하려면 sandbox/test 환경으로 전환 후 재호출이 필요합니다.
```

옵션 (CLI 표준 입력 대기):
- A: sandbox/test 환경으로 전환 후 재호출
- B: 작업 종료 (계속 안 함)

production endpoint 를 계속 사용하는 선택지는 없다. 본 skill 은 실 결제·실 발송·실 API 쓰기를 실행하지 않는다.

### 4-4. sandbox/test endpoint 자동 채택

production credential 이 없고 다음 패턴이 발견되면 자동으로 그쪽 사용 결정:

| 패턴 | 채택 |
|---|---|
| `STRIPE_TEST_KEY` / `sk_test_*` | Stripe test mode |
| `SANDBOX_API_URL` / `*.sandbox.<service>.com` | service sandbox |
| Firebase Local Emulator Suite (localhost:9099/8080/9000/5001) 또는 `<project>-test.firebaseio.com` 명시 test naming | Firebase 에뮬레이터·test project |
| `mailtrap` / `mailcatcher` / `ethereal.email` | dev SMTP |
| in-memory DB/저장소 가능 (Sqlite `:memory:`, `fakeredis` 같은 in-memory Redis Fake 등 — Fowler 분류상 Fake 만, verify-behavior 도구는 제외) | in-memory |

### 4-5. 외부 의존성은 있으나 안전 실행 대상이 없을 때

외부 의존성 패턴이 하나라도 발견됐는데 in-memory 구현체, sandbox endpoint, test endpoint 중 어느 것도 확인할 수 없으면 **BLOCKED** 로 종료한다. 실제 인프라 호출로 대체하지 않는다.

산출물:

`.harness/01-detect/blocked-dependencies.md`

```markdown
# BLOCKED - 안전 실행 대상 없음

- 발견된 외부 의존성:
- in-memory 가능 여부:
- sandbox/test endpoint 확인 결과:
- 재호출 조건: sandbox/test 환경 또는 in-memory 구현체 준비
```

### 4-6. 외부 의존성이 없을 때

외부 의존성 패턴이 하나도 발견되지 않은 경우에만 **외부 의존성 없는 프로젝트** 로 판정하고 step 2 로 진행한다.

### 4-7. `external-dependencies.md` 산출 (v2 의무 — non-waivable invariant)

탐색 결과는 **항상** `.harness/01-detect/external-dependencies.md` 로 작성한다 (외부 의존성 0건이어도 빈 표로 명시). 본 파일이 없으면 step 7 audit 가 자동 `FAIL` (run-modes.md §non-waivable invariant #7). 양식은 [templates/external-dependencies.md.tpl](../../templates/external-dependencies.md.tpl).

핵심 컬럼:

| category | found | changed_in_this_run | sandbox_available | blocked | redacted_value |
|---|---|---|---|---|---|

- `found = no` 도 명시 — *"변경 없음"* 과 *"의존성 없음"* 을 구분하기 위함 (Codex 2차 분석 권고).
- `blocked = yes` 인 항목은 step 1 4-3 의 redaction 의무 그대로 (`SHA256(value)[:8]`).
- 검색에 사용한 실제 명령 (rg pattern·glob·실행 위치) 도 본 파일 부록에 verbatim 기록.

---

## 5. step 1 종료 조건

다음이 모두 충족되어야 step 2 로 진입:

- [ ] 에이전트 presence check 완료 — `~/.codex/skills/harness-run/agents/` 에 필수 4개 sub-agent 등록 확인 + `log.md` 에 `AGENT PRESENCE CHECK` 라인 기록 (v2.1)
- [ ] `01-detect/input.md` 작성 완료
- [ ] `01-detect/environment.md` 작성 완료
- [ ] `01-detect/cqrs-es-warning.md` 작성 완료 + 채팅 통보 1회
- [ ] `01-detect/run-mode.md` 작성 완료 + 1회 통보 (v2)
- [ ] `01-detect/external-dependencies.md` 작성 완료 — 0건이어도 빈 표 명시 (v2, non-waivable invariant)
- [ ] 외부 의존성 점검 완료. BLOCKED 발생 시 사용자 결정 완료
- [ ] `log.md` 에 step 1 종료 라인 append

step 2 진입 시 현재 회차 폴더의 log.md (`runs/<run-id>/log.md`) 끝에 `[YYYY-MM-DD HH:MM:SS UTC] STEP 1 END / STEP 2 START` append. **루트 `.harness/log.md` 는 사용하지 않는다** — log 는 회차 폴더 안에만.

---

## 6. 외부 정보가 필요할 때

step 1 진행 중 *"이 프레임워크의 표준 폴더 구조는?"*, *"이 라이브러리의 test mode endpoint URL은?"* 같은 외부 사실 확인이 필요하면 codex exec 재귀 호출 의 `agent=harness-engineering-researcher` 로 호출 (`~/.codex/skills/harness-run/agents/harness-engineering-researcher.md` — v2.1 single source of truth). researcher 는 learning 파일 없이 매번 신선 리서치를 수행한다.
