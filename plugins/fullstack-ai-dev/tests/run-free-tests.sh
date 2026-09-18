#!/usr/bin/env bash
# run-free-tests.sh — checks that cost nothing (no model calls).
# Covers: manifest/JSON validity, script syntax, Claude Code's validator (if installed),
# the Bash guard hook, the Stop gate hook, the stack scanner, and the eval fixtures.
# Usage: bash tests/run-free-tests.sh   (from anywhere)
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOKS="$ROOT/hooks/scripts"
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT
PASS=0; FAIL=0
ok()   { PASS=$((PASS+1)); printf '  ✓ %s\n' "$1"; }
bad()  { FAIL=$((FAIL+1)); printf '  ✗ %s\n' "$1"; }
check(){ if [ "$2" = "$3" ]; then ok "$1"; else bad "$1 (got: $2, expected: $3)"; fi; }
section(){ printf '\n%s\n' "$1"; }

json_ok() {
  if command -v python3 >/dev/null 2>&1; then python3 -c 'import json,sys; json.load(open(sys.argv[1]))' "$1" 2>/dev/null
  else node -e 'JSON.parse(require("fs").readFileSync(process.argv[1],"utf8"))' "$1" 2>/dev/null; fi
}
# ------------------------------------------------------------------ structure
section "Structure"
for f in .claude-plugin/plugin.json hooks/hooks.json .mcp.json; do
  if json_ok "$ROOT/$f"; then ok "$f is valid JSON"; else bad "$f is invalid JSON"; fi
done
for s in $(find "$ROOT" -name '*.sh' -not -path '*/results/*'); do
  if bash -n "$s" 2>/dev/null; then ok "syntax: ${s#$ROOT/}"; else bad "syntax: ${s#$ROOT/}"; fi
