import { onCall, HttpsError } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import { orpay } from './openreserve';

export const createAjo = onCall(async (request) => {
  const { data, auth } = request;
  if (!auth) throw new HttpsError('unauthenticated', 'User must be logged in.');

  const { circleName, contribution, frequency } = data as any;

  // Create Checkout using OpenReserve SDK for initial contribution
  const checkout = await orpay.createCheckout({
    amount: contribution.toString(),
    description: `Ajo Contribution: ${circleName}`,
  });

  // Save to Firestore
  const docRef = admin.firestore().collection('ajos').doc();
  await docRef.set({
    name: circleName,
    contribution,
    frequency,
    members: [auth.uid],
    creator: auth.uid,
    status: 'active',
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { success: true, ajoId: docRef.id, checkoutUrl: checkout.checkout_url };
});
