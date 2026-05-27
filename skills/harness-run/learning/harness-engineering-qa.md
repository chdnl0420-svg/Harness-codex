# Learning Data: harness-engineering-qa

> Schema 1.0. dated entries only (`[YYYY-MM-DD]` 태그 필수).
> add/update/delete 는 메인 Codex 가 서브에이전트 응답의 `## Learning Proposals` 섹션을 검증 후 반영.
> 사이즈 정책: 작업 캡 800줄. 공식 startup inject 는 첫 200줄 컷 — 핵심 patterns 는 상단 배치.

## Principles
범용 원칙. 거의 안 바뀜.

(빈 섹션)

## Patterns
잘 통하는 접근법. 자주 갱신.

- [2026-05-25] **CSS bundle 크기 0 변화 = 스타일 회귀 0 보장 (Vite 한정)**: Vite/Rollup 의 CSS 처리는 deterministic — `*.css` 입력 무수정이면 출력 `.css` 해시·크기 1:1 일치. refactor 회차에서 React 컴포넌트만 분해하고 CSS 무수정 시, build 후 renderer CSS bundle 크기가 baseline 과 동일하면 스타일 회귀 0 으로 자동 판정 가능. 별도 visual regression 불필요.
- [2026-05-25] **`^export (function|const|default)` rg 으로 object-per-file 정합성 검증**: 분리 회차의 신규 파일이 "1 객체 = 1 파일" 규칙을 지키는지 빠르게 확인. 한 파일에 export 가 2개 이상이면 위반 가능성 (단, type/interface 와 동일 이름 함수의 동거는 정상). React 컴포넌트 + 같은 파일 안의 helper 함수는 위반 패턴.
- [2026-05-25] **constants.ts / persistence.ts / utils.ts 같은 도메인 묶음 파일은 multi-export 정상**: `constants.ts` (12 exports) + `persistence.ts` (4 exports) 처럼 같은 도메인의 상수·유틸 함수를 묶은 파일은 object-per-file 위반이 아님. `^export ...` rg 에서 export 수 > 1 이면 **도메인 묶음 파일(constants/utils/types)인지** 먼저 확인하고 위반 판정. 진짜 위반 패턴은 "서로 다른 책임의 React 컴포넌트 2개 + helper 함수가 한 파일에 공존".

## Anti-patterns
하면 안 되는 것.

(빈 섹션)

## Project-specific
프로젝트별 빌드·테스트 명령·도구·관행. 회차마다 다름.

### VisualAgents.dryrun (Electron + React + electron-vite, monorepo with `avd/` workspace)

- [2026-05-25] **`npm run typecheck` 가 avd workspace build 를 내포**: `package.json` `scripts.typecheck = "npm -w avd run build && tsc --noEmit -p tsconfig.node.json && tsc --noEmit -p tsconfig.web.json"`. `npm -w avd run build` (= `tsc -p tsconfig.json` in `avd/`) 이 먼저 실행되므로, 별도 `npm -w avd run build` 명령 불필요. `typecheck` 한 번이면 avd 도 함께 검증됨.
- [2026-05-25] **테스트 인프라 미설정 — refactor 회차 시 waiver 3종 세트 패턴**: `package.json` `scripts` 에 `test` 없음, `devDependencies` 에 vitest/jest/mocha/playwright 없음, ESLint 도 미설정. refactor 회차의 정합 처리:
  1. `02-domain/waiver.md` — CQRS+ES 적용 안 함 (회차 = 도메인 모델링 아님)
  2. `03-tdd/waiver.md` — TDD Red→Green→Refactor 안 함 (characterization 으로 대체)
  3. `04-qa/coverage-waiver.md` — 80% 커버리지 안 함 (테스트 도구 미설정)
  세 waiver 모두 *명시 사유* + *non-waivable invariant 7개와 충돌 없음* 체크박스 통과 시 audit `PASS_WITH_WAIVERS` 인정.

## Open Questions
아직 결론 안 난 것. 결론 나면 Patterns/Anti-patterns 로 이동.

(빈 섹션)

## Resolved Questions
해소된 Open Question 의 기록.

(빈 섹션)

## References

- VisualAgents.dryrun = AgentView Electron 앱의 dry-run 사본 (`D:\Project\VisualAgents.dryrun`)
- 이전 회차: `20260524T1217Z-refactor` (ipc.ts/App.tsx/global.css 분해 LGTM)
- 본 회차: `20260525T031018Z-refactor` (SessionDetail.tsx 1798L 분해)
