# Step 5: 리뷰

## 목표

구현 결과의 결함, 회귀 위험, 테스트 공백을 찾는다.

## 절차

1. `git diff --stat`와 대상 diff를 확인한다.
2. 변경 의도와 Step 3 계획을 대조한다.
3. 버그, 보안/개인정보, 데이터 손상, 성능, 테스트 공백을 우선 검토한다.
4. 결과를 `.harness/reviews/review-<slug>.md`에 누적한다.
5. 명시적 `LGTM: YES | NO | UNKNOWN` 라벨을 쓴다.
6. Step 6 진입 전 `validate-runtime-gate.ps1 -NextStep Step6`를 실행한다.
7. `FAIL`이면 Step 3 또는 Step 4로 되돌린다.

## 입력 게이트

- Step 4의 구현 diff 또는 명시 변경 파일 목록이 있어야 한다.
- `.harness/implementation-<slug>.html`을 먼저 읽어야 한다.
- 리뷰 파일 없이 Step 6으로 이동하지 않는다.

## 리뷰 체크리스트

- 사용자 요청 밖 변경이 섞였는가?
- 기존 public API, 저장 형식, 파일 경로, 환경 변수 계약이 깨졌는가?
- 실패 경로, 빈 입력, 권한 없음, 네트워크 없음 같은 경계 조건이 안전한가?
- 테스트가 변경된 동작을 직접 검증하는가?
- UI 변경이면 모바일/데스크톱에서 텍스트 겹침, 버튼 overflow, 접근성 문제가 없는가?

## 리뷰 도구 선택 순서

1. 가능한 경우 현재 구현 세션과 분리된 독립 리뷰를 먼저 사용한다. 예: 별도 `codex exec`, 사용자가 승인한 외부 리뷰, 병렬 리뷰 도구.
2. 프로젝트의 lint, typecheck, unit test, static analyzer가 있으면 리뷰 증거로 함께 실행한다.
3. 독립 리뷰 도구가 없으면 현재 Codex 세션에서 diff와 파일을 직접 읽어 self-review를 수행하되 `external_review: unavailable`을 기록하고 `LGTM: YES`를 쓰지 않는다. 이 경우 `LGTM: UNKNOWN`으로 둔다.
4. 사용자가 현재 세션 리뷰 결과를 승인해 Step 6 진입을 허용한 경우에만 `external_review: user-approved`와 함께 `LGTM: YES`를 쓸 수 있다.
5. 리뷰 대상 파일을 확정할 수 없으면 `UNKNOWN`으로 두고 파일 목록부터 다시 만든다.

## 딥 리서치 위임 조건

다음 신호 중 하나라도 있으면 Step 5 결론 전에 `harness-deep-researcher` 절차를 사용한다.

- 최신 라이브러리/프레임워크 동작이나 보안 권고가 판정에 필요하다.
- 마이그레이션, 브라우저 호환성, 플랫폼 정책처럼 현재 지식으로 틀릴 위험이 높다.
- 외부 API/표준/릴리스 노트의 정확한 계약을 확인해야 한다.
- 리뷰 finding이 추측에 의존하고 있고 1차 출처로 검증할 수 있다.

딥 리서치 결과 없이 추측성 finding을 `LGTM: YES` 근거로 쓰지 않는다.

## 보안 게이트

다음 영역이 diff에 포함되면 보안 관점을 별도로 검토한다.

- 인증/권한/세션
- 입력 검증/파싱
- 파일 시스템/경로 처리
- 네트워크 요청/외부 URL
- secret, token, key, credential
- 개인정보 또는 결제 데이터

CRITICAL 보안 이슈가 1건이라도 있으면 `LGTM: NO`다.

## LGTM 추출 규칙

- 승인 라벨은 정확히 `LGTM: YES`여야 한다.
- `문제 없어 보임`, `대체로 OK`, `큰 문제 없음` 같은 문장은 승인으로 해석하지 않는다.
- `CRITICAL` 또는 `HIGH` finding이 있으면 `LGTM: NO`다.
- 현재 Codex 세션의 self-review만 수행했고 독립 리뷰가 없으면 `LGTM: UNKNOWN`이다.
- `LGTM: YES`는 `external_review: independent-codex` 또는 `external_review: user-approved`와 함께만 쓸 수 있다.
- `external_review: unavailable` 또는 `external_review: not-requested` 상태에서는 `LGTM: YES`를 쓰지 않는다.

## 결정 보고 5필드

리뷰 파일에는 아래 필드를 포함한다.

```md
LGTM: YES | NO | UNKNOWN
external_review: unavailable | not-requested | independent-codex | user-approved
Review target: <diff/files>
Return path: continue | return-to-step-3 | return-to-step-4 | pause
Loop counter: <DEFECT_ENUM:file-or-area>=<count>
```

같은 결함 라벨이 5회 반복되면 자동 중단하고 [stop-report.md](../stop-report.md) 형식으로 남긴다.

`step4_commit_sha`는 git 저장소에서 필수다. 리뷰 파일 frontmatter 또는 본문에 기록하지 않으면 Step 6 게이트가 실패한다.

## Chunk 리뷰

Chunk 모드에서는 전체 diff를 한 번에 승인하지 않는다.

- `Review target`은 `chunk <n>`과 해당 파일 목록으로 제한한다.
- 각 chunk마다 `LGTM`, `Return path`, `Loop counter`를 독립 기록한다.
- 한 chunk가 `NO` 또는 `UNKNOWN`이면 다음 chunk로 넘어가지 않고 해당 chunk를 Step 3 또는 Step 4로 되돌린다.

## finding 형식

```md
- [P1|P2|P3] <DEFECT_ENUM> <문제 요약> — <파일:라인>
  Impact: <사용자/시스템 영향>
  Evidence: <diff, 테스트, 코드 근거>
  Fix: <수정 방향>
```

## 결함 유형 enum

Loop counter는 자유 문구가 아니라 아래 enum과 파일 경로를 함께 사용한다.

- `SECURITY_AUTH`
- `SECURITY_SECRET`
- `DATA_LOSS`
- `API_CONTRACT`
- `STORAGE_FORMAT`
- `FILE_PATH`
- `RUNTIME_ERROR`
- `UI_LAYOUT`
- `ACCESSIBILITY`
- `PERFORMANCE`
- `TEST_GAP`
- `SCOPE_DRIFT`
- `BUILD_CI`

동일성 라벨 형식: `<DEFECT_ENUM>:<file-or-area>`.

## 재진입 규칙

- 코드 결함은 Step 4로 돌린다.
- 계획 누락이나 범위 오류는 Step 3로 돌린다.
- 검증 부족만 문제면 Step 6으로 보낼 수 있다.
- 리뷰 대상 자체가 불명확하면 `UNKNOWN`으로 두고 대상 파일 목록을 다시 만든다.

## 판정

- `PASS`: 막는 이슈가 없고 검증도 충분하다.
- `FAIL`: 수정이 필요한 이슈가 있다.
- `UNKNOWN`: 리뷰 대상이나 검증 증거가 부족하다.

판정과 별개로 Step 전환은 `validate-runtime-gate.ps1` 결과를 따른다.

## 완료 조건

- 발견 사항이 심각도 순으로 정리되어 있다.
- 파일/라인 근거가 가능한 범위에서 포함되어 있다.
- 미실행 테스트가 명확히 표시되어 있다.
- `PASS`면 막는 이슈 없음과 남은 위험이 함께 적혀 있다.
