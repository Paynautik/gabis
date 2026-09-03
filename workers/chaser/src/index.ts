import { accessToken } from './google';
import { Firestore, decode, uidOf } from './firestore';
import {
  decide,
  daysOverdue,
  type Attempt,
  type Debtor,
} from '../../../firebase/functions/src/policy';
import {
  chaseMessage,
  isOptOut,
  optOutLine,
} from '../../../firebase/functions/src/message';
import { send } from './send';

/**
 * The rail that makes reminders autonomous, on a schedule that costs nothing.
 *
 * The queue lives in Firestore, written by the app through the account the
 * user already signs into — that has not changed and is the point. What moved
 * is the clock: scheduled Cloud Functions need the project on Blaze, while
 * Firestore itself does not, so the schedule runs on Cloudflare, where gabis
 * already hosts its site and where cron triggers are free.
 *
 * The rules in policy.ts are shared with firebase/functions rather than
 * copied, so the day this does move to a Cloud Function there is one set of
 * rules to move, not two that have drifted.
 */

export interface Env {
  GOOGLE_SA_EMAIL: string;
  GOOGLE_SA_PRIVATE_KEY: string;
  FIREBASE_PROJECT: string;
  FIRESTORE_DB?: string;
  WHATSAPP_TOKEN?: string;
  WHATSAPP_PHONE_ID?: string;
}

interface Queue {
  autonomous?: boolean;
  business?: string;
  debtors?: Debtor[];
}

/** Says which secret is missing rather than throwing an opaque 1101. */
function missingSecret(env: Env): string | null {
  if (!env.GOOGLE_SA_EMAIL) return 'GOOGLE_SA_EMAIL';
  if (!env.GOOGLE_SA_PRIVATE_KEY) return 'GOOGLE_SA_PRIVATE_KEY';
  return null;
}

async function connect(env: Env): Promise<Firestore> {
  const token = await accessToken({
    email: env.GOOGLE_SA_EMAIL,
    privateKey: env.GOOGLE_SA_PRIVATE_KEY.replace(/\\n/g, '\n'),
  });
  return new Firestore(token, env.FIREBASE_PROJECT, env.FIRESTORE_DB ?? '(default)');
}

/** Every account that turned reminders on. */
async function queues(db: Firestore) {
  const documents = await db.query('', {
    from: [{ collectionId: 'gabis', allDescendants: true }],
    where: {
      fieldFilter: {
        field: { fieldPath: 'autonomous' },
        op: 'EQUAL',
        value: { booleanValue: true },
      },
    },
  });

  return documents
    .filter((doc) => doc.name.endsWith('/gabis/collections'))
    .map((doc) => ({
      uid: uidOf(doc.name),
      queue: decode(doc.fields) as Queue,
    }))
    .filter((row): row is { uid: string; queue: Queue } => row.uid !== null);
}

async function priorAttempts(
  db: Firestore,
  uid: string,
  name: string,
): Promise<Attempt[]> {
  const documents = await db.query(`/users/${uid}/gabis/collections`, {
    from: [{ collectionId: 'attempts' }],
    where: {
      fieldFilter: {
        field: { fieldPath: 'debtor_name' },
        op: 'EQUAL',
        value: { stringValue: name },
      },
    },
    orderBy: [{ field: { fieldPath: 'placed_at' }, direction: 'ASCENDING' }],
  });

  return documents.map((doc) => decode(doc.fields) as Attempt);
}

/** What would go out for one account, and what is holding each one back. */
export async function planFor(
  db: Firestore,
  uid: string,
  queue: Queue,
  now: Date,
) {
  const company = queue.business ?? 'your supplier';
  const plan: {
    debtor: Debtor;
    attempt: number;
    message: string;
    allowed: boolean;
    reason?: string;
  }[] = [];

  for (const debtor of queue.debtors ?? []) {
    const decision = decide(
      debtor,
      await priorAttempts(db, uid, debtor.name),
      now,
    );

    plan.push({
      debtor,
      attempt: decision.attempt,
      allowed: decision.allowed,
      reason: decision.reason,
      message:
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
        optOutLine(company),
    });
  }

  return plan;
}

