# Step 6: QA

## 목표

구현이 실제 실행 환경에서 동작하는지 검증한다.

## 절차

1. 테스트 가이드를 작성 또는 갱신한다.
2. Step 5 리뷰 파일을 확인한다.
3. 사용 가능한 검증 명령, dev server, URL, 브라우저 도구를 확인한다.
4. 핵심 사용자 흐름과 회귀 위험을 실제로 실행한다.
5. 로그, 스크린샷, 명령 출력 등 증거를 남긴다.
6. `.harness/results/qa-<slug>.md`에 결과를 기록한다.
7. Step 7 또는 Complete 진입 전 `validate-runtime-gate.ps1`를 실행한다.

## 입력 게이트

- `.harness/reviews/review-<slug>.md`가 있어야 한다.
- 리뷰 파일에는 명시적 `LGTM: YES`가 있어야 한다.
- `external_review: unavailable` 상태의 self-review `LGTM: YES`는 승인으로 보지 않는다.
- `.harness/test-guide-<slug>.md`가 없으면 먼저 작성하거나, QA 파일에 `Blocked reason: GUIDE_MISSING`을 기록한다.

## 의존성 사전 점검

도우미 호출 또는 테스트 실행 전에 아래를 확인한다.

- 실행 명령 또는 dev server 명령이 있는가?
- UI 검증이 필요하면 브라우저 도구, Playwright, 기존 E2E 중 하나가 가능한가?
- 계정, 권한, 외부 서비스, 네트워크가 필요한가?
- 필요한 산출물 경로가 Git common dir 기준 `.harness` 아래에 있는가?

검증 수단이 모두 없으면 테스트를 시도한 척하지 말고 `Verdict: BLOCKED`, `Blocked reason: DEPENDENCY_MISSING` 또는 `ENV_UNREACHABLE`을 쓴다. 이 경우에도 Step 6의 자동 결정 분기(재시도 1회, slug 분기, 동일 사유 5회 예외)를 따른다.

## Learning Prepend 게이트

`harness-qa-engineer` helper를 사용할 때는 호출자 Codex가 먼저 `agents/learning/harness-qa-engineer.md`를 읽고 helper 입력 첫 200줄 안에 아래 헤더를 넣는다.

```md
## Prior Learning (READ FIRST): harness-qa-engineer
```

헤더와 learning 요약 없이 나온 helper 결과는 QA 판정 근거로 쓰지 않는다.

## 테스트 가이드 최소 항목

- Environment: OS, 실행 명령, URL, 계정/권한 필요 여부
- Scope: 반드시 확인할 사용자 흐름
- Regression: 깨지면 안 되는 기존 동작
- Oracle: 기대 결과를 어떻게 판정할지
- Evidence: 저장할 로그, 스크린샷, 명령 출력
- Learning Prepend: helper learning 사용 여부

## 도구 선택 순서

1. 프로젝트에 이미 있는 unit/integration/E2E 명령
2. Codex 브라우저 도구
3. 로컬 Playwright 또는 기존 E2E 스크립트
4. CLI 기반 smoke test
5. 도구가 없으면 `BLOCKED` 또는 `UNKNOWN`

## 결과 기록 형식

```md
## QA Round <n>
- Verdict: PASS | FAIL | BLOCKED | UNKNOWN
- Blocked reason: DEPENDENCY_MISSING | EVIDENCE_GATE_FAIL | PERMISSION_DENIED | GUIDE_MISSING | ENV_UNREACHABLE | OTHER | none
- Scope: <검증 범위>
- Environment: <OS, command, URL, account/permission>
- Commands: <실행한 명령>
- Screens: <스크린샷 경로 또는 없음>
- Logs: <중요 로그>
- Evidence: <명령 출력, 로그, 스크린샷, 테스트 리포트>
- Coverage: <확인한 핵심 흐름과 회귀 범위>
- Regression: <회귀 확인 결과>
- Remaining Unknowns: <없음 또는 미확인 항목>
- Failures: <재현 절차>
- Learning Prepend: yes | not-used
- Next: <수정 또는 재검증>
```

위 필드는 Step 6 결정 보고의 필수 필드다. `validate-runtime-gate.ps1`는 모든 필수 필드와 `Learning Prepend`를 검사한다.

위 블록의 모든 라인은 결정 보고 필드다. `Screens`, `Logs`, `Failures`가 해당 없음이면 `없음` 또는 `n/a`로 명시한다.

## 산출물 3축 게이트

`PASS`는 아래 3축이 모두 충족될 때만 쓴다.

- Evidence axis: 명령 출력, 로그, 스크린샷, 테스트 리포트 중 하나 이상이 실제로 있다.
- Coverage axis: Step 3 검증 계획의 핵심 흐름과 회귀 항목이 확인되었다.
- Return axis: Step 5에서 넘어온 finding 또는 회송 결함이 재검증되었다.

하나라도 빠지면 `PASS`가 아니라 `UNKNOWN`, `FAIL`, 또는 `BLOCKED`다.

`PASS`에서 아래 값은 증거로 인정하지 않는다.

