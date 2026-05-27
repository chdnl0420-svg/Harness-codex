# Learning Data: harness-engineering-auditor

> Schema 1.0. dated entries only (`[YYYY-MM-DD]` 태그 필수).
> add/update/delete 는 메인 Codex 가 서브에이전트 응답의 `## Learning Proposals` 섹션을 검증 후 반영.
> 사이즈 정책: 작업 캡 800줄. 공식 startup inject 는 첫 200줄 컷 — 핵심 patterns 는 상단 배치.

## Principles
범용 원칙. 거의 안 바뀜.

(빈 섹션)

## Patterns
잘 통하는 접근법. 자주 발견되는 결함 패턴 + 자가 수정 성공 사례.

- [2026-05-25] **1차+2차 audit 이견 처리 — "2차 우선 원칙 + 정책 텍스트 범위 초과 케이스 1차 채택"**: 7c 종합 단계에서 1차 self vs 2차 codex 가 다른 verdict 를 낼 때 기본은 *2차 우선* (07-audit.md §7c, self-review bias 차단). 단 *2차가 정책 텍스트의 범위를 초과 적용* 한 경우 1차 채택. 예: step 1 non-waivable #1 의 본질이 "production **credential** BLOCKED" 인데 2차 codex 가 "production URL 도 동등 BLOCKED" 로 확대 해석 → credential 0건 + URL only + `changed_in_this_run=no` 면 1차 PASS 채택. 종합 표에 *이견 등급 (critical/medium/low)* + *해소 근거* 명시 의무.
- [2026-05-25] **artifact 자가 수정 #1 — 파일명 위반 + 의무 필드 누락 통합 처리 패턴**: step 6 산출물이 *파일명 위반* (예: report.md vs 명세된 customer.md) + *Verdict 필드 누락* 두 finding 가 동시 발견되면 한 번의 artifact correction 으로 통합 처리 가능 (OWASP ASI06 8-step 가드 single-pass 적용). 신규 customer.md 생성 + Verdict 추가 + 원본 report.md 보존 (rollback 가능) + 참조 파일 (waiver.md) 의 path 도 함께 수정. 카운터: 1/2 소진.
- [2026-05-25] **codex timeout (exit 124) 처리 — 분석 완료 후 timeout = valid 출력**: codex exec 가 180s timeout 으로 exit 124 를 반환하더라도 stdout 에 결론이 포함되어 있으면 valid 출력으로 처리. auth 실패(2) / quota 소진(3) 이 아니므로 fallback 불필요. invocation.md 에 exit 124 + "분석 완료 후 timeout" 명시. 2nd-external-audit.md 에 stdout verbatim 저장. exit 124 자체는 명시적 BLOCKED 사유 아님.
- [2026-05-25] **waiver 사전 작성 타임스탬프 독립 검증 패턴 (2차 audit 핵심)**: 2차 codex 가 `Get-ChildItem -Recurse -File | Sort-Object LastWriteTimeUtc` 로 파일 mtime 을 독립 검증하면 waiver 사전/post-hoc 여부를 객관적으로 확인 가능. step X waiver 가 step X 종료 후 step (X+1) 진입 전에 생성되었는지를 타임스탬프로 증명하는 것이 2차 audit 의 핵심 가치 중 하나. 1차 self 가 같은 검증을 수행해도 self-review bias 가 있으므로 2차 외부 verifier 의 mtime 검증이 정합성 보장.

## Anti-patterns
하면 안 되는 것. 자가 수정 회귀 사례.

- [2026-05-25] **메인 Codex 의 "codex LGTM:NO 시 모든 finding 을 pre-existing 으로 분류하고 회송 0회" 패턴 = PARTIAL 트리거**: step 5 정책 (`05-review.md:49`) "LGTM:NO → 즉시 step 3 회송" 은 강제. 메인 Codex 가 *git show HEAD* 검증으로 finding 의 pre-existing 성격을 확인하더라도, *회송 자체를 생략* 하면 강제 항목 위반 + waiver 없음 → 자동 PARTIAL. 정합 처리: (a) 사전 `05-review/waiver.md` 작성 (pre-existing 분류 사유 + git evidence + 회송 생략 정당화) 후 audit 인정 받기, **또는** (b) 회송 후 step 5 재심에서 finding 의 pre-existing 분류 적용. post-hoc waiver 는 audit 인정 게이트 통과 못 함.
- [2026-05-25] **자동 수정 불가 항목을 자가 수정 카운터에 포함 시도 금지**: workflow 소급 실행 (예: step 5 회송 후 step 3 재실행) 은 audit 의 *"규칙·일관성·구조만 고친다"* 범위 밖. 시도조차 안 함 + self-correction.md 에 *불가 사유* 명시 후 PARTIAL 사유로 기록.

## Project-specific
프로젝트별 결함 특성. 회차마다 다름.

### VisualAgents.dryrun (Electron + React + electron-vite, AgentView)

- [2026-05-25] **refactor 회차 waiver 4건 누적 패턴**: AgentView 의 refactor 회차는 (1) CQRS+ES 미적용 (`02-domain/waiver.md`), (2) TDD characterization (`03-tdd/waiver.md`), (3) 80% coverage 미설정 (`04-qa/coverage-waiver.md`), (4) dev build 우회 customer (`06-customer/waiver.md`) 4건 동시 발생. 모두 정합 사유. *다음 회차 Vitest 도입 → 1건 해소* 권장. 단 누적 4건 자체는 audit `LOW` finding 으로 등재 (waiver-driven workflow 의 *조용한 degradation* 신호).
- [2026-05-25] **pre-existing dead code 보존 정책의 audit 인정 사유**: CLAUDE.md §3 "Don't remove pre-existing dead code unless asked" + `void` 캐스트 패턴은 TypeScript `noUnusedLocals` 회피의 *세 번째 옵션* (제거/사용 외). audit 이 *dead code 보존* 을 finding 으로 등재하면 사용자 정책과 충돌 — `void` 캐스트가 *의도 명시* 임을 인정.

## Open Questions
아직 결론 안 난 것. 결론 나면 Patterns/Anti-patterns 로 이동.

- [2026-05-25] **PARTIAL 판정 후 자동 모드의 사용자 확인 처리**: `run-modes.md §3` 가 "사용자 확인 후 step 9" 명시, SKILL.md 가 "5 예외 enum 외 사용자 결정 안 묻음" 명시. PARTIAL 은 5 예외 enum 어디에도 안 들어감. 충돌 해소 정책 명문화 필요. *임시 해석*: 자동 모드는 PARTIAL 도 자동 진행 + summary 에 PARTIAL 명시 + 사용자가 결과 확인 후 다음 회차 결정. 다음 회차에서 본 ambiguity 의 명문화 검토.

## Resolved Questions
해소된 Open Question 의 기록.

(빈 섹션)

## References

- 본 회차: `D:\Project\VisualAgents.dryrun\.harness-engineering\runs\20260525T031018Z-refactor\07-audit\`
- 이전 회차: `20260524T1217Z-refactor` (PASS, 자가 수정 0)
- skill ambiguity dry-run 제안: `07-audit/skill-improvement.md §Ambiguity A, B`
