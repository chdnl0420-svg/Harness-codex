# step 6 - 고객 테스트

기존 `harness-customer-user` 를 재사용한다. 일반 사용자 관점의 사용성 검증이며, 호출자 Codex 가 직접 페르소나를 수행하지 않는다.

## 재사용 계약 (호출 방식)

- **에이전트 위치**: `~/.codex/skills/harness-run/agents/harness-customer-user.md` (v2.1 부터 Codex 최상위 single source of truth — 본 skill 과 자매 skill `harness` 공유)
- **호출 방식**: 메인 Codex 가 codex exec 재귀 호출로 `harness-customer-user` agent prompt 실행. 페르소나 객관성 보존을 위해 sub-agent 컨텍스트 유지 필수. step 1 의 presence check 가 본 에이전트 등록 확인 후 진행.
- **learning 시스템**: 자매 skill `harness` 가 제거되어 외부 learning 경로 없음. 본 skill 의 `learning/` 또는 별도 메모리에 누적.
- **실패 처리** (예외 ⑤ `SUBAGENT_RUNTIME_BLOCKED`):
  - 스크린샷 캡처 도구 부재: BLOCKED 보고 + 사용자 환경 설정 안내 후 대기
  - 테스트 대상 URL 접근 불가: BLOCKED 보고 + 사용자 확인 후 재시도
- **fake 응답 절대 금지**: 실 테스트 수행 못하면 임의로 `Verdict: PASS` 작성 금지.

## 호출 전 안전 게이트 (CRITICAL — 산업 표준 UAT 격리)

ISTQB / UAT 컨센서스: **UAT/customer test 는 production 환경에서 절대 수행하지 않는다.** `harness-customer-user` 는 실제 클릭·스크린샷·계정 입력을 수행하므로 production endpoint 에 닿으면 실 결제·실 발송·실 외부 API 쓰기를 일으킨다. 다음을 호출 전에 강제 검증한다.

### Production-touch 차단 (step 1 과 동일 enum + allowlist 기반)

호출자가 받은 URL · 계정 · credential · base URL · env var · SDK config · CLI args · launch profile · CI secret source 에 다음 패턴이 하나라도 매치되거나 URL allowlist 외 host 이면 **즉시 BLOCKED** (deny-by-default):

- credential / key regex (step 1 와 동일): `STRIPE_LIVE`·`OPENAI_PROJECT`·`AWS_ACCESS_KEY`·`GITHUB_PAT`·`GOOGLE_API_KEY`·`SLACK_TOKEN`·`ANTHROPIC_KEY`·`PRIVATE_KEY`
- URL **allowlist**: [step 1 `01-detect.md` 의 Safe-endpoint Allowlist 표](01-detect.md#safe-endpoint-allowlist-단일-출처--step-6-customer-단계도-동일-표-참조) 만 참조. 본 step 은 별도 정의 없음 — 중복 정의는 충돌 위험.
- 핵심 사례: `*.firebaseio.com` 일반은 production 으로 간주 (BLOCKED). Firebase Local Emulator Suite 의 `localhost:9099/8080/9000/5001` 또는 명시 `<project>-test.firebaseio.com` 만 통과.
- `.env` 또는 환경변수: [step 1 의 production env var regex fenced block](01-detect.md#production-env-var-정확한-regex-markdown-표-escape-회피--fenced-block-사용) 참조. 추가로 `production-` prefix / `*_LIVE_KEY` / `*_PROD_KEY` 도 차단.
- 발견 시 customer test 자체를 실행하지 않음.

### BLOCKED 시 동작

1. `.harness/06-customer/customer.md` 에 `Verdict: BLOCKED` + `BLOCKED_REASON: production_endpoint_detected` + 발견 패턴의 **redaction (`<param_name> = <SHA256(value)[:8]>`)** 만 기록. **raw value 절대 금지.**
2. 채팅에 BLOCKED 보고 — *"customer test 는 sandbox/test endpoint 로만 진행됩니다. sandbox 전환 후 step 6 재호출 필요."*
3. step 6 진행 안 함. step 7 audit 단계는 BLOCKED 결과로 진행.

## 호출 전 준비

1. 실행 방법, URL, 계정, 테스트 데이터가 있으면 정리한다.
2. **상기 production-touch 차단 regex 재검증 통과 확인.**
3. 사용자에게 보이는 제품 설명만 전달한다.
4. 필요한 경우 테스트 가이드는 `Hidden Oracle (NOT USER INSTRUCTIONS)` 로 분리한다.
5. 결과 경로는 `.harness/06-customer/customer.md` 로 지정한다.
6. **credential·계정 정보는 sub-agent prompt 에 raw 로 전달 금지** — 별도 안전한 환경변수 또는 1회용 sandbox 계정만.

## 검증 범위

- 첫 화면에서 무엇을 해야 하는지 이해 가능한가
- 주요 기능의 첫 클릭이 맞는가
- 5초 테스트 결과
- Cognitive Walkthrough 4문항
- SUS / SEQ 점수
- Time-to-First-Value

## 산출물

`customer.md` 는 다음을 포함한다.

- `Verdict: PASS | FAIL | BLOCKED | UNKNOWN`
- `BLOCKED_REASON` (해당 시): `production_endpoint_detected` / `credential_missing` / `tool_unavailable` / `other`
- 발견한 사용자 혼란
- 첫 클릭 정확도
- 개선 제안
- 스크린샷 또는 실행 증거 경로가 있으면 포함
- **redaction 의무**: customer.md 와 스크린샷에 production 데이터·실 계정·실 결제 정보가 포착되면 자동 마스킹 후 저장. raw 저장 금지.

고객 테스트는 게이트가 아니라 보고 단계다. 단, BLOCKED 라면 summary 에 명확히 기록한다.

## 산출물 secret scan

`customer.md` · 스크린샷 파일 · `*.har` · `*.log` 가 생성된 직후 step 9 가 사용하는 동일 secret scan regex 로 1회 검사. 매치 발생 시 해당 파일을 `09-commit/files-excluded.md` 에 자동 등록 (step 9 가 커밋 대상에서 제외).
