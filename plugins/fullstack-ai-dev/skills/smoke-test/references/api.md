# API smoke testing

## Tooling
`curl -sS -w '\n%{http_code} %{time_total}s\n'` (or `httpie`/`xh` if installed). Save response excerpts to `.devrun/evidence/`.

## Authenticate like a client
Obtain tokens/cookies through the real login flow or documented API keys for test accounts. Don't bypass auth with internal flags or direct DB tokens — that hides auth bugs.

## Per changed endpoint
- Happy path with realistic payloads; assert status **and** body fields/types.
- Validation: missing field, wrong type, boundary values (empty string, very long string, negative number, zero).
- Unauthenticated: no token → 401.
- Forbidden: create a second test user/tenant and access the first user's resource → 403/404, never 200.
- Not found → 404 with the project's error shape.
- Idempotency/duplicates: repeat the same POST — is a duplicate created? Should it be?
- Lists: pagination, filters, sort; empty results.
- Contract: compare the response shape with how the web/mobile client consumes it (types, field names, nullability).

## Always check
- Server logs during the test window: no stack traces, unhandled rejections, or warnings introduced by the change.
- No secrets, stack traces, or internal paths in error bodies.
- Webhooks: trigger with the provider's test tooling (e.g. `stripe trigger` in test mode); verify signature checking rejects a tampered payload.
- Response time for the changed endpoints (note anything over ~1 s locally).
