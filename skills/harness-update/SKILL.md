---
name: harness-update
description: Slash command '/harness-update'. Install or update Harness for Codex from https://github.com/chdnl0420-svg/Harness-Codex into the current Codex home without interactive questions.
---

# harness-update

Use only when the user explicitly invokes `/harness-update` or directly asks to install/update Harness for Codex.

## Behavior

Run the bundled installer without asking questions:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "<this skill>/scripts/harness-update.ps1"
```

Default behavior:

- Clone `https://github.com/chdnl0420-svg/Harness-Codex.git` at `main`.
- Treat that repository as the Codex-ready distribution. Do not port, classify, or transform files from the old `Harness` repository.
- Install source `skills/*` directories into `$CODEX_HOME/skills` or `~/.codex/skills`.
- Install source `agents/*.md` files into `$CODEX_HOME/agents` or `~/.codex/agents`.
- Back up previously managed Harness skills, agents, and old `ecc-command-harness*` wrappers to `$CODEX_HOME/harness-update-backups/<timestamp>` before replacement unless `-NoBackup` is passed.
- Write an install report to `$CODEX_HOME/harness-update-reports/update-<timestamp>.json`.

Managed legacy names removed or replaced by this installer:

- Skills: `harness`, `harness-plan`, `harness-plan-ask`, `harness-review`, `harness-deep-researcher`, `harness-customer-user`, `harness-update`
- Agents: `codex-reviewer`, `harness-customer-user`, `harness-deep-researcher`, `harness-qa-engineer`

## Options

The script supports:

- `-CodexHome <path>`: override `$CODEX_HOME`.
- `-UpstreamUrl <url>`: override the Harness-Codex git URL.
- `-Ref <branch-or-tag>`: install a branch or tag instead of `main`.
- `-SourcePath <path>`: install from an already checked-out local Harness-Codex directory. This is for verification and development.
- `-NoBackup`: remove existing managed files instead of moving them to a backup directory.
- `-KeepTemp`: keep the temporary clone for debugging.

## Verification

After the script runs, report:

- installed global skills path
- installed global agents path
- upstream URL and commit/ref
- installed skill names
- installed agent file names
- backup path, if any
- report path
