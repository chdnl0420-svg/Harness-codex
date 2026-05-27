# 1st Self-Audit — `harness-engineering-auditor` (Codex)

> v2 audit 강화의 1차 단계. `07-audit/1st-self-audit.md` 로 저장.
> 본 단계 종료 후 2차 외부 codex audit (`07-audit/2nd-external-audit.md`) 가 자동 실행.
> 1차+2차 종합은 `07-audit/findings.md` 에 별도 기록.

---

## 회차 컨텍스트

- 회차 ID: `<UTC-timestamp>-<slug>`
- run-mode: <new-domain / feature-add / refactor>
- 1차 audit UTC: <YYYY-MM-DD HH:MM:SS UTC>
- auditor: `harness-engineering-auditor` (model: claude-sonnet-4-6)
- learning prepend: `~/.codex/skills/harness-run/learning/harness-engineering-auditor.md` (bytes: <N>)

---

## 1차 Verdict (4단계)

`PASS` / `PASS_WITH_WAIVERS` / `PARTIAL` / `FAIL`

> 본 1차 verdict 는 자체 점검 한정. 최종 verdict 는 `findings.md` 의 종합 단계가 결정.

---

## Audit Checklist (8 항목 — v5 그대로 유지)

각 항목 PASS/FAIL/WAIVER 마킹 + 근거 1줄.

- [ ] 1. Requirements matched (자연어 목표 vs 산출물 대조) — <근거>
- [ ] 2. DDD coherent (Bounded Context · Aggregate · Invariant · Command · Event · Query · Projection) — <근거>
- [ ] 3. TDD evidence complete (Red FAIL 로그 + Green PASS 로그 + Refactor 노트) — <근거>
- [ ] 4. Numbers consistent (커버리지 % · 사이클 수 · 한도 카운터 모든 파일에서 일치) — <근거>
- [ ] 5. External review summarized (Codex 리뷰 + customer test 결과 hidden 없이 반영) — <근거>
- [ ] 6. Workflow complete (step 1~9 누락 없이 모두 종료) — <근거>
- [ ] 7. Skill improvement considered (반복 finding 이 skill 파일 자기 개선 트리거 일으켰는지) — <근거>
- [ ] 8. Code structure checked (객체 단위 분리 + UI↔기능 분리 위반 자동 리팩토링 시도 여부) — <근거>

---

## non-waivable invariant 7개 점검 (위반 즉시 FAIL)

[docs/run-modes.md §non-waivable](../docs/run-modes.md#non-waivable-invariant-7개) 참조.

| # | invariant | 결과 | 근거 (파일:줄) |
|---|---|---|---|
| 1 | step 1 외부 의존성 감지 + production credential BLOCKED | PASS/FAIL | <근거> |
| 2 | step 5 codex-reviewer 실 호출 + raw 결과 보존 | PASS/FAIL | <근거> |
| 3 | step 7 1차+2차 audit 둘 다 실행 + `findings.md` 산출 | PASS/FAIL | <근거 — 본 회차에서 2차도 실행될 예정 명시> |
| 4 | step 9 민감 파일 자동 제외 | PASS/FAIL | <근거> |
| 5 | step 9 푸쉬 금지 | PASS/FAIL | <근거> |
| 6 | §2.5 객체 분리 + UI ↔ 기능 분리 + 자동 리팩토링 | PASS/FAIL | <근거> |
| 7 | `01-detect/external-dependencies.md` 산출 | PASS/FAIL | <근거> |

---

## waiver 검토

본 회차의 `<step>/waiver.md` 파일 존재 여부 + 각 waiver 의 [run-modes.md §2 인정 게이트](../docs/run-modes.md#2-waiver-체계) 통과 여부.

| step | waiver 존재 | 생략 항목 | 인정 게이트 | 결과 |
|---|---|---|---|---|
| 2 | yes/no | <항목> | <게이트> | 인정 / 거부 |
| 3 | yes/no | <항목> | <게이트> | 인정 / 거부 |
| 4 | yes/no | <항목> | <게이트> | 인정 / 거부 |
| 6 | yes/no | <항목> | <게이트> | 인정 / 거부 |

---

## Findings (severity 역순)

| ID | Severity | Area | Evidence (file:line) | Required Fix | 자동 수정 후보 |
|---|---|---|---|---|---|
| #001 | CRITICAL/HIGH/MEDIUM/LOW | <영역> | <파일:줄> | <fix> | yes/no/blocked-by-whitelist |

### Severity 등급 기준
- **CRITICAL** = 보안·데이터 손실·재현 가능 결함
- **HIGH** = 명확한 버그·일관성 위반
- **MEDIUM** = 유지보수성·성능 우려
- **LOW** = 스타일·미세 개선

---

## 1차 단계 종료 보고

- 다음 단계: 2차 외부 codex audit (`07-audit/2nd-external-audit.md`) 자동 실행
- 2차 단계가 fallback 으로 진행될 가능성 (codex 인증 만료 / quota 소진 → code-review skill fallback)
- 종합 단계 (`07-audit/findings.md`) 에서 1차+2차 합의/이견 정리 + 최종 verdict 확정
