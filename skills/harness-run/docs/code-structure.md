# 코드 구조 규칙 — 객체 단위 분리 + UI ↔ 기능 분리

모든 코드 생성 지점에서 만드는 코드 파일은 아래 두 규칙을 무조건 따른다. 적용 시점은 step 2 코드 스켈레톤 생성 직후, step 3 TDD Green 직후 Refactor 단계, step 7 audit 점검이다.

---

## 규칙 1: 객체 단위 분리 (CRITICAL)

**코드 파일은 객체지향 단위로 쪼갠다.** 한 파일에 두 객체를 같이 쓰지 않는다.

| 객체 종류 | 별도 파일 |
|---|---|
| **Aggregate Root** | 1 객체 = 1 파일 |
| **Entity** | 1 객체 = 1 파일 |
| **Value Object** | 1 객체 = 1 파일 |
| **Domain Event** | 1 이벤트 = 1 파일 |
| **Command** | 1 커맨드 = 1 파일 |
| **Repository** (인터페이스) | 1 Aggregate 마다 1 파일 |
| **Repository** (in-memory 구현체) | 인터페이스마다 1 파일 |
| **Domain Service** | 1 책임 = 1 파일 |
| **Application Service** | 1 use case = 1 파일 |
| **Event Handler** (CQRS read model) | 1 이벤트 처리 = 1 파일 |
| **Query Handler** (CQRS 조회) | 1 쿼리 = 1 파일 |
| **Projection** (Event Sourcing) | 1 read model = 1 파일 |

### 폴더 구조 예 (`03-aggregate-<name>/skeleton/`)

```
03-aggregate-order/
└── skeleton/
    ├── aggregate/
    │   └── Order.<ext>
    ├── entity/
    │   └── OrderLine.<ext>
    ├── vo/
    │   ├── Money.<ext>
    │   ├── OrderId.<ext>
    │   └── ShippingAddress.<ext>
    ├── event/
    │   ├── OrderPlaced.<ext>
    │   ├── OrderPaid.<ext>
    │   └── OrderCancelled.<ext>
    ├── command/
    │   ├── PlaceOrder.<ext>
    │   ├── PayOrder.<ext>
    │   └── CancelOrder.<ext>
    ├── repository/
    │   ├── OrderRepository.<ext>            # 인터페이스
    │   └── InMemoryOrderRepository.<ext>    # in-memory 구현체 (Mock 금지)
    ├── service/
    │   ├── OrderPricingService.<ext>        # Domain Service
    │   └── PlaceOrderUseCase.<ext>          # Application Service
    ├── query/
    │   ├── GetOrderByIdQuery.<ext>          # CQRS 조회
    │   └── ListPendingOrdersQuery.<ext>
    └── projection/
        └── OrderListProjection.<ext>        # Event Sourcing read model
```

---

## 규칙 2: UI ↔ 기능 분리 (UI 있는 프로젝트만)

**UI 가 있는 프로젝트는 컴포넌트마다 UI 파일 1개 + 기능 파일 1개로 무조건 분리.**

| 파일 | 들어가는 것 | 안 들어가는 것 |
|---|---|---|
| **UI 파일** | 마크업·스타일·표현 | 상태 변경·비즈니스 로직·검증 |
| **기능 파일** | 상태·이벤트 처리·입력 검증·외부 호출 | 마크업·스타일 |

**UI 는 기능을 호출만 한다. 기능은 UI 를 모른다.**

### 예: 메시지 입력창

| 파일 | 내용 |
|---|---|
| `MessageInputView.tsx` | `<form>`·`<input>`·`<button>`·스타일링·placeholder |
| `useMessageInput.ts` | `useState`·`validate()`·`send()`·debounce·error 상태 |

### 언어·프레임워크별 이름 규약 (step 1 자동 선택)

| 언어 / 프레임워크 | UI 파일 | 기능 파일 |
|---|---|---|
| React / Next.js | `MessageInput.tsx` | `useMessageInput.ts` |
| Vue 3 | `MessageInput.vue` | `useMessageInput.ts` |
| Svelte | `MessageInput.svelte` | `messageInput.ts` |
| SwiftUI | `MessageInputView.swift` | `MessageInputModel.swift` (또는 `MessageInputViewModel.swift`) |
| Flutter | `message_input_view.dart` | `message_input_controller.dart` |
| Android Compose | `MessageInputScreen.kt` | `MessageInputViewModel.kt` |
| C# WPF | `MessageInputView.xaml` + `MessageInputView.xaml.cs` | `MessageInputViewModel.cs` |
| Unity (uGUI) | `MessageInputView.cs` | `MessageInputPresenter.cs` |
| 일반 (감지 실패) | `<이름>.view.<ext>` | `<이름>.logic.<ext>` |

