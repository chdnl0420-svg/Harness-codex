#!/usr/bin/env bash
set -u

project_dir="$(pwd)"
mode="audit"
check_mirror=0
json=0
dry_run=0
codex_home="${CODEX_HOME:-$HOME/.codex}"
claude_home="${CLAUDE_HOME:-$HOME/.claude}"

usage() {
  cat <<'EOF'
Usage: check-harness-setup.sh [--project-dir PATH] [--codex-home PATH]
                              [--claude-home PATH] [--mode audit|update|init]
                              [--check-mirror] [--dry-run] [--json]

This bash checker audits the Codex Harness installation and optional
Codex/Claude mirror drift. It does not mutate files; update mode is reported
as a dry-run unless the PowerShell updater is used separately.
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --project-dir) project_dir="$2"; shift 2 ;;
    --codex-home) codex_home="$2"; shift 2 ;;
    --claude-home) claude_home="$2"; shift 2 ;;
    --mode) mode="$2"; shift 2 ;;
    --check-mirror) check_mirror=1; shift ;;
    --dry-run) dry_run=1; shift ;;
    --json) json=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage >&2; exit 2 ;;
  esac
done

normalize_path() {
  local p="$1"
  case "$p" in
    /*) printf '%s\n' "$p"; return ;;
  esac
  if command -v cygpath >/dev/null 2>&1; then
    cygpath -u "$p" 2>/dev/null || printf '%s\n' "$p"
  elif command -v wslpath >/dev/null 2>&1; then
    wslpath -u "$p" 2>/dev/null || printf '%s\n' "$p"
  else
    printf '%s\n' "$p"
  fi
}

codex_home="$(normalize_path "$codex_home")"
claude_home="$(normalize_path "$claude_home")"
project_dir="$(normalize_path "$project_dir")"

checks_area=()
checks_status=()
checks_evidence=()
checks_action=()

add_check() {
  checks_area+=("$1")
  checks_status+=("$2")
  checks_evidence+=("$3")
  checks_action+=("$4")
}

non_empty_file() {
  [ -f "$1" ] && [ -s "$1" ]
}

check_file() {
  local area="$1"
  local path="$2"
  local action="$3"
  if non_empty_file "$path"; then
    add_check "$area" "PASS" "$path" "None"
  elif [ -f "$path" ]; then
    add_check "$area" "FAIL" "$path is empty" "$action"
  else
    add_check "$area" "FAIL" "$path is missing" "$action"
  fi
}

check_contains_all() {
  local area="$1"
  local path="$2"
  local status="$3"
  local action="$4"
  shift 4
  if ! non_empty_file "$path"; then
    add_check "$area" "FAIL" "$path is missing or empty" "$action"
    return
  fi

  local missing=()
  local needle
  for needle in "$@"; do
    if ! grep -Fq "$needle" "$path"; then
      missing+=("$needle")
    fi
  done

  if [ "${#missing[@]}" -gt 0 ]; then
    add_check "$area" "$status" "Missing: ${missing[*]}" "$action"
  else
    add_check "$area" "PASS" "$path" "None"
  fi
}

json_escape() {
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  s="${s//$'\n'/\\n}"
  s="${s//$'\r'/}"
  printf '%s' "$s"
}

skills_dir="$codex_home/skills"
harness_dir="$skills_dir/harness"
setup_dir="$skills_dir/ecc-command-harness-setup"

[ -d "$codex_home" ] && add_check "path:CODEX_HOME" "PASS" "$codex_home" "None" || add_check "path:CODEX_HOME" "FAIL" "$codex_home missing" "Install Codex Harness."
[ -d "$skills_dir" ] && add_check "path:skills" "PASS" "$skills_dir" "None" || add_check "path:skills" "FAIL" "$skills_dir missing" "Install Codex skills."

check_file "skill:harness" "$harness_dir/SKILL.md" "Restore harness/SKILL.md."
check_file "skill:harness-plan" "$skills_dir/harness-plan/SKILL.md" "Restore harness-plan/SKILL.md."
check_file "skill:harness-plan-ask" "$skills_dir/harness-plan-ask/SKILL.md" "Restore harness-plan-ask/SKILL.md."
check_file "skill:harness-setup" "$setup_dir/SKILL.md" "Restore harness setup wrapper."
check_file "setup:powershell" "$setup_dir/scripts/check-harness-setup.ps1" "Restore the PowerShell checker."
check_file "setup:bash" "$setup_dir/scripts/check-harness-setup.sh" "Restore the bash checker."
check_file "setup:sync-script" "$setup_dir/scripts/sync-codex-harness.ps1" "Restore the portable sync script."
check_file "core:bootstrap" "$harness_dir/core/bootstrap-runtime.sh" "Restore bootstrap-runtime.sh."
check_file "core:runtime-gate" "$harness_dir/core/validate-runtime-gate.ps1" "Restore validate-runtime-gate.ps1."

for doc in setup workflow environment-map html-output-rule donot test-guide-format context-layer file-formats phases examples stop-report; do
  check_file "bundle:docs" "$harness_dir/docs/$doc.md" "Restore the missing Harness doc."
done

if grep -Eq '^[[:space:]]*9\.[[:space:]]*\[?Complete' "$harness_dir/SKILL.md" "$harness_dir/docs/workflow.md" "$harness_dir/docs/phases.md" 2>/dev/null; then
  add_check "content:complete-numbered" "FAIL" "Complete is listed as item 9" "Complete must be unnumbered; Step 9 does not exist."
else
  add_check "content:complete-numbered" "PASS" "Complete is not numbered as 9" "None"
fi

if grep -R -E '\.harness/plans/(domain|impl)-|final-<slug>|progress-<slug>\.html' "$harness_dir/SKILL.md" "$harness_dir/docs" "$harness_dir/templates" >/dev/null 2>&1; then
  add_check "content:legacy-artifact-paths" "FAIL" "Legacy artifact path text found" "Use standardized Harness artifact paths."
else
  add_check "content:legacy-artifact-paths" "PASS" "No legacy artifact path text" "None"
fi

harness_plan_path="$skills_dir/harness-plan/SKILL.md"
harness_plan_ask_path="$skills_dir/harness-plan-ask/SKILL.md"
step2_domain_path="$harness_dir/docs/steps/step2-domain.md"
deep_research_command_path="$skills_dir/ecc-command-harness-deep-researcher/SKILL.md"
deep_research_procedure_path="$harness_dir/docs/procedures/deep-research-procedure.md"
six_categories=("domain-category:integrated-user-scenario" "domain-category:success-criteria" "domain-category:scope-exclusions" "domain-category:constraints" "domain-category:external-dependencies" "domain-category:non-functional-requirements")
check_contains_all "content:step2:harness-plan-categories" "$harness_plan_path" "FAIL" "Restore all six Step 2 domain categories in harness-plan." "${six_categories[@]}"
check_contains_all "content:step2:harness-plan-ask-categories" "$harness_plan_ask_path" "FAIL" "Restore all six Step 2 domain categories in harness-plan-ask." "${six_categories[@]}"
check_contains_all "content:step2:domain-doc-categories" "$step2_domain_path" "FAIL" "Restore all six Step 2 domain categories in step2-domain.md." "${six_categories[@]}"
check_contains_all "content:step2:readability" "$harness_plan_path" "WARN" "Restore the readability self-check in harness-plan." "readability" "short" "headings" "technical terms" "daily workflow"
check_contains_all "content:step2:ask-interactive" "$harness_plan_ask_path" "FAIL" "Ensure harness-plan-ask forces interactive Step 2 behavior." "mode:interactive-forced" "noask-marker-ignored" "six-category-collection"
check_contains_all "content:step2:ux-gate" "$step2_domain_path" "FAIL" "Restore the Step 2 UX gate." "ux-gate" "ux-field:target-surface" "ux-field:before-after" "ux-field:affected-user-scenario" "ux-field:visual-evidence-or-omission-reason"
check_contains_all "content:step2:description-boundary" "$harness_plan_path" "FAIL" "Ensure harness-plan is scoped to /harness Step 2 only." "boundary:harness-step2-only" "boundary:exclude-general-planning" "boundary:exclude-step3-implementation-plan"
check_contains_all "content:step2:noask-evidence" "$harness_plan_path" "FAIL" "Restore noask evidence collection anchors." "evidence:user-request" "evidence:prd" "evidence:architecture" "evidence:adr" "evidence:ui-guide" "evidence:agents-or-claude" "evidence:git-history-5" "evidence:code-search"
check_contains_all "content:step2:output-template" "$harness_plan_path" "FAIL" "Restore Step 2 output template sections." "template-section:requirements-restatement" "template-section:risks" "template-section:open-questions"
check_contains_all "content:step2:research-format" "$harness_plan_path" "FAIL" "Restore deep research output format requirements." "research-field:summary" "research-field:key-findings" "research-field:sources-consulted" "research-field:search-trail" "research-field:stop-reason" "research-field:research-date" "research-field:step2-impact" "research-field:inferred"
check_contains_all "content:deep-research:command-format" "$deep_research_command_path" "FAIL" "Restore deep research command output format requirements." "research-field:summary" "research-field:key-findings" "research-field:sources-consulted" "research-field:search-trail" "research-field:stop-reason" "research-field:research-date" "research-field:step2-impact" "research-field:inferred"
check_contains_all "content:deep-research:procedure-format" "$deep_research_procedure_path" "FAIL" "Restore deep research procedure output format requirements." "research-field:summary" "research-field:key-findings" "research-field:sources-consulted" "research-field:search-trail" "research-field:stop-reason" "research-field:research-date" "research-field:step2-impact" "research-field:inferred"
check_contains_all "content:step2:ux-keywords" "$step2_domain_path" "FAIL" "Restore expanded UX keyword coverage." "ux-keyword:screen" "ux-keyword:button" "ux-keyword:menu" "ux-keyword:layout" "ux-keyword:accessibility" "ux-keyword:wireframe" "ux-keyword:mockup"
check_contains_all "content:step2:approval-flow" "$step2_domain_path" "FAIL" "Restore Step 2 caller approval flow." "approval-flow:review-draft" "approval-flow:apply-review" "approval-flow:noask-auto-approve" "approval-flow:ask-confirm-approve-revise-cancel" "approval-flow:save-after-approval"

if command -v git >/dev/null 2>&1; then
  add_check "runtime:git" "PASS" "$(git --version 2>/dev/null | head -n 1)" "None"
else
  add_check "runtime:git" "WARN" "git is not available" "Install Git before init/update."
fi

if command -v bash >/dev/null 2>&1; then
  add_check "runtime:bash" "PASS" "${BASH_VERSION:-bash available}" "None"
else
  add_check "runtime:bash" "FAIL" "bash is not available" "Run this script with bash."
fi

target_root="$project_dir"
if command -v git >/dev/null 2>&1 && git -C "$project_dir" rev-parse --git-common-dir >/dev/null 2>&1; then
  common_dir="$(git -C "$project_dir" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)"
  target_root="$(dirname "$common_dir")"
  add_check "project:git-root" "PASS" "$target_root" "None"
else
  add_check "project:git-root" "WARN" "Project is not a git repository" "Use the current directory as Harness target."
fi

for dir in .harness .harness/progress .harness/reviews .harness/results .harness/research; do
  if [ -d "$target_root/$dir" ]; then
    add_check "project:$dir" "PASS" "$target_root/$dir" "None"
  else
    add_check "project:$dir" "WARN" "$target_root/$dir is missing" "Run bootstrap only after user approval."
  fi
done

if [ "$mode" = "update" ]; then
  if [ "$dry_run" -eq 1 ]; then
    add_check "update:portable-sync" "PASS" "DryRun=1; bash checker does not mutate files" "Run PowerShell update mode when you want portable sync applied."
  else
    add_check "update:portable-sync" "WARN" "bash update mode is audit-only" "Use check-harness-setup.ps1 -Mode update for applying portable sync."
  fi
fi

if [ "$check_mirror" -eq 1 ]; then
  claude_harness="$claude_home/skills/harness"
  if [ ! -d "$claude_harness" ]; then
    add_check "mirror:claude-harness" "WARN" "$claude_harness missing" "Skip mirror check or install Claude Harness."
  elif [ ! -d "$harness_dir" ]; then
    add_check "mirror:codex-harness" "FAIL" "$harness_dir missing" "Install Codex Harness."
  else
    while IFS= read -r -d '' file; do
      rel="${file#"$harness_dir"/}"
      other="$claude_harness/$rel"
      if [ ! -f "$other" ]; then
        add_check "mirror:missing-in-claude" "WARN" "$rel" "Review whether Claude mirror should include this file."
      elif ! cmp -s "$file" "$other"; then
        add_check "mirror:content-drift" "WARN" "$rel" "Review diff before syncing either side."
      fi
    done < <(find "$harness_dir" -type f -not -path '*/.git/*' -print0)
  fi
fi

summary="PASS"
pass_count=0
warn_count=0
fail_count=0
for status in "${checks_status[@]}"; do
  case "$status" in
    PASS) pass_count=$((pass_count + 1)) ;;
    WARN) warn_count=$((warn_count + 1)); [ "$summary" = "PASS" ] && summary="WARN" ;;
    FAIL) fail_count=$((fail_count + 1)); summary="FAIL" ;;
  esac
done

if [ "$json" -eq 1 ]; then
  printf '{"Summary":"%s","CodexHome":"%s","ProjectDir":"%s","HarnessTargetRoot":"%s","Mode":"%s","Counts":{"PASS":%s,"WARN":%s,"FAIL":%s},"Checks":[' \
    "$summary" "$(json_escape "$codex_home")" "$(json_escape "$project_dir")" "$(json_escape "$target_root")" "$(json_escape "$mode")" "$pass_count" "$warn_count" "$fail_count"
  for i in "${!checks_area[@]}"; do
    [ "$i" -gt 0 ] && printf ','
    printf '{"Area":"%s","Status":"%s","Evidence":"%s","Action":"%s"}' \
      "$(json_escape "${checks_area[$i]}")" "$(json_escape "${checks_status[$i]}")" "$(json_escape "${checks_evidence[$i]}")" "$(json_escape "${checks_action[$i]}")"
  done
  printf ']}\n'
else
  printf 'Summary: %s (PASS=%s WARN=%s FAIL=%s)\n' "$summary" "$pass_count" "$warn_count" "$fail_count"
  for i in "${!checks_area[@]}"; do
    printf '[%s] %s - %s\n' "${checks_status[$i]}" "${checks_area[$i]}" "${checks_evidence[$i]}"
  done
fi

[ "$summary" = "FAIL" ] && exit 1
exit 0
