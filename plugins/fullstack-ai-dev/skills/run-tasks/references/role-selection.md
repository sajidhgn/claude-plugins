# Role selection

One senior developer, six hats. Pick the hat that owns the **core risk** of each task, then borrow checklists from the others it touches. Every task is verified by the smoke-tester regardless of role.

## Roster

| Role | Owns | Task text signals | Codebase signals |
|---|---|---|---|
| `frontend-web` | UI, pages, components, forms, client state, styling, SSR/SSG, accessibility, i18n/RTL, web performance | page, screen (web), component, form, button, layout, responsive, dark mode, UX, animation, SEO, hydration | `.tsx/.vue/.svelte` under `app/`, `pages/`, `components/`; Tailwind/CSS; Next/Vite configs |
| `backend-api` | endpoints, business logic, DB schema and migrations, auth/authz, jobs, webhooks, third-party integrations, payments | endpoint, API, 500, validation, database, migration, query, permission, role, webhook, queue, email, payment | routes/controllers/services, ORM models, migrations, `schemas/`, `api/` |
| `mobile` | React Native/Expo, Flutter, native screens, navigation, device APIs, push, offline, store config | iOS, Android, app, screen (mobile), push notification, deep link, camera, offline, TestFlight, APK | `app.json`, `eas.json`, `ios/`, `android/`, `pubspec.yaml`, RN components |
| `ai-llm` | LLM calls, prompt design, RAG, embeddings, agents/tool use, structured outputs, streaming, generative media pipelines, evals, AI cost/latency | prompt, model, LLM, GPT/Claude/Gemini, generate, AI, chat, embedding, RAG, agent, hallucination, image/video generation | provider SDKs, model IDs, `prompts/`, vector DB clients, job/polling code for generation APIs |
| `devops` | containers, CI/CD, env config, deploy config, IaC, observability | Docker, CI, pipeline, deploy, env, logging, monitoring, build fails | Dockerfile, compose, `.github/workflows`, `*.tf`, platform configs |
| `qa-test` | tests as the deliverable: unit/integration/e2e suites, flaky tests, coverage, test infra | test, coverage, flaky, e2e, regression suite, QA | test configs, `__tests__`, `tests/`, `.maestro/` |

## Routing procedure

1. List the layers the task changes (UI, API, DB, mobile, AI, infra, tests).
2. **Primary** = the layer where the acceptance criteria are hardest to satisfy or where a mistake does the most damage (data loss, security, cost, broken core flow).
3. **Supporting** = every other layer touched. Apply their done-checklists.
4. **Bugs:** tentatively assign by symptom, then re-assign after reproducing to the layer where the root cause actually lives.
5. **Lead role** for the file = the most frequent primary role; if tied, the riskiest. If the file spans three or more layers evenly, the lead is "fullstack: <top two roles>".

## Tie-breakers

- AI feature with a UI: `ai-llm` if the criteria are about what the model produces (quality, format, language, safety, cost); `frontend-web` if they are about how results are shown (layout, streaming render, states).
- Data model + UI for a new feature: `backend-api` primary (schema mistakes are expensive to undo).
- Mobile screen consuming a new endpoint: `backend-api` primary if the endpoint doesn't exist yet, otherwise `mobile`.
- "Make it faster": profile first; the role is wherever the time is actually spent.
- Security-related (authz, secrets, injection): primary is the layer that enforces the rule — usually `backend-api`, or `ai-llm` for prompt injection defenses.

## Examples

| Task | Primary | Supporting | Why |
|---|---|---|---|
| Add Arabic output option to the product description generator | ai-llm | frontend-web (RTL display) | criteria are about model output language and quality |
| Checkout returns 500 when a coupon is applied | backend-api | frontend-web | root cause in order total calculation (after reproducing) |
| Add pull-to-refresh and empty state to Orders screen | mobile | — | RN screen behavior |
| Stream chat replies token by token | ai-llm | frontend-web | server streaming transport and error handling are the risk |
| Show generation progress bar for video jobs | frontend-web | backend-api (status endpoint), ai-llm (job states) | UI states over an existing job API |
| Dockerize the FastAPI service with Postgres | devops | backend-api | container and compose config |
| Checkout e2e test is flaky in CI | qa-test | devops | test determinism is the deliverable |
| Multi-tenant: users can see other schools' students | backend-api | qa-test | authorization scoping; add cross-tenant tests |
