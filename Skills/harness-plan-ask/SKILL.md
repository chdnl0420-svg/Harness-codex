---
name: harness-plan-ask
description: 'Harness /harness-ask Step 2 도메인 설계 전용 wrapper. .harness/.noask가 있어도 ask 진입 중에는 interactive 모드를 강제하고, 6개 도메인 카테고리를 순차적으로 수집한다. 일반 구현 계획이나 Step 3 구현 계획에는 사용하지 않는다.'
---

# Harness Plan Ask

이 스킬은 `/harness-ask` Step 2에서만 사용한다. `harness-plan`의 ask 모드 wrapper로 동작하며, `.harness/.noask`가 있더라도 이 스킬에 진입한 동안에는 interactive 모드를 강제한다.

Contract anchors: `mode:interactive-forced`, `noask-marker-ignored`, `six-category-collection`, `boundary:harness-step2-only`, `boundary:exclude-step3-implementation-plan`.

Codex에 전용 질문 도구가 없으면 일반 채팅 질문으로 대체한다. 한 번에 너무 많이 묻지 말고, 현재 결정을 막는 질문부터 진행한다.

## Required Category Flow

아래 6개 카테고리를 모두 다루기 전에는 다음 단계로 넘어가지 않는다.

1. 통합 사용자 시나리오 (`domain-category:integrated-user-scenario`)
2. 성공 기준 (`domain-category:success-criteria`)
3. 범위 / 제외 항목 (`domain-category:scope-exclusions`)
4. 제약 (`domain-category:constraints`)
5. 외부 의존성 (`domain-category:external-dependencies`)
6. 비기능 요구 (`domain-category:non-functional-requirements`)

질문은 한 번에 1~4개로 제한한다. 이 제한은 전체 카테고리를 생략하라는 뜻이 아니다.

사용자가 어떤 항목에 "상관없음", "기본값", "추천대로"라고 답하면 `사용자 위임 - 기본값 사용`으로 기록한다. 사용자가 한 질문에 답하면 그 질문에만 합의한 것으로 보고, 바로 다음 카테고리 질문으로 복귀한다.

이미 충분히 답한 항목은 반복해서 묻지 않는다. 대신 확인 질문 1개로 압축할 수 있다. 조용히 통과하지 않는다.

`Open Questions`는 카테고리 생략의 대체물이 아니다. 진행을 막지 않는 불확실성만 `Open Questions`에 남긴다.

## Output Responsibility

이 스킬은 도메인 설계 초안 본문만 만든다. 6개 카테고리 수집이 끝났다고 해서 Step 2 산출물을 자동 확정하지 않는다. 파일 저장, 승인, 수정, 취소 분기는 호출자인 Step 2 흐름이 처리한다.

초안에는 `harness-plan`의 출력 템플릿을 따른다.

- Requirements Restatement (`template-section:requirements-restatement`)
- 통합 사용자 시나리오 (`domain-category:integrated-user-scenario`)
- 성공 기준 (`domain-category:success-criteria`)
- 범위 / 제외 항목 (`domain-category:scope-exclusions`)
- 제약 (`domain-category:constraints`)
- 외부 의존성 (`domain-category:external-dependencies`)
- 비기능 요구 (`domain-category:non-functional-requirements`)
- Risks (`template-section:risks`)
- 사용자 답변과 반영 내용
- Open Questions (`template-section:open-questions`)

사용자 답변과 Codex 임시 가정은 분리해서 보이게 쓴다.

## Research and UX

최신 외부 정보가 필요한 경우 `harness-plan`의 리서치 트리거, 리서치 저장 계약, `research-field:*` 산출물 형식을 따른다.

요청에 화면, UI, 버튼, 메뉴, 레이아웃, 색상, 폰트, 아이콘, 내비게이션, 모달, 다이얼로그, 탭, 입력, 리스트, 카드, 사이드바, 헤더, 푸터, 토글, 드롭다운, 애니메이션, 전환, 반응형, 모바일, 데스크톱, 다크모드, 접근성, flow, wireframe, mockup 같은 UX 신호가 포함되면 `# UX` 또는 `## UX` 섹션을 만든다.

UX 섹션에는 다음 4개 필드가 필요하다.

- 변경 대상 화면/요소 (`ux-field:target-surface`)
- Before -> After (`ux-field:before-after`)
- 영향 사용자 시나리오 (`ux-field:affected-user-scenario`)
- 시각 증거 또는 생략 사유 (`ux-field:visual-evidence-or-omission-reason`)

## Completion Criteria

- ask 모드가 noask 기본값으로 바뀌지 않는다.
- 6개 카테고리를 모두 다루며, 부족한 항목은 다음 질문으로 이어진다.
- `Open Questions`가 카테고리 생략의 대체물이 되지 않는다.
- 사용자 답변과 Codex 임시 가정이 분리된다.
- 최신 외부 정보와 UX 신호는 `harness-plan`의 계약을 따른다.
