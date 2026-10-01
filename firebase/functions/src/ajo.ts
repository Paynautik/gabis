import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { getFirestore, FieldValue } from 'firebase-admin/firestore';

import { orpay } from './openreserve';
import { ajoReference, parseAjoReference } from './ajo-ref';

/**
 * Saving circles (Ajo) through ORPay.
 *
 * gabis keeps the circle; ORPay collects each member's contribution as a
 * checkout. The reference on every checkout is `ajo:<circleId>:<round>:<member>`
 * so the webhook can tell which contribution was paid without a second
 * lookup, and a redelivered webhook writes the same payment document twice.
 *
 * Firestore: ajos/{id} is the circle; ajos/{id}/payments/{round}_{member} is
 * one paid contribution, written only by the ORPay webhook.
 */
const db = () => getFirestore(process.env.FIRESTORE_DB ?? '(default)');
const SECRETS = ['ORPAY_API_KEY'];

/** Creates the circle record. The app picks the id so a retry cannot duplicate it. */
export const createAjo = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError('unauthenticated', 'Sign in first.');

  const { id, name, members, contribution, frequency } = (request.data ?? {}) as {
    id?: string;
    name?: string;
    members?: string[];
    contribution?: number;
    frequency?: string;
  };
  const names = (members ?? []).map((m) => String(m).trim()).filter(Boolean);
  if (!name || !contribution || contribution <= 0 || names.length < 2) {
    throw new HttpsError('invalid-argument', 'A name, a positive contribution and at least two members are required.');
  }
  if (!/^[A-Za-z0-9]{1,40}$/.test(id ?? '')) {
    throw new HttpsError('invalid-argument', 'A circle id is required.');
  }

  const ref = db().collection('ajos').doc(id!);
  const existing = await ref.get();
  if (existing.exists) {
    if (existing.data()!.creator !== uid) throw new HttpsError('permission-denied', 'This circle is not yours.');
    return { ajoId: ref.id };
  }
  await ref.set({
    name,
    contribution,
    frequency: frequency === 'weekly' ? 'weekly' : 'monthly',
    members: names,
    creator: uid,
    status: 'active',
    createdAt: FieldValue.serverTimestamp(),
  });
  return { ajoId: ref.id };
});

/** A checkout for one member's contribution to one round. Only the organiser may ask. */
export const ajoContribute = onCall({ secrets: SECRETS }, async (request) => {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError('unauthenticated', 'Sign in first.');

  const { id, round, member } = (request.data ?? {}) as { id?: string; round?: number; member?: number };
  const snap = await db().collection('ajos').doc(String(id ?? '')).get();
  if (!snap.exists) throw new HttpsError('not-found', 'No such circle.');
  const c = snap.data()!;
  if (c.creator !== uid) throw new HttpsError('permission-denied', 'Only the organiser can collect for this circle.');

  const names = c.members as string[];
  if (!Number.isInteger(round) || round! < 0 || round! >= names.length) {
    throw new HttpsError('invalid-argument', 'Unknown round.');
  }
  if (!Number.isInteger(member) || member! < 0 || member! >= names.length) {
    throw new HttpsError('invalid-argument', 'Unknown member.');
  }
  const done = await snap.ref.collection('payments').doc(`${round}_${member}`).get();
  if (done.exists) throw new HttpsError('already-exists', `${names[member!]} has already paid this round.`);

  const checkout = await (await orpay()).createCheckout({
    amount: (c.contribution as number).toFixed(2),
    description: `Ajo contribution: ${c.name}, round ${round! + 1}, ${names[member!]}`,
    reference: ajoReference(snap.id, round!, member!),
  });
  return { checkoutUrl: checkout.checkout_url };
});

/** Records a paid contribution. Called by the ORPay webhook on `invoice.paid`. */
export async function recordAjoPayment(reference: unknown, paidAt?: unknown) {
  const p = parseAjoReference(reference);
  if (!p) return false;
  const circle = db().collection('ajos').doc(p.circleId);
  if (!(await circle.get()).exists) return false;
  await circle.collection('payments').doc(`${p.round}_${p.member}`).set(
    { round: p.round, member: p.member, paidAt: paidAt ?? null, recordedAt: FieldValue.serverTimestamp() },
    { merge: true },
  );
  return true;
}
