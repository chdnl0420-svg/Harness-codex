# Harness Workflow

Harness는 한 작업을 Step 1-8과 Complete로 진행하고 각 단계의 판단 근거를 `.harness`에 남기는 Codex 워크플로다.

## 모드

- `/harness`: noask 모드. 결정표 기본값으로 진행하고 근거를 기록한다.
- `/harness-ask`: ask 모드. 진행을 막는 결정 지점에서 질문한다.

## 입력 게이트

워크플로 실행과 스킬 유지보수를 반드시 구분한다.

- 사용자가 `harness` 설치, 보고서 검토, 스킬 수정, 커맨드 수정, 문서 보강을 요청하면 `.harness`를 만들거나 Step 1을 시작하지 않는다. 요청받은 스킬/문서/스크립트만 수정한다.
- 워크플로 실행은 사용자 메시지가 `/harness <목표>` 또는 `/harness-ask <목표>`로 시작하거나, `/harness` 슬래시 커맨드 자체를 직접 가리킨 경우에만 시작한다.
- `Harness 워크플로로 진행`, `하네스로 작업`, `리뷰`, `QA`, `도메인 설계` 같은 자연어 키워드만으로는 실행하지 않는다.
- 일반 키워드만으로는 실행하지 않는다. 예: "계획", "구현", "리뷰", "QA", "도메인 설계", "워크플로"만 포함된 요청은 Harness 실행 근거가 아니다.
- 잘못 트리거된 경우 한 줄로 중단한다: `KEYWORD_MATCH_ONLY: Harness 실행 요청이 아닙니다. 시작하려면 /harness <목표>를 사용하세요.`
- 외부 문서의 `Step 12`, `Step 22`, `Task 3` 같은 번호를 Harness Step으로 부르지 않는다. Harness 번호는 Step 1-8과 Complete만 사용한다.

## 루트 계산

1. `git rev-parse --path-format=absolute --git-common-dir`를 실행한다.
2. 반환된 Git common dir의 부모를 `HARNESS_PROJECT_DIR`로 둔다.
3. Harness 상태 폴더는 `$HARNESS_PROJECT_DIR/.harness`다.
4. Codex worktree 안에서 실행 중이어도 worktree 안에 별도 `.harness`를 만들지 않는다.

## 표준 파일

| 종류 | 경로 |
| --- | --- |
| Progress | `.harness/progress/progress-<slug>.md` |
| Domain | `.harness/domain-<slug>.html` |
| Implementation | `.harness/implementation-<slug>.html` |
| Review | `.harness/reviews/review-<slug>.md` |
| QA | `.harness/results/qa-<slug>.md` |
| Customer | `.harness/results/customer-<slug>.md` |
| Final report | `.harness/results/report-<slug>.html` |

## 단계 흐름

각 단계 시작 시 해당 `docs/steps/*.md` 파일을 반드시 읽는다.

워크플로를 시작할 때 사용자에게 전체 단계 흐름을 먼저 짧게 알린다. 이 안내는 승인 요청이 아니며, `/harness` noask 모드에서도 허용되는 진행 상황 공유다. 최소한 아래 순서를 포함한다: Step 1 초기화/재개, Step 2 도메인 설계, Step 3 구현 계획, Step 4 구현, Step 5 리뷰, Step 6 QA, Step 7 고객 사용자 검증, Step 8 완료 전 정리, Complete 최종 보고.

각 단계에 진입하거나 단계가 끝날 때도 현재 단계, 핵심 산출물, 다음 단계를 사용자에게 한두 문장으로 알린다. 단, 진행을 막지 않는 단순 안내로 유지하고 noask 모드에서 사용자 승인이나 선택을 요구하지 않는다.

- [Step 1](steps/step1-init.md)은 `.harness`와 필수 폴더를 준비한다.
- [Step 2](steps/step2-domain.md)는 도메인 설계를 작성한다.
- [Step 3](steps/step3-impl-plan.md)은 구현 계획과 검증 계획을 만든다.
- [Step 4](steps/step4-impl.md)는 코드를 수정한다.
- [Step 5](steps/step5-review.md)는 리뷰를 수행하고 결함을 기록한다. 세부 기준은 [codex-review-procedure.md](procedures/codex-review-procedure.md)를 따른다.
- [Step 6](steps/step6-qa.md)은 실제 테스트와 QA를 수행한다. 테스트 가이드는 [test-guide-format.md](test-guide-format.md)를 따른다.
- [Step 7](steps/step7-customer.md)은 고객 사용자 관점 검증을 수행한다. 세부 기준은 [customer-test-procedure.md](procedures/customer-test-procedure.md)를 따른다.
- [Step 8](steps/step8-commit.md)은 요청된 경우 commit/push 등 마무리 작업을 한다.
- [Complete](steps/complete.md)는 최종 보고를 작성한다.

