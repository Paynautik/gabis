import { Firestore, decode } from './firestore.ts';

/**
 * Money arriving, and finding the invoice it belongs to.
 *
 * This is the difference between an invoicing app and something a business
 * pays for. Until now a customer paid into a shared account, typed the invoice
 * number into the narration if they remembered, and the business found out by
 * being told. A per-invoice account removes all of that: the account number is
 * the reference, so a payment identifies itself.
 *
 * Paystack's dedicated NUBAN is the provider here. The shape is deliberately
 * behind an interface — a business already banking with someone else should be
 * able to keep them.
 */

/**
 * What came of trying to mint an account, including why not.
 *
 * A plain null was hiding the difference between no provider configured and a
 * provider that refused, and those need opposite responses: one is a setting,
 * the other is a business whose Paystack account cannot issue NUBANs yet. Both
 * fall back to the shared account, so neither is visible in the invoice — only
 * in what this says.
 */
export type Minted =
  | { ok: true; bank: string; account: string; name: string }
  | { ok: false; reason: 'not_configured' | 'refused'; detail?: string };

export interface Provider {
  create(
    invoiceId: string,
    customer: { name: string; email: string; phone?: string },
  ): Promise<Minted>;

  /** Whether the credentials work and NUBANs can actually be issued. */
  check(): Promise<{ ok: boolean; detail?: string; banks?: string[] }>;

  /** Whether this webhook really came from the provider. */
  verify(body: string, signature: string): Promise<boolean>;

  /** What a webhook body means, or null when it is not a payment. */
  read(body: unknown): Payment | null;
}

export interface Payment {
  account: string;
  amount: number;
  currency: string;
  reference: string;
  paidAt: string;
  /** Whatever the sender typed, which is the fallback when nothing else matches. */
  narration: string;
}

/** Paystack says what is wrong in the body; the status alone never does. */
async function message(response: Response, doing: string): Promise<string> {
  const body = (await response.json().catch(() => null)) as { message?: string } | null;
  return `Paystack refused ${doing}: ${body?.message ?? `HTTP ${response.status}`}`;
}

async function hmacSha512(secret: string, body: string): Promise<string> {
  const key = await crypto.subtle.importKey(
    'raw',
    new TextEncoder().encode(secret),
    { name: 'HMAC', hash: 'SHA-512' },
    false,
    ['sign'],
  );
  const signature = await crypto.subtle.sign(
    'HMAC',
    key,
    new TextEncoder().encode(body),
  );
  return [...new Uint8Array(signature)]
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('');
}

export class Paystack implements Provider {
  readonly secret?: string;

  constructor(secret?: string) {
    this.secret = secret;
  }

  async create(
    invoiceId: string,
    customer: { name: string; email: string; phone?: string },
  ): Promise<Minted> {
    if (!this.secret) return { ok: false, reason: 'not_configured' };

    const created = await fetch('https://api.paystack.co/customer', {
      method: 'POST',
      headers: {
        authorization: `Bearer ${this.secret}`,
        'content-type': 'application/json',
      },
      body: JSON.stringify({
        email: customer.email,
        first_name: customer.name.split(' ')[0],
        last_name: customer.name.split(' ').slice(1).join(' ') || customer.name,
        phone: customer.phone,
      }),
    });
    if (!created.ok) {
      return {
        ok: false,
        reason: 'refused',
        detail: await message(created, 'creating the customer record'),
      };
    }
    const code = ((await created.json()) as any)?.data?.customer_code;
    if (!code) {
      return { ok: false, reason: 'refused', detail: 'Paystack returned no customer code.' };
    }

    const account = await fetch('https://api.paystack.co/dedicated_account', {
      method: 'POST',
      headers: {
        authorization: `Bearer ${this.secret}`,
        'content-type': 'application/json',
      },
      body: JSON.stringify({ customer: code, preferred_bank: 'wema-bank' }),
    });
    if (!account.ok) {
      return {
        ok: false,
        reason: 'refused',
        detail: await message(account, 'issuing the account number'),
      };
    }

    const data = ((await account.json()) as any)?.data;
    if (!data?.account_number) {
      return { ok: false, reason: 'refused', detail: 'Paystack issued no account number.' };
    }

    return {
      ok: true,
      bank: data.bank?.name ?? 'Wema Bank',
      account: String(data.account_number),
      name: data.account_name ?? invoiceId,
    };
  }

