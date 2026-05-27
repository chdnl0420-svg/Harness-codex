# step 3 - TDD 루프

step 2 에서 만든 Bounded Context 와 Aggregate 를 실제 프로젝트 코드로 구현한다. 모든 구현은 Red -> Green -> Refactor 순서를 따른다.

## 입력

- `.harness/02-domain/domain-model.md`
- `.harness/02-domain/event-storming.md`
- `.harness/02-domain/code-skeleton.md`
- 프로젝트 테스트 명령과 기존 테스트 구조

## 원칙

- 테스트를 먼저 작성한다.
- Red 는 실제 테스트 러너를 실행해 실패 로그를 남긴다.
- Green 은 도메인 규칙을 완전히 반영해 한 번에 통과시킨다.
- Refactor 는 매 사이클 의무다. 할 일이 없으면 `Refactor: 없음` 으로 기록한다.
- Mock, stub, monkeypatch 기반 테스트 더블은 금지한다.
- Repository 는 in-memory 구현체 또는 sandbox/test endpoint 를 사용한다.
- production endpoint 와 production credential 은 BLOCKED 로 처리한다.

## 사이클

각 Aggregate 의 시나리오마다 다음 파일을 만든다.

`.harness/03-aggregate-<name>/tdd/cycle-NNN.md`

```markdown
# TDD Cycle NNN - <시나리오>

## Red
- 테스트 파일:
- 실행 명령:
- 실패 로그:
- 기대한 실패인지:

## Green
- 구현 파일:
- 반영한 도메인 규칙:
- 실행 명령:
- 통과 로그:

## Refactor
- 변경 내용 또는 `Refactor: 없음`:
- 구조 검사 결과:
- 재실행 로그:
```

## 실패 처리

- 같은 사이클에서 5회 연속 실패하면 멈추고 사용자에게 보고한다 (예외 ② `TDD_5X_SAME_SCENARIO`).
- 실패 원인은 `TYPE_ERROR`, `NULL_REFERENCE`, `PERMISSION_DENIED`, `RESOURCE_NOT_FOUND`, `RACE_CONDITION`, `LOGIC_ERROR`, `IO_FAILURE`, `TIMEOUT`, `API_CONTRACT`, `SECURITY`, `TEST_COVERAGE`, `BUILD_FAILURE`, `OTHER` 중 하나로 기록한다.
- 서로 다른 실패는 별도 진척으로 본다.

## Cycle 간 자동 진행 (응답 분할 금지)

step 3 내부의 모든 cycle 은 **한 호흡으로 연속** 진행한다. SKILL.md §7.1 (응답 분할 절대 금지) 와 docs/workflow.md 의 "끝까지 자동 진행" 정의 준수.

- cycle-NNN GREEN 통과 → 즉시 cycle-(NNN+1) RED 진입. 사용자 입력 대기 **금지**.
- 마지막 cycle 종료 → 즉시 step 4 (QA) 진입. 사용자 입력 대기 **금지**.
- 금지 멘트 (Cycle 4 학습 패턴):
  - "다음 응답에서 cycle-NNN 부터 계속 진행합니다"
  - "한 응답 한도 + 정확성 우선으로 응답 단위를 끊었습니다"
  - "계속하려면 `진행해줘` 주시면 cycle-NNN 부터 step 9 까지 자동 진행합니다"
  - "본 응답에서 cycle-NNN 까지 완료. 다음 응답에서 cycle-(NNN+1) 진행"
- 자동 진행 중단 유일 사유: 예외 ② `TDD_5X_SAME_SCENARIO` 트리거 또는 사용자의 명시적 중단 요청.

**자가 점검 (cycle 종료 시)**:
- [ ] 본 cycle 의 RED/GREEN/Refactor 3 단계 모두 완료 + `cycle-NNN.md` 산출물 작성?
- [ ] log.md 에 cycle 결과 1줄 기록?
- [ ] 다음 cycle 또는 step 4 즉시 진입 준비?
- [ ] 사용자에게 진행 확인을 묻거나 응답을 끊으려는 사고가 떠올랐다면 → STOP, §7.1 위반. 그대로 다음 cycle/step 진입.

## 구조 검사

Green 직후 Refactor 단계 안에서 `docs/code-structure.md` 를 적용한다.

위반 기준 (`docs/code-structure.md` 의 단일 정합 파일 길이 정책과 일치):

- 한 파일에 주요 객체 2개 이상 → 즉시 분리
- UI 파일에 상태 관리·외부 호출·검증·도메인 규칙 포함 → 즉시 분리
- 기능 파일에 마크업·스타일 포함 → 즉시 분리
- 한 파일 길이:
  - ≤ 200줄: OK
  - 201–400줄: `MEDIUM` finding (warning) — Refactor 권고, 즉시 분리 강제 아님
  - 401–800줄: `HIGH` finding (hard cap) — **자동 분리 시도** 강제
  - > 800줄: `CRITICAL` finding — audit 단계가 자동 분리

위반 시 객체별·역할별 파일로 분리하고 테스트를 다시 실행한다. 실패하면 변경을 되돌리고 로그에 남긴다.
