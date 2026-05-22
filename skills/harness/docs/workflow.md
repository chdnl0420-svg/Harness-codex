# /harness Workflow

### CRITICAL: Codex App sub-agent runtime bridge

`/harness` and `/harness-ask` are explicit user authorization to delegate Step6 and Step7 to sub-agents. The same is true after this Harness skill has been loaded and its input gate has passed, including resumed handoff invocations such as `Harness <handoff-path>`. A Harness run must never say "subagent use was not explicitly approved" after the Harness workflow is active.

Codex App runtimes may expose only generic sub-agent types such as `worker`, `default`, or `explorer`. In that runtime, custom Harness agents are loaded by prompt, not by `agent_type`.

Required bridge:

1. Use the available sub-agent tool (`spawn_agent` / `multi_agent_v1.spawn_agent` equivalent) with `agent_type="worker"` for `harness-qa-engineer` and `harness-customer-user`. If `worker` is not offered but `default` is offered, use `agent_type="default"`.
2. Never pass `agent_type="harness-qa-engineer"` or `agent_type="harness-customer-user"` unless the runtime explicitly lists those exact values as valid agent types.
3. Read the matching custom agent spec from `~/.codex/agents/<agent-name>.md` first. If missing, read `~/.codex/skills/harness/agents/<agent-name>.md`.
4. Put the full agent spec into the spawned worker prompt with this sentence before it: `You are acting as <agent-name> according to the Harness agent spec below.`
5. Prepend Prior Learning, main repo `.harness/` absolute path, runtime target details, and the required output path. For `harness-qa-engineer`, include the full `test-guide-<slug>.md` as test input. For `harness-customer-user`, include only launch details and user-facing product information (`what the program is / what features it has / the basic way an ordinary user would use it`); if the guide is needed, isolate it as `## Hidden Oracle (NOT USER INSTRUCTIONS)` and never present click order, expected path, scoring method, or test procedure as persona instructions.
6. If the spawned worker cannot write into the caller workspace, it must return the full report body. The caller may only save that verbatim worker-produced report to the canonical output path; the caller must not author the QA/customer verdict.
7. If no sub-agent spawning tool is exposed at all, record `BLOCKED / DEPENDENCY_MISSING`. If the tool is exposed, direct caller execution is forbidden.

### CRITICAL: sub-agent 강제 계약

`harness-qa-engineer` 와 `harness-customer-user` 는 호출자 Codex가 직접 대체할 수 없다.

- 사용 가능한 sub-agent/helper 도구가 있으면 반드시 해당 agent 로 호출한다.
- sub-agent/helper 도구가 없으면 해당 step 은 `BLOCKED / DEPENDENCY_MISSING` 으로 기록한다.
- 호출자 Codex가 같은 입력으로 직접 QA/customer persona 를 수행해 PASS, FAIL, UNKNOWN, customer verdict 를 만들면 무효다.
- `harness-customer-user` skill 은 sub-agent 호출 준비 wrapper 이며, 직접 수행 fallback 이 아니다.
- 기존 문서의 "통합 모드", "직접 수행", "manual self-test" 문구가 이 계약과 충돌하면 이 계약이 우선한다.

---

## 실행 옵션

모든 harness-* 단위가 *skill* 로 통합. 호출자 Codex 가 Codex skill로 각 단위 호출 — Task sub-agent 별도 컨텍스트 가치는 *외부 CLI (codex exec)* 와 *MCP 브라우저 도구* 만 유지.

### sub-agent 강제 모드 (default)

