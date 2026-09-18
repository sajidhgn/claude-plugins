---
description: A one-function edit — must not trigger the heavy task pipeline, intake, or smoke testing.
tags: [negative]
max_turns: 5
allowed_tools: [Read, Glob, Grep, Skill]
---

Add input validation so this throws on negative numbers, and show me the updated function:

function area(width, height) {
  return width * height;
}