---

## UI 없는 프로젝트

서버 · CLI · 라이브러리 · 데몬은 **규칙 1 (객체 단위 분리)** 만 적용. UI ↔ 기능 분리는 생략.

---

## 폴더 배치 규칙

**경로 컨벤션**: 모든 산출물 경로는 메인 Codex 가 자동으로 `.harness/runs/<run-id>/...` prefix 를 추가한다 (step 1 부트스트랩 정책). 아래 표의 짧은 경로는 shorthand 이며 실행 시에는 회차 폴더 안에 들어간다.

| 짧은 경로 (shorthand) | 실제 위치 | 무엇이 들어가나 |
|---|---|---|
| `<project root>/<코드 폴더>/` | 그대로 | 사용자 프로젝트의 실제 코드 (step 3 TDD 결과물) |
| `.harness/02-domain/` | `.harness/runs/<run-id>/02-domain/` | 도메인 모델 문서 (`model.md`·`event-storming.md`·`mermaid.md`) |
| `.harness/03-aggregate-<name>/skeleton/` | `.harness/runs/<run-id>/03-aggregate-<name>/skeleton/` | Aggregate 별 코드 스켈레톤 (참고용) |
| `.harness/03-aggregate-<name>/tdd/` | `.harness/runs/<run-id>/03-aggregate-<name>/tdd/` | TDD 사이클 기록 (`cycle-001.md` …) |
| `.harness/ui/<screen>/` | `.harness/runs/<run-id>/ui/<screen>/` | UI 프로젝트 컴포넌트 스켈레톤 — `<Component>.view.<ext>` + `<Component>.logic.<ext>` |

**중요**: 스켈레톤 폴더는 **참고용**. 실제 TDD 가 만든 코드는 사용자 프로젝트의 정상 폴더 (예: `src/domain/order/`) 에 배치된다. 스켈레톤은 도메인 모델링 시점의 "이렇게 쪼갠다" 청사진이고, TDD 단계에서는 사용자 프로젝트의 컨벤션을 따라가며 같은 분리 규칙을 유지한다.

---

## 왜 (중학생 설명)

한 파일에 여러 객체·기능이 섞여 있으면, 한 곳을 고치다가 옆 기능이 망가지기 쉽다. UI 와 비즈니스 로직까지 한 파일에 있으면 디자인만 손대도 로직이 망가질 수 있다. 작게 쪼개두면:

1. **한쪽만 손볼 수 있다** — UI 디자인 바꿀 때 기능 파일은 안 건드림.
2. **테스트 쉽다** — 기능 파일만 단위 테스트할 수 있음 (UI 없이).
3. **다른 사람이 이해하기 쉽다** — 파일 이름만 보고 어디서 뭐 하는지 안다.
4. **Mock 안 써도 된다** — 인터페이스 + in-memory 구현체로 진짜 객체를 갈아 끼울 수 있음.

---

## 파일 길이 정책 (단일 정합 — 모든 step·agent 참조)

- **목표**: 200줄 이하 (한 객체 = 한 파일 원칙에서 자연스럽게 도출).
- **경고 임계 (WARNING)**: 200줄 초과 시 step 7 audit 가 `MEDIUM` finding 발행.
- **하드 한계 (HARD CAP)**: 400줄 — 초과 시 step 3 Refactor 단계가 자동 분리 시도, audit 는 `HIGH` finding 발행.
- **절대 한계**: 800줄 — 초과 시 step 7 audit 가 `CRITICAL` finding 으로 분리 강제.

본 정책이 SKILL.md / workflow.md / step 3 03-tdd.md / step 4 04-qa.md / agent qa.md 모두에서 동일하게 참조된다. 글로벌 룰 (`~/.codex/rules/common/coding-style.md`) 의 "200-400 줄 typical, 800 max" 가이드와 호환.

## 코딩 스타일 글로벌 룰 참조

- 작은 파일 (위 정책): `~/.codex/rules/common/coding-style.md`
- 불변성 (immutability): `~/.codex/rules/common/coding-style.md`
- 에러 처리: `~/.codex/rules/common/coding-style.md`
- 입력 검증 (시스템 경계): `~/.codex/rules/common/coding-style.md`
- L9ASIA C# 컨벤션 (감지된 언어가 C# 일 때): `C:\Users\NX3GAMES\.codex\l9asia-client-coding-conventions.md`

본 코드 구조 규칙이 위 룰과 충돌하면 본 규칙 우선 (객체 단위·UI↔기능 분리는 본 skill 핵심 정책).
