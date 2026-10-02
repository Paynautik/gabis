/**
 * Unsubscribe from the newsletter.
 *
 * The link in the email opens a confirmation page, and only the button on it
 * removes the address. Mail scanners and link previewers fetch every URL in a
 * message, so a link that unsubscribed on GET would quietly drop people who
 * never clicked anything.
 */

interface Env {
  SUBSCRIBERS: KVNamespace;
}

interface Subscriber {
  token: string;
}

const page = (inner: string) =>
  new Response(
    `<!doctype html><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Unsubscribe | gabis</title><body style="font-family:Helvetica,Arial,sans-serif;background:#f4f0e8;color:#101010;display:flex;min-height:100vh;align-items:center;justify-content:center;margin:0"><main style="max-width:420px;padding:32px;text-align:center">${inner}</main>`,
    { headers: { "content-type": "text/html; charset=utf-8", "cache-control": "no-store" } },
  );

const esc = (v: string) =>
  v.replace(/[&<>"']/g, (c) => `&#${c.charCodeAt(0)};`);

export const onRequestGet: PagesFunction<Env> = async ({ request }) => {
  const url = new URL(request.url);
  const email = esc(url.searchParams.get("e") ?? "");
  const token = esc(url.searchParams.get("t") ?? "");
  return page(
    `<h1 style="font-size:22px;margin:0 0 12px">Unsubscribe from gabis updates?</h1>
<p style="margin:0 0 20px;color:#3a3733">${email}</p>
<form method="post"><input type="hidden" name="e" value="${email}"><input type="hidden" name="t" value="${token}">
<button style="background:#101010;color:#f4f0e8;border:0;border-radius:999px;padding:14px 26px;font-weight:700;font-size:15px;cursor:pointer">Yes, unsubscribe</button></form>
<p style="margin-top:20px"><a href="/" style="color:#4c45ff;font-weight:700">Keep me subscribed</a></p>`,
  );
};

export const onRequestPost: PagesFunction<Env> = async ({ request, env }) => {
  const form = await request.formData();
  const email = String(form.get("e") ?? "").trim().toLowerCase();
  const token = String(form.get("t") ?? "");
  const key = `sub:${email}`;
  const sub = email ? await env.SUBSCRIBERS.get<Subscriber>(key, "json") : null;

  if (sub && sub.token === token) {
    await env.SUBSCRIBERS.delete(key);
    return page(
      `<h1 style="font-size:22px;margin:0 0 12px">You are unsubscribed.</h1><p style="color:#3a3733;margin:0 0 20px">You will not hear from us again.</p><a href="/" style="color:#4c45ff;font-weight:700">Back to gabis</a>`,
    );
  }
  return page(
    `<h1 style="font-size:22px;margin:0 0 12px">That link is not valid.</h1><p style="color:#3a3733;margin:0 0 20px">It may have expired, or you are already unsubscribed.</p><a href="/" style="color:#4c45ff;font-weight:700">Back to gabis</a>`,
  );
};
