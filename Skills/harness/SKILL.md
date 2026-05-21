---
name: harness
description: '''DO NOT AUTO-TRIGGER. SLASH-COMMAND-ONLY. Codex용 Harness 단계형 개발 워크플로. 사용자가 `/harness <자연어>` 또는 `/harness-ask <자연어>` 슬래시 커맨드를 명시 호출했거나, 슬래시 커맨드 자체를 직접 가리킨 경우에만 실행한다. "워크플로 / 도메인 설계 / 구현 계획 / QA / Codex 리뷰 / commit / push / Harness 워크플로" 같은 키워드만으로 자동 트리거하지 않는다. Harness 스킬 설치, 보고서 검토, 문서 보강, 커맨드 수정 요청은 워크플로를 시작하지 않고 스킬 유지보수로 처리한다.'''
---

# Harness

이 스킬은 Codex용 Harness 진입점이다. 자세한 실행 규칙은 `docs/` 문서가 정본이다. Claude 전용 도구명, 홈 경로, 서브에이전트 이름은 Codex 실행 요구로 그대로 해석하지 않고 Codex 도구와 경로로 매핑한다. 단, 원본 Harness의 행동 계약(noask 예외, Step 회송, 리뷰/QA 게이트)은 Codex 포트에서도 의미를 바꾸지 않는다.

## 실행 여부 먼저 판정

- 사용자가 `harness` 설치, 보고서 검토, 스킬 수정, 커맨드 수정, 문서 보강을 요청하면 Harness 워크플로를 실행하지 않는다. 요청받은 스킬/문서/스크립트만 수정한다.
- 워크플로 실행은 직전 사용자 메시지가 `/harness <목표>` 또는 `/harness-ask <목표>`로 시작하거나, `"/harness 워크플로를 시작"`처럼 슬래시 커맨드 자체를 직접 가리킨 경우에만 시작한다.
- `Harness 워크플로로 진행`, `하네스로 작업`, `QA 해줘`, `리뷰해줘`, `구현 계획 세워줘` 같은 자연어 키워드만으로는 실행하지 않는다.
- 잘못 트리거된 경우 한 줄로 중단한다: `KEYWORD_MATCH_ONLY: Harness 실행 요청이 아닙니다. 시작하려면 /harness <목표>를 사용하세요.`

## 최상위 불변 규칙

- Harness 단계는 `Step 1`부터 `Step 8`까지와 `Complete`뿐이다. `Step 9`는 없다.
- `Complete`는 번호 없는 최종 보고 단계다. Markdown 목록에서도 `9. Complete`처럼 쓰지 않는다.
- Step을 건너뛰지 않는다. 산출물이나 게이트가 없으면 다음 Step으로 가지 않고 `BLOCKED` 또는 `UNKNOWN`을 기록한다.
- 상태 라벨은 `PASS`, `FAIL`, `BLOCKED`, `UNKNOWN`만 쓴다. `대체로 OK`, `부분 통과`, `확인 못 했지만 통과` 같은 문구로 바꾸지 않는다.
- `/harness` noask 모드의 기본 결정 문구는 의미를 바꿔 요약하지 않는다. 불확실하면 `workflow.md`의 결정표를 그대로 따른다.
- noask에서도 원본 Harness와 동일하게 사용자 질문이 허용되는 예외는 정확히 두 곳뿐이다: Complete 진입 전 Step 7 결과 처리, Step 6 동일 BLOCKED 사유 5회 누적.
- self-review만 수행한 `LGTM: YES`와 증거 없는 self-QA `PASS`는 승인으로 보지 않는다.

## 실행 시 필수 로드

`/harness`, `/harness-ask`, `/harness-*` 실행 요청이면 아래 문서를 먼저 읽고, 필요한 단계 문서를 추가로 읽는다.

1. [donot.md](docs/donot.md): 모든 지침보다 우선되는 금지 사항
2. [workflow.md](docs/workflow.md): 전체 흐름, 모드, 단계 게이트, noask/ask 분기, Chunk, 실패 처리
3. [setup.md](docs/setup.md): 설치, 초기화, 루트 계산, 문제 해결
4. [file-formats.md](docs/file-formats.md): 산출물 파일 형식과 저장 보고
5. [html-output-rule.md](docs/html-output-rule.md): HTML 산출물 형식
6. [context-layer.md](docs/context-layer.md): 재개 시 읽어야 할 상태 문서
7. [phases.md](docs/phases.md): Step 그룹 설명

UI, QA, 고객 검증, 병행 환경이 관련되면 다음 문서도 읽는다.

- [test-guide-format.md](docs/test-guide-format.md): QA 테스트 가이드 형식
- [environment-map.md](docs/environment-map.md): Codex와 Claude Code 병행 환경 매핑
- [stop-report.md](docs/stop-report.md): 중단/보류 보고 기준
- [examples.md](docs/examples.md): 사용 예시

