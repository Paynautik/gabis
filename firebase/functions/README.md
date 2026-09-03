# chaser

Scheduled collections reminders, on the Firebase project the app already uses.

Everything in the app up to this point needs somebody to be holding the phone.
This runs the same queue on a schedule, so a business that is asleep, busy or
simply sick of asking still gets its money chased — inside rules a scheduled
job cannot talk itself out of.

## Where the queue lives

`users/{uid}/gabis/collections`, written by `AutonomousReminders` in the app
through the same `UserSync` that already carries the rest of the account. That
is the whole reason this is a Firebase function rather than something standing
on its own: no second store to run, no service token to hand out, and no
separate notion of who a business is, because Firebase Auth already answered
that.

Attempts go to the `attempts` subcollection under that document. The rules let
the owner read them and let nobody edit them: the log is what the frequency
limits are counted from, and what settles a dispute.

## Why the rules are written twice

`src/policy.ts` is a port of `ContactPolicy` in the Flutter app, and the
duplication is deliberate. The app's copy stops a person pressing a button at
midnight. This copy stops an unattended job doing it three thousand times
before anyone notices. Both enforce: a lawful basis for holding the number,
08:00–20:00 Lagos, one approach a day, three in a rolling week, and a refusal
that ends the sequence permanently. This side adds two the hand-driven version
got for free — nothing is chased before it is due, or for a zero balance.

## What it holds, and what it does not

A name, a phone number, an amount, a due date, the lawful basis. Nothing else:
no invoice descriptions, no emails, no addresses. The statement link stored
with each debtor is opaque to this function — the invoice details live in that
URL's fragment, which never leaves the client's browser.

## Sending

With no WhatsApp credentials the sender rehearses: it works out exactly what
would go out, writes it to `attempts` with outcome `rehearsed`, and sends
nothing. That is the honest default — a half-configured sender that silently
drops reminders is worse than one that says it did nothing.

```bash
firebase functions:secrets:set WHATSAPP_TOKEN
firebase functions:secrets:set WHATSAPP_PHONE_ID
```

## Deploying

```bash
npm --prefix firebase/functions install
firebase deploy --only functions,firestore:rules
```

Functions on a schedule need the Blaze plan. Until this is deployed the switch
in the app writes `autonomous: true` and nothing reads it, which is inert
rather than broken.

## Functions

| Name      | Trigger              | What it does                                     |
|-----------|----------------------|--------------------------------------------------|
| `chaser`  | 09:00 Africa/Lagos   | One pass: decide, send or rehearse, write it down |
| `inbound` | HTTPS                | A reply of STOP; honoured permanently             |

`inbound` is deliberately unauthenticated: the worst a forged call can do is
stop somebody's reminders, which is the safe direction to fail in.

## Tests

```bash
npm --prefix firebase/functions test
```
