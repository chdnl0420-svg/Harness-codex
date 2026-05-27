# step 5 - 코드 리뷰

기존 `codex-reviewer` 를 재사용해 코드 리뷰를 수행한다. 호출자 Codex 의 자기 리뷰로 대체하지 않는다.

## 재사용 계약 (호출 방식)

- **에이전트 위치**: `~/.codex/skills/harness-run/agents/codex-reviewer.md` (자매 skill `harness` 가 등록한 공식 subagent — v2.1 부터 Codex 최상위 single source of truth)
- **호출 방식**: 메인 Codex 가 codex exec 재귀 호출로 `codex-reviewer` agent prompt 실행. 또는 `codex exec` CLI 직접 실행 (자매 skill `harness-review` 의 4단계 절차 동일).
- **입력 계약**: 변경 파일 목록 (`.harness/05-review/file-list.md` 작성 후 전달)
- **본 skill 의 learning prepend 비대상**: codex-reviewer 는 자체 운영 (본 skill 의 `learning/` 에 파일 두지 않음).
- **실패 처리** (예외 ⑤ `SUBAGENT_RUNTIME_BLOCKED`):
  - Codex 인증 실패 (exit 2): 사용자 로그인 안내 후 대기 + 재시도
  - Codex quota 소진 (exit 3): 사유 안내 후 대기 + 재시도
  - 자매 skill `harness-review` 의 fallback 정책 따름: `code-review` skill 로 fallback 가능 (산출물에 `fallback_used: true` 명시)
- **fake 응답 절대 금지**: codex 호출 실패 시 임의로 `LGTM: YES` 작성 금지.

## 입력

- step 3 이후 변경된 사용자 프로젝트 코드
- `.harness/02-domain/` 도메인 산출물
- `.harness/03-aggregate-*/tdd/` TDD 기록
- `.harness/04-qa/qa.md`

## 리뷰 관점

- 요구사항 누락
- DDD 일관성
- CQRS / Event Sourcing 구조 결함
- 테스트가 실제 실패 후 통과했는지
- Mock 금지 위반
- production endpoint 호출 위험
- 구조 분리 규칙 위반

## 산출물

`.harness/05-review/review.md`

필수 판정:

- `LGTM: YES`
- `LGTM: NO`
- `LGTM: BLOCKED`

명시적 `LGTM: YES` 가 없으면 NO 로 취급한다.

## 회송

- `LGTM: YES`: step 6 진행
- `LGTM: NO`: **분기 결정 — 회송 vs waiver** (아래 §회송-vs-waiver 절차 따름)
- `LGTM: BLOCKED`: 로그에 사유 기록 후 사용자에게 보고

동일 결함 5회 반복 시 멈추고 사용자에게 보고한다.

## 회송-vs-waiver (LGTM:NO 시 의무 분기)

LGTM:NO 라고 무조건 회송하지 않는다. **3 케이스 중 하나** 로 분류 후 처리 (`05-review/result.md` 에 표로 기록).

### 케이스 A — pre-existing 분류

- 조건: codex 가 결함 보고 + 본 회차 변경 전 코드에 동일 결함 존재 (`git show HEAD:<file>` 검증)
- 처리: **waiver path** (아래 §waiver path 4 조건 충족 시)

### 케이스 B — 0 findings + LGTM 형식 부재

- 조건: codex 본문이 "no findings"/"결함 없음" 명시 + 마지막 줄에 `LGTM: YES` 정확 문자열 부재 (예: codex 가 평문으로 "버그성 finding 없음" 만 작성하고 LGTM 키워드 안 씀)
- 처리: **waiver path** (아래 §waiver path 4 조건 충족 시) + `result.md` 에 codex 본문 verbatim 인용 의무

### 케이스 C — 본 회차가 만든 신규 결함

- 조건: codex 결함이 본 회차 변경에서 *신규 발생* (pre-existing 아님)
- 처리: **회송 강제** — 결함 본문을 step 3 입력으로 붙이고 회송. waiver path 적용 불가.

### 결정 트리