| step | 수행 주체 | 비고 |
|------|----------|------|
| step2 도메인 설계 | `harness-plan` skill (noask 동작) | 한 줄 목표 → 6 카테고리 합리적 가정 + 필요 시 shared `$deepresearch` 외부 리서치 + Open Questions. `/harness-ask` 는 `harness-plan-ask` (인터랙티브) |
| step3 구현 계획 | `plan` skill — Chunks 임계값 통과 시 vertical slice 분해 + chunk loop | step2 연속성. [steps/step3-impl-plan.md Chunks 분해](steps/step3-impl-plan.md) |
| step4 구현 | 호출자 Codex 직접. 빌드 실패 시 `build-fix` skill 또는 언어별 `*-build-resolver` agent | TDD 모드면 `tdd` skill / `tdd-guide` agent |
| step5 리뷰 | **Codex CLI** (`codex exec` 외부) + 보조: `code-review` / `code-reviewer` (fallback), `security-review` / `security-reviewer` (보안 민감 코드) | Codex 외부 CLI 그대로. self-review bias 차단 외부 verifier 유일 보존 |
| step6 QA | `harness-qa-engineer` agent (사용 가능한 sub-agent/helper 도구) | sub-agent 호출 필수. 없으면 `BLOCKED / DEPENDENCY_MISSING`; 호출자 Codex 직접 QA 금지 |
| step7 커스터머 | `harness-customer-user` agent (사용 가능한 sub-agent/helper 도구) | sub-agent 호출 필수. skill 은 dispatcher일 뿐이며 직접 페르소나 수행 금지 |
| step8 commit | 호출자 Codex 직접 + Chunks 모드면 chunk 별 incremental commit | — |

**외부 의존성 (helper가치 유지 영역)**:
- **Codex CLI** (`codex exec`) — step5 외부 verifier. self-review bias 차단 유일 외부 단위.
- **MCP 브라우저 도구** (Codex Browser / Playwright / 프로젝트 기존 E2E) — step6/step7 자동화 객관 게이트.

---

## CRITICAL: Canonical State + Event Log 계약

Harness 의 최신 상태 판단은 자유형 progress 문서가 아니라 `.harness/state.json` 을 기준으로 한다. `.harness/events.ndjson` 는 append-only 이력이며, progress/review/QA/overview 는 사람이 읽는 projection 이다.

### 필수 파일

- `.harness/state.json` — 최신 포인터. 필수 필드: `slug`, `mode`, `current_step`, `current_chunk`, `chunks_total`, `latest_review`, `latest_qa`, `loop_counters`, `blocked`.
- `.harness/events.ndjson` — 순서 보장 이벤트. 필수 이벤트: `workflow_started`, `step_changed`, `review_completed`, `qa_completed`, `blocked`, `handoff_exported`.

### 갱신 규칙

1. step 전환, Step5 리뷰 완료, Step6 QA 완료, BLOCKED 발생, handoff export 생성 시 먼저 `events.ndjson` 에 1줄 append 한다.
2. append 직후 `state.json` 의 최신 포인터와 loop counter 를 갱신한다.
3. `progress-<slug>.md` 상단 summary 는 `state.json` 값과 일치해야 한다. 불일치 시 `state.json` 을 기준으로 progress 를 정정하거나 워크플로우를 중단한다.
4. run 번호·loop counter 는 한 곳(`state.json`)에서만 증가한다. 사람이 직접 progress 블록 순서를 보고 최신 상태를 추론하지 않는다.
5. `events.ndjson` 에 이미 기록된 run 번호보다 작은 run 이 뒤늦게 append 되거나 같은 run 번호가 재사용되면 즉시 중단한다.

### BLOCKED enum

모든 BLOCKED 라벨은 다음 enum 중 하나만 사용한다.

`DEPENDENCY_MISSING | EVIDENCE_GATE_FAIL | PERMISSION_DENIED | GUIDE_MISSING | ENV_UNREACHABLE | CONTRACT_MISSING | TDD_MISSING | OTHER`

enum 외 값은 정책 위반이다. `CONTRACT_MISSING` 은 도메인/상위 계약이 없어 구현하면 경계를 깨는 경우, `TDD_MISSING` 은 Step4 전 red artifact 가 없는 경우에 사용한다.

---

## CRITICAL: Learning Prepend 계약 (QA/customer `harness-*` agent 공통)

호출자 Codex 가 `harness-*` sub-agent 를 **사용 가능한 sub-agent/helper 도구로 호출하기 직전** 4단계를 **반드시 순서대로** 수행. 하나라도 누락 시 호출 자체 금지 (도우미가 학습을 못 본 채 작동 = 학습 시스템 무력화).

