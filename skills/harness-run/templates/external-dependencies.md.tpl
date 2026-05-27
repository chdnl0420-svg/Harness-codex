# External Dependencies — 본 회차 외부 의존성 점검 결과

> v2 audit 강화 non-waivable invariant #7. step 1 종료 직전 의무 산출.
> 외부 의존성 0건이어도 본 파일 작성 (빈 표 명시) — "변경 없음" 과 "의존성 없음" 구분이 audit 추적성의 핵심.
> 본 파일이 없으면 step 7 audit 자동 `FAIL`.

---

## 1. 회차 컨텍스트

- 회차 ID: `<UTC-timestamp>-<slug>`
- run-mode: <new-domain / feature-add / refactor>
- 점검 UTC: <YYYY-MM-DD HH:MM:SS UTC>
- 점검 범위: <프로젝트 루트 절대 경로>

## 2. 점검 결과 표

| # | category | found | changed_in_this_run | sandbox_available | blocked | redacted_value | evidence |
|---|---|---|---|---|---|---|---|
| 1 | <외부 API / 결제 / 이메일 / DB / 스토리지 / 큐 / 인증 / LLM> | yes/no | yes/no/n-a | yes/no/n-a | yes/no | <SHA256(value)[:8]> 또는 `-` | <파일:줄 또는 `-`> |

**컬럼 의미**:
- `found`: 본 회차에서 패턴 매치 발견 여부 (yes/no 의무 — 0건이어도 표 비우지 말고 한 줄로 "n-a, no, ..." 라도 명시)
- `changed_in_this_run`: 본 회차의 코드 변경이 이 의존성을 신규 추가/변경했는가 (yes/no/n-a)
- `sandbox_available`: in-memory 가능 또는 sandbox/test endpoint 존재 (yes/no/n-a)
- `blocked`: production credential·URL 감지로 BLOCKED 됐는가 (yes/no)
- `redacted_value`: BLOCKED 항목의 raw value SHA256[:8] hash (raw 절대 금지)
- `evidence`: 발견된 파일:줄 (BLOCKED 항목은 의무, 그 외 optional)

## 3. BLOCKED 항목 처리 (`blocked = yes`)

본 표에서 `blocked = yes` 인 항목은 [docs/steps/01-detect.md §4-3](../docs/steps/01-detect.md#4-3-blocked-시-동작-redaction-강제) 의 절차를 따른다:

1. `01-detect/blocked-dependencies.md` 에 redaction 으로 별도 기록 (raw value 절대 금지)
2. `09-commit/files-excluded.md` 에 자동 등록 (커밋 시 제외)
3. 채팅 BLOCKED 보고 + CLI 표준 입력 대기 예외 ① `EXT_DEP_PROD_BLOCKED`

## 4. 검색 명령 (verbatim 기록 — audit 추적성)

본 회차에서 실제 실행한 검색 명령을 verbatim 기록. **재현 가능성** 이 audit 추적의 핵심.

| # | 명령 | 도구 (rg/Glob/Bash) | 매치 수 |
|---|---|---|---|
| 1 | `<예: sk_live_[A-Za-z0-9]{24,}>` | rg | <N건> |
| 2 | `<예: STRIPE_SECRET_KEY>` | rg | <N건> |

검색 패턴 풀세트는 [docs/steps/01-detect.md §4-1, §4-2](../docs/steps/01-detect.md#4-1-탐색-대상) 참조.

## 5. 채택 결정 (자동)

본 표를 바탕으로 step 3 이후 채택할 의존성 모드:

| category | 채택 모드 | 사유 |
|---|---|---|
| <category> | in-memory Fake / sandbox / test endpoint / BLOCKED | <자동 결정 사유> |

채택 우선순위 (SKILL.md §1):
1. in-memory 가능 → in-memory Fake
2. in-memory 불가 + sandbox/test endpoint 존재 → sandbox/test
3. 둘 다 불가 → BLOCKED + 사용자 결정

---

## 6. 0건 케이스 (의존성 없음)

본 회차에서 외부 의존성 패턴이 하나도 발견되지 않으면 §2 표를 다음 한 줄로 명시:

```
| 1 | - | no | n-a | n-a | no | - | (외부 의존성 패턴 0건) |
```

§4 검색 명령은 그대로 verbatim 기록 (audit 가 *"정말 검색했는가"* 를 확인).
