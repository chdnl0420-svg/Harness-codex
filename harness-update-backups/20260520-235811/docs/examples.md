# Examples

## 새 작업

```text
/harness 로그인 오류를 재현하고 수정해줘
```

예상 흐름:

1. Step 1에서 메인 repo의 `.harness`를 찾거나 만든다.
2. Step 2에서 도메인 설계를 만든다.
3. Step 3에서 구현 계획을 만든다.
4. Step 4에서 코드를 수정한다.
5. Step 5와 Step 6으로 리뷰와 검증을 수행한다.
6. 최종 보고서를 저장한다.

## 인터랙티브 작업

```text
/harness-ask 결제 플로우 개선을 계획해줘
```

불확실한 범위나 우선순위가 있으면 사용자에게 짧게 묻는다.

## worktree 작업

worktree가 `C:\Users\...\worktrees\123\Repo` 여도 `.harness`는 `git common dir` 부모의 메인 repo에 둔다.
