# Red Test — <slug>

## Target
- mode: single | chunk
- chunk: <chunk-N | N/A>
- related_domain_contract: <Domain Contract 항목>

## Failing Behavior
- 실패시킬 동작: <사용자 가치 단위 동작>
- 실패 이유: <현재 구현에서 왜 실패해야 하는지>

## Command
```bash
<실행 명령>
```

## Expected RED
- 기대 실패 메시지 또는 관찰 기준: <구체적 실패>

## Expected GREEN
- 구현 후 PASS 조건: <구체적 성공 기준>

## Evidence Type
- <unit_test | component_test | Electron CDP scenario | Playwright scenario | IPC contract test>

## Notes
- 정적 grep/assertion 은 pure validation helper 보조 검증으로만 허용한다.
- 사용자 흐름, async state, persistence, IPC 시나리오는 정적 assertion 만으로 red artifact 를 충족할 수 없다.
