# Harness-codex Negative Review

Date: 2026-05-22
Research tier: Focused
Research passes: 8
Stop reason: coverage complete

## Executive Summary

Harness is trying to solve the right problem: prevent AI coding agents from skipping domain framing, review, TDD, QA, and customer validation. The negative finding is that the current system is now so instruction-heavy and internally inconsistent that it can fail as an operating procedure. Several "single source of truth" claims are contradicted by sibling files, artifact paths drift between `.html` and `.md`, and some noask rules contradict step-level user-decision text. That means a future agent may comply with one document and violate another.

Highest-risk issues:

1. Codex review fallback policy is contradictory.
2. Implementation/progress artifact paths are inconsistent enough to break step transitions.
3. DDD/TDD gates are mostly prose, not executable enforcement.
4. Agent/MCP/security risks are under-modeled for a workflow that intentionally delegates tool use.
5. Customer-user testing risks false confidence because one synthetic persona is treated as a late workflow gate-adjacent artifact.

## Scope And Assumptions

Scope:

- Local repo: `C:\Users\NX3GAMES\Documents\Obsidian Vault\Harness-codex`
- Focus files: `skills/harness/**`, root `agents/**`, recent deepresearch artifacts
- Review posture: intentionally negative; this report emphasizes failure modes over strengths.

Assumptions:

- The user wants a critical process/design review, not a code patch.
- `/harness` itself was not invoked, so this review uses the shared `deepresearch` skill, not the slash-only Harness workflow.
- The report is Markdown because the shared `deepresearch` skill requires a Markdown report file.

## Methodology

- Local inspection: read Harness entrypoint, workflow, step docs, DDD/TDD gate docs, review/customer procedures, and searched for contradiction patterns.
- External research: 8 focused web passes across NIST AI RMF, OWASP LLM/MCP risks, OpenAI Codex docs, DDD, TDD, testing scope, usability testing, and WCAG.
- Evaluation rule: a Harness rule is treated as risky when it is internally contradictory, hard to execute deterministically, or weaker than the external baseline it claims to approximate.

## Key Findings

### 1. P1 - Codex Review Fallback Has Two Opposite Policies

Local evidence:

- `skills/harness/docs/procedures/codex-review-procedure.md` says exit code `2` means login required and `fallback 금지` at line 41.
- `skills/harness-review/SKILL.md` says exit code `2` automatically falls back to a helper or caller Codex direct review at line 34.
- The wrapper also says the older "fallback 금지" policy is not used at line 38, while the procedure file labels itself the single source of truth.

Why this is bad:

OpenAI's Codex Security flow emphasizes validation before surfacing findings and human review before code changes; it also frames review artifacts, logs, and tests as part of trust in the result [OpenAI Codex Security](https://help.openai.com/en/articles/20001107-codex-security). If Harness silently degrades from external Codex review to self-review depending on which entrypoint the agent read, the "independent verifier" promise collapses.

Impact:

- A run can produce `LGTM YES` or `UNKNOWN/BLOCKED` based solely on doc selection.
- The user may believe Codex external review happened when it did not.
- Future maintenance will keep reintroducing this because both files claim authority.

Recommendation:

- Pick one policy. For a negative-safety default, make `codex-review-procedure.md` authoritative: exit 2 blocks, exit 3 may fallback but must never yield `LGTM YES` unless independent context separation is proven.
- Add a small grep-based consistency test that fails when `fallback 금지` and `exit 2 ... 자동 fallback` coexist.

### 2. P1 - Artifact Extension And Path Drift Will Break The Workflow

Local evidence:

- Step3 says single-mode output is `implementation-<slug>.html` at `skills/harness/docs/steps/step3-impl-plan.md:4`.
- The same file later requires sections inside `implementation-<slug>.md` at line 82.
- Step4 requires reading `.harness/implementation-<slug>.md` at `skills/harness/docs/steps/step4-impl.md:8`.
- Progress paths drift across `.harness/progress-<slug>.md`, `.harness/progress/progress-<slug>.md`, and `progress-<slug>.html` in `step3-impl-plan.md:124`, `step3-impl-plan.md:159`, `step3-impl-plan.md:206`, and `step4-impl.md:5`.
- Step3 checks `.harness/reviews/review-<slug>.md` at line 12 but reads `.harness/review-<slug>.md` at line 21.

Why this is bad:

