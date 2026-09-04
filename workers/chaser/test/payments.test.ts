import { strict as assert } from 'node:assert';
import { test } from 'node:test';

import { Paystack } from '../src/payments.ts';

// The webhook is the one route that writes to a ledger without a user behind
// it, so what it accepts matters more than most things here.

test('an unsigned webhook is refused', async () => {
  const paystack = new Paystack('sk_test_secret');
  assert.equal(await paystack.verify('{}', ''), false);
  assert.equal(await paystack.verify('{}', 'deadbeef'), false);
});

test('with no secret configured nothing verifies', async () => {
  const paystack = new Paystack(undefined);
  assert.equal(await paystack.verify('{}', 'anything'), false);
});

test('kobo is read back as naira', () => {
  const payment = new Paystack('sk').read({
    event: 'charge.success',
    data: {
      amount: 4500000,
      currency: 'NGN',
      reference: 'ref_1',
      paid_at: '2026-09-03T10:00:00Z',
      authorization: {
        receiver_bank_account_number: '9911223344',
        narration: 'INV-1042 payment',
      },
    },
  });

  assert.equal(payment?.amount, 45000);
  assert.equal(payment?.account, '9911223344');
  assert.equal(payment?.narration, 'INV-1042 payment');
});

test('an event that is not a payment is ignored', () => {
  assert.equal(new Paystack('sk').read({ event: 'transfer.failed' }), null);
});

test('a payment with no account to match on is ignored', () => {
  assert.equal(
    new Paystack('sk').read({ event: 'charge.success', data: { amount: 100 } }),
    null,
  );
});

test('a mint that fails says which kind of failure it was', async () => {
  // No key at all: a setting nobody has filled in.
  const unset = await new Paystack(undefined).create('INV-1', {
    name: 'Adaeze Okafor',
    email: 'inv-1@invoices.gabis.app',
  });
  assert.equal(unset.ok, false);
  assert.equal(unset.ok === false && unset.reason, 'not_configured');

  // A key that Paystack itself refuses is the other problem entirely, and the
  // caller has to be able to tell them apart.
  const original = globalThis.fetch;
  globalThis.fetch = (async () =>
    new Response(JSON.stringify({ message: 'Business profile incomplete' }), {
      status: 403,
    })) as typeof fetch;

  try {
    const refused = await new Paystack('sk_test_x').create('INV-2', {
      name: 'Adaeze Okafor',
      email: 'inv-2@invoices.gabis.app',
    });
    assert.equal(refused.ok, false);
    assert.equal(refused.ok === false && refused.reason, 'refused');
    assert.match(
      refused.ok === false ? (refused.detail ?? '') : '',
      /Business profile incomplete/,
    );
  } finally {
    globalThis.fetch = original;
  }
});

test('the entitlement check reports what Paystack said', async () => {
  const original = globalThis.fetch;
  globalThis.fetch = (async () =>
    new Response(JSON.stringify({ data: [] }), { status: 200 })) as typeof fetch;

  try {
    // A key that works but offers no bank is the business profile, not the key,
    // and the difference is the whole point of saying so.
    const empty = await new Paystack('sk_test_x').check();
    assert.equal(empty.ok, false);
    assert.match(empty.detail ?? '', /business profile/i);
  } finally {
    globalThis.fetch = original;
  }
});
