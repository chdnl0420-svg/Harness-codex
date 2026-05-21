---
name: harness-customer-user
description: 'Harness Step 7 고객 사용자 검증 wrapper. 제품 지식이 없는 일반 사용자 관점으로 핵심 흐름, 헷갈린 표현, 첫 클릭, 마찰 지점을 검증하고 .harness/results/customer-<slug>.md에 기록한다.'
origin: local-codex-port-of-chdnl0420-svg-Harness
---

# harness-customer-user

Harness Step 7에서 사용하는 Codex용 고객 사용자 검증 wrapper다. 구현자가 알고 있는 의도와 분리해, 처음 쓰는 사람 관점의 마찰을 기록한다.

## 호출 조건

- Step 6 QA가 `PASS`다.
- 워크플로 전체에서 마지막 사용자 관점 검증이 필요하다.
- `/harness-customer-user` 직접 호출로 고객 관점 검토를 요청했다.

## 절차

1. 최신 `.harness/test-guide-<slug>.md`와 QA 결과를 읽는다.
2. 사용자가 받는 산출물 또는 실제 실행 화면을 기준으로 확인한다.
3. 핵심 흐름의 첫 클릭, 용어 이해, 막힌 지점, 기대와 다른 점을 기록한다.
4. 실행하지 못했으면 `BLOCKED`, 증거가 부족하면 `UNKNOWN`으로 둔다.
5. 결과를 `.harness/results/customer-<slug>.md`에 붙일 수 있는 형식으로 작성한다.

## 결과 형식

```md
## Customer Validation
- Verdict: PASS | FAIL | BLOCKED | UNKNOWN
- Persona: <초보/비전문 사용자 관점>
- Scenario: <확인한 흐름>
- Evidence: <화면, 로그, 실행 결과>
- Friction: <헷갈린 점>
- Recommendations: <후속 개선안>
- Learning Prepend: yes | not-used
```

## 관계

- 세부 기준: `~/.codex/skills/harness/docs/steps/step7-customer.md`
- 절차 문서: `~/.codex/skills/harness/docs/procedures/customer-test-procedure.md`
- 학습 파일: `~/.codex/skills/harness/agents/learning/harness-customer-user.md`
