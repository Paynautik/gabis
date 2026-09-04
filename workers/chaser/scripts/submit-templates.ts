/**
 * Submit the three reminder templates to Meta for approval.
 *
 * Typing them into the dashboard three times is where the mistakes happen: a
 * category left on Marketing, a language of en_US the worker will never match,
 * a placeholder that drifted from the body it belongs to. This posts exactly
 * what src/template.ts says, so what Meta approves is what the worker sends.
 *
 *   WABA_ID=... WHATSAPP_TOKEN=... node --experimental-strip-types \
 *     scripts/submit-templates.ts
 *
 * Safe to re-run: a template that already exists comes back as a name conflict,
 * which is reported and skipped rather than treated as failure.
 */

import { BODIES, FOOTER, type TemplateName } from '../src/template.ts';

const waba = process.env.WABA_ID;
const token = process.env.WHATSAPP_TOKEN;

if (!waba || !token) {
  console.error(
    'Need WABA_ID and WHATSAPP_TOKEN in the environment. Both are on the\n' +
      'WhatsApp API Setup page: the WhatsApp Business account ID, and a token.',
  );
  process.exit(1);
}

/** What the worker really produces, which is what Meta asks for as examples. */
const SAMPLES: Record<TemplateName, string[]> = {
  gabis_reminder_first: [
    'Adaeze',
    'Gabis Ventures',
    '₦250,000.00',
    'was due 12 days ago',
    'https://gabis.pages.dev/pay?i=abc',
  ],
  gabis_reminder_second: [
    'Adaeze',
    'Gabis Ventures',
    '₦250,000.00',
    'now 12 days overdue',
    'https://gabis.pages.dev/pay?i=abc',
  ],
  gabis_reminder_final: [
    'Adaeze',
    'Gabis Ventures',
    '₦250,000.00',
    'now 12 days overdue',
    'https://gabis.pages.dev/pay?i=abc',
  ],
};

for (const name of Object.keys(BODIES) as TemplateName[]) {
  const response = await fetch(
    `https://graph.facebook.com/v21.0/${waba}/message_templates`,
    {
      method: 'POST',
      headers: {
        authorization: `Bearer ${token}`,
        'content-type': 'application/json',
      },
      body: JSON.stringify({
        name,
        // Utility, not Marketing: these are transactional reminders about money
        // already owed. The wrong category costs more per message and is the
        // most common reason one of these is rejected.
        category: 'UTILITY',
        language: 'en',
        components: [
          {
            type: 'BODY',
            text: BODIES[name],
            example: { body_text: [SAMPLES[name]] },
          },
          { type: 'FOOTER', text: FOOTER },
        ],
      }),
    },
  );

  const body = (await response.json()) as {
    id?: string;
    status?: string;
    error?: { message?: string; error_subcode?: number };
  };

  if (response.ok) {
    console.log(`${name}: submitted, ${body.status ?? 'PENDING'}`);
  } else if (body.error?.error_subcode === 2388024) {
    console.log(`${name}: already exists, left alone`);
  } else {
    console.error(`${name}: ${body.error?.message ?? response.status}`);
  }
}

console.log(
  '\nApproval usually takes a few hours. Meta emails the app address, and\n' +
    'WhatsApp Manager shows the status.',
);
