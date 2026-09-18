---
name: run-tasks
description: >
  Execute a Markdown task file end to end as a senior full-stack AI developer. Use when the user
  says "run these tasks", "do the tasks in TASKS.md", "work through this task file", "implement
  everything in this md", "/run-tasks path/to/file.md", or hands over a .md file of development
  tasks (web, API, database, mobile, AI/LLM integration, prompt engineering, tests, DevOps). Detects
  the stack, picks the best specialist role per task, implements, smoke-tests the running app as a
  real client with realistic data, fixes what breaks, and writes a report. Also use for "resume the
  run", "continue the devrun", or "abandon the run". For raw client messages, use intake first.
argument-hint: "<path-to-tasks.md> [--env local|staging|production]"
---

# Run Tasks

Own a task list from intake to verified delivery, the way a senior full-stack AI developer would: understand the codebase first, choose the right expertise for each task, ship small verified changes, then prove the result works by using the app as a client — and fix what that reveals.

Arguments: `$ARGUMENTS` — first token is the task file path; optional `--env local|staging|production` (default `local`).

## Ground rules

- **Evidence or it didn't happen.** Never mark a task or fix done without evidence: command output, a passing test, an HTTP response, a screenshot, a log line.
- **Mirror the project.** Prefer existing patterns, libraries, and scripts. Justify every new dependency in PLAN.md.
- **State on disk.** Keep `.devrun/state.json` current (schema: `references/state-schema.md`). Update it at every phase change and task/issue status change. The plugin's hooks read it: the Stop hook blocks ending a turn mid-run, and the Bash guard asks before destructive commands.
- **Pausing.** When input is needed, set `phase` to `awaiting_user`, ask all open questions in one message, and stop. On the user's reply, restore the previous phase and continue.
- **Secrets.** Record env var names, never values. Redact tokens in anything written under `.devrun/`.
- **Production is read-only** unless the user explicitly approves writes in this conversation (then set `production_writes_approved: true`). Details: the smoke-test skill's `references/test-data-safety.md`.
- **Plan-only requests** ("just the plan", "who should do what", "don't write code yet"): run Phases 1–3 only — no branch, no commits, no code changes. Write `.devrun/PLAN.md`, set `phase` to `awaiting_user`, present the plan, and stop.
- **Don't push, deploy, or publish.** Commit locally on the run branch. Anything beyond that is the user's call.

## Phase 0 — Setup or resume

1. If `.devrun/state.json` exists and `phase` is not `done`/`abandoned`: summarize where the run stopped and resume from that phase, unless the user asked for a fresh start (then archive the old `.devrun/` as `.devrun-<old_run_id>/`). If the user says "abandon the run", set `phase: "abandoned"` and stop.
2. Otherwise create `.devrun/` with a `.gitignore` containing `state.json`, `evidence/`, `accounts.md`, and `intake/` (keep existing entries), and initialize `state.json` with a `run_id` of the form `YYYYMMDD-HHMM`.
3. Git: if the working tree is clean, create and switch to branch `devrun/<run_id>`. If it is dirty, pause (`awaiting_user`) and offer two options: continue on the current branch alongside their changes, or let them commit/stash first. Never stash, reset, or discard the user's work yourself.

## Phase 1 — Read the task file

1. **Approval gate.** If the file has an `## Approval` section (written by the intake skill) and its status isn't `approved`, pause (`awaiting_user`): say the client hasn't approved yet and ask whether to wait or proceed anyway. Record the user's decision in PLAN.md. Treat any remaining `Question:` lines as blocking ambiguities.
2. Read the task file. Normalize it into tasks per `references/task-file-format.md`: ID (`T1…Tn`), title, description, acceptance criteria, dependencies, and any per-task hints (env, test accounts, priority).
3. Where acceptance criteria are missing, derive concrete, testable ones and mark them `(derived)`.
4. Find **blocking ambiguities** only — cases where two reasonable readings lead to materially different implementations or data changes. Collect them all, pause once, and ask. For everything else, pick the most reasonable reading and record it as an assumption.

## Phase 2 — Stack reconnaissance

1. Run the `detect-stack` skill → `.devrun/STACK.md` (commands, versions, conventions, baseline test status).
2. For each task, search the codebase for the modules, routes, screens, models, prompts, and tests it will touch. Record them per task in PLAN.md.
3. If a task depends on an API or version you can't vouch for (new SDK release, model ID, framework feature), check current official docs before planning around it.

## Phase 3 — Role selection and plan

