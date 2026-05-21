# Step 2: 도메인 설계

## 목표

사용자 요청을 제품/사용자 관점의 도메인 설계 초안으로 바꾼다. Step 2는 구현 계획이 아니라, 무엇을 만들고 무엇을 만들지 않을지 합의할 수 있는 설계 문서다.

Boundary anchors: `boundary:harness-step2-only`, `boundary:exclude-general-planning`, `boundary:exclude-step3-implementation-plan`.

## 진입 조건

- Step 1 progress가 있다.
- `HARNESS_PROJECT_DIR`와 slug를 알고 있다.
- noask/ask 모드를 확인했다.

## 모드 분기

### noask 모드

`/harness` 또는 `.harness/.noask`에서는 사용자에게 질문하지 않는다. 프로젝트 증거와 보수적 가정으로 6개 카테고리를 모두 채우고, 불확실한 항목은 `Open Questions`에 질문과 임시 가정을 함께 남긴다.

noask에서 읽을 증거:

- 사용자 원문 요청 (`evidence:user-request`)
- `docs/PRD.md` (`evidence:prd`)
- `docs/ARCHITECTURE.md` (`evidence:architecture`)
- `docs/ADR.md` (`evidence:adr`)
- `docs/UI_GUIDE.md` (`evidence:ui-guide`)
- `AGENTS.md`와 존재하는 프로젝트 지침 파일 (`evidence:agents-or-claude`)
- 최근 git history 5개 (`evidence:git-history-5`)
- 변경 대상 키워드 기반 코드 검색 (`evidence:code-search`)

git 저장소가 아니면 실패하지 않는다. "git history 없음"을 progress 또는 초안의 가정에 남긴다.

### ask 모드

`/harness-ask`, `.harness/.ask`, 또는 모드가 불명확한 경우에는 ask 모드를 안전 기본값으로 둔다. `harness-plan-ask`를 사용해 6개 카테고리를 순차적으로 수집한다. 한 번에 묻는 질문은 1~4개로 제한하되, 6개 카테고리 완료 의무는 유지한다.

사용자가 이미 충분히 답한 항목은 확인 질문 1개로 압축할 수 있다. `Open Questions`는 진행을 막지 않는 불확실성을 기록하는 곳이며, 필수 카테고리 생략의 대체물이 아니다.

## 필수 출력 구조

도메인 HTML은 다음 항목을 빠뜨릴 수 없다.

1. Requirements Restatement (`template-section:requirements-restatement`)
2. 통합 사용자 시나리오 (`domain-category:integrated-user-scenario`)
3. 성공 기준 (`domain-category:success-criteria`)
4. 범위 / 제외 항목 (`domain-category:scope-exclusions`)
5. 제약 (`domain-category:constraints`)
6. 외부 의존성 (`domain-category:external-dependencies`)
7. 비기능 요구 (`domain-category:non-functional-requirements`)
8. Risks (`template-section:risks`)
9. Open Questions (`template-section:open-questions`)

Risks에는 `HIGH`, `MEDIUM`, `LOW`를 붙이고, 각 위험마다 "무슨 일이 생길 수 있는지"와 "어떻게 막는지"를 함께 쓴다.

## 리서치 기준

다음 중 하나라도 해당하면 Step 2 결론 전에 `harness-deep-researcher` 절차 또는 Codex의 웹 검증 절차를 사용한다.

- 라이브러리, 프레임워크, 서비스, SaaS, API를 비교하거나 선택해야 한다 (`research-trigger:library-comparison`).
- 최신 모델, 버전, 릴리스, 가격, 정책, 지원 여부가 판단에 영향을 준다 (`research-trigger:latest-version`).
- 보안 권고, 취약점, 인증/권한, 개인정보, 규정 준수가 관련된다 (`research-trigger:security`).
- API 사용법, SDK 변경, 마이그레이션 영향, 브레이킹 체인지가 관련된다 (`research-trigger:api-migration`).
- Step 1 입력이나 progress가 "조사 필요"를 명시한다 (`research-trigger:phase1-research-needed`).
- 사용자가 조사, 비교, 확인, 최신 정보 검증을 명시적으로 요청한다 (`research-trigger:user-requested-verification`).

