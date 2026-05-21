# Dual Environment Bridge

This project may be opened by both Codex and Claude Code.

## Authoritative Project Instructions

`AGENTS.md` is the shared project instruction source. Claude Code users should read `AGENTS.md` first and treat this file only as a bridge.

## Harness State Location

Harness state belongs in the main repository `.harness` directory resolved from Git common dir, not inside a temporary worktree.

Expected location:

```text
<main-repo-root>/.harness
```

## Runtime Ownership

- Codex command wrappers live under `~/.codex/skills/ecc-command-harness*`.
- Claude Code command wrappers live under `~/.claude/commands/harness*.md`.
- The project state files under `.harness` are shared.
- Do not copy one runtime's local skill installation over the other without a diff review.

## Conflict Rule

If this bridge conflicts with `AGENTS.md`, `AGENTS.md` wins.

If an existing `CLAUDE.md` has project-specific rules, merge those rules into `AGENTS.md` before replacing it with this bridge.

## Update Rule

When Harness is updated in Codex, run mirror drift checks before changing Claude Code files:

```text
/harness-setup --check-mirror
```

Only port the files that are relevant to Claude Code's command and skill model.