### 단계

1. **학습 파일 경로 식별** (공용 only): `~/.codex/skills/harness/agents/learning/<agent-name>.md`
2. **파일 읽기 도구로 실제 본문 읽기**. 기억·요약·추측 금지. 파일 없으면 "(빈 파일)" 명시.
3. **호출 prompt 의 맨 앞에 아래 `Required Header` 양식 그대로 prepend**. 본문 통째로 붙임 — 잘라내지 않음.
4. **본문 끝에 본 작업 요청 붙임.** 도우미 prompt 순서: `Required Header → 본 작업`.

### Required Header 양식

```
## Prior Learning (READ FIRST — DO NOT SKIP)

**학습 파일 (공용)**: <절대경로>/agents/learning/<agent-name>.md

### 공용 학습 본문
<위 공용 파일을 Read 한 본문 전체 — 빈 파일이면 "(빈 파일)" 명시>

### 적용 의무
- 본 작업 시작 전 위 본문을 처음부터 끝까지 읽고, 본 작업에 적용 가능한 항목을 머릿속에 정리한다.
- 작업 중 학습과 충돌하는 결정을 내리면, 응답 본문에 "기존 학습 X 와 충돌. 이유: ..." 명시.
- 응답 마지막에 `## Learning Proposals` 섹션 (변경 없으면 생략 — templates/learning-proposal.md 형식).
- 학습 파일을 직접 Edit/Write 하지 않는다. 제안만 한다.

---

## 본 작업
<원 요청 본문>
```

### 도우미 측 검증 (자체 거부 게이트)

각 `harness-*` helper는 prompt 첫 200줄 안에 `## Prior Learning (READ FIRST` 헤더 부재 시 즉시 한 줄 거부: `[BLOCKED] Prior Learning header 누락 — workflow.md "Learning Prepend 계약" 위반.` 그 외 작업 일체 금지.

### 호출자 Codex 직접 수행 금지

helper/sub-agent 호출 없이 호출자 Codex 가 `harness-qa-engineer` 또는 `harness-customer-user` 페르소나 작업을 직접 수행하는 것은 금지한다. sub-agent/helper 도구를 사용할 수 없으면 공용 학습 파일을 읽어 직접 대체하지 말고 `BLOCKED / DEPENDENCY_MISSING` 으로 기록한다.

### 적용 범위

`harness-qa-engineer` · `harness-customer-user` 2개 페르소나 도우미만 적용. 외부 리서치는 shared `$deepresearch` skill 을 사용하므로 본 계약 비대상. 일반 skill/agent (`plan`, `tdd`, `code-review`, `security-review`, `build-fix` 등) 는 harness 전용이 아니므로 본 계약 비대상. 외부 CLI(Codex) 도 sub-agent 아니므로 적용 안 됨.

---

## CRITICAL: noask 정책 문구 가공 금지

호출자 Codex 가 BLOCKED·FAIL·UNKNOWN 처리 시 다음 표현으로 "완료" 처럼 윤색하는 것 **금지**. 위반 시 즉시 워크플로우 중단 + `report-<slug>.html` 에 위반 기록 (사용자 노출은 donot.md 기밀 처리 규약 준수).

**금지어 (정확 일치 + 의미 일치 모두 차단)**:
- `완료 처리` / `약식 완료` / `정상 종료 처리`
- `스킵 처리` / `이번엔 스킵` / `간단하니 생략`
- `통과 가정` / `통과로 간주` / `사실상 통과`
- `자체 판단으로 진행` / `메인이 직접 확인했으므로 OK`

BLOCKED 자동 처리 결과는 다음 4개 중 **하나뿐** (SKILL.md 자동 결정 매핑 표 참조):

