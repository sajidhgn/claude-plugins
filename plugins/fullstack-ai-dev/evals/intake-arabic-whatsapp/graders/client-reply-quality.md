---
type: llm
weight: 2
---

Judge the draft reply to the client contained in the response.

PASS only if ALL of these hold:
1. There is a draft message addressed to the client, written in Arabic.
2. It lists the planned work in plain, non-technical language (no words like API, endpoint, deploy, migration, backend).
3. It asks at most 5 questions.
4. It asks the client to explicitly confirm or approve before work starts.

FAIL if there is no draft, the draft is mainly in English, it uses developer jargon, it asks more than 5 questions, or it does not ask for approval.
