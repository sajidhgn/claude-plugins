---
description: Black-box smoke test of a small order API with three planted bugs and two correct decoys.
tags: [smoke, heavy]
max_turns: 60
timeout_seconds: 1200
allowed_tools: [Read, Glob, Grep, Skill, Agent, Write, Bash]
---

The coupon, order-limit, and order-privacy tasks in TASKS.md are done. Before I send this to the client, test it like a real customer would. The API is driven with `node api.js` — see README.md. Report what's broken; don't fix anything.
