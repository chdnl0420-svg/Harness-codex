# Complete: 최종 보고

## 목표

Harness 작업의 결과, 검증, 남은 위험을 사용자에게 전달한다.

## 절차

1. progress, 계획, 리뷰, QA, 고객 테스트 산출물을 확인한다.
2. 완료된 변경과 보류된 항목을 분리한다.
3. 실행한 검증 명령과 결과를 요약한다.
4. 남은 위험과 다음 조치를 쓴다.

## 진입 게이트

다음이 없으면 Complete를 작성하지 않는다.

- `.harness/domain-<slug>.html`
- `.harness/implementation-<slug>.html`
- `.harness/reviews/review-<slug>.md`
- `.harness/results/qa-<slug>.md`
- `.harness/results/customer-<slug>.md` 또는 Step 7 비적용 사유

Step 5가 누락되었거나 Step 6/7 핵심 흐름이 `UNKNOWN` 또는 `BLOCKED`이면 stop report를 쓰고 멈춘다.
Step 6/7 결과 파일에는 `Learning Prepend: yes | not-used`가 있어야 한다.

## Step 7 결과 처리 게이트

`/harness` noask 모드에서도 Complete 진입 직전에는 원본 Harness와 동일하게 사용자에게 한 번 묻는다. 이는 noask의 두 예외 중 하나다.

질문 요지:

```text
Step 7 고객 사용자 검증 결과가 customer-<slug>.md에 정리되어 있습니다. 어떻게 처리할까요?
```

선택지는 세 가지뿐이다.

- A: 그대로 Complete 진행. 개선안은 report에 요약한다.
- B: 일시정지. `.harness/.pending-step7-review` 마커를 만들고 사용자가 customer 결과를 검토한 뒤 재호출한다.
- C: 개선안으로 신규 Harness 워크플로 자동 시작. 현재 워크플로는 Complete 처리하고, customer 결과의 권고/있었으면 하는 것/없었으면 하는 것을 합성해 새 목표를 만든다.

C를 선택해 생성된 새 워크플로의 progress에는 `auto_triggered_from: <parent-slug>`를 기록한다. 자동 chain을 막기 위해 `auto_triggered_from`이 있는 워크플로의 Complete 게이트에서는 C 선택지를 비활성화하고 A/B만 허용한다.

## 출력

최종 응답 또는 `.harness/results/report-<slug>.html`에 아래 내용을 포함한다.

- 완료한 일
- 변경 파일
- 검증 결과
- 실패/차단/미검증 항목
- 다음 단계

## noask 처리

`/harness`에서는 위 Step 7 결과 처리 게이트 외에 후속 작업을 임의로 묻거나 새 워크플로로 시작하지 않는다. A/B/C 선택 결과와 자동 결정 기록을 report에 남긴다.
