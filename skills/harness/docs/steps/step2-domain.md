# step2. 도메인 설계

**산출물**: `domain-<slug>.html` 파일 하나 (HTML 산출물 — SKILL.md 분류 규칙 따라 계획문서는 HTML)

**모드별 skill 분기 (CRITICAL — `.harness/.noask` 존재 여부로 판정)**:

| 모드 | skill | 사용자 질의 |
|------|-------|------------|
| **noask 기본** (`/harness` 호출 시 `.harness/.noask` 존재) | `harness-plan` skill (Codex skill, skill="harness-plan") | 없음 — 한 줄 목표를 6 카테고리 합리적 가정으로 메워 도메인 초안 작성. 모든 가정은 *"Open Questions"* 섹션에 누적. |
| **ask** (`/harness-ask` 호출 시 `.harness/.noask` 없음) | `harness-plan-ask` skill (Codex skill, skill="harness-plan-ask") | 6 카테고리 request_user_input 또는 일반 질문 인터랙티브 질의. |

두 skill 은 동일한 6 카테고리, 본문 구성, 자체 점검을 공유한다. 차이는 *입력 수집 방식* 만:
- **`harness-plan`** (noask): request_user_input 또는 일반 질문 호출 금지, 합리적 가정으로 자동 메우기, 모든 가정을 Open Questions 에 명시.
- **`harness-plan-ask`** (ask): request_user_input 또는 일반 질문 으로 카테고리별 인터랙티브 질의.

**흐름** (두 모드 공통, 입력 수집 방식만 다름):

1. **harness-plan 또는 harness-plan-ask skill 호출** — 산출: 도메인 설계 초안 본문 (사용자 미승인).
2. **(필요 시) 외부 리서치 포함** — 위 skill 내부 Phase 2에서 외부 정보가 필요하다고 판단되면 shared `$deepresearch` skill 을 호출한다. 판단 기준과 Harness 연결 방식은 [`../procedures/deep-research-procedure.md`](../procedures/deep-research-procedure.md) 를 따른다.
3. skill 결과(초안)를 Codex 가 리뷰
4. 리뷰 결과를 호출자 Codex 가 검토 / 반영
5. **승인 분기**:
   - **noask 모드**: request_user_input 또는 일반 질문 호출 금지. Codex 리뷰 1회 반영한 본문으로 **자동 승인** → 곧장 7번 단계.
   - **ask 모드**: request_user_input 또는 일반 질문 으로 *"1. 승인 / 2. 수정 의견 / 3. 취소"* 제시. 승인 질문 직전에 도메인 설계 본문을 화면에 그대로 보여 사용자가 확인 가능해야 함.
6. (ask 모드 한정) 수정 의견 시 1번(`harness-plan-ask`) 재호출, 단순 질문 시 답변만 하고 다시 승인 질문, 취소 시 워크플로우 중단.
7. 파일 작성 (`.harness/domain-<slug>.html`) → step3 로

## CRITICAL: Domain Contract 게이트

Step2 도메인 산출물은 `Domain Contract` 섹션을 반드시 포함한다. 단순 요구 요약은 DDD(도메인 주도 설계: 구현 전 업무 경계와 계약을 먼저 고정하는 방식) 로 인정하지 않는다. 자세한 DDD/TDD 게이트는 [`../ddd-tdd-gates.md`](../ddd-tdd-gates.md) 를 따른다.

필수 항목:

- bounded context: 이번 작업이 속한 업무/시스템 경계
- 주요 도메인 용어: 코드명이 아니라 사용자가 이해하는 핵심 개념
- 변경 가능한 계약: 이번 작업에서 수정 가능한 타입/API/UI 계약
- 변경 금지 경계: 수정하면 안 되는 디렉터리, 계층, 외부 시스템
- upstream/downstream 의존성: 선행 계약과 후속 영향
- missing contract: 아직 존재하지 않아 구현을 막는 계약
- 구현 전 block 조건: 구현 시작 전에 충족되어야 하는 조건
- public contracts: API, UI, IPC, persistence, permission, validation, event 중 변경 또는 보존해야 하는 계약
- invariants: 변경 후에도 반드시 참이어야 하는 업무 규칙
- commands/events: 사용자가 실행하는 명령과 관찰 가능한 도메인 이벤트
- contract examples: Given/When/Then 예시. 이후 red test 와 QA 시나리오의 원천이다.

예시:

```markdown
## Domain Contract
- Bounded context: Session launch
- Terms: Session, Backend, Worktree, PermissionMode
- May edit: src/renderer/**
- Must not edit: src/main/**, src/shared/**
- Upstream/downstream: Plan A backend contract → renderer selector
- Missing contract: BgSession.backend, NewSessionInput.backend
- Block before implementation: missing contract 존재 시 관련 chunk BLOCKED
- C1 public contract: NewSessionInput.backend accepts only configured backend ids
- C1 invariant: backend 선택 후 저장된 세션은 같은 backend 로 복원된다
- C1 example: Given backend A is selected, When session is launched, Then the created session records backend A
```

