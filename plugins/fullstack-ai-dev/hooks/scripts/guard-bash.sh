#!/usr/bin/env bash
# PreToolUse(Bash) guard, active only while a /run-tasks run is live.
#  - DENY  (exit 2): catastrophic, never needed for a task run.
#  - ASK   (JSON)  : risky or irreversible -> the user decides.
#  - Production: outbound write requests need approval unless the user
#    approved production writes (state.production_writes_approved = true).
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$DIR/lib.sh"

input="$(cat)"
resolve_state "$input"
run_is_live || exit 0

cmd="$(json_get "$input" tool_input.command)"
[ -n "$cmd" ] || exit 0

matches() { printf '%s' "$cmd" | grep -Eiq -- "$1"; }

ask() {
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"fullstack-ai-dev guard: %s. Approve only if you intend this."}}\n' "$1"
  exit 0
}

S='[[:space:]]'
# ---------- DENY ----------
deny_rules=(
  "(^|[;&|(]|$S)rm$S+(-[a-zA-Z]+$S+)*(/|/\*|~|~/|~/\*|\\\$HOME|\\\$HOME/\*)($S|$|;|&)|recursive delete of / or home"
  "DROP$S+(DATABASE|SCHEMA)|DROP DATABASE/SCHEMA"
  "\.dropDatabase\(|MongoDB dropDatabase"
  "(^|$S)FLUSHALL($S|$)|Redis FLUSHALL"
  "terraform$S+destroy|terraform destroy"
  "(^|$S)mkfs(\.|$S)|mkfs"
  "(^|$S)dd$S[^;&|]*of=/dev/|dd to a device"
)
for rule in "${deny_rules[@]}"; do
  pattern="${rule%|*}"; label="${rule##*|}"
  if matches "$pattern"; then
    echo "fullstack-ai-dev guard: blocked ($label). This is never part of a task run. If it is truly required, stop and ask the user to run it themselves." >&2
    exit 2
  fi
done

# ---------- ASK ----------
ask_rules=(
  "git$S+push|git push (the run commits locally only)"
  "git$S+reset$S+--hard|git reset --hard (can destroy uncommitted work)"
  "git$S+clean$S+-[a-zA-Z]*f|git clean -f (deletes untracked files)"
  "git$S+checkout$S+(--$S+)?\.($S|$)|git checkout . (discards changes)"
  "git$S+stash($S+(push|save|drop|clear)|$S*$)|git stash (hides or drops work)"
  "git$S+branch$S+-D|force-delete a branch"
  "DROP$S+TABLE|DROP TABLE"
  "TRUNCATE$S|TRUNCATE"
  "DELETE$S+FROM$S+[\"\`a-zA-Z0-9_.]+$S*(;|\"|'|$)|DELETE without WHERE"
  "deleteMany\($S*\{$S*\}$S*\)|deleteMany({}) wipes a collection"
  "(^|$S)FLUSHDB($S|$)|Redis FLUSHDB"
  "prisma$S+migrate$S+reset|prisma migrate reset (wipes the database)"
  "prisma$S+db$S+push[^;&|]*--(force-reset|accept-data-loss)|prisma db push with data loss"
  "(rails|rake)$S+db:(drop|reset|schema:load)|Rails DB drop/reset"
  "(^|$S)dropdb$S|dropdb"
  "alembic$S+downgrade|alembic downgrade"
  "manage\.py$S+(flush|reset_db)|Django flush"
  "(sequelize|knex|typeorm)[^;&|]*(db:drop|migrate:rollback|migration:revert|schema:drop)|ORM drop/rollback"
  "docker$S+(system|volume)$S+prune|docker prune (deletes volumes/images)"
  "docker$S+volume$S+rm|docker volume rm"
  "docker($S+|-)compose[^;&|]*down[^;&|]*($S-v($S|$)|--volumes)|compose down -v (deletes DB volumes)"
  "kubectl$S+delete|kubectl delete"
  "vercel[^;&|]*--prod|production deploy (vercel)"
  "netlify$S+deploy[^;&|]*--prod|production deploy (netlify)"
  "(^|$S)(fly|flyctl)$S+deploy|deploy (fly.io)"
  "firebase$S+deploy|deploy (firebase)"
  "eas$S+(submit|update)|app store submit / OTA update (EAS)"
  "(npm|pnpm|yarn)$S+publish|package publish"
  "stripe$S[^;&|]*--live|Stripe live mode"
)
for rule in "${ask_rules[@]}"; do
  pattern="${rule%|*}"; label="${rule##*|}"
  if matches "$pattern"; then ask "$label"; fi
done

# ---------- PRODUCTION WRITE GUARD ----------
env="$(json_get "$RUN_STATE" target_env)"
approved="$(json_get "$RUN_STATE" production_writes_approved)"
if [ "$env" = "production" ] && [ "$approved" != "true" ]; then
  if matches "(curl|http|https|xh|wget)$S" \
     && matches "(-X$S*(POST|PUT|PATCH|DELETE)|--request$S+(POST|PUT|PATCH|DELETE)|$S(-d|--data[a-z-]*|-F|--form|--json)$S|$S(POST|PUT|PATCH|DELETE)$S)" \
     && ! matches "(localhost|127\.0\.0\.1|0\.0\.0\.0|\[::1\])"; then
    ask "write request while target is production and production writes are not approved"
  fi
fi

exit 0
