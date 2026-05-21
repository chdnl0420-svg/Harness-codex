<!--
TEMPLATE: plan.md
Used for Step 3 implementation planning. Harness workflow names are Step 1-8 + Complete.
-->
---
request_id: <REQUEST_ID>
created: <ISO_TIMESTAMP>
status: draft
version: 1
user_request: "<USER_REQUEST>"
project_dir: <PROJECT_DIR>
chunk_mode: off
review_count: 0
research_count: 0
---

# Implementation Plan: <SHORT_TITLE>

## Inputs

- Domain: `.harness/domain-<REQUEST_ID>.html`
- Progress: `.harness/progress/progress-<REQUEST_ID>.md`
- User request: `<USER_REQUEST>`

## Scope

### In Scope

- <item>

### Out of Scope

- <item>

## Task Breakdown

### Task 1: <작업명>

- Files: <수정 예상 파일>
- Change: <구체적 변경>
- Verify: <명령 또는 수동 검증>
- Risk: <주요 위험>
- Rollback: <되돌리는 방법>

## Chunk Mode Check

- Changed files >= 6: yes | no
- Layers >= 3: yes | no
- User scenarios >= 3: yes | no
- Verification paths >= 3: yes | no
- Migration/refactor risk: yes | no
- Decision: `chunk_mode: on | off`

If chunk mode is on, list vertical slices:

| Chunk | User value | Files | Verify | Exit criteria |
| --- | --- | --- | --- | --- |
| C1 | <value> | <files> | <command> | <criteria> |

## Verification Plan

- Step 5 review target: <diff/files>
- Step 6 QA commands: <commands>
- Step 7 customer task: <task>

## Risks

| Risk | Impact | Mitigation | Evidence |
| --- | --- | --- | --- |
| <risk> | HIGH/MED/LOW | <mitigation> | <source> |

## Step 4 Entry Criteria

- [ ] Domain artifact exists.
- [ ] Implementation plan artifact exists.
- [ ] Test or QA fallback is defined.
- [ ] Rollback or pause condition is defined.
