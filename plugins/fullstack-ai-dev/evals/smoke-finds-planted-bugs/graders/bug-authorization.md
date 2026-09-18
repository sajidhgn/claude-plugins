---
type: llm
weight: 2
---

Planted bug: any signed-in user can open another user's order by its id (for example bob can fetch alice's order).

PASS if the response reports that one user can see another user's order.
FAIL if it says order privacy works, or does not mention this problem.
