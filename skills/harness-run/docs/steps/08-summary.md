# step 8 - 최종 보고서

전체 결과를 **현재 회차 폴더 안** (`.harness/runs/<run-id>/summary.md` 와 `.harness/runs/<run-id>/summary.html`) 으로 정리한다. 루트의 `.harness/README.md` (회차 인덱스) 만 갱신 — 루트에는 회차별 summary 사본을 두지 않는다.

## HTML 규칙

HTML 작성 전에 반드시 `C:\Users\NX3GAMES\.codex\html-document-rules.md` 를 읽고 따른다.

기본 원칙:

- 단일 HTML 파일
- CSS / JS 인라인
- 첫 화면에 요약이 보일 것
- 1440x900 기준으로 내용이 깨지지 않을 것
- 파일 저장 후 브라우저 또는 렌더링 도구로 확인할 것

## summary.md 필수 섹션

- 목표
- 구현 요약
- DDD 산출물 요약
- TDD 결과
- QA 결과
- 코드 리뷰 결과
- 고객 테스트 결과
- audit 결과
- 남은 위험
- step 9 커밋 계획과 푸쉬 안내

## summary.html 필수 구성

- 첫 탭 또는 첫 섹션은 `요약`
- 핵심 상태 카드 3개 이상
- DDD / TDD / QA / Review / Customer / Audit 섹션
- 실패·BLOCKED 가 있으면 숨기지 말고 상단에 표시

## README 갱신

`.harness/README.md` 는 **회차 인덱스 (모든 runs/) + 최신 회차 요약** 만 보유. 현재 회차 상태·summary 링크 (`runs/<id>/summary.md`)·판정을 갱신한다. **commit hash 자리는 placeholder `<commit hash: pending — git log -1 --format=%h 로 확인>` 로 두며 step 9 이후 사람·CI 가 `git log -1` 명령으로 확인**한다 — step 9 는 README 도 status.md 도 commit 이후 수정하지 않으며, `runs/<id>/09-commit/status.md` 는 pre-commit readiness (포함·제외·메시지·`READY_TO_COMMIT`·`COMMITTED_SHA: <PENDING>`) 만 담는다. 실제 SHA·시각은 산출물 어느 파일에도 기록되지 않음 (no-post-commit-mutation 계약).

## step 8/9 순서 분리 (자기모순 차단)

- step 8 산출물 (`runs/<id>/summary.md`, `runs/<id>/summary.html`, 루트 `README.md`) 은 **pre-commit draft** 다.
- `runs/<id>/09-commit/status.md` 는 **pre-commit readiness 만** 기록 — `READY_TO_COMMIT` + `COMMITTED_SHA: <PENDING>` + 포함·제외 파일 목록·커밋 메시지. **commit 이후 추가 mutation 없음.**
- **실제 git short SHA 와 실제 commit 시각은 산출물 어느 파일에도 기록되지 않음** — `git log -1 --format='%h %ai'` (또는 동등 명령) 로 누구나 확인 가능. step 9 는 채팅 최종 한 줄로만 SHA 보고.
- step 8 의 summary.md / summary.html / 루트 README.md 는 step 9 이후 **자동 수정하지 않는다**. README 의 commit hash 칸은 placeholder `<commit hash: pending — git log -1 로 확인>` 로 영구 유지.
