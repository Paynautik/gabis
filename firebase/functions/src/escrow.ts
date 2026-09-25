import { onCall, HttpsError } from 'firebase-functions/v2/https';
import * as admin from 'firebase-admin';
import { orpay } from './openreserve';

if (!admin.apps.length) admin.initializeApp();

export const createEscrow = onCall(async (request) => {
  const { data, auth } = request;
  if (!auth) throw new HttpsError('unauthenticated', 'User must be logged in.');

  const { itemName, amount, counterpartyId } = data as any;
  
  // Create Escrow using OpenReserve SDK
  const escrowReq = await orpay.createEscrow({
    seller: counterpartyId,
    description: itemName,
    currency: 'NGN',
    milestones: [{ label: 'Full Payment', amount: amount.toString() }]
  });

  // Save to Firestore
  await admin.firestore().collection('escrows').doc(escrowReq.id).set({
    itemName,
    amount,
    sellerId: counterpartyId,
    buyerId: auth.uid,
    status: escrowReq.status,
    openreserveId: escrowReq.id,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { success: true, escrowId: escrowReq.id, fundingUrl: escrowReq.funding_url };
});
