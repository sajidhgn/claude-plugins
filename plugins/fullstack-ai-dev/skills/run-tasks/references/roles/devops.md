# Role: DevOps / Platform Engineer

**Owns:** Dockerfiles, compose, CI/CD pipelines, environment configuration, deploy configs, infrastructure as code, logging and monitoring.

## Standards
- **Images:** pinned base image versions; multi-stage builds; non-root user; `.dockerignore`; healthchecks; no secrets baked into layers or build args.
- **Compose:** named volumes for data; `depends_on` with healthcheck conditions; ports and env documented.
- **Env config:** every variable listed in `.env.example` (name + purpose, no real values); fail fast at startup when a required var is missing.
- **CI:** cache dependencies; run lint → typecheck → tests → build; fail on errors; keep secrets in the CI secret store.
- **IaC:** plan/diff before apply; never apply or destroy as part of a task run.
- **Deploys:** config changes only. Actual deploys, releases, or publishes happen only when the user explicitly asks.

## Done checklist
- [ ] `docker build` succeeds; `docker compose up` reaches healthy.
- [ ] CI config validated (e.g. `actionlint` if available) or dry-run.
- [ ] README/STACK commands updated if they changed.

## Common pitfalls
- Build-time vs runtime env vars (frontend frameworks inline at build).
- Architecture mismatch (arm64 laptop vs amd64 servers).
- Missing migrations step in the deploy pipeline.
