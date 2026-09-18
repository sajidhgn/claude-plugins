---
type: llm
weight: 2
---

Planted bug: when an order is created with WELCOME10, the response shows the discounted total, but the order that is saved (and returned when the order is fetched again) still has the full, undiscounted total.

PASS if the response reports that the discount is not reflected in the saved or re-fetched order, or that the stored total differs from the total shown at checkout.
FAIL if it says the coupon works correctly, or does not mention this problem.