```
LGTM:NO 발생 →
  ├─ codex 본문 평가가 "결함 0건/no findings" 명시? Y/N
  │
  ├─ Y → 케이스 B: waiver path (result.md 에 codex 본문 verbatim 인용)
  │
  └─ N → codex 가 보고한 결함 1건마다:
      ├─ pre-existing 여부 검증 (필수, audit trail 의무)
      │   - 명령: git show HEAD:<파일경로> | grep -n <패턴>
      │   - **검증 명령 verbatim 을 invocation.md 또는 result.md 에 기록 의무**
      │
      ├─ Y (pre-existing) → 케이스 A:
      │   ├─ run-mode = refactor + 결함 수정이 scope 밖? Y/N
      │   ├─ Y (scope 밖): **waiver path** (waiver.md 작성)
      │   └─ N (수정 가능): **회송 강제**
      │
      └─ N (본 회차 신규) → 케이스 C: **회송 강제**
```

### waiver path 의무 조건 4개 (케이스 A·B 공통, 한 개라도 미충족 시 회송 강제)

1. `05-review/waiver.md` 별도 파일 작성 — 필드: 케이스 (A/B), 결함 ID 또는 "0 findings" 명시, 정당화 사유, ADR 등재 약속
2. 케이스 A: pre-existing 검증 명령 verbatim 기록 (`git show HEAD:<file>` 등) — invocation.md 또는 result.md
   케이스 B: codex 본문 결론 verbatim 인용 — result.md (raw 인코딩 깨지면 정상화 명시)
3. run-mode ∈ {refactor, feature-add 의 도메인 외 영역}. new-domain 에서는 waiver path 금지 (모든 LGTM:NO 회송 강제)
4. 다음 회차 ADR 자동 등재 (summary.md `§다음 회차 권장 ADR`)

### Audit 영향

- 회송 결정 + 회송 실행 → step 3 재진입 1회 카운트
- waiver 결정 (A/B) + 4 조건 충족 → step 7 audit 가 `PASS_WITH_WAIVERS` 부여 가능
- waiver 결정 + 조건 미충족 → audit 가 catch → `PARTIAL` 강제

### 5회 동일 결함 누적 카운터

회송 결정만 카운트. waiver 결정 (A/B) 은 카운트 안 함 (대신 ADR 누적 추적).

## Codex 호출 정책 — Windows native only (WSL wrapper 폐기)

본 skill 의 step 5 는 **Windows native `codex` CLI 만** 사용. WSL wrapper (`AgentHub/.harness/wrappers/codex-review.sh`) 는 2026-05-25 폐기 (cycle 3 `20260525T125104Z-refactor` 에서 7m45s 무한대기 사례). 자매 skill `harness-review` 도 동일 정책 적용 권고.

### 표준 호출

```bash
cd <project-root> && timeout 600 codex exec review --uncommitted
```

