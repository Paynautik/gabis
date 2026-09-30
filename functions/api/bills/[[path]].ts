import { handleBills } from "../../_shared/bills.ts";
import { verifyFirebaseToken } from "../../_shared/firebase-auth.ts";
import type { Env } from "../../_shared/vtpass.ts";

/**
 * Bill payments: /api/bills/config | variations | verify | pay | status.
 *
 * Set VTPASS_API_KEY, VTPASS_PUBLIC_KEY and VTPASS_SECRET_KEY as encrypted
 * variables on the Pages project. Until they are set every endpoint but
 * `config` answers 503 and the app says bill payments are not connected.
 *
 * BILLS_MODE stays unset (the VTpass sandbox, which moves no money) until
 * balances are kept on a server. Today the app holds them itself, which is
 * fine for a sandbox and not for real money.
 */
export const onRequest: PagesFunction<Env> = ({ request, env }) =>
  handleBills(request, env, {
    fetch,
    now: () => Date.now(),
    verify: (authorization) =>
      verifyFirebaseToken(authorization, env.FIREBASE_PROJECT_ID ?? "gabis-pay-app"),
  });
