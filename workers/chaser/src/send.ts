/**
 * Getting a message to a phone.
 *
 * Until WhatsApp credentials exist this runs in rehearsal: it works out
 * exactly what would go out and writes it down, sending nothing. That is the
 * honest default — a half-configured sender that silently drops reminders is
 * worse than one that says it did nothing.
 */

import type { TemplateMessage } from './template';

export type SendOutcome = 'sent' | 'rehearsed' | 'failed';

/** Africa's Talking and WhatsApp both want digits, country code, no punctuation. */
export function normalise(phone: string): string {
  let p = phone.replace(/[^0-9+]/g, '');
  if (p.startsWith('+')) p = p.slice(1);
  if (p.startsWith('0')) p = '234' + p.slice(1); // default NG
  return p;
}

/**
 * A reminder the business started, which is all of them.
 *
 * Sent as a template because WhatsApp refuses our own words to anyone who has
 * not written to us in the last 24 hours — free text here comes back as error
 * 131047 and the customer hears nothing.
 */
export async function send(
  phone: string,
  message: TemplateMessage,
  config: { token?: string; phoneId?: string } = {},
): Promise<SendOutcome> {
  const token = config.token ?? process.env.WHATSAPP_TOKEN;
  const phoneId = config.phoneId ?? process.env.WHATSAPP_PHONE_ID;
  if (!token || !phoneId) return 'rehearsed';

  return post(token, phoneId, {
    messaging_product: 'whatsapp',
    to: normalise(phone),
    type: 'template',
    template: {
      name: message.name,
      language: { code: message.language },
      components: [
        {
          type: 'body',
          parameters: message.params.map((text) => ({ type: 'text', text })),
        },
      ],
    },
  });
}

/**
 * Free text, allowed only inside the 24 hours after a customer writes to us.
 *
 * Nothing calls this yet — replies arrive at the webhook and are read, not
 * answered. It is here because when an answer is written it must go out this
 * way and not as a template, which would read like a robot talking over
 * somebody who just said something.
 */
export async function reply(
  phone: string,
  text: string,
  config: { token?: string; phoneId?: string } = {},
): Promise<SendOutcome> {
  const token = config.token ?? process.env.WHATSAPP_TOKEN;
  const phoneId = config.phoneId ?? process.env.WHATSAPP_PHONE_ID;
  if (!token || !phoneId) return 'rehearsed';

  return post(token, phoneId, {
    messaging_product: 'whatsapp',
    to: normalise(phone),
    type: 'text',
    text: { preview_url: true, body: text },
  });
}

async function post(
  token: string,
  phoneId: string,
  body: unknown,
): Promise<SendOutcome> {
  try {
    const response = await fetch(
      `https://graph.facebook.com/v21.0/${phoneId}/messages`,
      {
        method: 'POST',
        headers: {
          authorization: `Bearer ${token}`,
          'content-type': 'application/json',
        },
        body: JSON.stringify(body),
      },
    );
    return response.ok ? 'sent' : 'failed';
  } catch {
    return 'failed';
  }
}
