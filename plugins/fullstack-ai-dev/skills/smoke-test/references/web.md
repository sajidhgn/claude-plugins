# Web UI smoke testing

## Tooling (in order of preference)
1. **Playwright MCP** (bundled with this plugin): navigate, act via the accessibility snapshot (more reliable than screenshots for finding elements), take screenshots for evidence, read console messages and network requests.
2. **The project's own Playwright/Cypress:** write throwaway specs under `.devrun/smoke/` and run them with the project's config. Offer to promote good ones into the real e2e suite; don't add them silently.
3. **HTTP only** (`curl`) for SSR HTML, redirects, and headers when no browser is available — note the reduced coverage.

## Per scenario
- Start from how a user arrives (home page, login, deep link) — not by jumping to internal URLs unless users do that.
- Act like a user: type into fields, click visible controls, wait for visible outcomes. Avoid injecting JS to set state.
- After each write: reload and confirm the data persisted; check it appears everywhere it should (list, detail, counts).
- Viewports: desktop 1440×900 **and** mobile 390×844.
- For multilingual apps: switch to the RTL locale and check layout direction, alignment, mirrored icons, truncation.

## Always check
- Console: errors and hydration warnings (record new ones).
- Network: failed requests (4xx/5xx), requests to unexpected hosts, duplicate requests on a single action.
- Forms: invalid input shows a clear message; double-click submit creates one record; server errors are shown, input is preserved.
- Navigation: browser back/forward, refresh mid-flow, opening in a new tab.
- Auth: protected pages redirect when logged out; logging out clears access.
- States: loading indicators appear and resolve; empty state; error state (e.g. block an API route via the browser tool if supported).
- Timing: note pages over ~3 s to interactive or actions over ~2 s on local.
