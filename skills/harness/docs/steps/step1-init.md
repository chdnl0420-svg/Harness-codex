# step1. harness 초기화

1. **REQUEST_ID 생성** — slug 형식 (예: `jwt-middleware`). 중복 시 숫자 추가.
2. **메인 repo 경로 식별 (worktree 안에서 실행된 경우)**
   - `git rev-parse --show-toplevel` 로 현재 작업 트리 경로 획득
   - `git rev-parse --git-common-dir` 로 공통 git 디렉토리 경로 획득. 두 값이 다르면 **현재 위치는 worktree 안**.
   - worktree 안이면 `.harness/` 의 정식 위치는 **공통 git 디렉토리의 부모(메인 repo 루트)** 로 고정한다. 이후 모든 step 이 그 경로를 `$HARNESS_PROJECT_DIR` 로 사용 (worktree 안에 별도 `.harness/` 만들지 않는다 — 자료가 둘로 갈라짐).
   - 일반 repo (worktree 아님) 면 `git rev-parse --show-toplevel` 결과를 그대로 사용.
3. **프로젝트 산출물 폴더 보장** — 메인 repo 경로의 `.harness/{progress,reviews,results,research,tests,export}` 디렉토리만 mkdir. 마스터의 `core/`, `wrappers/` 코드 복사 *폐기* (2026-05-20 정합화 — 마스터가 진실 원천, 프로젝트엔 산출물 (md/html/json/ndjson) 만 존재).
4. **harness-* helper 가용성 확인 + sub-agent 강제 게이트** — 본 워크플로우가 사용할 harness-* helper 또는 Codex skill 가용성을 확인한다. QA/customer sub-agent 부재는 직접 수행으로 대체하지 않고 `BLOCKED / DEPENDENCY_MISSING` 으로 처리한다.

   | 호출 대상 | 위치 | 부재 시 처리 |
   |----------|------|------------|
   | `harness-plan` (step2, noask 도메인) | `~/.codex/skills/harness-plan/SKILL.md` | 없으면 일반 `plan` skill + 호출자 Codex 가 직접 6 카테고리 합리적 가정 작성 |
   | `harness-plan-ask` (step2, ask 모드 인터랙티브) | `~/.codex/skills/harness-plan-ask/` | 부재 (2026-05-20 시점). `/harness-ask` 모드 사용 시 호출자 Codex 가 `harness-plan` 본문 + request_user_input 또는 일반 질문 직접 호출로 대체 |
   | `harness-review` (step5 Codex wrapper) | `~/.codex/skills/harness-review/` | 부재. step5 는 `codex exec` 직접 호출 + 결과 Read 절차 (docs/procedures/codex-review-procedure.md) 호출자 Codex 가 직접 수행. Codex 실패 시 `code-review` skill 폴백 |
   | `$deepresearch` | `~/.codex/skills/deepresearch/SKILL.md` | 부재 시 외부 리서치가 필요한 step 은 `BLOCKED / DEPENDENCY_MISSING` |
   | `harness-qa-engineer` | `~/.codex/agents/harness-qa-engineer.md` | 부재 시 step6 은 `BLOCKED / DEPENDENCY_MISSING`; 직접 QA 금지 |
   | `harness-customer-user` | `~/.codex/agents/harness-customer-user.md` 및 `~/.codex/skills/harness-customer-user/` | 부재 시 step7 은 `BLOCKED / DEPENDENCY_MISSING`; 직접 고객 페르소나 수행 금지 |

   - **검증 절차**: skill 경로는 `SKILL.md`, agent 경로는 `.md` 파일 존재 여부를 확인한다. QA/customer agent 부재 시 `progress-<slug>.md` 에 `subagent_missing=<name>` 을 기록하고 해당 step 진입 시 BLOCKED 처리한다.
   - **자동 복구 안 함**: 본 step1 도 `bootstrap-runtime.sh` 도 `/harness-setup` 도 부재 skill/helper를 자동 생성하지 않는다. skill 생성은 사용자가 명시 요청 시에만 별도 작업으로 수행한다.

5. **learning 파일 확인 (QA/customer 페르소나)** — 다음 공용 learning 파일이 설치본에 있는지 확인한다. 없으면 helper를 호출하지 말고 해당 step 을 `BLOCKED / DEPENDENCY_MISSING` 으로 처리한다. 호출자 Codex 직접 수행 금지.
   - `agents/learning/harness-customer-user.md`
   - `agents/learning/harness-qa-engineer.md`
