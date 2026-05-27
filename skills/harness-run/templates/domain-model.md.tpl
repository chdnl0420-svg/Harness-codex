# Domain Model - {{goal}}

## Scope
- Goal:
- In scope:
- Out of scope:

## Ubiquitous Language
| Term | Meaning | Notes |
|---|---|---|

## Bounded Contexts
| Context | Responsibility | Model Boundary | Integration pattern (Customer-Supplier / Partnership / Published Language / ACL) |
|---|---|---|---|

## Aggregates (Vernon 4-rule)
| Aggregate | Root | Invariants (must hold in single transaction) | Commands | Events | Snapshot every N events |
|---|---|---|---|---|---|

## Entities
| Entity | Aggregate | Identity | Lifecycle (when created / archived) |
|---|---|---|---|

## Value Objects (immutable, equality by value)
| Value Object | Fields | Validation | Equality |
|---|---|---|---|

## Domain Events (past tense, intent over state)
| Event | Triggered by Command | Payload (intent fields only — no Entity/Aggregate object) | Subscribers |
|---|---|---|---|

## Commands (imperative)
| Command | Actor | Target Aggregate | Pre-conditions | Resulting Events |
|---|---|---|---|---|

## Domain Services (cross-aggregate logic)
| Service | Responsibility | Why it's not inside any single aggregate |
|---|---|---|

## Application Services (use cases)
| Use Case | Input (DTO/Command) | Steps (load aggregate → invoke → save) | Output |
|---|---|---|---|

## Repositories
| Repository | Aggregate | Production implementation | In-memory (Fake) implementation |
|---|---|---|---|

## CQRS Read Side
### Queries
| Query | Read Model | Source events | Use case |
|---|---|---|---|

### Projections (Event Sourcing read models)
| Projection | Source events | Idempotent handler | Rebuild策略 |
|---|---|---|---|

### Read model & write model 분리
- Write side: Aggregate + Repository + Event Store
- Read side: Projections + Read Models + Queries
- Eventual consistency 경계: <어디까지 stale 허용>

## Event Sourcing Notes
- Event store: <어디 — `.harness/event-store/` in-memory 등>
- Event versioning: <e.g., `OrderPlacedV1` → `OrderPlacedV2` migration 전략>
- Snapshot strategy: <N events 마다, 또는 시점 기반>
- Compensating events: <모든 state-change 의 rollback pair>

## Inter-Aggregate Reference
| From | To | Reference type (ID only, never object ref) | Sync mechanism (Domain Event + eventual consistency) |
|---|---|---|---|

## Aggregate 간 일관성
- Strong consistency: 같은 Aggregate 내부만
- Eventual consistency: Aggregate 간 (Domain Event 비동기 전파)

## ADR Notes (CQRS + Event Sourcing 풀세트 강제 적용)
- 본 skill 의 강제 정책으로 모든 Aggregate 에 CQRS + ES 적용
- **산업 권고 (Microsoft, Vernon, Calmops) 와 충돌**: 단순 CRUD·MVP·짧은 lifespan 에는 과한 패턴
- 본 회차의 적용 목적: 학습 / 감사 / 일관성 / 본 skill 의 학습 가치
- 프로덕션 적용 시 재검토 필요 사항:
  - 정말 모든 aggregate 가 ES 가 필요한가
  - eventual consistency 가 UX/비즈니스 요구와 양립 가능한가
  - 운영 부담 (snapshot, schema evolution, projection rebuild) 감당 가능한가

## Hotspots (미해결 / 사용자 검토 필요)
- ⚠️ <불확실성>
- ❓ <확정 못한 결정>
