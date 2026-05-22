# DDD/TDD Gates

Harness uses DDD and TDD as a traceability spine, not as extra ceremony:

`Domain Contract -> Implementation Boundary -> Test Evidence -> Green Implementation -> QA Evidence`

Use this document when Step 2, Step 3, Step 4, Step 6, or the test guide needs a DDD/TDD decision. Do not add tactical DDD patterns just to look domain-driven. Add only the boundary, contract, and test evidence needed for the requested change.

## Decision Rule

Use a risk-based evidence mode per `contract_id`.

| mode | use when | Step4 entry evidence |
|---|---|---|
| `STRICT_RED` | new behavior, bug fixes, user-visible flows, API/IPC/persistence/permission/validation/state-boundary changes, or any high-risk chunk | a red artifact that fails before implementation |
| `CHARACTERIZATION` | existing behavior must be preserved, package/build wiring is being moved, or the change proves no regression rather than adding behavior | a characterization artifact or embedded plan row with command, current observation, protected contract, and expected post-change result |
| `STATIC_ONLY` | pure static contract such as file presence, build order, export shape, dependency graph, or scope guard | a static assertion row with command, expected failure/pass condition, and why dynamic behavior is not applicable |

`STRICT_RED` remains the default. Downgrading to `CHARACTERIZATION` or `STATIC_ONLY` must be explicit and justified in Step 3. Static assertions cannot be the only evidence for user flow, async state, IPC, persistence, permission, validation, or state-boundary behavior.

## Step 2: Domain Contract Gate

The Step 2 `Domain Contract` should be a compact contract capsule. It must include:

- `bounded_context`: the business or workflow boundary for this change.
- `ubiquitous_language`: user-facing terms and their meanings inside this context.
- `public_contracts`: API, UI, IPC, persistence, permission, validation, or event contracts that other code or users depend on.
- `invariants`: rules that must remain true after the change.
- `commands_and_events`: user/system commands and observable domain events. Keep this lightweight; a full event-storming workshop is not required.
- `context_relationships`: upstream/downstream systems, anti-corruption boundaries, shared-kernel risks, or `none`.
- `contract_examples`: Given/When/Then examples that can become tests.
- `missing_contracts`: contracts not yet known. If non-empty and required for implementation, the related chunk is `BLOCKED / CONTRACT_MISSING`.
- `implementation_boundaries`: files, modules, or directories that may and must not change.

Reject Step 2 output before Step 3 if a required item needed by the current chunk is missing. Do not block on optional tactical DDD detail that is irrelevant to the requested change.

## Step 3: Planning Gate

The implementation plan must carry the contract forward. For normal chunks, a compact `Contract/Test Trace` table is enough. For high-risk chunks, keep separate `Contract Traceability Matrix` and `Test Design Matrix` tables.

### Compact Contract/Test Trace

| contract_id | domain term/rule | files allowed | implementation step | evidence_mode | command | expected red/current | expected green | QA evidence |
|---|---|---|---|---|---|---|---|---|
| C1 | <rule> | <paths> | <step> | STRICT_RED | <cmd> | <failure> | <pass> | <evidence> |

Every changed file must map to at least one `contract_id`. A file outside `files allowed` is a boundary violation unless Step 2 is revised first.

### Full Matrices

Use the full matrices when the change crosses process boundaries, persists state, changes permissions/validation, changes IPC/API contracts, or has more than one independent test strategy.

Contract traceability:

| contract_id | domain term/rule | files allowed | files forbidden | implementation step | test evidence | QA evidence |
|---|---|---|---|---|---|---|
| C1 | <rule> | <paths> | <paths> | <step> | <red/characterization/static artifact> | <evidence> |

Test design:

| test_id | contract_id | evidence_mode | test size | test type | command | expected red/current | expected green |
|---|---|---|---|---|---|---|---|
| T1 | C1 | STRICT_RED | small/medium/large | unit/contract/component/e2e/static | <cmd> | <failure/current observation> | <pass> |

Test size guidance:

- `small`: no network, no database, no filesystem mutation except temp fixtures, no sleeps.
- `medium`: local process, local database, localhost, or component integration allowed.
- `large`: browser, full app, external service, or end-to-end journey.

Prefer small tests for invariants and pure behavior, medium tests for API/IPC/persistence contracts, and large tests only for high-value user journeys.

## Step 4: TDD Gate

Step 4 cannot start until each planned `contract_id` has valid entry evidence for its evidence mode.

`STRICT_RED` evidence is valid only if it:

- Names the `contract_id` it protects.
- Names the user-visible or domain behavior it drives.
- Includes the exact command to run.
- Records the expected RED failure before implementation.
- Records the expected GREEN condition after implementation.
- Includes at least one contract-violating case for API, IPC, persistence, permission, validation, or state-boundary changes.

`CHARACTERIZATION` evidence is valid only if it:

- Names the `contract_id` it protects.
- Records the current behavior or current failure being preserved.
- Includes the exact command to run.
- Explains why strict RED is not meaningful for this chunk.
- States the expected post-change result and at least one regression it guards against.

`STATIC_ONLY` evidence is valid only if it:

- Names the `contract_id` it protects.
- Includes the exact static command or assertion.
- Explains why dynamic runtime behavior is not applicable.
- States the expected failure/pass condition.

If required evidence is absent, not tied to Step 2 contracts, or was invented after implementation, mark Step 4 `BLOCKED / TDD_MISSING`.

## Step 6: QA Evidence Gate

QA must validate the same contracts named in Step 2 and Step 3.

The test guide and QA report must include:

- Domain examples covered.
- Contract-violating examples covered when applicable.
- Evidence mode and evidence type for each scenario.
- Evidence path or trace.
- Persistent-state restore evidence when state is changed.
- A note for any contract not tested and why.

PASS is invalid when a contract marked in the trace table has no matching evidence, or when a `STRICT_RED` contract is only checked by static evidence.

## Minimalism Rule

Use DDD/TDD to reduce ambiguity. Do not add repositories, aggregates, event sourcing, CQRS, Pact, Context Mapper, or new test frameworks unless the project already uses them or the specific change requires them.
