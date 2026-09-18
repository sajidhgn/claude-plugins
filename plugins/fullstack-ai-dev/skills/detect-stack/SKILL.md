---
name: detect-stack
description: >
  Detect and document the technologies a project uses before any work starts. Use when the user
  asks "what stack is this", "what technologies does this project use", "scan the repo", "analyze
  this codebase before we start", or as the reconnaissance phase of run-tasks. Produces
  .devrun/STACK.md covering languages, frameworks and versions, data layer, AI/LLM providers and
  models, mobile setup, infra, test tooling, run commands, and conventions.
argument-hint: "[project-dir]"
---

# Detect Stack

Build an accurate picture of the project so every later decision (role, patterns, commands, test approach) rests on facts rather than assumptions.

## Procedure

1. **Run the scanner.** Execute `bash scripts/detect-stack.sh <project-dir>` from this skill's base directory (default project dir: the current working directory). It is read-only, prints Markdown, and never prints secret values.

2. **Verify what matters.** Treat the scanner output as leads. Open and read:
   - Every `CLAUDE.md`, `AGENTS.md`, `.cursorrules`, or `CONTRIBUTING.md` it lists. Rules in these files override defaults from this plugin.
   - The root and per-app manifests, to confirm framework **major versions** — they change how code must be written (for example Next.js App vs Pages Router, React 18 vs 19, Tailwind v3 config file vs v4 CSS-first `@theme`, Expo SDK level, Pydantic v1 vs v2, SQLAlchemy 1.x vs 2.x async).
   - One representative file per layer (a page/component, an API route/handler, a model/schema, a service calling an LLM, a test) to learn the house style: naming, folder structure, error handling, data fetching, validation, logging.
   - Env example files for required configuration (names only). Never open real `.env` files to copy values into any output.

3. **Resolve how to run things.** Determine the exact commands for: install, dev server(s) and ports, build, typecheck, lint, unit tests, e2e tests, DB start/migrate/seed, background workers, mobile simulator targets. Prefer scripts already defined in `package.json`, `Makefile`, `pyproject.toml`, `docker-compose.yml`, or README. Note anything that needs a secret or external service to start.

4. **Check currency when it matters.** If a library version is newer than what is reliably known, or a later task depends on a specific API (a model ID, an SDK method, a framework feature), look up the current official docs (web search or a docs MCP server if one is connected) and record the finding with its source. Never invent model IDs, SDK methods, or config keys.

5. **Write `.devrun/STACK.md`** using the template below. Create `.devrun/` if missing. Keep it factual and short; link to files instead of pasting them.

6. **Report in chat** with a 3–6 line summary: stack in one line per app, how to run it, and any red flags (dirty git tree, missing env vars, no tests, conflicting lockfiles, outdated majors).

## STACK.md template

```markdown
# Stack — <project> (<date>)

## Apps
| App / path | Type | Language | Framework (version) | Entry / port |
|---|---|---|---|---|

## Layers
- **Frontend:** framework, router style, styling, state/data fetching, i18n/RTL
- **Backend/API:** framework, validation, auth, error shape
- **Data:** DB, ORM/ODM, migrations tool, seed scripts
- **AI/LLM:** providers, SDKs, model IDs in use, where prompts live, structured output method, streaming, evals
- **Mobile:** RN/Expo (SDK, managed/bare) or Flutter (version, state mgmt), navigation, API base URL config
- **Infra/CI:** containers, deploy targets, CI pipelines
- **Testing:** unit, integration, e2e tools; how to run; current state (passing? count)

## Commands
| Purpose | Command | Notes |
|---|---|---|
| install | | |
| dev | | port |
| typecheck / lint | | |
| unit tests | | |
| e2e | | |
| db up / migrate / seed | | |

## Conventions observed
- (naming, folders, patterns to mirror — with file references)

## Config required (names only)
- (env var names and what needs them)

## Red flags / unknowns
- (dirty tree, failing tests at baseline, missing envs, version conflicts)

## Sources checked
- (docs looked up, with links)
```

## Notes

- Record the **baseline**: run the typecheck/lint/unit-test commands once if they are fast (under ~3 minutes) and note the pre-existing failures, so later work is not blamed for them — and does not hide behind them.
- In a monorepo, document each app separately; tasks usually touch one or two.
- If the scanner is unavailable (for example on Windows without bash), perform the same checks manually with file search and reads.
