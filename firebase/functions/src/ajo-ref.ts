/** Pure helpers for the references ORPay carries on each Ajo contribution. */

export const AJO_REF = 'ajo';

/** `ajo:<circleId>:<round>:<member>` */
export function ajoReference(circleId: string, round: number, member: number) {
  return `${AJO_REF}:${circleId}:${round}:${member}`;
}

/** Inverse of [ajoReference]; null when the reference is not an Ajo one. */
export function parseAjoReference(ref: unknown) {
  if (typeof ref !== 'string') return null;
  const m = /^ajo:([A-Za-z0-9]+):(\d+):(\d+)$/.exec(ref);
  return m ? { circleId: m[1], round: Number(m[2]), member: Number(m[3]) } : null;
}
