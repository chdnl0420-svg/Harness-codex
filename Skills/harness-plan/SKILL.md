---
name: harness-plan
description: 'Harness /harness Step 2 도메인 설계 전용 스킬. 일반 구현 계획, 일반 설계 계획, /plan 계열 작업, Step 3 구현 계획에는 사용하지 않는다. /harness Step 2에서 사용자 요청과 프로젝트 증거를 바탕으로 도메인 설계 초안 본문만 만든다.'
---

# Harness Plan

이 스킬은 `/harness` Step 2 도메인 설계 초안 본문을 만들 때만 사용한다. 일반 구현 계획은 `planner` 또는 `/plan` 계열을 사용한다. Step 3 구현 계획에는 이 스킬을 쓰지 않는다.

`harness-plan`은 초안 본문만 반환한다. `.harness/domain-<slug>.html` 저장, 리뷰 반영, 승인 분기는 Step 2 호출자가 책임진다.

## Mode Boundary

Boundary anchors: `boundary:harness-step2-only`, `boundary:exclude-general-planning`, `boundary:exclude-step3-implementation-plan`.

- `.harness/.noask`가 있거나 현재 흐름이 `/harness`이면 noask 모드다.
- `.harness/.ask`가 있거나 현재 흐름이 `/harness-ask`이면 ask 모드다.
- 모드가 불명확하면 ask 모드를 안전 기본값으로 둔다.
- noask 모드에서는 사용자에게 질문하지 않는다.
- ask 모드에서는 추측으로 밀어붙이지 않는다. Codex에 전용 질문 도구가 없으면 일반 채팅 질문이나 사용 가능한 사용자 입력 도구로 필요한 입력을 받는다.

## Inputs

- 사용자 원문 요청
- 현재 저장소 맥락과 관련 파일
- Step 1에서 계산한 `HARNESS_PROJECT_DIR`
- 기존 `.harness` 산출물과 progress
- ask 모드에서 받은 사용자 답변

## Noask Evidence

noask 모드에서는 사용자 원문 요청만 보고 초안을 만들지 않는다. 가능한 범위에서 아래 증거를 읽고, 없는 항목은 실패가 아니라 `Open Questions`와 progress에 "증거 없음"으로 남긴다.

Evidence anchors: `evidence:user-request`, `evidence:prd`, `evidence:architecture`, `evidence:adr`, `evidence:ui-guide`, `evidence:agents-or-claude`, `evidence:git-history-5`, `evidence:code-search`.

- 사용자 원문 요청과 목표
- `docs/PRD.md`
- `docs/ARCHITECTURE.md`
- `docs/ADR.md`
- `docs/UI_GUIDE.md`
- `AGENTS.md`와, 존재한다면 프로젝트 지침 파일로서의 `CLAUDE.md`
- 최근 git history 5개
- 변경 대상 키워드 기반 코드 검색 결과

git 저장소가 아니거나 history를 읽을 수 없으면 "git history 없음"을 progress 또는 초안 가정에 기록한다.

## Required Output Sections

도메인 설계 초안에는 6개 도메인 카테고리와 3개 필수 보조 섹션을 포함한다.

필수 보조 섹션:
- 요구사항 재진술 (`template-section:requirements-restatement`)
- 위험 (`template-section:risks`)
- Open Questions (`template-section:open-questions`)

6개 도메인 카테고리:
- 통합 사용자 시나리오 (`domain-category:integrated-user-scenario`)
- 성공 기준 (`domain-category:success-criteria`)
- 범위 / 제외 항목 (`domain-category:scope-exclusions`)
- 제약 (`domain-category:constraints`)
- 외부 의존성 (`domain-category:external-dependencies`)
- 비기능 요구 (`domain-category:non-functional-requirements`)

불명확한 내용은 `Open Questions`에 질문과 임시 가정을 함께 남긴다.

## Output Template

초안은 아래 구조를 권장한다. 항목명은 프로젝트에 맞게 다듬을 수 있지만 의미는 빠뜨리지 않는다.

- `Requirements Restatement`: 사용자의 요청을 제품/사용자 관점으로 다시 쓴다.
- `Integrated User Scenario`: 한 흐름으로 사용자가 무엇을 하게 되는지 설명한다.
- `Success Criteria`: 완료를 판단할 수 있는 관찰 가능한 기준을 쓴다.
- `Scope / Exclusions`: 이번 Step 2에 포함할 것과 제외할 것을 분리한다.
- `Constraints`: 기술, 일정, 운영, 정책 제약을 쓴다.
- `External Dependencies`: API, 서비스, 데이터, 문서, 승인 등 외부 의존성을 쓴다.
- `Non-functional Requirements`: 성능, 보안, 접근성, 안정성, 호환성 같은 품질 기준을 쓴다.
- `Risks`: 각 위험에 `HIGH`, `MEDIUM`, `LOW`를 붙이고 "무슨 일이 생길 수 있는지"와 "어떻게 막는지"를 함께 쓴다.
- `Open Questions`: 답이 없으면 어떤 임시 가정으로 진행했는지 같이 쓴다.

