import { decide, daysOverdue, type Attempt, type Debtor } from './policy';
import { chaseMessage, isOptOut, optOutLine } from './message';
import { send, type Env } from './send';

/**
 * The rail that makes reminders autonomous.
 *
 * Everything before this needed someone to be holding the phone. A cron job
 * does not get tired at the third reminder or soft at the first, which is
 * exactly why the rules live in policy.ts and are checked here again rather
 * than trusted from whatever the app last synced.
 *
 * What it deliberately does not hold: invoice descriptions, emails, addresses.
 * The statement link the app syncs is opaque to this worker — the details are
 * in its fragment, which never leaves the client's browser.
 */

interface BusinessRow {
  id: string;
  name: string;
  token_hash: string;
  autonomous: number;
}

async function hash(token: string): Promise<string> {
  const digest = await crypto.subtle.digest(
    'SHA-256',
    new TextEncoder().encode(token),
  );
  return [...new Uint8Array(digest)]
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('');
}

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'content-type': 'application/json' },
  });
}

/** Constant-time enough for a token compare on a string of equal length. */
function same(a: string, b: string): boolean {
  if (a.length !== b.length) return false;
  let diff = 0;
  for (let i = 0; i < a.length; i++) diff |= a.charCodeAt(i) ^ b.charCodeAt(i);
  return diff === 0;
}

async function authorise(
  env: Env,
  request: Request,
): Promise<BusinessRow | null> {
  const header = request.headers.get('authorization') ?? '';
  const token = header.startsWith('Bearer ') ? header.slice(7) : '';
  const id = request.headers.get('x-business-id') ?? '';
  if (!token || !id) return null;

  const row = await env.DB.prepare(
    'SELECT id, name, token_hash, autonomous FROM businesses WHERE id = ?',
  )
    .bind(id)
    .first<BusinessRow>();
  if (!row) return null;

  return same(row.token_hash, await hash(token)) ? row : null;
}

