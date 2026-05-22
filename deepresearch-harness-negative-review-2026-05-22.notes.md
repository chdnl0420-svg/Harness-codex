# DeepResearch Notes: Harness Negative Review

Date: 2026-05-22
Tier: Focused
Target passes: 8
Stop reason: coverage complete after 8 focused passes

## Pass 1

- Query: NIST AI Risk Management Framework Govern Map Measure Manage official PDF agent human oversight verification
- Inspected URLs:
  - https://nvlpubs.nist.gov/nistpubs/ai/nist.ai.100-1.pdf
- Key finding: NIST AI RMF requires documented application scope, human oversight processes, component risk controls, and impact characterization. Harness has many textual controls, but weak executable validation for whether those controls actually fired.
- Confidence: High
- Remaining gap: NIST is broad governance guidance, not coding-harness-specific.

## Pass 2

- Query: OWASP Top 10 for LLM Applications 2025 agent excessive agency prompt injection official
- Inspected URLs:
  - https://owasp.org/www-project-top-10-for-large-language-model-applications/
  - https://owasp.org/www-project-mcp-top-10/
- Key finding: OWASP highlights prompt injection, excessive agency, MCP scope creep, command execution, tool poisoning, and contextual prompt payload risks. Harness delegates tool use, shell execution, browser/MCP use, and sub-agent prompts, but its docs focus more on workflow compliance than adversarial context/tool risk.
- Confidence: High
- Remaining gap: OWASP MCP Top 10 is v0.1, so recommendations should be treated as emerging but relevant.

## Pass 3

- Query: OpenAI Codex best practices code review tests official documentation Codex cloud tasks
- Inspected URLs:
  - https://developers.openai.com/codex/cloud
  - https://openai.com/index/introducing-upgrades-to-codex/
  - https://help.openai.com/en/articles/20001107-codex-security
- Key finding: OpenAI positions Codex as a coding agent that can read/edit/run code, but emphasizes sandboxing, command approvals, citations/logs/test results, human review, and validation before surfacing security findings. Harness's noask policy and automatic fallback paths can undermine this if they replace independent verification with self-review or unclear proof.
- Confidence: High
- Remaining gap: Some Codex pages are product docs, not formal standards.

## Pass 4

- Query: Microsoft domain-driven design microservices bounded context official documentation
- Inspected URLs:
  - https://learn.microsoft.com/en-us/dotnet/architecture/microservices/microservice-ddd-cqrs-patterns/ddd-oriented-microservice
- Key finding: Microsoft describes DDD as modeling around business reality, bounded contexts, common language, and invariants. Harness's Domain Contract direction is aligned, but the current doc set can turn DDD into checklist ceremony when not backed by validators and canonical schemas.
- Confidence: High
- Remaining gap: Microsoft's page targets microservices; Harness is a workflow system, so mapping is conceptual.

## Pass 5

- Query: Martin Fowler test driven development red green refactor article
- Inspected URLs:
  - https://martinfowler.com/bliki/TestDrivenDevelopment.html
  - https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/considerations/development-strategy-test-driven-development
- Key finding: TDD's essence is tests first, red-green-refactor, plus a list and sequencing of tests. Harness's STRICT_RED/CHARACTERIZATION/STATIC_ONLY modes are reasonable, but inconsistent artifact extensions and lack of automatic test-impact selection create risk that the process becomes post-hoc documentation.
- Confidence: High
- Remaining gap: TDD success depends on project context and developer discipline.

## Pass 6

- Query: Google Testing Blog test pyramid small medium large tests official
- Inspected URLs:
  - https://testing.googleblog.com/2011/03/how-google-tests-software-part-five.html
  - https://arxiv.org/abs/2603.17973
- Key finding: Google emphasizes test scope language: small tests answer whether code does what it should, medium tests cover nearby interactions, and large tests answer user expectation. TDAD reports that targeted test context reduced regressions, while procedural TDD instructions alone increased regressions in their setting. Harness currently adds process language, but does not provide an executable impact graph or test-selection mechanism.
- Confidence: Medium-High
- Remaining gap: TDAD is an arXiv 2026 toolpaper, not yet an established industry standard.

## Pass 7

- Query: Nielsen Norman Group usability testing 101 5-8 participants qualitative official
- Inspected URLs:
  - https://media.nngroup.com/media/articles/attachments/UsabilityTesting101_Letter_Size.pdf
  - https://media.nngroup.com/media/reports/free/How_To_Recruit_Participants_for_Usability_Studies.pdf
- Key finding: NN/g frames usability testing around realistic participants, realistic tasks, neutral facilitation, and 5-8 qualitative participants. Harness's customer-user step is directionally good, but a single sub-agent persona can overstate confidence unless the report labels it as one synthetic pass and uses severity/triage rather than product acceptance.
- Confidence: Medium
- Remaining gap: The inspected sources are NN/g PDFs and general usability guidance, not AI-agent-specific customer simulation guidance.

## Pass 8

- Query: W3C WCAG accessibility conformance official focus visible contrast
- Inspected URLs:
  - https://w3c.github.io/wcag/guidelines/22/
  - https://www.w3.org/WAI/WCAG21/Understanding/focus-visible.html
- Key finding: WCAG 2.2 requires measurable accessibility properties such as contrast, resize behavior, and focus visibility. Harness's UX gates mention screenshots and accessibility, but the customer/QA path should require explicit accessibility evidence for UI-affecting changes, not only qualitative impressions.
- Confidence: High
- Remaining gap: WCAG applies to web content; non-web apps need platform-specific equivalents.

