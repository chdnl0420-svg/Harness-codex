$ErrorActionPreference = "Continue"
$root = Join-Path $HOME ".codex/skills/harness-run"
$pass = 0; $warn = 0; $fail = 0
function Ok($m){ "[PASS] $m"; $script:pass++ }
function Warn($m){ "[WARN] $m"; $script:warn++ }
function Fail($m){ "[FAIL] $m"; $script:fail++ }
function Has($rel){ Test-Path -LiteralPath (Join-Path $root $rel) }
"=== dryrun.ps1 ==="
foreach($f in @('SKILL.md','docs/workflow.md','docs/code-structure.md','docs/run-modes.md')){ if(Has $f){Ok $f}else{Fail "$f missing"} }
foreach($s in @('01-detect','02-domain','03-tdd','04-qa','05-review','06-customer','07-audit','08-summary','09-commit')){ if(Has "docs/steps/$s.md"){Ok "step $s"}else{Fail "step $s missing"} }
foreach($a in @('codex-reviewer','harness-customer-user','harness-engineering-researcher','harness-engineering-qa','harness-engineering-auditor','planner')){ if(Has "agents/$a.md"){Ok "agent $a"}else{Fail "agent $a missing"} }
foreach($l in @('codex-reviewer','harness-customer-user','harness-engineering-researcher','harness-engineering-qa','harness-engineering-auditor')){ if(Has "learning/$l.md"){Ok "learning $l"}else{Warn "learning $l missing"} }
if(Test-Path -LiteralPath (Join-Path $HOME ".codex/prompts/harness-run.md")){Ok "entry prompt"}else{Fail "entry prompt missing"}
$skill = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $root 'SKILL.md')
if($skill -match '~/.claude/'){Fail 'SKILL.md has ~/.claude path'}else{Ok 'SKILL.md Codex paths'}
foreach($enum in @('EXT_DEP_PROD_BLOCKED','TDD_5X_SAME_SCENARIO','QA_OR_REVIEW_5X_SAME_DEFECT','AUDIT_LIMIT_EXCEEDED','SUBAGENT_RUNTIME_BLOCKED')){ if($skill.Contains($enum)){Ok "enum $enum"}else{Fail "enum $enum missing"} }
if($skill -match 'Mock.*금지|mockito.*금지|NSubstitute'){Ok 'Mock ban policy'}else{Fail 'Mock ban policy missing'}
if($skill.Contains('non-waivable invariant 7개')){Ok 'non-waivable invariant'}else{Warn 'non-waivable invariant not identified'}
if($skill.Contains('codex exec --skip-git-repo-check')){Ok 'codex exec recursive pattern'}else{Fail 'codex exec recursive pattern missing'}
"PASS: $pass / WARN: $warn / FAIL: $fail"
if($fail -gt 0){ exit 1 }
