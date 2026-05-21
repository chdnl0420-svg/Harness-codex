param(
    [string]$ProjectDir = (Get-Location).Path,
    [string]$HarnessRoot = "",
    [string]$Slug = "",
    [ValidateSet("Step2", "Step3", "Step4", "Step5", "Step6", "Step7", "Step8", "Complete")]
    [string]$NextStep,
    [string]$Step4CommitSha = "",
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
    return (Test-Path -LiteralPath $Path -PathType Leaf) -and ((Get-Item -LiteralPath $Path).Length -gt 0)
}

function Read-Text {
    param([string]$Path)
    if (Test-NonEmptyFile $Path) {
        return [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
    }
    return ""
}

function Get-GitOutput {
    param([string[]]$GitArgs)
    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $output = & git @GitArgs 2>$null
        return [pscustomobject]@{ ExitCode = $LASTEXITCODE; Output = $output }
    } finally {
        $ErrorActionPreference = $oldPreference
    }
}

function Resolve-HarnessPath {
    param(
        [string]$BaseDir,
        [string]$Path
    )

    if ([System.IO.Path]::IsPathRooted($Path)) {
        $candidate = $Path
    } else {
        $candidate = Join-Path $BaseDir $Path
    }

    if (Test-Path -LiteralPath $candidate) {
        return (Resolve-Path -LiteralPath $candidate).Path
    }

    return [System.IO.Path]::GetFullPath($candidate)
}

function Get-HarnessRoot {
    param([string]$ProjectDir)

    if (-not [string]::IsNullOrWhiteSpace($HarnessRoot)) {
        return Resolve-HarnessPath $ProjectDir $HarnessRoot
    }

    $git = Get-GitOutput @("-C", $ProjectDir, "rev-parse", "--path-format=absolute", "--git-common-dir")
    if ($git.ExitCode -eq 0 -and -not [string]::IsNullOrWhiteSpace($git.Output)) {
        return (Join-Path (Split-Path -Parent ([string]$git.Output).Trim()) ".harness")
    }

    return (Join-Path $ProjectDir ".harness")
}

function Get-LatestProgressFile {
    param([string]$Root)

    $progressDir = Join-Path $Root "progress"
    if (-not (Test-Path -LiteralPath $progressDir -PathType Container)) {
        return $null
    }
    return Get-ChildItem -LiteralPath $progressDir -File -Filter "progress-*.md" |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1
}

function Add-FileGate {
    param(
        [string]$Area,
        [string]$Path,
        [string]$Action
    )

    if (Test-NonEmptyFile $Path) {
        Add-Check $Area "PASS" $Path "None"
    } elseif (Test-Path -LiteralPath $Path -PathType Leaf) {
        Add-Check $Area "FAIL" "$Path is empty" $Action
    } else {
        Add-Check $Area "FAIL" "$Path is missing" $Action
    }
}

function Get-LatestFile {
    param(
        [string]$Dir,
        [string]$Pattern
    )

    if (-not (Test-Path -LiteralPath $Dir -PathType Container)) {
        return $null
    }
    return Get-ChildItem -LiteralPath $Dir -File -Filter $Pattern |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1
}

function Get-Field {
    param(
        [string]$Text,
        [string]$Name
    )

    $match = [regex]::Match($Text, "(?im)^\s*(?:-\s*)?" + [regex]::Escape($Name) + "\s*:\s*(.+?)\s*$")
    if ($match.Success) {
        return $match.Groups[1].Value.Trim()
    }
    return ""
}

