/**
 * Verifies a Firebase ID token without any SDK: it is a JWT signed with a
 * Google key, and the keys are published. Checking it here means the bills
 * endpoints only answer to someone signed in to gabis.
 */

const JWKS_URL =
  "https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com";

interface Jwk {
  kid: string;
  alg?: string;
  [k: string]: unknown;
}

let cache: { keys: Jwk[]; until: number } | null = null;

function b64urlToBytes(s: string): Uint8Array {
  const pad = "=".repeat((4 - (s.length % 4)) % 4);
  const bin = atob((s + pad).replace(/-/g, "+").replace(/_/g, "/"));
  return Uint8Array.from(bin, (c) => c.charCodeAt(0));
}

function decodeJson(part: string): any {
  return JSON.parse(new TextDecoder().decode(b64urlToBytes(part)));
}

async function signingKeys(fetchFn: typeof fetch): Promise<Jwk[]> {
  if (cache && cache.until > Date.now()) return cache.keys;
  const res = await fetchFn(JWKS_URL);
  if (!res.ok) throw new Error("jwks_unavailable");
  const body = (await res.json()) as { keys: Jwk[] };
  const maxAge = /max-age=(\d+)/.exec(res.headers.get("cache-control") ?? "");
  cache = { keys: body.keys, until: Date.now() + (maxAge ? Number(maxAge[1]) : 3600) * 1000 };
  return body.keys;
}

/** The Firebase user id, or null if the token is missing, forged or expired. */
export async function verifyFirebaseToken(
  authorization: string | null,
  projectId: string,
  fetchFn: typeof fetch = fetch,
  nowMs: number = Date.now(),
): Promise<string | null> {
  const token = /^Bearer (.+)$/.exec(authorization ?? "")?.[1];
  if (!token) return null;
  const parts = token.split(".");
  if (parts.length !== 3) return null;

  try {
    const header = decodeJson(parts[0]);
    const claims = decodeJson(parts[1]);
    if (header.alg !== "RS256" || !header.kid) return null;

    const now = Math.floor(nowMs / 1000);
    if (claims.aud !== projectId) return null;
    if (claims.iss !== `https://securetoken.google.com/${projectId}`) return null;
    if (typeof claims.sub !== "string" || claims.sub.length === 0) return null;
    if (typeof claims.exp !== "number" || claims.exp <= now) return null;
    if (typeof claims.iat === "number" && claims.iat > now + 300) return null;

    const jwk = (await signingKeys(fetchFn)).find((k) => k.kid === header.kid);
    if (!jwk) return null;
    const key = await crypto.subtle.importKey(
      "jwk",
      jwk as JsonWebKey,
      { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
      false,
      ["verify"],
    );
    const ok = await crypto.subtle.verify(
      "RSASSA-PKCS1-v1_5",
      key,
      b64urlToBytes(parts[2]),
      new TextEncoder().encode(`${parts[0]}.${parts[1]}`),
    );
    return ok ? claims.sub : null;
  } catch {
    return null;
  }
}