검증 규칙:

- `missing contract` 가 비어 있지 않으면 관련 chunk 는 step3 에서 자동 `BLOCKED / CONTRACT_MISSING` 또는 `BLOCKED / DEPENDENCY_MISSING` 으로 표시한다.
- 도메인 경계 위반 파일이 step4 diff 에 포함되면 step4 완료 불가다.
- Domain Contract 섹션이 없으면 step3 진입 금지. noask 모드라도 step2 산출물을 재작성한다.
- `contract examples` 가 비어 있으면 step3 진입 금지. 테스트로 바꿀 예시가 없는 계약은 구현 가능한 계약으로 보지 않는다.

## 외부 리서치 호출 — Single Source

step2 의 *외부 리서치* 분기 (라이브러리 비교·최신 모범 사례·보안 권고·API 마이그레이션·사용자 답변의 "조사 필요" 항목 등) 는 shared `$deepresearch` skill (`~/.codex/skills/deepresearch/SKILL.md`) 을 사용한다.

리서치 report 는 `.harness/research/` 아래 Markdown 파일로 생성하도록 요청한다. 도메인 초안에는 high-confidence cited findings 만 반영한다. 리서치가 필요 없다고 판단하면 `"리서치 필요 없음 — 사유: …"` 를 진행 로그에 남기고 결과 파일은 만들지 않는다.

---

## CRITICAL: UX 카테고리 강제 게이트 (산출물 검증)

도메인 본문이 다음 키워드 중 **하나라도** 포함하면 *UX 변경 작업* 으로 자동 판정 — `# UX` 또는 `## UX` 카테고리가 도메인 HTML 본문에 **반드시** 존재해야 한다:

`화면` · `UI` · `버튼` · `메뉴` · `레이아웃` · `색상` · `폰트` · `아이콘` · `네비게이션` · `모달` · `툴팁` · `폼` · `입력` · `리스트` · `카드` · `사이드바` · `헤더` · `푸터` · `토글` · `드롭다운` · `애니메이션` · `전환` · `반응형` · `모바일` · `데스크톱` · `다크모드` · `접근성` · `flow` · `wireframe` · `mockup`

### UX 카테고리 필수 항목 (4종)

1. **변경 대상 화면·요소** — 어느 화면의 무엇이 바뀌나 (구체적 위치, 예: "메인 화면의 우측 사이드바 검색 박스")
2. **Before → After** — 현재 동작 vs 변경 후 동작, *사용자 시점 1줄씩* (개발자 용어 금지, `harness-plan` 문체 기준)
3. **영향 사용자 시나리오** — 누가 어떻게 영향 받나 (페르소나 + 흐름)
4. **시각화 (Best-effort 순위, 가능한 가장 위 옵션 선택)**:
   - (a) **실제 이미지 (Best)** — 사용자 첨부 디자인 / 현재 화면 스크린샷이 있으면 `<img>` 로 임베드. 외부 URL 금지 (HTML 출력 규칙 §단일 파일). 사용자 제공 로컬 이미지는 **base64 인라인** (`<img src="data:image/png;base64,...">`) 또는 `file:///` 상대경로 둘 중 하나.
   - (b) **inline SVG mockup** — 직접 그릴 수 있으면 `<svg>...</svg>` 로 와이어프레임 임베드 (도형·텍스트로 화면 골격 표현).
   - (c) **ASCII 와이어프레임** — 둘 다 어려우면 `<pre>` 안에 ASCII 박스 (`+-----+`, `|btn|` 등) 로 골격 표시.
   - (d) **텍스트 설명만** — 시각화 자체가 의미 없는 변경 (예: 텍스트 라벨 한 줄 바꿈) 만 허용. 이 경우 *"시각화 생략 사유: …"* 명시.

### 자동 검증 (step3 진입 전)

step3 진입 직전 호출자 Codex 가 `domain-<slug>.html` 본문에 다음을 grep 확인:

- UX 키워드 등장 여부 (위 키워드 목록)
- UX 키워드 등장 + `# UX` 또는 `## UX` 헤더 존재 + 4종 필수 항목 (변경 대상 / Before-After / 영향 시나리오 / 시각화) 모두 존재 여부

키워드 등장 + UX 섹션 누락 또는 4종 미충족 → **도메인 초안 재작성** (Codex 리뷰 NO 와 동일 분기, 1번 단계 재호출). report 에 *"UX 카테고리 게이트 실패"* 기록.

키워드 미등장 → UX 카테고리 없음 OK (백엔드·인프라·문서 등 화면 변경 없는 작업은 면제).
