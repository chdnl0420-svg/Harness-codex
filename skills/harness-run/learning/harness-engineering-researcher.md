# Learning Data: harness-engineering-researcher

> Schema 1.0. **본 파일은 placeholder.** researcher 는 **stateless 호출** (fresh context per call) 결정에 따라 누적하지 않는다.
> 메인 Codex 는 researcher 호출 시 **본 파일을 prepend 하지 않는다** — SKILL.md "Learning 파일 자동 prepend" 규약의 예외. (researcher 는 fresh context 보장이 우선.)

(누적 학습 없음 — stateless 결정, [README.md](README.md) 참조)

## 왜 stateless 인가

- **출처 다양성 보존** — 누적 learning 은 *"좋은 출처"* 편향을 만들어 같은 도메인에서 같은 출처를 반복 인용할 위험. researcher 는 매 회차 새 출처 발견이 가치.
- **환각 격리** — 1회 fabricated citation 이 누적되면 다운스트림 회차 모두를 오염. stateless 는 매회 독립 검증.
- **Anthropic 권고와 정합** — Multi-agent research system 의 *"fresh context per sub-research"* 패턴.
- **메타 학습 보존 채널 따로 있음** — 일반 원칙·검색 전략 같은 메타 학습은 본 skill 밖 `harness-deep-researcher` 의 learning 에 이미 누적. 정보 손실 위험 낮음.

## Open Question 발생 시

researcher 응답에 `## Learning Proposals` 섹션이 있어도 메인 Codex 는 **본 파일에 반영하지 않는다**. 대신:

1. 응답 본문에 그대로 보존 (보고용)
2. 일반화 가능한 메타 원칙이면 `harness-deep-researcher` 의 learning (`~/.codex/skills/harness-run/agents/learning/harness-deep-researcher.md`) 에 반영
3. 프로젝트별 출처는 현재 회차 폴더의 `runs/<run-id>/log.md` 에 1줄 기록 (메인 Codex 가 자동으로 회차 prefix 적용 — 루트 `.harness-engineering/log.md` 사용 금지)
