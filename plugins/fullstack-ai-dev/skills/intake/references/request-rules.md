# Turning client requests into tasks

## Reading the material

- **Chat exports:** read in order. Later messages override earlier ones on the same point ("make it blue", then "actually keep it red" → red). If it's unclear whether a later message overrides, turn it into a question.
- **Skip the noise** (greetings, scheduling, small talk), but keep deadlines and priorities ("before Thursday's launch", "this one first").
- **Screenshots:** state what the screenshot shows and what is circled, arrowed, or annotated; tie it to a real page or screen; reference the file name in the task.
- **One sentence, several asks → several tasks.** "Fix the logo and add Apple Pay" is two tasks.
- **The same ask repeated → one task.**
- **Emphasis** ("URGENT!!!", "this looks terrible") is a priority signal, not extra scope.

## Vague → testable

Propose a concrete, checkable outcome. If a reasonable default exists, state it as an assumption in the client message instead of asking. Ask only when the answer materially changes the work.

| Client says | Propose as acceptance | Ask (only if needed) |
|---|---|---|
| "Make it faster" | The page opens in under 2 s on a mid-range phone on 4G | "Is under 2 seconds on mobile good for you?" |
| "Modern / cleaner design" | Not testable yet | "Can you share 1–2 sites or screenshots you like?" |
| "Fix the bug" (no details) | — | "Which page, what did you tap, and what happened? A screenshot or screen recording helps." |
| "Like [competitor]" | — | "Which part of their site: the layout, the product page, or the checkout?" |
| "Support Arabic" | Arabic text, right-to-left layout, nothing overlapping or cut off | "The whole site or specific pages? Who provides the Arabic text?" |
| "Add payments" | Customer can pay with the agreed methods; failed payment shows a clear message | "Which methods (mada, Apple Pay, cards)? Do you already have a payment provider account?" |
| "Make the AI results better" | Not testable yet | "Can you send 2–3 results you didn't like and what you expected instead?" |
| "Same as last time but…" | Find the earlier item in the repo or previous task files | Ask only if it can't be found |

**Question budget:** at most 5 per message. Each answerable in one line, with options where possible. Everything else becomes a stated assumption.

## Classify every item

- **Ready** — clear outcome that can be tested.
- **Question** — the answer blocks the work or changes its size materially. Add a `Question:` line to the task.
- **Out of scope** — not development work (writing marketing copy, running ads, "rank #1 on Google"), or it looks outside the agreed project. List it politely as "not included this round". Whether it's outside the agreement is the user's decision: flag it, don't decide it.
- **Risky** — deleting data, payment or money logic, login and permissions, production access, legal or compliance claims, anything irreversible. Include it, but flag it for the user's explicit OK before the client message goes out.

## Size (rough — for the user's quoting, never shown to the client)

- **S** — text, style, or config change; a small fix in one place.
- **M** — one screen, endpoint, or integration step; a bug that needs investigation.
- **L** — a new feature across layers, a new integration, a data migration, or an AI pipeline change that needs evals.

These are relative sizes, not time estimates.

## Writing each task

- **Title:** the outcome in 3–8 words ("Apple Pay at checkout", not "Payments").
- **What:** 1–3 lines in developer terms, naming real pages, routes, or files when found.
- **Client said:** a short quote in the client's original language, for traceability.
- **Acceptance:** 2–4 observable outcomes, including at least one failure case. These must match the plain-language outcomes in the client message, because the client is approving them.
- **Question:** one line per open question; remove it once answered.
