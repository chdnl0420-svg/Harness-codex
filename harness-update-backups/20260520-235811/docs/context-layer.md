# Context Layer

Harness는 긴 작업을 `.harness` 아래의 문서로 이어간다.

## 기준 파일

- `.harness/progress/progress-<slug>.md`: 현재 상태와 자동 결정 기록
- `.harness/domain-<slug>.html`: 도메인 설계
- `.harness/implementation-<slug>.html`: 구현 계획
- `.harness/results/report-<slug>.html`: 최종 보고

## 재개 규칙

작업을 재개할 때는 progress 파일을 먼저 읽고, 그 다음 domain 또는 implementation 문서를 다시 읽는다. 이전 대화 기억만으로 이어가지 않는다.

## worktree 규칙

작업 파일은 Codex worktree에 있을 수 있지만, Harness 상태 파일은 Git common dir 기준 메인 repo의 `.harness`에 둔다.