1. Load `references/role-selection.md`. For the whole file pick a **lead role**; for each task pick a **primary role**, **supporting roles**, a **risk level**, and a **verification method**.
2. Order tasks: dependencies first, then higher-risk work (schema, auth, payments, core AI pipeline) early so problems surface while there is time.
3. Write `.devrun/PLAN.md`:

   | ID | Task | Primary role | Supporting | Touches | Risk | Verify by |
   |----|------|--------------|------------|---------|------|-----------|

   followed by an Assumptions section.
4. Post the plan table in chat, then continue. Pause for approval only if the target env is `production`, or the plan requires a destructive data migration.

## Phase 4 — Implement

For each task, in plan order:

1. Set the task `in_progress`. Load the primary role's playbook from `references/roles/` (and the supporting roles' done-checklists). If a more specific skill for this stack is installed (for example a React, FastAPI, Next.js, or testing skill), use it alongside the playbook.
2. Read the code before changing it. For bugs, reproduce first and confirm the root cause before choosing a fix; re-assign the role if the cause lives in a different layer.
3. Make the smallest complete change that satisfies every acceptance criterion. Add or update tests where the project has a test setup — at minimum one test that would have failed before the change.
4. Run fast, scoped checks: typecheck, lint, and the related tests. Fix failures you caused. Leave pre-existing failures alone and note them.
5. Commit with message `T<n>: <title>`. Update state and PLAN.md (files changed, decisions, assumptions). If the task file uses `- [ ]` checkboxes, tick the task.
6. If a task is still failing after three genuine attempts with different hypotheses, mark it `blocked` with what was tried and what is known, and move on.

## Phase 5 — Smoke test as a client

1. Start everything the app needs using STACK.md commands (DB/services, API, web, workers; simulator for mobile). Poll health endpoints/URLs until ready. Record URLs, ports, and PIDs in state.
2. Prepare realistic test data and accounts per the smoke-test skill's `references/test-data-safety.md`.
3. Delegate to the **smoke-tester** agent. In the delegation prompt include: the task list with acceptance criteria, target env, app URLs, where test credentials are, the run ID for tagging data, the paths to `.devrun/STACK.md` and `.devrun/PLAN.md`, and the absolute path of the smoke-test skill's `references/` directory (resolve it from this skill's base directory: `../smoke-test/references/`). Ask it to write `.devrun/SMOKE-REPORT.md` and record issues in state.
4. If subagents are unavailable, run the `smoke-test` skill inline and adopt its mindset strictly: test from the outside as a user would, not from knowledge of the code just written.

## Phase 6 — Fix loop

1. Process open issues by severity: critical → major → minor.
2. For each: reproduce → find the root cause (not the symptom) → fix → add a regression test when feasible → rerun the failing smoke step plus the related task's checks → mark `fixed` with evidence and commit as `fix(S<n>): <summary>`.
3. Cap at three attempts per issue; then mark `needs_human` with findings.
4. Never make a test pass by weakening it: no disabling or skipping tests, no swallowing errors, no special-casing test data, no loosening validation to accept bad input.
5. After fixing, delegate a **fresh full smoke pass** to catch regressions introduced by fixes. Repeat smoke → fix at most three cycles in total.

## Phase 7 — Report

1. Write `.devrun/REPORT.md` using `references/report-template.md`.
2. **Client delivery note.** If the task file has a `## Client` section, also write `.devrun/DELIVERY.md` in the client's language using the delivery template in the intake skill's `references/client-messages.md` (resolve from this skill's base directory: `../intake/references/client-messages.md`). One line per approved task, with a status taken from the final smoke results (done / partly done / not done) and where the client can see it. List the screenshots from `.devrun/evidence/` worth attaching — only ones showing results with test data, never passwords, keys, or internal tools. No task IDs, commit hashes, or developer jargon. Show it in chat as a copyable block; never send it yourself.
3. Stop servers and processes this run started. Remove smoke data tagged with the run ID where the environment allows it.
4. Set `phase: "done"`.
5. In chat, give a short summary: tasks done / blocked, issues found / fixed / open, anything needing the user's decision (with a recommendation), the branch name, and how to review (`git log`, report path).

## References

- `references/task-file-format.md` — accepted task file formats and normalization rules
- `references/state-schema.md` — `.devrun/state.json` fields and phase values
- `references/role-selection.md` — role roster, routing rules, tie-breakers, examples
- `references/roles/*.md` — playbooks: frontend-web, backend-api, mobile, ai-llm, devops, qa-test
- `references/report-template.md` — final report structure
- `examples/TASKS.example.md` — a sample task file to share with users
