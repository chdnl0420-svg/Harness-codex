---
name: ecc-command-harness-deep-researcher
description: 'Slash command ''/harness-deep-researcher''. 최신 외부 정보가 필요한 주제를 항상 deep tier로 출처 기반 조사한다. 결과는 Harness Step 2 결정에 미치는 영향과 저장 가능한 Markdown 형식으로 정리한다.'
origin: local-codex-port-of-chdnl0420-svg-Harness
---

# Command: /harness-deep-researcher

최신 정보, 라이브러리 비교, 보안 권고, API/SDK 마이그레이션 영향처럼 외부 근거가 필요한 주제를 deep tier로 조사한다.

## 절차

1. 조사 질문을 하위 질문으로 나눈다.
2. 공식 문서와 1차 출처를 우선한다.
3. 날짜, 버전, 정책 상태를 확인한다.
4. 출처가 충돌하면 충돌 자체를 기록한다.
5. 확인하지 못한 주장은 결론 근거로 쓰지 않는다.
6. 출처 없이 추론한 내용은 `Inferred`로 분리한다.

## 출력

결과는 `.harness/research/research-<slug>-<NN>-<topic>.md`에 저장할 수 있는 Markdown으로 작성한다.

필수 필드:

- Summary (`research-field:summary`)
- Key Findings (`research-field:key-findings`)
- Sources Consulted (`research-field:sources-consulted`)
- Search Trail (`research-field:search-trail`)
- Stop reason (`research-field:stop-reason`)
- 조사 일자 (`research-field:research-date`)
- Step 2 영향 (`research-field:step2-impact`)
- Inferred (`research-field:inferred`)
- Open Questions

## 기준

- slash command 호출은 항상 deep tier 기준으로 수행한다.
- 호출자가 light/standard를 언급해도 이 command는 deep tier로 조사한다.
- 실제 파일 쓰기는 호출자 Codex가 담당할 수 있다. 이 경우 저장 경로를 progress에 남긴다.
- Codex 환경에서는 Claude 전용 subagent 명령을 그대로 복사하지 않는다.
