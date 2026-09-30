import assert from "node:assert/strict";
import { describe, it } from "node:test";
import { handleBills, type Deps } from "../../functions/_shared/bills.ts";
import { verifyFirebaseToken } from "../../functions/_shared/firebase-auth.ts";
import { lagosStamp, mapPay, serviceIdFor } from "../../functions/_shared/vtpass.ts";

const ENV = { VTPASS_API_KEY: "ak", VTPASS_PUBLIC_KEY: "pk", VTPASS_SECRET_KEY: "sk" };
const REQ_ID = "202609301415abcdef123456";

interface Call {
  url: string;
  init?: RequestInit;
}

function deps(reply: (call: Call) => unknown, opts: { user?: string | null; fail?: boolean } = {}) {
  const calls: Call[] = [];
  const d: Deps = {
    fetch: (async (url: string, init?: RequestInit) => {
      calls.push({ url: String(url), init });
      if (opts.fail) throw new Error("network");
      return new Response(JSON.stringify(reply({ url: String(url), init })), { status: 200 });
    }) as typeof fetch,
    now: () => Date.UTC(2026, 8, 30, 13, 15), // 14:15 in Lagos
    verify: async () => (opts.user === undefined ? "uid1" : opts.user),
  };
  return { d, calls };
}

const post = (path: string, body: unknown) =>
  new Request(`https://gabispay.com/api/bills/${path}`, {
    method: "POST",
    headers: { authorization: "Bearer t", "content-type": "application/json" },
    body: JSON.stringify(body),
  });

const delivered = {
  code: "000",
  response_description: "TRANSACTION SUCCESSFUL",
  content: { transactions: { status: "delivered", transactionId: "1234" } },
};

describe("access", () => {
  it("config is public and says whether bills are on", async () => {
    const { d } = deps(() => ({}), { user: null });
    const on = await handleBills(new Request("https://gabispay.com/api/bills/config"), ENV, d);
    assert.deepEqual(await on.json(), { enabled: true, mode: "sandbox" });
    const off = await handleBills(new Request("https://gabispay.com/api/bills/config"), {}, d);
    assert.deepEqual(await off.json(), { enabled: false, mode: "sandbox" });
  });

  it("answers 503 until the keys are set", async () => {
    const { d } = deps(() => ({}));
    const res = await handleBills(post("pay", {}), {}, d);
    assert.equal(res.status, 503);
  });

  it("refuses someone who is not signed in", async () => {
    const { d, calls } = deps(() => delivered, { user: null });
    const res = await handleBills(post("pay", { kind: "airtime" }), ENV, d);
    assert.equal(res.status, 401);
    assert.equal(calls.length, 0);
  });

  it("uses the sandbox unless BILLS_MODE is live", async () => {
    const a = deps(() => delivered);
    await handleBills(post("pay", { kind: "airtime", provider: "MTN", account: "08012345678", amount: 100, requestId: REQ_ID }), ENV, a.d);
    assert.match(a.calls[0].url, /^https:\/\/sandbox\.vtpass\.com\/api\/pay$/);
    const b = deps(() => delivered);
    await handleBills(post("pay", { kind: "airtime", provider: "MTN", account: "08012345678", amount: 100, requestId: REQ_ID }), { ...ENV, BILLS_MODE: "live" }, b.d);
    assert.match(b.calls[0].url, /^https:\/\/vtpass\.com\/api\/pay$/);
  });
});

