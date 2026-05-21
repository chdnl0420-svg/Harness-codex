param(
    [string]$CodexHome = $env:CODEX_HOME,
    [string]$SkillsDir = "",
    [string]$UpstreamUrl = "https://github.com/chdnl0420-svg/Harness.git",
    [string]$Ref = "main",
    [switch]$KeepTemp,
    [switch]$NoBackup
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($CodexHome)) {
    $CodexHome = Join-Path $HOME ".codex"
}

$codexHomeFull = [System.IO.Path]::GetFullPath($CodexHome)
if ([string]::IsNullOrWhiteSpace($SkillsDir)) {
    $skillsRoot = Join-Path $codexHomeFull "skills"
} elseif ([System.IO.Path]::IsPathRooted($SkillsDir)) {
    $skillsRoot = [System.IO.Path]::GetFullPath($SkillsDir)
} else {
    $skillsRoot = [System.IO.Path]::GetFullPath((Join-Path (Get-Location).Path $SkillsDir))
}

$managedSkillNames = @(
    "harness",
    "harness-plan",
    "harness-plan-ask",
    "harness-review",
    "harness-deep-researcher",
    "harness-customer-user"
)

function Write-Utf8NoBom {
    param(
        [Parameter(Mandatory=$true)][string]$Path,
        [Parameter(Mandatory=$true)][string]$Text
    )
    $parent = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($parent)) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Text, $utf8)
}

function Read-PortableText {
    param([Parameter(Mandatory=$true)][string]$Path)
    $bytes = [System.IO.File]::ReadAllBytes($Path)
    $strictUtf8 = New-Object System.Text.UTF8Encoding($false, $true)
    try {
        return $strictUtf8.GetString($bytes)
    } catch {
        return [System.Text.Encoding]::GetEncoding(949).GetString($bytes)
    }
}

function Copy-ExactFile {
    param(
        [Parameter(Mandatory=$true)][string]$Source,
        [Parameter(Mandatory=$true)][string]$Destination
    )
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Destination) | Out-Null
    Copy-Item -LiteralPath $Source -Destination $Destination -Force
}

function Convert-ToCodexText {
    param([Parameter(Mandatory=$true)][string]$Text)

    $result = $Text
    $replacements = [ordered]@{
        "~/.claude" = "~/.codex"
        ".claude" = ".codex"
        "CLAUDE.md" = "AGENTS.md"
        "메인 Claude" = "호출자 Codex"
        "main Claude" = "caller Codex"
        "Claude Code" = "Codex"
        "AskUserQuestion" = "request_user_input 또는 일반 질문"
        "mcp__Claude" = "Codex Browser/Playwright/E2E"
        "Claude Preview" = "Codex Browser/Playwright/E2E"
        "Claude_in_Chrome" = "Codex Browser"
        "Claude_Preview" = "Codex Browser"
        "Task 도구" = "사용 가능한 helper/sub-agent 도구"
        "Skill 도구" = "Codex skill"
        "Skill tool" = "Codex skill"
        "project-claude.md" = "project-agents.md"
    }

    foreach ($key in $replacements.Keys) {
        $result = $result.Replace($key, $replacements[$key])
    }

    $result = $result -replace 'Task\(', '사용 가능한 helper/sub-agent 호출 또는 호출자 Codex 직접 수행('
    $result = $result -replace 'agent_type=', 'role='
    $result = $result -replace 'agent_type\s*=\s*"([^"]+)"', 'role="$1"'
    $result = $result -replace 'agent_type\s*:\s*"([^"]+)"', 'role: "$1"'
    $result = $result -replace 'subagent_type=', 'role='
    $result = $result -replace 'subagent_type\s*=\s*"([^"]+)"', 'role="$1"'
    $result = $result -replace 'sub-agent 컨텍스트', 'helper/sub-agent 컨텍스트'
    $result = $result -replace 'agent 가 작성한', 'helper 또는 호출자 Codex가 작성한'
    $result = $result -replace 'agent가 작성한', 'helper 또는 호출자 Codex가 작성한'
    $result = $result.Replace("../agents/codex-reviewer.md", "procedures/codex-review-procedure.md")
    $result = $result.Replace("../../../commands/harness-review.md", "../procedures/codex-review-procedure.md")
    $result = $result.Replace("../harness/agents/codex-reviewer.md", "../harness/docs/procedures/codex-review-procedure.md")
    $result = $result.Replace("../harness/agents/harness-customer-user.md", "../harness/docs/procedures/customer-test-procedure.md")
    $result = $result.Replace("../harness/agents/harness-deep-researcher.md", "../harness/docs/procedures/deep-research-procedure.md")
    $result = $result.Replace("~/.codex/commands/harness-ask.md", "/harness-ask")
    $result = $result.Replace("commands/harness-review.md", "harness-review skill")
    $result = $result.Replace("commands/harness.md", "harness skill")
    $result = $result.Replace("agents/codex-reviewer.md", "codex-review-procedure.md")
    return $result
}

