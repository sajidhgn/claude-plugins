---
type: regex
target: { source: file, path: TASKS.md }
pattern: '- \[ \] \*\*[^\n]*(واتساب|whatsapp)'
flags: i
match: not_contains
weight: 2
---
