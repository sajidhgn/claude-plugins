# Sprint 14 — Product studio

## Context
Next.js web app + FastAPI backend + Expo mobile app. Local stack: `docker compose up -d && pnpm dev`.

## Environment
- Target: local
- Test accounts: `owner@example.test` / see 1Password "Studio test accounts"

## Out of scope
- Billing page redesign

## Tasks

- [ ] **Add Arabic output to the product description generator**
  - Users can pick "Arabic" or "English" before generating.
  - Acceptance:
    - Arabic output is Modern Standard Arabic and renders right-to-left.
    - Generation for either language returns in under 10 s for a typical product.
    - Existing English prompts still pass the eval set.

- [ ] **Fix: checkout returns 500 when a coupon is applied**
  - Repro: add any product, apply `WELCOME10`, click Pay.
  - Acceptance:
    - Order total reflects the discount; order is created.
    - Expired coupons show "This coupon has expired" and no 500.

- [ ] **Show progress for video generation jobs (web + mobile)**
  - Depends on: status endpoint `GET /jobs/{id}` (exists).
  - Acceptance:
    - Progress updates at least every 5 s while the job runs.
    - Failed jobs show the reason and a "Try again" button.
    - Leaving and returning to the page resumes progress.
