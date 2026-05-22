# Deep Research Notes: Harness Pragmatic DDD/TDD Policy

- date: 2026-05-22
- tier: Standard
- pass_count: 13
- stop_reason: enough convergence across DDD, TDD, testing strategy, traceability, and durable workflow sources
- target_session: `019e4f11-e97f-7d33-be72-622d4ddbc03a`

## Question

Current Harness docs require strict DDD/TDD gates. The actual run used DDD/TDD-adjacent evidence, external review, worker QA, and state tracking, but did not always produce strict red artifacts or full matrices. Decide which behavior is better and apply the better policy for future Harness runs.

## Pass Log

1. Local session audit: target run completed chunk-5c, used external Codex review twice, used worker QA, committed `d1a572d`.
2. Local artifact audit: state and events were useful, but event schema was incomplete versus current workflow requirements.
3. DDD source pass: bounded contexts and ubiquitous language support compact contract boundaries, not heavyweight tactical patterns by default.
4. Microsoft DDD pass: service and model boundaries should follow business capabilities, loose coupling, and cohesive purpose.
5. TDD source pass: TDD is test-first, red/green/refactor, and starts from a test list that drives interface design.
6. Testing pyramid pass: small/medium/large evidence should be risk-based; not every contract should be pushed into E2E.
7. E2E risk pass: overusing large E2E checks creates slow/flaky feedback and poor failure localization.
8. Characterization pass: existing behavior preservation is a legitimate testing goal when changing legacy/build wiring.
9. Traceability pass: trace links are valuable for progress, impact analysis, compliance, and collaboration, but maintenance overhead matters.
10. Durable workflow pass: append-only event history and stable instance state are important for resumability and diagnosis.
11. Agentic coding pass: LLM code generation benefits from tests as partial formalization of informal intent.
12. Mismatch synthesis pass: strict current docs are safer for new behavior, but too rigid for static/build-contract chunks.
13. Policy pass: adopt evidence modes: `STRICT_RED`, `CHARACTERIZATION`, `STATIC_ONLY`.

## Source Notes

- Martin Fowler describes TDD as writing a test, making it pass, then refactoring, with an initial test list that guides design: https://martinfowler.com/bliki/TestDrivenDevelopment.html
- Fowler and Microsoft DDD sources support bounded contexts and ubiquitous language as boundary/contract tools, not ceremony: https://martinfowler.com/bliki/BoundedContext.html and https://learn.microsoft.com/en-us/azure/architecture/microservices/model/domain-analysis
- Microsoft tactical DDD places aggregate/service sizing inside bounded context decisions; it should be used when the domain needs it: https://learn.microsoft.com/en-us/azure/architecture/microservices/model/tactical-domain-driven-design
- Google testing guidance supports lower-level tests where possible and a smaller number of large E2E tests: https://testing.googleblog.com/2015/04/just-say-no-to-more-end-to-end-tests.html
- Temporal and Azure Durable Task both use event history/execution history as durable state evidence for workflow replay and diagnostics: https://docs.temporal.io/workflows and https://learn.microsoft.com/en-us/azure/durable-task/common/durable-task-orchestrations
- Microsoft Research reports that test-guided clarification improves LLM code generation accuracy and user evaluation of AI-generated code: https://www.microsoft.com/en-us/research/publication/llm-based-test-driven-interactive-code-generation-user-study-and-empirical-evaluation/
- Springer traceability case study reports both value and maintenance challenges for collaborative traceability: https://link.springer.com/article/10.1007/s00766-018-0306-1

## Decision

Do not keep the previous strict-only rule. Do not copy the actual run's ad hoc looseness either.

Use a hybrid:

- `STRICT_RED` remains default for new behavior, bug fixes, user-visible flows, API/IPC/persistence/permission/validation/state-boundary changes, and high-risk chunks.
- `CHARACTERIZATION` is valid for preserving existing behavior or proving no regression, when strict RED would be artificial.
- `STATIC_ONLY` is valid for pure static contracts such as file presence, build order, export shape, dependency graph, or scope guard.
- All non-strict modes must name the contract_id, command/assertion, current observation or expected result, and why strict RED is not meaningful.
- Static evidence is never enough for user flow, async state, IPC, persistence, permission, validation, or state-boundary behavior.

