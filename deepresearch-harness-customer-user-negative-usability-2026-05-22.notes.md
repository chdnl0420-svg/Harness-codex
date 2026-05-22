# DeepResearch Notes: harness-customer-user negative usability principles

- Date: 2026-05-22
- Tier: Focused
- Target passes: 8
- Stop reason: coverage complete after focused pass minimum

## Pass 1

- Query: Nielsen Norman Group thinking aloud usability testing first-time users
- Inspected URLs:
  - https://www.nngroup.com/articles/thinking-aloud-the-1-usability-tool/
  - https://en.wikipedia.org/wiki/Think_aloud_protocol
- Key finding: Think-aloud is useful because it exposes user misconceptions while using the interface, but facilitator prompts can bias behavior. Harness customer user should capture immediate thoughts, not post-hoc polished summaries.
- Confidence: High
- Remaining gap: Need stricter guard against LLM cooperation bias.

## Pass 2

- Query: Nielsen Norman Group cognitive walkthrough 4 questions usability
- Inspected URLs:
  - https://www.userfocus.co.uk/articles/cogwalk.html
  - https://en.wikipedia.org/wiki/Cognitive_walkthrough
- Key finding: Cognitive walkthrough is specifically aimed at first-time use without training and asks whether the user will try the action, see the control, connect it to the result, and receive feedback. This supports "if unclear, fail the step."
- Confidence: Medium-high
- Remaining gap: Need first-impression and first-click evidence.

## Pass 3

- Query: first click testing information scent Jared Spool UIE
- Inspected URLs:
  - https://www.userinterviews.com/ux-research-field-guide-chapter/first-click-testing
  - Search snippets referencing Jared Spool/UIE first-click testing
- Key finding: First-click behavior is a practical proxy for whether the interface gives a usable scent toward the right path. Customer-user should record wrong first clicks instead of correcting course from hidden instructions.
- Confidence: Medium
- Remaining gap: Need first-screen impression method.

## Pass 4

- Query: Nielsen Norman Group 5 second usability test first impression
- Inspected URLs:
  - https://www.nngroup.com/videos/5-second-usability-test/
  - https://www.userlytics.com/resources/glossary/five-second-test/
- Key finding: The 5-second test is for first impressions, not full task success. Harness should use it to catch immediate product clarity/trust issues, then rely on action evidence for task friction.
- Confidence: High
- Remaining gap: Need validated lightweight ratings for task difficulty.

## Pass 5

- Query: System Usability Scale Single Ease Question measuring perceived usability Nielsen Norman Group
- Inspected URLs:
  - https://www.nngroup.com/articles/measuring-perceived-usability/
  - https://measuringu.com/seq10/
- Key finding: SUS is post-test; SEQ is post-task and useful because the task is fresh. Both require enough samples for quantitative benchmarking, so a single harness-customer-user run should treat scores as friction signals, not pass/fail proof.
- Confidence: High
- Remaining gap: Need simulation-specific bias evidence.

## Pass 6

- Query: arXiv Lost in Simulation LLM simulated users unreliable proxies human users agentic evaluations
- Inspected URLs:
  - https://arxiv.org/abs/2601.17087
- Key finding: LLM-simulated users vary by simulator, show systematic miscalibration, surface different failure patterns from humans, and can misrepresent real deployment challenges. Customer-user must explicitly fight the LLM tendency to be a neat proxy.
- Confidence: High
- Remaining gap: Need evidence on over-cooperative simulator behavior.

## Pass 7

- Query: arXiv Beyond Cooperative Simulators real users ambiguous fragmented adversarial language
- Inspected URLs:
  - https://arxiv.org/abs/2605.12894
  - https://arxiv.org/abs/2603.11245
- Key finding: Recent agent-evaluation papers identify LLM simulators as cooperative, homogeneous, stylistically uniform, and lacking realistic frustration/ambiguity. This directly supports a skeptical, impatient, friction-seeking customer-user policy.
- Confidence: High
- Remaining gap: Need production-install trust/friction angle.

## Pass 8

- Query: Nielsen Norman Group mobile app permission requests just in time rationale
- Inspected URLs:
  - https://www.nngroup.com/articles/permission-requests/
  - https://www.gov.uk/service-manual/user-research/using-moderated-usability-testing
- Key finding: Permission requests and task prompts must use plain language, give user-centered rationale, and avoid biasing the participant. Production launch/permission prompts are part of first-use UX and should be judged by ordinary-user trust and confusion.
- Confidence: High
- Remaining gap: None for this focused policy update.

