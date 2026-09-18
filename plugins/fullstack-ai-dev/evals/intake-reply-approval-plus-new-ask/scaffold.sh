#!/usr/bin/env bash
set -euo pipefail
cat > TASKS.md <<'EOF'
# Tasks — Lamsa Store — 2026-09-18

## Client
- Name: Nora
- Language: Arabic
- Channel: WhatsApp
- Received: 2026-09-18

## Approval
- Status: pending
- Approved by: —
- Date: —
- Evidence: —

## Context
Lamsa online store (Next.js storefront).

## Out of scope
- Ranking first on Google

## Tasks

- [ ] **Faster product page**
  - What: Reduce product page load time on mobile.
  - Client said: "صفحة المنتج بطيئة مرة"
  - Size: M
  - Acceptance:
    - Product page opens in under 2 s on a mid-range phone on 4G
    - Images still load at full quality when zoomed

- [ ] **Bigger red add-to-cart button**
  - What: Keep the button red, increase its size on product and listing pages.
  - Client said: "خلوا الزر أحمر زي ما هو بس كبروه شوي"
  - Size: S
  - Acceptance:
    - Button is red and visibly larger on mobile and desktop
    - Button stays fully visible on a 375px-wide screen

- [ ] **Apple Pay at checkout**
  - What: Add Apple Pay as a payment method.
  - Client said: "أبغى نضيف الدفع بأبل باي"
  - Size: L
  - Acceptance:
    - Customers on iPhone/Safari can pay with Apple Pay
    - A declined payment shows a clear message and the cart is kept
EOF
