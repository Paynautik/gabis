import {
  accountError,
  configured,
  isKind,
  isPhone,
  isPlanService,
  LIMITS,
  mapPay,
  mode,
  newRequestId,
  REQUEST_ID,
  serviceIdFor,
  vtGet,
  vtPost,
  type Env,
  type Kind,
  type PayResult,
} from "./vtpass.ts";

export interface Deps {
  fetch: typeof fetch;
  now: () => number;
  /** The signed-in user's id, or null. */
  verify: (authorization: string | null) => Promise<string | null>;
}

function json(status: number, body: unknown): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "content-type": "application/json", "cache-control": "no-store" },
  });
}

async function readBody(request: Request): Promise<Record<string, unknown> | null> {
  try {
    const body = await request.json();
    return body && typeof body === "object" ? (body as Record<string, unknown>) : null;
  } catch {
    return null;
  }
}

const str = (v: unknown) => (typeof v === "string" ? v.trim() : "");

/**
 * POST /api/bills/pay
 *
 * {kind, provider, account, phone, amount?, planCode?, requestId}
 *
 * The one rule that matters here: an answer of "failed" is only ever given
 * when VTpass said so. If the call itself times out or errors, the payment
 * may still have gone through, so the answer is "pending" and the app asks
 * again with the same requestId rather than paying twice.
 */
async function pay(request: Request, env: Env, deps: Deps): Promise<Response> {
  const body = await readBody(request);
  if (!body) return json(400, { error: "bad_request" });

  const kind = body.kind;
  if (!isKind(kind)) return json(400, { error: "bad_kind" });
  const provider = str(body.provider);
  const serviceId = serviceIdFor(kind, provider);
  if (!serviceId) return json(400, { error: "bad_provider" });

  const account = str(body.account).replace(/[\s-]/g, "");
  const accErr = accountError(kind, account);
  if (accErr) return json(400, { error: accErr });

  const phone = str(body.phone).replace(/[\s-]/g, "") || (kind === "airtime" || kind === "data" ? account : "");
  if (!isPhone(phone)) return json(400, { error: "invalid_phone" });

  let requestId = str(body.requestId);
  if (requestId && !REQUEST_ID.test(requestId)) return json(400, { error: "bad_request_id" });
  if (!requestId) requestId = newRequestId(deps.now());

  const limits = LIMITS[kind as Kind];
  const planCode = str(body.planCode);
  let amount = typeof body.amount === "number" ? Math.round(body.amount) : NaN;

  const payload: Record<string, unknown> = {
    request_id: requestId,
    serviceID: serviceId,
    billersCode: account,
    phone,
  };

  if (kind === "airtime") {
    delete payload.billersCode;
    payload.phone = account;
  }
  if (kind === "data") {
    if (!planCode) return json(400, { error: "plan_required" });
    payload.variation_code = planCode;
  }
  if (kind === "electricity") payload.variation_code = "prepaid";
  if (kind === "cable") {
    if (!planCode) return json(400, { error: "plan_required" });
    payload.variation_code = planCode;
    payload.subscription_type = "change";
  }

  // Data and TV are priced by the plan, and the app tells us the price it
  // showed. Airtime and electricity are priced by what the person typed.
  if (!Number.isFinite(amount) || amount < limits.min) return json(400, { error: "amount_too_small", min: limits.min });
  if (amount > limits.max) return json(400, { error: "amount_too_large", max: limits.max });
  payload.amount = amount;

  let result: PayResult;
  try {
    const raw = await vtPost(env, "pay", payload, deps.fetch);
    result = mapPay(raw, requestId);
  } catch {
    result = {
      status: "pending",
      reference: requestId,
      message: "We could not confirm this payment yet. Check its status before trying again.",
    };
  }
  return json(200, result);
}

/** POST /api/bills/status {requestId} */
async function status(request: Request, env: Env, deps: Deps): Promise<Response> {
  const body = await readBody(request);
  const requestId = str(body?.requestId);
  if (!REQUEST_ID.test(requestId)) return json(400, { error: "bad_request_id" });
  try {
    const raw = await vtPost(env, "requery", { request_id: requestId }, deps.fetch);
    return json(200, mapPay(raw, requestId));
  } catch {
    return json(200, {
      status: "pending",
      reference: requestId,
      message: "Still checking.",
    } satisfies PayResult);
  }
}

/** POST /api/bills/verify {kind, provider, account} — who does this meter or card belong to? */
async function verify(request: Request, env: Env, deps: Deps): Promise<Response> {
  const body = await readBody(request);
  if (!body) return json(400, { error: "bad_request" });
  const kind = body.kind;
  if (kind !== "electricity" && kind !== "cable") return json(400, { error: "bad_kind" });
  const serviceId = serviceIdFor(kind, str(body.provider));
  if (!serviceId) return json(400, { error: "bad_provider" });
  const account = str(body.account).replace(/[\s-]/g, "");
  const accErr = accountError(kind, account);
  if (accErr) return json(400, { error: accErr });

  try {
    const payload: Record<string, unknown> = { billersCode: account, serviceID: serviceId };
    if (kind === "electricity") payload.type = "prepaid";
    const raw = await vtPost(env, "merchant-verify", payload, deps.fetch);
    const content = raw?.content ?? {};
    const valid = String(raw?.code) === "000" && !content.error && !content.WrongBillersCode;
    return json(200, {
      valid,
      name: valid ? String(content.Customer_Name ?? "").trim() || undefined : undefined,
      minAmount: valid && content.Min_Purchase_Amount ? Number(content.Min_Purchase_Amount) : undefined,
    });
  } catch {
    // Not knowing is not the same as invalid: let the person go on.
    return json(200, { valid: null });
  }
}

/** GET /api/bills/variations?serviceID=mtn-data — plans and bouquets with prices. */
async function variations(url: URL, env: Env, deps: Deps): Promise<Response> {
  const serviceId = url.searchParams.get("serviceID") ?? "";
  if (!isPlanService(serviceId)) return json(400, { error: "bad_service" });
  try {
    const raw = await vtGet(env, "service-variations", { serviceID: serviceId }, deps.fetch);
    const list: any[] = raw?.content?.variations ?? raw?.content?.varations ?? [];
    const plans = list
      .map((v) => ({
        code: String(v.variation_code ?? ""),
        name: String(v.name ?? ""),
        amount: Number(v.variation_amount),
      }))
      .filter((p) => p.code && p.name && Number.isFinite(p.amount) && p.amount > 0);
    return json(200, { plans });
  } catch {
    return json(502, { error: "unavailable" });
  }
}

export async function handleBills(request: Request, env: Env, deps: Deps): Promise<Response> {
  const url = new URL(request.url);
  const action = url.pathname.replace(/^\/api\/bills\/?/, "").replace(/\/+$/, "");

  // Whether bill payments are switched on. Nothing secret, no sign-in needed.
  if (action === "config" && request.method === "GET") {
    return json(200, { enabled: configured(env), mode: mode(env) });
  }

  if (!configured(env)) return json(503, { error: "not_configured" });
  if (!(await deps.verify(request.headers.get("authorization")))) {
    return json(401, { error: "unauthorized" });
  }

  if (action === "variations" && request.method === "GET") return variations(url, env, deps);
  if (request.method !== "POST") return json(405, { error: "method_not_allowed" });
  if (action === "pay") return pay(request, env, deps);
  if (action === "status") return status(request, env, deps);
  if (action === "verify") return verify(request, env, deps);
  return json(404, { error: "not_found" });
}
