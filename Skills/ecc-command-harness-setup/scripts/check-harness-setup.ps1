param(
    [string]$ProjectDir = (Get-Location).Path,
    [ValidateSet("audit", "init", "update")]
    [string]$Mode = "audit",
    [switch]$CheckMirror,
    [switch]$DryRun,
    [switch]$Json
)

$ErrorActionPreference = "Stop"

$checks = New-Object System.Collections.Generic.List[object]

function Add-Check {
    param(
        [string]$Area,
        [ValidateSet("PASS", "WARN", "FAIL")]
        [string]$Status,
        [string]$Evidence,
        [string]$Action
    )

    $checks.Add([pscustomobject]@{
        Area = $Area
        Status = $Status
        Evidence = $Evidence
        Action = $Action
    }) | Out-Null
}

function Test-NonEmptyFile {
    param([string]$Path)

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        return $false
    }

    return ((Get-Item -LiteralPath $Path).Length -gt 0)
}

function Check-NonEmptyFile {
    param(
        [string]$Area,
        [string]$Path,
        [string]$Action
    )

    if (Test-NonEmptyFile -Path $Path) {
        Add-Check $Area "PASS" $Path "None"
    } elseif (Test-Path -LiteralPath $Path -PathType Leaf) {
        Add-Check $Area "FAIL" "$Path is empty" $Action
    } else {
        Add-Check $Area "FAIL" "$Path is missing" $Action
    }
}

function Check-NoContentMatch {
    param(
        [string]$Area,
        [string[]]$Paths,
        [string]$Pattern,
        [string]$Action
    )

    $matches = @()
    foreach ($path in $Paths) {
        if (Test-Path -LiteralPath $path -PathType Leaf) {
            $matches += Select-String -LiteralPath $path -Pattern $Pattern -ErrorAction SilentlyContinue | Select-Object -First 5
        }
    }

    if ($matches.Count -gt 0) {
        Add-Check $Area "FAIL" (($matches | ForEach-Object { "$($_.Path):$($_.LineNumber)" }) -join "; ") $Action
    } else {
        Add-Check $Area "PASS" "No matches: $Pattern" "None"
    }
}

function Check-ContentContainsAll {
    param(
        [string]$Area,
        [string]$Path,
        [string[]]$Needles,
        [ValidateSet("WARN", "FAIL")]
        [string]$MissingStatus,
        [string]$Action
    )

    if (-not (Test-NonEmptyFile -Path $Path)) {
        Add-Check $Area "FAIL" "$Path is missing or empty" $Action
        return
    }

    $text = Get-Content -Raw -Encoding UTF8 -LiteralPath $Path
    $missing = @()
    foreach ($needle in $Needles) {
        if ($text -notmatch [regex]::Escape($needle)) {
            $missing += $needle
        }
    }

    if ($missing.Count -gt 0) {
        Add-Check $Area $MissingStatus ("Missing: " + ($missing -join ", ")) $Action
    } else {
        Add-Check $Area "PASS" $Path "None"
    }
}

function Test-CommandAvailable {
    param([string]$Name)
    return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Get-CommandVersion {
    param(
        [string]$Name,
        [string[]]$CommandArgs
    )

    try {
        $output = & $Name @CommandArgs 2>$null
        if ($output -is [array]) {
            return ($output | Select-Object -First 1)
        }
        return $output
    } catch {
        return ""
    }
}

function Invoke-GitCapture {
    param([string[]]$GitArgs)

    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $output = & git @GitArgs 2>$null
        $exitCode = $LASTEXITCODE
        return [pscustomobject]@{
            ExitCode = $exitCode
            Output = $output
        }
    } finally {
        $ErrorActionPreference = $oldPreference
    }
}

function Test-VersionField {
    param(
        [string]$Text,
        [string]$Name
    )

    return ($Text -match ("(?m)^" + [regex]::Escape($Name) + "\s*:"))
}

