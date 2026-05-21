# Step 7: 고객 사용자 검증

## 목표

최종 사용자 관점에서 첫 화면, 핵심 과업, 문구, 흐름의 마찰을 확인한다.

## 절차

1. 실제 사용자가 접하는 방식으로 앱을 실행하거나 산출물을 연다.
2. 첫 화면에서 무엇을 해야 하는지 5초 기준으로 평가한다.
3. 핵심 과업을 사용자 언어로 수행한다.
4. 헷갈린 단어, 막힌 지점, 기대와 다른 동작을 기록한다.
5. `.harness/results/customer-<slug>.md`에 결과를 작성한다.

## 관찰 기준

- 첫 화면에서 제품/기능의 목적이 보이는가?
- 사용자가 다음 행동을 추측하지 않고 시작할 수 있는가?
- 버튼, 메뉴, 상태 문구가 도메인 사용자 언어로 되어 있는가?
- 오류가 나면 회복 방법을 알 수 있는가?
- 핵심 가치까지 도달하는 데 불필요한 단계가 있는가?

## 결과 형식

```md
## Customer Test Round <n>
- Verdict: PASS | FAIL | BLOCKED | UNKNOWN
- Persona: <사용자 유형>
- First impression: <5초 인상>
- First value time: <측정값 또는 측정 불가>
- Task path: <클릭/입력 흐름>
- Friction: <막힘>
- Recommendation: <개선안>
- Learning Prepend: yes | not-used
```

`harness-customer-user` helper를 사용했으면 `Learning Prepend: yes`여야 한다. helper를 사용하지 않고 호출자 Codex가 직접 관찰했으면 `Learning Prepend: not-used`를 기록한다.

## 재진입 규칙

- 문구/흐름 문제는 Step 3로 돌려 범위를 다시 정한다.
- 구현 버그는 Step 4로 돌린다.
- QA에서 이미 잡힌 문제면 Step 6 결과와 연결하고 중복 이슈로 표시한다.
- 후속 개선이 별도 기능이면 현재 작업을 완료하고 새 작업 후보로 기록한다.

## 판정

- `PASS`: 첫 사용자가 핵심 가치를 무리 없이 얻을 수 있다.
- `FAIL`: 핵심 과업이 막히거나 심각한 혼란이 있다.
- `BLOCKED`: 실행/접근 환경이 없어 확인할 수 없다.
- `UNKNOWN`: 증거가 부족하다.

## Complete 차단

Step 7이 핵심 흐름인데 `BLOCKED` 또는 `UNKNOWN`이면 Complete로 가지 않는다. 제품 특성상 고객 검증이 비적용이면 비적용 사유를 `.harness/results/customer-<slug>.md`에 기록한다.

## 완료 조건

- 사용자의 첫 인상이 기록되어 있다.
- 과업별 결과와 근거가 있다.
- 개선 제안이 제품 관점으로 정리되어 있다.
- 후속 작업 여부가 보류 또는 완료로 명확히 표시되어 있다.
