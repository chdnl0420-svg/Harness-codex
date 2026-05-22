# step4. 구현

**산출물**:
- 실제 프로젝트 코드 파일
- `.harness/progress/progress-<slug>.md` 진행 기록

**입력 게이트 (skip 금지)**:
- `.harness/implementation-<slug>.html` 전문을 **반드시 다시 읽어** 메인 컨텍스트에 올린다.
- step3 의 7개 필수 섹션 (변경 파일 / 영향 영역 / Contract-Test Trace 또는 full matrices / 단계별 순서 / 테스트 전략 / 위험·롤백) 이 채워져 있는지 확인. 누락 시 step3 로 되돌린다.
- `Contract/Test Trace` 또는 `Contract Traceability Matrix` 의 허용 경계 밖 파일을 수정하려면 step2 로 되돌려 Domain Contract 를 먼저 갱신한다.
- 각 contract_id 에 `evidence_mode`(`STRICT_RED`/`CHARACTERIZATION`/`STATIC_ONLY`) 와 진입 evidence 가 있어야 한다. `STRICT_RED` 는 `.harness/tests/red-<slug>.md` 또는 Chunks 모드의 `.harness/tests/red-<slug>-chunk-<n>.md` 가 필요하다. `CHARACTERIZATION`/`STATIC_ONLY` 는 step3 trace 안에 명령, 현재 관찰/기대 결과, strict RED 가 맞지 않는 이유를 명시해야 한다. 없으면 `state.json.blocked.reason_enum=TDD_MISSING` 으로 중단하고 step4 진입 금지.

**흐름** (호출자 Codex 가 직접 구현):

1. **단계별 진행** — `implementation-<slug>.html` 의 *"단계별 구현 순서"* 를 한 단계씩 처리. 한 번에 전체 구현 금지.
2. 각 단계에서:
   - **읽기 먼저** — 변경 대상 파일을 Read 로 먼저 본다. 추측 편집 금지.
   - **TDD 필수** — 동작이 측정 가능한 경우 테스트를 먼저 작성(RED) → 구현(GREEN) → 정리(REFACTOR). 새 동작, 버그 수정, API/IPC/persistence/permission/validation/state-boundary 변경은 `STRICT_RED` 로 처리한다. 기존 동작 보존이나 빌드/정적 계약 검증은 `CHARACTERIZATION` 또는 `STATIC_ONLY` 로 명시할 수 있지만, 이유와 명령/evidence 가 없으면 `TDD_MISSING` BLOCKED 로 기록한다.
   - **TDD 사이클이 막힐 때 일반 도구 호출**: 테스트 작성·구현·refactor 어느 단계든 3회 시도 후 진척이 없으면 `tdd` skill (Codex skill) 또는 `tdd-guide` agent (사용 가능한 sub-agent/helper 도구) 호출. RED → GREEN → REFACTOR 사이클 안내 받음.
   - **빌드/타입체크/lint 등 즉시 검증 가능한 항목**은 단계마다 실행. 실패하면 다음 단계로 넘어가지 않는다.
3. **변경 기록** — 각 단계 완료 시 `.harness/progress/progress-<slug>.md` 에 다음 형식으로 누적:
   ```markdown
   ## Step N (<날짜·시간>)
   - 단계명: <implementation-<slug>.html 의 단계명>
   - 변경 파일: <경로 목록>
   - 검증: <테스트·빌드·타입체크 결과>
   - 비고: <발견된 문제·skip 한 항목>
   ```
4. 모든 단계 완료 → step5 로.

## Red Artifact 형식 (CRITICAL)

Step4 전 다음 파일 중 하나를 작성한다.

- 단일 모드: `.harness/tests/red-<slug>.md`
- Chunks 모드: `.harness/tests/red-<slug>-chunk-<n>.md`

필수 내용:

- contract_id (`Domain Contract` 와 `Contract Traceability Matrix` 에 존재해야 함)
- 실패시킬 동작
- 실행 명령
- 기대 실패 메시지 또는 실패 관찰 기준
- 구현 후 기대 PASS 조건
- evidence type (`unit_test`, `component_test`, `Electron CDP scenario`, `Playwright scenario`, `IPC contract test` 중 하나)
- contract-violating case: API, IPC, persistence, permission, validation, state boundary 변경이면 정상 케이스 외에 계약 위반 입력/상태를 최소 1개 포함한다.

