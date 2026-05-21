---
name: harness-update
description: Slash command '/harness-update'. Update the real global Codex skills directory from https://github.com/chdnl0420-svg/Harness without asking questions. Classify upstream files into exact-copy, minimal-Codex-port, and port-required groups, validate a staged Codex port, then replace the managed Harness skills under $CODEX_HOME/skills or ~/.codex/skills automatically.
---

# harness-update

Use only when the user explicitly invokes `/harness-update` or directly asks to create/run the Harness update flow.

## Behavior

Run the bundled script without asking questions:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "<this skill>/scripts/harness-update.ps1"
```

Default behavior:

- Clone `https://github.com/chdnl0420-svg/Harness` at `main`.
- Build a temporary staged Codex port from the classified upstream file set.
- Validate the staged port before touching the live global skills directory.
- Replace only managed Harness skills in `$CODEX_HOME/skills` or `~/.codex/skills`:
  - `harness`
  - `harness-plan`
  - `harness-plan-ask`
  - `harness-review`
  - `harness-deep-researcher`
  - `harness-customer-user`
- Move existing managed Harness skills and old `ecc-command-harness*` wrappers to `$CODEX_HOME/harness-update-backups/<timestamp>` before replacement.
- Install only the Codex-supported surface.
- Do not install Claude Code `commands/`, user-level `agents/`, root `README.md`, upstream `.version`, or `.gitattributes`.
- Write reports to `$CODEX_HOME/harness-update-reports/`.

## Classification

Exact copy:

- `LICENSE` into `harness/LICENSE`
- Safe templates: `doc-adr.md`, `doc-architecture.md`, `doc-prd.md`, `doc-ui-guide.md`, `improvement.md`

Minimal Codex port:

- Core docs: `workflow.md`, `donot.md`, `html-output-rule.md`, `test-guide-format.md`
- Step docs: `docs/steps/*.md`
- Procedure docs: `codex-review-procedure.md`, `customer-test-procedure.md`, `deep-research-procedure.md`
- Learning files: `agents/learning/*.md`
- Additional templates: `learning-proposal.md`, `plan.md`, `progress.md`, `result.md`, `review.md`, `project-claude.md` as `project-agents.md`

Port required:

- `skills/harness/SKILL.md`
- `skills/harness-plan/SKILL.md`
- `skills/harness-plan-ask/SKILL.md`
- `skills/harness-review/SKILL.md`
- `skills/harness-deep-researcher/SKILL.md`
- `skills/harness-customer-user/SKILL.md`
- `skills/harness/core/bootstrap-runtime.sh`

## Verification

After the script runs, report:

- installed global skills path
- upstream commit
- exact/minimal/ported/excluded counts
- forbidden-string check result
- broken relative Markdown link count
- `bootstrap-runtime.sh` `bash -n` result, if `bash` is available