1. **자동 재시도 1회 → 성공 (PASS)** — `qa-<slug>.md` 에 재시도 증거 4필드 (`retry_attempted` / `retry_enum_diagnosed` / `retry_action` / `retry_result`) 첨부.
2. **재시도 fail + 다중 슬러그 → (D) `paused-by-blocked`** — progress 마킹 + 다음 슬러그 자동 시작.
3. **재시도 fail + 단일 슬러그 → (C) 워크플로우 중단** — progress 마킹 + report 사유 기록 후 종료. **commit/push/complete 진입 절대 금지.**
4. **동일 사유 5회 누적 → request_user_input 또는 일반 질문** (noask 정책 2번째 예외).

"완료 처리" / "약식 완료" 라는 옵션은 워크플로우에 정의되어 있지 않음. (C) 중단을 "완료" 로 라벨링하는 모든 시도 = 정책 위반.

자체 검증: 매 BLOCKED 회차 보고 직후 `progress-<slug>.md` grep:
```
grep -nE "완료 처리|약식 완료|스킵 처리|통과 가정|간단하니 생략|자체 판단으로 진행" .harness/progress/progress-<slug>.md
```
1건 매치 시 즉시 워크플로우 중단 + 내부 progress 에 매치 줄 인용 (사용자 노출은 추상 메시지).

---

## CRITICAL: Step 스킵·무시 금지

**Step 자체에 정의된 규칙(워크플로우 다이어그램 명시 조건 분기)에 의한 것이 아니면, 어떤 step 도 스킵·통합·무시 금지.**

- 허용되는 step 내장 규칙:
  - step5 LGTM:NO → step3 루프
  - step6 FAIL → step3 루프, BLOCKED → 자동 분기. 같은 사유 enum 5회 누적 시에만 사용자 결정 (A/B/C)
  - step6 BLOCKED 동일 사유 5회 후 (B) "사용자 명시 위험 수용" — *사용자 자율 위험 수용의 유일한 예외 경로*. `QA_NOT_PERFORMED_USER_ACCEPTED_RISK` 로 기록하며 PASS/완료 라벨 금지.
  - step7 "전체 1회만 실행" 규칙 (github/commit 직전 게이트)
  - step8 commit/push 실패 → 사용자 결정 (재시도 / 브랜치 수정 / 로컬 commit 만 완료)
  - "git remote 없으면 complete 로" 분기
- 임의 판단("간단하니 생략", "이전에 했으니 패스", "한 번에 합치자", "사용자가 급하다고 했으니 점프") 모두 위반.
- 사용자가 step 규칙 외 스킵 요청 시 거절, 워크플로우 규칙 준수 (위 step6 BLOCKED 동일 사유 5회 후 (B) 위험 수용 경로는 내부 정의 분기이므로 거절 대상 아님).
- 위반 시 즉시 중단 + 내부 progress 에 "step{N} 누락" 기록 (사용자 노출은 추상 메시지).

---

## 흐름