리서치 결과는 `.harness/research/research-<slug>-<NN>-<topic>.md`에 저장한다. 긴 ask 답변은 `.harness/research/answers-<slug>.md`에 저장하고, 메인 컨텍스트에는 요약만 둔다. 리서치가 필요 없으면 progress에 "리서치 필요 없음"과 이유를 남긴다.

리서치 산출물에는 `research-field:summary`, `research-field:key-findings`, `research-field:sources-consulted`, `research-field:search-trail`, `research-field:stop-reason`, `research-field:research-date`, `research-field:step2-impact`, `research-field:inferred`가 있어야 한다.

## UX 게이트

UX gate anchor: `ux-gate`.

UX 키워드 목록:

`ux-keyword:screen`, `ux-keyword:ui`, `ux-keyword:button`, `ux-keyword:menu`, `ux-keyword:layout`, `ux-keyword:color`, `ux-keyword:font`, `ux-keyword:icon`, `ux-keyword:navigation`, `ux-keyword:modal`, `ux-keyword:dialog`, `ux-keyword:tab`, `ux-keyword:input`, `ux-keyword:list`, `ux-keyword:card`, `ux-keyword:sidebar`, `ux-keyword:header`, `ux-keyword:footer`, `ux-keyword:toggle`, `ux-keyword:dropdown`, `ux-keyword:animation`, `ux-keyword:transition`, `ux-keyword:responsive`, `ux-keyword:mobile`, `ux-keyword:desktop`, `ux-keyword:dark-mode`, `ux-keyword:accessibility`, `ux-keyword:flow`, `ux-keyword:wireframe`, `ux-keyword:mockup`.

요청이나 도메인 초안에 위 UX 신호가 있으면 도메인 HTML에 `# UX`, `## UX`, `<h1>UX</h1>`, 또는 `<h2>UX</h2>` 섹션이 필요하다.

UX 섹션에는 다음 4개 필드가 필요하다.

- 변경 대상 화면/요소 (`ux-field:target-surface`)
- Before -> After (`ux-field:before-after`)
- 영향 사용자 시나리오 (`ux-field:affected-user-scenario`)
- 시각 증거 또는 생략 사유 (`ux-field:visual-evidence-or-omission-reason`)

시각 증거 우선순위는 실제 이미지, inline SVG mockup, ASCII 와이어프레임, 텍스트 생략 사유 순서다. UX 신호가 있는데 UX 섹션이 없거나 4개 필드 중 하나가 없으면 Step 3로 진입하지 않는다.

## 호출자 책임과 승인 흐름

`harness-plan`과 `harness-plan-ask`는 도메인 설계 초안 본문만 반환한다. Step 2 호출자는 다음을 처리한다.

Approval anchors: `approval-flow:review-draft`, `approval-flow:apply-review`, `approval-flow:noask-auto-approve`, `approval-flow:ask-confirm-approve-revise-cancel`, `approval-flow:save-after-approval`.

1. `harness-plan` 또는 `harness-plan-ask`를 호출한다.
2. 초안을 리뷰한다.
3. 리뷰 결과를 반영한다.
4. noask 모드에서는 리뷰 1회 반영 후 자동 승인한다.
5. ask 모드에서는 사용자에게 승인, 수정 의견, 취소 중 하나를 확인한다.
6. 수정 의견이면 Step 2 초안 작성으로 돌아간다.
7. 승인 후 `.harness/domain-<slug>.html`로 저장한다.
8. 저장 경로, 리서치 경로, 남은 질문을 progress에 기록한다.

## 산출물

- `.harness/domain-<slug>.html`
- 필요 시 `.harness/research/research-<slug>-<NN>-<topic>.md`
- 필요 시 `.harness/research/answers-<slug>.md`
- progress의 Step 2 상태, 리서치 저장 경로 또는 리서치 생략 사유

## 완료 조건

- 도메인 HTML이 존재하고 비어 있지 않다.
- 필수 출력 구조가 모두 있다.
- 사용자 답변과 Codex 임시 가정이 분리되어 있다.
- 최신 외부 정보가 필요한 판단은 검증되었거나 리서치 경로로 추적된다.
- UX 신호가 있으면 UX 섹션과 4개 필드가 있다.
- 저장은 승인 흐름 이후에만 일어난다.
