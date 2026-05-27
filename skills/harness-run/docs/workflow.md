# harness 워크플로우 개요

`/harness <자연어 목표>` 실행 시 9 단계가 순서대로 자동 진행된다. 한 번 시작하면 사용자가 명시 중단하지 않는 한 끝까지 자동 진행. 사용자에게 묻는 경우는 **SKILL.md 의 5 예외 enum 만**:

1. `EXT_DEP_PROD_BLOCKED` — production credential / base URL 감지
2. `TDD_5X_SAME_SCENARIO` — TDD 5회 연속 같은 사이클 실패
3. `QA_OR_REVIEW_5X_SAME_DEFECT` — QA FAIL 또는 Codex LGTM:NO 5회 누적 (동일 결함)
4. `AUDIT_LIMIT_EXCEEDED` — audit 자가 수정 산출물 2회 + 스킬 2회 모두 초과
5. `SUBAGENT_RUNTIME_BLOCKED` — sub-agent BLOCKED 반환 (auth·quota·도구 부재)

본 문서의 모든 사용자 질문은 [SKILL.md CLI 표준 입력 대기 표](../SKILL.md#cli-표준-입력-대기-호출-허용-예외-이-5-가지만--단일-정합-표) 만 따른다. 본 문서에 명시되지 않은 예외 추가 금지.

## "끝까지 자동 진행" 정의 (응답 분할 금지)

"자동 진행" = step 1 → step 9 commit 까지 **한 호흡으로 연결된 어시스턴트 작업**. 다음 모두를 의미:

- step 간 사용자 입력 대기 **금지**. step 1 종료 시 즉시 step 2 진입. step 2 종료 시 즉시 step 3 진입. step 9 까지 동일.
- step 내부 cycle 간 사용자 입력 대기 **금지**. step 3 cycle-001 GREEN 종료 시 즉시 cycle-002 RED 진입. 모든 cycle 종료 시 즉시 step 4 진입.
- 메인 Codex 가 자체적으로 응답 길이/토큰/시간을 판단해 **응답을 끊고 사용자 입력을 기다리는 행위 금지** (SKILL.md §7.1 응답 분할 절대 금지 참조).
- "다음 응답에서 계속 진행" / "`진행해줘` 주시면 계속" / "한 응답 한도" 류 멘트 **금지**.

**유일한 자동 진행 중단 사유**: 5 예외 enum 트리거 또는 사용자의 명시적 중단 요청. 그 외는 모두 §7.1 위반.

**응답이 자연 길어지는 경우**: Codex 의 응답 길이 한도에 자연적으로 도달하면 도구 호출 결과 후 동일 컨텍스트에서 계속 작업하면 된다. 사용자에게 입력 요청 멘트를 띄울 필요 없음.

---

## 9 단계 흐름

```
사용자: /harness 자연어 목표 입력
   │
   ▼
[step 1] 감지 + 입력 정리
   - 프로젝트 언어·프레임워크 자동 감지 (확장자·설정 파일 기반)
   - UI 프로젝트 여부 판정
   - 외부 의존성 (API · 결제 · 이메일 · 외부 쓰기) 감지
   - production credential·base URL 감지 시 BLOCKED → 사용자 결정 (예외 ①)
   - 루트 .harness/README.md 초기화 (회차 인덱스) + 현재 회차 폴더 .harness/runs/<run-id>/log.md 초기화 (step 1 run-prefix 컨벤션 참조 — 루트 log.md 사용 금지)
   │
   ▼
[step 2] DDD 도메인 모델링 (Codex 단독 작성)
   - 도메인 이벤트 / 커맨드 / Aggregate 후보 (Event Storming)
   - Bounded Context 식별 → 여러 개면 각각 따로 다음 단계 진행
   - Aggregate · Entity · VO · Domain Event · Repository · Service 식별
   - CQRS + Event Sourcing 풀세트 적용 (모든 Aggregate 강제)
   - Mermaid 관계도 + Markdown 모델 문서 + 코드 스켈레톤 (객체별 분리)
   - 외부 정보가 필요하면 harness-engineering-researcher 호출
   │
   ▼
[step 3] TDD 루프 (Bounded Context 별, Aggregate 별)
   - 한 Aggregate 가 가진 시나리오 개수만큼 사이클 반복
   - 각 사이클: Red (실제 실행해 FAIL 로그) → Green (풀 구현 한 번에) → Refactor (의무)
   - Mock 금지 — 실제 객체 + in-memory Repository
   - 외부 의존성은 sandbox/test endpoint 만, production BLOCKED
   - 시나리오 있으면 outside-in, 도메인 조각만이면 inside-out
   - 단위 + 통합 + 인수 테스트 모두
   - 5 회 연속 실패 시 멈추고 사용자 결정 (예외 ②)
   │
   ▼
[step 4] QA 서브에이전트 — harness-engineering-qa
   - 빌드 / 테스트 / 80%+ 커버리지 / 정적 분석 (린터·타입체커)
   - learning 파일에 프로젝트 빌드·테스트 특성 누적
   - FAIL 시 log.md 기록 후 step 3 로 회송 (5 회 누적 시 멈춤)
   │
   ▼
[step 5] 코드 리뷰 — codex-reviewer (재사용)
   - LGTM 까지 step 3 ↔ step 5 회송
   - 동일 결함 5 회 누적 시 멈추고 사용자 결정
   - Codex 인증 실패·quota 소진 시 사용자 대기 (fake 응답 금지)
   │
   ▼
[step 6] 고객 테스트 — harness-customer-user (재사용)
   - 일반 사용자 페르소나로 안전한 실행 대상 검증
   - 외부 API·결제·이메일·외부 쓰기는 sandbox/test endpoint 또는 in-memory 구현체만 허용
   - 5초 테스트 + Cognitive Walkthrough + SUS/SEQ + Time-to-First-Value
   - 결과는 06-customer/ 에 기록
   │
   ▼
[step 7] audit + 자가 수정 — harness-engineering-auditor
   ├─ 7a. 점검 8 항목: 요구사항 대조 · DDD 일관성 · TDD 규칙 준수 · 숫자 정합성 · 외부 검토 종합 · 워크플로 점검 · 재발 방지 · 코드 구조 위반 자동 리팩토링
   ├─ 7b. 산출물 자가 수정 (한도 2 회)
   ├─ 7c. 스킬 파일 자체 수정 (한도 2 회) — ~/.codex/skills/harness-run/ 자동 편집
   └─ 두 한도 모두 도달 시 사용자 결정 (예외 ④ `AUDIT_LIMIT_EXCEEDED`)
   │
   ▼
[step 8] 최종 보고서
   - summary.md (마크다운)
   - summary.html (HTML, html-document-rules.md 준수)
   - README.md 인덱스 갱신
   - log.md 마감
   - 스킬 자기 개선 변경 로그 같이 포함
   │
   ▼
[step 9] 커밋 (push 안 함)
   ├─ 9a. git 저장소 확인 → 없으면 step 9 통째로 skip + log 명시
   ├─ 9b. 변경 파일 점검 + 민감 파일(.env·credentials·하드코딩 비밀) 자동 제외
   ├─ 9c. summary 기반 자연어 커밋 메시지 자동 작성
   ├─ 9d. 사용자 프로젝트 코드 + .harness/ 산출물 커밋
   └─ 9e. push 안 함 (사람이 직접)
```

---

## 단계 간 회송 규칙 (SKILL.md 의 5 예외 enum 과 정합)

| 회송 트리거 | 회송 위치 | 회수 한도 | 한도 초과 시 |
|---|---|---|---|
| TDD 사이클 FAIL (같은 시나리오) | step 3 (같은 사이클 재시도) | 5 회 연속 | 사용자 결정 → 예외 ② `TDD_5X_SAME_SCENARIO` |
| QA FAIL (동일 결함) | step 3 (수정 후 재실행) | 동일 결함 5 회 누적 | 사용자 결정 → 예외 ③ `QA_OR_REVIEW_5X_SAME_DEFECT` |
| Codex LGTM:NO (동일 결함) | step 3 (수정 후 재리뷰) | 동일 결함 5 회 누적 | 사용자 결정 → 예외 ③ `QA_OR_REVIEW_5X_SAME_DEFECT` |
| Customer test BLOCKED (production endpoint) | — | 즉시 | 사용자 결정 → 예외 ① `EXT_DEP_PROD_BLOCKED` |
| audit FAIL — 산출물 | step 7a 재실행 | 2 회 | step 7c 로 (자동) |
| audit FAIL — 스킬 | step 7c 재실행 | 2 회 (산출물·스킬 둘 다 한도 도달 시) | 사용자 결정 → 예외 ④ `AUDIT_LIMIT_EXCEEDED` (예외 ③ 와 혼동 금지 — ③ 은 QA/review 동일 결함 5회 누적) |
| sub-agent BLOCKED 반환 | — | 1 회 (사용자 환경 수정 후) | 사용자 결정 → 예외 ⑤ `SUBAGENT_RUNTIME_BLOCKED` |

**동일성 판정**: `(결함 유형 enum, 파일 경로 normalized)` 튜플 일치. 서로 다른 결함 5 회는 중단 아님.

---

## 자동 결정 매핑 (단일 자동 모드)

| 결정 지점 | 기본 동작 |
|---|---|
| 외부 의존성 감지 — in-memory 가능 | 자동 in-memory 채택 |
| 외부 의존성 감지 — sandbox 존재 | 자동 sandbox 채택 |
| 외부 의존성 감지 — production credential·URL | BLOCKED → 사용자 결정 (예외 ①) |
| Bounded Context 여러 개 | 자동 — 각 Context 별 step 2~3 독립 루프 |
| TDD 시작점 (outside-in vs inside-out) | 자동 — 시나리오 있으면 outside-in |
| Aggregate 사이클 한도 | 자동 — Aggregate 가 가진 시나리오·동작 개수만큼 |
| Refactor 없음 | 자동 — `Refactor: 없음` 기록 후 다음 사이클 |
| Codex fallback | 자동 — Codex 인증 실패·quota 소진 시 사용자 대기 후 재시도 (fake 응답 금지) |
| 커밋 메시지 형식 | 자동 — summary 기반 자연어 (Conventional Commits 강제 아님) |
| git 저장소 없음 | 자동 — step 9 통째로 skip + log 명시 |
| 민감 파일 감지 | 자동 — `.env`·`credentials.*`·하드코딩 비밀 자동 제외 |

---

## 학습 파일 (learning) 운영

QA/audit 서브에이전트에 대해 호출 직전 메인 Codex 가 prepend:

- `~/.codex/skills/harness-run/learning/harness-engineering-qa.md` — 프로젝트 빌드·테스트 특성 누적
- `~/.codex/skills/harness-run/learning/harness-engineering-auditor.md` — 자주 나오는 결함 패턴 누적

`harness-engineering-researcher` 는 FINAL 결정에 따라 learning 파일 없이 매번 신선 리서치를 수행한다.

**학습 갱신 절차**:
1. 서브에이전트 응답 끝에 `## Learning Proposals` 섹션 포함.
2. 메인 Codex 가 검증 (출처·확신도·중복 여부) 후 learning 파일에 반영.
3. 갱신 시점은 step 마무리 직전 또는 audit 단계.
4. Max 800 줄. 초과 시 정리 권고 메시지.

---

## CLAUDE.md / 글로벌 룰 참조

- 산출물 HTML 양식: `C:\Users\NX3GAMES\.codex\html-document-rules.md`
- 보안 룰 (민감 파일 자동 제외): `~/.codex/rules/common/security.md`
- 코딩 스타일 (불변성·작은 파일·에러 처리): `~/.codex/rules/common/coding-style.md`
- L9ASIA C# 컨벤션: `C:\Users\NX3GAMES\.codex\l9asia-client-coding-conventions.md` (감지된 언어가 C# 일 때)

**우선순위 (충돌 시)**:
1. **글로벌 보안 룰** (`~/.codex/rules/common/security.md`, OWASP, gitleaks 차단 패턴) — 항상 최우선. 본 SKILL.md 가 이를 덮어쓰지 못함.
2. **글로벌 산출물 형식 룰** (HTML rules, CLAUDE.md §6) — 산출물 형식·접근성 측면에서 우선.
3. **본 SKILL.md** — 워크플로우·자동 결정·자가 수정 정책에 한해 글로벌 일반 룰보다 우선.
4. **글로벌 일반 룰** (coding-style, git-workflow 등 비보안 항목) — 명시 충돌 없으면 따름.

본 SKILL.md 가 보안 룰 / 산출물 형식 룰 덮어쓰는 표현이 발견되면 audit 단계가 finding 발행 + 자가 수정 대상.