/** One business's queue: who is due a reminder, and what it would say. */
async function queue(env: Env, business: BusinessRow, now: Date) {
  const debtors = await env.DB.prepare(
    'SELECT name, phone, outstanding, currency, due_on, consent_basis, do_not_contact, portal_link ' +
      'FROM debtors WHERE business_id = ?',
  )
    .bind(business.id)
    .all<Debtor>();

  const out: {
    debtor: Debtor;
    attempt: number;
    message: string;
    reason?: string;
    allowed: boolean;
  }[] = [];

  for (const debtor of debtors.results ?? []) {
    const prior = await env.DB.prepare(
      'SELECT placed_at, outcome FROM attempts WHERE business_id = ? AND debtor_name = ? ORDER BY placed_at',
    )
      .bind(business.id, debtor.name)
      .all<Attempt>();

    const decision = decide(debtor, prior.results ?? [], now);
    const message =
      chaseMessage({
        name: debtor.name,
        company: business.name,
        outstanding: debtor.outstanding,
        currency: debtor.currency,
        daysOverdue: daysOverdue(debtor.due_on, now),
        attempt: decision.attempt,
        payLink: debtor.portal_link,
      }) +
      '\n\n' +
      optOutLine(business.name);

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

async function runOnce(env: Env, now: Date) {
  const businesses = await env.DB.prepare(
    'SELECT id, name, token_hash, autonomous FROM businesses WHERE autonomous = 1',
  ).all<BusinessRow>();

  let sent = 0;
  let held = 0;

  for (const business of businesses.results ?? []) {
    for (const item of await queue(env, business, now)) {
      if (!item.allowed) {
        held++;
        continue;
      }

      const outcome = await send(env, item.debtor.phone, item.message);
      if (outcome === 'failed') {
        held++;
        continue;
      }

      // Written down whether it went out or was rehearsed, because the record
      // is what the frequency limits are counted from.
      await env.DB.prepare(
        'INSERT INTO attempts (business_id, debtor_name, placed_at, attempt, channel, outcome, message) ' +
          'VALUES (?, ?, ?, ?, ?, ?, ?)',
      )
        .bind(
          business.id,
          item.debtor.name,
          now.toISOString(),
          item.attempt,
          'whatsapp',
          outcome === 'sent' ? 'link_sent' : 'rehearsed',
          item.message,
        )
        .run();
      sent++;
    }
  }

  return { sent, held };
}

export default {
  /** Once a day, mid-morning in Lagos. The hours rule holds the line anyway. */
  async scheduled(_event: ScheduledController, env: Env): Promise<void> {
    await runOnce(env, new Date());
  },

  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);

    // A reply of STOP is a refusal, and refusals are honoured permanently.
    // Unauthenticated on purpose: it is the provider's webhook, and the worst
    // a forged call can do is stop reminders, which is the safe direction.
    if (url.pathname === '/inbound' && request.method === 'POST') {
      const body = (await request.json().catch(() => null)) as {
        from?: string;
        text?: string;
      } | null;
      if (!body?.from || !body.text) return json({ error: 'bad_request' }, 400);
      if (!isOptOut(body.text)) return json({ ok: true, acted: false });

      await env.DB.prepare(
        'UPDATE debtors SET do_not_contact = 1 WHERE replace(replace(phone, " ", ""), "+", "") LIKE ?',
      )
        .bind('%' + body.from.replace(/[^0-9]/g, '').slice(-10))
        .run();
      return json({ ok: true, acted: true });
    }

    const business = await authorise(env, request);
    if (!business) return json({ error: 'unauthorised' }, 401);

    // The app pushes the little it needs to chase on its behalf. Turning this
    // on is a decision a business makes; until it does, autonomous stays 0 and
    // the cron job skips it entirely.
    if (url.pathname === '/sync' && request.method === 'POST') {
      const body = (await request.json().catch(() => null)) as {
        autonomous?: boolean;
        debtors?: Debtor[];
      } | null;
      if (!body) return json({ error: 'bad_request' }, 400);

      await env.DB.prepare(
        'UPDATE businesses SET autonomous = ?, synced_at = ? WHERE id = ?',
      )
        .bind(body.autonomous ? 1 : 0, new Date().toISOString(), business.id)
        .run();

      const rows = body.debtors ?? [];
      // Replaced wholesale: someone who has been paid off or deleted in the
      // app must stop being chased here, and a diff is a way to get that wrong.
      const statements = [
        env.DB.prepare('DELETE FROM debtors WHERE business_id = ?').bind(
          business.id,
        ),
        ...rows.map((d) =>
          env.DB.prepare(
            'INSERT INTO debtors (business_id, name, phone, outstanding, currency, due_on, consent_basis, do_not_contact, portal_link) ' +
              'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)',
          ).bind(
            business.id,
            d.name,
            d.phone,
            d.outstanding,
            d.currency ?? 'NGN',
            d.due_on,
            d.consent_basis ?? null,
            d.do_not_contact ? 1 : 0,
            d.portal_link ?? null,
          ),
        ),
      ];
      await env.DB.batch(statements);

      return json({ ok: true, debtors: rows.length });
    }

    // What would go out, so the dashboard can show it before it does.
    if (url.pathname === '/queue' && request.method === 'GET') {
      const now = new Date();
      const items = await queue(env, business, now);
      return json({
        now: now.toISOString(),
        autonomous: business.autonomous === 1,
        items: items.map((i) => ({
          name: i.debtor.name,
          outstanding: i.debtor.outstanding,
          attempt: i.attempt,
          allowed: i.allowed,
          reason: i.reason,
          message: i.message,
        })),
      });
    }

    // The same pass the cron job makes, on demand, for testing it.
    if (url.pathname === '/run' && request.method === 'POST') {
      return json(await runOnce(env, new Date()));
    }

    return json({ error: 'not_found' }, 404);
  },
};
