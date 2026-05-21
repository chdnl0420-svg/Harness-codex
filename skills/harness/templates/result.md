<!--
TEMPLATE: result.md
Generated at Complete.
Filename: result-<REQUEST_ID>.md
-->
---
request_id: <REQUEST_ID>
status: completed
total_iterations: <N>
created: <ISO_TIMESTAMP_START>
completed: <ISO_TIMESTAMP_END>
plan_final_version: <N>
research_count: <N>
review_count: <N>
critique_method: <codex | code-review-skill | self-only>
---

# ✅ Result: <SHORT_TITLE>

## Summary
<1-2 sentence summary of what was accomplished>

## Original Request
> <USER_REQUEST verbatim>

## Final Changes

### Files Created
- `<path>` — <description>

### Files Modified
- `<path>` (+<lines added> / -<lines removed>) — <description>

## Workflow Rounds

### Domain and Plan (Steps 2-3)
- Plan revisions: <N>
- Self-Review final: <X/10>
- External critique: <Codex LGTM | code-review-skill LGTM | self-only>

### Research (on-demand)
- Total research calls: <N>
- Topics covered:
  - <topic 1> (research-XX)
  - <topic 2> (research-XX)

### Review Loop (Step 5)
- Iter 1: <reviewer> — <N CRITICAL, M HIGH → fixed>
- Iter 2: <reviewer> — <LGTM | issues>
- ...

## Deferred Issues (선택적 후속 작업)

- <MEDIUM/LOW item from final review — for user judgement>

## Recommended Next Steps

- [ ] Run tests: `<command>`
- [ ] (필요시) PR 생성
- [ ] (필요시) <additional follow-up>

## Reproduce / Audit Trail

모든 산출물은 `.harness/` 아래 보존됨:

| 종류 | 파일 |
|------|------|
| Domain | `domain-<id>.html` |
| Implementation | `implementation-<id>.html` |
| Progress | `progress/progress-<id>.md` |
| Research | `research/research-<id>-*.md` |
| Reviews | `reviews/review-<id>.md` |
| QA | `results/qa-<id>.md` |
| Customer | `results/customer-<id>.md` |
| **Final report** | **`results/report-<id>.html`** |

## Cost Summary

- Codex critique/review calls: <N> (subscription)
- Research files written: <N> (호출자 Codex 직접 수행)
- Codex orchestration: current Codex session/runtime
