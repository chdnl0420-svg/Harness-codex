# File Formats

모든 산출물은 Git common dir 기준 메인 repo의 `.harness` 아래에 둔다.

## HTML

다음 파일은 HTML을 우선한다.

- `domain-<slug>.html`
- `implementation-<slug>.html`
- `results/report-<slug>.html`

HTML은 단일 파일이어야 하며, 첫 탭은 요약이어야 한다.

## Markdown

다음 파일은 Markdown을 우선한다.

- `progress/progress-<slug>.md`
- `reviews/review-<slug>.md`
- `results/qa-<slug>.md`
- `results/customer-<slug>.md`
- `test-guide-<slug>.md`
- `research/research-<slug>-<NN>-<topic>.md`

`progress`는 `.html`로 만들지 않는다. 항상 `progress/progress-<slug>.md`를 사용한다.

## 표준 산출물 경로

| 종류 | 경로 |
| --- | --- |
| Progress | `.harness/progress/progress-<slug>.md` |
| Domain | `.harness/domain-<slug>.html` |
| Implementation | `.harness/implementation-<slug>.html` |
| Review | `.harness/reviews/review-<slug>.md` |
| QA | `.harness/results/qa-<slug>.md` |
| Customer | `.harness/results/customer-<slug>.md` |
| Final report | `.harness/results/report-<slug>.html` |

## 저장 보고

파일을 저장한 뒤 채팅에는 절대경로를 한 줄로 보고한다. `file://` 링크는 만들지 않는다.
