---
name: harness-run
description: Run the Harness 9-step DDD/TDD/audit workflow in Codex. Use when the user explicitly asks for harness-run, Harness workflow execution, DDD/TDD workflow automation, Mock-free implementation with QA/review/audit gates, or porting/running the Harness skill in Codex.
---

# harness-run — DDD/TDD/Audit 9-step workflow (Codex 적응본)

> Codex discovery 를 위해 최소 frontmatter 만 유지한다. Claude Code 플러그인 frontmatter 는 제거했고, 본문 정책은 Codex 호출 모델에 맞게 변환했다.

## v2 출시 노트 (audit 강화 — 2026-05-24)

본 skill 은 v5 (9 단계 자동 워크플로우 + 자가 수정) 위에 **audit 강화 v2** 가 누적 적용된 상태다. v5 본문은 변경 없이 유지하고 다음만 추가했다.

- **step 7 audit = 1차 self + 2차 external Codex 2단 구조**. 둘 다 자동 실행, raw 산출물 보존, 종합 → 자가 수정 → 판정 4단계 (`PASS` / `PASS_WITH_WAIVERS` / `PARTIAL` / `FAIL`). 절차는 [docs/steps/07-audit.md](docs/steps/07-audit.md) 와 `~/.codex/skills/harness-run/agents/harness-engineering-auditor.md` (Codex 최상위 agents 폴더) 참조.
- **회차 유형 (`run-mode`)**: step 1 에서 `new-domain` / `feature-add` / `refactor` 자동 감지 + 1회 통보. 유형별 DDD/TDD/커버리지 강제 정도가 다르고, 강제 항목 생략 시 `waiver.md` 의무. 본문은 [docs/run-modes.md](docs/run-modes.md).
- **non-waivable invariant 7개**: 회차 유형 무관 절대 생략 금지 게이트 (외부 의존성 감지·step 5 codex 실호출·step 7 1+2 audit·민감 파일 자동 제외·푸쉬 금지·객체/UI 분리 자동 리팩토링·external-dependencies.md 산출). 위반 시 자동 `FAIL`. [docs/run-modes.md §non-waivable](docs/run-modes.md#non-waivable-invariant-7개) 참조.
- **신규 산출물**: `01-detect/external-dependencies.md`, `01-detect/run-mode.md`, `<step>/waiver.md` (필요 시), `07-audit/1st-self-audit.md`, `07-audit/2nd-external-audit.md`, `07-audit/2nd-external-audit-file-list.md`, `07-audit/findings.md` (1+2 종합).
- **에이전트 single source of truth = `~/.codex/skills/harness-run/agents/` (v2.1)**: 본 skill 의 sub-agent 정의 4개 (`harness-engineering-researcher` / `harness-engineering-qa` / `harness-engineering-auditor` / `harness-customer-user`) 는 **`~/.codex/skills/harness-run/agents/<name>.md` 에만 존재**. skill 내부에 중복본 두지 않음 (Codex 가 Codex 재귀 호출의 agent prompt 호출 시 본 경로만 본다). step 1 진입 시 메인 Codex 가 본 폴더에 필요한 에이전트가 모두 존재하는지 *presence check* 만 수행 (복사·이동 안 함). 없으면 BLOCKED + 사용자 안내 (skill 재설치 권장). 절차 본문은 [docs/steps/01-detect.md § 에이전트 presence check](docs/steps/01-detect.md#에이전트-presence-check-v2-신규--매-회차-자동-점검).
- **learning 파일 위치 (v2.1)**: 학습 누적 파일은 `~/.codex/skills/harness-run/learning/<agent-name>.md` 에 보관 (Codex 최상위 agents 폴더 산하 — skill 외부 single source of truth, 이전 `agents/learning/` → `learning/` → 최종 `~/.codex/skills/harness-run/learning/` 이동). 메인 Codex 가 매 호출 시 Read → prompt 에 prepend.

v5 의 5 예외 enum · audit 자가 수정 한도 (산출물 2회 + 스킬 2회) · 푸쉬 금지 · Mock 금지 · §2.5 코드 구조 정책은 그대로 유지.

---

## 호출 형식

본 skill 은 다음 두 가지 형태로만 호출한다.

1. 권장: Codex 대화창에서 `/prompts harness-run <자연어 목표>`
2. 비대화형: `codex exec "$(cat ~/.codex/prompts/harness-run.md | sed 's/{{ARGS}}/<자연어 목표>/')"`

다른 호출 경로 발견 시 step 1 진입 전 종료한다.

```text
[harness-run] 본 skill 은 위 두 형식 전용. /prompts harness-run 또는 codex exec 사용 요망.
```

---


## 기본 정책: 단일 자동 모드 (noask)

> `/harness:run` (또는 backward-compat `/harness`) 호출 = "끝까지 자동으로 돌려라" 명시 위임 = 모든 자동 결정 사용자 사전 승인. 결정 지점에서 막혀도 묻지 않음 — 합리적 기본값 진행. 사용자에게 묻는 경우는 아래 명시 예외만.

### CLI 표준 입력 대기 호출 허용 예외 (이 5 가지만 — 단일 정합 표)

본 skill 의 회송·실패 한도 결정은 모두 다음 5 예외 enum 으로만 사용자에게 묻는다. SKILL.md · workflow.md · step 문서 · agent 정의 모두 본 표를 참조한다.

| # | 예외 enum | 트리거 조건 | 옵션 |
|---|---|---|---|
| 1 | `EXT_DEP_PROD_BLOCKED` | step 1 · step 6 — production credential / base URL 감지 | A: sandbox 전환 후 재호출 / B: 작업 종료 |
| 2 | `TDD_5X_SAME_SCENARIO` | step 3 — 같은 사이클 5회 연속 FAIL | A: 도메인 모델 재검토 (step 2 회송) / B: 시나리오 SKIP / C: 중단 |
| 3 | `QA_OR_REVIEW_5X_SAME_DEFECT` | step 4 QA FAIL 또는 step 5 Codex LGTM:NO — **동일 결함 (유형 enum + 파일 경로)** 5회 누적 | A: step 3 재진입 1회 추가 / B: 결함 무시 통과 / C: 중단 |
| 4 | `AUDIT_LIMIT_EXCEEDED` | step 7 — 산출물·스킬 자가 수정 각 2회 한도 초과 후에도 AUDIT_FAIL | A: 재시도 1회 추가 / B: 결함 무시 통과 / C: 중단 |
| 5 | `SUBAGENT_RUNTIME_BLOCKED` | 모든 step — codex auth 만료·quota 소진·필수 도구 부재로 sub-agent 가 BLOCKED 반환 시 (§ 6 런타임 계약) | A: 재시도 (사용자가 환경 수정 후) / B: skip + 다음 단계 / C: 중단 |

서로 다른 결함의 5회 누적은 중단 사유 **아님**. 동일성 판정은 `(결함 유형 enum, 파일 경로 normalized)` 튜플 일치.

그 외 모든 결정은 `CLI 표준 입력 대기` 호출 금지. 합리적 기본값 결정 + `log.md` 1 줄 로깅.

### 호출 직후 1회 통보 (질문 아님)

`/harness:run` (또는 `/harness`) 호출 직후 step1 진입 전 단순 통보 1회 출력 (응답 대기 안 함):

```
[harness] 단일 자동 모드 시작. 9단계 워크플로우 끝까지 자동 진행.
- step 1: 언어·프레임워크 감지 + 외부 의존성 점검
- step 2: DDD 도메인 모델링 (Event Storming + Bounded Context + Aggregate)
- step 3: TDD 루프 (Red·Green·Refactor, Mock 금지)
- step 4: QA 검증 (빌드·테스트·80%+ 커버리지·정적 분석)
- step 5: 코드 리뷰 (codex-reviewer)
- step 6: 고객 테스트 (harness-customer-user)
- step 7: audit + 자가 수정 (산출물 + 스킬 파일)
- step 8: summary.md + summary.html 보고서
- step 9: 커밋 (푸쉬 안 함, 사람이 직접)
사용자 결정 요청은 다음 5 가지에서만:
  ① EXT_DEP_PROD_BLOCKED (외부 의존성 production)
  ② TDD_5X_SAME_SCENARIO (TDD 5회 연속 동일 실패)
  ③ QA_OR_REVIEW_5X_SAME_DEFECT (QA/리뷰 5회 누적 동일 결함)
  ④ AUDIT_LIMIT_EXCEEDED (audit 2회 한도 초과)
  ⑤ SUBAGENT_RUNTIME_BLOCKED (sub-agent BLOCKED 반환)
모든 자동 결정은 .harness/runs/<현재 회차>/log.md 에 기록됩니다.
```

---

## CRITICAL: 핵심 정책 (충돌 시 본 SKILL.md 우선)

### 1. 외부 의존성 정책 (v4 강제)

| 상황 | 동작 |
|---|---|
| in-memory 가능 (DB·이메일 등) | **in-memory Repository (= Fowler 분류상 Fake)** 사용 |
| in-memory 불가 + sandbox/test endpoint 존재 | sandbox/test endpoint 강제 사용 |
| 외부 의존성 있음 + in-memory 불가 + sandbox/test endpoint 없음 | **BLOCKED** + 사용자 보고 후 종료. 실제 인프라 호출 금지 |
| sandbox 도 없음 + production credential·base URL 감지 | **즉시 BLOCKED** + 사용자 보고 + CLI 표준 입력 대기 (예외 ①) |
| 결제·외부 API production endpoint | **무조건 BLOCKED** (sandbox/test 전환 후 재호출 전까지 진행 금지) |

### 2. 테스트 더블 정책 (Fowler TestDouble 분류)

본 skill 은 Martin Fowler 의 [TestDouble](https://www.martinfowler.com/bliki/TestDouble.html) 정의를 채택. *"InMemoryTestDatabase 는 Fake 의 좋은 예"* — **in-memory Repository = Fake 의 한 형태**.

| 더블 종류 | 본 skill 정책 | 사유 |
|---|---|---|
| **Mock** (verify behavior) | **금지** | brittle tests, refactor 회귀 위험. `Mock`/`MagicMock`/`mockito`/`jest.mock`/`sinon.stub` 등 일체 |
| **Stub** (canned response) | **금지** | 도메인 흐름이 stub 응답에 결속되면 검증 가치 없음 |
| **Spy** (recording stub) | **금지** | Mock 의 하위 카테고리 |
| **Fake — in-memory Repository / Queue / Store** | **허용** | 도메인 객체와 동등 의미. 실제 코드 + shortcut |
| **Fake — 외부 시스템 시뮬레이터 (자작 결제 mock 등)** | **금지** | sandbox 가 산업 표준 |
| **Dummy** (placeholder) | 사용 가능 | 도메인 검증과 무관 |

**핵심 규칙**:
- 도메인 객체·Aggregate·Entity·VO 는 **실제 객체** 로 생성. 절대 mock 안 함.
- Repository 는 **in-memory 구현체 (= Fake)** 로 인터페이스 갈아 끼움.
- **외부 인프라** (DB·이메일·결제·외부 API) 는 in-memory adapter 또는 sandbox/test endpoint 만. 외부 시스템을 흉내 내는 자작 Fake 금지.
- *"Mock"* 이름이 들어간 라이브러리도 실제 semantics 가 in-memory Fake 면 허용 (예: `fakeredis` 류). **단, `mockito`·`unittest.mock`·`jest.mock`·`sinon` 등 verify-behavior 도구는 이름 불문 금지.**

### 3. 자가 수정 한도 정책

- **TDD 사이클 한도**: Aggregate 가 가진 시나리오·동작 개수만큼. 5회 연속 실패 시 멈추고 사용자 보고.
- **audit 자가 수정 한도**: 산출물 자가 수정 2회 + 스킬 파일 자가 수정 2회. 둘 다 초과 시 사용자 보고 (예외 ④ `AUDIT_LIMIT_EXCEEDED`).
- **스킬 자기 개선 자동성 (제한된 자동)**:
  - **자동 수정 whitelist**: `docs/steps/*.md`, `templates/*.tpl`, `~/.codex/skills/harness-run/learning/*.md` (skill 외부 최상위 — 학습 누적 파일만) 만.
  - **자동 수정 금지 (manual approval required)**: `SKILL.md`, `docs/workflow.md`, `docs/code-structure.md`, `docs/run-modes.md`, `~/.codex/skills/harness-run/agents/<name>.md` (skill 외부 최상위 위치 + frontmatter 변경 위험). 이 파일에서 결함 발견 시 `Verdict: BLOCKED` + 사용자 승인 요청.
  - 변경 로그 `07-audit/skill-improvement.md` 의무 기록. 자동 커밋 안 함 (사람이 별도로).
  - OWASP ASI06 8-step 안전 가드 (`docs/steps/07-audit.md` 참조) 모두 통과해야만 자동 수정 적용.

### 4. 푸쉬 금지

skill 은 **절대 git push 하지 않음**. step 9 는 commit 까지만. 푸쉬는 사람이 직접.

### 5. HTML 산출물 규칙

`summary.html` 작성 시 **`C:\Users\NX3GAMES\.codex\html-document-rules.md`** 를 먼저 읽고 따른다. 본 SKILL.md 는 위치만 명시 — `.harness/runs/<run-id>/summary.html` (run-scoped).

### 6. 서브에이전트 공통 런타임 계약

| 상황 | 동작 |
|---|---|
| 로그인 필요 (codex auth 만료 등) | 로그인 안내 출력 + 사용자 처리 대기 + 처리 후 재시도 |
| quota·rate limit 소진 | 사유 안내 후 사용자 대기 (재충전·시간 경과) + 재시도 |
| 필수 도구 부재 (gh·codex·WebSearch 미가용) | BLOCKED 보고 + 설치·활성화 안내 + 사용자 처리 대기 |
| 쓰기 권한 실패 | 경로·권한 보고 후 사용자 대기 |
| 그 외 알 수 없는 실패 | STOP, log.md 기록, 사용자 보고 |

**핵심: fake 응답 절대 금지. 도구가 안 되면 사용자가 해결할 때까지 멈춰서 기다린다.**

### 7. 임의 중단·단축·생략 절대 금지 (cost-saving heuristics 차단)

**메인 Codex 가 *자체 판단* 으로 절차를 단축·중단·생략·재사용 금지.** 토큰 사용량·작업 시간·작업량·컨텍스트 크기 등 *비용* 은 사용자 영역. skill 은 절차 완수 (procedure completeness) 만 책임진다.

**금지되는 합리화 패턴** (cycle 4 `20260525T140541Z-refactor` baseline 학습):

| 합리화 발언 | 실제 의미 | 처리 |
|---|---|---|
| "토큰 절약 위해 재호출 안 함" | cost-saving 자체 판단 | **금지** — 풀세트 진행 |
| "이전 cycle 결과 동일하므로 재사용" | 정합성 명분 cost-saving | **금지** — 사용자 명시 요청 시에만 재사용 |
| "산출물 압축 작성" | 토큰 부담 자체 판단 | **금지** — 템플릿 풀세트 작성 |
| "agent 호출 토큰 큼" | 비용 부담 자체 판단 | **금지** — 정책상 agent 호출 명시되면 호출 |
| "이미 검증됨, 재실행 의미 없음" | 시간 절약 자체 판단 | **금지** — 매 회차 독립 검증 |
| "본 세션 컨텍스트 부담 큼" | 메모리 자체 판단 | **금지** — 사용자가 결정할 영역 |
| "별 의미 없음, skip" | 작업량 자체 판단 | **금지** — 명시된 step 모두 수행 |
| **"한 응답 한도, 다음 응답에서 계속"** | **응답 길이 자체 판단 (응답 분할 cost-saving)** | **금지** — step 1 → step 9 한 호흡 자동 진행 |
| **"정확성 우선으로 응답 단위를 끊음"** | **정확성 명분 응답 분할** | **금지** — 응답 길이는 사용자 영역. 정확성은 분할로 안 올라감 |
| **"응답이 너무 길어진다, 끊자"** | **응답 길이 자체 판단** | **금지** — 길어지면 그대로 길게 진행 |
| **"여기서 끊고 사용자 확인 받자"** | **5 예외 enum 외 자체 중단** | **금지** — 5 예외만 유일한 중단 사유 |
| **"진행하려면 '진행해줘' 입력 주세요"** | **자체 분할 후 사용자 입력 대기** | **금지** — 5 예외 외 사용자 응답 대기 일체 금지 |

**5 예외 enum 과의 구분**:

| 사유 | 정책 |
|---|---|
| 외부 환경 차단 (auth 만료·quota 소진·도구 부재) | 5 예외 enum 발동 — 사용자 결정 대기 |
| 외부 classifier 차단 (Auto Mode Classifier denial) | 즉시 사용자 보고 + 결정 대기 |
| 정책상 명시된 자가 수정 한도 도달 | 5 예외 ④ `AUDIT_LIMIT_EXCEEDED` |
| **메인 Codex 의 *내부 자체 판단* (토큰/시간/작업량)** | **본 §7 위반 — 진행 강제** |

**검증 게이트**: 매 step 종료 시 메인 Codex 가 자체 점검:
- [ ] 본 step 의 모든 산출물 풀세트 작성 (압축·생략 없음)
- [ ] 명시된 agent/codex 호출 모두 수행 (재사용 명시 요청 없으면 새 호출)
- [ ] "토큰", "시간", "부담", "절약", "압축" 같은 단어가 산출물 또는 사고 과정에 합리화로 등장하지 않음

위반 발견 시: 풀세트 재실행 + log.md 에 위반 + 시정 기록.

**예외 — 사용자 명시 인가**: 사용자가 *명시적으로* "압축해줘", "재사용해줘", "skip 해줘" 등을 요청한 경우만 허용. log.md 에 사용자 instruction verbatim 인용.

**Cycle 4 의 §7 위반 사례 (학습 데이터)**:
- step 5: cycle 3 unblock 결과 재사용 (사용자 미요청, "토큰 절약" 명분) — F-02 grey zone 등재
- summary.md: "압축 작성" 명분 짧게 작성
- 7-audit/* 산출물: "토큰 부담 큼" 명분 압축

→ 본 §7 신규 정책 적용 후 위 패턴 모두 차단.

**Red flags — STOP 트리거**:

자체 판단 합리화 사고가 떠오르면 즉시 STOP + 풀세트 진행:
- "토큰 부담 큼" → STOP
- "시간 큼" → STOP
- "토큰 절약" → STOP
- "압축 작성" → STOP
- "재호출 의미 없음" → STOP
- "비용/편익 차이" (자체 판단) → STOP
- **"한 응답 한도, 다음 응답에서 계속"** → STOP (응답 분할 = cost-saving)
- **"정확성 우선으로 응답을 끊자"** → STOP (정확성 명분 응답 분할)
- **"응답이 길어진다, 분할하자"** → STOP (응답 길이 자체 판단)
- **"여기서 사용자 확인 받자"** (5 예외 enum 외) → STOP
- **"`진행해줘` 입력 주시면 계속" 류 발언** → STOP

→ /harness:run 호출 1회 = step 1 → step 9 commit 까지 **한 호흡 자동 진행**. 5 예외 enum 트리거 외 어떤 사유로도 응답 중간에서 사용자 입력을 대기하지 않는다.

### 7.1 응답 분할 절대 금지 (별도 명시)

§7 의 cost-saving 합리화 중 *응답 분할* 만 별도 절로 강화한다 (이전 회차 cycle-002 → cycle-003 분할 사고 학습).

**정의**: 5 예외 enum 트리거 없이 메인 Codex 가 자체적으로 응답을 종료하고 사용자 입력을 기다리는 모든 행위 = **응답 분할**.

**금지 형식 (예시)**:
- "다음 응답에서 cycle-NNN 부터 계속 진행합니다"
- "한 응답 한도 + 정확성 우선으로 응답 단위를 끊었습니다"
- "계속하려면 `진행해줘` 주시면 cycle-NNN 부터 step 9 까지 자동 진행합니다"
- "본 응답에서 step N 까지 완료. 다음 응답에서 step N+1 진행"
- "토큰 한도 부담 — 여기서 끊고 사용자 확인 요청"

**원칙**:
1. /harness:run 호출 1회 = **하나의 단일 단위**. step 1 부터 step 9 commit 까지 한 어시스턴트 응답 또는 (응답이 자연 길어지면) **연속 응답** 으로 진행. 사용자 입력 대기 없이.
2. **응답 길이는 사용자가 결정할 영역**. 메인 Codex 가 "길어진다" 판단해 자체 분할 금지.
3. **정확성은 응답 분할로 향상되지 않음**. 정확성은 §2 (Mock 금지) · §3 (자가 수정 한도) · step 4 (QA) · step 5 (review) · step 7 (audit) 가 보장. "정확성 우선으로 끊자" 는 명분일 뿐 cost-saving.
4. 사용자가 *명시적으로* "여기까지만 / 끊어줘 / 일단 멈춰" 라고 인가하면 허용. 그 외 메인 Codex 의 자체 판단 분할 = §7.1 위반.

**위반 발견 시 자가 처리**:
- 분할 멘트를 작성하기 직전에 자가 점검:
  - [ ] 5 예외 enum 중 하나가 트리거되었나? (`EXT_DEP_PROD_BLOCKED` / `TDD_5X_SAME_SCENARIO` / `QA_OR_REVIEW_5X_SAME_DEFECT` / `AUDIT_LIMIT_EXCEEDED` / `SUBAGENT_RUNTIME_BLOCKED`)
  - [ ] 사용자가 명시적으로 분할 인가했나?
  - 둘 다 NO → 분할 금지. 그대로 다음 step 진행.
- 이미 분할 멘트 작성한 경우 (자가 발견): log.md 에 §7.1 위반 기록 + 다음 step 즉시 진행.

**Cycle 4 학습 데이터 (20260526T024115Z-avd-session-manager)**:
- cycle-002 GREEN 완료 후 "다음 응답에서 cycle-003 부터 계속 진행" 멘트 + "한 응답 한도 + 정확성 우선으로 응답 단위를 끊었습니다" 명분 → 본 §7.1 신규 정책 트리거.
- 본 §7.1 적용 후 동일 패턴 차단.

---

## CRITICAL: 학습 파일 자동 prepend (QA/audit 서브에이전트 호출)

`harness-engineering-qa` 와 `harness-engineering-auditor` 호출 시 **공용 학습 파일 prepend 필수**. `harness-engineering-researcher` 는 FINAL 결정에 따라 learning 파일을 쓰지 않고 매번 신선 리서치를 수행한다.

- **경로**: `~/.codex/skills/harness-run/learning/<agent-name>.md` (v2.1 부터 — Codex 최상위 agents 산하)
- 매 호출 시 메인 Codex 가 Read 해 prompt 에 prepend. 파일이 비어 있으면 `(빈 파일)` 명시.
- 재사용 서브에이전트 (`codex-reviewer` · `harness-customer-user`) 는 자체 learning 시스템 사용 (본 skill 비대상).

---

## 9 단계 워크플로우 (한눈에)

```
[step 1] 감지 + 입력 정리 — docs/steps/01-detect.md
[step 2] DDD 도메인 모델링 (Event Storming, Bounded Context, Aggregate) — docs/steps/02-domain.md
[step 3] TDD 루프 (Red·Green·Refactor, Bounded Context 별, Aggregate 별) — docs/steps/03-tdd.md
[step 4] QA (빌드·테스트·커버리지·정적 분석) — docs/steps/04-qa.md
[step 5] Codex 리뷰 — docs/steps/05-review.md
[step 6] 고객 테스트 — docs/steps/06-customer.md
[step 7] Audit + 자가 수정 (산출물 + 스킬 파일) — docs/steps/07-audit.md
[step 8] 최종 보고서 (summary.md + summary.html) — docs/steps/08-summary.md
[step 9] Commit (push 안 함) — docs/steps/09-commit.md
```

전체 흐름·동작은 [docs/workflow.md](docs/workflow.md), 코드 구조 규칙은 [docs/code-structure.md](docs/code-structure.md).

---

## 산출물 폴더 규약

```
<프로젝트>/.harness/
├── README.md                              # 회차 인덱스 + 최신 회차 요약
└── runs/
    └── <UTC-timestamp>-<slug>/            # 회차 별 폴더 (예: 20260524T144500Z-payment)
        ├── log.md                         # 진행 로그 (타임스탬프·단계·결과)
        ├── summary.md                     # 최종 보고서 (마크다운, pre-commit draft)
        ├── summary.html                   # 최종 보고서 (HTML, html-document-rules.md 준수)
        ├── 01-detect/                     # 언어·프레임워크 감지 + 외부 의존성 점검
        ├── 02-domain/                     # 도메인 모델·Event Storming (Bounded Context 별 하위 폴더)
        ├── 03-aggregate-<name>/           # Aggregate 별
        │   ├── model.md
        │   ├── skeleton/                  # 객체 단위 파일 분리 (참고용)
        │   └── tdd/cycle-NNN.md
        ├── ui/                            # UI 프로젝트만 (컴포넌트별 View + Logic 분리)
        ├── 04-qa/
        ├── 05-review/
        ├── 06-customer/
        ├── 07-audit/
        │   ├── findings.md
        │   ├── self-correction.md         # 산출물 자가 수정 이력
        │   └── skill-improvement.md       # 스킬 파일 자기 개선 변경 로그
        └── 09-commit/
            ├── commit-message.md
            ├── files-included.md
            ├── files-excluded.md
            └── status.md
```

본 문서·하위 step 문서·템플릿이 `.harness/<sub>/` 표기를 쓰면 메인 Codex 가 자동으로 `.harness/runs/<현재 회차>/<sub>/` 로 prefix 를 추가한다 (간결한 문서 컨벤션 — step 1 참조).

---

## docs/ 안내판

| 파일 | 내용 |
|---|---|
| [docs/workflow.md](docs/workflow.md) | 9 단계 흐름 전체 개요 |
| [docs/code-structure.md](docs/code-structure.md) | 객체 단위 + UI↔기능 분리 규칙 상세 |
| [docs/steps/01-detect.md](docs/steps/01-detect.md) | 언어·프레임워크 감지 + 외부 의존성 점검 |
| [docs/steps/02-domain.md](docs/steps/02-domain.md) | DDD 도메인 모델링 (Event Storming + Aggregate + 코드 스켈레톤) |
| [docs/steps/03-tdd.md](docs/steps/03-tdd.md) | TDD 루프 (Red·Green·Refactor, Mock 금지) |
| [docs/steps/04-qa.md](docs/steps/04-qa.md) | QA 서브에이전트 호출 |
| [docs/steps/05-review.md](docs/steps/05-review.md) | codex-reviewer 호출 |
| [docs/steps/06-customer.md](docs/steps/06-customer.md) | harness-customer-user 호출 |
| [docs/steps/07-audit.md](docs/steps/07-audit.md) | audit 서브에이전트 + 자가 수정 루프 |
| [docs/steps/08-summary.md](docs/steps/08-summary.md) | summary.md + summary.html 생성 |
| [docs/steps/09-commit.md](docs/steps/09-commit.md) | git commit (push 안 함) |
| `~/.codex/skills/harness-run/agents/harness-engineering-{researcher,qa,auditor}.md` + `harness-customer-user.md` | 신규·재사용 서브에이전트 정의 (single source of truth — skill 외부 최상위) |
| `~/.codex/skills/harness-run/learning/<agent>.md` | 서브에이전트별 학습 누적 파일 (skill 외부 최상위 — 메인 Codex 가 prepend) |
| [templates/](templates/) | 산출물 템플릿 10 종 |


---

## §8 Codex 한정 운영 메모

- **shell 도구 sandbox 모드**: 본 skill 은 `workspace-write` sandbox 가정. `danger-full-access` 면 §1 외부 의존성 정책 위반 위험 증가 → 사용자 명시 인가 필수.
- **codex exec 재귀 호출 timeout**: 기본 600초. dotnet/maven 등 무거운 빌드는 `--timeout 1800` 으로 확장 가능. step 5 codex-reviewer 호출이 timeout 되면 LP-1 개선 항목으로 `skill-improvement.md` 에 기록한다.
- **모델 선택**: 기본 `gpt-5-codex`. step 5 review 의 codex-reviewer 만 `gpt-5` reasoning 강화 권장. 호출 시 `codex exec --model gpt-5 ...` 를 사용한다.
- **AGENTS.md 우선순위**: Codex 는 `~/.codex/AGENTS.md` 와 프로젝트 `AGENTS.md` 를 항상 prepend 한다. 충돌 시 본 SKILL.md 가 더 구체적인 harness-run 정책으로 우선한다.
- **partial stdout 캡처**: exit 124 timeout 시에도 `2>&1 | tee <raw-result.md>` 패턴으로 partial stdout 을 보존한다. step 5 `raw-result.md` 와 step 7 `2nd-external-audit.md` 는 요약하지 않고 verbatim 저장한다.
- **exit code 분기**: `0=성공`, `2=auth 만료`, `3=quota/rate limit`, `124=timeout`, 그 외는 `SUBAGENT_RUNTIME_BLOCKED` 로 처리한다. fake 응답 작성 금지.

## Codex sub-agent 호출 표준 패턴

```bash
AGENT_NAME="harness-engineering-qa"
RUN_ID="${RUN_ID:-$(date -u +%Y%m%dT%H%M%SZ)-${SLUG:-task}}"
LEARNING_FILE="$HOME/.codex/skills/harness-run/learning/${AGENT_NAME}.md"
AGENT_DEF="$HOME/.codex/skills/harness-run/agents/${AGENT_NAME}.md"

if [ "${AGENT_NAME}" = "harness-engineering-researcher" ]; then
  LEARNING_BLOCK="(researcher 는 learning 사용 안 함 — 매번 신선 리서치)"
else
  LEARNING_BLOCK="$(cat "${LEARNING_FILE}" 2>/dev/null || echo "(빈 파일 / 미생성)")"
fi

PROMPT="$(cat "${AGENT_DEF}")

## Prior Learning (READ FIRST — DO NOT SKIP)

${LEARNING_BLOCK}

## 회차 컨텍스트

- run-id: ${RUN_ID}
- 대상 repo: $(pwd)
- 호출 사유: <step N 의 사유 한 줄>

## 요청 사항

<step 별 구체 요청 — 검증 항목, 출력 형식, LGTM 기준 등>
"

RAW_OUT="$(pwd)/.harness/runs/${RUN_ID}/<step>/raw-${AGENT_NAME}.md"
mkdir -p "$(dirname "${RAW_OUT}")"

codex exec --skip-git-repo-check \
  --sandbox workspace-write \
  --ask-for-approval never \
  --model gpt-5-codex \
  --timeout 900 \
  "${PROMPT}" 2>&1 | tee "${RAW_OUT}"
EXIT_CODE="${PIPESTATUS[0]}"
echo "exit_code: ${EXIT_CODE}" >> "${RAW_OUT}.meta"
```

## 5 예외 enum CLI 입력 패턴

```bash
echo "[harness-run] <enum-id> 트리거"
echo "사유: <한 줄>"
echo ""
echo "옵션:"
echo "  A: <옵션 A>"
echo "  B: <옵션 B>"
echo "  C: <옵션 C>"
echo "  (Other: 자유 입력)"
echo ""
read -r -p "선택 (A/B/C/Other): " CHOICE
echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) | exception_choice | enum=<id> | choice=${CHOICE}" >> ".harness/runs/${RUN_ID}/log.md"
```