function Convert-ProgressTemplate {
    param([Parameter(Mandatory=$true)][string]$Text)
    $result = Convert-ToCodexText $Text
    $result = $result.Replace("current_phase", "current_step")
    $result = $result.Replace("Phase 1-5", "Step 1-8 + Complete")
    $result = $result.Replace("phase", "step")
    $result = $result.Replace("Phase", "Step")
    return $result
}

function Get-CustomBootstrap {
@'
#!/bin/bash
# bootstrap-runtime.sh - initialize Harness output directories for Codex.
#
# Usage:
#   bash bootstrap-runtime.sh [PROJECT_DIR]

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

seed_doc "$SKILL_DIR/templates/project-agents.md" "$HARNESS_PROJECT_DIR/AGENTS.md" "AGENTS.md"

echo "HARNESS_PROJECT_DIR=$HARNESS_PROJECT_DIR"
echo "HARNESS_DIR=$HARNESS_PROJECT_DIR/.harness"

exit 0
'@
}

function Add-Record {
    param(
        [System.Collections.Generic.List[object]]$List,
        [string]$Category,
        [string]$Source,
        [string]$Destination,
        [string]$Action,
        [string]$Reason = ""
    )
    $List.Add([pscustomobject]@{
        category = $Category
        source = $Source
        destination = $Destination
        action = $Action
        reason = $Reason
    }) | Out-Null
}

function Install-FileToStage {
    param(
        [string]$SourceRoot,
        [string]$StageRoot,
        [string]$SourceRel,
        [string]$DestRel,
        [string]$Category,
        [string]$Transform,
        [System.Collections.Generic.List[object]]$Records
    )

    $source = Join-Path $SourceRoot $SourceRel
    if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
        throw "Missing upstream file: $SourceRel"
    }

    $dest = Join-Path $StageRoot $DestRel
    if ($Transform -eq "exact") {
        Copy-ExactFile -Source $source -Destination $dest
    } else {
        $text = Read-PortableText $source
        if ($Transform -eq "progress") {
            $text = Convert-ProgressTemplate $text
        } else {
            $text = Convert-ToCodexText $text
        }
        Write-Utf8NoBom -Path $dest -Text $text
    }

    Add-Record -List $Records -Category $Category -Source $SourceRel -Destination $DestRel -Action $Transform
}

