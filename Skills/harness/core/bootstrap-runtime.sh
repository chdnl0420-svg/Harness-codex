#!/bin/bash
# bootstrap-runtime.sh - initialize a project's Harness output directories.
#
# Usage:
#   bash bootstrap-runtime.sh [--dual-env] [PROJECT_DIR]
#
# The input may be a normal repo root or a Codex worktree. When it is a
# worktree, Harness state is written to the parent of git common dir.
# Skill docs/templates/learning files remain in ~/.codex/skills/harness;
# project .harness stores workflow outputs only.

set -euo pipefail

DUAL_ENV=${HARNESS_DUAL_ENV:-0}
if [ "${1:-}" = "--dual-env" ]; then
    DUAL_ENV=1
    shift
fi

PROJECT_DIR=${1:-$(pwd)}

if [ ! -d "$PROJECT_DIR" ]; then
    echo "FATAL: PROJECT path not found: $PROJECT_DIR" >&2
    exit 1
fi

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
SKILL_DIR=$(dirname "$SCRIPT_DIR")

if COMMON_GIT_DIR=$(git -C "$PROJECT_DIR" rev-parse --path-format=absolute --git-common-dir 2>/dev/null); then
    HARNESS_PROJECT_DIR=$(dirname "$COMMON_GIT_DIR")
else
    HARNESS_PROJECT_DIR="$PROJECT_DIR"
fi

mkdir -p "$HARNESS_PROJECT_DIR/.harness"/{progress,research,reviews,results}

mkdir -p "$HARNESS_PROJECT_DIR/docs"

seed_doc() {
    local tmpl=$1
    local dst=$2
    local label=$3
    if { [ ! -f "$dst" ] || [ ! -s "$dst" ]; } && [ -f "$tmpl" ]; then
        cp "$tmpl" "$dst"
        echo "spec seed: $label" >&2
    fi
}

seed_doc "$SKILL_DIR/templates/doc-prd.md"          "$HARNESS_PROJECT_DIR/docs/PRD.md"          "docs/PRD.md"
seed_doc "$SKILL_DIR/templates/doc-architecture.md" "$HARNESS_PROJECT_DIR/docs/ARCHITECTURE.md" "docs/ARCHITECTURE.md"
seed_doc "$SKILL_DIR/templates/doc-adr.md"          "$HARNESS_PROJECT_DIR/docs/ADR.md"          "docs/ADR.md"
seed_doc "$SKILL_DIR/templates/doc-ui-guide.md"     "$HARNESS_PROJECT_DIR/docs/UI_GUIDE.md"     "docs/UI_GUIDE.md"
seed_doc "$SKILL_DIR/templates/project-agents.md"   "$HARNESS_PROJECT_DIR/AGENTS.md"            "AGENTS.md"

if [ "$DUAL_ENV" = "1" ]; then
    seed_doc "$SKILL_DIR/templates/project-dual-bridge.md" "$HARNESS_PROJECT_DIR/CLAUDE.md" "CLAUDE.md"
fi

echo "HARNESS_PROJECT_DIR=$HARNESS_PROJECT_DIR"
echo "HARNESS_DIR=$HARNESS_PROJECT_DIR/.harness"

exit 0
