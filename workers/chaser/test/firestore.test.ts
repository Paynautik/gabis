import { strict as assert } from 'node:assert';
import { test } from 'node:test';

import { decode, encode, uidOf } from '../src/firestore.ts';

// Firestore's REST shape wraps every value in its type. Getting this wrong is
// silent: a debtor's balance read back as undefined would look like a paid-up
// account rather than an error, so it is worth its own tests.

test('a queue document survives the round trip', () => {
  const queue = {
    autonomous: true,
    business: 'Gabis Ventures',
    debtors: [
      {
        name: 'Adaeze Okafor',
        phone: '+2348031234567',
        outstanding: 150000,
        currency: 'NGN',
        due_on: '2026-08-24',
        consent_basis: 'contract',
        do_not_contact: 0,
        portal_link: 'https://gabis.pages.dev/portal#abc',
      },
    ],
  };

  assert.deepEqual(decode(encode(queue)), queue);
});

test('an integer amount comes back as a number, not a string', () => {
  const back = decode(encode({ outstanding: 150000, rate: 2.5 }));
  assert.equal(back.outstanding, 150000);
  assert.equal(typeof back.outstanding, 'number');
  assert.equal(back.rate, 2.5);
});

test('null and missing consent survive', () => {
  assert.deepEqual(decode(encode({ consent_basis: null })), {
    consent_basis: null,
  });
});

test('the uid is read out of the document path', () => {
  assert.equal(
    uidOf(
      'projects/paynautic/databases/(default)/documents/users/abc123/gabis/collections',
    ),
    'abc123',
  );
  assert.equal(uidOf('projects/p/databases/(default)/documents/users'), null);
});
