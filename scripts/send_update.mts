/**
 * Sends the "Something good is coming" update, with the shared banner.
 *
 *   node scripts/send_update.mts --html                     print the HTML (to look at it)
 *   node scripts/send_update.mts --preview you@example.com  send ONE copy to that address
 *   node scripts/send_update.mts --list recipients.json     show who would receive it, send nothing
 *   node scripts/send_update.mts --send recipients.json     send to everyone in the file
 *
 * recipients.json is [{ "email": "...", "name": "...", "token": "..." }]. The
 * token is the one stored with the address in the SUBSCRIBERS KV namespace, so
 * the unsubscribe link in each email actually works.
 *
 * RESEND_API_KEY must be in the environment. Sending is capped per run by
 * --max (default 90) because Resend's free plan allows 100 emails a day.
 */
import { readFileSync } from "node:fs";
import { button, esc, layout, p, plain } from "../functions/_lib/email.ts";

const SITE = "https://gabispay.com";
const FROM = "gabis <hello@gabispay.com>";
const SUBJECT = "Something good is coming to gabis";

interface Recipient {
  email: string;
  name?: string;
  token: string;
}

const firstName = (name?: string) => (name ?? "").trim().split(/\s+/)[0] ?? "";

function unsubscribeUrl(r: Recipient) {
  return `${SITE}/api/unsubscribe?e=${encodeURIComponent(r.email)}&t=${r.token}`;
}

function build(r: Recipient) {
  const first = firstName(r.name);
  const unsub = unsubscribeUrl(r);
  const hello = first ? `Hey ${esc(first)}` : "Hey there";
  const body =
    p(`<strong>${hello} &#128075;</strong>`) +
    p("<strong>Thank you for registering with gabis.</strong> You signed up early, and we do not take that lightly.") +
    p("Here is where things stand: <strong>our registrations are complete, and we will start the services very soon.</strong>") +
    p("gabis is being built so you can hold naira, shillings, cedis and dollars in one account, get paid by clients anywhere, and let your invoices follow up on themselves, without anyone converting your money at a rate you never saw.") +
    p("You do not need to do anything right now. We will email you the moment your account is ready to use.") +
    p("In the meantime, if you have a question or an idea, just reply to this email. A person reads every reply.") +
    button(SITE, "VISIT GABIS") +
    p("Best regards,<br>The gabis team");
  const footerNote = `You are receiving this because you registered with gabis. <a href="${unsub}" style="color:#6b6660">Unsubscribe</a>.`;
  const text = plain(
    [
      first ? `Hey ${first},` : "Hey there,",
      "Thank you for registering with gabis. You signed up early, and we do not take that lightly.",
      "Here is where things stand: our registrations are complete, and we will start the services very soon.",
      "gabis is being built so you can hold naira, shillings, cedis and dollars in one account, get paid by clients anywhere, and let your invoices follow up on themselves, without anyone converting your money at a rate you never saw.",
      "You do not need to do anything right now. We will email you the moment your account is ready to use.",
      "In the meantime, if you have a question or an idea, just reply to this email. A person reads every reply.",
      `Visit gabis: ${SITE}`,
      "Best regards,\nThe gabis team",
    ],
    `You are receiving this because you registered with gabis. Unsubscribe: ${unsub}`,
  );
  return { html: layout({ siteUrl: SITE, banner: "update", body, footerNote }), text, unsub };
}

async function send(batch: Recipient[]) {
  const key = process.env.RESEND_API_KEY;
  if (!key) throw new Error("RESEND_API_KEY is not set");
  const res = await fetch("https://api.resend.com/emails/batch", {
    method: "POST",
    headers: { authorization: `Bearer ${key}`, "content-type": "application/json" },
    body: JSON.stringify(
      batch.map((r) => {
        const m = build(r);
        return {
          from: FROM,
          to: [r.email],
          reply_to: "hello@gabispay.com",
          subject: SUBJECT,
          html: m.html,
          text: m.text,
          headers: { "List-Unsubscribe": `<${m.unsub}>` },
        };
      }),
    ),
  });
  const body = await res.text();
  if (!res.ok) throw new Error(`Resend ${res.status}: ${body}`);
  return body;
}

const args = process.argv.slice(2);
const flag = (n: string) => args.indexOf(n);
const val = (n: string) => args[flag(n) + 1];
const sample: Recipient = { email: "preview@example.com", name: "Raphael", token: "preview" };

if (flag("--html") >= 0) {
  console.log(build(sample).html);
} else if (flag("--preview") >= 0) {
  const to = val("--preview");
  const token = process.env.PREVIEW_TOKEN ?? "preview";
  const out = await send([{ email: to, name: process.env.PREVIEW_NAME ?? "Raphael", token }]);
  console.log("preview sent to", to, out);
} else if (flag("--list") >= 0 || flag("--send") >= 0) {
  const sending = flag("--send") >= 0;
  const file = val(sending ? "--send" : "--list");
  const all = JSON.parse(readFileSync(file, "utf8")) as Recipient[];
  const seen = new Set<string>();
  const list = all.filter((r) => {
    const e = r.email.trim().toLowerCase();
    if (seen.has(e) || !/^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/.test(e)) return false;
    seen.add(e);
    r.email = e;
    return true;
  });
  const max = Number(val("--max") ?? 90);
  console.log(`${list.length} unique valid recipients (${all.length - list.length} dropped as duplicate or invalid).`);
  if (!sending) {
    list.slice(0, 20).forEach((r) => console.log(" ", r.email, r.name ? `(${r.name})` : ""));
    if (list.length > 20) console.log(`  ... and ${list.length - 20} more`);
  } else {
    const todo = list.slice(0, max);
    console.log(`Sending ${todo.length} now${list.length > todo.length ? `; ${list.length - todo.length} left for another run` : ""}.`);
    for (let i = 0; i < todo.length; i += 100) {
      console.log("batch", i / 100 + 1, await send(todo.slice(i, i + 100)));
    }
  }
} else {
  console.log("Use --html, --preview <email>, --list <file> or --send <file>.");
}
