/**
 * Mid-market exchange rates for the landing page: the converter and the ticker.
 *
 * Fiat rates come from open.er-api.com (no key, refreshed once a day). Bitcoin
 * comes from CoinGecko's public endpoint. Day-on-day change is real: whenever
 * the fiat feed publishes a new day, the previous day's rates are kept in KV
 * and compared, so the ticker never shows an invented percentage. If there is
 * nothing to compare against yet, the change is simply left out.
 */

interface Env {
  SUBSCRIBERS?: KVNamespace;
}

const CODES = ["NGN", "KES", "GHS", "UGX", "TZS", "GBP", "EUR", "ZAR", "XOF"];

type Snap = { updated: string; rates: Record<string, number> };

export const onRequestGet: PagesFunction<Env> = async ({ request, env, waitUntil }) => {
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
    const updated = data.time_last_update_utc ?? "";

    // Day-on-day change, from the snapshot of the previous publication.
    const changes: Record<string, number> = {};
    if (env.SUBSCRIBERS && updated) {
      const last = await env.SUBSCRIBERS.get<Snap>("rates:last", "json");
      let prev = await env.SUBSCRIBERS.get<Snap>("rates:prev", "json");
      if (!last || last.updated !== updated) {
        if (last) {
          prev = last;
          await env.SUBSCRIBERS.put("rates:prev", JSON.stringify(last));
        }
        await env.SUBSCRIBERS.put("rates:last", JSON.stringify({ updated, rates }));
      }
      if (prev) {
        for (const c of CODES) {
          if (prev.rates[c] && rates[c]) changes[c] = (rates[c] / prev.rates[c] - 1) * 100;
        }
      }
    }

    // Bitcoin is optional: a failure here must not take the fiat rates down.
    let btc: { usd: number; change24h: number | null } | null = null;
    try {
      const cg = await fetch(
        "https://api.coingecko.com/api/v3/simple/price?ids=bitcoin&vs_currencies=usd&include_24hr_change=true",
      );
      if (cg.ok) {
        const j = (await cg.json()) as { bitcoin?: { usd?: number; usd_24h_change?: number } };
        if (typeof j.bitcoin?.usd === "number") {
          btc = {
            usd: j.bitcoin.usd,
            change24h: typeof j.bitcoin.usd_24h_change === "number" ? j.bitcoin.usd_24h_change : null,
          };
        }
      }
    } catch {
      /* leave btc null */
    }

    const res = new Response(JSON.stringify({ base: "USD", rates, changes, btc, updated }), {
      headers: { "content-type": "application/json", "cache-control": "public, max-age=600" },
    });
    waitUntil(cache.put(cacheKey, res.clone()));
    return res;
  } catch {
    return new Response(JSON.stringify({ error: "rates_unavailable" }), {
      status: 502,
      headers: { "content-type": "application/json", "cache-control": "no-store" },
    });
  }
};