function Test-MeaningfulValue {
    param(
        [string]$Value,
        [string]$Kind = "generic"
    )

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return $false
    }

    $normalized = $Value.Trim().ToLowerInvariant()
    $genericBad = @(
        "n/a", "na", "none", "-", "unknown",
        "pass", "passed", "ok", "yes", "assumed",
        "not run", "not-run", "not executed", "not applicable"
    )
    $koreanBad = @(
        (-join @([char]0xC5C6, [char]0xC74C)),
        (-join @([char]0xD574, [char]0xB2F9, [char]0x20, [char]0xC5C6, [char]0xC74C)),
        (-join @([char]0xBBF8, [char]0xC2E4, [char]0xD589)),
        (-join @([char]0xC2E4, [char]0xD589, [char]0x20, [char]0xC548, [char]0x20, [char]0xD568)),
        (-join @([char]0xC2E4, [char]0xD589, [char]0xD558, [char]0xC9C0, [char]0x20, [char]0xC54A, [char]0xC74C)),
        (-join @([char]0xBBF8, [char]0xD655, [char]0xC778)),
        (-join @([char]0xC54C, [char]0x20, [char]0xC218, [char]0x20, [char]0xC5C6, [char]0xC74C)),
        (-join @([char]0xCD94, [char]0xC815))
    )
    $genericBad = $genericBad + $koreanBad

    if ($genericBad -contains $normalized) {
        return $false
    }

    if ($Kind -eq "evidence" -and $Value.Trim().Length -lt 12) {
        return $false
    }

    return $true
}

function Test-LearningField {
    param(
        [string]$Text,
        [string]$Area
    )

    $learning = Get-Field $Text "Learning Prepend"
    if ([string]::IsNullOrWhiteSpace($learning)) {
        Add-Check $Area "FAIL" "Learning Prepend field is missing" "Record Learning Prepend: yes or Learning Prepend: not-used."
        return
    }

    if ($learning -match "^(yes|not-used)$") {
        Add-Check $Area "PASS" "Learning Prepend: $learning" "None"
    } else {
        Add-Check $Area "FAIL" "Learning Prepend: $learning" "Use yes when helper learning was prepended, or not-used when no helper was used."
    }
}

function Test-DomainUxGate {
    param([string]$Text)

    if ([string]::IsNullOrWhiteSpace($Text)) {
        return
    }

    $hasUxSignal = ($Text -match "(?i)(\bUX\b|\bUI\b|button|menu|layout|color|font|icon|navigation|modal|dialog|tab|input|list|card|sidebar|header|footer|toggle|dropdown|animation|transition|responsive|mobile|desktop|dark-mode|accessibility|flow|wireframe|mockup|visual|ux-field:|ux-keyword:)")
    if (-not $hasUxSignal) {
        Add-Check "domain:ux-gate" "PASS" "No UX signal detected" "None"
        return
    }

    if ($Text -notmatch "(?im)(^\s*#{1,2}\s*UX\b|<h[12][^>]*>\s*UX\s*</h[12]>)") {
        Add-Check "domain:ux-gate" "FAIL" "UX signal detected but UX heading is missing" "Add UX section before Step 3."
        return
    }

    $required = @("ux-field:target-surface", "ux-field:before-after", "ux-field:affected-user-scenario", "ux-field:visual-evidence-or-omission-reason")
    $missing = @()
    foreach ($field in $required) {
        if ($Text -notmatch [regex]::Escape($field)) {
            $missing += $field
        }
    }

    if ($missing.Count -gt 0) {
        Add-Check "domain:ux-gate" "FAIL" ("Missing UX fields: " + ($missing -join ", ")) "Add all required UX fields before Step 3."
    } else {
        Add-Check "domain:ux-gate" "PASS" "UX section contains required fields" "None"
    }
}

$resolvedProjectDir = (Resolve-Path -LiteralPath $ProjectDir).Path
$root = Get-HarnessRoot $resolvedProjectDir
$gitRoot = Get-GitOutput @("-C", $resolvedProjectDir, "rev-parse", "--show-toplevel")
$isGitRepo = ($gitRoot.ExitCode -eq 0 -and -not [string]::IsNullOrWhiteSpace(($gitRoot.Output | Out-String)))
if (Test-Path -LiteralPath $root -PathType Container) {
    Add-Check "root:.harness" "PASS" $root "None"
} else {
    Add-Check "root:.harness" "FAIL" "$root is missing" "Run Step 1 bootstrap before any later step."
}

