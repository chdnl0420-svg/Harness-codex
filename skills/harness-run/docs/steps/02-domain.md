# step 2 - DDD 도메인 모델링

사용자의 자연어 목표와 step 1 감지 결과를 기준으로 도메인 모델을 먼저 만든다. 이 단계는 구현 전에 반드시 끝나야 하며, 결과는 `.harness/02-domain/` 아래에 남긴다.

## 입력

- `.harness/01-detect/input.md`
- `.harness/01-detect/environment.md`
- 프로젝트의 기존 코드 구조
- 외부 리서치가 필요한 경우 `harness-engineering-researcher` 결과

## 산출물

| 파일 | 내용 |
|---|---|
| `02-domain/domain-model.md` | Bounded Context, Ubiquitous Language, Aggregate, Entity, VO, Repository, Service |
| `02-domain/event-storming.md` | 이벤트, 커맨드, 액터, 정책, 외부 시스템 |
| `02-domain/mermaid.md` | Mermaid 관계도 |
| `02-domain/code-skeleton.md` | 프로젝트 언어에 맞춘 객체별 파일 스켈레톤 |

## 절차

1. 프로젝트가 다루는 핵심 업무 흐름을 도메인 언어로 정리한다.
2. Bounded Context 를 식별한다. 여러 개면 Context 별로 독립 TDD 루프를 만든다.
3. 각 Context 안에서 Aggregate 후보를 뽑고 일관성 경계를 적는다.
4. 모든 Aggregate 에 CQRS + Event Sourcing 구조를 설계한다.
5. 도메인 이벤트는 **상태 변화 결과 (state) 가 아니라 비즈니스 의도 (intent) 를 과거형으로 표현**한다. 예: `RemainingSeatsChangedTo42` (state, 금지) vs `SeatsReserved` (intent, 권장). Microsoft Azure Event Sourcing 권고.
6. Repository 는 인터페이스 + in-memory 구현체 (= Fowler 분류 Fake) 를 함께 설계한다. Mock 은 설계하지 않는다.
7. 코드 스켈레톤을 생성한 직후 `docs/code-structure.md` 기준으로 구조 검사를 한다.
8. 구조 위반이 있으면 **자동 리팩토링 적용 시도**: 객체별·역할별로 파일을 즉시 분리하고 결과를 `02-domain/refactor-applied.md` 에 기록. 자동 적용 실패 시 (예: 사용자 코드 영역 외 수정 권한 부재) `02-domain/refactor-blocked.md` 에 사유 + 사용자 수동 조치 안내. 단순 "계획만" 작성하고 끝내지 않는다.

## 검증 게이트

- [ ] Bounded Context 가 명시됨
- [ ] Aggregate 별 불변식과 일관성 경계가 있음
- [ ] Command / Event / Query / Projection 이 분리됨
- [ ] Event Sourcing 재생, snapshot, event versioning 고려가 있음
- [ ] Repository in-memory 구현체가 계획됨
- [ ] Mermaid 관계도가 있음
- [ ] 코드 스켈레톤이 객체 단위로 분리됨
- [ ] UI 프로젝트면 View/Logic 분리 규칙이 반영됨

## 리서치 반영 메모

Microsoft Azure 문서는 CQRS 와 Event Sourcing 이 복잡도를 크게 올리고 eventual consistency, projection, snapshot, event versioning 고려가 필요하다고 설명한다. 이 skill 은 사용자 결정에 따라 CQRS + Event Sourcing 을 강제하지만, step 2 산출물에는 그 비용과 ADR 검토 지점을 반드시 남긴다.
