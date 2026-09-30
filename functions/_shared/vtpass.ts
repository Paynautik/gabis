/**
 * Bill payments through VTpass (https://vtpass.com/documentation/).
 *
 * The keys live here, on the server. A Flutter web build ships every value it
 * is given inside the JavaScript bundle, so a key put in the app is a key
 * handed to anyone who opens the site.
 *
 * Everything the app may ask for is checked against tables below before a
 * request leaves: which services exist, what an account number looks like,
 * and how much one payment may be. VTpass is only ever called for something
 * on those lists.
 */

export type Kind = "airtime" | "data" | "electricity" | "cable";

export interface Env {
  VTPASS_API_KEY?: string;
  VTPASS_PUBLIC_KEY?: string;
  VTPASS_SECRET_KEY?: string;
  /** "live" spends real money. Anything else, or nothing, is the sandbox. */
  BILLS_MODE?: string;
  FIREBASE_PROJECT_ID?: string;
}

const NETWORKS: Record<string, string> = {
  mtn: "mtn",
  airtel: "airtel",
  glo: "glo",
  "9mobile": "etisalat",
};

const DISCOS: Record<string, string> = {
  "ikeja electric": "ikeja-electric",
  "eko electric": "eko-electric",
  "abuja electric": "abuja-electric",
  "ibadan electric": "ibadan-electric",
};

const TV: Record<string, string> = {
  dstv: "dstv",
  gotv: "gotv",
  startimes: "startimes",
  showmax: "showmax",
};

/** Naira, per payment. Smaller than the app's own limits on purpose. */
export const LIMITS: Record<Kind, { min: number; max: number }> = {
  airtime: { min: 50, max: 20000 },
  data: { min: 50, max: 60000 },
  electricity: { min: 500, max: 100000 },
  cable: { min: 500, max: 60000 },
};

const PHONE = /^0[789][01]\d{8}$/;
const METER = /^(\d{11}|\d{13})$/;
const SMARTCARD = /^\d{10,11}$/;

export function isKind(v: unknown): v is Kind {
  return v === "airtime" || v === "data" || v === "electricity" || v === "cable";
}

/** The VTpass serviceID for what the app calls a network, company or provider. */
export function serviceIdFor(kind: Kind, provider: string): string | null {
  const p = provider.trim().toLowerCase();
  switch (kind) {
    case "airtime":
      return NETWORKS[p] ?? null;
    case "data":
      return NETWORKS[p] ? `${NETWORKS[p]}-data` : null;
    case "electricity":
      return DISCOS[p] ?? null;
    case "cable":
      return TV[p] ?? null;
  }
}

/** Services whose price list (data plans, TV bouquets) the app may ask for. */
export function isPlanService(serviceId: string): boolean {
  return (
    Object.values(NETWORKS).some((n) => `${n}-data` === serviceId) ||
    Object.values(TV).includes(serviceId)
  );
}

export function accountError(kind: Kind, account: string): string | null {
  if (kind === "airtime" || kind === "data") {
    return PHONE.test(account) ? null : "invalid_phone";
  }
  if (kind === "electricity") return METER.test(account) ? null : "invalid_meter";
  return SMARTCARD.test(account) ? null : "invalid_smartcard";
}

export function isPhone(v: unknown): v is string {
  return typeof v === "string" && PHONE.test(v);
}

export function configured(env: Env): boolean {
  return Boolean(env.VTPASS_API_KEY && env.VTPASS_PUBLIC_KEY && env.VTPASS_SECRET_KEY);
}

export function mode(env: Env): "live" | "sandbox" {
  return env.BILLS_MODE === "live" ? "live" : "sandbox";
}

export function baseUrl(env: Env): string {
  return mode(env) === "live" ? "https://vtpass.com/api" : "https://sandbox.vtpass.com/api";
}

/** YYYYMMDDHHmm in Lagos time, which VTpass wants at the front of a request id. */
export function lagosStamp(nowMs: number): string {
  const parts = new Intl.DateTimeFormat("en-GB", {
    timeZone: "Africa/Lagos",
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
    hour: "2-digit",
    minute: "2-digit",
    hourCycle: "h23",
  }).formatToParts(new Date(nowMs));
  const get = (t: string) => parts.find((p) => p.type === t)!.value;
  return `${get("year")}${get("month")}${get("day")}${get("hour")}${get("minute")}`;
}

export function newRequestId(nowMs: number): string {
  const bytes = crypto.getRandomValues(new Uint8Array(6));
  const tail = Array.from(bytes, (b) => b.toString(16).padStart(2, "0")).join("");
  return `${lagosStamp(nowMs)}${tail}`;
}

export const REQUEST_ID = /^\d{12}[A-Za-z0-9]{6,32}$/;

export async function vtGet(
  env: Env,
  path: string,
  params: Record<string, string>,
  fetchFn: typeof fetch,
): Promise<any> {
  const url = new URL(`${baseUrl(env)}/${path}`);
  for (const [k, v] of Object.entries(params)) url.searchParams.set(k, v);
  const res = await fetchFn(url.toString(), {
    headers: { "api-key": env.VTPASS_API_KEY!, "public-key": env.VTPASS_PUBLIC_KEY! },
  });
  return res.json();
}

export async function vtPost(
  env: Env,
  path: string,
  body: Record<string, unknown>,
  fetchFn: typeof fetch,
): Promise<any> {
  const res = await fetchFn(`${baseUrl(env)}/${path}`, {
    method: "POST",
    headers: {
      "api-key": env.VTPASS_API_KEY!,
      "secret-key": env.VTPASS_SECRET_KEY!,
      "content-type": "application/json",
    },
    body: JSON.stringify(body),
  });
  return res.json();
}

export interface PayResult {
  status: "delivered" | "pending" | "failed";
  reference: string;
  providerReference?: string;
  message: string;
  token?: string;
  units?: string;
}

/**
 * VTpass answers 000 for "the request was understood", and puts the real
 * outcome in the transaction status. 099 means it is still being processed.
 * Anything not clearly delivered or clearly failed is treated as pending: the
 * money may have moved, so the app must look again rather than assume.
 */
export function mapPay(raw: any, reference: string): PayResult {
  const code = String(raw?.code ?? "");
  const txn = raw?.content?.transactions ?? {};
  const state = String(txn.status ?? "").toLowerCase();
  const providerReference = txn.transactionId ? String(txn.transactionId) : undefined;
  const message = String(raw?.response_description ?? "");

  const tokenRaw = raw?.mainToken ?? raw?.purchased_code ?? raw?.token ?? raw?.content?.token;
  const token = tokenRaw ? String(tokenRaw).replace(/^\s*token\s*:\s*/i, "").trim() : undefined;
  const units = raw?.mainTokenUnit ?? raw?.units ?? raw?.content?.units;

  let status: PayResult["status"];
  if (code === "000" && state === "delivered") status = "delivered";
  else if (state === "failed" || state === "reversed") status = "failed";
  else if (code === "099" || state === "pending" || state === "initiated" || code === "000") status = "pending";
  else status = "failed";

  return {
    status,
    reference,
    providerReference,
    message,
    token: status === "delivered" && token ? token : undefined,
    units: status === "delivered" && units ? String(units) : undefined,
  };
}
