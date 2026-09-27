import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { getFirestore, FieldValue } from 'firebase-admin/firestore';

import { orpay } from './openreserve';

const db = () => getFirestore(process.env.FIRESTORE_DB ?? '(default)');

/** A checkout for one member's Ajo contribution, paid in ORPay. */
export const createAjo = onCall({ secrets: ['ORPAY_API_KEY'] }, async (request) => {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError('unauthenticated', 'Sign in first.');

  const { circleName, contribution, frequency } = (request.data ?? {}) as {
    circleName?: string;
    contribution?: number;
    frequency?: string;
  };
  if (!circleName || !contribution || contribution <= 0) {
    throw new HttpsError('invalid-argument', 'Circle name and a positive contribution are required.');
  }

  const ref = db().collection('ajos').doc();
  const checkout = await (await orpay()).createCheckout({
    amount: contribution.toFixed(2),
    description: `Ajo contribution: ${circleName}`,
    reference: ref.id,
  });

  await ref.set({
    name: circleName,
    contribution,
    frequency: frequency ?? 'monthly',
    members: [uid],
    creator: uid,
    status: 'active',
    createdAt: FieldValue.serverTimestamp(),
  });

  return { ajoId: ref.id, checkoutUrl: checkout.checkout_url };
});
