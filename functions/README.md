# Pages Functions

## Bill payments: `/api/bills/*`

Airtime, data, electricity and cable TV are bought through
[VTpass](https://vtpass.com/documentation/). The app never holds the keys: it
asks these functions, and they ask VTpass.

| Route | Does |
|---|---|
| `GET /api/bills/config` | Whether bills are switched on (`enabled`, `mode`). Public. |
| `GET /api/bills/variations?serviceID=mtn-data` | Data plans or TV bouquets with prices. |
| `POST /api/bills/verify` | Whose meter or smartcard this is. |
| `POST /api/bills/pay` | Buys. One `requestId` per payment, reused on every retry. |
| `POST /api/bills/status` | Looks a payment up again by `requestId`. |

Everything but `config` needs a signed-in user: the Firebase ID token is
checked here (`_shared/firebase-auth.ts`), not trusted from the app.

### Set it up

1. Create a VTpass **sandbox** account at https://sandbox.vtpass.com and copy
   the API key, public key and secret key from its profile, API Keys tab.
2. In Cloudflare: Workers & Pages, the project, Settings, Variables and
   Secrets. Add these as **encrypted** variables:
   `VTPASS_API_KEY`, `VTPASS_PUBLIC_KEY`, `VTPASS_SECRET_KEY`.
3. Redeploy. The app switches from example payments to the sandbox.
   `BILLS_MODE` stays unset (sandbox: no money moves).

Sandbox test numbers: meter `1111111111111` (prepaid, succeeds), `201000000000`
(pending), anything else fails. See the VTpass docs for more scenarios.

### Going live is not just a setting

`BILLS_MODE=live` spends real money from your VTpass wallet. Balances in the
app are kept by the app itself, so anyone signed in could call `/pay` without
having the money. Do not set `live` until balances are held and checked on a
server. The endpoints already cap one payment (`LIMITS` in
`_shared/vtpass.ts`), and Cloudflare rate limiting on `/api/bills/pay` should
be added as well.

### Tests

`npm test` runs the function tests with a fake VTpass (Node 22+).
