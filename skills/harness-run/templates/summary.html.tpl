<!doctype html>
<html lang="ko">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>harness Summary — {{run_id}}</title>
  <style>
    :root { color-scheme: light; font-family: system-ui, Arial, sans-serif; --accent:#3b82f6; --danger:#dc2626; --warning:#d97706; --success:#16a34a; --muted:#666; }
    * { box-sizing: border-box; }
    body { margin: 0; background: #f7f7f5; color: #1f2933; }
    main { max-width: 1120px; margin: 0 auto; padding: 24px; height: 100vh; display: flex; flex-direction: column; }
    header { margin-bottom: 16px; }
    h1 { margin: 0 0 4px; font-size: 26px; }
    h2 { margin: 16px 0 8px; font-size: 18px; }
    [role="tablist"] { display: flex; gap: 4px; border-bottom: 2px solid #ddd; flex-wrap: wrap; }
    [role="tab"] { padding: 10px 16px; border: 0; background: transparent; cursor: pointer; font: inherit; color: var(--muted); border-bottom: 2px solid transparent; margin-bottom: -2px; }
    [role="tab"][aria-selected="true"] { color: var(--accent); border-bottom-color: var(--accent); font-weight: 600; }
    [role="tab"]:focus-visible { outline: 2px solid var(--accent); outline-offset: 2px; }
    [role="tabpanel"] { flex: 1; overflow: auto; padding: 12px 0; min-height: 0; }
    [role="tabpanel"][hidden] { display: none; }
    .cards { display: grid; grid-template-columns: repeat(3, minmax(0, 1fr)); gap: 10px; }
    .card { border: 1px solid #d8d8d0; border-radius: 8px; background: #fff; padding: 12px; overflow: auto; max-height: 200px; }
    .label { color: var(--muted); font-size: 12px; }
    .value { margin-top: 6px; font-size: 18px; font-weight: 700; }
    .value.fail, .value.blocked { color: var(--danger); }
    .value.warn { color: var(--warning); }
    .value.pass { color: var(--success); }
    .alert { background: #fef2f2; border: 1px solid var(--danger); color: var(--danger); padding: 10px 14px; border-radius: 6px; margin: 8px 0; }
    table { width: 100%; border-collapse: collapse; margin: 8px 0; }
    th, td { border: 1px solid #ddd; padding: 6px 10px; text-align: left; font-size: 13px; }
    th { background: #f3f4f6; }
    pre { background: #f3f4f6; padding: 10px; border-radius: 4px; overflow-x: auto; max-height: 240px; overflow-y: auto; }
    code { font-family: ui-monospace, SFMono-Regular, Menlo, monospace; font-size: 13px; }
    /* overflow defense */
    p, li, td { word-break: break-word; overflow-wrap: anywhere; }
    @media (max-width: 760px) {
      main { padding: 16px; height: auto; }
      .cards { grid-template-columns: 1fr; }
    }
  </style>
</head>
<body>
<main>
  <header>
    <h1>harness Summary</h1>
    <p style="margin:0;color:var(--muted);">{{goal}} <span style="margin-left:10px;font-size:12px;">run: {{run_id}}</span></p>
  </header>

  <!-- BLOCKED/FAIL 가 있으면 첫 화면 상단에 명시 -->
  <div id="alerts">
    <!-- placeholder: BLOCKED/FAIL 항목이 있으면 <div class="alert">…</div> 삽입 -->
  </div>

  <div role="tablist" aria-label="Engineering 보고서 섹션">
    <button role="tab" id="t-summary" aria-controls="p-summary" aria-selected="true" tabindex="0">요약</button>
    <button role="tab" id="t-domain"  aria-controls="p-domain"  aria-selected="false" tabindex="-1">DDD</button>
    <button role="tab" id="t-tdd"     aria-controls="p-tdd"     aria-selected="false" tabindex="-1">TDD</button>
    <button role="tab" id="t-qa"      aria-controls="p-qa"      aria-selected="false" tabindex="-1">QA</button>
    <button role="tab" id="t-review"  aria-controls="p-review"  aria-selected="false" tabindex="-1">Review</button>
    <button role="tab" id="t-customer" aria-controls="p-customer" aria-selected="false" tabindex="-1">Customer</button>
    <button role="tab" id="t-audit"   aria-controls="p-audit"   aria-selected="false" tabindex="-1">Audit</button>
    <button role="tab" id="t-commit"  aria-controls="p-commit"  aria-selected="false" tabindex="-1">Commit 계획</button>
  </div>

  <section role="tabpanel" id="p-summary" aria-labelledby="t-summary">
    <div class="cards">
      <div class="card"><div class="label">Overall</div><div class="value {{verdict_class}}">{{verdict}}</div></div>
      <div class="card"><div class="label">Tests</div><div class="value">{{tests}}</div></div>
      <div class="card"><div class="label">Coverage</div><div class="value">{{coverage}}</div></div>
    </div>
    <h2>한눈에</h2>
    <p>{{summary}}</p>
    <h2>실패 / BLOCKED (있으면 명시)</h2>
    <p>{{failures}}</p>
  </section>

  <section role="tabpanel" id="p-domain" aria-labelledby="t-domain" hidden>
    <h2>도메인 모델</h2>
    <p>{{ddd}}</p>
    <h2>Bounded Contexts</h2>
    <p>{{contexts}}</p>
    <h2>Aggregates</h2>
    <p>{{aggregates}}</p>
  </section>

  <section role="tabpanel" id="p-tdd" aria-labelledby="t-tdd" hidden>
    <h2>TDD 사이클</h2>
    <p>{{tdd}}</p>
    <h2>No-Mock 증거</h2>
    <pre><code>{{nomock_evidence}}</code></pre>
    <h2>Production endpoint 증거</h2>
    <pre><code>{{noprod_evidence}}</code></pre>
  </section>

  <section role="tabpanel" id="p-qa" aria-labelledby="t-qa" hidden>
    <h2>QA</h2>
    <p>{{qa}}</p>
  </section>

  <section role="tabpanel" id="p-review" aria-labelledby="t-review" hidden>
    <h2>Codex Review</h2>
    <p>{{review}}</p>
  </section>

  <section role="tabpanel" id="p-customer" aria-labelledby="t-customer" hidden>
    <h2>Customer Test</h2>
    <p>{{customer}}</p>
    <p style="font-size:12px;color:var(--muted);">redaction 적용됨 — production data·실 계정은 마스킹.</p>
  </section>

  <section role="tabpanel" id="p-audit" aria-labelledby="t-audit" hidden>
    <h2>Audit Findings</h2>
    <p>{{audit_detail}}</p>
    <h2>자가 수정 카운터</h2>
    <p>산출물: <strong>{{audit_artifact_count}}/2</strong> · 스킬: <strong>{{audit_skill_count}}/2</strong></p>
    <h2>스킬 자기 개선 변경 로그</h2>
    <p>{{skill_improvements}}</p>
  </section>

  <section role="tabpanel" id="p-commit" aria-labelledby="t-commit" hidden>
    <h2>Commit 계획 (step 9)</h2>
    <p><strong>본 skill 은 commit 만 수행. push 는 절대 안 함.</strong></p>
    <p><code>runs/{{run_id}}/09-commit/status.md</code> = pre-commit readiness (포함·제외·메시지·<code>READY_TO_COMMIT</code>·<code>COMMITTED_SHA: &lt;PENDING&gt;</code>). 실제 SHA·시각은 <code>git log -1 --format='%h %ai'</code> 로만 확인 (no-post-commit-mutation 계약).</p>
    <p>{{commit_plan}}</p>
  </section>
</main>

<script>
(function(){
  var tabs = document.querySelectorAll('[role="tab"]');
  var panels = document.querySelectorAll('[role="tabpanel"]');
  function activate(idx){
    tabs.forEach(function(t,i){
      t.setAttribute('aria-selected', i===idx ? 'true':'false');
      t.tabIndex = i===idx ? 0 : -1;
    });
    panels.forEach(function(p,i){ p.hidden = i!==idx; });
    tabs[idx].focus();
  }
  tabs.forEach(function(tab,i){
    tab.addEventListener('click', function(){ activate(i); });
    tab.addEventListener('keydown', function(e){
      if(e.key==='ArrowRight') activate((i+1) % tabs.length);
      else if(e.key==='ArrowLeft') activate((i-1+tabs.length) % tabs.length);
      else if(e.key==='Home') activate(0);
      else if(e.key==='End') activate(tabs.length-1);
    });
  });
})();
</script>
</body>
</html>
