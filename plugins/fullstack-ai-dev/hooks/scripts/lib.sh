#!/usr/bin/env bash
# Shared helpers for fullstack-ai-dev hooks. Hooks fail open: if no JSON
# parser is available (jq, python3, or node), they allow everything.

# json_get <json-string> <dot.path> -> prints the value, or nothing.
# Booleans print as "true"/"false".
json_get() {
  local json="$1" path="$2"
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$json" | jq -r --arg p "$path" \
      'getpath($p | split(".")) | if . == null then empty else (if type == "object" or type == "array" then tojson else tostring end) end' 2>/dev/null
  elif command -v python3 >/dev/null 2>&1; then
    printf '%s' "$json" | python3 -c '
import json, sys
try:
    v = json.load(sys.stdin)
    for k in sys.argv[1].split("."):
        v = v[k]
    if v is None:
        pass
    elif isinstance(v, bool):
        print("true" if v else "false")
    elif isinstance(v, (dict, list)):
        print(json.dumps(v))
    else:
        print(v)
except Exception:
    pass
' "$path"
  elif command -v node >/dev/null 2>&1; then
    printf '%s' "$json" | node -e '
let d = "";
process.stdin.on("data", c => d += c).on("end", () => {
  try {
    let v = JSON.parse(d);
    for (const k of process.argv[1].split(".")) v = v[k];
    if (v !== undefined && v !== null)
      process.stdout.write(typeof v === "object" ? JSON.stringify(v) : String(v));
  } catch (e) {}
});' "$path"
  fi
}

# resolve_state <hook-input-json> -> sets PROJECT_DIR and STATE_FILE
resolve_state() {
  local cwd
  cwd="$(json_get "$1" cwd)"
  PROJECT_DIR="${CLAUDE_PROJECT_DIR:-${cwd:-$PWD}}"
  STATE_FILE="$PROJECT_DIR/.devrun/state.json"
}

# run_is_live -> 0 if a run exists, is unfinished, and was touched in the last 6h.
# Stale runs (abandoned sessions) are ignored so they never nag forever.
run_is_live() {
  [ -f "$STATE_FILE" ] || return 1
  [ -n "$(find "$STATE_FILE" -mmin -360 2>/dev/null)" ] || return 1
  RUN_STATE="$(cat "$STATE_FILE" 2>/dev/null)"
  RUN_PHASE="$(json_get "$RUN_STATE" phase)"
  case "$RUN_PHASE" in
    done|abandoned) return 1 ;;
  esac
  return 0
}