6. **일반 skill/helper 가용성 확인** — 다음 일반 도구가 호출 가능하면 사용하고, 없으면 호출자 Codex가 직접 수행하거나 `BLOCKED`/`UNKNOWN`으로 기록한다.
   - skill `plan` (step3 구현 계획), `code-review` (step5 fallback), `security-review` (보안 게이트), `tdd` (TDD 모드 사이클), `build-fix` (step4 빌드 에러)
   - 사용 가능한 sub-agent/helper: `architect`, `code-reviewer`, `security-reviewer`, `tdd-guide`, 언어별 `*-build-resolver`
7. **legacy 폴더·마커 cleanup** — `.harness/.noagent`, `.harness/agents/`, `.harness/core/`, `.harness/wrappers/`, `.harness/plans/`, `.harness/improvements/` 가 보이면 *방치* (사용자 자료 보호 — 자동 삭제 안 함). 모두 2026-05-20 폐기됐고 워크플로우가 사용 안 함. 사용자가 정리 원하면 수동 `rm -rf` 안내.
8. **canonical state + event log 부트스트랩 (CRITICAL)** — `.harness/state.json` 과 `.harness/events.ndjson` 를 생성한다. `state.json` 은 최신 상태의 단일 진실원이고, `events.ndjson` 는 append-only 변경 이력이다. 사람이 읽는 progress summary 와 `state.json` 이 불일치하면 `state.json` 을 기준으로 progress 를 정정하거나 워크플로우를 중단한다.

   - `state.json` 필수 필드: `slug`, `mode`, `current_step`, `current_chunk`, `chunks_total`, `latest_review`, `latest_qa`, `loop_counters`, `blocked`.
   - `events.ndjson` 필수 이벤트: `workflow_started`, `step_changed`, `review_completed`, `qa_completed`, `blocked`, `handoff_exported`.
   - 모든 step 전환은 먼저 `events.ndjson` 에 append 한 뒤 `state.json` 최신 포인터를 갱신한다.
   - Run 번호·loop counter 는 `state.json` 에서만 증가시키고 progress 는 그 값을 복사한다.

   초기 `state.json`:

   ```json
   {
     "slug": "<slug>",
     "mode": "noask",
     "current_step": "step1",
     "current_chunk": null,
     "chunks_total": null,
     "latest_review": null,
     "latest_qa": null,
     "loop_counters": {
       "step5_lgtm_no": 0,
       "step6_fail": 0,
       "step6_blocked": 0
     },
     "blocked": {
       "is_blocked": false,
       "reason_enum": null,
       "chunk": null,
       "required_unblock": []
     }
   }
   ```

   초기 `events.ndjson`:

   ```json
   {"ts":"<ISO_TIMESTAMP>","type":"workflow_started","slug":"<slug>","mode":"noask"}
   ```

9. **progress 파일 부트스트랩** — `.harness/progress/progress-<slug>.md` 를 다음 양식으로 생성. 이후 step 들이 이 파일에 섹션 append.

   ```markdown
   # progress-<slug>

   - slug: <slug>
   - 시작일시: <YYYY-MM-DD HH:MM>
   - 모드: noask | ask
   - 한 줄 목표: <사용자 원본 한 줄 목표>
   - auto_triggered_from: <원본 slug> | (없음)   # step7 → 신규 워크플로우 chain 일 때만 채움. 존재하면 complete 진입 게이트에서 C 선택지 비활성 (무한 chain 차단)
   - state: .harness/state.json
   - events: .harness/events.ndjson
   - latest_review_run: null
   - latest_review_verdict: null
   - current_chunk: null
   - current_chunk_status: null
   - current_chunk_blocked_reason: null

   ## Loop Counter
   - step5 LGTM:NO 누적: 0회
   - step6 FAIL 누적: 0회
   - step6 BLOCKED 누적: 0회   # 동일 사유 5회 누적 시 request_user_input 또는 일반 질문 (noask 2번째 예외)

   ## step4_commit_sha
   <step4 진입 시 git rev-parse HEAD 결과 자동 기록>
   ```

   - **`auto_triggered_from` 필드 결정 규칙**:
     - 사용자가 직접 `/harness <목표>` 로 호출한 경우 → "(없음)" 으로 채움.
     - 부모 워크플로우의 complete 진입 게이트에서 *C 선택* 으로 자동 트리거된 경우 → 부모 slug 를 자동 기록 (호출자 Codex 가 step1 진입 직전 부모 progress 의 slug 를 prompt 컨텍스트에서 식별).
   - 부모 progress 가 있는지 식별이 모호하면 "(없음)" 으로 두고 사용자에게 한 줄 안내 — 자동 chain 감지 실패 시 무한 chain 차단이 발동 안 함, 그러나 동일 슬러그 재호출이 5회 누적되면 별도 가드(workflow.md 의 회송 5회 게이트) 에서 차단됨.
