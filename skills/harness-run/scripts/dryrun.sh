#!/usr/bin/env bash
set -uo pipefail
ROOT="$HOME/.codex/skills/harness-run"
PROMPT_FILE="$HOME/.codex/prompts/harness-run.md"
if [ ! -f "$ROOT/SKILL.md" ] && [ -f "/mnt/c/Users/NX3GAMES/.codex/skills/harness-run/SKILL.md" ]; then
  ROOT="/mnt/c/Users/NX3GAMES/.codex/skills/harness-run"
  PROMPT_FILE="/mnt/c/Users/NX3GAMES/.codex/prompts/harness-run.md"
fi
PASS=0; FAIL=0; WARN=0
ok()   { printf "[PASS] %s\n" "$*"; PASS=$((PASS+1)); }
warn() { printf "[WARN] %s\n" "$*"; WARN=$((WARN+1)); }
fail() { printf "[FAIL] %s\n" "$*"; FAIL=$((FAIL+1)); }
section() { printf "\n=== %s ===\n" "$*"; }
section "1. 필수 파일 존재"
for f in SKILL.md docs/workflow.md docs/code-structure.md docs/run-modes.md; do [ -f "$ROOT/$f" ] && ok "$f" || fail "$f missing"; done
for s in 01-detect 02-domain 03-tdd 04-qa 05-review 06-customer 07-audit 08-summary 09-commit; do [ -f "$ROOT/docs/steps/$s.md" ] && ok "step $s" || fail "step $s missing"; done
section "2. agent 정의 6개"
for a in codex-reviewer harness-customer-user harness-engineering-researcher harness-engineering-qa harness-engineering-auditor planner; do [ -f "$ROOT/agents/$a.md" ] && ok "agent $a" || fail "agent $a missing"; done
section "3. learning 파일 5개"
for l in codex-reviewer harness-customer-user harness-engineering-researcher harness-engineering-qa harness-engineering-auditor; do [ -f "$ROOT/learning/$l.md" ] && ok "learning $l" || warn "learning $l missing"; done
section "4. entry prompt"
[ -f "$PROMPT_FILE" ] && ok "entry prompt" || fail "entry prompt missing"
section "5. SKILL.md 내 절대 경로 검증"
if grep -q "~/.claude/" "$ROOT/SKILL.md"; then fail "SKILL.md 에 ~/.claude/ 경로 잔존"; else ok "SKILL.md 경로 치환 완료"; fi
section "6. Task tool 호출 잔존 검사"
if grep -rE "Task tool|subagent_type" "$ROOT/docs" "$ROOT/SKILL.md" 2>/dev/null | head -5; then warn "Task tool / subagent_type 표기 잔존"; else ok "Task tool 표기 0건"; fi
section "7. 5 예외 enum 명시"
for enum in EXT_DEP_PROD_BLOCKED TDD_5X_SAME_SCENARIO QA_OR_REVIEW_5X_SAME_DEFECT AUDIT_LIMIT_EXCEEDED SUBAGENT_RUNTIME_BLOCKED; do if grep -q "$enum" "$ROOT/SKILL.md"; then ok "enum $enum 명시"; else fail "enum $enum 누락"; fi; done
section "8. Mock 금지 정책 명시"
if grep -qE "Mock.*금지|mockito.*금지|NSubstitute" "$ROOT/SKILL.md"; then ok "Mock 금지 정책 명시"; else fail "Mock 금지 정책 누락"; fi
section "9. non-waivable invariant 7개 명시"
if grep -q "non-waivable invariant 7개" "$ROOT/SKILL.md"; then ok "non-waivable invariant 표 존재"; else warn "non-waivable invariant 7개 표 식별 안 됨"; fi
section "10. Codex 포팅 핵심 패턴"
grep -q "codex exec --skip-git-repo-check" "$ROOT/SKILL.md" && ok "codex exec 재귀 패턴" || fail "codex exec 재귀 패턴 누락"
grep -q "2>&1 | tee" "$ROOT/docs/steps/05-review.md" && ok "step5 raw tee" || fail "step5 raw tee 누락"
grep -q "~/.codex/skills/harness-run/learning" "$ROOT/SKILL.md" && ok "learning Codex 경로" || fail "learning Codex 경로 누락"
section "Summary"
printf "PASS: %d / WARN: %d / FAIL: %d\n" "$PASS" "$WARN" "$FAIL"
[ "$FAIL" -gt 0 ] && exit 1 || exit 0
