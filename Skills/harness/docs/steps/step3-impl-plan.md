# Step 3: 구현 계획

## 목표

Step 2 설계를 코드 변경 단위, 검증 방법, 위험 관리 계획으로 바꾼다.

## 절차

1. 회송된 결함이 있으면 `Returned Defects` 블록을 먼저 읽는다.
2. 관련 파일을 탐색한다.
3. 기존 패턴, 테스트 위치, 실행 명령을 확인한다.
4. 변경 범위를 최소 단위로 나눈다.
5. 각 단위마다 검증 방법을 붙인다.
6. 롤백 또는 보류 조건을 명시한다.
7. Chunk 모드가 필요한지 판단한다.

## 회송 입력 게이트

Step 5/6/7에서 돌아온 경우 구현 계획 맨 앞에 아래 블록이 있어야 한다.

```md
## Returned Defects (READ FIRST)
- Source step: Step 5 | Step 6 | Step 7
- Return path: return-to-step-3 | return-to-step-4 | pause
- Loop counter: <DEFECT_ENUM:file-or-area>=<count>
- Evidence: <review/qa/customer file path and command/screenshot/log>
- Required change: <next concrete action>
```

이 블록이 없으면 이전 Step의 결과 파일을 다시 읽고, 결함 요약을 먼저 붙인 뒤 계획을 수정한다.

## 탐색 체크리스트

- `rg --files`로 관련 소스, 테스트, 설정 파일을 찾는다.
- package/test 스크립트, 빌드 명령, lint 명령을 확인한다.
- 기존 구현 스타일과 에러 처리 방식을 기록한다.
- 사용자 요청과 직접 관련 없는 파일은 비범위로 둔다.
- 최신 외부 정보가 필요한 항목은 딥 리서치 대상으로 분리한다.

## 계획 항목 형식

각 작업 단위는 아래 형식을 따른다.

```md
### Task <n>: <작업명>
- Files: <수정 예상 파일>
- Change: <구체적 변경>
- Verify: <명령 또는 수동 검증>
- Risk: <주요 위험>
- Rollback: <되돌리는 방법>
```

## Chunk 모드 판정

아래 신호 중 2개 이상이면 `Chunk mode: ON`으로 기록하고 vertical slice로 나눈다.

- 변경 예상 파일 6개 이상
- 서로 다른 레이어 3개 이상
- 독립 사용자 시나리오 3개 이상
- 검증 경로 3개 이상
- 위험한 마이그레이션 또는 대규모 리팩터

각 chunk는 Step 4 구현, Step 5 리뷰, Step 6 QA를 반복한다.

## 실패/보류 기준

- 관련 파일을 찾지 못하면 `BLOCKED`가 아니라 먼저 검색 범위를 넓힌다.
- 테스트 명령이 없으면 대체 검증 방법을 계획에 쓴다.
- 요구사항이 상충하면 noask에서는 가정을 기록하고, ask 모드에서는 질문한다.
- 계획만으로 구현 위험을 설명할 수 없으면 Step 4로 가지 않는다.

## 산출물

`.harness/implementation-<slug>.html`

## 포함 내용

- 변경 대상 파일/모듈
- 작업 순서
- 테스트/검증 명령
- 위험과 대응
- 비범위
- Step 4 진입 조건

## 완료 조건

- 모든 변경이 사용자 요청으로 추적 가능하다.
- 테스트할 수 없는 항목은 이유가 기록되어 있다.
- Step 4에서 바로 구현할 수 있다.
- 실패 시 어느 단계로 돌아갈지 정해져 있다.
