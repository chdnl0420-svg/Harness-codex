param(
    [string]$CodexHome = $env:CODEX_HOME,
    [string]$UpstreamUrl = "",
    [string]$Branch = "main",
    [switch]$Apply,
    [switch]$KeepTemp,
    [switch]$Json
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($CodexHome)) {
    $CodexHome = Join-Path $HOME ".codex"
}

$skillsDir = Join-Path $CodexHome "skills"
$harnessDir = Join-Path $skillsDir "harness"
$versionPath = Join-Path $harnessDir ".version"

function Read-VersionValue {
    param(
        [string]$Text,
        [string]$Name
    )

    $match = [regex]::Match($Text, ("(?m)^" + [regex]::Escape($Name) + "\s*:\s*(.+?)\s*$"))
    if ($match.Success) {
        return $match.Groups[1].Value.Trim()
    }
    return ""
}

function Write-VersionValue {
    param(
        [string]$Text,
        [string]$Name,
        [string]$Value
    )

    $line = "$Name`: $Value"
    if ($Text -match ("(?m)^" + [regex]::Escape($Name) + "\s*:")) {
        return [regex]::Replace($Text, ("(?m)^" + [regex]::Escape($Name) + "\s*:.*$"), $line)
    }
    return ($Text.TrimEnd() + [Environment]::NewLine + $line + [Environment]::NewLine)
}

function Get-RelativeFiles {
    param([string]$Root)

    $rootFull = [System.IO.Path]::GetFullPath((Resolve-Path -LiteralPath $Root).Path).TrimEnd("\", "/")
    Get-ChildItem -LiteralPath $Root -Recurse -File |
        Where-Object { $_.FullName -notmatch "\\\.git\\" } |
        ForEach-Object {
            $full = [System.IO.Path]::GetFullPath($_.FullName)
            $rel = $full.Substring($rootFull.Length).TrimStart("\", "/").Replace("\", "/")
            [pscustomobject]@{ Relative = $rel; FullName = $_.FullName }
        }
}

function Read-PortableText {
    param([string]$Path)

    $bytes = [System.IO.File]::ReadAllBytes($Path)
    $strictUtf8 = New-Object System.Text.UTF8Encoding -ArgumentList $false, $true
    try {
        return $strictUtf8.GetString($bytes)
    }
    catch {
        return [System.Text.Encoding]::GetEncoding(949).GetString($bytes)
    }
}

function Write-Utf8NoBom {
    param(
        [string]$Path,
        [string]$Text
    )

    $utf8NoBom = New-Object System.Text.UTF8Encoding -ArgumentList $false
    [System.IO.File]::WriteAllText($Path, $Text, $utf8NoBom)
}

function Test-ForbiddenText {
    param([string]$Path)

    $text = Read-PortableText $Path
    if ($null -eq $text) {
        $text = ""
    }
    $patterns = @(
        ("~/" + ".claude"),
        ("AskUser" + "Question"),
        ("CLAUDE" + "_COMMAND"),
        ("--" + "noagent"),
        ("." + "noagent"),
        ("harness/skills/" + "harness"),
        ("PROJECT_WSL" + "_PATH"),
        ("." + "claude/worktrees"),
        (([string][char]0xBA54) + ([string][char]0xC778) + " " + "Claude"),
        ("main " + "Claude"),
        ("claude-" + "fallback"),
        ("Claude " + "main"),
        ("Claude " + "Max"),
        ("Claude " + "code-reviewer")
    )

    foreach ($pattern in $patterns) {
        if ($text.Contains($pattern)) {
            return $pattern
        }
    }
    return ""
}

function Test-PortablePath {
    param([string]$Relative)

    $portableRegexes = @(
        "^templates/(improvement|learning-proposal)\.md$",
        "^docs/(context-layer|examples|file-formats|phases|stop-report|test-guide-format)\.md$"
    )

    foreach ($regex in $portableRegexes) {
        if ($Relative -match $regex) {
            return $true
        }
    }
    return $false
}

function Find-HarnessRoot {
    param([string]$CloneRoot)

    $candidates = @(
        $CloneRoot,
        (Join-Path $CloneRoot "skills\harness"),
        (Join-Path $CloneRoot "harness")
    )

    foreach ($candidate in $candidates) {
        if (
            (Test-Path -LiteralPath (Join-Path $candidate "SKILL.md") -PathType Leaf) -and
            (Test-Path -LiteralPath (Join-Path $candidate "docs") -PathType Container) -and
            (Test-Path -LiteralPath (Join-Path $candidate "templates") -PathType Container)
        ) {
            return $candidate
        }
    }

    throw "Could not locate Harness root in cloned upstream."
}

function Copy-WithBackup {
    param(
        [string]$Source,
        [string]$Destination,
        [string]$BackupRoot
    )

    if (Test-Path -LiteralPath $Destination -PathType Leaf) {
        $relative = $Destination.Substring($harnessDir.Length).TrimStart("\", "/")
        $backupPath = Join-Path $BackupRoot $relative
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $backupPath) | Out-Null
        Copy-Item -LiteralPath $Destination -Destination $backupPath -Force
    }

    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Destination) | Out-Null
    Write-Utf8NoBom -Path $Destination -Text (Read-PortableText $Source)
}

if (-not (Test-Path -LiteralPath $harnessDir -PathType Container)) {
    throw "Codex Harness directory not found: $harnessDir"
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "git is not available."
}

if ([string]::IsNullOrWhiteSpace($UpstreamUrl)) {
    if (Test-Path -LiteralPath $versionPath -PathType Leaf) {
        $versionText = Get-Content -Raw -Encoding UTF8 -LiteralPath $versionPath
        $UpstreamUrl = Read-VersionValue $versionText "upstream_reference"
        if ([string]::IsNullOrWhiteSpace($UpstreamUrl)) {
            $UpstreamUrl = Read-VersionValue $versionText "source"
        }
    }
}

if ([string]::IsNullOrWhiteSpace($UpstreamUrl)) {
    throw "Missing upstream URL. Set upstream_reference in $versionPath or pass -UpstreamUrl."
}

$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) "codex-harness-upstream-$stamp"
$reportRoot = Join-Path $CodexHome "harness-update-reports"
$backupRoot = Join-Path $CodexHome "harness-update-backups\$stamp"
New-Item -ItemType Directory -Force -Path $reportRoot | Out-Null