## 단계 문서

각 단계 시작 시 해당 단계 문서를 반드시 읽는다.

- Step 1: [초기화 또는 재개](docs/steps/step1-init.md)
- Step 2: [도메인 설계](docs/steps/step2-domain.md)
- Step 3: [구현 계획](docs/steps/step3-impl-plan.md)
- Step 4: [구현](docs/steps/step4-impl.md)
- Step 5: [리뷰](docs/steps/step5-review.md)
- Step 6: [QA](docs/steps/step6-qa.md)
- Step 7: [고객 사용자 검증](docs/steps/step7-customer.md)
- Step 8: [완료 전 정리](docs/steps/step8-commit.md)
- Complete: [최종 보고](docs/steps/complete.md)

## 전환 게이트

Step 3 이후의 전환과 Complete 진입 전에는 [validate-runtime-gate.ps1](core/validate-runtime-gate.ps1)를 실행한다.

```powershell
powershell -ExecutionPolicy Bypass -File ~/.codex/skills/harness/core/validate-runtime-gate.ps1 -ProjectDir <project-dir> -NextStep <Step5|Step6|Step7|Step8|Complete> -Slug <slug>
```

`Summary: FAIL`이면 다음 Step으로 이동하지 않는다. 실패 사유를 `.harness/progress/progress-<slug>.md`와 stop report에 남긴다.

## noask 결정 매핑

`/harness`는 사용자에게 묻지 않고 아래 기본값으로 진행한다. 결정은 progress에 그대로 기록한다.

| 결정 지점 | noask 기본값 |
| --- | --- |
| 요구사항 일부 불명확 | 합리적 가정을 적고 `Open Questions`에 남긴다. 구현을 막으면 `BLOCKED`로 멈춘다. |
| Step 2 도메인 설계 | `harness-plan`을 사용하고 사용자 승인 없이 Step 3로 간다. |
| Step 3 작업 크기 | Chunk 신호가 2개 이상이면 vertical slice로 나누고 Step 4-6을 chunk별 반복한다. |
| Step 5 `LGTM: NO` | finding을 Step 3 또는 Step 4 입력으로 되돌린다. |
| Step 5 `LGTM: UNKNOWN` | 리뷰 대상 파일 목록을 다시 만들고, 그래도 불명확하면 멈춘다. |
| Step 6 `FAIL` | 재현 절차를 Step 4 입력으로 되돌린다. |
| Step 6 `BLOCKED` | 같은 명령/환경으로 1회만 재시도한다. 재시도 실패 시 다중 slug는 `paused-by-blocked` 후 다음 slug, 단일 slug는 중단한다. 동일 사유 5회 누적 시에만 사용자 결정을 묻는다. |
| Step 6/7 `UNKNOWN` | 핵심 흐름이면 Complete 금지, 비핵심이면 위험으로 분리한다. |
| 동일 결함 반복 | 같은 결함 라벨이 5회 반복되면 자동 중단하고 stop report를 쓴다. |
| Step 8 push | `--push` 또는 `.harness/.auto-push`가 있을 때만 push한다. |
| Complete 진입 전 Step 7 결과 처리 | 사용자에게 A/B/C를 한 번 묻는다. A: 그대로 complete, B: `.harness/.pending-step7-review`로 일시정지, C: 개선안으로 새 Harness 워크플로 자동 시작. |

`/harness-ask`는 같은 흐름을 사용하되 진행을 막는 결정 지점에서 짧게 질문한다. Step 2는 `harness-plan-ask`를 사용한다.

위 표 외의 명시 질문 도구 호출 또는 사용자 승인 요청 문장은 noask 위반이다.

## Chunk 임계값

Step 3에서 아래 신호 중 2개 이상이면 Chunk 모드다.

- 변경 예상 파일 6개 이상
- 서로 다른 레이어 3개 이상
- 독립 사용자 시나리오 3개 이상
- 검증 경로 3개 이상
- 위험한 마이그레이션 또는 대규모 리팩터

각 chunk는 Step 4 구현, Step 5 리뷰, Step 6 QA를 독립 반복한다. 모든 chunk가 검증되기 전에는 Complete로 가지 않는다.

## Learning Prepend 계약

QA, 고객 검증, 딥 리서치 helper를 사용할 때는 호출자가 먼저 해당 `agents/learning/*.md` 파일을 읽고 helper 입력 첫 200줄 안에 아래 헤더를 포함한다.

```md
## Prior Learning (READ FIRST): <helper-name>
```

이 헤더와 learning 요약 없이 나온 helper 결과는 Step 판정 근거로 쓰지 않는다.

## 보조 절차

- [codex-review-procedure.md](docs/procedures/codex-review-procedure.md)
- [customer-test-procedure.md](docs/procedures/customer-test-procedure.md)
- [deep-research-procedure.md](docs/procedures/deep-research-procedure.md)
