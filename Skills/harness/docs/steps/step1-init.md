# Step 1: 초기화 또는 재개

## 목표

Harness 상태 폴더를 Git common dir 기준 메인 repo에 준비하고, 현재 작업을 추적할 progress 파일을 연다.

다음 단계는 [Step 2: 도메인 설계](step2-domain.md)다. 전체 흐름은 [workflow.md](../workflow.md)를 따른다.

## 절차

1. `git rev-parse --path-format=absolute --git-common-dir`를 실행한다.
2. 반환된 Git common dir의 부모를 `HARNESS_PROJECT_DIR`로 둔다.
3. `$HARNESS_PROJECT_DIR/.harness`를 확인한다.
4. `.harness/{progress,research,reviews,results}` 폴더만 보장한다.
5. `progress/`, `reviews/`, `results/`, `research/` 폴더를 보장한다.
6. slug를 정하고 `.harness/progress/progress-<slug>.md`를 생성 또는 재개한다.

## 프로젝트에 복사하지 않는 대상

원본 Harness와 동일하게 스킬 본문, `docs/`, `templates/`, `agents/learning/`, `core/`, wrapper 코드는 프로젝트 `.harness`로 복사하지 않는다. 스킬 설치본(`~/.codex/skills/harness`)이 정본이고, 프로젝트 `.harness`에는 실행 산출물만 둔다.

프로젝트 사양 문서(`docs/PRD.md`, `docs/ARCHITECTURE.md`, `docs/ADR.md`, `docs/UI_GUIDE.md`)와 Codex 지침(`AGENTS.md`)은 비어 있거나 없을 때만 seed할 수 있다. 기존 파일은 덮어쓰지 않는다.

## 예외 처리

- Git 저장소가 아니면 현재 디렉터리를 `HARNESS_PROJECT_DIR`로 두고 `NO_GIT`를 progress에 기록한다.
- `.harness/docs`, `.harness/templates`, `.harness/agents`가 이미 있어도 워크플로 정본으로 사용하지 않는다. 기존 사용자 자료 보호를 위해 자동 삭제하지 않는다.
- Codex worktree에서 실행 중이면 worktree 루트가 아니라 Git common dir의 부모를 사용한다.
- 기존 `AGENTS.md`는 덮어쓰지 않는다. 병행 환경 bridge는 `HARNESS_DUAL_ENV=1` 또는 `--dual-env`일 때만 만든다. 기준은 [environment-map.md](../environment-map.md)를 따른다.

## progress 최소 내용

```md
# Harness Progress: <slug>

- Goal: <사용자 요청에서 추린 목표>
- HARNESS_PROJECT_DIR: <절대 경로>
- Mode: noask | ask
- Current step: 1

## Step 1
- Status: PASS | BLOCKED
- Notes:
```

## Step chain

- [Step 2: 도메인 설계](step2-domain.md)
- [Step 3: 구현 계획](step3-impl-plan.md)
- [Step 4: 구현](step4-impl.md)
- [Step 5: 리뷰](step5-review.md)
- [Step 6: QA](step6-qa.md)
- [Step 7: 고객 사용자 검증](step7-customer.md)
- [Step 8: 완료 전 정리](step8-commit.md)
- [Complete: 최종 보고](complete.md)