done
for d in "$ROOT"/skills/*/; do
  [ -f "$d/SKILL.md" ] && ok "skill has SKILL.md: $(basename "$d")" || bad "missing SKILL.md: $(basename "$d")"
done
if command -v claude >/dev/null 2>&1; then
  if claude plugin validate --strict "$ROOT" >/dev/null 2>&1; then ok "claude plugin validate --strict"
  else bad "claude plugin validate --strict (run it directly to see why)"; fi
else
  printf '  - skipped claude plugin validate (claude CLI not installed)\n'
fi

# ------------------------------------------------------------------ Bash guard
section "Bash guard hook"
PROJ="$TMP/proj"; mkdir -p "$PROJ/.devrun"
guard() { # guard <command> → allow | ask | deny
  local input out code
  input="$(python3 -c 'import json,sys; print(json.dumps({"cwd":sys.argv[1],"tool_input":{"command":sys.argv[2]}}))' "$PROJ" "$1" 2>/dev/null \
          || node -e 'console.log(JSON.stringify({cwd:process.argv[1],tool_input:{command:process.argv[2]}}))' "$PROJ" "$1")"
  out="$(printf '%s' "$input" | CLAUDE_PROJECT_DIR="$PROJ" bash "$HOOKS/guard-bash.sh" 2>/dev/null)"; code=$?
  if [ $code -eq 2 ]; then echo deny
  elif printf '%s' "$out" | grep -q '"permissionDecision":"ask"'; then echo ask
  else echo allow; fi
}
set_state() { printf '%s' "$1" > "$PROJ/.devrun/state.json"; }

rm -f "$PROJ/.devrun/state.json"
check "no run active → rm -rf / allowed through (guard inactive)" "$(guard 'rm -rf /')" allow
set_state '{"run_id":"t","phase":"implement","target_env":"local","production_writes_approved":false}'
while IFS='|' read -r expected cmd; do
  [ -z "$cmd" ] && continue
  check "$expected: $cmd" "$(guard "$cmd")" "$expected"
done <<'CASES'
deny|rm -rf /
deny|rm -rf ~
deny|sudo rm -rf / --no-preserve-root
deny|psql -c "DROP DATABASE app"
deny|redis-cli FLUSHALL
deny|terraform destroy
allow|rm -rf node_modules
allow|rm -rf ./dist
ask|psql -c "drop table users"
ask|psql -c "DELETE FROM users;"
allow|psql -c "DELETE FROM users WHERE id=3"
ask|git push origin main
ask|git push --force
ask|git reset --hard HEAD~1
allow|git reset --soft HEAD~1
ask|git checkout .
allow|git checkout -b feature/x
ask|git stash
allow|git stash pop
allow|git commit -m "T1: add coupon"
ask|npx prisma migrate reset --force
allow|npx prisma migrate dev
ask|docker compose down -v
allow|docker compose down
allow|docker compose up -d
ask|vercel --prod
ask|npm publish
allow|npm run build
ask|mongosh --eval "db.users.deleteMany({})"
allow|terraform plan
ask|alembic downgrade -1
allow|alembic upgrade head
allow|curl -X POST https://api.example.com/orders -d "{}"
CASES

set_state '{"run_id":"t","phase":"smoke","target_env":"production","production_writes_approved":false}'
check "production, not approved: external POST asks" "$(guard 'curl -X POST https://api.example.com/orders -d "{}"')" ask
check "production, not approved: GET allowed" "$(guard 'curl -sS https://api.example.com/health')" allow
check "production, not approved: localhost POST allowed" "$(guard 'curl -X POST http://localhost:3000/api/x')" allow
set_state '{"run_id":"t","phase":"smoke","target_env":"production","production_writes_approved":true}'
check "production, approved: external POST allowed" "$(guard 'curl -X POST https://api.example.com/orders -d "{}"')" allow
set_state '{"run_id":"t","phase":"done"}'
check "finished run → guard inactive" "$(guard 'rm -rf /')" allow

# ------------------------------------------------------------------ Stop gate
section "Stop gate hook"
gate() { # gate <stop_hook_active> → exit code
  printf '{"cwd":"%s","stop_hook_active":%s}' "$PROJ" "$1" | CLAUDE_PROJECT_DIR="$PROJ" bash "$HOOKS/gate-stop.sh" >/dev/null 2>&1; echo $?
}
for p in implement smoke fix report; do set_state "{\"run_id\":\"t\",\"phase\":\"$p\"}"; check "blocks stop in phase $p" "$(gate false)" 2; done
for p in awaiting_user blocked done abandoned; do set_state "{\"run_id\":\"t\",\"phase\":\"$p\"}"; check "allows stop in phase $p" "$(gate false)" 0; done
set_state '{"run_id":"t","phase":"smoke"}'
check "loop guard: allows when already continuing" "$(gate true)" 0
touch -t "$(date -d '8 hours ago' +%Y%m%d%H%M 2>/dev/null || date -v-8H +%Y%m%d%H%M)" "$PROJ/.devrun/state.json"
check "stale run (8h) is ignored" "$(gate false)" 0

# ------------------------------------------------------------------ stack scanner
section "Stack scanner"
S="$TMP/stack"; mkdir -p "$S/web/app" "$S/api"
echo '{"name":"web","dependencies":{"next":"15.1.4","react":"19.0.0","@anthropic-ai/sdk":"^0.40.0"}}' > "$S/web/package.json"
touch "$S/web/next.config.ts"
printf '[project]\ndependencies = ["fastapi>=0.115", "pydantic-settings>=2.7"]\n' > "$S/api/pyproject.toml"
printf 'ANTHROPIC_API_KEY=\n' > "$S/.env.example"
printf 'SECRET=do-not-print-me\n' > "$S/.env"
OUT="$(bash "$ROOT/skills/detect-stack/scripts/detect-stack.sh" "$S" 2>/dev/null)"
printf '%s' "$OUT" | grep -q 'next@15.1.4' && ok "detects Next.js version" || bad "detects Next.js version"
printf '%s' "$OUT" | grep -q 'fastapi>=0.115' && ok "detects FastAPI" || bad "detects FastAPI"
printf '%s' "$OUT" | grep -Eq '(^|[ ,])pydantic(,|$)' && bad "no pydantic false positive" || ok "no pydantic false positive"
printf '%s' "$OUT" | grep -q 'Next.js App Router' && ok "detects App Router" || bad "detects App Router"
printf '%s' "$OUT" | grep -q 'do-not-print-me' && bad "never prints .env values" || ok "never prints .env values"

# ------------------------------------------------------------------ eval fixtures
section "Eval fixtures"
F="$TMP/fixture"; mkdir -p "$F"
if (cd "$F" && bash "$ROOT/evals/smoke-finds-planted-bugs/scaffold.sh") && command -v node >/dev/null 2>&1; then
  api() { (cd "$F" && node api.js "$@" | head -1); }
  body() { (cd "$F" && node api.js "$@" | tail -n +2); }
  check "decoy: unknown coupon rejected" "$(api POST /orders '{"productId":"p1","coupon":"FAKE"}' --as alice)" "HTTP 400"
  check "decoy: expired coupon rejected" "$(api POST /orders '{"productId":"p1","coupon":"SUMMER5"}' --as alice)" "HTTP 400"
  body POST /orders '{"productId":"p1","quantity":1,"coupon":"WELCOME10"}' --as alice | grep -q '"total": 108' \
    && ok "bug 1 setup: create response shows discounted total" || bad "bug 1 setup: create response shows discounted total"
  body GET /orders/1 --as alice | grep -q '"total": 120' && ok "bug 1 present: saved order keeps full price" || bad "bug 1 present"
  check "bug 2 present: bob can open alice's order" "$(api GET /orders/1 --as bob)" "HTTP 200"
  check "bug 3 present: negative quantity accepted" "$(api POST /orders '{"productId":"p2","quantity":-2}' --as bob)" "HTTP 201"
  body GET /orders --as bob | grep -q '"owner": "alice"' && bad "decoy: order list is private" || ok "decoy: order list is private"
else
  bad "smoke fixture scaffold or node unavailable"
fi
for c in intake-reply-approval-plus-new-ask plan-roles-and-order; do
  D="$TMP/$c"; mkdir -p "$D"
  (cd "$D" && bash "$ROOT/evals/$c/scaffold.sh") && [ -f "$D/TASKS.md" ] && ok "scaffold runs: $c" || bad "scaffold runs: $c"
done

# ------------------------------------------------------------------ summary
printf '\n%d passed, %d failed\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