if ([string]::IsNullOrWhiteSpace($Slug)) {
    $latestProgress = Get-LatestProgressFile $root
    if ($null -ne $latestProgress) {
        $Slug = $latestProgress.BaseName.Substring("progress-".Length)
    }
}

if ([string]::IsNullOrWhiteSpace($Slug)) {
    Add-Check "slug" "FAIL" "No slug provided and no progress file found" "Create progress/progress-<slug>.md in Step 1."
    $Slug = "__missing__"
} else {
    Add-Check "slug" "PASS" $Slug "None"
}

$progressPath = Join-Path $root "progress\progress-$Slug.md"
$domainPath = Join-Path $root "domain-$Slug.html"
$implementationPath = Join-Path $root "implementation-$Slug.html"
$reviewDir = Join-Path $root "reviews"
$resultsDir = Join-Path $root "results"
$reviewFile = Get-LatestFile $reviewDir "review-$Slug*.md"
$qaPath = Join-Path $resultsDir "qa-$Slug.md"
$customerPath = Join-Path $resultsDir "customer-$Slug.md"
$reportPath = Join-Path $resultsDir "report-$Slug.html"
$testGuidePath = Join-Path $root "test-guide-$Slug.md"

Add-FileGate "progress" $progressPath "Step 1 must create progress/progress-<slug>.md."

$progressText = Read-Text $progressPath
if ($progressText -match "(?im)\bstep\s*9\b|\bstep9\b|\bHarness\s+Step\s+(?:9|[1-9]\d+)\b") {
    Add-Check "progress:step-number" "FAIL" "Progress contains Step 9 or two-digit Harness Step wording" "Use only Harness Step 1-8 and Complete. External plan numbers must be labelled Task."
} else {
    Add-Check "progress:step-number" "PASS" "No invalid Harness Step number" "None"
}

if ($NextStep -in @("Step3", "Step4", "Step5", "Step6", "Step7", "Step8", "Complete")) {
    Add-FileGate "artifact:domain" $domainPath "Step 2 must write .harness/domain-<slug>.html before Step 3."
    Test-DomainUxGate (Read-Text $domainPath)
}

if ($NextStep -in @("Step4", "Step5", "Step6", "Step7", "Step8", "Complete")) {
    Add-FileGate "artifact:implementation" $implementationPath "Step 3 must write .harness/implementation-<slug>.html before Step 4."
}

if ($NextStep -eq "Step5") {
    $status = Get-GitOutput @("-C", $resolvedProjectDir, "status", "--short")
    if ($status.ExitCode -eq 0 -and -not [string]::IsNullOrWhiteSpace(($status.Output | Out-String))) {
        Add-Check "git:changed-files" "PASS" (($status.Output | Out-String).Trim()) "None"
    } else {
        Add-Check "git:changed-files" "WARN" "No git changed files detected" "If reviewing non-git artifacts, list them explicitly in the review file."
    }
}

