# Harness Agent Learning Data

Harness keeps shared learning files only for persona helpers that still have local Harness state:

- `harness-customer-user.md` - step7 general-user validation
- `harness-qa-engineer.md` - step6 QA validation

External research does not use a Harness-specific learning file. Harness delegates research to the shared `$deepresearch` skill at `~/.codex/skills/deepresearch/SKILL.md`.

## Storage

- Shared learning files live under `~/.codex/skills/harness/agents/learning/<agent>.md`.
- Project-specific learning under `<PROJECT>/.harness/agents/learning/` is deprecated. Put project context in `AGENTS.md` or project docs instead.

## File Structure

Each learning file keeps this fixed shape:

```markdown
# Learning Data: <agent-name>

> Schema 1.0. dated entries only. add/update/delete via caller loop (Codex).
> Max 800 lines. Over limit -> /harness-distill <agent>.

## Principles
General principles.

## Patterns
Useful repeated patterns.

## Anti-patterns
Things to avoid.

## Project-Specific
Normally empty in shared files.

## Open Questions
Unresolved items that need future distillation.
```

Entry format:

```markdown
- [YYYY-MM-DD] One or two sentence summary. (source: REQUEST_ID or general)
```

## Update Rule

Helpers may propose learning changes in a `## Learning Proposals` section. The caller verifies duplicates, contradictions, format, and size before editing these files. Helpers must not edit learning files directly.
