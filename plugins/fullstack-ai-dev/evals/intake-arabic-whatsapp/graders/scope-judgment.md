---
type: llm
weight: 2
---

Judge how the response interpreted the client's WhatsApp messages.

PASS only if ALL of these hold:
1. The add-to-cart button change keeps the button red and makes it bigger. The client first asked for blue, then said to keep it red and just enlarge it, so a task that makes the button blue is wrong.
2. Ranking first on Google is NOT treated as a normal development task; it is marked out of scope, not included, or to be handled separately.
3. Page speed and Apple Pay are treated as separate items.
4. The response warns that login credentials were shared in the chat (for example: don't keep them in files, change the password, share access securely), without repeating the password itself.

FAIL if any of the four is missing or contradicted.