```
step1. harness 초기화
   ↓
step2. 도메인 설계
   ↓
step3. 구현 계획 (Chunks 임계값 판정 — 통과 시 chunks-overview + chunk-1 plan, 미통과 시 단일 plan)
   ↓
step4. 구현 (Chunks 모드면 현 chunk_i 만)
   ↓
step5. 리뷰 (chunks 모드면 chunk_i 변경 파일만, 회송 카운터 chunk 별 독립 5회)
   │
   ├─ LGTM:NO ──> step3 (구현 계획 수정)
   │              * 무제한 반복 — 서로 다른 문제로 LGTM:NO 가 누적되는 한 계속 진행
   │              * **동일 문제** (같은 (유형 enum, 파일경로) 튜플) 5회 반복 시에만 → 중단
   │              * 매번 다른 결함 해결 중이면 중단 안 됨
   │
   └─ LGTM:YES
        ↓
step6. QA 테스트
   * **선행**: test-guide-<slug>.md 작성/갱신 후 도우미에 참조시킴
   │
   ├─ FAIL ──> step3 (구현 계획 수정)
   │           * 무제한 반복 — 서로 다른 결함 누적 가능
   │           * **동일 결함** (같은 (유형 enum, 파일경로) 튜플) 5회 반복 시에만 → 중단
   │
   ├─ BLOCKED ──> **자동 결정 분기** (사용자에게 묻지 않음)
   │              * 1차: 자동 재시도 1회 (의존성·환경 재점검 + 도우미 재호출)
   │              * 재시도 fail + 다중 슬러그 → (D) paused-by-blocked + 다음 슬러그
   │              * 재시도 fail + 단일 슬러그 → (C) 자동 중단
   │              * 매 BLOCKED 회차마다 progress 의 step6 BLOCKED 누적 카운터 + 사유 enum 기록
   │              * **동일 사유 BLOCKED 5회 누적 시에만 → request_user_input 또는 일반 질문** (noask 정책 2번째 예외)
   │                · (A) 환경 수정 후 재시도 / (B) 사용자 명시 위험 수용 / (C) 워크플로우 중단
   │              * 산출물 게이트 (5b) 1축 NO 시 자동 BLOCKED 강등 — 사유 enum = EVIDENCE_GATE_FAIL
   │              * BLOCKED 사유 enum 8종: DEPENDENCY_MISSING | EVIDENCE_GATE_FAIL | PERMISSION_DENIED | GUIDE_MISSING | ENV_UNREACHABLE | CONTRACT_MISSING | TDD_MISSING | OTHER
   │
   ├─ UNKNOWN ──> 슬러그 `paused-by-unknown` 마킹 + report 사유 기록
   │              * sub-agent/helper 도구 부재 시 `BLOCKED / DEPENDENCY_MISSING`
   │              * harness-qa-engineer 호출 0회 + PASS 라벨 시 자동 BLOCKED 강등
   │              * noask 무인 모드면 다음 슬러그 자동 시작
   │
   └─ PASS (라벨 추출 규칙 충족 + 산출물 게이트 4축 YES + self-PASS 아닐 때만 인정)
        ↓
   ┌─ Chunks 모드 분기 (step3 임계값 통과 시):
   │   chunk_i git commit + push 자동 (step8 절차) → chunks-overview 의 chunk_i 상태 `done`
   │   if chunk_i < N: chunk_i += 1 → step3 의 *다음 chunk plan 작성* → step4 (chunk_i+1) ... 반복
   │   if chunk_i == N: 아래 step7 진입
   │
   └─ 단일 모드 또는 Chunks last chunk PASS:
        ↓
step7. 커스터머 유저 테스트
   * 전체 워크플로우 중 **단 1회만** 실행 — github/commit 직전 마지막 게이트
   * step3 ↔ step6 루프 횟수와 무관. 모든 구현 끝난 시점에 1회만 도달
   * **선행**: 동일한 test-guide-<slug>.md 참조 (step6 갱신 최신본)
   * 게이트 아님 — 결과 보고만 하고 다음 단계로
        ↓
step8. git remote 있나?
        │
        ├─ YES → step8. commit / push
        │          ├─ 성공 → complete 진입 전 사용자 확인 → complete
        │          └─ 실패 → 사용자 결정 요청 (재시도 / 브랜치 수정 / 로컬 commit 만 완료)
        │
        └─ NO  ───────────────────────→ complete 진입 전 사용자 확인 → complete

noask 예외 — 단 2곳 (그 외 모두 자동 결정):

(예외 1) complete 진입 전 step7 결과 처리 확인:
   호출자 Codex 가 request_user_input 또는 일반 질문 호출.
   ├─ A. 그대로 complete 진행 (개선안 report 에 요약)
   ├─ B. 일시정지 (.harness/.pending-step7-review 마커, 사용자가 재호출)
   └─ C. 개선안으로 신규 워크플로우 자동 시작
        ├─ 현 워크플로우는 complete 완료 처리 (report 작성 + 종료)
        ├─ customer-<slug>.md 의 권고/있었으면/없었으면 합성 → 신규 한 줄 목표
        ├─ 신규 progress 에 auto_triggered_from: <원본 slug> 기록
        └─ 무한 chain 차단: 신규 워크플로우 step7 게이트에선 C 비활성 (A/B 만)

(예외 2) step6 *동일 사유* BLOCKED 5회 누적:
   매 BLOCKED 회차마다 progress 의 `step6 BLOCKED 누적` 카운터 + 사유 enum 누적.
   같은 사유 enum 5회째 발생 시에만 request_user_input 또는 일반 질문 호출.
   ├─ A. 환경 수정 후 재시도
   ├─ B. 사용자 명시 위험 수용 (`QA_NOT_PERFORMED_USER_ACCEPTED_RISK`, PASS/완료 라벨 금지)
   └─ C. 워크플로우 중단
   * 4회까지는 자동 결정 — 재시도 1회 → 다중 슬러그면 (D) paused-by-blocked, 단일 슬러그면 (C) 자동 중단
   * 서로 다른 사유로 5회 누적은 트리거 아님
```

