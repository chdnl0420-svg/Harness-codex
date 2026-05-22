# Handoff — <slug>

## Runtime Resume Contract

This handoff is an active Harness resume artifact. Invoking Harness with this file path is explicit user authorization for Step6/Step7 sub-agent delegation.

Codex App bridge: spawn `agent_type="worker"` (`default` only if `worker` is unavailable), then load the custom Harness agent by including the full `~/.codex/agents/harness-qa-engineer.md` or `~/.codex/agents/harness-customer-user.md` spec in the prompt. Do not pass custom names as `agent_type` unless the runtime explicitly lists them. If spawn is exposed, direct caller QA/customer fallback is forbidden; if no spawn tool is exposed, record `BLOCKED / DEPENDENCY_MISSING`.

## Summary
- status: <completed | blocked | paused | failed>
- latest_review: <run/verdict/result_path>
- latest_qa: <verdict/result_path>
- commit_hash: <hash | not committed>

## Changed Files
- `<path>` — <summary>

## QA Evidence
- evidence_matrix: <present | missing>
- evidence_summary: <short summary>
- persistent_state_restored: <YES | NO | N/A>

## BLOCKED
- is_blocked: <true | false>
- reason_enum: <DEPENDENCY_MISSING | EVIDENCE_GATE_FAIL | PERMISSION_DENIED | GUIDE_MISSING | ENV_UNREACHABLE | CONTRACT_MISSING | TDD_MISSING | OTHER | none>
- blocking_contracts: <list>
- retry_condition: <what must change before resume>

## Audit
- state: `.harness/state.json`
- events: `.harness/events.ndjson`
- progress: `.harness/progress/progress-<slug>.md`
- generated_at: <ISO_TIMESTAMP>
