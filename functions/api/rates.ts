/**
 * Mid-market exchange rates for the landing page's converter.
 *
 * Source: open.er-api.com, which needs no key and refreshes once a day, so the
 * page says "updated daily" rather than "live". Answers are cached for ten
 * minutes at Cloudflare's edge so a busy page makes one upstream call, not one
 * per visitor.
 */

const CODES = ["NGN", "KES", "GHS", "UGX", "TZS", "GBP", "EUR", "ZAR", "XOF"];

export const onRequestGet: PagesFunction = async ({ request, waitUntil }) => {
  const cache = caches.default;
  const cacheKey = new Request(new URL("/api/rates", request.url).toString());
  const hit = await cache.match(cacheKey);
  if (hit) return hit;

  try {
    const upstream = await fetch("https://open.er-api.com/v6/latest/USD");
    if (!upstream.ok) throw new Error(String(upstream.status));
    const data = (await upstream.json()) as {
      result?: string;
      rates?: Record<string, number>;
      time_last_update_utc?: string;
    };
    if (data.result !== "success" || !data.rates) throw new Error("bad payload");

    const rates: Record<string, number> = { USD: 1 };
    for (const c of CODES) if (typeof data.rates[c] === "number") rates[c] = data.rates[c];

    const res = new Response(
      JSON.stringify({ base: "USD", rates, updated: data.time_last_update_utc ?? null }),
      {
        headers: {
          "content-type": "application/json",
          "cache-control": "public, max-age=600",
        },
      },
    );
    waitUntil(cache.put(cacheKey, res.clone()));
    return res;
  } catch {
    return new Response(JSON.stringify({ error: "rates_unavailable" }), {
      status: 502,
      headers: { "content-type": "application/json", "cache-control": "no-store" },
    });
  }
};