async function runOnce(env: Env, now: Date) {
  const db = await connect(env);
  let sent = 0;
  let held = 0;

  for (const { uid, queue } of await queues(db)) {
    for (const item of await planFor(db, uid, queue, now)) {
      if (!item.allowed) {
        held++;
        continue;
      }

      const outcome = await send(item.debtor.phone, item.message, {
        token: env.WHATSAPP_TOKEN,
        phoneId: env.WHATSAPP_PHONE_ID,
      });
      if (outcome === 'failed') {
        held++;
        continue;
      }

      // Written down whether it went out or was only rehearsed, because this
      // log is what the frequency limits are counted from.
      await db.createDocument(`users/${uid}/gabis/collections/attempts`, {
        debtor_name: item.debtor.name,
        placed_at: now.toISOString(),
        attempt: item.attempt,
        channel: 'whatsapp',
        outcome: outcome === 'sent' ? 'link_sent' : 'rehearsed',
        message: item.message,
      });
      sent++;
    }
  }

  return { sent, held };
}

export default {
  /** Mid-morning in Lagos. The hours rule in policy.ts holds the line anyway. */
  async scheduled(_event: ScheduledController, env: Env): Promise<void> {
    const missing = missingSecret(env);
    if (missing) {
      console.error(`chaser not configured: ${missing} is not set; nothing sent`);
      return;
    }

    const result = await runOnce(env, new Date());
    console.log('chaser pass complete', result);
  },

  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);

    const missing = missingSecret(env);
    if (missing) {
      return Response.json(
        {
          error: 'not_configured',
          detail: `${missing} is not set. See workers/chaser/README.md — without it the schedule runs and does nothing.`,
        },
        { status: 503 },
      );
    }

    // A reply of STOP is a refusal, honoured permanently. Unauthenticated on
    // purpose: it is the provider's webhook, and the worst a forged call can
    // do is stop somebody's reminders, which is the safe direction to fail in.
    if (url.pathname === '/inbound' && request.method === 'POST') {
      const body = (await request.json().catch(() => null)) as {
        from?: string;
        text?: string;
      } | null;
      if (!body?.from || !body.text) {
        return Response.json({ error: 'bad_request' }, { status: 400 });
      }
      if (!isOptOut(body.text)) return Response.json({ ok: true, acted: false });

      const db = await connect(env);
      const tail = body.from.replace(/[^0-9]/g, '').slice(-10);
      let acted = false;

      for (const { uid, queue } of await queues(db)) {
        const debtors = queue.debtors ?? [];
        let touched = false;
        const updated = debtors.map((d) => {
          if (!d.phone?.replace(/[^0-9]/g, '').endsWith(tail)) return d;
          touched = true;
          return { ...d, do_not_contact: 1 };
        });

        if (touched) {
          await db.patch(`users/${uid}/gabis/collections`, { debtors: updated });
          acted = true;
        }
      }

      return Response.json({ ok: true, acted });
    }

    // The pass the schedule makes, on demand, for seeing what it would do.
    // Dry by default: it reports and writes nothing unless asked to run.
    if (url.pathname === '/queue' && request.method === 'GET') {
      const db = await connect(env);
      const now = new Date();
      const out = [];

      for (const { uid, queue } of await queues(db)) {
        for (const item of await planFor(db, uid, queue, now)) {
          out.push({
            name: item.debtor.name,
            outstanding: item.debtor.outstanding,
            attempt: item.attempt,
            allowed: item.allowed,
            reason: item.reason,
            message: item.message,
          });
        }
      }

      return Response.json({ now: now.toISOString(), items: out });
    }

    return Response.json({ error: 'not_found' }, { status: 404 });
  },
};
