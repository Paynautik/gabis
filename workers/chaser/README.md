# gabis-chaser

The rail that makes reminders autonomous.

Everything in the app up to this point needs somebody to be holding the phone.
This worker runs the same queue on a cron trigger, so a business that is asleep,
busy or simply sick of asking still gets its money chased — inside rules a cron
job cannot talk itself out of.

## Why the rules are written twice

`src/policy.ts` is a port of `ContactPolicy` in the Flutter app, and the
duplication is deliberate. The app's copy stops a person pressing a button at
midnight. This copy stops an unattended job doing it three thousand times before
anyone notices. Both enforce the same things: a lawful basis for holding the
number, 08:00–20:00 Lagos, one approach a day, three in a rolling week, and a
refusal that ends the sequence permanently.

## What it holds, and what it does not

The app syncs a name, a phone number, an amount, a due date, and the lawful
basis. Nothing else: no invoice descriptions, no emails, no addresses. The
statement link it stores is opaque to the worker — the invoice details live in
that URL's fragment, which never leaves the client's browser.

## Sending

With no WhatsApp credentials the sender rehearses: it works out exactly what
would go out, writes it to `attempts` with outcome `rehearsed`, and sends
nothing. That is the honest default — a half-configured sender that silently
drops reminders is worse than one that says it did nothing. Set
`WHATSAPP_TOKEN` and `WHATSAPP_PHONE_ID` to make it real.

## Setting it up

```bash
cd workers/chaser
npx wrangler d1 create gabis-chaser          # put the id in wrangler.toml
npx wrangler d1 execute gabis-chaser --file schema.sql --remote
npx wrangler secret put WHATSAPP_TOKEN       # optional; rehearses without it
npx wrangler secret put WHATSAPP_PHONE_ID
npx wrangler deploy
```

Each business needs a row in `businesses` with `token_hash` set to the SHA-256
of the token the app will present. Build the app with the matching values:

```bash
flutter build web --release \
  --dart-define=CHASER_URL=https://gabis-chaser.<subdomain>.workers.dev \
  --dart-define=CHASER_BUSINESS_ID=<id> \
  --dart-define=CHASER_TOKEN=<token>
```

Without those three the app says the rail is not configured rather than showing
a switch that does nothing.

## Endpoints

| Route      | Who calls it   | What it does                                  |
|------------|----------------|-----------------------------------------------|
| `POST /sync`   | the app     | Replaces this business's queue; sets the switch |
| `GET /queue`   | the app     | What would go out next, and why it would not    |
| `POST /run`    | you         | The cron pass, on demand, for testing it        |
| `POST /inbound`| the provider| A reply of STOP; honoured permanently           |

`/inbound` is deliberately unauthenticated: the worst a forged call can do is
stop somebody's reminders, which is the safe direction to fail in.

## Tests

```bash
node --experimental-strip-types --test test/policy.test.ts
```
