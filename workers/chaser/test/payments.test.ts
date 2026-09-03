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
