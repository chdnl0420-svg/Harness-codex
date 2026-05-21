#!/bin/bash
# bootstrap-runtime.sh - initialize Harness output directories for Codex.
#
# Usage:
#   bash bootstrap-runtime.sh [PROJECT_DIR]
#
# The input may be a normal repo root or a Codex worktree. When it is a
# worktree, Harness state is written to the parent of git common dir.
# Skill docs/templates/learning files remain in ~/.codex/skills/harness;
# project .harness stores workflow outputs only.

set -euo pipefail

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

seed_doc() {
    local tmpl=$1
    local dst=$2
    local label=$3
    if { [ ! -f "$dst" ] || [ ! -s "$dst" ]; } && [ -f "$tmpl" ]; then
        cp "$tmpl" "$dst"
        echo "spec seed: $label" >&2
    fi
}

seed_doc "$SKILL_DIR/templates/project-agents.md"   "$HARNESS_PROJECT_DIR/AGENTS.md"            "AGENTS.md"

echo "HARNESS_PROJECT_DIR=$HARNESS_PROJECT_DIR"
echo "HARNESS_DIR=$HARNESS_PROJECT_DIR/.harness"

exit 0
