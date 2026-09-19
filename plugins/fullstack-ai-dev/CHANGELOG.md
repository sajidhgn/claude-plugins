# Changelog — fullstack-ai-dev

Version lives in `.claude-plugin/plugin.json`. Bump it with every change — Claude Code uses it to detect updates.

## 0.3.2 — 2026-09-18
- Changed: author and marketplace are now `sajidhgn`. Install with `/plugin install fullstack-ai-dev@sajidhgn`.

## 0.3.1 — 2026-09-18
- Fixed: `detect-stack` missed Python dependencies written as a single-line array in `pyproject.toml`; it now also lists dependency-group (dev) packages. Caught by the new free tests.

## 0.3.0 — 2026-09-18
- Added: eval suite in `evals/` for `claude plugin eval` (6 cases: Arabic intake, approval + new request, role planning, planted-bug smoke test, two should-not-trigger cases).
- Added: `tests/run-free-tests.sh` — structure, hook-guard, stop-gate, scanner, and fixture checks that make no model calls.
- Fixed: `run-tasks` now stops after the plan for plan-only requests instead of continuing into implementation.

## 0.2.0 — 2026-09-18
- Added: `intake` skill — client request (WhatsApp, email, screenshots, PDF; English/Arabic) → task file + client confirmation; handles client replies and records approval.
- Added: approval gate in `run-tasks` (pauses on unapproved client files) and client delivery note (`.devrun/DELIVERY.md`) at the end of a run.

## 0.1.0 — 2026-09-18
- Initial release: `run-tasks`, `detect-stack`, `smoke-test` skills; `smoke-tester` agent; Stop gate, Bash guard, and session-resume hooks; Playwright MCP.
