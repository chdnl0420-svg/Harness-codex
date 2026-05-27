{{type_prefix}}: {{summary_title_korean_or_english}}

{{free_body_natural_language}}

Refs: .harness/runs/{{run_id}}/summary.md

# ──────────── 작성 규칙 ────────────
# 1. type_prefix 는 summary 의 핵심 변화에서 자동 추론:
#    feat (새 기능) | fix (버그) | refactor (구조 개선·동작 동일) | docs | test | chore | perf | ci
# 2. summary_title 은 한국어/영어 자유, 50자 이내, 명령형.
# 3. free_body 는 자연어 자유 (한국어 OK). 구조 강제 없음 — Why/What/How 중 필요한 것만.
#    소규모 변경이면 본문 생략 가능, 큰 변경이면 3-5 문장.
# 4. Refs 라인은 자동 부착 — summary 위치 가리킴.
# 5. 마지막 줄 (이 주석 포함) 은 commit message 에서 제거.
