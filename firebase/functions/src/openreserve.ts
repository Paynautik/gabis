/**
 * ORPay client for gabis.
 *
 * @openreserve/orpay is an ES module; these functions compile to CommonJS on
 * Node 20, which cannot require() an ES module. So it is loaded once with a
 * real dynamic import, which TypeScript would otherwise rewrite to require().
 *
 * The API key only creates, reads and cancels unfunded escrows. It can never
 * move escrowed money: every release, refund or dispute is signed by the
 * buyer, seller or arbiter in ORPay. A stolen key therefore cannot empty
 * anyone's escrow.
 */
type OrpayModule = typeof import('@openreserve/orpay');

const esmImport = new Function('s', 'return import(s)') as (s: string) => Promise<OrpayModule>;

let mod: Promise<OrpayModule> | undefined;
function load() {
  return (mod ??= esmImport('@openreserve/orpay'));
}

export async function orpay() {
  const { ORPay } = await load();
  const apiKey = process.env.ORPAY_API_KEY;
  if (!apiKey) throw new Error('ORPAY_API_KEY is not set');
  return new ORPay({ apiKey, baseUrl: process.env.ORPAY_URL });
}

export async function verifyOrpayWebhook(raw: string, signature: string) {
  const { verifyWebhook } = await load();
  const secret = process.env.ORPAY_WEBHOOK_SECRET;
  if (!secret) throw new Error('ORPAY_WEBHOOK_SECRET is not set');
  return verifyWebhook(raw, signature, secret);
}