describe("pay", () => {
  it("buys airtime with the secret key and the right service", async () => {
    const { d, calls } = deps(() => delivered);
    const res = await handleBills(post("pay", { kind: "airtime", provider: "9mobile", account: "0803 123 4567", amount: 500, requestId: REQ_ID }), ENV, d);
    const out = (await res.json()) as any;
    assert.equal(out.status, "delivered");
    assert.equal(out.reference, REQ_ID);
    const sent = JSON.parse(String(calls[0].init!.body));
    assert.equal(sent.serviceID, "etisalat");
    assert.equal(sent.phone, "08031234567");
    assert.equal(sent.amount, 500);
    assert.equal(sent.request_id, REQ_ID);
    const headers = calls[0].init!.headers as Record<string, string>;
    assert.equal(headers["secret-key"], "sk");
    assert.equal(headers["api-key"], "ak");
  });

  it("returns the token for a prepaid meter", async () => {
    const { d, calls } = deps(() => ({ ...delivered, purchased_code: "Token : 1234-5678-9012", mainTokenUnit: "12.4" }));
    const res = await handleBills(post("pay", { kind: "electricity", provider: "Eko Electric", account: "1111111111111", phone: "08012345678", amount: 2000, requestId: REQ_ID }), ENV, d);
    const out = (await res.json()) as any;
    assert.equal(out.token, "1234-5678-9012");
    assert.equal(out.units, "12.4");
    const sent = JSON.parse(String(calls[0].init!.body));
    assert.equal(sent.serviceID, "eko-electric");
    assert.equal(sent.variation_code, "prepaid");
    assert.equal(sent.billersCode, "1111111111111");
  });

  it("needs a plan for data and cable, and sends it", async () => {
    const { d, calls } = deps(() => delivered);
    const noPlan = await handleBills(post("pay", { kind: "data", provider: "Glo", account: "08051234567", amount: 100, requestId: REQ_ID }), ENV, d);
    assert.equal(noPlan.status, 400);
    assert.equal(calls.length, 0);
    await handleBills(post("pay", { kind: "cable", provider: "GOtv", account: "7012345678", phone: "08051234567", planCode: "gotv-max", amount: 8500, requestId: REQ_ID }), ENV, d);
    const sent = JSON.parse(String(calls[0].init!.body));
    assert.equal(sent.serviceID, "gotv");
    assert.equal(sent.variation_code, "gotv-max");
    assert.equal(sent.subscription_type, "change");
  });

  it("rejects what should never reach the biller, without calling it", async () => {
    const { d, calls } = deps(() => delivered);
    const cases: Array<[any, string]> = [
      [{ kind: "crypto" }, "bad_kind"],
      [{ kind: "airtime", provider: "Vodafone", account: "08012345678", amount: 100 }, "bad_provider"],
      [{ kind: "airtime", provider: "MTN", account: "12345", amount: 100 }, "invalid_phone"],
      [{ kind: "electricity", provider: "Eko Electric", account: "123", phone: "08012345678", amount: 1000 }, "invalid_meter"],
      [{ kind: "airtime", provider: "MTN", account: "08012345678", amount: 10 }, "amount_too_small"],
      [{ kind: "airtime", provider: "MTN", account: "08012345678", amount: 20001 }, "amount_too_large"],
      [{ kind: "airtime", provider: "MTN", account: "08012345678", amount: 100, requestId: "nope" }, "bad_request_id"],
    ];
    for (const [body, error] of cases) {
      const res = await handleBills(post("pay", body), ENV, d);
      assert.equal(res.status, 400, error);
      assert.equal(((await res.json()) as any).error, error);
    }
    assert.equal(calls.length, 0);
  });

  it("makes a request id in Lagos time when none is given", async () => {
    const { d, calls } = deps(() => delivered);
    await handleBills(post("pay", { kind: "airtime", provider: "MTN", account: "08012345678", amount: 100 }), ENV, d);
    const sent = JSON.parse(String(calls[0].init!.body));
    assert.match(sent.request_id, /^202609301415[0-9a-f]{12}$/);
  });

  it("never says failed when the call itself failed: the money may have moved", async () => {
    const { d } = deps(() => ({}), { fail: true });
    const res = await handleBills(post("pay", { kind: "airtime", provider: "MTN", account: "08012345678", amount: 100, requestId: REQ_ID }), ENV, d);
    const out = (await res.json()) as any;
    assert.equal(out.status, "pending");
    assert.equal(out.reference, REQ_ID);
  });
});

describe("mapping VTpass answers", () => {
  it("delivered, pending, failed", () => {
    assert.equal(mapPay(delivered, "r").status, "delivered");
    assert.equal(mapPay({ code: "099", response_description: "PROCESSING" }, "r").status, "pending");
    assert.equal(mapPay({ code: "000", content: { transactions: { status: "pending" } } }, "r").status, "pending");
    assert.equal(mapPay({ code: "000", content: { transactions: { status: "initiated" } } }, "r").status, "pending");
    assert.equal(mapPay({ code: "016", response_description: "TRANSACTION FAILED" }, "r").status, "failed");
    assert.equal(mapPay({ code: "000", content: { transactions: { status: "reversed" } } }, "r").status, "failed");
  });

  it("only hands out a token for a delivered payment", () => {
    assert.equal(mapPay({ code: "099", purchased_code: "Token : 1" }, "r").token, undefined);
  });

  it("knows the services and the time", () => {
    assert.equal(serviceIdFor("data", "9mobile"), "etisalat-data");
    assert.equal(serviceIdFor("cable", "DSTV"), "dstv");
    assert.equal(serviceIdFor("cable", "unknown"), null);
    assert.equal(lagosStamp(Date.UTC(2026, 11, 31, 23, 5)), "202701010005"); // Lagos is UTC+1
  });
});

