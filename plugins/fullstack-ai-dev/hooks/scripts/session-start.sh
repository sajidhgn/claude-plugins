#!/usr/bin/env bash
# SessionStart: if an unfinished run exists, tell Claude so it can offer to resume.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$DIR/lib.sh"

input="$(cat)"
resolve_state "$input"
run_is_live || exit 0

task_file="$(json_get "$RUN_STATE" task_file)"
run_id="$(json_get "$RUN_STATE" run_id)"
echo "fullstack-ai-dev: unfinished run ${run_id:-?} found for ${task_file:-a task file} (phase: ${RUN_PHASE:-unknown}). If the user wants to continue, resume it with the run-tasks skill; if they want to drop it, set phase to \"abandoned\" in .devrun/state.json."
exit 0
