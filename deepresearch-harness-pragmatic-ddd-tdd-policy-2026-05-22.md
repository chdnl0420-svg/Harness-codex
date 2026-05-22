# Harness DDD/TDD 불일치 딥리서치 보고서

- 날짜: 2026-05-22
- 대상 세션: `019e4f11-e97f-7d33-be72-622d4ddbc03a`
- 리서치 등급: Standard
- 패스 수: 13
- 중단 사유: DDD, TDD, 테스트 전략, traceability, durable workflow 근거가 같은 결론으로 수렴

## 결론

현재 문서의 strict-only DDD/TDD 게이트가 항상 더 낫지는 않다. 실제 작업 방식도 그대로 채택하기에는 evidence mode 가 명시되지 않아 재현성과 감사성이 약하다.

다음 실행부터는 hybrid 정책을 적용한다.

- `STRICT_RED`: 새 동작, 버그 수정, 사용자 흐름, API/IPC/persistence/permission/validation/state-boundary 변경, 고위험 chunk 에서 필수.
- `CHARACTERIZATION`: 기존 동작 보존, regression 방지, 빌드/패키징 wiring 이동처럼 실패 테스트를 억지로 만들면 오히려 의미가 흐려지는 경우 허용.
- `STATIC_ONLY`: 파일 존재, build order, export shape, dependency graph, scope guard 같은 순수 정적 계약에만 허용.

