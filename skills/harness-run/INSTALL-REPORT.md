# harness-run Install Report

Generated: 2026-05-27T01:54:27.991Z

## Result

- Skill root: `C:/Users/NX3GAMES/.codex/skills/harness-run`
- Entry prompt: `C:/Users/NX3GAMES/.codex/prompts/harness-run.md`
- Source read manifest: `references/source-manifest.md`
- Codex skill validation: PASS (`quick_validate.py` with UTF-8 mode)
- Static dryrun, PowerShell: PASS 34 / WARN 0 / FAIL 0
- Static dryrun, WSL bash: PASS 37 / WARN 0 / FAIL 0
- Residual forbidden markers in SKILL/docs/agents/templates: 0 matches for `~/.claude/`, `Task tool`, `subagent_type`, `AskUserQuestion`
- Dynamic G4 end-to-end: not run in this install pass because it invokes a full recursive Codex workflow and creates a sample .NET project; static install gates are complete.

## Installed Files

- `SKILL.md`
- `docs/workflow.md`, `docs/code-structure.md`, `docs/run-modes.md`
- `docs/steps/01-detect.md` through `09-commit.md`
- 6 agent definitions under `agents/`
- 14 templates under `templates/`
- 5 learning files plus `learning/README.md`
- `scripts/dryrun.sh` and `scripts/dryrun.ps1`
- `INSTALL-CHECK.md` and `references/source-manifest.md`

## Applied Codex Port Changes

- Claude plugin frontmatter replaced with minimal Codex skill frontmatter for discovery.
- Claude slash-command gate replaced with `/prompts harness-run` and non-interactive `codex exec` invocation rules.
- `~/.claude/...` paths converted to `~/.codex/skills/harness-run/...`.
- `Task tool` / `subagent_type` language converted to recursive `codex exec` patterns.
- Step 5 and step 7 raw stdout preservation added with `2>&1 | tee`.
- Learning bootstrap files installed, including new `harness-customer-user.md` seed.
- LP-1 through LP-5 pre-applied in step docs, agent learning, and audit/review invocation notes.

## Notes

- PowerShell 5 requires BOM for `dryrun.ps1`; the file was written with UTF-8 BOM.
- `dryrun.sh` detects WSL and maps to `/mnt/c/Users/NX3GAMES/.codex` when needed.
