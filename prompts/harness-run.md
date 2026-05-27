# harness-run — DDD/TDD/Audit 9-step workflow

본 prompt 호출 = "끝까지 자동으로 돌려라" 명시 위임. SKILL 본문을 흡수 + 사용자 목표 인자 받아 step 1~9 자동 진행.

## 사용자 목표 (인자)

{{ARGS}}

## SKILL 본문 (자동 흡수)

다음 파일을 즉시 read 해 본 prompt 의 컨텍스트에 추가:
- `~/.codex/skills/harness-run/SKILL.md`
- `~/.codex/skills/harness-run/docs/workflow.md`
- `~/.codex/skills/harness-run/docs/code-structure.md`
- `~/.codex/skills/harness-run/docs/run-modes.md`

step 진입 시 해당 step 의 절차서 추가 read:
- `~/.codex/skills/harness-run/docs/steps/0<N>-<name>.md`

sub-agent 호출 시 해당 agent 정의 + learning 추가 read:
- `~/.codex/skills/harness-run/agents/<name>.md`
- `~/.codex/skills/harness-run/learning/<name>.md` (researcher 제외)

## 시작 통보 (1회)

```text
[harness-run] 단일 자동 모드 시작. 9단계 워크플로우 끝까지 자동 진행.
- step 1: 언어·프레임워크 감지 + 외부 의존성 점검
- step 2: DDD 도메인 모델링
- step 3: TDD 루프 (Mock 금지)
- step 4: QA 검증
- step 5: 코드 리뷰 (codex-reviewer 재귀 호출)
- step 6: 고객 테스트 (harness-customer-user)
- step 7: audit + 자가 수정
- step 8: summary.md + summary.html
- step 9: 커밋 (push 안 함)
사용자 결정 요청은 5 예외 enum 발동 시만.
log: .harness/runs/<run-id>/log.md
```

위 통보 후 즉시 step 1 진입.
