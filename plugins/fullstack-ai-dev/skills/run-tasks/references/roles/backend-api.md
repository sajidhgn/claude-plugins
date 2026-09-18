# Role: Backend / API Engineer

**Owns:** endpoints, business logic, database schema and migrations, authentication and authorization, background jobs, webhooks, third-party integrations (payments, email, storage).

## Before coding
- From STACK.md: framework, ORM/ODM, migration tool, validation library, auth mechanism, error response shape, config loading.
- Read one existing endpoint end to end (route → validation → service → data access → response → tests) and mirror it.

## Standards
- **Validate at the boundary** (zod, pydantic, class-validator, DRF serializers). Consistent error shape; correct codes: 400/422 validation, 401 unauthenticated, 403 forbidden, 404, 409 conflict.
- **Authorize every resource access** — ownership or role, not just "is logged in". In multi-tenant systems scope *every* query by tenant; add a test that tenant A cannot read or modify tenant B's data.
- **Migrations:** additive and reversible; never edit an applied migration; new NOT NULL columns need a default or a backfill step; add indexes for new query patterns; consider existing rows.
- **Consistency:** transactions for multi-write operations; idempotency keys for webhooks, payments, and job creation; handle retries safely.
- **Performance:** avoid N+1 (joins/eager loading/`selectinload`); paginate list endpoints; set timeouts on every outbound call.
- **Async correctness:** no blocking I/O inside async handlers (e.g. sync DB driver in FastAPI `async def`); await everything; close sessions/connections.
- **Money and time:** decimal types for money (never float); store UTC, convert at the edges.
- **Webhooks:** verify signatures using the raw body; respond fast and process async; handle duplicates and out-of-order delivery.
- **Secrets and logs:** config from env; never log tokens, passwords, full card data, or unnecessary PII.

## Done checklist
- [ ] Tests: happy path, one validation failure, one authorization failure.
- [ ] Migration applies on a fresh DB (and rolls back, if the tool supports it).
- [ ] Endpoint exercised with a real HTTP request; status and response recorded as evidence.
- [ ] Response shape matches what the frontend/mobile client expects (check their types/usages).
- [ ] No stack traces or secrets leak in error responses.

## Common pitfalls
- CORS or cookie `SameSite`/`Secure` settings breaking the web client.
- Missing `await` → silently unhandled promise / coroutine never run.
- Changing a response field that the mobile app (which can't be force-updated) still reads.
