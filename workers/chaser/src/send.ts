/**
 * Getting a message to a phone.
 *
 * Until WhatsApp credentials exist this runs in rehearsal: it works out
 * exactly what would go out and writes it down, sending nothing. That is the
 * honest default — a half-configured sender that silently drops reminders is
 * worse than one that says it did nothing.
 */

export interface Env {
  DB: D1Database;
  WHATSAPP_TOKEN?: string;
  WHATSAPP_PHONE_ID?: string;
}

export type SendOutcome = 'sent' | 'rehearsed' | 'failed';

/** Africa's Talking and WhatsApp both want digits, country code, no punctuation. */
export function normalise(phone: string): string {
  let p = phone.replace(/[^0-9+]/g, '');
  if (p.startsWith('+')) p = p.slice(1);
  if (p.startsWith('0')) p = '234' + p.slice(1); // default NG
  return p;
}

export async function send(
  env: Env,
  phone: string,
  message: string,
): Promise<SendOutcome> {
  if (!env.WHATSAPP_TOKEN || !env.WHATSAPP_PHONE_ID) return 'rehearsed';

  try {
    const response = await fetch(
      `https://graph.facebook.com/v21.0/${env.WHATSAPP_PHONE_ID}/messages`,
      {
        method: 'POST',
        headers: {
          authorization: `Bearer ${env.WHATSAPP_TOKEN}`,
          'content-type': 'application/json',
        },
        body: JSON.stringify({
          messaging_product: 'whatsapp',
          to: normalise(phone),
          type: 'text',
          text: { preview_url: true, body: message },
        }),
      },
    );
    return response.ok ? 'sent' : 'failed';
  } catch {
    return 'failed';
  }
}