if ($NextStep -in @("Step6", "Step7", "Step8", "Complete")) {
    if ($null -eq $reviewFile) {
        Add-Check "artifact:review" "FAIL" "review-$Slug*.md is missing" "Run Step 5 review before Step 6."
    } else {
        Add-Check "artifact:review" "PASS" $reviewFile.FullName "None"
        $reviewText = Read-Text $reviewFile.FullName
        $lgtm = Get-Field $reviewText "LGTM"
        $external = Get-Field $reviewText "external_review"
        foreach ($field in @("LGTM", "external_review", "Review target", "Return path", "Loop counter")) {
            if ([string]::IsNullOrWhiteSpace((Get-Field $reviewText $field))) {
                Add-Check "review:field:$field" "FAIL" "$field is missing" "Write the full Step 5 decision report before Step 6."
            }
        }
        if ($lgtm -eq "YES" -and $external -ne "unavailable") {
            if ($external -match "^(independent-codex|user-approved)$") {
                Add-Check "review:lgtm" "PASS" "LGTM: YES; external_review: $external" "None"
            } else {
                Add-Check "review:lgtm" "FAIL" "LGTM: YES requires external_review: independent-codex or user-approved; got $external" "Do not promote self-review or not-requested review to LGTM: YES."
            }
        } elseif ($lgtm -eq "YES" -and $external -eq "unavailable") {
            Add-Check "review:lgtm" "FAIL" "Self-review LGTM: YES is not accepted" "Use LGTM: UNKNOWN or obtain a user-approved external review."
        } else {
            Add-Check "review:lgtm" "FAIL" "Explicit LGTM: YES not found" "Step 6 cannot start without an explicit approved Step 5 result."
        }

        if ($isGitRepo) {
            $effectiveStep4CommitSha = $Step4CommitSha
            if ([string]::IsNullOrWhiteSpace($effectiveStep4CommitSha)) {
                $effectiveStep4CommitSha = Get-Field $reviewText "step4_commit_sha"
            }

            if ([string]::IsNullOrWhiteSpace($effectiveStep4CommitSha) -or $effectiveStep4CommitSha -match "^(none|n/a|unknown)$") {
                Add-Check "git:step4-commit-sha" "FAIL" "step4_commit_sha is missing in a git repository" "Record the Step 4 commit/base SHA in the review file or pass -Step4CommitSha."
            } else {
                if ([string]::IsNullOrWhiteSpace($Step4CommitSha)) {
                    $Step4CommitSha = $effectiveStep4CommitSha
                }
                Add-Check "git:step4-commit-sha" "PASS" $effectiveStep4CommitSha "None"
            }
        }
    }
}

if ($NextStep -in @("Step7", "Step8", "Complete")) {
    Add-FileGate "artifact:test-guide" $testGuidePath "Step 6 must write or update .harness/test-guide-<slug>.md before QA can pass."
    Add-FileGate "artifact:qa" $qaPath "Run Step 6 and write results/qa-<slug>.md before Step 7."
    $qaText = Read-Text $qaPath
    $qaVerdict = Get-Field $qaText "Verdict"
    if ($qaVerdict -eq "PASS") {
        Add-Check "qa:verdict" "PASS" "Verdict: PASS" "None"
    } elseif ($qaVerdict -eq "BLOCKED") {
        $reason = Get-Field $qaText "Blocked reason"
        if ($reason -match "^(DEPENDENCY_MISSING|EVIDENCE_GATE_FAIL|PERMISSION_DENIED|GUIDE_MISSING|ENV_UNREACHABLE|OTHER)$") {
            Add-Check "qa:verdict" "FAIL" "Verdict: BLOCKED; reason: $reason" "Resolve blocker before continuing."
        } else {
            Add-Check "qa:verdict" "FAIL" "Verdict: BLOCKED without valid Blocked reason enum" "Use a valid Blocked reason enum."
        }
    } elseif ([string]::IsNullOrWhiteSpace($qaVerdict)) {
        Add-Check "qa:verdict" "FAIL" "Verdict field missing" "Write the full Step 6 decision report."
    } else {
        Add-Check "qa:verdict" "FAIL" "Verdict: $qaVerdict" "Core QA must PASS before continuing."
    }

    foreach ($field in @("Blocked reason", "Scope", "Environment", "Commands", "Screens", "Logs", "Evidence", "Coverage", "Regression", "Remaining Unknowns", "Failures", "Next")) {
        if ([string]::IsNullOrWhiteSpace((Get-Field $qaText $field))) {
            Add-Check "qa:field:$field" "FAIL" "$field is missing" "Write the full Step 6 decision report."
        }
    }

    Test-LearningField $qaText "qa:learning-prepend"

    if ($qaVerdict -eq "PASS") {
        $commands = Get-Field $qaText "Commands"
        $evidence = Get-Field $qaText "Evidence"
        $coverage = Get-Field $qaText "Coverage"
        $screens = Get-Field $qaText "Screens"
        $logs = Get-Field $qaText "Logs"

        if (-not (Test-MeaningfulValue $commands "command")) {
            Add-Check "qa:evidence:commands" "FAIL" "Commands is not meaningful: $commands" "PASS requires a real command, flow, or browser action."
        }
        if (-not (Test-MeaningfulValue $evidence "evidence")) {
            Add-Check "qa:evidence:evidence" "FAIL" "Evidence is not meaningful: $evidence" "PASS requires concrete output, log, screenshot, report, or file path."
        }
        if (-not (Test-MeaningfulValue $coverage "coverage")) {
            Add-Check "qa:evidence:coverage" "FAIL" "Coverage is not meaningful: $coverage" "Describe the checked core flow and regression scope."
        }
        if (
            -not (Test-MeaningfulValue $screens "evidence") -and
            -not (Test-MeaningfulValue $logs "evidence") -and
            $evidence.Trim().Length -lt 40
        ) {
            Add-Check "qa:evidence:artifact" "FAIL" "Screens and Logs are not meaningful and Evidence is too thin" "Attach at least one concrete screen, log, command output, or report path."
        }
    }
}

