/**
 * Newsletter signup from the footer form: stores the address and sends a
 * welcome email.
 *
 * Storage is one KV key per address, `sub:<email>`, so a repeat signup is a
 * lookup rather than a scan. The welcome email goes through Resend, whose key
 * lives in a Pages secret (RESEND_API_KEY) and never in the page. Without the
 * key the address is still saved and the reply says no email went out, so the
 * form does not claim something it did not do.
 *
 * A form that emails whatever address it is given is a way to mail-bomb a
 * stranger, so three things limit that: the welcome email goes out once per
 * address (a repeat signup sends nothing), signups are throttled per visitor,
 * and a hidden field catches simple bots.
 */

interface Env {
  SUBSCRIBERS: KVNamespace;
  RESEND_API_KEY?: string;
  /** "gabis <hello@gabispay.com>" unless overridden. */
  FROM_EMAIL?: string;
  /** Public origin used in links inside the email. */
  SITE_URL?: string;
  /** Only set in tests, to point at a stand-in for Resend. */
  RESEND_API_URL?: string;
}

interface Subscriber {
  email: string;
  subscribedAt: string;
  /** Random, so an unsubscribe link cannot be guessed from the address. */
  token: string;
  welcomeSent: boolean;
  source: string;
}

const MAX_PER_HOUR = 6;
const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/;

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { "content-type": "application/json", "cache-control": "no-store" },
  });

export const onRequestPost: PagesFunction<Env> = async ({ request, env }) => {
  let email = "";
  let honeypot = "";
  try {
    const body = (await request.json()) as { email?: unknown; website?: unknown };
    email = typeof body.email === "string" ? body.email.trim().toLowerCase() : "";
    honeypot = typeof body.website === "string" ? body.website : "";
  } catch {
    return json({ error: "bad_request" }, 400);
  }

  // Real visitors never see this field. A bot that fills it gets the same
  // answer as everyone else and nothing is stored.
  if (honeypot) return json({ ok: true, welcome: false });

  if (email.length > 254 || !EMAIL_RE.test(email)) {
    return json({ error: "invalid_email" }, 400);
  }

  // Per-visitor throttle. The address is hashed so the address is not kept.
  const ip = request.headers.get("cf-connecting-ip") ?? "unknown";
  const hour = Math.floor(Date.now() / 3_600_000);
  const rlKey = `rl:${await sha256(ip)}:${hour}`;
  const used = parseInt((await env.SUBSCRIBERS.get(rlKey)) ?? "0", 10);
  if (used >= MAX_PER_HOUR) return json({ error: "rate_limited" }, 429);
  await env.SUBSCRIBERS.put(rlKey, String(used + 1), { expirationTtl: 7200 });

  const key = `sub:${email}`;
  const existing = await env.SUBSCRIBERS.get<Subscriber>(key, "json");
  if (existing) {
    // Already on the list: same reply as a new signup, and no second email.
    return json({ ok: true, welcome: existing.welcomeSent, already: true });
  }

  const sub: Subscriber = {
    email,
    subscribedAt: new Date().toISOString(),
    token: crypto.randomUUID().replace(/-/g, ""),
    welcomeSent: false,
    source: "landing",
  };
  await env.SUBSCRIBERS.put(key, JSON.stringify(sub));

  const siteUrl = (env.SITE_URL ?? "https://gabispay.com").replace(/\/$/, "");
  let welcome = false;
  if (env.RESEND_API_KEY) {
    welcome = await sendWelcome(env, email, sub.token, siteUrl);
    if (welcome) {
      await env.SUBSCRIBERS.put(key, JSON.stringify({ ...sub, welcomeSent: true }));
    }
  }

  return json({ ok: true, welcome });
};

async function sendWelcome(
  env: Env,
  email: string,
  token: string,
  siteUrl: string,
): Promise<boolean> {
  const unsubscribe = `${siteUrl}/api/unsubscribe?e=${encodeURIComponent(email)}&t=${token}`;
  try {
    const res = await fetch(`${env.RESEND_API_URL ?? "https://api.resend.com"}/emails`, {
      method: "POST",
      headers: {
        authorization: `Bearer ${env.RESEND_API_KEY}`,
        "content-type": "application/json",
      },
      body: JSON.stringify({
        from: env.FROM_EMAIL ?? "gabis <hello@gabispay.com>",
        to: [email],
        subject: "Welcome to gabis",
        html: welcomeHtml(siteUrl, unsubscribe),
        text: welcomeText(siteUrl, unsubscribe),
        headers: { "List-Unsubscribe": `<${unsubscribe}>` },
      }),
    });
    if (!res.ok) {
      console.error("welcome email failed", res.status, await res.text());
      return false;
    }
    return true;
  } catch (err) {
    console.error("welcome email error", err);
    return false;
  }
}

function welcomeText(siteUrl: string, unsubscribe: string): string {
  return `Welcome to gabis.

You are on the list for product updates and new currency corridors. We will keep it short and only write when there is something worth saying.

In the meantime:
- Open an account: ${siteUrl}/login
- Read our guides: ${siteUrl}/#stories

If you did not sign up, you can ignore this email, or unsubscribe here: ${unsubscribe}

gabis is a financial technology company, not a bank. Money remittance and banking services are provided by our licensed financial institution partners.
`;
}

function welcomeHtml(siteUrl: string, unsubscribe: string): string {
  return `<!doctype html>
<html><body style="margin:0;background:#f4f0e8;font-family:Helvetica,Arial,sans-serif;color:#101010">
<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background:#f4f0e8"><tr><td align="center" style="padding:32px 16px">
<table role="presentation" width="560" cellpadding="0" cellspacing="0" style="max-width:560px;width:100%;background:#ffffff;border-radius:16px;overflow:hidden">
<tr><td style="background:#1a1147;padding:24px 32px"><img src="${siteUrl}/landing/media/gabis-logo-white.png" alt="gabis" height="30" style="display:block;height:30px;width:auto"></td></tr>
<tr><td style="padding:32px">
<h1 style="margin:0 0 16px;font-size:26px;line-height:1.2;color:#1a1147">Welcome to gabis</h1>
<p style="margin:0 0 16px;font-size:16px;line-height:1.6;color:#2b2926">You are on the list for product updates and new currency corridors. We will keep it short and only write when there is something worth saying.</p>
<p style="margin:0 0 24px;font-size:16px;line-height:1.6;color:#2b2926">In the meantime, you can open an account or read how collections, tax and school fees work.</p>
<p style="margin:0 0 24px"><a href="${siteUrl}/login" style="display:inline-block;background:#4b45f5;color:#ffffff;text-decoration:none;font-weight:700;font-size:15px;padding:14px 26px;border-radius:999px">Open your account</a></p>
<p style="margin:0;font-size:15px;line-height:1.6"><a href="${siteUrl}/#stories" style="color:#4b45f5;font-weight:700">Read our guides &rarr;</a></p>
</td></tr>
<tr><td style="padding:20px 32px 28px;border-top:1px solid #ece6db;font-size:12px;line-height:1.6;color:#6b6660">
You received this because this address was entered on gabispay.com. If that was not you, ignore this email or <a href="${unsubscribe}" style="color:#6b6660">unsubscribe</a>.<br><br>
gabis is a financial technology company, not a bank. Money remittance and banking services are provided by our licensed financial institution partners.
</td></tr>
</table></td></tr></table></body></html>`;
}

async function sha256(input: string): Promise<string> {
  const data = new TextEncoder().encode(input);
  const digest = await crypto.subtle.digest("SHA-256", data);
  return [...new Uint8Array(digest)]
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("")
    .slice(0, 24);
}
