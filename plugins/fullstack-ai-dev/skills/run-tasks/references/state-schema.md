# `.devrun/state.json`

Single source of truth for the run. Hooks read `phase`, `target_env`, and `production_writes_approved`, so keep those exact names.

```json
{
  "run_id": "20260918-1430",
  "task_file": "docs/TASKS.md",
  "branch": "devrun/20260918-1430",
  "phase": "implement",
  "previous_phase": null,
  "blocked_reason": null,
  "target_env": "local",
  "production_writes_approved": false,
  "lead_role": "fullstack: backend-api + frontend-web",
  "app": {
    "urls": { "web": "http://localhost:3000", "api": "http://localhost:8000" },
    "pids": [12345],
    "test_accounts": "see .devrun/accounts.md (gitignored)"
  },
  "budget": { "llm_calls_max": 50, "llm_calls_used": 0, "media_generations_max": 10, "media_generations_used": 0 },
  "tasks": [
    { "id": "T1", "title": "Add coupon to checkout", "role": "backend-api", "support": ["frontend-web"],
      "risk": "high", "status": "done", "commit": "a1b2c3d", "notes": "" }
  ],
  "issues": [
    { "id": "S1", "task": "T1", "severity": "major", "title": "Discount not reflected in total",
      "status": "fixed", "attempts": 1, "evidence": ".devrun/evidence/S1-after.png", "commit": "d4e5f6a" }
  ],
  "smoke_cycles": 1
}
```

## Phase values

`setup` → `intake` → `recon` → `plan` → `implement` → `smoke` → `fix` → `report` → `done`

Special: `awaiting_user` (paused for input; store the phase to return to in `previous_phase`), `blocked` (cannot continue; set `blocked_reason`), `abandoned` (user dropped the run).

The Stop hook lets a turn end only in `done`, `blocked`, `awaiting_user`, or `abandoned`. It ignores state files untouched for 6 hours.

## Status values

- Task: `pending | in_progress | done | blocked | skipped`
- Issue: `open | fixing | fixed | needs_human | wontfix` (`wontfix` only with the user's agreement or when the issue is out of scope and pre-existing — say which)

## Files in `.devrun/`

| File | Purpose | Committed? |
|---|---|---|
| `STACK.md` | stack reconnaissance | optional |
| `PLAN.md` | plan table, per-task notes, assumptions | optional |
| `SMOKE-REPORT.md` | latest smoke results + issues | optional |
| `REPORT.md` | final report | optional |
| `DELIVERY.md` | client-facing delivery note (only when the task file has a `## Client` section) | optional |
| `intake/` | raw client requests and drafted client messages (intake skill) | no (gitignored) |
| `state.json` | run state | no (gitignored) |
| `evidence/` | screenshots, response dumps, logs | no (gitignored) |
| `accounts.md` | test credentials if created | never — add to `.devrun/.gitignore` |
