# Task file format

Accept whatever format the user wrote. Normalize it; don't ask them to rewrite it.

## Recognized structures

| Structure | Example | One task = |
|---|---|---|
| Checkboxes | `- [ ] Add coupon field to checkout` | each unchecked item (checked items = already done, skip) |
| Headings | `## Task 3: Stream chat replies` | each `##`/`###` section; its body is the description |
| Numbered list | `1. Fix login redirect loop` | each top-level item; nested items are sub-steps |
| Free prose | a paragraph describing a feature | split into tasks by distinct deliverable; list the split in PLAN.md |

Nested bullets under a task are sub-steps or criteria of that task, not separate tasks.

## Fields to extract per task

- **ID** — `T1…Tn` in document order (keep the user's own IDs if present, e.g. `RAW-42`).
- **Title** — one line.
- **Description** — the body text.
- **Acceptance criteria** — lines under `Acceptance`, `AC`, `Done when`, `Expected`, `Criteria`, or a nested checklist. If absent, derive 2–5 criteria that a tester could verify from outside (observable behavior, not implementation details) and mark them `(derived)`.
- **Dependencies** — explicit (`depends on T2`, `after the auth task`) or implied (a UI task that needs a new endpoint from another task).
- **Hints** — priority, target platform (web/iOS/Android), environment, test accounts, files, links, screenshots.

## Global sections

Treat sections named `Context`, `Notes`, `Environment`, `Test accounts`, `Constraints`, or `Out of scope` as applying to all tasks. Respect `Out of scope` strictly.

Files created by the intake skill also have:
- `## Client` — name, language, channel. Its presence means a client delivery note (`.devrun/DELIVERY.md`) is written at the end of the run.
- `## Approval` — `Status: pending | changes-requested | approved`, plus who/when/evidence. Anything other than `approved` pauses the run until the user decides.

## Per-task lines from intake

- `Client said:` — the client's original words. Part of the description; use it to check the implementation matches what they meant.
- `Size:` — the user's rough sizing. Informational only.
- `Question:` — an open question. Blocking until removed; ask the user rather than guessing.

## Writing back

- Checkbox files: tick `- [x]` when a task is verified done. Append ` — blocked: <one-line reason>` to blocked items. Change nothing else in the file.
- Other formats: leave the file untouched; status lives in `.devrun/PLAN.md` and `REPORT.md`.

## Example (recommended format to share with users)

See `../examples/TASKS.example.md`.
