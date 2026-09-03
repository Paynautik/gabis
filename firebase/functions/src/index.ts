import { getFirestore, FieldValue } from 'firebase-admin/firestore';
import { initializeApp } from 'firebase-admin/app';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import { onRequest } from 'firebase-functions/v2/https';
import { logger } from 'firebase-functions';

import { decide, daysOverdue, type Attempt, type Debtor } from './policy';
import { chaseMessage, isOptOut, optOutLine } from './message';
import { send } from './send';

/**
 * The rail that makes reminders autonomous.
 *
 * Everything before this needed somebody to be holding the phone. A scheduled
 * function does not get tired at the third reminder or soft at the first,
 * which is exactly why the rules live in policy.ts and are checked here again
 * rather than trusted from whatever the app last wrote.
 *
 * It reads the queue the app already syncs to Firestore under the user's own
 * document, so there is no second copy of the ledger, no service token to
 * hand out, and no separate notion of who a business is: Firebase Auth
 * already answered that.
 */

initializeApp();
const db = getFirestore();

/** users/{uid}/gabis/collections — written by the app, read by this. */
interface Queue {
  autonomous?: boolean;
  business?: string;
  debtors?: Debtor[];
}

function attemptsOf(uid: string) {
  return db
    .collection('users')
    .doc(uid)
    .collection('gabis')
    .doc('collections')
    .collection('attempts');
}

/** What would go out for one business, and what would hold it back. */
export async function queueFor(uid: string, queue: Queue, now: Date) {
  const company = queue.business ?? 'your supplier';
  const out: {
    debtor: Debtor;
    attempt: number;
    message: string;
    allowed: boolean;
    reason?: string;
  }[] = [];

  for (const debtor of queue.debtors ?? []) {
    const prior = await attemptsOf(uid)
      .where('debtor_name', '==', debtor.name)
      .orderBy('placed_at')
      .get();

    const decision = decide(
      debtor,
      prior.docs.map((d) => d.data() as Attempt),
      now,
    );

    const message =
      chaseMessage({
        name: debtor.name,
        company,
        outstanding: debtor.outstanding,
        currency: debtor.currency,
        daysOverdue: daysOverdue(debtor.due_on, now),
        attempt: decision.attempt,
        payLink: debtor.portal_link,
      }) +
      '\n\n' +
      optOutLine(company);

    out.push({
      debtor,
      attempt: decision.attempt,
      message,
      allowed: decision.allowed,
      reason: decision.reason,
    });
  }

  return out;
}

async function runOnce(now: Date) {
  // Only the businesses that turned it on. A user who never asked for this is
  // never in this query.
  const queues = await db
    .collectionGroup('gabis')
    .where('autonomous', '==', true)
    .get();

  let sent = 0;
  let held = 0;

  for (const doc of queues.docs) {
    if (doc.id !== 'collections') continue;
    const uid = doc.ref.parent.parent?.id;
    if (!uid) continue;

    for (const item of await queueFor(uid, doc.data() as Queue, now)) {
      if (!item.allowed) {
        held++;
        continue;
      }

      const outcome = await send(item.debtor.phone, item.message);
      if (outcome === 'failed') {
        held++;
        continue;
      }

      // Written down whether it went out or was rehearsed, because the record
      // is what the frequency limits are counted from.
      await attemptsOf(uid).add({
        debtor_name: item.debtor.name,
        placed_at: now.toISOString(),
        attempt: item.attempt,
        channel: 'whatsapp',
        outcome: outcome === 'sent' ? 'link_sent' : 'rehearsed',
        message: item.message,
        created_at: FieldValue.serverTimestamp(),
      });
      sent++;
    }
  }

  logger.info('chaser pass complete', { sent, held });
  return { sent, held };
}

/** Mid-morning in Lagos. The hours rule in policy.ts holds the line anyway. */
export const chaser = onSchedule(
  { schedule: '0 9 * * *', timeZone: 'Africa/Lagos', secrets: ['WHATSAPP_TOKEN', 'WHATSAPP_PHONE_ID'] },
  async () => {
    await runOnce(new Date());
  },
);

/**
 * A reply of STOP is a refusal, and refusals are honoured permanently.
 *
 * Unauthenticated on purpose: it is the provider's webhook, and the worst a
 * forged call can do is stop somebody's reminders, which is the safe
 * direction to fail in.
 */
export const inbound = onRequest(async (request, response) => {
  const from = String(request.body?.from ?? '');
  const text = String(request.body?.text ?? '');
  if (!from || !text) {
    response.status(400).json({ error: 'bad_request' });
    return;
  }
  if (!isOptOut(text)) {
    response.json({ ok: true, acted: false });
    return;
  }

  const tail = from.replace(/[^0-9]/g, '').slice(-10);
  const queues = await db.collectionGroup('gabis').get();
  let acted = 0;

  for (const doc of queues.docs) {
    if (doc.id !== 'collections') continue;
    const queue = doc.data() as Queue;
    const debtors = queue.debtors ?? [];
    let touched = false;

    const updated = debtors.map((d) => {
      if (!d.phone?.replace(/[^0-9]/g, '').endsWith(tail)) return d;
      touched = true;
      return { ...d, do_not_contact: 1 };
    });

    if (touched) {
      await doc.ref.update({ debtors: updated });
      acted++;
    }
  }

  response.json({ ok: true, acted: acted > 0 });
});