function Test-ForbiddenStrings {
    param([string]$Root)
    $patterns = @(
        "~/.claude",
        "CLAUDE.md",
        "메인 Claude",
        "AskUserQuestion",
        "mcp__Claude",
        "Claude Preview",
        "Claude_in_Chrome",
        "Claude_Preview",
        "Task 도구",
        "Skill 도구",
        "Skill tool",
        "subagent_type",
        "commands/harness",
        "agents/codex-reviewer",
        "Task\(",
        "agent_type\s*="
    )
    $hits = New-Object System.Collections.Generic.List[object]
    $files = Get-ChildItem -LiteralPath $Root -Recurse -File -Include *.md,*.sh,*.txt -ErrorAction SilentlyContinue
    foreach ($file in $files) {
        $text = Read-PortableText $file.FullName
        foreach ($pattern in $patterns) {
            if ($text -match $pattern) {
                $rel = $file.FullName.Substring($Root.Length).TrimStart("\", "/").Replace("\", "/")
                $hits.Add([pscustomobject]@{ file = $rel; pattern = $pattern }) | Out-Null
            }
        }
    }
    return $hits
}

function Test-MarkdownLinks {
    param([string]$Root)
    $broken = New-Object System.Collections.Generic.List[object]
    $files = Get-ChildItem -LiteralPath $Root -Recurse -File -Include *.md -ErrorAction SilentlyContinue
    foreach ($file in $files) {
        $text = Read-PortableText $file.FullName
        $matches = [regex]::Matches($text, '\[[^\]]+\]\(([^)]+)\)')
        foreach ($match in $matches) {
            $raw = $match.Groups[1].Value.Trim()
            if ($raw -match '^(https?:|mailto:|tel:|ftp:|#|/|~)') { continue }
            $target = ($raw -split '#')[0]
            if ([string]::IsNullOrWhiteSpace($target)) { continue }
            if ($target -match '^[a-zA-Z]+:') { continue }
            $resolved = Join-Path (Split-Path -Parent $file.FullName) $target
            if (-not (Test-Path -LiteralPath $resolved)) {
                $rel = $file.FullName.Substring($Root.Length).TrimStart("\", "/").Replace("\", "/")
                $broken.Add([pscustomobject]@{ file = $rel; link = $raw }) | Out-Null
            }
        }
    }
    return $broken
}

function Write-ClassificationMarkdown {
    param(
        [string]$Path,
        [string]$UpstreamCommit,
        [object[]]$Records,
        [object[]]$Excluded,
        [string]$SkillsRoot
    )

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("# Harness Update Classification") | Out-Null
    $lines.Add("") | Out-Null
    $lines.Add("- Upstream: https://github.com/chdnl0420-svg/Harness") | Out-Null
    $lines.Add("- Commit: ``$UpstreamCommit``") | Out-Null
    $lines.Add("- Target: ``$SkillsRoot``") | Out-Null
    $lines.Add("") | Out-Null

    foreach ($category in @("exact-copy", "minimal-codex-port", "port-required")) {
        $lines.Add("## $category") | Out-Null
        $items = $Records | Where-Object { $_.category -eq $category } | Sort-Object destination
        foreach ($item in $items) {
            $lines.Add("- ``" + $item.source + "`` -> ``" + $item.destination + "`` (" + $item.action + ")") | Out-Null
        }
        $lines.Add("") | Out-Null
    }

    $lines.Add("## excluded") | Out-Null
    foreach ($item in ($Excluded | Sort-Object source)) {
        $lines.Add("- ``" + $item.source + "`` (" + $item.reason + ")") | Out-Null
    }
    $lines.Add("") | Out-Null
    Write-Utf8NoBom -Path $Path -Text ($lines -join [Environment]::NewLine)
}

function Copy-Directory {
    param(
        [string]$Source,
        [string]$Destination
    )
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Destination) | Out-Null
    Copy-Item -LiteralPath $Source -Destination $Destination -Recurse -Force
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "git is required for /harness-update."
}

$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) "harness-update-$stamp"
$cloneRoot = Join-Path $tempRoot "upstream"
$stageRoot = Join-Path $tempRoot "stage-skills"
$reportRoot = Join-Path $codexHomeFull "harness-update-reports"
$backupRoot = Join-Path (Join-Path $codexHomeFull "harness-update-backups") $stamp
$records = New-Object System.Collections.Generic.List[object]
$excluded = New-Object System.Collections.Generic.List[object]

