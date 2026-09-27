import { onCall, onRequest, HttpsError } from 'firebase-functions/v2/https';
import { getFirestore, FieldValue } from 'firebase-admin/firestore';
import { logger } from 'firebase-functions';

import { orpay, verifyOrpayWebhook } from './openreserve';

/**
 * Escrow through ORPay.
 *
 * gabis creates the escrow request and, until the buyer funds it, may cancel
 * it. After funding, gabis cannot move the money: it hands the right person a
 * link to sign the step in ORPay, and learns the outcome from the webhook.
 *
 * Firestore: escrows/{id} holds the order as gabis sees it; the app listens
 * to the docs where the user is buyer or seller.
 */
const db = () => getFirestore(process.env.FIRESTORE_DB ?? '(default)');
const SECRETS = ['ORPAY_API_KEY'];

type Role = 'buyer' | 'seller';

/** Who may sign each step. Mirrors the ORPay SDK README. */
const SIGNERS: Record<string, Role[]> = {
  release: ['buyer'],
  refund: ['seller', 'buyer'], // buyer only after the ship-by date; ORPay enforces the date
  dispute: ['buyer', 'seller'],
  dispatch: ['seller'],
  claim: ['seller'],
};

export const createEscrow = onCall({ secrets: SECRETS }, async (request) => {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError('unauthenticated', 'Sign in first.');

  const { itemName, amount, seller, sellerUid, shipByDays } = (request.data ?? {}) as {
    itemName?: string;
    amount?: number;
    seller?: string; // ORPay username or address of whoever gets paid
    sellerUid?: string; // their gabis account, if they have one
    shipByDays?: number;
  };
  if (!itemName || !seller || !amount || amount <= 0) {
    throw new HttpsError('invalid-argument', 'Item, seller and a positive amount are required.');
  }

  const ref = db().collection('escrows').doc();
  const client = await orpay();
  const e = await client.createEscrow({
    seller,
    currency: 'NGN',
    description: itemName,
    reference: ref.id,
    milestones: [{ label: 'Full payment', amount: amount.toFixed(2) }],
    shipByDays: shipByDays ?? 14,
    returnUrl: `https://gabis.pages.dev/home?escrow=${ref.id}`,
  });

  await ref.set({
    itemName,
    amount,
    buyerUid: uid,
    sellerUid: sellerUid ?? null,
    seller,
    orpayId: e.id,
    status: e.status,
    fundingUrl: e.funding_url,
    escrowUrl: e.escrow_url ?? null,
    createdAt: FieldValue.serverTimestamp(),
  });

  return { id: ref.id, orpayId: e.id, fundingUrl: e.funding_url };
});

async function escrowFor(uid: string, id: string) {
  const snap = await db().collection('escrows').doc(id).get();
  if (!snap.exists) throw new HttpsError('not-found', 'No such escrow.');
  const d = snap.data()!;
  const role: Role | null = d.buyerUid === uid ? 'buyer' : d.sellerUid === uid ? 'seller' : null;
  if (!role) throw new HttpsError('permission-denied', 'This escrow is not yours.');
  return { ref: snap.ref, d, role };
}

/** Withdraw a request the buyer has not funded. ORPay refuses once funded. */
export const cancelEscrow = onCall({ secrets: SECRETS }, async (request) => {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError('unauthenticated', 'Sign in first.');
  const { ref, d, role } = await escrowFor(uid, String(request.data?.id ?? ''));
  if (role !== 'buyer') throw new HttpsError('permission-denied', 'Only the buyer can cancel before funding.');

  try {
    const e = await (await orpay()).cancelEscrow(d.orpayId);
    await ref.update({ status: e.status, updatedAt: FieldValue.serverTimestamp() });
    return { status: e.status };
  } catch (err) {
    // ORPay says why (for example, already funded); pass it through as-is.
    throw new HttpsError('failed-precondition', (err as Error).message);
  }
});

/**
 * A link for the caller to sign one step in ORPay. gabis checks the caller
 * may ask; ORPay checks the signature and its own rules (dates, state).
 */
export const escrowAction = onCall({ secrets: SECRETS }, async (request) => {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError('unauthenticated', 'Sign in first.');
  const action = String(request.data?.action ?? '');
  const allowed = SIGNERS[action];
  if (!allowed) throw new HttpsError('invalid-argument', `Unknown action "${action}".`);

  const { d, role } = await escrowFor(uid, String(request.data?.id ?? ''));
  if (!allowed.includes(role)) {
    throw new HttpsError('permission-denied', `The ${role} cannot ${action} this escrow.`);
  }

  const client = await orpay();
  const e = d.escrowUrl ? { escrow_url: d.escrowUrl as string } : await client.getEscrow(d.orpayId);
  if (!e.escrow_url) throw new HttpsError('failed-precondition', 'The buyer has not funded this escrow yet.');
  return { url: client.escrowActionUrl(e, action as Parameters<typeof client.escrowActionUrl>[1]) };
});

/**
 * ORPay → gabis. Verified with the webhook secret, keyed on the escrow so a
 * retried delivery writes the same thing twice, and the only way an escrow's
 * state changes after funding.
 */
export const orpayWebhook = onRequest({ secrets: ['ORPAY_WEBHOOK_SECRET'] }, async (req, res) => {
  let event;
  try {
    event = await verifyOrpayWebhook(req.rawBody.toString('utf8'), String(req.get('ORPay-Signature') ?? ''));
  } catch {
    res.status(400).send('bad signature');
    return;
  }

  if (event.type.startsWith('escrow.')) {
    const e = event.data as { reference?: string; status: string; escrow_url?: string; escrow?: { status: string } };
    if (e.reference) {
      await db().collection('escrows').doc(e.reference).set(
        {
          status: e.escrow?.status ?? e.status,
          escrowUrl: e.escrow_url ?? null,
          lastEvent: event.type,
          lastEventAt: event.created,
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
    }
  }
  logger.info('orpay webhook', { type: event.type });
  res.send('ok');
});
