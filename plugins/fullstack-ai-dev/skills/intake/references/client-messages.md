# Client messages

## Writing rules

- Plain words only. No developer terms: not "endpoint", "API", "deploy", "migration", "bug fix in the backend". Say what the client will see or be able to do.
- Numbered list of outcomes, one line each. These are the same outcomes as the acceptance criteria in the task file, rephrased for the client.
- Questions: at most 5, each answerable in one line, with options where possible.
- State assumptions so the client can correct them by exception ("We'll keep your current colors and fonts").
- Out-of-scope items: polite, one line each, with an offer to handle them separately.
- End with a clear, single approval request.
- Use the client's language. WhatsApp: no headings or markdown, under ~15 lines, emoji only if the client uses them. Email: subject line plus the same structure.
- Never include internal task IDs, sizes, prices, file names, or commit hashes.

## Confirmation — English (WhatsApp)

```
Hi [Name], thanks for the details. Here's what we'll do:

1. [Outcome in plain words]
2. [Outcome]
3. [Outcome]

Unless you tell us otherwise, we'll [assumption].

Before we start, a few quick questions:
a) [Question]? ([option] or [option])
b) [Question]?

Not included this round:
- [Item] — happy to quote it separately.

Reply "approved" and we'll get started.
```

## Confirmation — Arabic (WhatsApp)

```
مرحباً [الاسم]، شكراً على التفاصيل. هذا ما سننفذه:

1. [النتيجة بكلمات بسيطة]
2. [النتيجة]
3. [النتيجة]

ما لم تخبرنا بغير ذلك، سنعتمد [الافتراض].

قبل البدء، نحتاج إجابة سريعة على:
أ) [السؤال]؟ ([خيار] أو [خيار])
ب) [السؤال]؟

غير مشمول في هذه المرحلة:
- [البند] — يسعدنا تقديم عرض منفصل له.

إذا كان كل شيء مناسباً، أرسل "موافق" ونبدأ العمل.
```

## Email subject lines

- English: `Confirming the requested updates — [project]`
- Arabic: `تأكيد التعديلات المطلوبة — [اسم المشروع]`

## Follow-up after answers

English:
```
Thanks, [Name]. Here's the final list:

1. [Outcome]
2. [Outcome]

Reply "approved" and we'll start.
```

Arabic:
```
شكراً [الاسم]، هذه القائمة النهائية:

1. [النتيجة]
2. [النتيجة]

أرسل "موافق" ونبدأ مباشرة.
```

## Checking a bare acknowledgement

English: `Just to confirm — shall we start on the list as it is?`
Arabic: `للتأكيد فقط: هل نبدأ بتنفيذ القائمة كما هي؟`

## Approval rules

**Counts as approval** when it answers the confirmation message and doesn't add conditions:
- English: "approved", "go ahead", "confirmed", "yes, start", "let's go".
- Arabic: "موافق"، "معتمد"، "اعتمد"، "تم الاعتماد"، "ابدأ" / "ابدؤوا"، "توكل على الله"، "تمام، ابدأ".

**Does not count on its own**, especially when the message you sent contained questions: "ok", "تمام", "طيب", "شكراً", 👍, a voice note you haven't seen transcribed. Send the acknowledgement check instead.

**Approval with conditions or new asks** ("approved, and also add…"): approve the current list, and start a new round for the additions.

Record on approval: `Approved by` (name), `Date`, `Evidence` (channel + short quote, e.g. `WhatsApp — "موافق، توكل على الله"`).

## Delivery note (written by run-tasks at the end of a run)

Only list items from the approved task file. Base each status on the smoke-test results, not on what was implemented. Suggest screenshots from `.devrun/evidence/` that show the result with test data; never include screenshots that show passwords, keys, or internal tools.

English:
```
Hi [Name], the updates are ready:

✅ 1. [Outcome] — you can see it at [page / screen]
✅ 2. [Outcome]
⚠️ 3. [Outcome] — done, except [what's left], because [plain reason]
❌ 4. [Outcome] — not done yet: [plain reason]. Next step: [what happens next]

Screenshots attached.
[What we need from you, if anything]
```

Arabic:
```
مرحباً [الاسم]، التحديثات جاهزة:

✅ 1. [النتيجة] — يمكنك مشاهدتها في [الصفحة / الشاشة]
✅ 2. [النتيجة]
⚠️ 3. [النتيجة] — تمت، باستثناء [المتبقي] بسبب [السبب بكلمات بسيطة]
❌ 4. [النتيجة] — لم تكتمل بعد: [السبب]. الخطوة التالية: [ما سيحدث]

مرفق صور توضيحية.
[ما نحتاجه منك، إن وجد]
```