try {
    New-Item -ItemType Directory -Force -Path $stageRoot, $reportRoot | Out-Null

    git clone --depth 1 --branch $Ref $UpstreamUrl $cloneRoot | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "git clone failed: $UpstreamUrl ($Ref)"
    }
    $upstreamCommit = (git -C $cloneRoot rev-parse HEAD).Trim()

    $exactFiles = @(
        @{ s = "LICENSE"; d = "harness/LICENSE" },
        @{ s = "skills/harness/templates/doc-adr.md"; d = "harness/templates/doc-adr.md" },
        @{ s = "skills/harness/templates/doc-architecture.md"; d = "harness/templates/doc-architecture.md" },
        @{ s = "skills/harness/templates/doc-prd.md"; d = "harness/templates/doc-prd.md" },
        @{ s = "skills/harness/templates/doc-ui-guide.md"; d = "harness/templates/doc-ui-guide.md" },
        @{ s = "skills/harness/templates/improvement.md"; d = "harness/templates/improvement.md" }
    )
    foreach ($item in $exactFiles) {
        Install-FileToStage -SourceRoot $cloneRoot -StageRoot $stageRoot -SourceRel $item.s -DestRel $item.d -Category "exact-copy" -Transform "exact" -Records $records
    }

    $minimalFiles = @(
        @{ s = "skills/harness/docs/workflow.md"; d = "harness/docs/workflow.md"; t = "minimal" },
        @{ s = "skills/harness/docs/donot.md"; d = "harness/docs/donot.md"; t = "minimal" },
        @{ s = "skills/harness/docs/html-output-rule.md"; d = "harness/docs/html-output-rule.md"; t = "minimal" },
        @{ s = "skills/harness/docs/test-guide-format.md"; d = "harness/docs/test-guide-format.md"; t = "minimal" },
        @{ s = "skills/harness/docs/procedures/codex-review-procedure.md"; d = "harness/docs/procedures/codex-review-procedure.md"; t = "minimal" },
        @{ s = "skills/harness/docs/procedures/customer-test-procedure.md"; d = "harness/docs/procedures/customer-test-procedure.md"; t = "minimal" },
        @{ s = "skills/harness/docs/procedures/deep-research-procedure.md"; d = "harness/docs/procedures/deep-research-procedure.md"; t = "minimal" },
        @{ s = "skills/harness/agents/learning/README.md"; d = "harness/agents/learning/README.md"; t = "minimal" },
        @{ s = "skills/harness/agents/learning/harness-customer-user.md"; d = "harness/agents/learning/harness-customer-user.md"; t = "minimal" },
        @{ s = "skills/harness/agents/learning/harness-deep-researcher.md"; d = "harness/agents/learning/harness-deep-researcher.md"; t = "minimal" },
        @{ s = "skills/harness/agents/learning/harness-qa-engineer.md"; d = "harness/agents/learning/harness-qa-engineer.md"; t = "minimal" },
        @{ s = "skills/harness/templates/learning-proposal.md"; d = "harness/templates/learning-proposal.md"; t = "minimal" },
        @{ s = "skills/harness/templates/plan.md"; d = "harness/templates/plan.md"; t = "minimal" },
        @{ s = "skills/harness/templates/progress.md"; d = "harness/templates/progress.md"; t = "progress" },
        @{ s = "skills/harness/templates/result.md"; d = "harness/templates/result.md"; t = "minimal" },
        @{ s = "skills/harness/templates/review.md"; d = "harness/templates/review.md"; t = "minimal" },
        @{ s = "skills/harness/templates/project-claude.md"; d = "harness/templates/project-agents.md"; t = "minimal" }
    )
    Get-ChildItem -LiteralPath (Join-Path $cloneRoot "skills/harness/docs/steps") -File -Filter "*.md" |
        Sort-Object Name |
        ForEach-Object {
            $minimalFiles += @{ s = "skills/harness/docs/steps/$($_.Name)"; d = "harness/docs/steps/$($_.Name)"; t = "minimal" }
        }
    foreach ($item in $minimalFiles) {
        Install-FileToStage -SourceRoot $cloneRoot -StageRoot $stageRoot -SourceRel $item.s -DestRel $item.d -Category "minimal-codex-port" -Transform $item.t -Records $records
    }

    $portFiles = @(
        @{ s = "skills/harness/SKILL.md"; d = "harness/SKILL.md" },
        @{ s = "skills/harness-plan/SKILL.md"; d = "harness-plan/SKILL.md" },
        @{ s = "skills/harness-plan-ask/SKILL.md"; d = "harness-plan-ask/SKILL.md" },
        @{ s = "skills/harness-review/SKILL.md"; d = "harness-review/SKILL.md" },
        @{ s = "skills/harness-deep-researcher/SKILL.md"; d = "harness-deep-researcher/SKILL.md" },
        @{ s = "skills/harness-customer-user/SKILL.md"; d = "harness-customer-user/SKILL.md" }
    )
    foreach ($item in $portFiles) {
        Install-FileToStage -SourceRoot $cloneRoot -StageRoot $stageRoot -SourceRel $item.s -DestRel $item.d -Category "port-required" -Transform "minimal" -Records $records
    }

    Write-Utf8NoBom -Path (Join-Path $stageRoot "harness/core/bootstrap-runtime.sh") -Text (Get-CustomBootstrap)
    Add-Record -List $records -Category "port-required" -Source "skills/harness/core/bootstrap-runtime.sh" -Destination "harness/core/bootstrap-runtime.sh" -Action "custom-codex-port" -Reason "Limit runtime bootstrap to .harness output dirs and AGENTS.md seed."

    $allUpstream = Get-ChildItem -LiteralPath $cloneRoot -Recurse -File |
        Where-Object { $_.FullName -notmatch "\\.git\\" } |
        ForEach-Object { $_.FullName.Substring($cloneRoot.Length + 1).Replace("\", "/") }
    $installedSources = @{}
    foreach ($record in $records) { $installedSources[$record.source] = $true }
    foreach ($rel in ($allUpstream | Sort-Object)) {
        if (-not $installedSources.ContainsKey($rel)) {
            $reason = "not part of Codex runtime surface"
            if ($rel -like "commands/*") { $reason = "Claude Code slash command file; not consumed directly by Codex" }
            elseif ($rel -eq "README.md") { $reason = "distribution documentation; not runtime" }
            elseif ($rel -like "skills/harness/agents/*.md") { $reason = "user-level agent registry file; helper skills/procedures are used instead" }
            elseif ($rel -in @("skills/harness/.version", "skills/harness/.gitattributes", ".gitignore")) { $reason = "upstream metadata; Codex package owns generated metadata" }
            $excluded.Add([pscustomobject]@{ source = $rel; reason = $reason }) | Out-Null
        }
    }

    $forbidden = @(Test-ForbiddenStrings -Root $stageRoot)
    $brokenLinks = @(Test-MarkdownLinks -Root $stageRoot)
    $bashCheck = "not-run"
    if (Get-Command bash -ErrorAction SilentlyContinue) {
        $bootstrap = Join-Path $stageRoot "harness/core/bootstrap-runtime.sh"
        $wslPath = $bootstrap
        if ($bootstrap -match '^([A-Za-z]):\\(.+)$') {
            $drive = $matches[1].ToLowerInvariant()
            $rest = $matches[2].Replace('\','/')
            $wslPath = "/mnt/$drive/$rest"
        }
        bash -n "$wslPath"
        $bashCheck = if ($LASTEXITCODE -eq 0) { "ok" } else { "failed:$LASTEXITCODE" }
    }

    if ($forbidden.Count -gt 0 -or $brokenLinks.Count -gt 0 -or $bashCheck -like "failed:*") {
        $failedReport = [pscustomobject]@{
            generated_at = (Get-Date).ToString("yyyy-MM-ddTHH:mm:sszzz")
            status = "failed-before-global-install"
            upstream_url = $UpstreamUrl
            upstream_ref = $Ref
            upstream_commit = $upstreamCommit
            skills_root = $skillsRoot
            forbidden_hits = $forbidden
            broken_links = $brokenLinks
            bash_n_bootstrap = $bashCheck
        }
        Write-Utf8NoBom -Path (Join-Path $reportRoot "failed-$stamp.json") -Text ($failedReport | ConvertTo-Json -Depth 8)
        throw "Staged Harness port failed validation. See $reportRoot\failed-$stamp.json"
    }

    New-Item -ItemType Directory -Force -Path $skillsRoot | Out-Null
    $existing = New-Object System.Collections.Generic.List[string]
    foreach ($name in $managedSkillNames) {
        $path = Join-Path $skillsRoot $name
        if (Test-Path -LiteralPath $path) { $existing.Add($path) | Out-Null }
    }
    Get-ChildItem -LiteralPath $skillsRoot -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -like "ecc-command-harness*" } |
        ForEach-Object { $existing.Add($_.FullName) | Out-Null }

    if ($existing.Count -gt 0 -and -not $NoBackup) {
        New-Item -ItemType Directory -Force -Path $backupRoot | Out-Null
        foreach ($path in $existing) {
            Move-Item -LiteralPath $path -Destination (Join-Path $backupRoot (Split-Path -Leaf $path))
        }
    } else {
        foreach ($path in $existing) {
            Remove-Item -LiteralPath $path -Recurse -Force
        }
    }

    foreach ($name in $managedSkillNames) {
        Copy-Directory -Source (Join-Path $stageRoot $name) -Destination (Join-Path $skillsRoot $name)
    }

    $classificationPath = Join-Path $reportRoot "classification-$stamp.md"
    Write-ClassificationMarkdown -Path $classificationPath -UpstreamCommit $upstreamCommit -Records $records.ToArray() -Excluded $excluded.ToArray() -SkillsRoot $skillsRoot

    $report = [pscustomobject]@{
        generated_at = (Get-Date).ToString("yyyy-MM-ddTHH:mm:sszzz")
        status = "installed"
        upstream_url = $UpstreamUrl
        upstream_ref = $Ref
        upstream_commit = $upstreamCommit
        codex_home = $codexHomeFull
        skills_root = $skillsRoot
        backup_root = if ($existing.Count -gt 0 -and -not $NoBackup) { $backupRoot } else { "" }
        classification = $classificationPath
        counts = [pscustomobject]@{
            exact_copy = @($records | Where-Object { $_.category -eq "exact-copy" }).Count
            minimal_codex_port = @($records | Where-Object { $_.category -eq "minimal-codex-port" }).Count
            port_required = @($records | Where-Object { $_.category -eq "port-required" }).Count
            excluded = $excluded.Count
            forbidden_hits = $forbidden.Count
            broken_links = $brokenLinks.Count
        }
        bash_n_bootstrap = $bashCheck
        installed_skill_names = $managedSkillNames
        installed = $records
        excluded = $excluded
    }
    $reportPath = Join-Path $reportRoot "update-$stamp.json"
    Write-Utf8NoBom -Path $reportPath -Text ($report | ConvertTo-Json -Depth 8)

    Write-Output "harness-update complete"
    Write-Output "skills_root=$skillsRoot"
    Write-Output "upstream_commit=$upstreamCommit"
    Write-Output "exact_copy=$($report.counts.exact_copy)"
    Write-Output "minimal_codex_port=$($report.counts.minimal_codex_port)"
    Write-Output "port_required=$($report.counts.port_required)"
    Write-Output "excluded=$($report.counts.excluded)"
    Write-Output "forbidden_hits=$($report.counts.forbidden_hits)"
    Write-Output "broken_links=$($report.counts.broken_links)"
    Write-Output "bash_n_bootstrap=$bashCheck"
    Write-Output "report=$reportPath"
    Write-Output "classification=$classificationPath"
} finally {
    if (-not $KeepTemp -and (Test-Path -LiteralPath $tempRoot)) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}
