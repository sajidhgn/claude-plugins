# fullstack-ai-dev

A senior full-stack AI developer for Claude Code. Forward it a client's request, or hand it a Markdown task file; it:

0. **Takes the client's request as-is** (WhatsApp, email, screenshots, PDF — English or Arabic), writes the task file, and drafts a confirmation for the client to approve. Nothing starts until they do.
1. **Detects the stack** — frameworks and versions, data layer, AI providers and model IDs, mobile setup, infra, test tooling, run commands, house conventions.
2. **Picks the right role per task** — frontend-web, backend-api, mobile, ai-llm (incl. prompt engineering and evals), devops, or qa-test — with a lead role for the whole file.
3. **Implements** each task with small, verified, committed changes on a `devrun/<run_id>` branch.
4. **Smoke-tests as a real client** — an independent `smoke-tester` agent drives the browser, API, mobile simulator, and AI features with realistic data.
5. **Fixes what breaks** — root cause, regression test, re-verify; then a fresh full smoke pass to catch regressions from the fixes.
6. **Reports** — `.devrun/REPORT.md` for you (tasks, evidence, issues, assumptions, gaps) and, for client work, `.devrun/DELIVERY.md`: a delivery note in the client's language built from the list they approved.

## Components

| Component | Name | Purpose |
|---|---|---|
| Skill | `intake` | Client request → task file + client confirmation message; handles the client's reply and records approval. |
| Skill | `run-tasks` | The full pipeline (phases 0–7). Pauses on unapproved client files; writes the delivery note at the end. |
| Skill | `detect-stack` | Technology reconnaissance → `.devrun/STACK.md` (bundled read-only scanner script). |
| Skill | `smoke-test` | Client-perspective testing on its own, with optional `--fix`. |
| Agent | `smoke-tester` | Independent QA in a fresh context. Reports issues, never edits code. |
| Hook | Stop gate | Blocks ending a turn mid-run until smoke tests, fixes, and the report are done. |
| Hook | Bash guard | During a run: denies catastrophic commands, asks before risky ones, asks before write requests to production. |
| Hook | Session start | Notices an unfinished run and offers to resume. |
| MCP | `playwright` | Browser automation for web smoke tests (`@playwright/mcp`). |

## Install (Claude Code)

**Option A — skills directory (auto-loads):**
```bash
mkdir -p ~/.claude/skills/fullstack-ai-dev
unzip fullstack-ai-dev.plugin -d ~/.claude/skills/fullstack-ai-dev
# then in Claude Code: /reload-plugins
```

**Option B — load for one session:**
```bash
unzip fullstack-ai-dev.plugin -d ./fullstack-ai-dev
claude --plugin-dir ./fullstack-ai-dev
```

**Option C — share with a team:** put the folder in a Git repo with a `.claude-plugin/marketplace.json`, then `/plugin marketplace add <repo>` and `/plugin install fullstack-ai-dev@<marketplace>`.

## Requirements