  /**
   * Whether this business can actually mint per-invoice accounts.
   *
   * Paystack gates dedicated NUBANs on a completed business profile, and a key
   * that works everywhere else fails only here. Asking which banks are
   * available answers both questions — the key, and the entitlement — without
   * creating anything.
   */
  async check(): Promise<{ ok: boolean; detail?: string; banks?: string[] }> {
    if (!this.secret) return { ok: false, detail: 'No Paystack key is set.' };

    const response = await fetch(
      'https://api.paystack.co/dedicated_account/available_providers',
      { headers: { authorization: `Bearer ${this.secret}` } },
    );

    if (!response.ok) {
      return { ok: false, detail: await message(response, 'listing the banks') };
    }

    const banks = (((await response.json()) as any)?.data ?? [])
      .map((b: any) => String(b.provider_slug ?? b.bank_name ?? ''))
      .filter(Boolean);

    return banks.length
      ? { ok: true, banks }
      : {
          ok: false,
          detail:
            'Paystack accepted the key but offers no bank for dedicated accounts. ' +
            'That is the business profile, not the key: finish it in the Paystack dashboard.',
        };
  }

  async verify(body: string, signature: string): Promise<boolean> {
    if (!this.secret || !signature) return false;
    const expected = await hmacSha512(this.secret, body);
    // Same length either way, so a plain compare leaks nothing useful.
    return expected.length === signature.length && expected === signature;
  }

  read(body: unknown): Payment | null {
    const event = body as any;
    if (event?.event !== 'charge.success') return null;

    const data = event.data ?? {};
    const account =
      data.authorization?.receiver_bank_account_number ??
      data.metadata?.receiver_account_number ??
      '';
    if (!account) return null;

    return {
      account: String(account),
      // Paystack counts in kobo; the rest of gabis counts in naira.
      amount: Number(data.amount ?? 0) / 100,
      currency: String(data.currency ?? 'NGN'),
      reference: String(data.reference ?? ''),
      paidAt: String(data.paid_at ?? new Date().toISOString()),
      narration: String(data.authorization?.narration ?? data.narration ?? ''),
    };
  }
}

/**
 * Which invoice a payment belongs to.
 *
 * The account number is the strong answer, because it was minted for one
 * invoice and nothing else. Narration is the weak one, kept because customers
 * paying from an old saved beneficiary still exist, and a payment matched by
 * what somebody typed is better than a payment nobody can place.
 */
export interface Claim {
  uid: string;
  invoice: string;
  /** 'account' is certain; 'narration' is a guess the business should confirm. */
  how: 'account' | 'narration';
}

export async function claim(
  db: Firestore,
  payment: Payment,
): Promise<Claim | null> {
  const byAccount = await db.query('', {
    from: [{ collectionId: 'payment_accounts', allDescendants: true }],
    where: {
      fieldFilter: {
        field: { fieldPath: 'account' },
        op: 'EQUAL',
        value: { stringValue: payment.account },
      },
    },
  });

  if (byAccount.length) {
    const row = decode(byAccount[0].fields) as { uid: string; invoice: string };
    if (row.uid && row.invoice) {
      return { uid: row.uid, invoice: row.invoice, how: 'account' };
    }
  }

  const reference = payment.narration.match(/\b(?:INV|AGR)-[A-Za-z0-9-]+/i);
  if (!reference) return null;

  const byNarration = await db.query('', {
    from: [{ collectionId: 'payment_accounts', allDescendants: true }],
    where: {
      fieldFilter: {
        field: { fieldPath: 'invoice' },
        op: 'EQUAL',
        value: { stringValue: reference[0].toUpperCase() },
      },
    },
  });

  if (!byNarration.length) return null;
  const row = decode(byNarration[0].fields) as { uid: string; invoice: string };
  return row.uid && row.invoice
    ? { uid: row.uid, invoice: row.invoice, how: 'narration' }
    : null;
}
