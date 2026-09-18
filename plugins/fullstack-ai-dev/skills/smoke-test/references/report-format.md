# SMOKE-REPORT.md format

```markdown
# Smoke report — <run_id> · cycle <n>

**Env:** <local|staging|production> · **Build/commit:** <sha> · **Tester:** smoke-tester · **Date:** <UTC>

## Verdict
<PASS | PASS WITH MINOR ISSUES | FAIL> — <one sentence>

## Test plan & results
| # | Task | Scenario | Surface | Result | Evidence |
|---|---|---|---|---|---|
| 1 | T1 | Generate Arabic description for a real product | web | PASS | evidence/T1-1.png |
| 2 | T1 | Prompt-injection input | api | FAIL → S2 | evidence/T1-2.json |
| 3 | — | Regression: sign in → dashboard | web | PASS | evidence/R-1.png |

Results: PASS · FAIL (link issue) · BLOCKED (why) · NOT TESTED (why)

## Issues
### S1 — [critical] <short title> (T2)
- **Where:** <URL / endpoint / screen>, <env>
- **Steps:** 1. … 2. … 3. …
- **Expected:** …
- **Actual:** …
- **Evidence:** <paths; log excerpt with secrets redacted>
- **Suspected area:** <file/module/layer — a lead, not a verdict>
- **Status:** open

## Side-channel findings
- Console errors / failed requests / server log errors seen during the run, even if no scenario failed.

## Not tested
- <what> — <why> — <how to verify manually>
```

## Severity rubric

| Severity | Meaning | Examples |
|---|---|---|
| **critical** | data loss or corruption, security hole, core journey blocked, crash | authz bypass, secret in response, checkout impossible, app crashes on launch, duplicate charges |
| **major** | an acceptance criterion not met, wrong data shown or saved, error with no recovery path, significant regression | discount not applied, Arabic output comes back in English, spinner never ends on failure |
| **minor** | cosmetic, copy, small UX friction, non-blocking warning | misaligned icon in RTL, typo, new console warning |

When in doubt between two levels, pick the higher one and say why.