function Get-VersionValue {
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

function Get-RelativeFileMap {
    param([string]$Root)

    $map = @{}
    if (-not (Test-Path -LiteralPath $Root -PathType Container)) {
        return $map
    }

    $rootFull = [System.IO.Path]::GetFullPath((Resolve-Path -LiteralPath $Root).Path).TrimEnd("\", "/")

    Get-ChildItem -LiteralPath $Root -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object {
            $_.FullName -notmatch "\\\.git\\" -and
            $_.FullName -notmatch "\\\.harness\\progress\\" -and
            $_.FullName -notmatch "\\\.harness\\results\\" -and
            $_.FullName -notmatch "\\\.harness\\reviews\\" -and
            $_.FullName -notmatch "\\\.harness\\research\\"
        } |
        ForEach-Object {
            $full = [System.IO.Path]::GetFullPath($_.FullName)
            if (-not $full.StartsWith($rootFull, [System.StringComparison]::OrdinalIgnoreCase)) {
                return
            }
            $relative = $full.Substring($rootFull.Length).TrimStart("\", "/").Replace("\", "/")
            if ([string]::IsNullOrWhiteSpace($relative)) {
                return
            }
            $map[$relative] = $_.FullName
        }

    return $map
}

$codexHome = $env:CODEX_HOME
if ([string]::IsNullOrWhiteSpace($codexHome)) {
    $codexHome = Join-Path $HOME ".codex"
}

$skillsDir = Join-Path $codexHome "skills"
$harnessDir = Join-Path $skillsDir "harness"
$harnessPlanDir = Join-Path $skillsDir "harness-plan"
$harnessPlanAskDir = Join-Path $skillsDir "harness-plan-ask"
$setupDir = Join-Path $skillsDir "ecc-command-harness-setup"
$bootstrapScript = Join-Path $harnessDir "core\bootstrap-runtime.sh"
$runtimeGateScript = Join-Path $harnessDir "core\validate-runtime-gate.ps1"
$syncScript = Join-Path $setupDir "scripts\sync-codex-harness.ps1"

Add-Check "path:CODEX_HOME" "PASS" $codexHome "None"

if (Test-Path -LiteralPath $skillsDir -PathType Container) {
    Add-Check "path:skills" "PASS" $skillsDir "None"
} else {
    Add-Check "path:skills" "FAIL" "$skillsDir is missing" "Install Codex skills under CODEX_HOME."
}

Check-NonEmptyFile "skill:harness" (Join-Path $harnessDir "SKILL.md") "Restore the harness skill."
Check-NonEmptyFile "skill:harness-plan" (Join-Path $harnessPlanDir "SKILL.md") "Restore the harness-plan skill."
Check-NonEmptyFile "skill:harness-plan-ask" (Join-Path $harnessPlanAskDir "SKILL.md") "Restore the harness-plan-ask skill."
Check-NonEmptyFile "skill:harness-setup" (Join-Path $setupDir "SKILL.md") "Restore the harness-setup skill."
Check-NonEmptyFile "setup:sync-script" $syncScript "Restore the portable upstream sync script."
Check-NonEmptyFile "setup:bash-script" (Join-Path $setupDir "scripts\check-harness-setup.sh") "Restore the bash setup checker."

$wrappers = @(
    "ecc-command-harness",
    "ecc-command-harness-ask",
    "ecc-command-harness-audit",
    "ecc-command-harness-customer-user",
    "ecc-command-harness-deep-researcher",
    "ecc-command-harness-distill",
    "ecc-command-harness-help",
    "ecc-command-harness-review",
    "ecc-command-harness-setup",
    "ecc-command-harness-spec"
)

foreach ($wrapper in $wrappers) {
    Check-NonEmptyFile "wrapper:$wrapper" (Join-Path $skillsDir "$wrapper\SKILL.md") "Restore the wrapper skill."
}

$versionPath = Join-Path $harnessDir ".version"
if (Test-NonEmptyFile -Path $versionPath) {
    $versionText = Get-Content -Raw -Encoding UTF8 -LiteralPath $versionPath

    $hasLegacyVersion = (
        (Test-VersionField $versionText "commit") -and
        (Test-VersionField $versionText "source") -and
        (Test-VersionField $versionText "branch")
    )
    $hasCodexPortVersion = (
        (Test-VersionField $versionText "upstream_commit") -and
        (Test-VersionField $versionText "upstream_reference") -and
        (Test-VersionField $versionText "upstream_branch")
    )

    if ($hasCodexPortVersion) {
        Add-Check "version" "PASS" $versionPath "None"
    } elseif ($hasLegacyVersion) {
        Add-Check "version" "WARN" "Legacy upstream-only version schema" "Rewrite .version with codex-local port fields before update work."
    } else {
        Add-Check "version" "FAIL" "Missing Codex port version fields" "Repair harness/.version from the verified installed source."
    }

    if (-not (Test-VersionField $versionText "installed")) {
        Add-Check "version:installed" "WARN" "installed timestamp is missing" "Record install time on the next verified update."
    }

    if (-not (Test-VersionField $versionText "update_policy")) {
        Add-Check "version:update-policy" "WARN" "update_policy is missing" "Record the manual update policy on the next verified update."
    }
} else {
    Add-Check "version" "FAIL" "$versionPath is missing or empty" "Restore harness/.version from the verified installed source."
}

if ($CheckMirror) {
    $claudeHome = Join-Path (Split-Path -Parent $codexHome) ".claude"
    $claudeHarnessDir = Join-Path $claudeHome "skills\harness"

    if (-not (Test-Path -LiteralPath $claudeHarnessDir -PathType Container)) {
        Add-Check "mirror:claude-harness" "WARN" "$claudeHarnessDir is missing" "Mirror check skipped; install or point to the other environment before comparing."
    } else {
        Add-Check "mirror:claude-harness" "PASS" $claudeHarnessDir "None"

        $codexVersionText = if (Test-NonEmptyFile -Path $versionPath) { Get-Content -Raw -Encoding UTF8 -LiteralPath $versionPath } else { "" }
        $claudeVersionPath = Join-Path $claudeHarnessDir ".version"
        $claudeVersionText = if (Test-NonEmptyFile -Path $claudeVersionPath) { Get-Content -Raw -Encoding UTF8 -LiteralPath $claudeVersionPath } else { "" }
        $codexCommit = Get-VersionValue $codexVersionText "upstream_commit"
        if ([string]::IsNullOrWhiteSpace($codexCommit)) {
            $codexCommit = Get-VersionValue $codexVersionText "commit"
        }
        $claudeCommit = Get-VersionValue $claudeVersionText "upstream_commit"
        if ([string]::IsNullOrWhiteSpace($claudeCommit)) {
            $claudeCommit = Get-VersionValue $claudeVersionText "commit"
        }

        if (-not [string]::IsNullOrWhiteSpace($codexCommit) -and $codexCommit -eq $claudeCommit) {
            Add-Check "mirror:commit" "PASS" "Both environments reference $codexCommit" "None"
        } else {
            Add-Check "mirror:commit" "WARN" "Codex=$codexCommit; Other=$claudeCommit" "Compare manually before copying any file."
        }

        $codexMap = Get-RelativeFileMap $harnessDir
        $claudeMap = Get-RelativeFileMap $claudeHarnessDir
        $allRel = @($codexMap.Keys + $claudeMap.Keys | Sort-Object -Unique)
        $missingInCodex = New-Object System.Collections.Generic.List[string]
        $missingInOther = New-Object System.Collections.Generic.List[string]
        $different = New-Object System.Collections.Generic.List[string]

        foreach ($rel in $allRel) {
            if (-not $codexMap.ContainsKey($rel)) {
                $missingInCodex.Add($rel) | Out-Null
                continue
            }
            if (-not $claudeMap.ContainsKey($rel)) {
                $missingInOther.Add($rel) | Out-Null
                continue
            }
            $codexHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $codexMap[$rel]).Hash
            $otherHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $claudeMap[$rel]).Hash
            if ($codexHash -ne $otherHash) {
                $different.Add($rel) | Out-Null
            }
        }

        if ($missingInCodex.Count -gt 0) {
            Add-Check "mirror:missing-in-codex" "WARN" (($missingInCodex | Select-Object -First 10) -join ", ") "Review whether these files are intentionally absent from the Codex port."
        }
        if ($missingInOther.Count -gt 0) {
            Add-Check "mirror:missing-in-other" "WARN" (($missingInOther | Select-Object -First 10) -join ", ") "Review whether these Codex files should have a bridge or counterpart."
        }
        if ($different.Count -gt 0) {
            $status = if (-not [string]::IsNullOrWhiteSpace($codexCommit) -and $codexCommit -eq $claudeCommit) { "WARN" } else { "WARN" }
            Add-Check "mirror:different-content" $status (($different | Select-Object -First 15) -join ", ") "Same filenames differ; inspect diff before any sync."
        }
        if ($missingInCodex.Count -eq 0 -and $missingInOther.Count -eq 0 -and $different.Count -eq 0) {
            Add-Check "mirror:content" "PASS" "No file drift detected" "None"
        }
    }
}

Check-NonEmptyFile "bootstrap" $bootstrapScript "Restore harness/core/bootstrap-runtime.sh."
Check-NonEmptyFile "core:runtime-gate" $runtimeGateScript "Restore harness/core/validate-runtime-gate.ps1."

$templateFiles = @(
    "doc-prd.md",
    "doc-architecture.md",
    "doc-adr.md",
    "doc-ui-guide.md",
    "project-agents.md",
    "project-dual-bridge.md",
    "plan.md",
    "progress.md",
    "result.md",
    "review.md"
)

foreach ($file in $templateFiles) {
    Check-NonEmptyFile "bundle:templates" (Join-Path $harnessDir "templates\$file") "Restore the missing Harness template."
}

$docFiles = @(
    "setup.md",
    "workflow.md",
    "context-layer.md",
    "environment-map.md",
    "examples.md",
    "phases.md",
    "file-formats.md",
    "html-output-rule.md",
    "stop-report.md",
    "procedures\codex-review-procedure.md",
    "procedures\customer-test-procedure.md",
    "procedures\deep-research-procedure.md",
    "steps\step1-init.md",
    "steps\step2-domain.md",
    "steps\step3-impl-plan.md",
    "steps\step4-impl.md",
    "steps\step5-review.md",
    "steps\step6-qa.md",
    "steps\step7-customer.md",
    "steps\step8-commit.md",
    "steps\complete.md"
)

foreach ($file in $docFiles) {
    Check-NonEmptyFile "bundle:docs" (Join-Path $harnessDir "docs\$file") "Restore the missing Harness doc."
}

$workflowTemplatePaths = @(
    (Join-Path $harnessDir "templates\plan.md"),
    (Join-Path $harnessDir "templates\progress.md"),
    (Join-Path $harnessDir "templates\result.md"),
    (Join-Path $harnessDir "templates\review.md")
)
Check-NoContentMatch "content:workflow-template-phase" $workflowTemplatePaths "\bPhase\b" "Use Step 1-8 + Complete terminology in workflow templates."

$stepListFiles = @(
    (Join-Path $harnessDir "SKILL.md"),
    (Join-Path $harnessDir "docs\workflow.md"),
    (Join-Path $harnessDir "docs\phases.md")
)
Check-NoContentMatch "content:complete-numbered" $stepListFiles "(?m)^\s*9\.\s*\[?Complete" "Complete must be listed as an unnumbered final stage, not Step 9."

$pathContractFiles = @(
    (Join-Path $harnessDir "SKILL.md"),
    (Join-Path $harnessDir "docs\workflow.md"),
    (Join-Path $harnessDir "docs\steps\step2-domain.md"),
    (Join-Path $harnessDir "docs\steps\step3-impl-plan.md"),
    (Join-Path $harnessDir "docs\steps\complete.md"),
    (Join-Path $harnessDir "docs\file-formats.md")
)
$legacyPathPattern = "\.harness/" + "plans/" + "(domain|impl)-|" + "final-" + "<slug>|" + "progress-" + "<slug>\.html"
Check-NoContentMatch "content:legacy-artifact-paths" $pathContractFiles $legacyPathPattern "Use the standardized Harness artifact paths."

$harnessPlanPath = Join-Path $harnessPlanDir "SKILL.md"
$harnessPlanAskPath = Join-Path $harnessPlanAskDir "SKILL.md"
$step2DomainPath = Join-Path $harnessDir "docs\steps\step2-domain.md"
$deepResearchCommandPath = Join-Path $skillsDir "ecc-command-harness-deep-researcher\SKILL.md"
$deepResearchProcedurePath = Join-Path $harnessDir "docs\procedures\deep-research-procedure.md"
$sixDomainCategories = @(
    "domain-category:integrated-user-scenario",
    "domain-category:success-criteria",
    "domain-category:scope-exclusions",
    "domain-category:constraints",
    "domain-category:external-dependencies",
    "domain-category:non-functional-requirements"
)
Check-ContentContainsAll "content:step2:harness-plan-categories" $harnessPlanPath $sixDomainCategories "FAIL" "Restore all six Step 2 domain categories in harness-plan."
Check-ContentContainsAll "content:step2:harness-plan-ask-categories" $harnessPlanAskPath $sixDomainCategories "FAIL" "Restore all six Step 2 domain categories in harness-plan-ask."
Check-ContentContainsAll "content:step2:domain-doc-categories" $step2DomainPath $sixDomainCategories "FAIL" "Restore all six Step 2 domain categories in step2-domain.md."
Check-ContentContainsAll "content:step2:readability" $harnessPlanPath @("readability", "short", "headings", "technical terms", "daily workflow") "WARN" "Restore the readability self-check in harness-plan."
Check-ContentContainsAll "content:step2:ask-interactive" $harnessPlanAskPath @("mode:interactive-forced", "noask-marker-ignored", "six-category-collection") "FAIL" "Ensure harness-plan-ask forces interactive Step 2 behavior."
Check-ContentContainsAll "content:step2:ux-gate" $step2DomainPath @("ux-gate", "ux-field:target-surface", "ux-field:before-after", "ux-field:affected-user-scenario", "ux-field:visual-evidence-or-omission-reason") "FAIL" "Restore the Step 2 UX gate."
Check-ContentContainsAll "content:step2:description-boundary" $harnessPlanPath @("boundary:harness-step2-only", "boundary:exclude-general-planning", "boundary:exclude-step3-implementation-plan") "FAIL" "Ensure harness-plan is scoped to /harness Step 2 only."
Check-ContentContainsAll "content:step2:noask-evidence" $harnessPlanPath @("evidence:user-request", "evidence:prd", "evidence:architecture", "evidence:adr", "evidence:ui-guide", "evidence:agents-or-claude", "evidence:git-history-5", "evidence:code-search") "FAIL" "Restore noask evidence collection anchors."
Check-ContentContainsAll "content:step2:output-template" $harnessPlanPath @("template-section:requirements-restatement", "template-section:risks", "template-section:open-questions") "FAIL" "Restore Step 2 output template sections."
Check-ContentContainsAll "content:step2:research-format" $harnessPlanPath @("research-field:summary", "research-field:key-findings", "research-field:sources-consulted", "research-field:search-trail", "research-field:stop-reason", "research-field:research-date", "research-field:step2-impact", "research-field:inferred") "FAIL" "Restore deep research output format requirements."
Check-ContentContainsAll "content:deep-research:command-format" $deepResearchCommandPath @("research-field:summary", "research-field:key-findings", "research-field:sources-consulted", "research-field:search-trail", "research-field:stop-reason", "research-field:research-date", "research-field:step2-impact", "research-field:inferred") "FAIL" "Restore deep research command output format requirements."
Check-ContentContainsAll "content:deep-research:procedure-format" $deepResearchProcedurePath @("research-field:summary", "research-field:key-findings", "research-field:sources-consulted", "research-field:search-trail", "research-field:stop-reason", "research-field:research-date", "research-field:step2-impact", "research-field:inferred") "FAIL" "Restore deep research procedure output format requirements."
Check-ContentContainsAll "content:step2:ux-keywords" $step2DomainPath @("ux-keyword:screen", "ux-keyword:button", "ux-keyword:menu", "ux-keyword:layout", "ux-keyword:accessibility", "ux-keyword:wireframe", "ux-keyword:mockup") "FAIL" "Restore expanded UX keyword coverage."
Check-ContentContainsAll "content:step2:approval-flow" $step2DomainPath @("approval-flow:review-draft", "approval-flow:apply-review", "approval-flow:noask-auto-approve", "approval-flow:ask-confirm-approve-revise-cancel", "approval-flow:save-after-approval") "FAIL" "Restore Step 2 caller approval flow."

$forbiddenPatterns = @(
    ("~/" + ".claude"),
    ("AskUser" + "Question"),
    ("CLAUDE" + "_COMMAND"),
    ("--" + "noagent"),
    ("." + "noagent"),
    ("harness/skills/" + "harness")
)

foreach ($pattern in $forbiddenPatterns) {
    $matches = @(
        Get-ChildItem -LiteralPath $harnessDir -Recurse -File -ErrorAction SilentlyContinue |
            Where-Object { $_.Extension -in @(".md", ".sh", ".txt", ".yaml", ".yml") -or $_.Name -eq ".version" } |
            Where-Object { -not ($pattern -eq ("~/" + ".claude") -and $_.FullName -like "*\docs\environment-map.md") } |
            Where-Object { -not ($pattern -eq ("~/" + ".claude") -and $_.FullName -like "*\templates\project-dual-bridge.md") } |
            Select-String -SimpleMatch -Pattern $pattern -ErrorAction SilentlyContinue |
            Select-Object -First 3
    )
    if ($matches.Count -gt 0) {
        Add-Check "content:forbidden:$pattern" "FAIL" ($matches | ForEach-Object { "$($_.Path):$($_.LineNumber)" } | Out-String).Trim() "Remove stale non-Codex Harness text."
    }
}

$learningFiles = @(
    "README.md",
    "harness-customer-user.md",
    "harness-deep-researcher.md",
    "harness-qa-engineer.md"
)

foreach ($file in $learningFiles) {
    Check-NonEmptyFile "bundle:agents-learning" (Join-Path $harnessDir "agents\learning\$file") "Restore the missing Harness learning file."
}

$gitAvailable = Test-CommandAvailable "git"
if ($gitAvailable) {
    Add-Check "runtime:git" "PASS" (Get-CommandVersion "git" @("--version")) "None"
} else {
    $status = if ($Mode -eq "audit") { "WARN" } else { "FAIL" }
    Add-Check "runtime:git" $status "git is not available" "Install Git before Harness init/update."
}

$bashAvailable = Test-CommandAvailable "bash"
if ($bashAvailable) {
    Add-Check "runtime:bash" "PASS" (Get-CommandVersion "bash" @("--version")) "None"
} else {
    $status = if ($Mode -eq "init") { "FAIL" } else { "WARN" }
    Add-Check "runtime:bash" $status "bash is not available" "Install Git Bash or WSL before running bootstrap-runtime.sh."
}

if (Test-Path -LiteralPath $ProjectDir -PathType Container) {
    $resolvedProjectDir = (Resolve-Path -LiteralPath $ProjectDir).Path
    Add-Check "project:path" "PASS" $resolvedProjectDir "None"
} else {
    $resolvedProjectDir = $ProjectDir
    Add-Check "project:path" "FAIL" "$ProjectDir is missing" "Use an existing project directory."
}

$projectRoot = $resolvedProjectDir
$bootstrapTargetRoot = $resolvedProjectDir

if ($gitAvailable -and (Test-Path -LiteralPath $resolvedProjectDir -PathType Container)) {
    $gitRootResult = Invoke-GitCapture @("-C", $resolvedProjectDir, "rev-parse", "--show-toplevel")
    if ($gitRootResult.ExitCode -eq 0 -and -not [string]::IsNullOrWhiteSpace($gitRootResult.Output)) {
        $projectRoot = ([string]$gitRootResult.Output).Trim()
        Add-Check "project:git-root" "PASS" $projectRoot "None"

        $commonGitDirResult = Invoke-GitCapture @("-C", $resolvedProjectDir, "rev-parse", "--path-format=absolute", "--git-common-dir")
        $commonGitDir = $commonGitDirResult.Output
        if ($commonGitDirResult.ExitCode -ne 0 -or [string]::IsNullOrWhiteSpace($commonGitDir)) {
            $commonGitDirResult = Invoke-GitCapture @("-C", $resolvedProjectDir, "rev-parse", "--git-common-dir")
            $commonGitDir = $commonGitDirResult.Output
            if ($commonGitDirResult.ExitCode -eq 0 -and -not [string]::IsNullOrWhiteSpace($commonGitDir)) {
                $commonGitDir = ([string]$commonGitDir).Trim()
                if (-not [System.IO.Path]::IsPathRooted($commonGitDir)) {
                    $commonGitDir = Join-Path $projectRoot $commonGitDir
                }
            }
        }

        if (-not [string]::IsNullOrWhiteSpace($commonGitDir)) {
            $bootstrapTargetRoot = Split-Path -Parent ($commonGitDir.Trim())
            Add-Check "project:bootstrap-root" "PASS" $bootstrapTargetRoot "Confirm this path before write operations."
            if ([System.IO.Path]::GetFullPath($bootstrapTargetRoot) -ne [System.IO.Path]::GetFullPath($projectRoot)) {
                Add-Check "project:root-mismatch" "WARN" "git root: $projectRoot; bootstrap root: $bootstrapTargetRoot" "Ask for confirmation before running bootstrap."
            }
        } else {
            Add-Check "project:bootstrap-root" "WARN" "Could not resolve git common dir" "Use the visible project root and ask before writing."
        }
    } else {
        Add-Check "project:git-root" "WARN" "Project is not a git repository" "Use the current directory as Harness target."
    }
}

$projectHarnessDir = Join-Path $bootstrapTargetRoot ".harness"
if (Test-Path -LiteralPath $projectHarnessDir -PathType Container) {
    Add-Check "project:.harness" "PASS" $projectHarnessDir "None"
} else {
    Add-Check "project:.harness" "WARN" "$projectHarnessDir is missing" "Run bootstrap only after user approval."
}

foreach ($dir in @("templates", "docs", "agents\learning", "progress", "research", "reviews", "results")) {
    $path = Join-Path $projectHarnessDir $dir
    if (Test-Path -LiteralPath $path -PathType Container) {
        Add-Check "project:.harness\$dir" "PASS" $path "None"
    } else {
        Add-Check "project:.harness\$dir" "WARN" "$path is missing" "Run bootstrap only after user approval."
    }
}

foreach ($file in @("PRD.md", "ARCHITECTURE.md", "ADR.md", "UI_GUIDE.md")) {
    $path = Join-Path (Join-Path $bootstrapTargetRoot "docs") $file
    if (Test-NonEmptyFile -Path $path) {
        Add-Check "project:docs\$file" "PASS" $path "None"
    } elseif (Test-Path -LiteralPath $path -PathType Leaf) {
        Add-Check "project:docs\$file" "WARN" "$path is empty" "Run bootstrap only after user approval."
    } else {
        Add-Check "project:docs\$file" "WARN" "$path is missing" "Run bootstrap only after user approval."
    }
}

$agentsPath = Join-Path $bootstrapTargetRoot "AGENTS.md"
if (Test-NonEmptyFile -Path $agentsPath) {
    $agentsText = Get-Content -Raw -Encoding UTF8 -LiteralPath $agentsPath
    if ($agentsText -match "(?i)harness") {
        Add-Check "project:AGENTS.md" "PASS" $agentsPath "None"
    } else {
        Add-Check "project:AGENTS.md" "WARN" "AGENTS.md exists but does not mention Harness" "Do not overwrite; propose a manual merge."
    }
} elseif (Test-Path -LiteralPath $agentsPath -PathType Leaf) {
    Add-Check "project:AGENTS.md" "WARN" "$agentsPath is empty" "Run bootstrap only after user approval."
} else {
    Add-Check "project:AGENTS.md" "WARN" "$agentsPath is missing" "Run bootstrap only after user approval."
}

$claudePath = Join-Path $bootstrapTargetRoot "CLAUDE.md"
if (Test-Path -LiteralPath $claudePath -PathType Leaf) {
    $claudeText = Get-Content -Raw -Encoding UTF8 -LiteralPath $claudePath
    if ($claudeText -match "AGENTS\.md") {
        Add-Check "project:CLAUDE.md-bridge" "PASS" "CLAUDE.md points to AGENTS.md" "None"
    } else {
        Add-Check "project:CLAUDE.md-bridge" "WARN" "CLAUDE.md exists but does not point to AGENTS.md" "Do not overwrite; propose a manual bridge if this is a dual environment."
    }
}

if ($Mode -eq "update") {
    if (-not (Test-NonEmptyFile -Path $syncScript)) {
        Add-Check "update:portable-sync" "FAIL" "Sync script missing: $syncScript" "Restore sync-codex-harness.ps1."
    } else {
        $syncErrPath = [System.IO.Path]::GetTempFileName()
        try {
            $syncArgs = @("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $syncScript, "-CodexHome", $codexHome, "-Json")
            if (-not $DryRun) {
                $syncArgs += "-Apply"
            }
            $syncJsonText = & powershell @syncArgs 2> $syncErrPath
            if ($LASTEXITCODE -ne 0) {
                $syncErr = ""
                if (Test-Path -LiteralPath $syncErrPath -PathType Leaf) {
                    $syncErr = (Get-Content -LiteralPath $syncErrPath -Raw).Trim()
                }
                $syncEvidence = "sync-codex-harness.ps1 exited with $LASTEXITCODE. $syncErr"
                try {
                    $blockedResult = ($syncJsonText | Out-String).Trim() | ConvertFrom-Json
                    if ($blockedResult.Status -eq "BLOCKED" -and -not [string]::IsNullOrWhiteSpace($blockedResult.Error)) {
                        $syncEvidence = "$($blockedResult.Status): $($blockedResult.Error); Report=$($blockedResult.ReportPath)"
                    }
                } catch {
                    # Keep the raw evidence when the child process did not return JSON.
                }

                if ($DryRun) {
                    Add-Check "update:portable-sync" "WARN" $syncEvidence "Upstream sync check was blocked; retry with network access or pass -UpstreamUrl."
                } else {
                    Add-Check "update:portable-sync" "FAIL" $syncEvidence "Resolve upstream access, then rerun update."
                }
            } else {
                $syncResult = $syncJsonText | ConvertFrom-Json
                if ($DryRun) {
                    Add-Check "update:portable-sync" "PASS" "DryRun=1; Planned=$($syncResult.Planned.Count); ManualPort=$($syncResult.NeedsManualPort.Count); Report=$($syncResult.ReportPath)" "Review the report before running update without -DryRun."
                } else {
                    Add-Check "update:portable-sync" "PASS" "Applied=$($syncResult.Applied.Count); ManualPort=$($syncResult.NeedsManualPort.Count); Report=$($syncResult.ReportPath)" "Review manual port report for held files."
                }
            }
        } catch {
            Add-Check "update:portable-sync" "FAIL" $_.Exception.Message "Inspect sync-codex-harness.ps1."
        } finally {
            if (Test-Path -LiteralPath $syncErrPath -PathType Leaf) {
                Remove-Item -LiteralPath $syncErrPath -Force
            }
        }
    }
}

$finalStatus = "PASS"
if ($checks | Where-Object { $_.Status -eq "FAIL" }) {
    $finalStatus = "FAIL"
} elseif ($checks | Where-Object { $_.Status -eq "WARN" }) {
    $finalStatus = "WARN"
}

$result = [pscustomobject]@{
    Summary = $finalStatus
    Mode = $Mode
    CodexHome = $codexHome
    SkillsDir = $skillsDir
    ProjectDir = $resolvedProjectDir
    ProjectRoot = $projectRoot
    HarnessTargetRoot = $bootstrapTargetRoot
    Checks = $checks
}

if ($Json) {
    $result | ConvertTo-Json -Depth 5
} else {
    "Summary: $finalStatus"
    "Mode: $Mode"
    "CODEX_HOME: $codexHome"
    "Skills: $skillsDir"
    "ProjectDir: $resolvedProjectDir"
    "ProjectRoot: $projectRoot"
    "HarnessTargetRoot: $bootstrapTargetRoot"
    ""
    $checks | Format-Table -AutoSize
}

if ($finalStatus -eq "FAIL") {
    exit 1
}

exit 0
