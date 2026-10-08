/**
 * The site's brand colour, changeable from /admin/brand without a deploy.
 *
 *   GET  /api/theme   public. { color: "#rrggbb" | null }   null = the default blue
 *   POST /api/theme   needs `Authorization: Bearer <ADMIN_TOKEN>`.
 *                     { color: "#rrggbb" } to set it, { reset: true } to go back.
 *
 * The colour is one value in KV (key `theme:brand`), so a change reaches every
 * visitor within about half a minute. Three things keep it from being abused:
 *
 *  - the token is a Pages secret, compared in constant time, and a wrong guess
 *    costs the guesser: eight misses from one visitor in an hour locks them out
 *    for the rest of it;
 *  - only a strict #rrggbb is accepted, so nothing the admin page (or anyone
 *    who got past it) sends can inject CSS or script;
 *  - the colour must keep white text readable on it (contrast at least 4.5:1),
 *    because every button on the site puts white text on this colour.
 */

interface Env {
  SUBSCRIBERS: KVNamespace;
  ADMIN_TOKEN?: string;
}

const KEY = "theme:brand";
const HEX = /^#[0-9a-f]{6}$/i;
const MAX_MISSES_PER_HOUR = 8;

const json = (body: unknown, status = 200, extra: Record<string, string> = {}) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { "content-type": "application/json", ...extra },
  });

/** WCAG relative luminance of a #rrggbb colour. */
function luminance(hex: string): number {
  const lin = (v: number) => {
    const c = v / 255;
    return c <= 0.03928 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4);
  };
  const n = parseInt(hex.slice(1), 16);
  return 0.2126 * lin((n >> 16) & 255) + 0.7152 * lin((n >> 8) & 255) + 0.0722 * lin(n & 255);
}

/** Contrast of white text on the given background colour. */
export function contrastWithWhite(hex: string): number {
  return 1.05 / (luminance(hex) + 0.05);
}

async function sha256(text: string): Promise<Uint8Array> {
  return new Uint8Array(await crypto.subtle.digest("SHA-256", new TextEncoder().encode(text)));
}

/** Compares digests, so the check takes the same time wherever a guess differs. */
async function sameSecret(a: string, b: string): Promise<boolean> {
  const [x, y] = await Promise.all([sha256(a), sha256(b)]);
  let diff = 0;
  for (let i = 0; i < x.length; i++) diff |= x[i] ^ y[i];
  return diff === 0;
}

const hex = (bytes: Uint8Array) => [...bytes].map((b) => b.toString(16).padStart(2, "0")).join("");

export const onRequestGet: PagesFunction<Env> = async ({ env }) => {
  const stored = await env.SUBSCRIBERS.get<{ color: string; updatedAt: string }>(KEY, "json");
  const color = stored && HEX.test(stored.color) ? stored.color.toLowerCase() : null;
  return json({ color, updatedAt: stored?.updatedAt ?? null }, 200, {
    "cache-control": "public, max-age=30",
  });
};

export const onRequestPost: PagesFunction<Env> = async ({ request, env }) => {
  // Not configured: refuse everything rather than accept an empty token.
  if (!env.ADMIN_TOKEN || env.ADMIN_TOKEN.length < 16) return json({ error: "not_configured" }, 503);

  const ip = request.headers.get("cf-connecting-ip") ?? "unknown";
  const missKey = `adm-miss:${hex(await sha256(ip)).slice(0, 24)}:${Math.floor(Date.now() / 3_600_000)}`;
  const misses = parseInt((await env.SUBSCRIBERS.get(missKey)) ?? "0", 10);
  if (misses >= MAX_MISSES_PER_HOUR) return json({ error: "locked" }, 429, { "retry-after": "3600" });

  const auth = request.headers.get("authorization") ?? "";
  const given = auth.startsWith("Bearer ") ? auth.slice(7).trim() : "";
  if (!given || !(await sameSecret(given, env.ADMIN_TOKEN))) {
    await env.SUBSCRIBERS.put(missKey, String(misses + 1), { expirationTtl: 7200 });
    return json({ error: "unauthorized" }, 401);
  }

  let body: { color?: unknown; reset?: unknown };
  try {
    body = (await request.json()) as typeof body;
  } catch {
    return json({ error: "bad_request" }, 400);
  }

  if (body.reset === true) {
    await env.SUBSCRIBERS.delete(KEY);
    return json({ ok: true, color: null });
  }

  const color = typeof body.color === "string" ? body.color.trim().toLowerCase() : "";
  if (!HEX.test(color)) return json({ error: "invalid_color", detail: "Use a colour like #4b45f5." }, 400);
  const ratio = contrastWithWhite(color);
  if (ratio < 4.5) {
    return json(
      {
        error: "too_light",
        detail: `White text would be hard to read on this colour (contrast ${ratio.toFixed(1)}:1, needs 4.5:1). Pick a darker one.`,
        ratio: Number(ratio.toFixed(2)),
      },
      400,
    );
  }

  await env.SUBSCRIBERS.put(KEY, JSON.stringify({ color, updatedAt: new Date().toISOString() }));
  return json({ ok: true, color, ratio: Number(ratio.toFixed(2)) });
};
