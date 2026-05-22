# Harness Customer User Negative Usability Principles

## Executive Summary

Focused DeepResearch supports making the customer-user rule intentionally skeptical. The strongest evidence is that ordinary usability work depends on observing first-time users' misconceptions in the moment, while LLM user simulators are known to become too cooperative, too uniform, and too positive. Therefore Harness should provide only product execution information, and the customer-user agent should independently test from a first-time ordinary-user stance.

## Scope And Assumptions

- Scope: strengthen Harness Step7 and `harness-customer-user` operating principles.
- Audience: maintainers of the Harness Codex workflow.
- Assumption: Step7 remains a customer friction discovery step, not a release gate.
- Key constraint from user: Harness must not teach the customer-user how to test after launch; customer-user must test with ordinary-person knowledge and a strongly negative, improvement-seeking stance.

## Methodology

Selected tier: Focused, 8 passes. I searched usability research methods, first-time user evaluation, lightweight UX metrics, LLM-simulated-user reliability, and permission/launch friction. Stop reason: coverage complete after focused pass minimum.

## Key Findings

1. Think-aloud testing is valuable because it exposes what users think while moving through the UI; NN/G also warns that facilitator prompts can bias user behavior, which supports keeping Harness instructions minimal and non-leading ([NN/G Think Aloud](https://www.nngroup.com/articles/thinking-aloud-the-1-usability-tool/)).
2. Cognitive walkthrough is explicitly aimed at first-time use without training; the user should not need a manual or hidden expected path to proceed ([Userfocus Cognitive Walkthrough](https://www.userfocus.co.uk/articles/cogwalk.html)).
3. The 5-second test is a first-impression tool, not a full usability verdict; it should flag unclear product purpose, next action, and trust issues ([NN/G 5-Second Test](https://www.nngroup.com/videos/5-second-usability-test/)).
4. SUS/SEQ are useful friction signals, but a single customer-user run must not become a statistical pass/fail benchmark ([NN/G perceived usability](https://www.nngroup.com/articles/measuring-perceived-usability/), [MeasuringU SEQ](https://measuringu.com/seq10/)).
5. LLM-simulated users are unreliable proxies for real humans and can miscalibrate task difficulty and failure patterns, so the agent needs explicit anti-cooperation rules ([Lost in Simulation](https://arxiv.org/abs/2601.17087)).
6. Recent simulator research says baseline LLM users are often cooperative, homogeneous, stylistically uniform, and lacking realistic frustration or ambiguity; the customer-user policy should deliberately counter that behavior ([Beyond Cooperative Simulators](https://arxiv.org/abs/2605.12894), [Mind the Sim2Real Gap](https://arxiv.org/abs/2603.11245)).
7. Permission and first-launch prompts affect trust; ordinary users need plain-language rationale and user-visible benefit, so production-install friction belongs in customer-user reporting ([NN/G Permission Requests](https://www.nngroup.com/articles/permission-requests/)).

## Detailed Analysis

The workflow should separate two concerns:

- Harness caller responsibility: build, install, launch, and tell the sub-agent how to access the product.
- Customer-user responsibility: decide how to explore, where to click, when to give up, and what feels broken, scary, confusing, or unnecessary.

Passing click paths, expected routes, or scoring instructions as persona-facing context risks contaminating the test. The better pattern is to treat `test-guide-<slug>.md` as a hidden oracle or scope reference only. The agent can use it to know which product area matters, but it cannot use it as a manual.

The negative stance is not cosmetic. It is a corrective against LLM simulator bias. The user simulator literature repeatedly flags over-cooperation and positivity; without explicit rules, a customer-user agent will tend to infer intent, forgive ambiguity, and produce tidy feedback. Harness should instead force direct friction language: "I do not know what this means", "this looks scary", "I would close this", "this should be removed", "this needs a plain explanation".

## Evidence Table

| Claim | Evidence | Harness implication |
|---|---|---|
| Facilitator prompts can bias usability behavior | NN/G says think-aloud is useful, but prompts/clarifying questions can change user behavior ([source](https://www.nngroup.com/articles/thinking-aloud-the-1-usability-tool/)) | Harness should not provide test procedure after launch |
| First-time users explore without training | Cognitive walkthrough targets first-use problems and manual-free exploration ([source](https://www.userfocus.co.uk/articles/cogwalk.html)) | Treat unclear UI as product failure, not user failure |
| First impression is only one signal | NN/G frames 5-second testing as first-impression measurement ([source](https://www.nngroup.com/videos/5-second-usability-test/)) | Use it for clarity/trust, not task pass/fail |
| SEQ is task-fresh perceived ease | NN/G explains SEQ is post-task and fresh in memory ([source](https://www.nngroup.com/articles/measuring-perceived-usability/)) | Ask "why was this hard?" when SEQ is low |
| LLM users are not reliable human proxies | arXiv 2601.17087 reports robustness, calibration, and population gaps ([source](https://arxiv.org/abs/2601.17087)) | Add explicit anti-sycophancy, anti-cooperation rules |
| Baseline simulators are too cooperative | arXiv 2603.11245 describes excessive cooperation and uniformly positive feedback ([source](https://arxiv.org/abs/2603.11245)) | Default to skeptical/friction-seeking behavior |
| Production permission prompts affect trust | NN/G says poor permission requests make users uncomfortable, confused, irritated, and may drive uninstall/competitor switching ([source](https://www.nngroup.com/articles/permission-requests/)) | Record scary/unclear first-launch prompts |

## Recommendations

1. Add a top-priority "최상위 동작원칙" above the customer procedure and agent test steps.
2. State that Harness only supplies product execution/launch information and a minimal product brief.
3. Treat `test-guide-<slug>.md` as hidden oracle/scope, not persona-facing test instructions.
4. Make the customer-user default to skeptical, impatient, and friction-seeking.
5. Require every major friction point to include at least one ordinary-language improvement request: change, add, remove, or hide.
6. Keep good points optional and short; the report's main purpose is discomfort, confusion, weirdness, distrust, and abandonment signals.

## Risks, Uncertainties, And Contradictions

- LLM customer-user results are still not a substitute for real user research. The strengthened policy reduces cooperation bias but cannot remove simulation limits.
- `test-guide` handling needs careful wording: the agent needs scope/oracle context, but the persona must not receive it as a manual.
- A strongly negative stance can over-report irritations. That is acceptable for Harness Step7 because the step is not a release gate; it is a friction discovery pass.

## Research Log

1. Think-aloud usability testing.
2. Cognitive walkthrough and first-time use.
3. First-click testing and information scent.
4. 5-second first-impression testing.
5. SUS/SEQ perceived usability metrics.
6. LLM-simulated-user reliability gaps.
7. Cooperative simulator and Sim2Real gap evidence.
8. Permission and first-launch trust friction.

## Sources

- [NN/G: Thinking Aloud](https://www.nngroup.com/articles/thinking-aloud-the-1-usability-tool/)
- [Userfocus: Cognitive Walkthrough](https://www.userfocus.co.uk/articles/cogwalk.html)
- [NN/G: 5-Second Usability Test](https://www.nngroup.com/videos/5-second-usability-test/)
- [NN/G: Measuring Perceived Usability](https://www.nngroup.com/articles/measuring-perceived-usability/)
- [MeasuringU: SEQ](https://measuringu.com/seq10/)
- [arXiv 2601.17087: Lost in Simulation](https://arxiv.org/abs/2601.17087)
- [arXiv 2605.12894: Beyond Cooperative Simulators](https://arxiv.org/abs/2605.12894)
- [arXiv 2603.11245: Mind the Sim2Real Gap](https://arxiv.org/abs/2603.11245)
- [NN/G: Permission Requests](https://www.nngroup.com/articles/permission-requests/)
- [GOV.UK: Moderated Usability Testing](https://www.gov.uk/service-manual/user-research/using-moderated-usability-testing)

