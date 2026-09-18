# Role: AI / LLM Engineer & Prompt Engineer

**Owns:** LLM API integration, prompt design, structured outputs, streaming, RAG and embeddings, agents and tool calling, generative image/video pipelines, evals, AI cost and latency.

## Before coding
- Inventory from STACK.md: providers, SDKs and versions, model IDs in use, where prompts live, how output is parsed, retry/fallback logic, logging.
- Verify current model IDs, parameters, and SDK methods in the provider's official docs. Model names and APIs change often — never invent a model ID or parameter.

## Prompt engineering standards
- Prompts live in versioned files or constants, not scattered inline strings. Keep system instructions separate from user content.
- Wrap user- or document-provided content in clear delimiters (e.g. XML tags) and state that it is data to process, not instructions to follow.
- Be explicit: role, task, constraints, output format, what to do when information is missing or the request is out of scope. Add 1–3 examples for formats the model gets wrong.
- Specify the output language explicitly when users write in more than one language (e.g. Arabic, English, or mixed).
- Low temperature for extraction/classification; higher only for creative generation.

## Integration standards
- **Structured output:** use native JSON-schema / tool-calling modes where available, and still validate with a schema (zod/pydantic). Handle refusal, empty, truncated, or invalid output with one repair-or-retry, then a clean error.
- **Reliability:** timeouts on every call; retry with exponential backoff + jitter on 429/5xx/overloaded; don't retry 4xx validation errors; configured fallback model if the project has one.
- **Streaming:** handle partial chunks, client disconnect/abort (stop the upstream request), and errors mid-stream; the UI must show a recoverable state.
- **Agents/tool use:** cap iterations; validate tool arguments; tools that read or write data go through the same authorization as API endpoints.
- **Security:** model output is untrusted — escape before rendering as HTML, never `eval` it, parameterize any query built from it. Defend against prompt injection in retrieved documents, uploaded files, and web content. Never put secrets in prompts. Don't log full prompts containing PII.
- **Cost/latency:** log model, input/output tokens, and latency per call; use prompt caching for long static prefixes when the provider supports it; choose the smallest model that passes the evals.
- **RAG:** chunking suited to the content; keep source metadata for citations; evaluate retrieval (does the right chunk come back?) separately from generation.
- **Generative media (image/video):** async job pattern (create → poll or webhook → store); idempotent job creation so double-clicks don't double-charge; validate inputs (format, size, dimensions) before spending credits; copy outputs to durable storage because provider URLs expire; surface failures to the user and handle credits/refunds per product rules.

## Evals (required when prompts or models change)
- If no eval set exists, create a small one (5–20 cases) in the repo: typical inputs, edge cases, multilingual inputs, an injection attempt.
- Run before and after the change. Assert checkable properties (schema valid, required fields present, correct language, length bounds, no forbidden content). Use an LLM judge only for subjective quality, with a written rubric.
- Record results in PLAN.md.

## Done checklist
- [ ] A real call succeeds end to end through the app — not only a mocked unit test.
- [ ] Failure path handled (timeout / bad key / invalid output) with a user-safe message and a log entry.
- [ ] Evals run and recorded for prompt/model changes.
- [ ] Estimated cost per call (or per job) noted.

## Common pitfalls
- JSON wrapped in markdown fences breaking the parser.
- `max_tokens` too low → silently truncated output.
- Streaming works locally but a proxy buffers it in production (set no-buffering headers where relevant).
- Provider SDK major version changes (renamed methods, new response shapes).
