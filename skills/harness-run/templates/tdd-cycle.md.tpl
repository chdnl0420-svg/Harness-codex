# TDD Cycle {{cycle}} - {{scenario}}

> Aggregate: {{aggregate}}  |  Context: {{context}}  |  Start: outside-in / inside-out (사유: {{reason}})

## Red — 실패하는 테스트 작성 + 실제 실행
- Test file:
- Test type: unit / integration / acceptance
- Command (실제 실행):
- Expected failure (의도):
- **Actual failure log (러너 출력 verbatim)**:
  ```
  <러너 출력>
  ```
- 의도된 FAIL? **YES / NO** (NO → 사이클 카운트 +1, 한도 게이지 +1)

## Green — 풀 구현 (Kent Beck Obvious Implementation 변형)
- Implementation files:
- Domain rules implemented (한 단락):
- Command:
- **Passing log (러너 출력)**:
  ```
  <PASS 라인>
  ```
- 외부 의존성 사용: in-memory / sandbox / 없음
- 사용한 in-memory 구현체 (Fake) 경로:
- 사용한 sandbox endpoint:

## Refactor — 매 사이클 의무
- 점검 항목:
  - [ ] 중복 코드 (Rule of Three)
  - [ ] 책임 분산
  - [ ] 객체 단위 분리 위반 (한 파일에 2 객체)
  - [ ] UI ↔ 기능 분리 위반 (UI 프로젝트)
  - [ ] 매직 넘버·문자열
  - [ ] 불변성 위반
  - [ ] 파일 길이 (200 권고 / 400 hard / 800 절대) - 위반 시 분리
- Change applied:
- Re-run command:
- Re-run result: PASS / FAIL
- (없으면 `Refactor: 없음`)

## No-Mock 증거 게이트 (자동 grep 검증)

다음 명령을 사이클 종료 직전 실행해 결과 verbatim 첨부. **finding 발견 시 사이클 FAIL.**

```bash
grep -nrE '\b(Mock|MagicMock|mockito|jest\.mock|jest\.spyOn|sinon\.(stub|spy|mock)|unittest\.mock|moq\.|NSubstitute|FakeItEasy)\b' <test directory>
```

- rg 결과 (raw):
  ```
  <결과 또는 "0 matches">
  ```
- Verdict: **NO_MOCK** / **MOCK_DETECTED → 사이클 FAIL**
- 예외 (`fakeredis` 같이 이름에 mock 들어가지만 Fowler 정의상 Fake): 명시 사유 + 라이브러리 docs URL

## Production-endpoint 증거 게이트 (자동 grep 검증)

```bash
grep -nrE '(sk_live_[A-Za-z0-9]{24,}|sk-proj-[A-Za-z0-9_-]{50,}T3BlbkFJ|\bAKIA[0-9A-Z]{16}\b|ghp_[A-Za-z0-9]{36}|AIza[0-9A-Za-z_-]{35}|xox[baprs]-)' <project source + test directory>
```

- rg 결과 (raw):
  ```
  <결과 또는 "0 matches">
  ```
- Verdict: **NO_PROD_ENDPOINT** / **PROD_DETECTED → 사이클 BLOCKED**

## Notes
- 도메인 결정 변경:
- Hotspot 추가:
