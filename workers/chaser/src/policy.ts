/**
 * The same rules as ContactPolicy in the app, enforced again here.
 *
 * They are duplicated deliberately. The app's copy stops a person pressing a
 * button at midnight; this copy stops a cron job doing it unattended, which is
 * the version that can go wrong three thousand times before anyone notices.
 * Nigeria's NDPR, Kenya's DPA 2019 and Ghana's Act 843 all turn on the same
 * three things: a lawful basis, a limit on frequency, and an honoured refusal.
 */

export const DAY_START_HOUR = 8;
export const DAY_END_HOUR = 20;
export const MAX_PER_DAY = 1;
export const MAX_PER_WEEK = 3;

/** Nigeria keeps one offset all year, so this needs no zone database. */
export const LAGOS_OFFSET_HOURS = 1;

export interface Debtor {
  name: string;
  phone: string;
  outstanding: number;
  currency: string;
  due_on: string;
  consent_basis: string | null;
  do_not_contact: number;
  portal_link: string | null;
}

export interface Attempt {
  placed_at: string;
  outcome: string;
}

export interface Decision {
  allowed: boolean;
  reason?: string;
  attempt: number;
}

function localHour(now: Date): number {
  return (now.getUTCHours() + LAGOS_OFFSET_HOURS) % 24;
}

function sameLocalDay(a: Date, b: Date): boolean {
  const shift = LAGOS_OFFSET_HOURS * 3600000;
  const x = new Date(a.getTime() + shift);
  const y = new Date(b.getTime() + shift);
  return (
    x.getUTCFullYear() === y.getUTCFullYear() &&
    x.getUTCMonth() === y.getUTCMonth() &&
    x.getUTCDate() === y.getUTCDate()
  );
}

export function decide(
  debtor: Debtor,
  prior: Attempt[],
  now: Date = new Date(),
): Decision {
  const sorted = [...prior].sort(
    (a, b) => Date.parse(a.placed_at) - Date.parse(b.placed_at),
  );
  const attempt = sorted.length + 1;

  if (debtor.do_not_contact) {
    return { allowed: false, reason: 'do_not_contact', attempt };
  }

  if (!debtor.consent_basis || !debtor.consent_basis.trim()) {
    return { allowed: false, reason: 'no_lawful_basis', attempt };
  }

  // Someone who has said no is not a lead to be worked. A refusal ends the
  // automated reminders; what follows is a conversation between two people.
  if (sorted.length && sorted[sorted.length - 1].outcome === 'refused') {
    return { allowed: false, reason: 'refused', attempt };
  }

  const hour = localHour(now);
  if (hour < DAY_START_HOUR || hour >= DAY_END_HOUR) {
    return { allowed: false, reason: 'outside_hours', attempt };
  }

  const today = sorted.filter((a) => sameLocalDay(new Date(a.placed_at), now));
  if (today.length >= MAX_PER_DAY) {
    return { allowed: false, reason: 'already_today', attempt };
  }

  const week = sorted.filter(
    (a) => now.getTime() - Date.parse(a.placed_at) < 7 * 86400000,
  );
  if (week.length >= MAX_PER_WEEK) {
    return { allowed: false, reason: 'weekly_cap', attempt };
  }

  // Nothing is chased before it is owed.
  const due = Date.parse(debtor.due_on + 'T00:00:00Z');
  if (!Number.isNaN(due) && due > now.getTime()) {
    return { allowed: false, reason: 'not_due', attempt };
  }

  if (!(debtor.outstanding > 0)) {
    return { allowed: false, reason: 'nothing_owed', attempt };
  }

  return { allowed: true, attempt };
}

export function daysOverdue(due_on: string, now: Date = new Date()): number {
  const due = Date.parse(due_on + 'T00:00:00Z');
  if (Number.isNaN(due)) return 0;
  return Math.max(0, Math.floor((now.getTime() - due) / 86400000));
}
