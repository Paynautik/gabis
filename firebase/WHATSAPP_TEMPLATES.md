# The three WhatsApp templates

WhatsApp does not let a business start a conversation in its own words. Anything
we send to someone who has not written to us in the last 24 hours has to be a
template Meta approved beforehand, with only the blanks filled in — free text
comes back as error 131047 and the customer hears nothing at all.

So these three have to exist in Meta before the chaser can send anything. They
are generated from `workers/chaser/src/template.ts`; if the words change there,
the template has to be resubmitted and approved again.

## Submitting them with the script

Three templates typed by hand is where the mistakes happen — a category left on
Marketing, a language of `en_US` the worker will never match, a placeholder that
drifted from its body. The script posts exactly what `src/template.ts` says:

```
cd workers/chaser
WABA_ID=<WhatsApp Business account ID> WHATSAPP_TOKEN=<token> \
  node --experimental-strip-types scripts/submit-templates.ts
```

Both values are on the WhatsApp **API Setup** page. Re-running is safe: a
template that already exists is reported and skipped.

## Submitting them by hand

Meta dashboard → WhatsApp Manager → Message templates → Create template.

For each of the three below:

- **Category:** Utility. Not Marketing — these are transactional reminders about
  money already owed, and the wrong category costs more per message and invites
  a rejection.
- **Language:** English (`en`). The code sends `en`; a template approved only as
  `en_US` will not match.
- **Name:** exactly as given. The worker asks for these names by string.
- **Body:** copy exactly, placeholders included.
- **Footer:** the same one line on all three.
- **Sample values:** Meta asks for an example of each placeholder before it will
  submit. The samples below are what the worker actually produces.

Approval usually takes a few hours. Two of Meta's rules are worth knowing before
editing any of this, because breaking either is rejected with nothing more
useful than "Invalid parameter": two placeholders may not sit next to each other
with only a space between them, and a body may not end on a placeholder.

## First reminder

**Name:** `gabis_reminder_first`
**Category:** Utility · **Language:** English (`en`)

**Body:**

```
Hello {{1}}, this is {{2}}. Your balance is {{3}}, and it {{4}}. You can pay from your gabis app, or reply here if you need a new date.

Pay here: {{5}}

Thank you.
```

**Footer:**

```
Sent through gabis. Reply STOP to opt out of reminders.
```

**Samples:** `{{1}}` Adaeze · `{{2}}` Gabis Ventures · `{{3}}` ₦250,000.00 · `{{4}}` was due 12 days ago · `{{5}}` https://gabis.pages.dev/pay?i=abc

## Second reminder

**Name:** `gabis_reminder_second`
**Category:** Utility · **Language:** English (`en`)

**Body:**

```
Hello {{1}}, {{2}} again about your balance of {{3}}, which is {{4}}. We have not heard back on the first reminder. Can you pay today, or reply with the date you will pay so we can hold it?

Pay here: {{5}}

Thank you.
```

**Footer:**

```
Sent through gabis. Reply STOP to opt out of reminders.
```

**Samples:** `{{1}}` Adaeze · `{{2}}` Gabis Ventures · `{{3}}` ₦250,000.00 · `{{4}}` now 12 days overdue · `{{5}}` https://gabis.pages.dev/pay?i=abc

## Final automated reminder

**Name:** `gabis_reminder_final`
**Category:** Utility · **Language:** English (`en`)

**Body:**

```
Hello {{1}}. This is the last automated reminder from {{2}} about your balance of {{3}}, which is {{4}}. After this someone from our team will contact you directly to agree how it will be settled. If you have already paid, reply with the date and we will match it.

Pay here: {{5}}

Thank you.
```

**Footer:**

```
Sent through gabis. Reply STOP to opt out of reminders.
```

**Samples:** `{{1}}` Adaeze · `{{2}}` Gabis Ventures · `{{3}}` ₦250,000.00 · `{{4}}` now 12 days overdue · `{{5}}` https://gabis.pages.dev/pay?i=abc

## After approval

Nothing to deploy — the worker already asks for these names. Check one really
went out rather than trusting the status line:

```
curl -s https://gabis-chaser.gabis-chaser.workers.dev/queue
```

An attempt written with outcome `link_sent` is one WhatsApp accepted. `rehearsed`
means no credentials; a held item names the rule that held it.

While the test number is in use, only the numbers added as recipients in the
Meta dashboard can receive anything — a real debtor gets nothing, however
approved the template is.
