# step7. 커스터머 유저 테스트

## CRITICAL: sub-agent spawn bridge

Step7 must use a real sub-agent. `/harness`, `/harness-ask`, an active Harness handoff/resume invocation, or the `harness-customer-user` skill invocation already counts as explicit user authorization for this delegation.

Codex App bridge:

1. Read the custom agent spec from `~/.codex/agents/harness-customer-user.md`; if absent, read `~/.codex/skills/harness/agents/harness-customer-user.md`.
2. Spawn the available sub-agent tool with `agent_type="worker"` (`default` only if `worker` is unavailable). Do not use `agent_type="harness-customer-user"` unless the runtime explicitly lists it as valid.
3. The spawned prompt must start with: `You are acting as harness-customer-user according to the Harness agent spec below.`
4. Include the full agent spec, Prior Learning, main repo `.harness/` absolute path, production install/launch details, output path `.harness/results/customer-<slug>.md`, and only user-facing product information: what the program is, what features it has, and the basic way an ordinary user would use it. Do not pass click order, expected path, scoring method, or test procedure as user-facing instructions.
5. If the worker cannot write into the caller workspace, it must return the full report body. The caller may save that body verbatim but must not role-play the customer persona or decide the customer verdict itself.
6. If no sub-agent spawn tool is exposed, record `BLOCKED / DEPENDENCY_MISSING` and stop before Step8.

**산출물**: `.harness/results/customer-<slug>.md`

**증거 한계**: step7 은 **합성 고객 워크스루(synthetic customer walkthrough)** 이다. 실제 사용자 조사, 접근성 적합성, 시장 검증, 전환율 검증으로 표현하지 않는다. 모든 발견은 `severity`, `confidence`, `evidence` 를 함께 기록해야 하며, "실제 사용자 검증 완료" 류의 문구는 금지한다.

**입력 게이트 (skip 금지 — 호출자 Codex 가 진입 직전 자체 검증)**:

step5/step6 의 입력 게이트와 동등 강도. 누락 시 step 스킵 위반으로 즉시 워크플로우 중단.

1. `.harness/results/qa-<slug>.md` 마지막 회차 라벨을 Read.
2. 라벨이 PASS 가 아니면 (`FAIL` / `BLOCKED` / `UNKNOWN` / 라벨 자체 부재) → **진입 거부**.
   - 채팅 한 줄 보고: `[step7-gate] step6 미통과 (<라벨 원문>) — step7 진입 금지`
   - 워크플로우는 중단 상태 유지. step8 도 진입 금지.
3. 라벨이 PASS 인 경우만 step7 호출 진행. 검증에 사용한 라벨 원문을 `customer-<slug>.md` 의 *진입 게이트* 섹션에 인용.
4. 검증 명령 (호출자 Codex 가 직접 실행):
   ```
   grep -oE "(Verdict|Status|최종 판정):[[:space:]]*(PASS|FAIL|BLOCKED|UNKNOWN)" .harness/results/qa-<slug>.md | tail -1
   ```
5. 본 게이트는 workflow.md "Step 스킵·무시 금지" 절의 강제 메커니즘이다. SKILL.md "자동 결정 매핑" 표의 어떤 자동 결정으로도 우회 불가.

**조건**: 위 게이트 통과 후, 워크플로우 전체에서 **단 1회만** 실행. step6 가 몇 번 FAIL → PASS 를 반복하든 이 단계는 한 번뿐.

**흐름**:
1. **테스트 가이드 확인** — step6 에서 작성·갱신된 `test-guide-<slug>.md` 최신본을 그대로 재사용 (이 단계에서 별도 작성 안 함). 가이드 없으면 step6 에서 누락된 것이므로 거기로 되돌려 작성 후 진행. 양식은 [../test-guide-format.md](../test-guide-format.md) 참조.
2. **실제 제품 빌드 + 설치 + 실행** (호출자 Codex 가 직접 수행) — step6 의 dev 환경이 아니라, **실제 사용자가 받는 그 형태**로 설치하고 띄운다.
   - CLI 라면: production 빌드 후 글로벌/로컬 설치 (`npm i -g .`, `pip install .`, `cargo install --path .` 등 프로젝트에 맞는 방식)
   - 데스크톱 앱이라면: production 빌드 산출물(installer / app bundle) 을 사용자처럼 설치 후 실행
   - 웹 앱이라면: production 빌드(`npm run build` 등) 후 정적 서버 또는 preview 모드로 서빙. dev hot-reload 서버 금지
   - 모바일 앱이라면: release 빌드 산출물(APK/IPA) 을 device/emulator 에 설치 후 실행
   - 설치·실행 명령과 접근 경로(URL/실행 파일/명령) 를 `test-guide-<slug>.md` 의 "환경" 섹션에 production install 정보로 적어 둔다.
   - 설치/빌드 실패 시 사용자에게 보고 후 결정 요청 (BLOCKED).
