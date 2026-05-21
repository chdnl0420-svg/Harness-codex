# Step Groups

Harness의 정식 실행 단위는 `Step 1`부터 `Step 8`까지와 `Complete`뿐이다. 이 문서는 읽기 편의를 위한 그룹 설명이며, progress나 보고서에서 `Phase 1`, `Phase 2` 같은 실행 단계명으로 쓰지 않는다.

## Discovery Group

- Step 1: 초기화 또는 재개
- Step 2: 도메인 설계
- Step 3: 구현 계획

## Implementation Group

- Step 4: 코드와 문서 변경

## Verification Group

- Step 5: 리뷰
- Step 6: QA
- Step 7: 고객 사용자 검증

## Completion Group

- Step 8: commit/push 처리
- Complete: 최종 보고

각 Step은 이전 Step의 산출물을 다시 읽고 시작한다. 내부 작업 분해가 필요하면 `Task` 번호를 사용하고, Harness Step 번호와 섞지 않는다.
