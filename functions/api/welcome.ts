/**
 * Welcome email for a newly created account.
 *
 * The app calls this right after sign-up with the person's Firebase ID token.
 * The address is taken from the verified token, never from the request body,
 * so this endpoint can only ever email the account that just signed up: it
 * is not a way to send mail to an arbitrary address.
 *
 * Two more guards: the account must have been created in the last half hour
 * (an old token cannot be used to resend), and the email goes out once per
 * account, remembered in KV.
 */

interface Env {
  SUBSCRIBERS: KVNamespace;
  /** The Firebase web API key. Public by design: it is in the app bundle. */
  FIREBASE_API_KEY?: string;
  RESEND_API_KEY?: string;
  FROM_EMAIL?: string;
  SITE_URL?: string;
  /** Only set in tests, to point at stand-ins. */
  RESEND_API_URL?: string;
  FIREBASE_LOOKUP_URL?: string;
}

interface FirebaseUser {
  localId: string;
  email?: string;
  displayName?: string;
  /** Milliseconds since the epoch, as a string. */
  createdAt?: string;
}

const FRESH_MS = 30 * 60 * 1000;

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { "content-type": "application/json", "cache-control": "no-store" },
  });

export const onRequestPost: PagesFunction<Env> = async ({ request, env }) => {
  const auth = request.headers.get("authorization") ?? "";
  const idToken = auth.startsWith("Bearer ") ? auth.slice(7).trim() : "";
  if (!idToken) return json({ error: "unauthorized" }, 401);
  if (!env.FIREBASE_API_KEY) return json({ error: "not_configured" }, 503);

  const user = await lookup(env, idToken);
  if (!user || !user.email) return json({ error: "unauthorized" }, 401);

  const created = Number(user.createdAt ?? 0);
  if (!created || Date.now() - created > FRESH_MS) {
    return json({ ok: true, sent: false, reason: "not_new" });
  }

  const key = `welcome:${user.localId}`;
  if (await env.SUBSCRIBERS.get(key)) {
    return json({ ok: true, sent: false, reason: "already_sent" });
  }
  if (!env.RESEND_API_KEY) return json({ ok: true, sent: false, reason: "not_configured" });

  const siteUrl = (env.SITE_URL ?? "https://gabispay.com").replace(/\/$/, "");
  const sent = await send(env, user.email, user.displayName ?? "", siteUrl);
  // Marked only after a successful send, so a failure can be retried.
  if (sent) await env.SUBSCRIBERS.put(key, new Date().toISOString());
  return json({ ok: true, sent });
};

async function lookup(env: Env, idToken: string): Promise<FirebaseUser | null> {
  try {
    const base =
      env.FIREBASE_LOOKUP_URL ?? "https://identitytoolkit.googleapis.com/v1/accounts:lookup";
    const res = await fetch(`${base}?key=${env.FIREBASE_API_KEY}`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ idToken }),
    });
    if (!res.ok) return null;
    const data = (await res.json()) as { users?: FirebaseUser[] };
    return data.users?.[0] ?? null;
  } catch {
    return null;
  }
}

async function send(env: Env, email: string, name: string, siteUrl: string): Promise<boolean> {
  const first = name.trim().split(/\s+/)[0] ?? "";
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
        reply_to: "hello@gabispay.com",
        subject: first ? `${first}, your gabis account is ready` : "Your gabis account is ready",
        html: html(first, siteUrl),
        text: text(first, siteUrl),
      }),
    });
    if (!res.ok) {
      console.error("account welcome failed", res.status, await res.text());
      return false;
    }
    return true;
  } catch (err) {
    console.error("account welcome error", err);
    return false;
  }
}

const esc = (v: string) => v.replace(/[&<>"']/g, (c) => `&#${c.charCodeAt(0)};`);

function text(first: string, siteUrl: string): string {
  return `${first ? `Hi ${first},` : "Hi,"}

Your gabis account is ready. You can sign in any time at ${siteUrl}/login.

To get started, add money to your wallet or send your first invoice. If you get stuck, or something looks wrong, just reply to this email. A person reads every reply.

If you did not create this account, reply and tell us.

The gabis team

---
gabis is a financial technology company, not a bank. Money remittance and banking services are provided by our licensed financial institution partners.
`;
}

function html(first: string, siteUrl: string): string {
  return `<div style="font-family:Arial,Helvetica,sans-serif;font-size:15px;line-height:1.6;color:#222;max-width:540px">
<p>${first ? `Hi ${esc(first)},` : "Hi,"}</p>
<p>Your gabis account is ready. You can sign in any time at <a href="${siteUrl}/login">${siteUrl.replace(/^https?:\/\//, "")}/login</a>.</p>
<p>To get started, add money to your wallet or send your first invoice. If you get stuck, or something looks wrong, just reply to this email. A person reads every reply.</p>
<p>If you did not create this account, reply and tell us.</p>
<p>The gabis team</p>
<p style="margin-top:28px;font-size:12px;color:#777">gabis is a financial technology company, not a bank. Money remittance and banking services are provided by our licensed financial institution partners.</p>
</div>`;
}
