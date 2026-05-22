# Red Test — <slug>

## Target
- mode: single | chunk
- chunk: <chunk-N | N/A>
- evidence_mode: STRICT_RED | CHARACTERIZATION | STATIC_ONLY
- risk_reason: <why this mode is valid for this contract_id>
- contract_id: <C1 | C2 | ...>
- related_domain_contract: <Domain Contract 항목>
- implementation_boundary: <허용 파일/금지 파일 요약>

## Failing Behavior
- 실패시킬 동작: <사용자 가치 단위 동작>
- 실패 이유: <현재 구현에서 왜 실패해야 하는지>
- 요구사항 출처: <Domain Contract contract examples / 사용자 요구 / PRD>

## Command
```bash
<실행 명령>
```

## Expected RED
- 기대 실패 메시지 또는 관찰 기준: <구체적 실패>

## Expected GREEN
- 구현 후 PASS 조건: <구체적 성공 기준>

## Characterization Evidence
- current_observation: <required when evidence_mode=CHARACTERIZATION>
- protected_regression: <what existing behavior must not regress>
- strict_red_not_meaningful_because: <why a failing-before-implementation test is not the right evidence>

## Static Evidence
- static_assertion: <required when evidence_mode=STATIC_ONLY>
- runtime_not_applicable_because: <why dynamic runtime behavior is not applicable>
- expected_static_result: <failure/pass condition>

## Contract-Violating Case
- 위반 입력/상태: <API/IPC/persistence/permission/validation/state boundary 위반 케이스>
- 기대 결과: <거부/오류/복구/무시 기준>
- 해당 없음 사유: <순수 내부 리팩토링 등 정말 없을 때만>

## Evidence Type
- <unit_test | component_test | Electron CDP scenario | Playwright scenario | IPC contract test>

## Notes
- 정적 grep/assertion 은 pure validation helper 보조 검증으로만 허용한다.
- 사용자 흐름, async state, persistence, IPC, permission, validation, state-boundary 시나리오는 정적 assertion 만으로 entry evidence 를 충족할 수 없다.
