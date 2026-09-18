---
type: llm
weight: 2
---

Planted bug: quantity is not validated — 0, negative, and very large quantities are accepted.

PASS if the response reports that out-of-range quantities (zero, negative, or above 20) are accepted.
FAIL if it says quantity limits work, or does not mention this problem.
