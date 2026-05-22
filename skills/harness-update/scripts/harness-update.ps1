param(
    [string]$CodexHome = $env:CODEX_HOME,
    [string]$UpstreamUrl = "https://github.com/chdnl0420-svg/Harness-Codex.git",
    [string]$Ref = "main",
    [string]$SourcePath = "",
    [switch]$KeepTemp,
    [switch]$NoBackup
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($CodexHome)) {
    $CodexHome = Join-Path $HOME ".codex"
}

$codexHomeFull = [System.IO.Path]::GetFullPath($CodexHome)
$skillsRoot = Join-Path $codexHomeFull "skills"
$agentsRoot = Join-Path $codexHomeFull "agents"
$reportRoot = Join-Path $codexHomeFull "harness-update-reports"

$legacySkillNames = @(
    "harness",
    "harness-plan",
    "harness-plan-ask",
    "harness-review",
    "harness-deep-researcher",
    "harness-customer-user",
    "harness-update"
)

$legacyAgentNames = @(
    "codex-reviewer",
    "harness-customer-user",
    "harness-deep-researcher",
    "harness-qa-engineer"
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

function Copy-Directory {
    param(
        [Parameter(Mandatory=$true)][string]$Source,
        [Parameter(Mandatory=$true)][string]$Destination
    )

    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Destination) | Out-Null
    Copy-Item -LiteralPath $Source -Destination $Destination -Recurse -Force
}

function Copy-File {
    param(
        [Parameter(Mandatory=$true)][string]$Source,
        [Parameter(Mandatory=$true)][string]$Destination
    )

    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Destination) | Out-Null
    Copy-Item -LiteralPath $Source -Destination $Destination -Force
}

function Move-Or-RemoveExisting {
    param(
        [Parameter(Mandatory=$true)][string[]]$Paths,
        [Parameter(Mandatory=$true)][string]$BackupRoot,
        [switch]$NoBackup
    )

    $handled = New-Object System.Collections.Generic.List[object]

    foreach ($path in ($Paths | Select-Object -Unique)) {
        if (-not (Test-Path -LiteralPath $path)) {
            continue
        }

        if ($NoBackup) {
            Remove-Item -LiteralPath $path -Recurse -Force
            $action = "removed"
            $backupPath = ""
        } else {
            New-Item -ItemType Directory -Force -Path $BackupRoot | Out-Null
            $backupPath = Join-Path $BackupRoot (Split-Path -Leaf $path)
            Move-Item -LiteralPath $path -Destination $backupPath
            $action = "backed-up"
        }

        $handled.Add([pscustomobject]@{
            path = $path
            action = $action
            backup_path = $backupPath
        }) | Out-Null
    }

    return $handled
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "git is required for /harness-update."
}

$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) "harness-codex-update-$stamp"
$backupRoot = Join-Path (Join-Path $codexHomeFull "harness-update-backups") $stamp
$sourceRoot = ""
$sourceKind = ""