$applied = New-Object System.Collections.Generic.List[object]
$planned = New-Object System.Collections.Generic.List[object]
$skipped = New-Object System.Collections.Generic.List[object]
$needsPort = New-Object System.Collections.Generic.List[object]

try {
    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        & git clone --depth 1 --branch $Branch $UpstreamUrl $tempRoot *> $null
        $cloneExitCode = $LASTEXITCODE
    } finally {
        $ErrorActionPreference = $oldPreference
    }
    if ($cloneExitCode -ne 0) {
        throw "git clone failed with exit code $cloneExitCode. Upstream=$UpstreamUrl Branch=$Branch"
    }

    $upstreamCommit = (& git -C $tempRoot rev-parse HEAD).Trim()
    $sourceHarness = Find-HarnessRoot $tempRoot
    $files = Get-RelativeFiles $sourceHarness

    foreach ($file in $files) {
        $rel = $file.Relative

        if ($rel -eq ".version" -or $rel -eq ".gitattributes" -or $rel -eq "SKILL.md") {
            $needsPort.Add([pscustomobject]@{ Path = $rel; Reason = "Codex-owned metadata or entrypoint" }) | Out-Null
            continue
        }

        if ($rel -like "core/*" -or $rel -like "agents/*" -or $rel -like "docs/steps/*" -or $rel -like "docs/procedures/*") {
            $needsPort.Add([pscustomobject]@{ Path = $rel; Reason = "Codex-specific workflow surface; manual port required" }) | Out-Null
            continue
        }

        if ($rel -in @("docs/setup.md", "docs/workflow.md", "docs/donot.md", "docs/html-output-rule.md", "docs/environment-map.md")) {
            $needsPort.Add([pscustomobject]@{ Path = $rel; Reason = "Codex policy document; manual port required" }) | Out-Null
            continue
        }

        $projectClaudeTemplate = "templates/project-" + "claude.md"
        if ($rel -eq $projectClaudeTemplate -or $rel -eq "templates/project-agents.md" -or $rel -eq "templates/project-dual-bridge.md") {
            $needsPort.Add([pscustomobject]@{ Path = $rel; Reason = "Project instruction template differs by runtime" }) | Out-Null
            continue
        }

        if (-not (Test-PortablePath $rel)) {
            $needsPort.Add([pscustomobject]@{ Path = $rel; Reason = "No automatic Codex port rule" }) | Out-Null
            continue
        }

        if ([string]::IsNullOrWhiteSpace((Read-PortableText $file.FullName))) {
            $needsPort.Add([pscustomobject]@{ Path = $rel; Reason = "Upstream portable file is empty; keep Codex local content" }) | Out-Null
            continue
        }

        $forbidden = Test-ForbiddenText $file.FullName
        if (-not [string]::IsNullOrWhiteSpace($forbidden)) {
            $needsPort.Add([pscustomobject]@{ Path = $rel; Reason = "Contains non-Codex marker: $forbidden" }) | Out-Null
            continue
        }

        $destination = Join-Path $harnessDir ($rel.Replace("/", "\"))
        $changed = $true
        if (Test-Path -LiteralPath $destination -PathType Leaf) {
            $sourceHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $file.FullName).Hash
            $destHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $destination).Hash
            $changed = ($sourceHash -ne $destHash)
        }

        if (-not $changed) {
            $skipped.Add([pscustomobject]@{ Path = $rel; Reason = "Already current" }) | Out-Null
            continue
        }

        if ($Apply) {
            Copy-WithBackup -Source $file.FullName -Destination $destination -BackupRoot $backupRoot
            $applied.Add([pscustomobject]@{ Path = $rel; Action = "copied"; BackupRoot = $backupRoot }) | Out-Null
        } else {
            $planned.Add([pscustomobject]@{ Path = $rel; Action = "would-copy" }) | Out-Null
        }
    }

    if ($Apply) {
        $versionText = if (Test-Path -LiteralPath $versionPath -PathType Leaf) { Get-Content -Raw -Encoding UTF8 -LiteralPath $versionPath } else { "" }
        $versionText = Write-VersionValue $versionText "port" "codex-local"
        $versionText = Write-VersionValue $versionText "upstream_reference" $UpstreamUrl
        $versionText = Write-VersionValue $versionText "upstream_commit" $upstreamCommit
        $versionText = Write-VersionValue $versionText "upstream_branch" $Branch
        $versionText = Write-VersionValue $versionText "update_policy" "portable-auto-sync-plus-manual-port"
        $versionText = Write-VersionValue $versionText "last_update_check" (Get-Date).ToString("s")
        $versionText = Write-VersionValue $versionText "last_portable_sync_applied" ([string]$applied.Count)
        Write-Utf8NoBom -Path $versionPath -Text $versionText
    }

    $result = [pscustomobject]@{
        Apply = [bool]$Apply
        UpstreamUrl = $UpstreamUrl
        Branch = $Branch
        UpstreamCommit = $upstreamCommit
        SourceHarness = $sourceHarness
        HarnessDir = $harnessDir
        Applied = $applied
        Planned = $planned
        Skipped = $skipped
        NeedsManualPort = $needsPort
        ReportPath = ""
        BackupRoot = if ($Apply -and $applied.Count -gt 0) { $backupRoot } else { "" }
    }

    $reportPath = Join-Path $reportRoot "sync-$stamp.json"
    $result.ReportPath = $reportPath
    Write-Utf8NoBom -Path $reportPath -Text ($result | ConvertTo-Json -Depth 6)

    if ($Json) {
        $result | ConvertTo-Json -Depth 6
    } else {
        "Apply: $($result.Apply)"
        "Upstream: $UpstreamUrl#$Branch @ $upstreamCommit"
        "Applied: $($applied.Count)"
        "Planned: $($planned.Count)"
        "Skipped: $($skipped.Count)"
        "NeedsManualPort: $($needsPort.Count)"
        "Report: $reportPath"
        if ($result.BackupRoot) {
            "Backup: $($result.BackupRoot)"
        }
    }
} catch {
    $errorMessage = $_.Exception.Message
    if ([string]::IsNullOrWhiteSpace($errorMessage)) {
        $errorMessage = ($_ | Out-String).Trim()
    }

    $result = [pscustomobject]@{
        Apply = [bool]$Apply
        Status = "BLOCKED"
        Error = $errorMessage
        UpstreamUrl = $UpstreamUrl
        Branch = $Branch
        UpstreamCommit = ""
        SourceHarness = ""
        HarnessDir = $harnessDir
        Applied = @()
        Planned = @()
        Skipped = @()
        NeedsManualPort = @()
        ReportPath = ""
        BackupRoot = ""
    }

    try {
        $reportPath = Join-Path $reportRoot "sync-$stamp-blocked.json"
        $result.ReportPath = $reportPath
        Write-Utf8NoBom -Path $reportPath -Text ($result | ConvertTo-Json -Depth 6)
    } catch {
        # A blocked update should still return structured output when report writing fails.
    }

    if ($Json) {
        $result | ConvertTo-Json -Depth 6
    } else {
        "Status: BLOCKED"
        "Apply: $($result.Apply)"
        "Upstream: $UpstreamUrl#$Branch"
        "Error: $errorMessage"
        if ($result.ReportPath) {
            "Report: $($result.ReportPath)"
        }
    }

    exit 2
} finally {
    if (-not $KeepTemp -and (Test-Path -LiteralPath $tempRoot)) {
        try {
            Remove-Item -LiteralPath $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
        } catch {
            # Cleanup failure should not invalidate the sync report.
        }
    }
}
