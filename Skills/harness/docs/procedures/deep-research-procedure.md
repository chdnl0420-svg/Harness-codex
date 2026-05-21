# Deep Research Procedure

## 목적

최신 정보나 외부 근거가 필요한 Harness 결정을 위해 출처가 있는 조사 결과를 만든다.

## 입력

- 조사 질문
- 필요한 깊이: `light`, `standard`, `deep`
- 적용할 프로젝트 맥락
- 결과를 사용할 Harness 단계

## 절차

1. 질문을 하위 질문으로 나눈다.
2. 공식 문서, 릴리스 노트, 표준 문서, 1차 출처를 우선 확인한다.
3. 최신성이 중요한 정보는 날짜와 버전을 명시한다.
4. 출처가 충돌하면 충돌 자체를 기록한다.
5. 구현, 계획, QA에 반영할 결론과 한계를 쓴다.
6. 검증하지 못한 주장은 결정 근거로 쓰지 않는다.

## 출력 기준

Research field anchors: `research-field:summary`, `research-field:key-findings`, `research-field:sources-consulted`, `research-field:search-trail`, `research-field:stop-reason`, `research-field:research-date`, `research-field:step2-impact`, `research-field:inferred`.

리서치 산출물에는 반드시 다음 항목을 포함한다.

- Summary
- Key Findings
- Sources Consulted
- Search Trail
- Stop reason
- 조사 일자
- 어떤 Harness 결정에 영향을 주는지
- Inferred: 출처 없이 추론한 내용과 결론에 쓰면 안 되는 내용
- Open Questions

결과를 Step 2에서 사용할 때는 `.harness/research/research-<slug>-<NN>-<topic>.md`에 저장하고, progress에 저장 경로를 남긴다.
