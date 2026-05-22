# DeepResearch Notes — Harness DDD/TDD Upgrade — 2026-05-22

Tier: Standard
Target passes: 13
Stop reason: coverage complete after 13 passes

## Pass 1
- Query: Domain-Driven Design bounded context ubiquitous language aggregate domain events official reference
- Inspected URLs: https://martinfowler.com/bliki/BoundedContext.html, https://learn.microsoft.com/en-us/azure/architecture/microservices/model/domain-analysis, https://learn.microsoft.com/uk-ua/azure/architecture/microservices/model/tactical-domain-driven-design
- Key finding: Harness should require explicit bounded context, vocabulary, aggregate/invariant candidates, and context relationships before implementation planning.
- Confidence: High
- Remaining gap: Need practical artifact shape.

## Pass 2
- Query: Martin Fowler bounded context domain driven design ubiquitous language
- Inspected URLs: https://martinfowler.com/bliki/BoundedContext.html, https://martinfowler.com/bliki/UbiquitousLanguage.html
- Key finding: Bounded contexts and ubiquitous language are communication and design boundaries, not folder-layout cosmetics.
- Confidence: High
- Remaining gap: Need step-level validation rules.

## Pass 3
- Query: Microsoft domain driven design microservices bounded context aggregates
- Inspected URLs: https://learn.microsoft.com/en-us/azure/architecture/microservices/model/domain-analysis, https://learn.microsoft.com/uk-ua/azure/architecture/microservices/model/tactical-domain-driven-design
- Key finding: Domain analysis should map business capabilities before technology choices; tactical DDD then refines entities, aggregates, and services inside a context.
- Confidence: High
- Remaining gap: Need anti-overengineering rule for small changes.

## Pass 4
- Query: event storming domain driven design requirements discovery
- Inspected URLs: https://www.eventsourcing.dev/best-practices/event-storming, https://learn.microsoft.com/en-us/azure/architecture/microservices/model/domain-analysis
- Key finding: Event storming vocabulary maps cleanly to commands, events, read models, external systems, and hot spots; Harness can use a lightweight event list instead of a full workshop.
- Confidence: Medium
- Remaining gap: Source is useful but less canonical than Evans/Fowler/Microsoft.

## Pass 5
- Query: DDD Crew bounded context canvas aggregate canvas GitHub
- Inspected URLs: https://github.com/ddd-crew/bounded-context-canvas
- Key finding: A bounded-context artifact should include name, responsibility, public interface, dependencies, verification metrics, and open questions.
- Confidence: High
- Remaining gap: Aggregate canvas details not needed for this upgrade.

## Pass 6
- Query: Context Mapper domain driven design bounded context relationships official
- Inspected URLs: https://contextmapper.org/, https://contextmapper.org/docs/context-map/
- Key finding: Context relationships are first-class architecture data. Harness should require upstream/downstream relationship and public contract tracking, even without adopting Context Mapper DSL.
- Confidence: Medium
- Remaining gap: Avoid adding a DSL dependency.

## Pass 7
- Query: test driven development red green refactor official Beck Kent TDD workflow
- Inspected URLs: https://martinfowler.com/bliki/TestDrivenDevelopment.html, https://gds-way.digital.cabinet-office.gov.uk/standards/test-driven-development.html
- Key finding: TDD is not just writing tests; it starts with a test list, then repeats red, green, refactor.
- Confidence: High
- Remaining gap: Need traceability from domain contract to red tests.

## Pass 8
- Query: Test Driven Development red green refactor Martin Fowler
- Inspected URLs: https://martinfowler.com/bliki/TestDrivenDevelopment.html
- Key finding: Test-first thinking forces interface design first; Harness should block implementation when the red test does not name the interface or behavior it drives.
- Confidence: High
- Remaining gap: None.

## Pass 9
- Query: testing pyramid Mike Cohn Martin Fowler test pyramid unit integration end to end
- Inspected URLs: https://martinfowler.com/articles/practical-test-pyramid.html
- Key finding: Harness should require mixed test granularity and keep E2E tests focused on high-value journeys because high-level tests are slower and more brittle.
- Confidence: High
- Remaining gap: Need practical size labels.

## Pass 10
- Query: Google testing blog test certified test sizes small medium large tests
- Inspected URLs: https://testing.googleblog.com/2010/12/test-sizes.html, https://testing.googleblog.com/2011/03/how-google-tests-software-part-five.html
- Key finding: Small/medium/large test sizes provide enforceable constraints around network, database, filesystem, time, and isolation.
- Confidence: High
- Remaining gap: Harness should add labels without forcing language-specific annotations.

## Pass 11
- Query: Google Testing Blog flaky tests hermetic isolation large tests
- Inspected URLs: https://testing.googleblog.com/2017/04/where-do-our-flaky-tests-come-from.html, https://testing.googleblog.com/2016/05/flaky-tests-at-google-and-how-we.html
- Key finding: Larger tests are much more likely to be flaky; Harness QA gates should preserve existing evidence-matrix and persistent-state requirements.
- Confidence: High
- Remaining gap: None.

## Pass 12
- Query: contract testing consumer driven contracts official Pact documentation
- Inspected URLs: https://docs.pact.io/, https://docs.pact.io/implementation_guides/javascript/docs/consumer
- Key finding: Consumer-driven contracts are executable examples between consumer and provider; Harness should represent API/UI/IPC contracts as examples, not just schema prose.
- Confidence: High
- Remaining gap: Avoid requiring Pact specifically.

## Pass 13
- Query: LLM code generation contract tests failing tests prompt study
- Inspected URLs: https://arxiv.org/abs/2510.12047, https://arxiv.org/abs/2402.11910, https://arxiv.org/abs/2408.16601
- Key finding: LLM code can pass normal functional tests while failing explicit contracts; contract-violating tests and requirement-derived tests should be mandatory evidence for Harness.
- Confidence: Medium-High
- Remaining gap: arXiv papers are preprints, but the direction supports existing Harness guardrails.
