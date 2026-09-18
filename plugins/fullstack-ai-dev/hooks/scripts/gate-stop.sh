#!/usr/bin/env bash
# Stop hook: while a /run-tasks run is active, don't let Claude end its turn
# before smoke testing, the fix loop and the report are complete.
# Exit 2 = block the stop and feed stderr back to Claude.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$DIR/lib.sh"

input="$(cat)"
resolve_state "$input"

# Already continuing because of this hook -> allow, to prevent loops.
[ "$(json_get "$input" stop_hook_active)" = "true" ] && exit 0
run_is_live || exit 0

case "$RUN_PHASE" in
  ""|blocked|awaiting_user) exit 0 ;;
esac

cat >&2 <<MSG
fullstack-ai-dev: a run is still active (phase: $RUN_PHASE, state: .devrun/state.json).
Continue with the next phase — smoke testing, the fix loop and .devrun/REPORT.md are required before finishing.
If you need the user's input, set "phase" to "awaiting_user" in the state file and ask your question.
If the run cannot continue, set "phase" to "blocked" and record the reason in "blocked_reason".
MSG
exit 2
