import { accessToken } from './google';
import { Firestore, decode, uidOf } from './firestore';
import {
  decide,
  daysOverdue,
  type Attempt,
  type Debtor,
} from '../../../firebase/functions/src/policy';
import { isOptOut } from '../../../firebase/functions/src/message';
import { send } from './send';
import { render, templateFor, type TemplateMessage } from './template';
import { uidFromIdToken } from './auth';
import { Paystack, claim } from './payments';

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
  PAYSTACK_SECRET?: string;
}

interface Queue {
  autonomous?: boolean;
  business?: string;
  debtors?: Debtor[];
}

/** The site is the only thing that asks, and only for /status. */
const cors = {
  'access-control-allow-origin': 'https://gabis.pages.dev',
  'access-control-allow-methods': 'GET, POST, OPTIONS',
  'access-control-allow-headers': 'authorization, content-type',
};

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
    template: TemplateMessage;
    allowed: boolean;
    reason?: string;
  }[] = [];

  for (const debtor of queue.debtors ?? []) {
    const decision = decide(
      debtor,
      await priorAttempts(db, uid, debtor.name),
      now,
    );

    // The words are the template's, filled in for this debtor. Rendering them
    // here means the queue and the attempts log show exactly what the customer
    // reads, rather than a placeholder body nobody can check.
    const template = templateFor({
      name: debtor.name,
      company,
      outstanding: debtor.outstanding,
      currency: debtor.currency,
      daysOverdue: daysOverdue(debtor.due_on, now),
      attempt: decision.attempt,
      payLink: debtor.portal_link,
    });

    plan.push({
      debtor,
      attempt: decision.attempt,
      allowed: decision.allowed,
      reason: decision.reason,
      template,
      message: render(template),
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

      const outcome = await send(item.debtor.phone, item.template, {
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

    if (request.method === 'OPTIONS') {
      return new Response(null, { status: 204, headers: cors });
    }

    // The app asks this before it offers to turn reminders on, so a switch is
    // never presented as armed when the rail behind it cannot send anything.
    // Readable by the site, and it says nothing a stranger could use.
    if (url.pathname === '/status') {
      return Response.json(
        {
          ok: true,
          configured: missingSecret(env) === null,
          sends: Boolean(env.WHATSAPP_TOKEN && env.WHATSAPP_PHONE_ID),
          accounts: Boolean(env.PAYSTACK_SECRET),
          schedule: '08:00 UTC daily',
        },
        { headers: cors },
      );
    }

    // Whether the credentials actually work, which /status cannot say: it only
    // knows the strings exist. A token that is expired, revoked, pasted twice
    // or scoped to the wrong account looks identical to a good one from here,
    // and the difference only shows up as reminders silently not arriving.
    //
    // Asks WhatsApp about the sending number and nothing else. Sends no
    // message, needs no debtor, and reports what Meta said rather than a
    // verdict of our own.
    if (url.pathname === '/check' && request.method === 'GET') {
      if (!env.WHATSAPP_TOKEN || !env.WHATSAPP_PHONE_ID) {
        return Response.json(
          { sends: false, detail: 'WhatsApp credentials are not set.' },
          { headers: cors },
        );
      }

      try {
        const response = await fetch(
          `https://graph.facebook.com/v21.0/${env.WHATSAPP_PHONE_ID}` +
            '?fields=display_phone_number,verified_name,quality_rating',
          { headers: { authorization: `Bearer ${env.WHATSAPP_TOKEN}` } },
        );
        const body = (await response.json()) as {
          display_phone_number?: string;
          verified_name?: string;
          quality_rating?: string;
          error?: { message?: string; code?: number };
        };

        if (!response.ok) {
          return Response.json(
            {
              sends: false,
              // Meta's own words. Code 190 is a token expired, revoked or
              // malformed; 100 is usually a token with no rights over this
              // number.
              detail: body.error?.message ?? `HTTP ${response.status}`,
              code: body.error?.code,
            },
            { headers: cors },
          );
        }

        const accounts = await new Paystack(env.PAYSTACK_SECRET).check();

        return Response.json(
          {
            sends: true,
            number: body.display_phone_number,
            name: body.verified_name,
            quality: body.quality_rating,
            // Whether invoices will really get their own account number, which
            // is a different question from whether a key is set.
            mints: accounts.ok,
            mintsDetail: accounts.detail,
            banks: accounts.banks,
          },
          { headers: cors },
        );
      } catch (error) {
        return Response.json(
          { sends: false, detail: String(error) },
          { headers: cors },
        );
      }
    }

    const missing = missingSecret(env);
    if (missing) {
      return Response.json(
        {
          error: 'not_configured',
          detail: `${missing} is not set. See workers/chaser/README.md — without it the schedule runs and does nothing.`,
        },
        { status: 503, headers: cors },
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

    // An account of its own for one invoice. The app asks with the user's
    // own Firebase token, so nothing here needs a second credential, and the
    // mapping is written under that uid and nowhere else.
    if (url.pathname === '/accounts' && request.method === 'POST') {
      const uid = await uidFromIdToken(
        (request.headers.get('authorization') ?? '').replace(/^Bearer /, ''),
        env.FIREBASE_PROJECT,
      );
      if (!uid) return Response.json({ error: 'unauthorised' }, { status: 401, headers: cors });

      const body = (await request.json().catch(() => null)) as {
        invoice?: string;
        name?: string;
        email?: string;
        phone?: string;
      } | null;
      if (!body?.invoice || !body.name) {
        return Response.json({ error: 'bad_request' }, { status: 400, headers: cors });
      }

      const provider = new Paystack(env.PAYSTACK_SECRET);
      const account = await provider.create(body.invoice, {
        name: body.name,
        // Paystack wants an address for the customer record; a per-invoice
        // alias keeps one client's accounts apart without asking for one.
        email: body.email || `${body.invoice.toLowerCase()}@invoices.gabis.app`,
        phone: body.phone,
      });

      if (!account.ok) {
        // Both fall back to the account the business already gives people, but
        // they are not the same problem: one is a key nobody has set, the other
        // a Paystack account that cannot issue NUBANs yet. Saying which is the
        // difference between a setting somebody fixes and a silence nobody
        // notices.
        return Response.json(
          {
            error: account.reason,
            detail:
              account.detail ??
              'No payment provider is configured, so the invoice keeps the account the business already gives people.',
          },
          { status: 503, headers: cors },
        );
      }

      const db = await connect(env);
      await db.createDocument('payment_accounts', {
        uid,
        invoice: body.invoice,
        account: account.account,
        bank: account.bank,
        name: account.name,
        created_at: new Date().toISOString(),
      });

      return Response.json(
        { ok: true, bank: account.bank, account: account.account, name: account.name },
        { headers: cors },
      );
    }

    // Money arriving. Signed by the provider, so this is the one route that
    // may write to somebody's ledger without a user token behind it.
    if (url.pathname === '/payments/paystack' && request.method === 'POST') {
      const raw = await request.text();
      const provider = new Paystack(env.PAYSTACK_SECRET);

      if (!(await provider.verify(raw, request.headers.get('x-paystack-signature') ?? ''))) {
        return Response.json({ error: 'bad_signature' }, { status: 401 });
      }

      const payment = provider.read(JSON.parse(raw));
      if (!payment) return Response.json({ ok: true, acted: false });

      const db = await connect(env);
      const matched = await claim(db, payment);
      if (!matched) {
        // Recorded rather than dropped: a payment nobody can place is still a
        // payment, and the business needs to see it to place it by hand.
        await db.createDocument('unmatched_payments', {
          account: payment.account,
          amount: payment.amount,
          reference: payment.reference,
          narration: payment.narration,
          paid_at: payment.paidAt,
        });
        return Response.json({ ok: true, acted: false, reason: 'unmatched' });
      }

      await db.createDocument(`users/${matched.uid}/gabis/collections/payments`, {
        invoice: matched.invoice,
        amount: payment.amount,
        currency: payment.currency,
        reference: payment.reference,
        paid_at: payment.paidAt,
        matched_by: matched.how,
        narration: payment.narration,
      });

      return Response.json({ ok: true, acted: true, invoice: matched.invoice });
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

      return Response.json({ now: now.toISOString(), items: out }, { headers: cors });
    }

    return Response.json({ error: 'not_found' }, { status: 404 });
  },
};