- `timeout 600` 으로 hard cap (10분) — 필수
- `--uncommitted` 는 staged + unstaged + untracked 전체 review
- 특정 commit/branch 비교: `codex exec review --against <ref>`
- exit 0 확인 + stdout verbatim 보존 (`raw-result.md`, non-waivable #2)
- 검증된 호출: cycle 2 (PASS_WITH_WAIVERS) + cycle 3 orchestration unblock (raw 105.4KB 정상)
- ⚠️ PowerShell 내부 호출 시 `[Console]::OutputEncoding` constraint warning 다발 가능 — 무시해도 됨 (codex 본문 분석 영향 없음)

### codex-reviewer agent 호출 vs 직접 호출

`docs/steps/05-review.md` 의 표준 경로는 `agent=codex-reviewer`. 단 agent 정의 (`~/.codex/skills/harness-run/agents/codex-reviewer.md` v2026-05-25 부터) 가 wrapper 폐기 + native codex 강제 — agent 호출이나 직접 호출이나 동일 effect.

직접 호출 (agent 우회) 이 필요한 경우:
- `agent=codex-reviewer` 가 어떤 사유로 BLOCKED 반환 (예외 ⑤)
- 외부 session 에서 막힌 회차 step 5 unblock
- 두 경우 모두 위 `codex exec review --uncommitted` 명령 직접 사용 + `05-review/result.md §호출 환경` 섹션에 호출 사유 명시

### Exit code 처리

| exit | 의미 | 본 skill 처리 |
|---|---|---|
| 0 | 성공 | raw-result.md 작성 + 본문 분석 (LGTM:NO 형식 분기) |
| 2 | 미로그인 | 사용자에게 `codex login` 안내 + 대기 (예외 ⑤ `SUBAGENT_RUNTIME_BLOCKED`) |
| 3 | quota 소진 | fallback 으로 `code-review` skill 사용 + `fallback_used: true` 명시 |
| 124 | timeout 600s 초과 | 1차 자동 재시도 1회 (네트워크 일시 장애 가능성) / 2차 실패 시 예외 ⑤ |
| Other | 알 수 없는 실패 | stdout/stderr 보고 + 예외 ⑤ |

### 외부 unblock (orchestration session 패턴)

dry-run 회차 main Codex 가 step 5 에서 막혔을 때 (예: 빈약한 토큰, 컨텍스트 손실) 사용자가 별도 session 으로 unblock 가능:

1. 외부 session 이 `cd <run-target> && timeout 600 codex exec review --uncommitted` 직접 호출
2. raw 결과를 회차의 `05-review/raw-result.md` 에 저장 (non-waivable #2 충족)
3. `result.md` 의 `호출 환경` 섹션에 1차 (막힘) + 2차 (외부) 호출 명령 verbatim 기록
4. `waiver.md` 의 `작성자` 필드에 외부 unblock 표시 (cycle 3 사례 참조)
5. log.md 에 STEP 5 BLOCKED → UNBLOCK → END 라인 추가

### cycle 간 codex 결과 재사용 (deprecated 후 재시작 패턴)

cycle N 이 step 5 이후 단계에서 중단되고 cycle N+1 로 재시작될 때, cycle N 의 codex 결과 재사용 허용 — 단 다음 3 조건 *모두* 충족 시:

1. **동일 코드 변경 + 동일 commit base**: `git diff` 결과가 cycle N 과 cycle N+1 에서 동일
2. **raw 결과 verbatim 보존**: cycle N 의 `raw-result.md` 가 cycle N+1 폴더에도 존재 (sed 치환은 회차 ID 만)
3. **호출 환경 기록 의무**: cycle N+1 의 `result.md` §호출 환경 섹션에 (a) cycle N 의 호출 명령 verbatim, (b) cycle N exit code 및 session id, (c) cycle N+1 재사용 사유 모두 기록

3 조건 미충족 시 cycle N+1 에서 native codex 새로 호출 의무.

본 정책의 취지: non-waivable #2 (codex 실호출 + raw 보존) 의 self-review bias 차단 목표는 cycle N 에서 이미 충족됨. cycle N+1 의 재호출은 *동일 결과* 가 보장된 경우 토큰/시간 낭비.

검증된 선례: cycle 4 (`20260525T140541Z-refactor`) 가 cycle 3 (`_deprecated-20260525T125104Z-refactor`) 의 codex review 결과 재사용 + 3 조건 모두 충족 → step 7 audit 가 `CONDITIONAL PASS` 처리 + F-02 grey zone 등재. 본 §명문화 후 grey zone 해소.



## Codex 포팅 추가 — step 5 재귀 review 호출

step 5 는 호출자 Codex 의 자기 리뷰로 대체하지 않는다. 다음 패턴으로 자식 Codex 를 호출하고 stdout 을 즉시 보존한다.

```bash
mkdir -p .harness/runs/${RUN_ID}/05-review
printf '%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ) step5 codex-reviewer start" > .harness/runs/${RUN_ID}/05-review/invocation.md
codex exec --skip-git-repo-check \
  --model gpt-5 \
  --sandbox read-only \
  --ask-for-approval never \
  --timeout 900 \
  "$(cat ~/.codex/skills/harness-run/agents/codex-reviewer.md)

## 회차 컨텍스트
repo=$(pwd)
run-id=${RUN_ID}
요청: uncommitted diff 를 Harness 정책 기준으로 리뷰하고 마지막 줄에 LGTM: YES/NO/BLOCKED 를 명시한다." \
  2>&1 | tee .harness/runs/${RUN_ID}/05-review/raw-result.md
EXIT_CODE=${PIPESTATUS[0]}
printf 'exit_code: %s\n' "$EXIT_CODE" >> .harness/runs/${RUN_ID}/05-review/invocation.md
```

`raw-result.md` 부재는 non-waivable invariant 위반이다.
