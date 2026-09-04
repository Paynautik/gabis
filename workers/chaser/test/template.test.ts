import { strict as assert } from 'node:assert';
import { test } from 'node:test';

import { BODIES, render, templateFor, templateName } from '../src/template.ts';

const debtor = {
  name: 'Adaeze Okafor',
  company: 'Gabis Ventures',
  outstanding: 250000,
  currency: 'NGN',
  daysOverdue: 12,
};

test('the template escalates with the attempt', () => {
  assert.equal(templateName(0), 'gabis_reminder_first');
  assert.equal(templateName(1), 'gabis_reminder_first');
  assert.equal(templateName(2), 'gabis_reminder_second');
  assert.equal(templateName(3), 'gabis_reminder_final');
  assert.equal(templateName(9), 'gabis_reminder_final');
});

test('every blank the body asks for is filled', () => {
  // Meta rejects the whole send when one parameter is missing or empty, so a
  // body with five placeholders must always be handed five real values.
  for (const attempt of [1, 2, 3]) {
    const message = templateFor({ ...debtor, attempt });
    const placeholders = new Set(
      [...BODIES[message.name].matchAll(/\{\{(\d)\}\}/g)].map((m) => m[1]),
    );

    assert.equal(message.params.length, placeholders.size);
    for (const value of message.params) assert.notEqual(value.trim(), '');
  }
});

test('the rendered message is what the customer will read', () => {
  const rendered = render(templateFor({ ...debtor, attempt: 1 }));

  assert.match(rendered, /Adaeze/);
  assert.ok(!rendered.includes('Okafor'), 'first names only');
  assert.match(rendered, /Gabis Ventures/);
  assert.match(rendered, /₦250,000\.00/);
  assert.match(rendered, /was due 12 days ago/);
  assert.match(rendered, /Reply STOP/);
  assert.ok(!rendered.includes('{{'), 'no placeholder left behind');
});

test('there is somewhere to pay even with no portal link', () => {
  const withoutLink = templateFor({ ...debtor, attempt: 1 });
  assert.match(withoutLink.params[4], /^https:\/\//);

  const withLink = templateFor({
    ...debtor,
    attempt: 1,
    payLink: 'https://gabis.pages.dev/pay?i=abc',
  });
  assert.equal(withLink.params[4], 'https://gabis.pages.dev/pay?i=abc');
});

test('it reads as a chase by the second attempt', () => {
  assert.match(render(templateFor({ ...debtor, attempt: 2 })), /now 12 days overdue/);
  assert.match(
    render(templateFor({ ...debtor, attempt: 3 })),
    /last automated reminder/,
  );
});
