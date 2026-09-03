/**
 * An access token for the Firestore REST API, signed here.
 *
 * Cloud Functions would have handed us credentials for free, but scheduled
 * functions need the project on Blaze and Firestore itself does not. So the
 * schedule lives on Cloudflare — where gabis already hosts the site, and where
 * cron triggers cost nothing — and talks to the same Firestore the app writes
 * to. No second datastore, no copy of the ledger, no Blaze.
 */

interface ServiceAccount {
  email: string;
  privateKey: string;
}

function base64url(bytes: Uint8Array | string): string {
  const raw =
    typeof bytes === 'string'
      ? bytes
      : String.fromCharCode(...Array.from(bytes));
  return btoa(raw).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
}

/** PEM out, WebCrypto key in. */
async function importKey(pem: string): Promise<CryptoKey> {
  const body = pem
    .replace(/-----BEGIN PRIVATE KEY-----/, '')
    .replace(/-----END PRIVATE KEY-----/, '')
    .replace(/\s+/g, '');
  const der = Uint8Array.from(atob(body), (c) => c.charCodeAt(0));
  return crypto.subtle.importKey(
    'pkcs8',
    der,
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign'],
  );
}

/**
 * Tokens last an hour; this asks for a fresh one per pass rather than caching,
 * because the pass runs once a day and a cached token in a Worker that may be
 * evicted at any moment is complexity bought for nothing.
 */
export async function accessToken(account: ServiceAccount): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const claim = {
    iss: account.email,
    scope: 'https://www.googleapis.com/auth/datastore',
    aud: 'https://oauth2.googleapis.com/token',
    iat: now,
    exp: now + 3600,
  };

  const unsigned =
    base64url(JSON.stringify({ alg: 'RS256', typ: 'JWT' })) +
    '.' +
    base64url(JSON.stringify(claim));

  const signature = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5',
    await importKey(account.privateKey),
    new TextEncoder().encode(unsigned),
  );

  const response = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'content-type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion: unsigned + '.' + base64url(new Uint8Array(signature)),
    }),
  });

  if (!response.ok) {
    throw new Error(`token request failed: ${response.status} ${await response.text()}`);
  }

  return ((await response.json()) as { access_token: string }).access_token;
}
