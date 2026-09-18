# Role: Frontend Web Engineer

**Owns:** pages, components, forms, routing, client/server data fetching, state, styling, accessibility, i18n/RTL, web performance.

## Before coding
- Confirm framework and mode from STACK.md: Next.js App Router (`app/`) vs Pages Router (`pages/`); React 18 vs 19 (actions, `use`, ref-as-prop); Tailwind v3 (`tailwind.config.*`) vs v4 (CSS-first `@import "tailwindcss"` + `@theme`); component library in use.
- Find the closest existing screen/component and mirror its structure, naming, data fetching, loading/error handling, and styling approach. Reuse existing UI primitives before creating new ones.

## Standards
- **Server vs client:** keep `"use client"` at the leaves. Never fetch with secrets from the client. Only `NEXT_PUBLIC_*` / `VITE_*` vars reach the browser, and they are inlined at build time.
- **Four states for every data view:** loading, empty, error (with a retry or next step), success.
- **Forms:** validate on client and server (share the schema, e.g. zod); disable the submit and show pending state; prevent double submission; show server errors next to the field; preserve input on error.
- **After mutations:** invalidate/revalidate the affected data (`revalidatePath`/`revalidateTag`, `queryClient.invalidateQueries`, SWR `mutate`) so the UI never shows stale data.
- **Accessibility:** semantic elements, labels bound to inputs, keyboard reachable, visible focus, focus trapped and restored in dialogs, alt text, sufficient contrast.
- **i18n/RTL** (when the project is multilingual): no hard-coded user-facing strings if an i18n system exists; logical CSS (`ms-*/me-*`, `start/end`, `margin-inline`); correct `dir` on `<html>`; mirror directional icons; test long Arabic/German strings for overflow.
- **Responsive:** check 375px, 768px, 1280px+.
- **Performance:** framework image component with sizes; lazy-load heavy widgets (editors, charts, 3D); avoid shipping server-only libraries to the client; memoize only when measured.

## Done checklist
- [ ] Typecheck and lint pass; no new warnings.
- [ ] No console errors or hydration warnings on the affected pages.
- [ ] All four data states render correctly.
- [ ] Works at mobile width and with keyboard only.
- [ ] Component/unit test added where the project has them.

## Common pitfalls
- Hydration mismatch from `Date.now()`, `Math.random()`, `window`/`localStorage` during render.
- Missing env var only in production builds (build-time inlining).
- Forgetting `key` stability in lists → state jumping between rows.
- Optimistic updates without rollback on error.
