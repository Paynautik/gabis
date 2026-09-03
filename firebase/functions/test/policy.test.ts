import { strict as assert } from 'node:assert';
import { test } from 'node:test';

import { decide, daysOverdue, type Debtor } from '../src/policy.ts';
import { chaseMessage, isOptOut } from '../src/message.ts';
import { normalise } from '../src/send.ts';

const debtor = (over: Partial<Debtor> = {}): Debtor => ({
  name: 'Adaeze Okafor',
  phone: '+2348031234567',
  outstanding: 150000,
  currency: 'NGN',
  due_on: '2026-08-24',
  consent_basis: 'contract',
  do_not_contact: 0,
  portal_link: null,
  ...over,
});

// 11:00 UTC is midday in Lagos, so the hours rule never decides these alone.
const noon = new Date('2026-09-03T11:00:00Z');
const attemptAt = (iso: string, outcome = 'no_answer') => ({
  placed_at: iso,
  outcome,
});

test('a first reminder for something genuinely overdue goes out', () => {
  const d = decide(debtor(), [], noon);
  assert.equal(d.allowed, true);
  assert.equal(d.attempt, 1);
});

test('nothing is chased before it is owed', () => {
  const d = decide(debtor({ due_on: '2026-12-01' }), [], noon);
  assert.equal(d.allowed, false);
  assert.equal(d.reason, 'not_due');
});

test('no lawful basis, no contact', () => {
  assert.equal(
    decide(debtor({ consent_basis: null }), [], noon).reason,
    'no_lawful_basis',
  );
});

test('a refusal ends it, however many days pass', () => {
  const d = decide(
    debtor(),
    [attemptAt('2026-08-01T10:00:00Z', 'refused')],
    noon,
  );
  assert.equal(d.allowed, false);
  assert.equal(d.reason, 'refused');
});

test('the cron job cannot ring anyone at night', () => {
  const threeAm = new Date('2026-09-03T02:00:00Z');
  assert.equal(decide(debtor(), [], threeAm).reason, 'outside_hours');
});

test('one a day, three a week', () => {
  assert.equal(
    decide(debtor(), [attemptAt('2026-09-03T08:00:00Z')], noon).reason,
    'already_today',
  );

  const thrice = ['2026-09-01', '2026-09-02', '2026-08-30'].map((d) =>
    attemptAt(`${d}T10:00:00Z`),
  );
  assert.equal(decide(debtor(), thrice, noon).reason, 'weekly_cap');
});

test('the attempt count drives the wording', () => {
  const words = (attempt: number) =>
    chaseMessage({
      name: 'Adaeze Okafor',
      company: 'Gabis Ventures',
      outstanding: 150000,
      currency: 'NGN',
      daysOverdue: daysOverdue('2026-08-24', noon),
      attempt,
    });

  assert.match(words(1), /need a new date/);
  assert.match(words(2), /have not heard back/);
  assert.match(words(3), /last automated reminder/);
  for (const n of [1, 2, 3]) assert.match(words(n), /Adaeze/);
});

test('overdue days are counted from the due date', () => {
  assert.equal(daysOverdue('2026-08-24', noon), 10);
  assert.equal(daysOverdue('2026-12-01', noon), 0);
});

test('a reply of STOP is a refusal', () => {
  assert.equal(isOptOut('STOP'), true);
  assert.equal(isOptOut('stop please'), true);
  assert.equal(isOptOut('I will pay on Friday'), false);
});

test('numbers are normalised the way the app normalises them', () => {
  assert.equal(normalise('0803 123 4567'), '2348031234567');
  assert.equal(normalise('+234 803 123 4567'), '2348031234567');
});