describe("status, verify, variations", () => {
  it("re-queries by request id", async () => {
    const { d, calls } = deps(() => delivered);
    const res = await handleBills(post("status", { requestId: REQ_ID }), ENV, d);
    assert.equal(((await res.json()) as any).status, "delivered");
    assert.match(calls[0].url, /\/requery$/);
    assert.equal(JSON.parse(String(calls[0].init!.body)).request_id, REQ_ID);
  });

  it("verify says whose meter it is, or that it is wrong", async () => {
    const ok = deps(() => ({ code: "000", content: { Customer_Name: "ADA OBI", Min_Purchase_Amount: 1000 } }));
    const good = (await (await handleBills(post("verify", { kind: "electricity", provider: "Eko Electric", account: "1111111111111" }), ENV, ok.d)).json()) as any;
    assert.deepEqual(good, { valid: true, name: "ADA OBI", minAmount: 1000 });
    const bad = deps(() => ({ code: "000", content: { WrongBillersCode: true } }));
    const wrong = (await (await handleBills(post("verify", { kind: "cable", provider: "DSTV", account: "1234567890" }), ENV, bad.d)).json()) as any;
    assert.equal(wrong.valid, false);
    const down = deps(() => ({}), { fail: true });
    const unknown = (await (await handleBills(post("verify", { kind: "cable", provider: "DSTV", account: "1234567890" }), ENV, down.d)).json()) as any;
    assert.equal(unknown.valid, null);
  });

  it("lists plans for data and TV only, with prices as numbers", async () => {
    const { d, calls } = deps(() => ({ content: { variations: [{ variation_code: "mtn-1gb", name: "1GB", variation_amount: "500.00" }, { variation_code: "x", name: "", variation_amount: "1" }] } }));
    const res = await handleBills(new Request("https://gabispay.com/api/bills/variations?serviceID=mtn-data", { headers: { authorization: "Bearer t" } }), ENV, d);
    assert.deepEqual(await res.json(), { plans: [{ code: "mtn-1gb", name: "1GB", amount: 500 }] });
    assert.match(calls[0].url, /service-variations\?serviceID=mtn-data$/);
    assert.equal((calls[0].init!.headers as Record<string, string>)["public-key"], "pk");
    const bad = await handleBills(new Request("https://gabispay.com/api/bills/variations?serviceID=../../admin", { headers: { authorization: "Bearer t" } }), ENV, d);
    assert.equal(bad.status, 400);
  });
});

describe("firebase token check", () => {
  const b64 = (o: unknown) => Buffer.from(JSON.stringify(o)).toString("base64url");

  async function setup(claims: Record<string, unknown>, tamper = false) {
    const pair = (await crypto.subtle.generateKey(
      { name: "RSASSA-PKCS1-v1_5", modulusLength: 2048, publicExponent: new Uint8Array([1, 0, 1]), hash: "SHA-256" },
      true,
      ["sign", "verify"],
    )) as CryptoKeyPair;
    const jwk = { ...(await crypto.subtle.exportKey("jwk", pair.publicKey)), kid: `k${Math.random()}` };
    const head = b64({ alg: "RS256", kid: jwk.kid });
    const body = b64(claims);
    const sig = Buffer.from(await crypto.subtle.sign("RSASSA-PKCS1-v1_5", pair.privateKey, new TextEncoder().encode(`${head}.${body}`))).toString("base64url");
    const token = `${head}.${body}.${tamper ? sig.slice(0, -4) + "AAAA" : sig}`;
    const fetchFn = (async () => new Response(JSON.stringify({ keys: [jwk] }), { headers: { "cache-control": "max-age=60" } })) as typeof fetch;
    return { token, fetchFn };
  }

  const now = Date.UTC(2026, 8, 30, 12, 0);
  const good = { aud: "gabis-pay-app", iss: "https://securetoken.google.com/gabis-pay-app", sub: "user-1", iat: now / 1000 - 10, exp: now / 1000 + 3000 };

  it("accepts a good token and returns the user", async () => {
    const { token, fetchFn } = await setup(good);
    assert.equal(await verifyFirebaseToken(`Bearer ${token}`, "gabis-pay-app", fetchFn, now), "user-1");
  });

  it("rejects a forged signature, another project, an expired token, and no token", async () => {
    const forged = await setup(good, true);
    assert.equal(await verifyFirebaseToken(`Bearer ${forged.token}`, "gabis-pay-app", forged.fetchFn, now), null);
    const other = await setup({ ...good, aud: "someone-else" });
    assert.equal(await verifyFirebaseToken(`Bearer ${other.token}`, "gabis-pay-app", other.fetchFn, now), null);
    const old = await setup({ ...good, exp: now / 1000 - 5 });
    assert.equal(await verifyFirebaseToken(`Bearer ${old.token}`, "gabis-pay-app", old.fetchFn, now), null);
    assert.equal(await verifyFirebaseToken(null, "gabis-pay-app", old.fetchFn, now), null);
    assert.equal(await verifyFirebaseToken("Bearer nonsense", "gabis-pay-app", old.fetchFn, now), null);
  });
});