## Readability Self Check

Readability anchors: `readability`, `short`, `headings`, `technical terms`, `daily workflow`.

초안 제출 전에 아래 4개 자체 평가를 통과해야 한다. 하나라도 실패하면 다시 쓴다.

- 중학생 테스트: 제품 배경을 모르는 사람이 흐름을 이해할 수 있다.
- 전문용어 검사: 처음 나오는 기술 용어는 짧게 설명한다.
- 문장 길이 검사: 긴 문장을 쪼개고 제목과 목록을 먼저 둔다.
- 수동태 검사: 책임과 행동 주체가 보이게 쓴다.

## Research Triggers

다음 중 하나라도 해당하면 `harness-deep-researcher` 절차 또는 Codex의 웹 검증 절차를 사용한다. 최신 외부 정보가 필요한 경우에는 반드시 검증한다.

Research anchors: `research-trigger:library-comparison`, `research-trigger:latest-version`, `research-trigger:security`, `research-trigger:api-migration`, `research-trigger:phase1-research-needed`, `research-trigger:user-requested-verification`.

- 라이브러리, 프레임워크, 서비스, SaaS, API를 비교하거나 선택해야 한다.
- 최신 모델, 버전, 릴리스, 가격, 정책, 지원 여부가 판단에 영향을 준다.
- 보안 권고, 취약점, 인증/권한, 개인정보, 규정 준수가 관련된다.
- API 사용법, SDK 변경, 마이그레이션 영향, 브레이킹 체인지가 관련된다.
- Step 1 입력이나 progress가 "조사 필요"를 명시한다.
- 사용자가 조사, 비교, 확인, 최신 정보 검증을 명시적으로 요청한다.

## Research Output Contract

리서치 결과는 `.harness/research/research-<slug>-<NN>-<topic>.md`에 저장할 수 있는 Markdown 형태로 정리한다. 긴 ask 답변은 `.harness/research/answers-<slug>.md`에 저장하고, 메인 컨텍스트에는 요약만 둔다.

Research field anchors: `research-field:summary`, `research-field:key-findings`, `research-field:sources-consulted`, `research-field:search-trail`, `research-field:stop-reason`, `research-field:research-date`, `research-field:step2-impact`, `research-field:inferred`.

리서치 산출물에는 반드시 다음 항목을 포함한다.

- Summary
- Key Findings
- Sources Consulted
- Search Trail
- Stop reason
- 조사 일자
- 어떤 Step 2 결정에 영향을 주는지
- Inferred: 출처 없이 추론한 내용과 결론에 쓰면 안 되는 내용

검증되지 않은 주장은 결정 근거로 쓰지 않는다. 출처가 약한 추론은 `Inferred`로 분리한다. 리서치가 필요 없으면 progress와 도메인 초안에 "리서치 필요 없음"과 이유를 남긴다.

## UX Gate

UX keyword anchors: `ux-keyword:screen`, `ux-keyword:ui`, `ux-keyword:button`, `ux-keyword:menu`, `ux-keyword:layout`, `ux-keyword:color`, `ux-keyword:font`, `ux-keyword:icon`, `ux-keyword:navigation`, `ux-keyword:modal`, `ux-keyword:dialog`, `ux-keyword:tab`, `ux-keyword:input`, `ux-keyword:list`, `ux-keyword:card`, `ux-keyword:sidebar`, `ux-keyword:header`, `ux-keyword:footer`, `ux-keyword:toggle`, `ux-keyword:dropdown`, `ux-keyword:animation`, `ux-keyword:transition`, `ux-keyword:responsive`, `ux-keyword:mobile`, `ux-keyword:desktop`, `ux-keyword:dark-mode`, `ux-keyword:accessibility`, `ux-keyword:flow`, `ux-keyword:wireframe`, `ux-keyword:mockup`.

요청이나 초안에 위 UX 신호가 있으면 `# UX` 또는 `## UX` 섹션을 포함한다.

UX 섹션에는 반드시 다음 4개 필드를 포함한다.

- 변경 대상 화면/요소 (`ux-field:target-surface`)
- Before -> After (`ux-field:before-after`)
- 영향 사용자 시나리오 (`ux-field:affected-user-scenario`)
- 시각 증거 또는 생략 사유 (`ux-field:visual-evidence-or-omission-reason`)

시각 증거 우선순위는 실제 이미지, inline SVG mockup, ASCII 와이어프레임, 텍스트 생략 사유 순서다.

## Completion Criteria

- 호출 경계가 `/harness` Step 2 전용으로 명확하다.
- noask 모드는 증거 목록을 확인하고, 없는 증거를 실패가 아닌 불확실성으로 기록한다.
- ask 모드는 6개 카테고리 수집을 생략하지 않는다.
- 출력에는 Requirements Restatement, Risks, Open Questions가 있다.
- 리서치 필요 여부, 저장 경로, 생략 사유가 추적된다.
- UX 신호가 있으면 UX 섹션과 4개 필드가 있다.