`Step 9`는 없다. Complete를 숫자 단계로 쓰지 않는다.

## 단계 진입 게이트

- Step 2 진입 전: Step 1 progress가 있어야 한다.
- Step 3 진입 전: `domain-<slug>.html`이 있어야 한다.
- Step 4 진입 전: `implementation-<slug>.html`이 있어야 한다.
- Step 5 진입 전: 구현 diff 또는 변경 파일 목록이 있어야 한다.
- Step 6 진입 전: Step 5 리뷰 파일이 있어야 한다.
- Step 7 진입 전: Step 6 QA 결과가 있어야 한다.
- Complete 진입 전: Step 5/6/7 결과를 읽고 핵심 흐름이 `PASS`인지 확인한다.

게이트를 만족하지 못하면 다음 단계로 가지 않고 `BLOCKED` 또는 `UNKNOWN`을 progress와 stop report에 남긴다.

### Step 스킵 금지

- 산출물이 없으면 해당 Step을 수행하지 않은 것으로 본다.
- "간단하므로 생략", "이미 알고 있으므로 생략", "이전 대화상 충분" 같은 사유로 Step을 건너뛰지 않는다.
- 진행 중 외부 계획 번호가 필요하면 `Task <n>`을 사용한다. Harness 번호는 Step 1-8과 Complete에만 쓴다.
- 누락된 Step을 발견하면 즉시 현재 Step을 중단하고 누락된 산출물과 복구 경로를 progress에 남긴다.

### 실행 게이트

Step 전환 전에는 다음 스크립트로 게이트를 확인한다.

```powershell
powershell -ExecutionPolicy Bypass -File ~/.codex/skills/harness/core/validate-runtime-gate.ps1 -ProjectDir <project-dir> -NextStep Step6 -Slug <slug>
```

`Summary: FAIL`이면 다음 Step으로 이동하지 않는다. 이 스크립트는 다음을 검사한다.

- Step 9 또는 두 자리 Harness Step 번호 사용 여부
- domain/implementation/review/QA/customer 산출물 존재 여부
- Step 5 리뷰의 명시적 `LGTM: YES` 여부
- self-review `LGTM: YES` 오판 여부
- Step 6 QA의 `Verdict`, 증거 필드, BLOCKED reason enum
- Complete 전 고객 검증 PASS 또는 명시적 비적용 사유

선택적으로 Step 4 기준 commit을 넘겨 리뷰/QA 결정 이후 diff를 확인한다.

```powershell
powershell -ExecutionPolicy Bypass -File ~/.codex/skills/harness/core/validate-runtime-gate.ps1 -ProjectDir <project-dir> -NextStep Complete -Slug <slug> -Step4CommitSha <sha>
```

## 회송 경로 보장

Step 5/6/7이 `FAIL`, `BLOCKED`, `UNKNOWN`을 내면 아래 5개 장치를 모두 적용한다.

1. 결정 보고 게이트: `Verdict`, `Evidence`, `Changed artifacts`, `Decision`, `Next` 없이 다음 Step으로 가지 않는다.
2. Loop Counter: 같은 결함 라벨을 `.harness/progress/progress-<slug>.md`에 누적한다.
3. git diff 게이트: Step 4 기준 commit이 있으면 `git diff <step4_commit_sha>..HEAD`를 실행하고, 리뷰/QA 이후 변경이 있으면 재리뷰 대상으로 돌린다.
4. 결함 prepend: Step 3 또는 Step 4로 돌아갈 때 직전 결함 요약을 입력 맨 앞에 붙인다.
5. 결함 유형 enum: 자유 문구 대신 아래 13개 enum 중 하나를 사용한다.

결함 유형 enum:

