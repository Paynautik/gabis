/**
 * Verifying a Firebase ID token, so the app can ask this worker for things
 * without a second set of credentials to hand out.
 *
 * The app already signs the user in; this checks that signature against
 * Google's published keys and hands back the uid. Anything the worker then
 * writes is written under that uid and nowhere else.
 */

const CERTS =
  'https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com';

let cache: { at: number; keys: Record<string, string> } | null = null;

async function keys(): Promise<Record<string, string>> {
  // Google rotates these daily and the response says how long it may be held.
  if (cache && Date.now() - cache.at < 3600_000) return cache.keys;
  const response = await fetch(CERTS);
  const fetched = (await response.json()) as Record<string, string>;
  cache = { at: Date.now(), keys: fetched };
  return fetched;
}

function base64urlToBytes(value: string): Uint8Array {
  const padded = value.replace(/-/g, '+').replace(/_/g, '/');
  const raw = atob(padded + '='.repeat((4 - (padded.length % 4)) % 4));
  return Uint8Array.from(raw, (c) => c.charCodeAt(0));
}

/** The certificate is PEM; WebCrypto wants the SPKI inside it. */
async function importCert(pem: string): Promise<CryptoKey> {
  const body = pem
    .replace(/-----BEGIN CERTIFICATE-----/, '')
    .replace(/-----END CERTIFICATE-----/, '')
    .replace(/\s+/g, '');
  const der = Uint8Array.from(atob(body), (c) => c.charCodeAt(0));

  // An X.509 certificate is not an SPKI blob, so the public key has to be
  // pulled out of it. The key sits at a fixed tag inside the TBS structure;
  // rather than write an ASN.1 parser, find the RSA SPKI header and take the
  // rest, which is stable for every certificate Google publishes here.
  const marker = [0x30, 0x82];
  for (let i = 0; i < der.length - 15; i++) {
    if (
      der[i] === marker[0] &&
      der[i + 1] === marker[1] &&
      der[i + 4] === 0x30 &&
      der[i + 6] === 0x06 &&
      der[i + 7] === 0x09 &&
      der[i + 8] === 0x2a &&
      der[i + 9] === 0x86 &&
      der[i + 10] === 0x48 &&
      der[i + 11] === 0x86 &&
      der[i + 12] === 0xf7
    ) {
      const length = (der[i + 2] << 8) + der[i + 3] + 4;
      return crypto.subtle.importKey(
        'spki',
        der.slice(i, i + length),
        { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
        false,
        ['verify'],
      );
    }
  }
  throw new Error('no public key in certificate');
}

/** The uid, or null for anything that does not verify. Never throws. */
export async function uidFromIdToken(
  token: string,
  project: string,
): Promise<string | null> {
  try {
    const [rawHeader, rawPayload, rawSignature] = token.split('.');
    if (!rawHeader || !rawPayload || !rawSignature) return null;

    const header = JSON.parse(new TextDecoder().decode(base64urlToBytes(rawHeader)));
    const payload = JSON.parse(new TextDecoder().decode(base64urlToBytes(rawPayload)));

    if (payload.aud !== project) return null;
    if (payload.iss !== `https://securetoken.google.com/${project}`) return null;
    if (typeof payload.sub !== 'string' || !payload.sub) return null;
    if (typeof payload.exp !== 'number' || payload.exp * 1000 < Date.now()) return null;

    const pem = (await keys())[header.kid];
    if (!pem) return null;

    const ok = await crypto.subtle.verify(
      'RSASSA-PKCS1-v1_5',
      await importCert(pem),
      base64urlToBytes(rawSignature),
      new TextEncoder().encode(`${rawHeader}.${rawPayload}`),
    );

    return ok ? payload.sub : null;
  } catch {
    return null;
  }
}
