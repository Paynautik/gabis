/**
 * WhatsApp will not carry our own words to somebody who has not written to us
 * first.
 *
 * Anything a business starts — which every reminder is — has to arrive as a
 * template Meta approved in advance, with only the blanks filled in. Free text
 * is allowed for 24 hours after the customer replies, and nowhere else. So the
 * escalation lives here twice: once as the template a human submits to Meta,
 * and once as the blanks the worker fills for a given debtor. The two must say
 * the same thing, which is why the body text sits in this file next to the
 * parameters rather than in a dashboard nobody reads.
 *
 * WHATSAPP_TEMPLATES.md is generated from BODIES below. If you change the
 * words here, the template in Meta has to be resubmitted and re-approved.
 */

import { money } from '../../../firebase/functions/src/message.ts';

/** Where somebody pays when an invoice carries no portal link of its own. */
const FALLBACK_PAY_LINK = 'https://gabis.pages.dev/pay';

export type TemplateName =
  | 'gabis_reminder_first'
  | 'gabis_reminder_second'
  | 'gabis_reminder_final';

/**
 * The approved body of each template, placeholders and all.
 *
 * Kept in the same order the parameters are sent, because Meta matches them by
 * position and a swapped pair reads as somebody else's debt.
 */
export const BODIES: Record<TemplateName, string> = {
  gabis_reminder_first:
    'Hello {{1}}, this is {{2}}. Your balance of {{3}} {{4}}. ' +
    'You can pay from your gabis app, or reply here if you need a new date. ' +
    'Thank you.\n\nPay here: {{5}}',

  gabis_reminder_second:
    'Hello {{1}}, {{2}} again about {{3}}, {{4}}. ' +
    'We have not heard back on the first reminder. ' +
    'Can you pay today, or reply with the date you will pay so we can hold it? ' +
    'Thank you.\n\nPay here: {{5}}',

  gabis_reminder_final:
    'Hello {{1}}. This is the last automated reminder from {{2}} about {{3}}, {{4}}. ' +
    'After this someone from our team will contact you directly to agree how it ' +
    'will be settled. If you have already paid, reply with the date and we will ' +
    'match it. Thank you.\n\nPay here: {{5}}',
};

/**
 * The footer every template carries. It cannot hold parameters, so the company
 * names itself in the body and this only has to say how to make it stop.
 */
export const FOOTER = 'Sent through gabis. Reply STOP to opt out of reminders.';

/** First, second, and everything after that. */
export function templateName(attempt: number): TemplateName {
  if (attempt <= 1) return 'gabis_reminder_first';
  if (attempt === 2) return 'gabis_reminder_second';
  return 'gabis_reminder_final';
}

export interface TemplateMessage {
  name: TemplateName;
  language: string;
  params: string[];
}

/**
 * The blanks, in the order the body expects them.
 *
 * Empty is not allowed: Meta rejects a blank parameter, and a reminder held
 * back over a missing surname helps nobody. Each blank has something true to
 * fall back on.
 */
export function templateFor(opts: {
  name: string;
  company: string;
  outstanding: number;
  currency: string;
  daysOverdue: number;
  attempt: number;
  payLink?: string | null;
}): TemplateMessage {
  const first = opts.name.split(' ')[0] || opts.name || 'there';
  const late = opts.daysOverdue === 1 ? '1 day' : `${opts.daysOverdue} days`;

  // The same phrase the free-text version uses, and the reason attempt two and
  // three read differently from attempt one.
  const timing =
    opts.attempt <= 1
      ? opts.daysOverdue > 0
        ? `was due ${late} ago`
        : 'is due shortly'
      : opts.daysOverdue > 0
        ? `now ${late} overdue`
        : 'due shortly';

  return {
    name: templateName(opts.attempt),
    language: 'en',
    params: [
      first,
      opts.company || 'your supplier',
      money(opts.outstanding, opts.currency),
      timing,
      opts.payLink || FALLBACK_PAY_LINK,
    ],
  };
}

/** What the customer will actually read, for the attempts log and for /queue. */
export function render(message: TemplateMessage): string {
  const body = BODIES[message.name].replace(
    /\{\{(\d)\}\}/g,
    (_, index) => message.params[Number(index) - 1] ?? '',
  );
  return `${body}\n\n${FOOTER}`;
}