- `Commands: not run`, `not executed`, `none`, `없음`
- `Evidence: pass`, `ok`, `yes`, `n/a`, `없음`
- `Coverage: assumed`, `추정`, `unknown`
- `Screens`와 `Logs`가 모두 `n/a` 또는 `없음`인데 `Evidence`가 짧은 한 줄뿐인 경우

## 판정

- `PASS`: 핵심 흐름을 실제로 검증했고 막는 문제가 없다.
- `FAIL`: 재현 가능한 문제가 있다.
- `BLOCKED`: 환경/계정/명령/의존성 때문에 검증할 수 없다.
- `UNKNOWN`: 일부 검증했지만 판정 증거가 부족하다.

## BLOCKED reason enum

`BLOCKED`일 때는 아래 중 하나를 `Blocked reason`으로 쓴다.

- `DEPENDENCY_MISSING`
- `EVIDENCE_GATE_FAIL`
- `PERMISSION_DENIED`
- `GUIDE_MISSING`
- `ENV_UNREACHABLE`
- `OTHER`

계정이 없어 앱에 접근하지 못하는 경우도 별도 enum을 만들지 않고 `PERMISSION_DENIED` 또는 `ENV_UNREACHABLE`로 기록한다.

## self-PASS 방지

같은 Codex 세션이 구현한 내용을 같은 세션이 검증할 수는 있지만, 증거 없는 자기 확신을 `PASS`로 쓰지 않는다.

- 명령 출력, 로그, 스크린샷, 브라우저 검증, 테스트 리포트 중 하나 이상이 있어야 `PASS`다.
- UI 변경인데 화면을 확인하지 못했으면 `UNKNOWN` 또는 `BLOCKED`다.
- 핵심 사용자 흐름을 실행하지 못했으면 Complete로 넘기지 않는다.
- 일부만 확인했으면 확인한 범위와 미확인 범위를 분리한다.
- helper 호출 0회, 도구 실행 0회, 수동 추측만 있는 `PASS`는 자동으로 `UNKNOWN`으로 낮춘다.

## noask BLOCKED 자동 분기

`/harness`에서는 단발 차단 상황을 바로 질문으로 해결하지 않는다. 원본 Harness와 동일하게 아래 순서로 처리한다.

1. 첫 `BLOCKED` 발생 시 원인 enum을 확정하고 같은 조건에서 자동 재시도 1회를 수행한다.
2. 재시도 성공 시 해당 회차를 `PASS` 또는 실제 판정으로 기록하고 진행한다.
3. 재시도도 `BLOCKED`이면 slug 큐를 확인한다.
4. 다중 slug 모드이면 현재 slug를 `paused-by-blocked`로 표시하고 다음 slug를 시작한다.
5. 단일 slug 모드이면 워크플로를 중단하고 stop report에 차단 사유와 재개 조건을 쓴다.
6. 같은 `Blocked reason` enum이 5회 누적된 경우에만 noask 예외로 사용자에게 A/B/C를 묻는다.

동일 사유 5회 누적 시 선택지는 다음 세 가지뿐이다.

- A: 환경 수정 후 재시도
- B: 사용자 명시 동의 스킵
- C: 워크플로 중단

## 재진입 규칙

- 기능 버그는 Step 4로 돌린다.
- 테스트 가이드가 부족하면 Step 3로 돌려 검증 계획을 보강한다.
- 환경만 문제면 `BLOCKED`로 멈추고 재개 조건을 적는다.
- 화면을 보지 못한 UI 항목은 PASS 처리하지 않는다.

## Loop Counter

`FAIL`과 `BLOCKED`는 별도 카운터로 누적한다.

- `FAIL:<DEFECT_ENUM:file-or-area>=<count>`
- `BLOCKED:<Blocked reason:file-or-area>=<count>`

같은 `FAIL` 라벨 5회 반복은 Step 3로 되돌려 계획을 다시 쓴다. 같은 `BLOCKED` 사유가 5회 반복되면 noask 예외 질문을 사용한다. 사용자가 C를 선택하거나 단일 slug 재시도 실패 상태이면 stop report를 쓰고 멈춘다.

## Worktree 처리

Codex worktree에서 실행 중이어도 `.harness`는 worktree 안이 아니라 Git common dir 부모 기준 메인 repo root에 둔다. QA 결과 파일도 `$HARNESS_PROJECT_DIR/.harness/results/qa-<slug>.md`에 저장한다.

## Chunk QA

Chunk 모드에서는 `chunk <n>`의 성공 기준만 검증한다.

- 각 chunk는 별도 QA round를 가진다.
- 이전 chunk의 PASS를 다음 chunk의 PASS로 재사용하지 않는다.
- chunk별 QA가 모두 PASS가 아니면 Complete로 가지 않는다.

## 완료 조건

- 실행한 명령과 결과가 있다.
- 화면 검증이 필요한 경우 실제 화면 근거가 있다.
- PASS가 아닌 경우 다음 조치가 명확하다.
- `validate-runtime-gate.ps1 -NextStep Step7`이 FAIL이 아니다.
