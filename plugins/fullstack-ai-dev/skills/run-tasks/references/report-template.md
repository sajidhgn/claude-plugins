# REPORT.md template

```markdown
# Run report — <run_id>

**Task file:** <path> · **Branch:** devrun/<run_id> · **Env:** <local|staging|production> · **Lead role:** <role>

## Summary
<2–4 sentences: what was delivered, overall confidence, what needs attention.>

| Tasks | Done | Blocked | Skipped |  | Issues found | Fixed | Open |
|---|---|---|---|---|---|---|---|
| n | n | n | n |  | n | n | n |

## Tasks
| ID | Task | Role | Status | Commit(s) | Verified by |
|---|---|---|---|---|---|
| T1 | … | backend-api | done | a1b2c3d | unit test + smoke S-T1-1..3 PASS |

## Smoke test results
- Cycles run: n. Final pass: <PASS / PASS with minor issues / FAIL>.
- Surfaces covered: web (desktop + mobile viewport), API, mobile (<platform>), AI features.
- Full details: `.devrun/SMOKE-REPORT.md`.

## Issues
| ID | Severity | Task | Title | Status | Fix commit |
|---|---|---|---|---|---|

## Needs your decision
- <item> — options, and my recommendation with the reason.

## Assumptions made
- <assumption> (task Tn)

## Not tested / known gaps
- <what, why (e.g. live payment keys only, no iOS simulator), and how to verify manually>

## Pre-existing problems noticed (not fixed)
- <failing test / warning / smell outside scope>

## How to review
- `git log --oneline <base>..devrun/<run_id>`
- Run: <commands>
- Start at: <URL/screen> and try: <2–3 key flows>
```