`CHARACTERIZATION` 은 step3 trace 또는 별도 evidence 파일에 contract_id, 현재 관찰, 실행 명령, strict RED 가 맞지 않는 이유, 구현 후 기대 결과, 보호할 regression 을 기록해야 한다.

`STATIC_ONLY` 는 step3 trace 또는 별도 evidence 파일에 contract_id, 정적 명령/assertion, 동적 runtime 검증이 해당 없는 이유, 기대 실패/PASS 조건을 기록해야 한다.

정적 grep/assertion 은 pure validation helper 또는 static contract 검증으로만 허용한다. 사용자 흐름, async state, persistence, IPC, permission, validation, state-boundary 시나리오의 유일한 evidence 로는 인정하지 않는다.
Red artifact 는 구현 코드를 보고 사후 작성하면 무효다. 요구사항과 Domain Contract 에서 먼저 만든 실패 테스트여야 한다. 위반 시 `BLOCKED / TDD_MISSING`.

**제약 (`donot.md` 참조)**:
- *"동작할 것 같다"* 로 다음 단계 진행 금지. 검증 통과 후에만 진행.
- `implementation-<slug>.html` 에 없는 기능을 임의로 추가 금지. 추가 필요 시 step3 로 되돌린다.
- 빌드 실패를 *"나중에 한꺼번에 고치자"* 로 미루지 않는다. 즉시 해결 또는 step3 로 회송.
- 동작하지 않는 기존 코드 (버튼·필터 등) 를 임의로 제거하지 않는다 — 버그일 수 있다.

**빌드 실패 처리**:
- 3회 연속 같은 에러 → 일반 도구 호출로 빌드 그린 복구:
  - skill `build-fix` (Codex skill) — 언어 무관 일반 절차
  - agent `*-build-resolver` (사용 가능한 sub-agent/helper 도구) — 언어별: `typescript-build-resolver`, `python-build-resolver`, `go-build-resolver`, `rust-build-resolver`, `java-build-resolver`, `cpp-build-resolver`, `kotlin-build-resolver`, `dart-build-resolver`, `pytorch-build-resolver` (PyTorch 런타임/CUDA 한정), 기본 fallback `build-error-resolver`
- 도우미·진단으로도 안 풀리면 step3 로 되돌려 계획 자체를 수정.

---

## Chunks 모드 (2026-05-20 신규)

**Chunks 모드일 때** (step3 의 임계값 통과 시):
- 본 step 진입 시 *현 chunk_i 의 implementation plan* 만 본다 — `implementation-<slug>-chunk-<i>.html`. 다른 chunk 의 plan 읽지 않음.
- 변경 범위도 *현 chunk 의 변경 대상 파일* 만. 다른 chunk 의 파일 건드리면 chunks 격리 위반.
- progress 파일의 `current_chunk` 필드를 본 step 진입 시 갱신.
- 자세히: [step3-impl-plan.md Chunks 분해 절차](step3-impl-plan.md#chunks-분해-절차-critical--2026-05-20-신규).
## DDD/TDD Evidence Override (2026-05-22)

This section overrides older wording in this file when the older wording requires a physical red artifact for every chunk.

- Step4 entry requires contract-linked evidence, not always a separate red file.
- `STRICT_RED` is required for new behavior, bug fixes, user-visible flows, API/IPC/persistence/permission/validation/state-boundary changes, and high-risk chunks. It must use `.harness/tests/red-<slug>.md` or `.harness/tests/red-<slug>-chunk-<n>.md`.
- `CHARACTERIZATION` is allowed for preserving existing behavior or proving no regression. It may live in the Step3 trace when it names the contract_id, command, current observation, expected post-change result, protected regression, and why strict RED is not meaningful.
- `STATIC_ONLY` is allowed only for pure static contracts such as file presence, build order, export shape, dependency graph, or scope guard. It may live in the Step3 trace when it names the contract_id, static command/assertion, expected failure/pass condition, and why runtime behavior is not applicable.
- Static evidence is never sufficient as the only evidence for user flow, async state, IPC, persistence, permission, validation, or state-boundary behavior.
- Missing or post-hoc evidence still blocks Step4 with `state.json.blocked.reason_enum=TDD_MISSING`.