if ($NextStep -eq "Complete") {
    Add-FileGate "artifact:customer" $customerPath "Run Step 7 or record why it is not applicable."
    $customerText = Read-Text $customerPath
    Test-LearningField $customerText "customer:learning-prepend"
    $customerVerdict = Get-Field $customerText "Verdict"
    if ($customerVerdict -eq "PASS" -or $customerVerdict -eq "not-applicable") {
        Add-Check "customer:verdict" "PASS" "Verdict: $customerVerdict" "None"
    } else {
        Add-Check "customer:verdict" "FAIL" "Verdict: $customerVerdict" "Customer validation must PASS or be explicitly not-applicable before Complete."
    }

    if (Test-Path -LiteralPath $reportPath -PathType Leaf) {
        Add-Check "artifact:report-existing" "WARN" "$reportPath already exists" "Overwrite only after rechecking gates."
    }
}

if (-not [string]::IsNullOrWhiteSpace($Step4CommitSha)) {
    $diff = Get-GitOutput @("-C", $resolvedProjectDir, "diff", "--name-only", "$Step4CommitSha..HEAD")
    if ($diff.ExitCode -eq 0) {
        $changed = ($diff.Output | Out-String).Trim()
        if ([string]::IsNullOrWhiteSpace($changed)) {
            Add-Check "git:diff-gate" "PASS" "No diff since $Step4CommitSha" "None"
        } else {
            Add-Check "git:diff-gate" "WARN" $changed "Confirm these changes were included in the latest review/QA decision."
        }
    } else {
        Add-Check "git:diff-gate" "FAIL" "Could not diff $Step4CommitSha..HEAD" "Use a valid Step 4 commit SHA or omit this optional gate."
    }
}

$summary = "PASS"
if ($checks | Where-Object { $_.Status -eq "FAIL" }) {
    $summary = "FAIL"
} elseif ($checks | Where-Object { $_.Status -eq "WARN" }) {
    $summary = "WARN"
}

$passCount = @($checks | Where-Object { $_.Status -eq "PASS" }).Count
$warnCount = @($checks | Where-Object { $_.Status -eq "WARN" }).Count
$failCount = @($checks | Where-Object { $_.Status -eq "FAIL" }).Count

$result = [pscustomobject]@{
    Summary = $summary
    Pass = $passCount
    Warn = $warnCount
    Fail = $failCount
    NextStep = $NextStep
    HarnessRoot = $root
    Slug = $Slug
    Checks = $checks
}

if ($Json) {
    $result | ConvertTo-Json -Depth 6
} else {
    "Summary: $summary"
    foreach ($check in $checks) {
        "[$($check.Status)] $($check.Area): $($check.Evidence)"
    }
}

if ($summary -eq "FAIL") {
    exit 1
}