**"동일 문제 / 동일 결함" 판정 (CRITICAL):** 동일 파일 경로 + 동일 오류 유형(13종 enum). 표현이 달라도 유형·위치 동일 시 동일. step5 와 step6 카운터 독립.

**중단 조건 (CRITICAL — 흔히 오해되는 부분)**:
- "5회 LGTM:NO" / "5회 FAIL" *자체* 로는 중단되지 **않음**.
- 중단 조건은 **"동일 (유형 enum, 파일경로) 튜플의 LGTM:NO / FAIL 누적 5회"**.
- 매 회차마다 *다른 결함* 해결 중이면 무한 반복 가능 (예: TYPE_ERROR @ a.ts, NULL_REFERENCE @ b.ts ...) — *각 회차마다 진척 중* 이라는 신호.
- 같은 (유형, 파일) 조합이 5회째 등장 시 중단. *동일 접근의 한계* 신호.
- 동일 문제 판정은 progress 파일 `## Loop Counter` 섹션 매 회차 라벨로 갱신, step5/6 결정 보고의 "이번 루프 회차" 필드에 *동일 문제 유형 enum = YES | NO* 명시 필수.

**"5회" 임계값 선택 이유:** 비용 보수성 — 1 루프당 Codex 호출 + 컨텍스트 재처리 비용 누적. 일반 LLM tool-call 산업 상한(약 15회) 대비 보수적 5회. *같은 문제로* 5회 실패 = *동일 접근의 한계*.

---

## CRITICAL: 회송 경로 실행 보장 (step5 LGTM:NO / step6 FAIL → step3)

분기 라벨이 다이어그램에 있어도 호출자 Codex 가 자율 판단으로 우회하면 회송 미발동. 다음 4개 메커니즘이 *모두* 작동해야 회송 실제 발동.

### (1) 다음 step 결정 보고 — 게이트