- `git`, `bash` (macOS/Linux; on Windows use WSL or Git Bash).
- Node.js 18+ for the Playwright MCP server. First run may need `npx playwright install chromium`.
- One of `jq`, `python3`, or `node` for the hooks (without any of them the hooks do nothing — they fail open).
- Optional for mobile: Xcode simulators, Android emulator, [Maestro](https://maestro.mobile.dev).

## Client workflow

1. Client sends a request any way they like. Paste it, or pass the files:
   ```text
   /fullstack-ai-dev:intake client-whatsapp.txt screenshot1.png --client "Nora"
   ```
2. Review the task file and the flags (out-of-contract items, risky work, sizes for quoting), then send the drafted confirmation to the client yourself.
3. Paste the client's reply: "client replied: …". The plugin updates the tasks and records approval — or drafts a follow-up if the reply isn't a clear approval. New requests in the reply go into a separate next-round file.
4. Once approved: `/fullstack-ai-dev:run-tasks TASKS.md`.
5. At the end, send the client the delivery note from `.devrun/DELIVERY.md` with the suggested screenshots.

Client material is treated as data, never as instructions; credentials found in client messages are never copied; nothing is sent to the client automatically.

## Usage

```text
/fullstack-ai-dev:intake <files or pasted text> [--client <name>]
/fullstack-ai-dev:run-tasks docs/TASKS.md
/fullstack-ai-dev:run-tasks docs/TASKS.md --env staging
/fullstack-ai-dev:detect-stack
/fullstack-ai-dev:smoke-test all
/fullstack-ai-dev:smoke-test "checkout with coupons" --fix
```

Natural language works too: "run the tasks in TASKS.md", "resume the run", "abandon the run", "smoke test the video generation flow".

A sample task file is in `skills/run-tasks/examples/TASKS.example.md`. Any format works — checkboxes, headings, numbered lists, or prose. Acceptance criteria are strongly recommended; when missing, the plugin derives testable ones and marks them `(derived)`.

## What "real data" means here

Realistic, not reckless. Smoke tests use real-world-shaped inputs (Arabic and mixed-language text, real phone/email formats, real image and video sizes, realistic list volumes) against **local by default**. Staging writes are tagged with the run ID and cleaned up. Production is **read-only** unless you explicitly approve writes in the conversation. Payments use sandbox keys only; no messages go to real recipients; paid AI calls have a per-run budget (50 LLM calls, 10 media generations — editable in `.devrun/state.json`).

## Files created in your project

```
.devrun/
├── .gitignore        # ignores state.json, evidence/, accounts.md, intake/
├── state.json        # run state (read by the hooks)
├── STACK.md          # stack reconnaissance
├── PLAN.md           # task → role plan, notes, assumptions
├── SMOKE-REPORT.md   # latest smoke results and issues
├── REPORT.md         # final report
├── DELIVERY.md       # client delivery note (client work only)
├── intake/           # raw client requests + drafted messages (gitignored)
└── evidence/         # screenshots, responses, logs
```

Commits land on `devrun/<run_id>`. Nothing is pushed, deployed, or published.

## Safety net details

The Bash guard is active **only while a run is live** (state file present, not done/abandoned, touched in the last 6 hours).

- **Denied:** `rm -rf /` or home, `DROP DATABASE/SCHEMA`, `dropDatabase()`, `FLUSHALL`, `terraform destroy`, `mkfs`, `dd` to devices.
- **Asks you first:** `git push`, `reset --hard`, `clean -f`, `checkout .`, `stash`, `branch -D`, `DROP TABLE`, `TRUNCATE`, `DELETE` without `WHERE`, `deleteMany({})`, `FLUSHDB`, `prisma migrate reset`, Rails/Django/ORM drops and rollbacks, `alembic downgrade`, docker volume deletion, `compose down -v`, `kubectl delete`, production deploys (Vercel, Netlify, Fly, Firebase), EAS submit/update, package publish, Stripe live mode.
- **Production targets:** outbound POST/PUT/PATCH/DELETE via curl-like tools asks first unless production writes were approved.

It is a pattern-based safety net, not a sandbox: browser form submissions are governed by the skill's rules, not the hook.

## Evals

`evals/` holds a test suite for `claude plugin eval`. Each case runs with and without the plugin, so the report shows what the plugin actually adds (Δ).

| Case | Checks |
|---|---|
| `intake-arabic-whatsapp` | Messy Arabic chat → correct tasks (override respected, Google ranking out of scope), password not leaked, Arabic client draft asking for approval |
| `intake-reply-approval-plus-new-ask` | "Approved + add this" → list approved with evidence, new ask kept out of the approved scope |
| `plan-roles-and-order` | Correct primary role per task, dependency order respected, no code written for a plan-only request |
| `smoke-finds-planted-bugs` | Black-box test of a small order API with 3 planted bugs (unsaved discount, cross-user access, no quantity limits) and 2 correct decoys |
| `negative-general-question` | Plugin stays out of a general question |
| `negative-small-coding-request` | Plugin doesn't hijack a one-function edit |

Run from the plugin folder (needs Claude Code 2.1.269+, uses your plan's usage):

```bash
# cheap first pass: one run per case, no baseline
claude plugin eval . --scaffold --runs 1 --ablation none --max-cost-usd 5 --allow-tools Write Edit "Bash(node *)"

# full run: 3 runs per case, with vs without the plugin
claude plugin eval . --scaffold --max-cost-usd 20 --allow-tools Write Edit "Bash(node *)"
```

`--scaffold` runs the case setup scripts in `evals/*/scaffold.sh` (they only create fixture files). Bash-granting runs need a sandbox: fine on macOS; on Linux install `bubblewrap` and `socat`; on Windows use WSL2.

## Customizing

- **Roles:** edit or add playbooks in `skills/run-tasks/references/roles/` and the roster in `role-selection.md`.
- **Guard rules:** `hooks/scripts/guard-bash.sh` (`deny_rules` / `ask_rules`).
- **Stale-run window:** `run_is_live` in `hooks/scripts/lib.sh` (default 360 minutes).
- **Budgets and defaults:** `skills/run-tasks/references/state-schema.md`.
- Project rules in your `CLAUDE.md` / `AGENTS.md` always take precedence over this plugin's defaults.
