# Event Storming - {{goal}}

> Brandolini 색상 표준: 🟧 Event / 🟦 Command / 🟨 Aggregate / 💜 Policy / 🟩 ReadModel / 🟪 Hotspot / 🟫 External System / 🧍 Actor

## Actors (🧍)
| Actor | Goal |
|---|---|

## Commands (🟦, 명령형)
| Command | Actor | Target Aggregate | Pre-conditions | Emitted Events |
|---|---|---|---|---|

## Domain Events (🟧, 과거형, intent over state)
| Event | Triggered by Command | Business Meaning (intent) | Subscribers | Version |
|---|---|---|---|---|

### Lifecycle 시작점 자동 검증 (AI Event Storming 누락 5종 게이트 #1)
- [ ] 모든 Aggregate 마다 `*Created` / `*Initialized` 이벤트 존재
- 누락 Aggregate: <list>

### 예외/실패 흐름 자동 추가 (게이트 #2)
- [ ] 모든 Command 마다 `*Rejected` / `*Failed` / `*Cancelled` 후보 존재
- 누락 Command: <list>

### Compensating events (게이트 #3)
| state-change event | compensating event | 사유 |
|---|---|---|
| OrderPlaced | OrderCancelled | refund · rollback |

### Pivotal events (게이트 #5 — 흐름 분기점)
| Event | swimlane 경계 후보? |
|---|---|

## Policies (💜, "Whenever X happens, do Y")
| Policy | When Event Happens | Command Emitted | Bounded Context |
|---|---|---|---|

## Read Models / Views (🟩)
| Read Model | Source Events | Use Case |
|---|---|---|

## External Systems (🟫) — production / BLOCKED 판단 강제
| System | Interaction | Sandbox/Test endpoint | Production endpoint detected? | step 1 BLOCKED 처리 |
|---|---|---|---|---|
| Stripe | Payment | Stripe API host `api.stripe.com` (mode 는 credential 로 결정 — `sk_test_*` test mode 사용, `sk_live_*` BLOCKED). raw credential 절대 본 표에 기록 금지 — `sk_test_<SHA256[:8]>` 형태로 redaction. | YES (live credential 발견) → BLOCKED / NO (test credential) | log entry id |
| SendGrid | Email | mailtrap 등 | YES/NO | |
| ... | | | | |

**모든 row 의 *"Production endpoint detected?"* 가 YES 면 step 1 BLOCKED. NO 인 경우만 step 2 진행 가능.**

## Hotspots (🟪, 게이트 #4)
- ⚠️ <불확실성·결정 못한 부분>
- ⚠️ <hotspot — 안 비워둠. 모호한 부분을 임의 결정으로 채우지 않음>

## Open Questions
- <user-facing question>
