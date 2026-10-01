# Partner integrations

gabis does not hold customer money itself. Four capabilities depend on a
licensed partner. Each one sits behind a single interface in
`lib/features/partners/partner_rails.dart`, and every screen talks only to
that interface.

Today every rail runs in **sandbox** (`partnerModeProvider`). The flows, state
and history are real and saved, but no money moves and the UI labels each
result as a sandbox result. Going live for one partner means:

1. Write a class that implements the interface below.
2. Return it from the matching provider when the mode is `live`.
3. Remove the sandbox banner for that screen once real money flows.

No screen needs to change.

## 1. Stablecoin rail (USDC): `StablecoinRail`

Used by **Global money → USDC wallet** and the **FX agent**.

| Method | The partner must provide |
|---|---|
| `depositAddress(userId)` | A per-user USDC deposit address or virtual USD account that settles to USDC |
| `quote(usdcCents, currency)` | A firm off-ramp quote into NGN, KES, GHS, UGX, TZS, SSP or LRD, held for 30 seconds |
| `convert(quote)` | Executes the quote and pays out to the user's local account |

The partner also needs a **deposit webhook** that credits the wallet. It
replaces `UsdcWalletNotifier.simulateIncoming`, which exists only in sandbox.

What to look for: a licensed stablecoin issuer or on/off-ramp covering the
seven corridors, plus the licensing gabis needs to offer it in each country.

## 2. Escrow custody: `EscrowCustodian` (ORPay)

Used by **Community & Trust → Escrow**.

The partner's API key can open an escrow and cancel it before funding, and
nothing more. Once funded, the buyer, seller or arbiter signs each step in
ORPay with their own wallet, so a stolen gabis key cannot empty an escrow.

| Method | What it does |
|---|---|
| `open(...)` | Creates the ORPay escrow request; returns the buyer's funding link |
| `cancel(id)` | Withdraws a request the buyer has not funded (`orpay.cancelEscrow`) |
| `stepUrl(id, step)` | Link for this user to sign release, refund, dispute, dispatch or claim (`orpay.escrowActionUrl`) |

State after funding arrives only by ORPay webhook.

**Built:** `OpenReserveEscrowCustodian` in the app, and in
`firebase/functions/src/escrow.ts` the functions `createEscrow`,
`cancelEscrow`, `escrowAction` (checks the caller's role) and `orpayWebhook`
(verifies the signature, updates `escrows/{id}`).

**To go live:**
1. Bundle `@openreserve/orpay` inside `firebase/functions` (it is currently
   linked from outside the folder, which a Firebase deploy does not upload).
2. Set secrets `ORPAY_API_KEY`, `ORPAY_WEBHOOK_SECRET`, `ORPAY_URL`.
3. Deploy the functions and register the `orpayWebhook` URL in ORPay → Developers.
4. Listen to `escrows/{id}` in the app and call `applyPartnerStatus`, then
   switch `escrowCustodianProvider` to the ORPay custodian in live mode.

### Ajo contributions: `AjoCollector` (ORPay)

Used by **Community & Trust → Ajo**. Sandbox keeps "Mark paid" only. Live, the
organiser also sees **Collect** per member, which opens an ORPay checkout.

**Built:** `OpenReserveAjoCollector` in the app, and in
`firebase/functions/src/ajo.ts` the functions `createAjo` (saves the circle
under the app's id, so a retry cannot duplicate it) and `ajoContribute` (one
checkout per member and round, organiser only). Each checkout's reference is
`ajo:<circleId>:<round>:<member>`; the existing `orpayWebhook` records
`invoice.paid` for it in `ajos/{id}/payments/{round}_{member}`.

**To go live:** same secrets and webhook as escrow (step 2 and 3 above), make
sure the webhook sends `invoice.paid`, then listen to `ajos/{id}/payments` in
the app and call `markPaid` for each new document, and switch
`ajoCollectorProvider` to the ORPay collector in live mode.

## 3. Tax remittance: `TaxRemitter`

Used by **Business → Tax · 7 corridors**.

| Method | The partner must provide |
|---|---|
| `remit(authority, taxType, amount, currency, period)` | Files and pays VAT, GST or sales tax to FIRS, KRA, GRA, URA, TRA, NRA or LRA, and returns the authority's receipt reference |

**Rates need confirming.** `lib/features/business/tax_rules.dart` marks
Uganda, Tanzania, South Sudan and Liberia with `needsConfirmation: true`. Their
rates were entered from general knowledge, not from each authority's current
schedule. Have a tax adviser check them, then set the flag to `false`; the
in-app warning disappears with it.

## 4. Exchange rates: `FxRateFeed`

Used by the **FX agent** and USDC quotes.

| Method | The partner must provide |
|---|---|
| `rate(base, quote)` | A live interbank rate for USD against the seven corridor currencies |

The sandbox rates in `sandboxReferenceRates` are round reference figures, not
market data, and the app says so wherever they appear.

## Built and working now (no partner needed)

These run on the user's own data, stored on the device:
- **Future Mode**: 30-day balance forecast, safe-to-spend today, what-if slider
- **Goals**: plain-language goals ("Save ₦2M by December") with a monthly plan
- **Autopilot**: income waterfall; proposes a split when salary lands and needs approval
- **Financial Firewall**: pauses unusual payments and explains why; the person decides
- **Friday Roast**: weekly spending roast from real figures, with a polite mode
- **Agent network**: live status for each of the five agents
- **Ajo circles**: rotation, contributions, payouts on approval
- **Refund windows**: 7/14/30-day countdowns with a 24-hour warning
- **Withholding tax**: per-invoice WHT across all seven corridors

Still to do: the Friday Roast and refund warnings show inside the app, but
push notifications at 6 PM Friday and 24 hours before a refund window closes
need a scheduled Cloud Function.
