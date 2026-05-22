---
name: harness-review
description: harness step5 외부 Codex 리뷰 wrapper. file-list MD 작성 → codex exec 한 줄 프롬프트 호출 → result.md Read → 호출자에 verbatim 반환의 4단계 절차. self-review bias 차단을 위해 외부 verifier 로 동작. Codex 로그인 필요(exit 2)는 fallback 금지, quota 소진(exit 3)만 code-review skill fallback + fallback_used 필드 명시.
---

# harness-review

`/harness` step5 리뷰 단계에서 호출자 Codex가 수행하는 **Codex 외부 리뷰** wrapper.

본 skill 은 별도 프로세스가 아니다. [`codex-review-procedure.md`](../harness/docs/procedures/codex-review-procedure.md) 의 4단계 절차를 호출자 Codex가 그대로 수행한다.

## 호출 조건

- `/harness` step5 진입 시 (자동)
- `/harness-review` 슬래시 커맨드 직접 호출

## 절차 (single source — codex-review-procedure.md 참조)

1. **file-list MD 작성** — `.harness/reviews/review-<slug>-file-list.md` 에 *경로만* 한 줄씩.
2. **`codex exec` 한 줄 프롬프트** 호출:
   ```bash
   codex exec --sandbox workspace-write \
     ".harness/reviews/review-<slug>-file-list.md 에 적힌 파일들 전부 리뷰해줘. \
      리뷰 결과는 .harness/reviews/codex-review-<slug>-result.md 에 작성해줘."
   ```
3. **결과 파일 Read** — `.harness/reviews/codex-review-<slug>-result.md` 본문 확인.
4. **호출자에 verbatim 반환** + result 절대경로 한 줄 보고.

## Fallback 정책 (정합 — SKILL.md "자동 결정 매핑" 따름)

`codex exec` exit code 별 처리:

- **exit 0** — 정상. 결과 파일 Read 후 호출자에 반환.
- **exit 2 (로그인 필요)** — fallback 금지. `BLOCKED / DEPENDENCY_MISSING` 으로 기록하고 사용자가 새 터미널에서 `codex login` 후 resume 하게 한다. 독립 리뷰가 빠진 self-review 를 LGTM 으로 승격하지 않는다.
- **exit 3 (quota 소진)** — `code-review` skill 자동 fallback. `fallback_used=code-review (codex quota)` 필드 명시. fallback 결과는 self-review 로 취급하고 `LGTM:YES` 승격 금지.
- **기타 exit code** — STOP, 사용자/호출자 보고. fake 응답 생성 절대 금지.

> **2026-05-22 정합화 노트**: exit 2 는 로그인 상태 문제라 독립 Codex 리뷰를 재개할 수 있으므로 fallback 하지 않는다. exit 3 quota 소진만 self-review fallback 을 허용하되 `LGTM:YES` 로 승격하지 않는다.

## 결과 양식

```
Codex 리뷰 완료
결과: <project>/.harness/reviews/codex-review-<slug>-result.md
fallback_used: <none | blocked-codex-auth | code-review (codex quota)>

(이하 result.md 본문 verbatim)
```

## 관계

- 본문 절차 정본: [`docs/procedures/codex-review-procedure.md`](../harness/docs/procedures/codex-review-procedure.md)
- helper 기준: 사용 가능한 Codex helper/sub-agent가 있으면 동일 절차를 맡기고, 없으면 호출자 Codex가 직접 수행한다.
- Fallback: exit 3 quota 소진 시에만 사용. exit 2 로그인 필요는 BLOCKED 로 멈춘다.
- 사용자 진입점: `/harness-review` 슬래시 커맨드