3. `harness-customer-user` sub-agent/helper 에 위임 — **호출 방식 single source**: [`docs/procedures/customer-test-procedure.md`](../procedures/customer-test-procedure.md) 의 최상위 동작원칙 + 4단계 흐름 + LLM 페르소나 함정 6종 차단 + 권한 정책.
   - workflow 내부에서는 `harness-customer-user` agent 를 사용 가능한 sub-agent/helper 도구로 호출해야 한다.
   - `harness-customer-user` skill 은 sub-agent 호출 준비 dispatcher 일 뿐이며 직접 고객 페르소나 수행 fallback 이 아니다.
   - `/harness-customer-user` slash 는 사용자 진입점이며 workflow 내부 대체 경로로 사용하지 않는다.
   - sub-agent/helper 도구가 없으면 즉시 `BLOCKED / DEPENDENCY_MISSING` 으로 기록하고 step8 진입 금지.
   - **[Learning Prepend 계약](../workflow.md#critical-learning-prepend-계약-모든-harness--agent-공통) 1·2·3·4 단계 수행 필수.** 즉 다음을 Read 후 `## Prior Learning (READ FIRST — DO NOT SKIP)` 헤더로 prepend:
     - `~/.codex/skills/harness/agents/learning/harness-customer-user.md` (공용만 — 프로젝트 learning 은 2026-05-20 폐기)
   - **test-guide-<slug>.md 는 호출자 게이트/범위 확인 자료** 이며, spawned prompt 에서는 클릭 순서·정답 경로·검증 방법을 페르소나 지시로 전달하지 않는다.
   - test-guide 내용을 전달해야 할 때는 `## Hidden Oracle (NOT USER INSTRUCTIONS)` 로 격리하고, 도우미가 숨은 채점표로만 취급하게 한다.
   - 누락 시 도우미가 `[BLOCKED]` 로 거부.
   - 도우미는 메인이 설치/실행해 둔 **실제 설치본**에 접속해서 테스트한다.
4. 도우미가 "제품을 처음 본 일반인" 페르소나로 제품을 독립 탐색한다. Harness 는 `어떤 프로그램인지 / 어떤 기능이 있는지 / 기본적으로 어떻게 사용하는지` 정도만 알려주며, 그 이후의 테스트 진행 방법은 알려주지 않는다.
5. 보고서 작성 (불편사항, 이상한 점, 바꿨으면 하는 것, 있었으면 하는 것, 없었으면 하는 것, 첫인상, 막힌 지점, 헷갈린 단어 등)
6. **게이트 아님** — 결과 통과/실패와 무관하게 다음 단계 (step8) 로
   - 발견된 사용성 이슈는 complete 단계의 `report-<slug>.html` 에 요약 포함
   - 사용자가 "지금 고치자" 라고 하면 별도 요청으로 새 워크플로우 시작
7. **정리** — 호출자 Codex 가 글로벌 설치 등 사용자 시스템에 흔적이 남는 항목을 제거 (예: `npm uninstall -g <pkg>`). 정리 내용도 보고서에 명시.

**다음 단계 안내**: step7 의 *결과* (개선 제안 / 좋았던 점 / 헷갈린 단어 등) 처리 방향은 step8 commit/push 완료 후 **complete 진입 전 사용자 확인 (request_user_input 또는 일반 질문)** 으로 한 번 물어본다 (noask 정책의 단 하나 예외). 3선택지 — A) 그대로 진행 (개선안 report 요약) / B) 일시정지 (직접 검토 후 재호출) / C) 개선안으로 신규 워크플로우 자동 시작 (auto_triggered_from chain + 무한 루프 차단). 자세히: [complete.md](complete.md#입력-게이트-critical--noask-예외-반드시-통과-후-진입).

**제약**:
- 커스터머 도우미도 보고서·스크린샷 외 파일 수정·생성 금지 — 빌드/설치/정리는 모두 호출자 Codex 책임
- QA 와 시점·페르소나가 다르므로 시나리오를 QA 보고서와 중복시키지 않음
- **dev 환경 / 테스트용 빌드로 대체 금지** — 실제 사용자가 받는 그 산출물로 테스트해야 의미가 있다

**Worktree 처리 (CRITICAL)**:
- `harness-customer-user` 를 사용 가능한 sub-agent/helper 도구로 호출할 때 **`isolation: "worktree"` 옵션 절대 사용 금지.** 격리된 worktree 안에는 `.harness/`, `test-guide-<slug>.md`, 설치된 production 산출물이 없으므로 helper가 실패한다.
- 호출자 Codex 가 worktree 안에서 작업 중이라면 step6 와 동일 — 메인 repo 의 `.harness/` 경로를 식별해 prompt 에 절대경로로 prepend, 보고서도 메인 repo 의 `.harness/results/customer-<slug>.md` 에 작성한다.
