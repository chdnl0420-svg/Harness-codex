# Run Modes — 회차 유형 + waiver + 판정 4단계 + non-waivable invariant

> v2 audit 강화. step 1 에서 회차 유형을 자동 감지하고 (`01-detect/run-mode.md`), step 7 audit 가 본 문서의 정책으로 판정한다. v5 본문(SKILL.md, workflow.md, code-structure.md) 은 그대로 두고 본 문서가 회차 유형·waiver·판정만 더한다.

---

## 1. 회차 유형 (`run-mode`)

step 1 에서 [docs/steps/01-detect.md §3-bis](steps/01-detect.md#3-bis-회차-유형-run-mode-자동-감지-v2) 의 휴리스틱으로 자동 판정.

| 유형 | 언제 | DDD 강제 | TDD 강제 | 커버리지 강제 | 1차 audit | 2차 audit |
|---|---|---|---|---|---|---|
| `new-domain` | 신규 도메인 구축 (`.harness/` 비었거나 사용자 입력에 `신규`/`new`/`구축`/`from scratch`) | 풀세트 (모든 Aggregate 에 CQRS+ES) | 풀세트 (Red→Green→Refactor 사이클) | 80%+ | 항상 | 항상 |
| `feature-add` | 기존 도메인에 기능 추가 (`02-domain/domain-model.md` 다른 회차에 존재 + 사용자 입력에 `feature`/`기능 추가`) | 해당 Aggregate 만 풀세트 (기존 Aggregate 는 그대로) | 풀세트 | 80%+ (변경 영역) | 항상 | 항상 |
| `refactor` | 동작 보존 + 구조 변경 (사용자 입력에 `refactor`/`리팩토링`/`cleanup`/`재구조화`) | adapt 허용 + `02-domain/waiver.md` 필수 | characterization 허용 (`03-characterization/`) + waiver | waiver 허용 (`04-qa/coverage-waiver.md`) | 항상 | 항상 (자동 adapt 위험 가장 큼) |

> §2.5 코드 구조 정책 (객체 단위 분리 + UI ↔ 기능 분리 + 자동 리팩토링) 은 어떤 유형에서도 항상 강제 (non-waivable #6).
> `hotfix` 같은 짧은 회차는 v2 범위 밖. 필요 시 `refactor` 로 잡고 waiver.md 에 사유 명시.

---

## 2. waiver 체계

`run-mode` 가 `refactor` 또는 `feature-add` 라 강제 항목을 생략할 때 **반드시** `<step>/waiver.md` 생성. waiver 없이 생략하면 step 7 audit 자동 `FAIL`.

### waiver.md 의무 필드 (5개)

[templates/waiver.md.tpl](../templates/waiver.md.tpl) 참조. 양식 요약:

| 필드 | 내용 |
|---|---|
| 생략 항목 | 어떤 강제 항목을 빼는가 (예: "step 3 TDD Red→Green→Refactor 사이클") |
| 사유 | 왜 빼야 하는가 (예: "Vitest/Jest 미설정, 기존 코드 보존 회차") |
| 대체 검증 | 무엇으로 보증하는가 (예: "characterization test 로 행위 보존 확인") |
| audit 허용 조건 | audit 이 이 waiver 를 인정하는 기준 (예: "characterization baseline + after 둘 다 PASS") |
| 후속 권장 | 다음 회차에서 메우려면 (예: "Vitest 도입 + TDD 회차 1회 추가") |

### waiver 인정 게이트

1차+2차 audit 가 waiver.md 를 읽고 다음 모두 충족 시 `PASS_WITH_WAIVERS` 로 처리:

- 생략 항목이 본 회차의 `run-mode` 에서 허용되는가
- 대체 검증 산출물이 실제 존재하는가 (예: characterization baseline.md 파일 존재 + 내용)
- audit 허용 조건이 측정 가능한가 (binary 또는 카운트)
- non-waivable invariant 7개 와 충돌하지 않는가 (충돌 시 즉시 `FAIL`)

---

## 3. audit 판정 4단계

step 7 종합 단계 (`07-audit/findings.md`) 가 다음 4 판정 중 하나를 명시.

| 판정 | 의미 | 다음 동작 |
|---|---|---|
| `PASS` | 모든 강제 항목 통과, waiver 없음 | step 8 진행 |
| `PASS_WITH_WAIVERS` | 모든 강제 또는 명시 waiver, non-waivable 위반 없음 | step 8 진행 + summary 에 waiver 목록 |
| `PARTIAL` | 일부 강제 미통과, 결과는 의미 있음 (예: 핵심 Aggregate 만 TDD, 부수 Aggregate 누락 + waiver 없음) | summary 작성 (PARTIAL 명시) + 사용자 확인 후 step 9. 예외 ④ `AUDIT_LIMIT_EXCEEDED` 와 별개 — PARTIAL 은 한도 초과가 아니라 판정 |
| `FAIL` | non-waivable invariant 위반 또는 자가 수정 한도 초과 후에도 회복 불가 | step 8 안 함, 자가 수정 → 한도 도달 시 사용자 보고 (예외 ④) |

### 판정 결정 트리

```
1. non-waivable invariant 7개 중 하나라도 위반?
   YES → FAIL (자가 수정 → 한도 도달 시 예외 ④)

2. 모든 강제 항목 통과 (waiver 없음)?
   YES → PASS

3. 일부 강제 항목 생략 + 모두 명시 waiver + waiver 인정 게이트 통과?
   YES → PASS_WITH_WAIVERS

4. 일부 강제 항목 생략 + waiver 없음 또는 인정 게이트 미통과?
   YES → PARTIAL (사용자 확인 후 step 9)
```

---

## non-waivable invariant 7개

회차 유형 무관 절대 생략 금지. 위반 시 자동 `FAIL` (waiver 인정 안 함).

| # | 게이트 | 이유 | 위치 |
|---|---|---|---|
| 1 | step 1 외부 의존성 감지 + production credential BLOCKED | 보안·비용 직결 (실 결제·실 발송 차단) | [01-detect.md §4](steps/01-detect.md#4-외부-의존성-자동-점검-critical--v4-강제) |
| 2 | step 5 codex-reviewer 실 호출 + raw 결과 보존 | self-review bias 차단 본질 | [05-review.md](steps/05-review.md) — `invocation.md` + `raw-result.md` |
| 3 | step 7 1차 + 2차 audit 둘 다 실행 + `findings.md` 산출 | audit 빠지면 보증 0 | [07-audit.md](steps/07-audit.md) |
| 4 | step 9 민감 파일 자동 제외 | 보안 직결 | [09-commit.md §민감-파일-제외](steps/09-commit.md#민감-파일-제외-확장된-차단-목록) |
| 5 | step 9 푸쉬 금지 | 사용자 정책 | [09-commit.md](steps/09-commit.md) |
| 6 | §2.5 객체 분리 + UI ↔ 기능 분리 + 자동 리팩토링 | 사용자 명시 코드 품질 표준 | [code-structure.md](code-structure.md) |
| 7 | `01-detect/external-dependencies.md` 산출 | "변경 없음" vs "의존성 없음" 구분 — 회차 추적성 보증 | [01-detect.md §4-7](steps/01-detect.md#4-7-external-dependenciesmd-산출-v2-의무--non-waivable-invariant) |

---

## 5. 회차 유형별 강제 항목 (step 별)

| step | new-domain | feature-add | refactor |
|---|---|---|---|
| 1 | run-mode.md + external-dependencies.md (의무) | 동일 | 동일 |
| 2 | DDD 풀세트 4종 산출물 (model + event-storming + mermaid + code-skeleton) | 해당 Aggregate 4종 + 기존 Aggregate 영향 분석 | adapt 허용 + `02-domain/waiver.md` (CQRS/ES 미적용 사유 명시) |
| 3 | Red→Green→Refactor 사이클 (Aggregate 당 시나리오 수) | 신규 Aggregate 풀 사이클 + 기존 Aggregate 회귀 테스트 | characterization 허용 (`baseline.md` + `scenarios/*.md` + `after.md`) + `tdd/waiver.md` |
| 4 | 80%+ 커버리지 | 80%+ (변경 영역) | waiver 허용 (`04-qa/coverage-waiver.md` + `learning.md`) |
| 5 | codex 실 호출 + invocation.md + raw-result.md | 동일 | 동일 |
| 6 | production 설치본 사용자 테스트 또는 명시 `waiver.md` | 동일 | dev build 우회 시 `06-customer/waiver.md` (사용자 체감 변화 없음 사유) |
| 7 | 1차+2차 audit + findings.md + self-correction.md + skill-improvement.md (0회라도 항상) | 동일 | 동일 |
| 8 | summary.md + summary.html + html-validation.md | 동일 | 동일 |
| 9 | status.md 에 primary/metadata/final_head 구분 | 동일 | 동일 |

---

## 6. 충돌 해소 우선순위

| # | 정책 | 우선순위 |
|---|---|---|
| 1 | non-waivable invariant 7개 | 최상위 — 어떤 waiver 도 못 뺌 |
| 2 | `SKILL.md` 의 보안 / 푸쉬 금지 / Mock 금지 | non-waivable 와 동등 |
| 3 | 회차 유형별 강제 항목 (§5) | 본 문서 |
| 4 | 회차 유형별 waiver 허용 (§2) | 본 문서 |
| 5 | step 별 산출물 (§5 표) | 본 문서 |

audit 가 충돌을 발견하면 위 우선순위로 판정.
