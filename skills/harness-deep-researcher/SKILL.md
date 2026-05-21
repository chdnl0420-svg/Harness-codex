---
name: harness-deep-researcher
description: harness 외부 리서치 wrapper. Plan-Act-Verify 반복 루프로 다중 출처 검색·교차검증. 사용 가능한 helper/sub-agent가 있으면 맡기고, 없으면 호출자 Codex가 직접 수행한다. 라이브러리 비교/최신 모범 사례/보안 권고/마이그레이션 영향 등에 사용.
---

# harness-deep-researcher (skill wrapper)

본 skill 은 **helper/sub-agent를 호출하거나 호출자 Codex가 직접 수행하는 wrapper**다. 원본 agent 파일은 설치하지 않으며, 이미 설치된 procedure·learning 파일을 정본으로 사용한다.

## 호출 조건

- step2 (`harness-plan`) Phase 2 — 외부 정보 필요 판단 시
- step5 (`harness-review`) — Codex 리뷰가 "최신 표준 확인 필요" 신호를 낼 때
- 호출자 Codex가 학습 cutoff 이후 변경 가능 영역을 다룰 때 (라이브러리 deprecation, CVE, API breaking change 등)

## 절차

1. **Learning Prepend 계약 4단계 수행** (workflow.md 참조):
   - 공용 학습 파일 Read: `~/.codex/skills/harness/agents/learning/harness-deep-researcher.md`
   - prompt 맨 앞에 `## Prior Learning (READ FIRST — DO NOT SKIP)` 헤더 prepend
   - 본 작업 요청 본문은 그 뒤에

2. **사용 가능한 helper/sub-agent 또는 직접 수행**:
   - helper/sub-agent가 가능하면 `Prior Learning 헤더 + 본 작업 요청`을 전달한다.
   - helper/sub-agent가 불가능하면 호출자 Codex가 같은 입력으로 직접 리서치한다.
   - 어떤 경우에도 별도 worktree 격리는 사용하지 않는다.

3. **결과 처리** — helper 또는 호출자 Codex가 작성한 `.harness/research/research-<slug>-<NN>-<topic>.md` 본문을 Read 후 호출자(step2 / step5)에 verbatim 반환.

## 페르소나 객관성 (왜 agent 인가)

본 단위가 **helper/sub-agent 로 유지되는 이유**:
- 호출자 Codex 와 *별도 컨텍스트* — 메인의 가정/편향이 리서치에 새지 않음.
- sub-agent 가 자체 WebSearch/WebFetch 도구로 다중 출처 교차검증 수행.
- "Plan-Act-Verify" 루프가 별도 컨텍스트에서 돌아야 검증 단계가 메인 응답에 침투 안 함.

SKILL.md "자동 결정 매핑" 표가 명시한 **페르소나 3개 (qa-engineer / customer-user / deep-researcher) 중 하나**. skill 통합 대상이 아님 — 본 skill 은 helper/sub-agent 호출 또는 직접 수행 wrapper 일 뿐.

## 관계

- 실제 작업자: 사용 가능한 helper/sub-agent 또는 호출자 Codex 직접 수행
- 공용 학습 파일: `~/.codex/skills/harness/agents/learning/harness-deep-researcher.md`
- 호출자: `harness-plan` (step2 Phase 2), `harness-review` (step5 외부 검증)
- 산출물: `.harness/research/research-<slug>-<NN>-<topic>.md`
