# Test data & environment safety

## What "real data" means

Realistic inputs that match what actual users send — not reckless use of real users' data.

- **Realistic content:** names and text in the languages users actually write (including Arabic and mixed Arabic–English), real phone and email formats, realistic lengths (a 60-character product name, a 2,000-character description), prices with decimals, realistic quantities.
- **Realistic files:** a 4 MB phone JPEG, a HEIC, a PNG with transparency, a multi-page PDF, a portrait video — at the sizes users upload.
- **Realistic volume:** lists with 50+ items, pagination, search with several matches.
- **Realistic edges:** emoji, RTL + LTR in one string, leading/trailing spaces, duplicate submissions, very long words, special characters in names (O'Brien, Ñ, ـ).

**Data sources, in order of preference:** (1) the project's seed/fixture scripts; (2) test accounts the user provides; (3) generated data with a locale-aware faker (`ar_SA`, `en_US`, …); (4) anonymized production copies — only if the user supplies them.

## Environment rules

| Env | Reads | Writes | Notes |
|---|---|---|---|
| local | yes | yes | Default. Seeding/resetting the **local** DB is fine. |
| staging / preview | yes | yes, tagged and cleaned up | Use test accounts. |
| production | own test account only | only if the user approved in this conversation — tagged, minimal, cleaned up | No bulk operations, no load. |

## Hard rules (every environment)

- **Payments:** sandbox/test keys and test cards only. If only live keys are configured, skip the payment step and report it as "not tested — live keys only".
- **Messaging:** never send email/SMS/WhatsApp/push to real recipients. Use a local sink (Mailpit/MailHog), the provider's sandbox, or an address the user designates.
- **Paid APIs (LLM, image/video generation):** respect `budget` in `.devrun/state.json` (default: 50 LLM calls, 10 media generations per run). Ask before exceeding. Never loop paid calls.
- **Tag everything you create** with the run ID: names/titles prefixed `smoke-<run_id>`, emails like `smoke-<run_id>+1@example.test`. It makes cleanup and auditing possible.
- **Credentials:** use provided test accounts, or create them locally/staging. Store any created credentials only in `.devrun/accounts.md` (gitignored). Never print secrets; redact tokens in evidence (`sk-…abcd`).
- **No load tests, fuzzing at volume, or security scanners** against non-local environments without explicit approval.
- **Stop immediately** and report if a test appears to touch real users' data or trigger real-world side effects (charges, messages, shipments).