- `SECURITY_AUTH`
- `SECURITY_SECRET`
- `DATA_LOSS`
- `API_CONTRACT`
- `STORAGE_FORMAT`
- `FILE_PATH`
- `RUNTIME_ERROR`
- `UI_LAYOUT`
- `ACCESSIBILITY`
- `PERFORMANCE`
- `TEST_GAP`
- `SCOPE_DRIFT`
- `BUILD_CI`

회송 prepend 형식:

```md
## Returned Defects (READ FIRST)
- Source step: Step 5 | Step 6 | Step 7
- Return path: return-to-step-3 | return-to-step-4 | pause
- Loop counter: <DEFECT_ENUM:file-or-area>=<count>
- Evidence: <review/qa/customer file path and command/screenshot/log>
- Required change: <next concrete action>
```

같은 `DEFECT_ENUM:file-or-area`가 5회 반복되면 자동 중단하고 [stop-report.md](stop-report.md)를 쓴다.

## Learning Prepend 계약

Harness helper 역할을 사용할 때는 호출자가 먼저 해당 learning 파일을 읽고 결과 프롬프트 또는 작업 메모 첫 200줄 안에 아래 헤더를 포함한다.

```md
## Prior Learning (READ FIRST): <helper-name>
```

대상 helper:

- `harness-qa-engineer`: `agents/learning/harness-qa-engineer.md`
- `harness-customer-user`: `agents/learning/harness-customer-user.md`
- `harness-deep-researcher`: `agents/learning/harness-deep-researcher.md`

이 헤더와 learning 요약 없이 helper 결과를 사용하지 않는다. helper가 직접 파일을 쓸 수 없으면 호출자 Codex가 결과를 `.harness/results/` 또는 `.harness/research/`에 저장한다.

핵심 사용자 흐름이 `UNKNOWN` 또는 `BLOCKED`면 Complete로 가지 않는다. 비핵심 항목만 미검증이면 최종 보고에 남은 위험으로 분리할 수 있다.

## noask 결정표

`/harness`는 사용자에게 묻지 않고 다음 기본값을 적용하며, 모든 결정은 progress에 기록한다.

| 결정 지점 | noask 기본값 |
| --- | --- |
| 요구사항 일부 불명확 | 합리적 가정을 적고 `Open Questions`에 남긴다. 구현을 막으면 `BLOCKED`로 멈춘다. |
| Step 2 도메인 설계 | `harness-plan`을 사용하고 사용자 승인 없이 Step 3로 간다. |
| Step 3 작업 크기 | Chunk 신호가 2개 이상이면 vertical slice로 나누고 Step 4-6을 chunk별 반복한다. |
| 동일 결함 반복 | 같은 결함 라벨이 5회 반복되면 자동 중단하고 stop report를 쓴다. |
| Step 5 FAIL | finding을 Step 3 또는 Step 4 입력으로 되돌린다. |
| Step 5 UNKNOWN | 리뷰 대상 파일 목록을 다시 만들고, 그래도 불명확하면 멈춘다. |
| Step 6 FAIL | 재현 절차를 Step 4 입력으로 되돌린다. |
| Step 6 BLOCKED | 같은 명령/환경으로 1회만 재시도한다. 재시도 실패 시 다중 slug는 `paused-by-blocked` 후 다음 slug, 단일 slug는 중단한다. 동일 사유 5회 누적 시에만 사용자 결정을 묻는다. |
| Step 6/7 UNKNOWN | 핵심 흐름이면 Complete 금지, 비핵심이면 위험으로 분리한다. |
| Step 8 push | `--push` 또는 `.harness/.auto-push`가 있을 때만 push한다. |
| Complete 진입 전 Step 7 결과 처리 | 사용자에게 A/B/C를 한 번 묻는다. A: 그대로 complete, B: `.harness/.pending-step7-review`로 일시정지, C: 개선안으로 새 Harness 워크플로 자동 시작. |

`/harness-ask`는 같은 흐름을 사용하되 진행을 막는 결정 지점에서 질문한다. Step 2는 `harness-plan-ask`를 사용한다.

noask 결정표의 의미를 축약하거나 완화하지 않는다. 예를 들어 `BLOCKED`를 `UNKNOWN`으로 바꾸거나, `LGTM: UNKNOWN`을 `LGTM: YES`로 승격하지 않는다.

### noask 예외

`/harness` noask 모드에서 사용자 질문이 허용되는 예외는 정확히 두 곳뿐이다.

