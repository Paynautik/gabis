/**
 * The words that go out, matched to the attempt they are.
 *
 * Kept in step with Outreach.chaseMessage in the app: a customer must not be
 * able to tell whether the reminder came from someone pressing a button or
 * from the cron job, because as far as they are concerned it is the same
 * business either way.
 */

const SYMBOLS: Record<string, string> = {
  NGN: '₦',
  USD: '$',
  GBP: '£',
  KES: 'KSh ',
  GHS: 'GH₵ ',
};

export function money(amount: number, currency: string): string {
  const symbol = SYMBOLS[currency] ?? (currency ? currency + ' ' : '');
  return (
    symbol +
    Number(amount || 0).toLocaleString('en-NG', {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2,
    })
  );
}

export function chaseMessage(opts: {
  name: string;
  company: string;
  outstanding: number;
  currency: string;
  daysOverdue: number;
  attempt: number;
  payLink?: string | null;
}): string {
  const first = opts.name.split(' ')[0];
  const owed = money(opts.outstanding, opts.currency);
  const late = opts.daysOverdue === 1 ? '1 day' : `${opts.daysOverdue} days`;
  const pay = opts.payLink ? `\n\nPay here: ${opts.payLink}` : '';

  if (opts.attempt <= 1) {
    const timing = opts.daysOverdue > 0 ? `was due ${late} ago` : 'is due shortly';
    return (
      `Hello ${first}, this is ${opts.company}. ` +
      `Your balance of ${owed} ${timing}. ` +
      'You can pay from your gabis app, or reply here if you need a new date. ' +
      `Thank you.${pay}`
    );
  }

  if (opts.attempt === 2) {
    return (
      `Hello ${first}, ${opts.company} again about ${owed}, ` +
      `${opts.daysOverdue > 0 ? `now ${late} overdue` : 'due shortly'}. ` +
      'We have not heard back on the first reminder. ' +
      'Can you pay today, or reply with the date you will pay so we can hold it? ' +
      `Thank you.${pay}`
    );
  }

  return (
    `Hello ${first}. This is the last automated reminder from ${opts.company} ` +
    `about ${owed}, ${opts.daysOverdue > 0 ? `${late} overdue` : 'now due'}. ` +
    `After this someone from ${opts.company} will contact you directly to agree ` +
    'how it will be settled. If you have already paid, reply with the date and ' +
    `we will match it. Thank you.${pay}`
  );
}

/** Travels with every automated reminder: who is asking, and how to stop it. */
export function optOutLine(company: string): string {
  return `Sent by ${company} through gabis. Reply STOP to opt out of reminders.`;
}

/** What counts as a refusal when a reply comes back. */
export function isOptOut(text: string): boolean {
  return /^\s*(stop|unsubscribe|opt\s*out|no more|leave me)\b/i.test(text);
}