이 결론은 TDD의 본질이 test-first red/green/refactor 라는 점을 유지하면서도, DDD와 traceability를 “필요한 계약과 경계만 문서화하는 방식”으로 줄이는 쪽이다. Fowler의 TDD 설명은 test-first와 red/green/refactor를 핵심으로 둔다 [[1]](https://martinfowler.com/bliki/TestDrivenDevelopment.html). DDD 쪽에서는 bounded context와 ubiquitous language가 업무 경계를 고정하는 수단이고, Microsoft도 microservice 경계를 business capability와 cohesion 중심으로 잡으라고 설명한다 [[2]](https://martinfowler.com/bliki/BoundedContext.html) [[3]](https://learn.microsoft.com/en-us/azure/architecture/microservices/model/domain-analysis).

## 대상 세션 판단

세션 `019e4f11-e97f-7d33-be72-622d4ddbc03a` 는 Harness 방식과 부분적으로 일치했다.

- 일치: `/harness` resume, chunk 단위 진행, 외부 Codex review 2회, worker QA, PASS 후 commit, `.harness/state.json` 갱신.
- 불일치: strict `Domain Contract` 필드, full trace matrices, 별도 `.harness/tests/red-*` artifact, workflow event schema 일부가 빠졌다.
- 판단: 실제 작업은 “빌드/계약 wiring 검증” 성격이 강해서 무조건 strict red artifact 를 요구하는 현재 문서보다 유연한 evidence mode 가 더 적합했다. 다만 그 유연성을 문서에 명시하지 않아 다음 실행이 흔들릴 위험이 있었다.

## 근거

DDD는 모든 변경에 aggregate, repository, event storming 같은 전술 패턴을 강제하는 체계가 아니다. bounded context 안에서 같은 용어가 같은 의미를 갖도록 하고, 시스템 경계를 업무 기능에 맞춰 세우는 것이 핵심이다 [[2]](https://martinfowler.com/bliki/BoundedContext.html) [[3]](https://learn.microsoft.com/en-us/azure/architecture/microservices/model/domain-analysis). Microsoft의 tactical DDD 문서도 entity/aggregate 같은 패턴은 bounded context 안에서 더 정밀한 모델이 필요할 때 적용하는 것으로 설명한다 [[4]](https://learn.microsoft.com/en-us/azure/architecture/microservices/model/tactical-domain-driven-design).

TDD는 새 기능과 버그 수정에서 강하게 유지해야 한다. 테스트를 먼저 쓰고, 기능 코드를 통과시킨 뒤, 구조를 정리하는 루프가 설계 피드백을 만든다 [[1]](https://martinfowler.com/bliki/TestDrivenDevelopment.html). 특히 LLM 기반 코딩에서는 테스트가 자연어 의도를 부분적으로 formalize 해 코드 정확도와 검토 품질을 높인다는 연구 결과가 있다 [[5]](https://www.microsoft.com/en-us/research/publication/llm-based-test-driven-interactive-code-generation-user-study-and-empirical-evaluation/).

반면 모든 검증을 strict RED나 E2E로 밀어 넣는 것은 좋지 않다. Google testing guidance 는 대부분을 낮은 레벨 테스트로 두고, 큰 E2E 테스트는 적게 유지하라고 설명한다 [[6]](https://testing.googleblog.com/2015/04/just-say-no-to-more-end-to-end-tests.html). 따라서 빌드 순서, export shape, 파일 존재 같은 정적 계약은 `STATIC_ONLY` 로 충분할 수 있다.

workflow 관점에서는 state/event 기록을 엄격히 해야 한다. Temporal은 Workflow Execution 이 Commands/Events 를 Event History 에 기록하고, 그 기록이 replay/resume 의 기준이 된다고 설명한다 [[7]](https://docs.temporal.io/workflows). Azure Durable Task 도 append-only execution history 를 통해 orchestration state 를 유지한다고 설명한다 [[8]](https://learn.microsoft.com/en-us/azure/durable-task/common/durable-task-orchestrations). Harness도 `.harness/state.json` 과 `events.ndjson` 을 canonical evidence 로 유지해야 한다.

Traceability는 필요한 만큼만 남겨야 한다. Springer의 traceability 연구는 traceability가 progress, compliance, collaboration 에 유익하지만 유지와 협업 부담도 크다고 보고한다 [[9]](https://link.springer.com/article/10.1007/s00766-018-0306-1). 그래서 full matrix 를 항상 강제하기보다 normal chunk 에는 compact `Contract/Test Trace`, high-risk chunk 에는 full matrices 가 맞다.

## 적용한 정책

다음 실행부터 Step3/Step4는 `contract_id` 별 `evidence_mode` 를 요구한다.

| mode | 사용 조건 | Step4 진입 evidence |
|---|---|---|
| `STRICT_RED` | 새 동작, 버그 수정, user flow, API/IPC/persistence/permission/validation/state-boundary, 고위험 chunk | 별도 red artifact |
| `CHARACTERIZATION` | 기존 동작 보존, regression 방지, build/package wiring 이동 | 현재 관찰, 실행 명령, 보호할 regression, strict RED 가 맞지 않는 이유 |
| `STATIC_ONLY` | 파일 존재, build order, export shape, dependency graph, scope guard | 정적 명령/assertion, 기대 실패/PASS, runtime 검증이 해당 없는 이유 |

정적 evidence 는 user flow, async state, IPC, persistence, permission, validation, state-boundary 의 유일한 evidence 로 인정하지 않는다.

## 변경 파일

- `skills/harness/docs/ddd-tdd-gates.md`: strict-only 문서를 risk-based evidence mode 정책으로 교체.
- `skills/harness/docs/steps/step3-impl-plan.md`: full matrix 고정 요구를 compact `Contract/Test Trace` 우선, high-risk full matrices 로 조정.
- `skills/harness/docs/steps/step4-impl.md`: physical red artifact always-required 문구를 evidence mode override 로 보정.
- `skills/harness/templates/red-test.md`: `evidence_mode`, `risk_reason`, characterization/static evidence 필드 추가.

## 남은 주의점

기존 문서 일부가 인코딩이 깨진 상태라 읽기성과 유지보수성이 낮다. 이번 변경은 요청 범위에 맞춰 정책만 최소 수정했지만, 다음 정리 작업에서는 Harness 문서 전체의 UTF-8 정규화가 필요하다.