1. Complete 진입 전 Step 7 결과 처리:
   - A: 그대로 Complete 진행, 개선안은 report에 요약한다.
   - B: `.harness/.pending-step7-review` 마커를 만들고 일시정지한다.
   - C: customer 결과의 권고/있었으면 하는 것/없었으면 하는 것을 합성해 새 Harness 워크플로를 자동 시작한다. 새 progress에는 `auto_triggered_from: <parent-slug>`를 기록하고, 자동 chain 방지를 위해 새 워크플로의 Complete 게이트에서는 C를 비활성화한다.
2. Step 6 동일 BLOCKED 사유 5회 누적:
   - A: 환경 수정 후 재시도
   - B: 사용자 명시 동의 스킵
   - C: 워크플로 중단

위 두 곳 외의 질문, 승인 요청, "어떻게 진행할까요" 문장은 noask 위반이다.

## Chunk 모드

Step 3에서 대규모 작업으로 판단되면 vertical slice로 나눈다. 각 chunk는 Step 4-6을 독립 반복한다.

Chunk 전환 신호:

- 변경 예상 파일 6개 이상
- 서로 다른 레이어 3개 이상
- 독립 사용자 시나리오 3개 이상
- 검증 경로 3개 이상
- 위험한 마이그레이션 또는 대규모 리팩터

2개 이상 해당하면 chunk를 만든다. 모든 chunk가 검증되기 전에는 Complete로 가지 않는다.

## 기록

각 단계는 `.harness/progress/progress-<slug>.md`에 아래 항목을 누적한다.

- 단계명
- 시작/종료 시각
- 수행 내용
- 생성/수정 산출물
- 검증 결과
- 보류 사유와 다음 단계

## 실패 처리

- `FAIL`: 원인을 파일/명령/화면 증거와 함께 기록하고 Step 3 또는 Step 4로 되돌린다. 되돌아간 단계는 같은 slug의 progress에 새 회차로 남긴다.
- `BLOCKED`: 차단 사유, 필요한 권한/계정/환경/사용자 결정, 재개 조건을 기록한다. Step 6에서는 자동 재시도 1회와 slug 분기를 먼저 적용하고, 동일 사유 5회 누적일 때만 noask 예외 질문을 사용한다.
- `UNKNOWN`: 증거가 부족한 항목과 추가 검증 방법을 기록한다. 핵심 흐름이 UNKNOWN이면 Complete로 가지 않는다.

상태 라벨은 `PASS`, `FAIL`, `BLOCKED`, `UNKNOWN`만 사용한다. `부분 통과`, `대체로 OK`, `확인 못 했지만 통과` 같은 문구로 라벨을 가공하지 않는다.

## 보고 형식

각 단계 종료 시 progress에 다음 5줄을 남긴다.

```md
### Step <n> result
- Verdict: PASS | FAIL | BLOCKED | UNKNOWN
- Evidence: <명령, 파일, 화면, 보고서 경로>
- Changed artifacts: <생성/수정한 산출물>
- Decision: continue | return-to-step-<n> | pause
- Next: <다음 행동>
```

## 도구 선택

- 파일 탐색은 `rg`/`rg --files`를 우선한다.
- 테스트 명령은 프로젝트에 이미 있는 스크립트를 우선한다.
- UI 검증은 Codex 브라우저 도구, Playwright, 프로젝트 E2E 순서로 찾는다.
- 어떤 도구도 없으면 수행 불가 사실을 결과에 남긴다.

## 도우미와 learning 계약

Codex에서 helper role 또는 별도 절차를 사용할 때는 먼저 해당 learning 파일을 읽는다.

- QA: `agents/learning/harness-qa-engineer.md`
- Customer: `agents/learning/harness-customer-user.md`
- Deep research: `agents/learning/harness-deep-researcher.md`

실제 파일 쓰기는 호출자 역할의 Codex가 책임진다. helper가 파일을 직접 쓸 수 없는 구조라면 helper 결과를 받아 `.harness/results/` 또는 `.harness/research/`에 저장하고, 저장 경로를 progress에 남긴다.

## 참고 문서

- [setup.md](setup.md)
- [environment-map.md](environment-map.md)
- [html-output-rule.md](html-output-rule.md)
- [donot.md](donot.md)
- [context-layer.md](context-layer.md)
- [file-formats.md](file-formats.md)
- [phases.md](phases.md)
- [examples.md](examples.md)
- [stop-report.md](stop-report.md)