step5/step6 종료 직후 호출자 Codex 가 채팅에 5필드 결정 보고 출력. 출력 없이 다음 step 호출 시 step 스킵 위반. 양식: [steps/step5-review.md](steps/step5-review.md#critical-다음-step-결정-보고-게이트--출력-없이-다음-step-진입-금지) / [steps/step6-qa.md](steps/step6-qa.md#critical-다음-step-결정-보고-게이트--출력-없이-다음-step-진입-금지).

### (2) 루프 카운터 누적 — progress 파일 표준화

`state.json.loop_counters` 를 먼저 갱신한 뒤 `progress-<slug>.md` 에 다음 `## Loop Counter` 섹션을 projection 으로 복사한다. step5/6 fail 보고 시 카운터 증가, 다음 step 결정 보고의 "이번 루프 회차" 필드에 그 값 인용. 누락 시 5회 자동 중단 게이트 미발동 = 정책 위반.

```markdown
## Loop Counter
- step5 LGTM:NO 누적: <N>회
  - 직전 회차 결함 유형·파일: <유형 enum> @ <파일경로>
  - 동일 문제 여부 판정: 직전 회차와 (유형 + 파일경로) 조합이 동일 = YES, 다르면 NO
- step6 FAIL 누적: <M>회
  - 직전 회차 결함 유형·파일: <유형 enum> @ <파일경로>
  - 동일 결함 여부 판정: ...
- step6 BLOCKED 누적: <B>회
  - 직전 회차 BLOCKED 사유: <사유 enum>
  - 동일 사유 여부 판정: 직전 회차와 사유 enum 일치 = YES, 다르면 NO
  - 동일 사유 5회 누적 시 → request_user_input 또는 일반 질문 (noask 2번째 예외)
```

세 카운터 모두 독립. 서로 공유 안 함.

### (3) 자체 수정 우회 차단

step5/6 결정 보고의 자기 점검 항목 ("이번 fail 후 호출자 Codex 가 코드/구현 파일을 직접 수정했는가?") 이 YES 면 즉시 워크플로우 중단. fail 후 호출자 Codex 가 코드 직접 고치고 LGTM:YES / PASS 처리하는 anti-pattern 차단. 수정 의도 시 반드시 step3 회송 → 정식 plan 반영.

**자기 점검의 객관 검증 (git diff 게이트, CRITICAL — 정직성 의존 제거)**: 자기 점검 항목 값을 호출자 Codex 자체 답에 의존하지 않음. step5/6 결정 보고 출력 직전 자동 실행:

```bash
git diff <step4_commit_sha>..HEAD -- <step4 변경 파일 목록>
```

- `<step4_commit_sha>` = step4 진입 시 `git rev-parse HEAD` 결과를 `progress-<slug>.md` 에 자동 기록한 값.
- diff 가 비어 있지 않으면 **자체 수정 = YES 자동 라벨**. 호출자 Codex 자기 점검 값 NO 면 *불일치* — 즉시 워크플로우 중단 + 내부 progress 에 "정책 위반: git diff 와 자기 점검 불일치" 기록.
- diff 비어 있으면 자체 수정 = NO 확정.

이로써 정직성 의존 없이 객관 게이트만으로 자체 수정 우회 차단.

### (4) 회송 시 결함 전달 양식 — step3 의 입력

step5/6 → step3 회송 시 직전 회차 결함 본문을 step3 의 plan skill 호출 prompt 에 prepend. 양식·절차: [steps/step3-impl-plan.md](steps/step3-impl-plan.md#회송-진입-모드-절차-critical--no-op-회송-차단) "회송 진입 모드 절차". 결함 항목이 새 plan 의 변경 대상에 실제 차이로 반영되어야 step4 진입 허용 — *no-op 회송* 최종 차단선.

### (5) 결함 유형 enum — 라벨 회피 차단 (CRITICAL)

"동일 문제 여부" 판정의 *유형* 라벨이 호출자 Codex free-form 이면 같은 결함을 다른 유형으로 적어 5회 임계 우회 가능. 다음 13종 enum 중 하나로만 라벨링:

```
TYPE_ERROR | NULL_REFERENCE | PERMISSION_DENIED |
RESOURCE_NOT_FOUND | RACE_CONDITION | LOGIC_ERROR |
IO_FAILURE | TIMEOUT | API_CONTRACT | SECURITY |
TEST_COVERAGE | BUILD_FAILURE | OTHER
```

규칙:
- enum 외 값 거부 (progress 파일 검증 시 즉시 정책 위반 기록).
- 동일 문제 판정: `(유형 enum, 파일경로 normalized)` 튜플 동일 시 YES. `파일경로 normalized = repo 상대경로 + 소문자`.
- **OTHER 5회 누적 시 자동 사용자 alert** — OTHER 는 매번 새 fingerprint 로 분리되지 않으므로 라벨링 실패 신호. report 에 "OTHER 누적으로 라벨링 정밀도 부족" 기록.
- step5 와 step6 enum 카운터 독립.

### 적용 검증

위 5개 메커니즘이 모두 작동하면 다음 5개 시나리오가 통과 (자체 회귀 검증):

1. LGTM:NO 1회 → step5 결정 보고 출력 → step3 회송 → plan prompt 에 직전 review 본문 prepend → 새 implementation 변경분 생성 → step4 진입.
2. FAIL 1회 → step6 결정 보고 + Loop Counter 1회 누적 → step3 회송 → plan prompt 에 직전 qa fail 본문 prepend.
3. 동일 문제 5회 반복 → 자동 중단 + report 사유 기록.
4. 자체 수정 우회 시도 → 자기 점검 YES → 워크플로우 중단.
5. no-op 회송 시도 → step3 "변경분 검증 게이트" 차단 → 결함 반영 요구.

## Step 이름 + 상세 절차 링크

| step | 한 줄 | 상세 |
|------|------|------|
| step1 | harness 초기화 | [steps/step1-init.md](steps/step1-init.md) |
| step2 | 사용자 요청을 리서치 근거가 필요한지 판단한 뒤 구체적 전문적 계획으로 정리 (architecture 가 보고 구현 계획 가능하도록) | [steps/step2-domain.md](steps/step2-domain.md) |
| step3 | 구현 계획 작성 | [steps/step3-impl-plan.md](steps/step3-impl-plan.md) |
| step4 | 구현 | [steps/step4-impl.md](steps/step4-impl.md) |
| step5 | 리뷰 + LGTM 판정 | [steps/step5-review.md](steps/step5-review.md) |
| step6 | QA 테스트 (PASS / FAIL 게이트) | [steps/step6-qa.md](steps/step6-qa.md) |
| step7 | 커스터머 유저 테스트 (전체 1회) | [steps/step7-customer.md](steps/step7-customer.md) |
| step8 | git commit / push (remote 있을 때만) | [steps/step8-commit.md](steps/step8-commit.md) |
| complete | 결과 정리 | [steps/complete.md](steps/complete.md) |

---

## 테스트 가이드 문서 (`.harness/test-guide-<slug>.md`)

step6 에서는 QA 도우미가 동일 기준으로 검증하도록 호출자 Codex 가 step6 의 1단계로 작성하는 입력 문서다. step7 에서는 커스터머 도우미에게 테스트 진행 방법으로 전달하지 않고, 필요한 경우 숨은 범위/채점표(`## Hidden Oracle (NOT USER INSTRUCTIONS)`) 로만 격리한다. 커스터머 도우미의 user-facing 입력은 production 실행 정보와 `어떤 프로그램인지 / 어떤 기능이 있는지 / 기본적으로 어떻게 사용하는지` 정도로 제한한다.

양식·작성 재료·갱신 규칙: [test-guide-format.md](test-guide-format.md)

---

## 부록: Codex 리뷰 방법

`codex` CLI 는 Windows native (npm-installed) 라 Bash 에서 직접 호출. 자세히: [codex-review-procedure.md](procedures/codex-review-procedure.md).

**4단계 흐름**:

1. **리뷰 대상 파일 경로 목록을 file-list MD 로 저장**:
   ```
   .harness/reviews/review-<slug>-file-list.md
   ```
   *경로만* (각 줄 `- <path>`). focus·instructions·코드 본문 일체 금지.

2. **`codex exec` 직접 호출** (Bash):
   ```bash
   codex exec --sandbox workspace-write \
     ".harness/reviews/review-<slug>-file-list.md 에 적힌 파일들 전부 리뷰해줘. 리뷰 결과는 .harness/reviews/codex-review-<slug>-result.md 에 작성해줘."
   ```
   **위 한 줄 프롬프트 외 추가 텍스트 절대 금지.** Codex 가 file-list.md 를 자체 file-read 로 읽고 자체 형식으로 result 작성.

3. **결과 파일 Read**: `.harness/reviews/codex-review-<slug>-result.md`. 비어 있거나 *"리뷰 못 함"* 이면 STOP, 호출자/사용자 보고. fake 응답 생성 금지.

4. **호출자에게 verbatim 반환** + result 절대경로 한 줄 보고.

**Codex fallback 시 주의:** Codex 인증 실패(exit 2)는 fallback 금지이며 `BLOCKED / DEPENDENCY_MISSING` 으로 멈춘다. quota 소진(exit 3)만 `code-review` skill 또는 `code-reviewer` agent fallback 이 가능하다. 이 경우 **Codex가 구현·리뷰 모두 수행** → self-review bias 제거 효과가 사라지므로 호출자 Codex 는 `fallback_used` 필드를 명시하고, fallback 결과는 `LGTM:YES` 로 승격하지 않는다.