try {
    New-Item -ItemType Directory -Force -Path $reportRoot | Out-Null

    if (-not [string]::IsNullOrWhiteSpace($SourcePath)) {
        $sourceRoot = [System.IO.Path]::GetFullPath($SourcePath)
        if (-not (Test-Path -LiteralPath $sourceRoot -PathType Container)) {
            throw "SourcePath does not exist: $sourceRoot"
        }
        $sourceKind = "local"
    } else {
        New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null
        $sourceRoot = Join-Path $tempRoot "Harness-Codex"
        git clone --depth 1 --branch $Ref $UpstreamUrl $sourceRoot | Out-Null
        if ($LASTEXITCODE -ne 0) {
            throw "git clone failed: $UpstreamUrl ($Ref)"
        }
        $sourceKind = "git"
    }

    $sourceSkillsRoot = Join-Path $sourceRoot "skills"
    $sourceAgentsRoot = Join-Path $sourceRoot "agents"

    if (-not (Test-Path -LiteralPath $sourceSkillsRoot -PathType Container)) {
        throw "Harness-Codex source is missing skills/: $sourceSkillsRoot"
    }

    $skillDirs = @(Get-ChildItem -LiteralPath $sourceSkillsRoot -Directory | Sort-Object Name)
    if ($skillDirs.Count -eq 0) {
        throw "Harness-Codex source has no skill directories under skills/."
    }

    foreach ($skillDir in $skillDirs) {
        $skillFile = Join-Path $skillDir.FullName "SKILL.md"
        if (-not (Test-Path -LiteralPath $skillFile -PathType Leaf)) {
            throw "Skill directory is missing SKILL.md: $($skillDir.FullName)"
        }
    }

    $agentFiles = @()
    if (Test-Path -LiteralPath $sourceAgentsRoot -PathType Container) {
        $agentFiles = @(Get-ChildItem -LiteralPath $sourceAgentsRoot -File -Filter "*.md" | Sort-Object Name)
    }

    $sourceCommit = "unknown"
    if (Test-Path -LiteralPath (Join-Path $sourceRoot ".git") -PathType Container) {
        $sourceCommit = (git -C $sourceRoot rev-parse HEAD).Trim()
    }

    New-Item -ItemType Directory -Force -Path $skillsRoot, $agentsRoot | Out-Null

    $skillNames = @($skillDirs | ForEach-Object { $_.Name })
    $agentNames = @($agentFiles | ForEach-Object { [System.IO.Path]::GetFileNameWithoutExtension($_.Name) })

    $skillPathsToReplace = New-Object System.Collections.Generic.List[string]
    foreach ($name in (($legacySkillNames + $skillNames) | Select-Object -Unique)) {
        $path = Join-Path $skillsRoot $name
        if (Test-Path -LiteralPath $path) {
            $skillPathsToReplace.Add($path) | Out-Null
        }
    }
    Get-ChildItem -LiteralPath $skillsRoot -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -like "ecc-command-harness*" } |
        ForEach-Object { $skillPathsToReplace.Add($_.FullName) | Out-Null }

    $agentPathsToReplace = New-Object System.Collections.Generic.List[string]
    foreach ($name in (($legacyAgentNames + $agentNames) | Select-Object -Unique)) {
        $path = Join-Path $agentsRoot "$name.md"
        if (Test-Path -LiteralPath $path) {
            $agentPathsToReplace.Add($path) | Out-Null
        }
    }

    $backedUpSkills = @()
    if ($skillPathsToReplace.Count -gt 0) {
        $backedUpSkills = @(Move-Or-RemoveExisting -Paths $skillPathsToReplace.ToArray() -BackupRoot $backupRoot -NoBackup:$NoBackup)
    }
    $agentBackupRoot = Join-Path $backupRoot "agents"
    $backedUpAgents = @()
    if ($agentPathsToReplace.Count -gt 0) {
        $backedUpAgents = @(Move-Or-RemoveExisting -Paths $agentPathsToReplace.ToArray() -BackupRoot $agentBackupRoot -NoBackup:$NoBackup)
    }

    foreach ($skillDir in $skillDirs) {
        Copy-Directory -Source $skillDir.FullName -Destination (Join-Path $skillsRoot $skillDir.Name)
    }

    foreach ($agentFile in $agentFiles) {
        Copy-File -Source $agentFile.FullName -Destination (Join-Path $agentsRoot $agentFile.Name)
    }

    $report = [pscustomobject]@{
        generated_at = (Get-Date).ToString("yyyy-MM-ddTHH:mm:sszzz")
        status = "installed"
        source_kind = $sourceKind
        upstream_url = $UpstreamUrl
        ref = $Ref
        source_path = $sourceRoot
        source_commit = $sourceCommit
        codex_home = $codexHomeFull
        skills_root = $skillsRoot
        agents_root = $agentsRoot
        backup_root = if (($backedUpSkills.Count -gt 0 -or $backedUpAgents.Count -gt 0) -and -not $NoBackup) { $backupRoot } else { "" }
        installed_skill_names = $skillNames
        installed_agent_names = $agentNames
        replaced_skills = $backedUpSkills
        replaced_agents = $backedUpAgents
        counts = [pscustomobject]@{
            installed_skills = $skillNames.Count
            installed_agents = $agentNames.Count
            replaced_skills = $backedUpSkills.Count
            replaced_agents = $backedUpAgents.Count
        }
    }

    $reportPath = Join-Path $reportRoot "update-$stamp.json"
    Write-Utf8NoBom -Path $reportPath -Text ($report | ConvertTo-Json -Depth 8)

    Write-Output "harness-update complete"
    Write-Output "source_kind=$sourceKind"
    Write-Output "upstream_url=$UpstreamUrl"
    Write-Output "ref=$Ref"
    Write-Output "source_commit=$sourceCommit"
    Write-Output "skills_root=$skillsRoot"
    Write-Output "agents_root=$agentsRoot"
    Write-Output "installed_skills=$($skillNames -join ',')"
    Write-Output "installed_agents=$($agentNames -join ',')"
    Write-Output "replaced_skills=$($backedUpSkills.Count)"
    Write-Output "replaced_agents=$($backedUpAgents.Count)"
    Write-Output "backup_root=$($report.backup_root)"
    Write-Output "report=$reportPath"
} finally {
    if (-not $KeepTemp -and [string]::IsNullOrWhiteSpace($SourcePath) -and (Test-Path -LiteralPath $tempRoot)) {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}