A workflow that depends on canonical state cannot tolerate ambiguous artifact paths. NIST AI RMF expects application scope, risk controls, and component risks to be documented and controlled, not inferred from inconsistent projections [NIST AI RMF](https://nvlpubs.nist.gov/nistpubs/ai/nist.ai.100-1.pdf). Here, the agent can follow one line exactly and fail the next step.

Impact:

- Step3 can write HTML, Step4 can look for MD, and the run blocks even though the plan exists.
- Review loop detection can miss the latest review because `.harness/review-...` and `.harness/reviews/review-...` differ.
- Progress/state drift becomes normal, not exceptional.

Recommendation:

- Define a single artifact manifest table in one machine-readable file, such as `skills/harness/docs/artifacts.json`.
- Update all docs from that manifest or add a CI script that checks every documented path token.
- For implementation plans, choose `.html` or `.md`. Current SKILL.md says implementation plans are HTML, so step4 and step3 internals should stop referencing `.md`.

### 3. P1 - DDD/TDD Gates Are Strong Prose But Weak Enforcement

Local evidence:

- DDD/TDD modes are specified in `skills/harness/docs/ddd-tdd-gates.md:15-19`.
- Step4 blocks when evidence is missing at `skills/harness/docs/steps/step4-impl.md:11`.
- Step6 requires evidence matrices and rejects static-only evidence for async/state paths at `skills/harness/docs/steps/step6-qa.md:39-40` and `:65`.

Why this is bad:

The policy is conceptually aligned with DDD and TDD. Microsoft describes DDD around bounded contexts and shared language [Microsoft DDD](https://learn.microsoft.com/en-us/dotnet/architecture/microservices/microservice-ddd-cqrs-patterns/ddd-oriented-microservice), and Fowler describes TDD as test-list plus red-green-refactor [Fowler TDD](https://martinfowler.com/bliki/TestDrivenDevelopment.html). The problem is that Harness mostly asks an agent to remember and self-enforce this. A 2026 TDAD paper found targeted test context reduced regressions, while adding TDD procedural instructions alone increased regressions in that experiment [TDAD](https://arxiv.org/abs/2603.17973). That is directly relevant: Harness currently adds many procedural instructions but no test-impact graph or validator.

Impact:

- Agents can produce plausible `Contract/Test Trace` tables after implementation.
- `STATIC_ONLY` downgrades may be justified in prose without a real runtime blocker.
- Contract IDs can drift between domain, plan, red evidence, QA guide, and report with no parser catching it.

Recommendation:

- Add an executable validator for `Domain Contract`, `Contract/Test Trace`, red evidence, and QA evidence matrix.
- Require each changed file to map to `contract_id` via a simple schema, not only markdown table text.
- Add a "post-hoc evidence detector": red evidence file modified after implementation diff starts should mark `TDD_MISSING`.

### 4. P1 - Noask Policy Still Contains User-Decision Leaks

Local evidence:

- SKILL.md says `/harness` is noask and only two exception points can call `request_user_input` or a normal question at `skills/harness/SKILL.md:94`, `:113`, and `:119`.
- Step6 says if all automation tools are unavailable, report BLOCKED and request a user decision at `skills/harness/docs/steps/step6-qa.md:54`.
- Step6 also offers "사용자 명시 동의 스킵 — 다음 step 으로 진행 (test 약식 완료 처리)" at line 81.
- The workflow bans "완료 처리" style wording elsewhere, so "test 약식 완료 처리" undermines the anti-bypass language.

Why this is bad:

Noask is a contract with the user: either the workflow continues automatically or stops under defined rules. Leaking user-decision calls into lower-level steps makes behavior unpredictable, and "skip to next step" after blocked QA is the exact failure mode the policy tries to prevent.

Impact:

- A noask run may still ask the user early, violating its own UX promise.
- A blocked QA path can be laundered into step7/step8 if the agent follows the wrong line.
- The policy becomes hard for sub-agents to follow because the language contradicts itself.

Recommendation:

- Replace all "사용자 결정 요청" in step docs with the exact noask branch names from SKILL.md.
- Delete "test 약식 완료 처리"; if user-approved skip remains, label it as `QA_NOT_PERFORMED_USER_ACCEPTED_RISK`, not completion.

### 5. P2 - Agent Security Risks Are Under-Specified For A Tool-Heavy Workflow

Local evidence:

- Harness explicitly uses sub-agents, Codex CLI, MCP/browser tools, shell commands, and external research.
- SKILL.md mentions MCP/browser outputs and `file://` reporting rules, but does not define an adversarial-context threat model for tool outputs or retrieved documents.

Why this is bad:

OWASP MCP Top 10 calls out privilege escalation by scope creep, command injection, tool poisoning, and prompt injection via contextual payloads [OWASP MCP Top 10](https://owasp.org/www-project-mcp-top-10/). OWASP LLM Top 10 treats LLM app risks as a core security taxonomy [OWASP LLM Top 10](https://owasp.org/www-project-top-10-for-large-language-model-applications/). OpenAI also notes that network/MCP access expands capability and risk, and recommends review before production changes [OpenAI Codex upgrades](https://openai.com/index/introducing-upgrades-to-codex/).

Impact:

- A malicious document in research context could steer sub-agent prompts.
- A tool output could be treated as instruction rather than data.
- noask plus tool access raises the blast radius of a prompt-injection failure.

Recommendation:

- Add a security section that classifies all retrieved files, web pages, MCP output, and test fixtures as untrusted data.
- Require explicit quoting/isolation when passing external content to sub-agents.
- Add least-privilege rules for shell, MCP, browser, and network use per step.

### 6. P2 - Customer Testing Can Create False Confidence

Local evidence:

- Step7 is mandatory once QA passes and uses one `harness-customer-user` sub-agent.
- Step7 says the result is not a gate, but later complete handling can auto-start new work from customer recommendations.

Why this is bad:

NN/g's usability guidance emphasizes realistic participants, realistic tasks, neutral facilitation, and 5-8 participants for qualitative testing [NN/g Usability Testing 101](https://media.nngroup.com/media/articles/attachments/UsabilityTesting101_Letter_Size.pdf). A single synthetic persona can be useful as a heuristic inspection, but it should not be framed like a customer validation substitute.

Impact:

- One simulated user may overfit to prompt wording.
- Customer findings can trigger follow-up work without a severity rubric.
- The system may treat "general user reaction" as broader evidence than it is.

Recommendation:

- Rename step7 output semantics to `synthetic customer walkthrough`, not customer validation.
- Add severity fields: blocker, major, minor, suggestion.
- Require "confidence: single synthetic pass" in the report header.

### 7. P2 - UI/Accessibility Evidence Is Not Explicit Enough

Local evidence:

- Step2 has a UX keyword gate and asks for visual artifacts.
- Step6 evidence types include screenshot, DOM, computed style, and static assertions.
- No UI path consistently requires WCAG-level contrast/focus/keyboard checks when UI is affected.

Why this is bad:

WCAG 2.2 defines concrete measurable criteria such as contrast, resize text, and focus behavior [WCAG 2.2](https://w3c.github.io/wcag/guidelines/22/). Harness's qualitative screenshot/click evidence can miss accessibility regressions unless the guide explicitly requires them.

Impact:

- A UI change can pass with screenshots while keyboard focus is invisible.
- Color/contrast regressions can pass customer persona testing because the persona is not an accessibility tool.

Recommendation:

- For UX-keyword tasks, require at least one accessibility evidence row: keyboard navigation, focus visibility, contrast, and resize/reflow where applicable.
- Treat missing accessibility row as `PASS_WITH_LIMITATIONS` or `GUIDE_MISSING`.

### 8. P3 - Duplicate Agent Specs Create Drift Risk

Local evidence:

- Root `agents/harness-customer-user.md` and `skills/harness/agents/harness-customer-user.md` both exist.
- Root `agents/harness-qa-engineer.md` and `skills/harness/agents/harness-qa-engineer.md` both exist.
- The runtime bridge says read root `~/.codex/agents/<agent>.md` first, then fallback to skill path.

Why this is bad:

Duplicated operational specs are acceptable only if generated from one source. Otherwise, fixes land in one copy and a runtime uses the other. This is particularly risky for safety-critical prompt headers such as Prior Learning and hidden oracle isolation.

Recommendation:

- Pick one source and generate/copy the other at install time.
- Add a checksum or installer test proving duplicate specs are identical.

## Evidence Table

| Finding | Local evidence | External baseline | Risk |
|---|---|---|---|
| Review fallback conflict | `codex-review-procedure.md:41`, `harness-review/SKILL.md:34` | OpenAI validation/human review guidance | P1 |
| Artifact path drift | `step3-impl-plan.md:4`, `:82`, `step4-impl.md:8` | NIST documented controls | P1 |
| Prose-only DDD/TDD | `ddd-tdd-gates.md`, `step4-impl.md`, `step6-qa.md` | Fowler TDD, Microsoft DDD, TDAD | P1 |
| noask leaks | `SKILL.md:94`, `step6-qa.md:54`, `:81` | Codex review/test evidence expectations | P1 |
| Tool/prompt security | Harness sub-agent/MCP/browser/shell design | OWASP LLM/MCP, OpenAI sandboxing | P2 |
| Synthetic customer confidence | `step7-customer.md` | NN/g usability testing guidance | P2 |
| Accessibility evidence gap | Step2 UX + Step6 evidence types | WCAG 2.2 | P2 |
| Duplicate specs | `agents/**`, `skills/harness/agents/**` | configuration hygiene inference | P3 |

## Risks, Uncertainties, And Contradictions

- The report is intentionally negative; it underweights benefits such as stronger anti-skip language and sub-agent separation.
- Some issues may be resolved by installation scripts outside the inspected docs; however, the docs themselves are the runtime instruction surface, so contradictions remain operationally relevant.
- TDAD is recent research. Its strongest use here is not "adopt TDAD", but "procedural TDD prompts alone are not enough."
- NN/g usability guidance is human-study guidance. It supports labeling the customer-user agent as heuristic/synthetic, not rejecting it entirely.

## Recommendations

1. Fix contradictions before adding features.
   - Normalize artifact paths/extensions.
   - Pick one Codex fallback policy.
   - Remove noask/user-decision conflicts.

2. Add executable validators.
   - Artifact manifest validator.
   - Contract/test trace validator.
   - Review/QA state pointer validator.

3. Add an agent security model.
   - Treat web/MCP/tool outputs as untrusted.
   - Define least privilege per step.
   - Require context isolation when passing external text to sub-agents.

4. Downgrade customer testing claims.
   - Rename as synthetic walkthrough.
   - Add severity and confidence labels.
   - Do not let one synthetic persona imply real customer validation.

5. Make accessibility evidence mandatory for UI work.
   - Keyboard/focus/contrast evidence should be part of the test guide when UX keywords trigger.

## Research Log

1. NIST AI RMF: governance, scope, risk controls, oversight.
2. OWASP LLM/MCP: prompt injection, excessive agency, MCP scope creep, command injection, tool poisoning.
3. OpenAI Codex docs: sandboxing, review, validation, citations/logs/tests, human review.
4. Microsoft DDD: bounded contexts, shared language, invariants.
5. Fowler/Microsoft TDD: test-first and red-green-refactor.
6. Google Testing + TDAD: test scope and targeted test context for agents.
7. NN/g usability testing: realistic participants/tasks, neutral facilitation, 5-8 qualitative participants.
8. WCAG 2.2: measurable accessibility criteria.

## Sources

- NIST, [Artificial Intelligence Risk Management Framework 1.0](https://nvlpubs.nist.gov/nistpubs/ai/nist.ai.100-1.pdf)
- OWASP, [Top 10 for LLM Applications](https://owasp.org/www-project-top-10-for-large-language-model-applications/)
- OWASP, [MCP Top 10](https://owasp.org/www-project-mcp-top-10/)
- OpenAI, [Codex web documentation](https://developers.openai.com/codex/cloud)
- OpenAI, [Introducing upgrades to Codex](https://openai.com/index/introducing-upgrades-to-codex/)
- OpenAI Help Center, [Codex Security](https://help.openai.com/en/articles/20001107-codex-security)
- Microsoft Learn, [Designing a DDD-oriented microservice](https://learn.microsoft.com/en-us/dotnet/architecture/microservices/microservice-ddd-cqrs-patterns/ddd-oriented-microservice)
- Martin Fowler, [Test Driven Development](https://martinfowler.com/bliki/TestDrivenDevelopment.html)
- Google Testing Blog, [How Google Tests Software - Part Five](https://testing.googleblog.com/2011/03/how-google-tests-software-part-five.html)
- Alonso, Yovine, Braberman, [TDAD: Test-Driven Agentic Development](https://arxiv.org/abs/2603.17973)
- Nielsen Norman Group, [Usability Testing 101](https://media.nngroup.com/media/articles/attachments/UsabilityTesting101_Letter_Size.pdf)
- Nielsen Norman Group, [How To Recruit Participants for Usability Studies](https://media.nngroup.com/media/reports/free/How_To_Recruit_Participants_for_Usability_Studies.pdf)
- W3C, [Web Content Accessibility Guidelines 2.2](https://w3c.github.io/wcag/guidelines/22/)
- W3C WAI, [Understanding Focus Visible](https://www.w3.org/WAI/WCAG21/Understanding/focus-visible.html)

