# Waiver — `<step>` 강제 항목 생략 사유

> v2 audit 강화의 waiver 양식. `run-mode` 가 `refactor` 또는 `feature-add` 라서 [docs/run-modes.md §5](../docs/run-modes.md#5-회차-유형별-강제-항목-step-별) 의 강제 항목을 생략할 때 의무.
> 본 파일이 없으면 step 7 audit 가 자동 `FAIL`. [docs/run-modes.md §2 waiver 인정 게이트](../docs/run-modes.md#2-waiver-체계) 통과 시 `PASS_WITH_WAIVERS`.

---

## 1. 생략 항목

- **항목**: <예: "step 3 TDD Red→Green→Refactor 사이클" / "step 4 80% 커버리지" / "step 6 production 설치본 사용자 테스트">
- **연결 정책 라인**: <run-modes.md / steps/*.md 의 어느 줄을 우회하는지 — 정확한 anchor 또는 줄번호>
- **본 회차 run-mode**: <new-domain / feature-add / refactor>
- **회차 ID**: `<UTC-timestamp>-<slug>`

## 2. 사유

<왜 빼야 하는가. 구체적으로. 예시:
- "이번 회차는 모놀리스 컴포넌트 분해 리팩토링으로 동작 변경 없음"
- "프로젝트에 Vitest/Jest 미설정 + 본 회차 범위에서 도입 비용 큼"
- "step 6 production 설치본은 사용자 체감 변화 없는 리팩토링이므로 dev build 검증으로 충분">

## 3. 대체 검증

<강제 항목을 빼는 대신 무엇으로 보증하는가. 측정 가능해야 함. 예시:
- "characterization test 로 행위 보존 확인 (baseline.md + after.md 둘 다 PASS)"
- "기존 회차 `<run-id>` 의 QA 산출물 회귀 검증"
- "dev build 의 화면 5개 스크린샷 비교 (변화 없음)">

## 4. audit 허용 조건

<1차+2차 audit 이 본 waiver 를 인정하기 위한 측정 가능한 기준. binary 또는 카운트:
- "characterization baseline 의 시나리오 수 == after 시나리오 수 + 모두 PASS"
- "스크린샷 비교 차이 < 1% (해시 또는 시각 비교)"
- "기존 회차 산출물 경로 존재 + Verdict: PASS 명시">

## 5. 후속 권장

<다음 회차에서 이 waiver 를 메우려면 무엇을 해야 하는가. 구체적 task:
- "Vitest 도입 + 본 회차의 Aggregate 에 대해 TDD 회차 1번 추가"
- "production 설치본 회귀 테스트 회차 1번 (`<UTC>-prod-uat`)">

---

## non-waivable invariant 충돌 확인 (의무)

본 waiver 가 [docs/run-modes.md §non-waivable invariant 7개](../docs/run-modes.md#non-waivable-invariant-7개) 중 하나라도 우회하면 즉시 무효 + audit `FAIL`.

- [ ] non-waivable #1 (외부 의존성 + production credential BLOCKED) — 충돌 없음 확인
- [ ] non-waivable #2 (step 5 codex 실 호출 + raw 보존) — 충돌 없음 확인
- [ ] non-waivable #3 (step 7 1+2 audit + findings.md) — 충돌 없음 확인
- [ ] non-waivable #4 (step 9 민감 파일 자동 제외) — 충돌 없음 확인
- [ ] non-waivable #5 (step 9 푸쉬 금지) — 충돌 없음 확인
- [ ] non-waivable #6 (§2.5 객체/UI 분리 자동 리팩토링) — 충돌 없음 확인
- [ ] non-waivable #7 (`01-detect/external-dependencies.md` 산출) — 충돌 없음 확인

모두 체크되어야 waiver 가 audit 인정 후보가 된다.

---

## 작성자 / 시각

- 작성자: <메인 Codex / 사용자>
- UTC: <YYYY-MM-DD HH:MM:SS UTC>
