# harness Summary — {{run_id}}

> step 8 산출물. **pre-commit draft** — 실제 commit SHA·시각은 산출물 어느 파일에도 기록되지 않음. **`git log -1 --format='%h %ai'`** 로 확인 (no-post-commit-mutation 계약). `09-commit/status.md` 는 pre-commit readiness (포함·제외·메시지·`READY_TO_COMMIT`·`COMMITTED_SHA: <PENDING>`) 만 담음.

## Goal
- 자연어 목표 (사용자 입력 첫 줄):
- scope:
- 명백히 제외:

## Verdict (한눈에)
| 단계 | 결과 |
|---|---|
| Build / Test / Coverage (step 4) | PASS / FAIL / BLOCKED |
| Codex review (step 5) | LGTM:YES / NO / BLOCKED |
| Customer test (step 6) | PASS / FAIL / BLOCKED / UNKNOWN |
| Audit (step 7) | PASS / FAIL / BLOCKED |
| Overall | PASS / FAIL / BLOCKED |

## 실패/BLOCKED 가 있으면 상단 명시
(숨김 금지 — 실패 항목 전부 여기에 요약)

## Implementation Summary
- 변경된 사용자 프로젝트 파일 (수): <N>
- 생성된 `.harness/` 산출물 (수): <N>
- 적용한 외부 의존성 처리: in-memory / sandbox (각 도구)

## DDD Summary
- Bounded Contexts: <list>
- Aggregates (수, root entity 이름): <list>
- Domain Events (수): <N>
- CQRS + ES 적용 여부: 모든 Aggregate (skill 강제)

## TDD Summary
- 총 사이클: <N>
- PASS: <N> / FAIL: <N> / SKIP: <N>
- 사용한 in-memory Repository: <list>
- 사용한 sandbox endpoint: <list>

## QA Result
- 빌드: PASS / FAIL
- 테스트: <count> PASS / <count> FAIL
- 커버리지: <%>
- 정적 분석 결함 수: <N>
- Mock 사용 grep 결과: 0 matches (또는 위반 파일)
- production endpoint grep 결과: 0 matches (또는 위반)

## Code Review Result (Codex)
- LGTM: YES / NO / BLOCKED
- 핵심 finding (CRITICAL/HIGH): <list>

## Customer Test Result
- Verdict: PASS / FAIL / BLOCKED / UNKNOWN
- SUS / SEQ 점수:
- Time-to-First-Value:
- 첫 클릭 정확도:
- redaction 적용된 산출물:

## Audit Result
- Verdict: PASS / FAIL / BLOCKED
- 산출물 자가 수정: <N>/2
- 스킬 자가 수정: <N>/2
- Findings (severity 별 수): CRITICAL <N> / HIGH <N> / MEDIUM <N> / LOW <N>
- 스킬 자기 개선 변경: <list of files in `07-audit/skill-improvement.md`>

## Remaining Risks
- ⚠️ <risk>

## Hotspots (해소되지 않은 미해결)
- <list from `02-domain/event-storming.md`>

## Commit 계획 (step 9 가 실행)
- **이 skill 은 commit 만 수행. push 는 절대 안 함 — 사람이 직접.**
- 커밋 메시지 형식: summary 기반 자연어 자유 + Conventional prefix 자동 추론 (feat/fix/refactor/docs/test/chore)
- 커밋 대상: 사용자 프로젝트 코드 + `.harness/` 산출물
- 제외 대상: [step 9 `docs/steps/09-commit.md` 의 민감 파일 제외 표](../../docs/steps/09-commit.md#민감-파일-제외-확장된-차단-목록) 의 완전한 denylist 적용. 실제 회차의 제외 목록은 `runs/{{run_id}}/09-commit/files-excluded.md` 참조 (요약본 부분 재서술 금지 — 축약 시 보호 범위 왜곡 위험).
- `runs/{{run_id}}/09-commit/status.md` 는 pre-commit readiness (포함·제외·메시지·`READY_TO_COMMIT`·`COMMITTED_SHA: <PENDING>`) 만 담음. **실제 hash·시각은 `git log -1 --format='%h %ai'` 로 확인** (산출물 파일에 기록되지 않음 — no-post-commit-mutation 계약).

## 자동 결정 기록 (noask 정책)
- 본 회차 자동 결정 목록은 `log.md` 의 `AUTO-DECISION:` 라인 참조
- 사용자 결정 (예외 호출) 발생 여부: YES (예외 enum) / NO
