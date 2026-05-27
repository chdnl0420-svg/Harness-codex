# Audit Findings — 1차+2차 종합 + 최종 Verdict

> v2 audit 강화. `07-audit/findings.md` 로 저장. **1차 self-audit (`1st-self-audit.md`) 과 2차 external audit (`2nd-external-audit.md` raw) 가 모두 존재해야 본 파일 작성 가능.**

---

## 최종 Verdict (4단계)

`PASS` / `PASS_WITH_WAIVERS` / `PARTIAL` / `FAIL`

> 판정 결정 트리는 [docs/run-modes.md §3](../docs/run-modes.md#3-audit-판정-4단계) 참조.
> non-waivable invariant 1개라도 위반 = 즉시 FAIL.

---

## 회차 컨텍스트

- 회차 ID: `<UTC-timestamp>-<slug>`
- run-mode: <new-domain / feature-add / refactor>
- 종합 UTC: <YYYY-MM-DD HH:MM:SS UTC>
- 1차 audit 결과: `07-audit/1st-self-audit.md` (Verdict: <P/PWW/PA/F>)
- 2차 audit 결과: `07-audit/2nd-external-audit.md` (codex stdout raw, fallback_used: <true/false>)
- 자가 수정 카운터: 산출물 <N>/2 · 스킬 <N>/2 · 한도 도달: <YES/NO>

---

## 1차 + 2차 합의/이견 표

| step | 1차 verdict | 1차 priority | 2차 verdict | 2차 priority | 합의 / 이견 | 최종 처리 |
|---|---|---|---|---|---|---|
| 1 detect | PASS/일탈/위반 | L/M/H | PASS/일탈/위반 | L/M/H | 합의 / 이견 | 자동 수정 / waiver / FAIL |
| 2 domain | | | | | | |
| 3 TDD | | | | | | |
| 4 QA | | | | | | |
| 5 review | | | | | | |
| 6 customer | | | | | | |
| 7 audit | | | | | | |
| 8 summary | | | | | | |
| 9 commit | | | | | | |

### 이견 처리 규칙

- **이견이 critical 이면 종합 단계가 멈추고 사용자 보고** (Verdict 미확정 → 채팅 1줄 보고 후 사용자 결정 대기 — 예외 ④ 와 별개).
- **이견이 medium 이하면 자동 결정**: 2차 (외부) 의견 우선 — self-review bias 차단이 본 skill 의 핵심 가치.
- **합의 항목** 은 그대로 처리 (자동 수정 후보).

---

## non-waivable invariant 7개 종합 점검

[docs/run-modes.md §non-waivable invariant 7개](../docs/run-modes.md#non-waivable-invariant-7개) 와 정합.

| # | invariant | 1차 | 2차 | 종합 결과 |
|---|---|---|---|---|
| 1 | step 1 외부 의존성 감지 + production credential BLOCKED | PASS/FAIL | PASS/FAIL | PASS / **FAIL** |
| 2 | step 5 codex-reviewer 실 호출 + raw 결과 보존 | | | |
| 3 | step 7 1차+2차 audit 둘 다 실행 + `findings.md` 산출 | | | |
| 4 | step 9 민감 파일 자동 제외 | | | |
| 5 | step 9 푸쉬 금지 | | | |
| 6 | §2.5 객체 분리 + UI ↔ 기능 분리 + 자동 리팩토링 | | | |
| 7 | `01-detect/external-dependencies.md` 산출 | | | |

**FAIL** 이 하나라도 있으면 최종 Verdict 즉시 `FAIL`. 자가 수정 시도 → 한도 도달 시 예외 ④ `AUDIT_LIMIT_EXCEEDED`.

---

## waiver 종합 검토

본 회차의 모든 `<step>/waiver.md` 와 [run-modes.md §2 인정 게이트](../docs/run-modes.md#2-waiver-체계) 통과 여부.

| step | waiver 존재 | 생략 항목 | 1차 판정 | 2차 판정 | 종합 결과 |
|---|---|---|---|---|---|
| 2 | yes/no | <항목> | 인정/거부 | 인정/거부 | 인정 → PWW / 거부 → PARTIAL or FAIL |
| 3 | | | | | |
| 4 | | | | | |
| 6 | | | | | |

---

## Findings (severity 역순 — 1차+2차 통합)

| ID | 출처 | Severity | Area | Evidence (file:line) | Required Fix | 자동 수정 결과 |
|---|---|---|---|---|---|---|
| #001 | 1차/2차/둘 다 | CRITICAL/HIGH/MEDIUM/LOW | <영역> | <파일:줄> | <fix> | APPLIED / ROLLED_BACK / BLOCKED |

### Severity 등급 기준 (산업 표준 + v5)
- **CRITICAL** = OWASP critical (보안·데이터 손실·재현 가능 결함). 자동 수정 시도 + 통과 못하면 사용자 결정
- **HIGH** = 명확한 버그·일관성 위반. 자동 수정 시도
- **MEDIUM** = 유지보수성·성능 우려. 보고만 (자동 수정 보류)
- **LOW** = 스타일·미세 개선. 기록만

---

## 하위 단계 BLOCKED 추적 (QA/Review/Customer 결과 정리)

| 단계 | Verdict | BLOCKED_REASON | BLOCKED_SUBCATEGORY |
|---|---|---|---|
| step 4 QA | PASS/FAIL/BLOCKED | <enum> | <e.g., coverage_tool_missing> |
| step 5 Review | LGTM:YES/NO/BLOCKED | <enum> | |
| step 6 Customer | PASS/FAIL/BLOCKED | <enum> | <e.g., prod_endpoint_detected> |

---

## Corrections Applied (자가 수정 결과)

| Finding ID | Files changed | Backup path | Diff path | Verification result |
|---|---|---|---|---|
| #001 | <파일> | `~/.codex/skills/.backups/...` (스킬 수정 시) | `07-audit/skill-diff-NN.patch` | PASS / FAIL → ROLLED_BACK |

---

## Audit Checklist (8 항목 — 1차+2차 통합)

각 항목 종합 결과 마킹.

- [ ] 1. Requirements matched (자연어 목표 vs 산출물 대조)
- [ ] 2. DDD coherent (Bounded Context, Aggregate, Invariant, Command, Event, Query, Projection)
- [ ] 3. TDD evidence complete (Red FAIL 로그 + Green PASS 로그 + Refactor 노트 모두)
- [ ] 4. Numbers consistent (커버리지 %, 사이클 수, 한도 카운터 모든 파일에서 일치)
- [ ] 5. External review summarized (Codex 리뷰 + customer test 결과 hidden 없이 반영)
- [ ] 6. Workflow complete (step 1~9 누락 없이 모두 종료)
- [ ] 7. Skill improvement considered (반복 finding 이 skill 파일 자기 개선 트리거 일으켰는지)
- [ ] 8. Code structure checked (객체 단위 분리 + UI↔기능 분리 위반 자동 리팩토링 시도 여부)

---

## Remaining Risks

- <risk>

---

## 한도 초과 시 보고 (예외 ④ AUDIT_LIMIT_EXCEEDED)

- 산출물 2회 + 스킬 2회 모두 시도 후에도 AUDIT_FAIL 인 finding 만 사용자에게 보고
- 옵션: A 재시도 1회 추가 / B 결함 무시 통과 / C 중단

---

## Verdict 확정 절차

1. non-waivable invariant 점검 표에서 FAIL 1개 이상 → 최종 `FAIL` (자가 수정 후 한도 도달 시 예외 ④)
2. 모든 강제 통과 + waiver 0건 → 최종 `PASS`
3. 모든 강제 또는 명시 waiver + 모든 waiver 인정 게이트 통과 → 최종 `PASS_WITH_WAIVERS`
4. 일부 강제 생략 + waiver 없음/거부 + non-waivable 위반 없음 → 최종 `PARTIAL` (사용자 확인 후 step 9)

---

## 자가 수정 카운터 (v5 그대로)

- 산출물 자가 수정 시도: <N>/2
- 스킬 자가 수정 시도: <N>/2
- 한도 도달 여부: YES → 예외 ④ `AUDIT_LIMIT_EXCEEDED` 사용자 결정 / NO
