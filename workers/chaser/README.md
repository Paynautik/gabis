# gabis-chaser

The reminder schedule, on Cloudflare, reading the Firestore the app already
writes to.

## Checking the credentials really work

`/status` says whether the secrets exist. It cannot say whether they work: an
expired token, a revoked one, one pasted in twice and one scoped to somebody
else's number all look the same from inside the worker, and the difference only
shows up later as reminders that never arrived.

```
curl -s https://gabis-chaser.gabis-chaser.workers.dev/check
```

Asks WhatsApp about the sending number and reports what it said. Sends no
message and needs no debtor. A failure carries Meta's own sentence and its code:
190 is a token expired, revoked or malformed; 100 is usually a token with no
rights over that number.

## Why here and not Firebase

Scheduled Cloud Functions need the project on the Blaze plan. Firestore does
not. Since `paynautic` is on Spark, the clock moved to Cloudflare — where gabis
already hosts its site and where cron triggers cost nothing — and it talks to
the same Firestore through the REST API with a service account.

Nothing else changed: the queue is still `users/{uid}/gabis/collections`,
written by the app through the account the user signs into. There is no second
datastore and no copy of the ledger.

`policy.ts` and `message.ts` are imported from `firebase/functions/src` rather
than copied, so the day this moves back to a Cloud Function there is one set of
rules to move, not two that have drifted. That Firebase version is still in the
repository and still deploys, if the project is ever upgraded.

## Setting it up

The service account needs Firestore read and write — the `Cloud Datastore User`
role is enough. Create one in the Google Cloud console for `paynautic`, download
its JSON key, then:

```bash
cd workers/chaser
npx wrangler secret put GOOGLE_SA_EMAIL        # client_email from the key file
npx wrangler secret put GOOGLE_SA_PRIVATE_KEY  # private_key, PEM, \n escapes intact
npx wrangler secret put WHATSAPP_TOKEN         # optional; rehearses without it
npx wrangler secret put WHATSAPP_PHONE_ID      # optional; same
npx wrangler deploy
```

Two indexes have to exist in Firestore before a pass can run — a
collection-group index on `gabis.autonomous` and a composite on
`attempts (debtor_name, placed_at)`. They are in `firestore.indexes.json` at
the repository root:

```bash
firebase deploy --only firestore:indexes --project paynautic
```

## Seeing what it would do

```bash
curl https://gabis-chaser.<subdomain>.workers.dev/queue
```

That runs the same pass the schedule runs and reports every debtor with the
message they would get and, where one is held back, the rule holding it. It
writes nothing.

## Sending

With no WhatsApp credentials the sender rehearses: it works out exactly what
would go out, writes it to `attempts` with outcome `rehearsed`, and sends
nothing. A half-configured sender that silently drops reminders is worse than
one that says it did nothing.

## Routes

| Route            | Who calls it  | What it does                                  |
|------------------|---------------|-----------------------------------------------|
| cron `0 8 * * *` | Cloudflare    | One pass: decide, send or rehearse, record it  |
| `GET /queue`     | you           | The same pass, reported, writing nothing       |
| `POST /inbound`  | the provider  | A reply of STOP; honoured permanently          |

`/inbound` is deliberately unauthenticated: the worst a forged call can do is
stop somebody's reminders, which is the safe direction to fail in.

## Tests

```bash
node --experimental-strip-types --test test/firestore.test.ts
node --experimental-strip-types --test ../../firebase/functions/test/policy.test.ts
```
