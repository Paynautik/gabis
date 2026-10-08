import { z } from "zod";

/**
 * Drafts an invoice from a sentence a business owner would actually say:
 * "bill Sarah 150k for brand design, net 14".
 *
 * The key lives here rather than in the app. A Flutter web build ships its
 * --dart-define values inside the JavaScript bundle, so an API key put there
 * is readable by anyone who opens the site.
 */

interface Env {
  /** Groq's free tier, if a key is set. Llama, and quick. */
  GROQ_API_KEY?: string;
  /** Cloudflare's own inference, bound to this Pages project — no key at all. */
  AI?: { run: (model: string, input: unknown) => Promise<any> };
}

const InvoiceDraft = z.object({
  client: z.string().describe("Who is being billed, as a name"),
  amount: z
    .number()
    .describe("The amount in major units. 150k means 150000, 2.5m means 2500000"),
  currency: z
    .string()
    .describe("ISO code. NGN unless the text clearly says otherwise"),
  description: z.string().describe("What the invoice is for, one short line"),
  phone: z
    .string()
    .describe(
      "The client's phone number exactly as written, or an empty string when the text has none",
    ),
  due_in_days: z
    .number()
    .describe("Payment terms in days. 30 when the text does not say"),
  /** So the app can show what it could not work out rather than inventing it. */
  missing: z
    .array(z.string())
    .describe("Fields the text did not contain, from: client, amount, description"),
});

const SYSTEM = `You turn a business owner's sentence into one invoice draft.

Rules:
- Nigerian shorthand is common: "150k" is 150000, "2.5m" is 2500000, "₦" is NGN.
- "net 14", "14 days", "two weeks" all set due_in_days.
- Never invent a client name or an amount that is not in the text. If one is
  absent, put a sensible placeholder in the field and name it in "missing".
- description is what the work was, not a sentence about invoicing.
- phone is copied verbatim when present, and left empty otherwise. Never invent
  a number, and never treat an amount as one.
- The draft is reviewed by a person before it is sent, so prefer leaving a
  field in "missing" over guessing.`;

/**
 * Two ways to read a sentence, tried in order.
 *
 * Groq's Llama is nearly free and needs a key. Cloudflare's own inference needs
 * neither — it is bound to this Pages project — so drafting works on a fresh
 * deployment with nothing configured at all, which is the point of having it
 * last rather than not at all. And behind both the app still has its own
 * parser, so a sentence is never simply refused.
 */
export const onRequestPost: PagesFunction<Env> = async ({ request, env }) => {
  let prompt: string;
  try {
    const body = (await request.json()) as { prompt?: unknown };
    prompt = typeof body.prompt === "string" ? body.prompt.trim() : "";
  } catch {
    return json({ error: "bad_request" }, 400);
  }

  if (prompt.length < 3) return json({ error: "bad_request" }, 400);
  // A sentence, not a pasted document: this endpoint is not a general proxy.
  if (prompt.length > 600) return json({ error: "too_long" }, 413);

  // Each rung is tried only if the one above it is unavailable or fails; a
  // draft is a draft, and a slightly worse one beats making the owner type.
  if (env.GROQ_API_KEY) {
    // The small model first because it is quick and this is extraction, not
    // reasoning; the larger one only when the small one comes back unusable.
    for (const model of ["llama-3.1-8b-instant", "llama-3.3-70b-versatile"]) {
      const drafted = await withGroq(env.GROQ_API_KEY, model, prompt);
      if (drafted) return json(drafted);
    }
  }

  if (env.AI) {
    for (const model of [
      "@cf/meta/llama-3.1-8b-instruct",
      "@cf/meta/llama-3.3-70b-instruct-fp8-fast",
    ]) {
      const drafted = await withWorkersAi(env.AI, model, prompt);
      if (drafted) return json(drafted);
    }
  }

  // Nothing configured and nothing bound: the app's own parser takes it. The
  // reply says which rungs existed, because "not configured" on its own sends
  // whoever deployed this looking in the wrong place.
  return json(
    {
      error: "not_configured",
      available: {
        groq: Boolean(env.GROQ_API_KEY),
        workersAi: Boolean(env.AI),
      },
      detail: lastFailure,
    },
    503,
  );
};

/**
 * The same job through an OpenAI-shaped API, which is what Groq speaks.
 *
 * Llama will not always honour a schema, so the reply is parsed and checked
 * against the same zod shape the draft must fit. A draft that does not fit is
 * discarded rather than shown: a wrong amount in a money field is worse than
 * an empty one.
 */
async function withGroq(apiKey: string, model: string, prompt: string) {
  try {
    const response = await fetch(
      "https://api.groq.com/openai/v1/chat/completions",
      {
        method: "POST",
        headers: {
          authorization: `Bearer ${apiKey}`,
          "content-type": "application/json",
        },
        body: JSON.stringify({
          model,
          temperature: 0,
          response_format: { type: "json_object" },
          messages: [
            { role: "system", content: `${SYSTEM}\n\n${SHAPE}` },
            { role: "user", content: prompt },
          ],
        }),
      },
    );
    if (!response.ok) return null;

    const body = (await response.json()) as any;
    return validate(body?.choices?.[0]?.message?.content);
  } catch {
    return null;
  }
}

/** Cloudflare's own inference: same models, no key, billed to the account. */
async function withWorkersAi(
  ai: NonNullable<Env["AI"]>,
  model: string,
  prompt: string,
) {
  try {
    const response = await ai.run(model, {
      temperature: 0,
      max_tokens: 400,
      messages: [
        { role: "system", content: `${SYSTEM}\n\n${SHAPE}` },
        { role: "user", content: prompt },
      ],
    });

    // Workers AI has more than one reply shape across models, so take the
    // first thing that is text rather than assuming one of them.
    const text =
      typeof response === "string"
        ? response
        : typeof response?.response === "string"
          ? response.response
          : typeof response?.result?.response === "string"
            ? response.result.response
            : typeof response?.choices?.[0]?.message?.content === "string"
              ? response.choices[0].message.content
              : null;

    if (text === null) {
      lastFailure = `${model} replied in a shape with no text in it`;
      return null;
    }

    return validate(text);
  } catch (error) {
    lastFailure = `${model}: ${error instanceof Error ? error.message : String(error)}`;
    return null;
  }
}

/**
 * What a smaller model gets wrong in ways that cost money.
 *
 * Llama answers "due_in_days": 0 for a sentence that says nothing about
 * terms, which would make every such invoice due the moment it is sent, and
 * overdue the next morning. Silence about terms means the default, not today.
 * It also names fields in "missing" that were never on the list, which shows
 * the owner a warning about a field they cannot see.
 */
function tidy(draft: {
  due_in_days: number;
  missing: string[];
  [key: string]: unknown;
}) {
  return {
    ...draft,
    due_in_days:
      Number.isFinite(draft.due_in_days) && draft.due_in_days >= 1
        ? Math.round(draft.due_in_days)
        : 30,
    missing: draft.missing.filter((field) =>
      ["client", "amount", "description"].includes(field.toLowerCase()),
    ),
  };
}

/**
 * Why the last rung gave up, reported when every rung has. Not logged and
 * thrown away: whoever deployed this needs to know the difference between "no
 * model is configured" and "the model refused".
 */
let lastFailure: string | null = null;

/** The shape the two Llama paths are told to produce, since they have no schema API. */
const SHAPE = `Reply with one JSON object and nothing else, in this shape:
{"client": string, "amount": number, "currency": string, "description": string,
 "phone": string, "due_in_days": number, "missing": string[]}`;

/**
 * A model's word is not taken for it. The reply has to parse, and it has to
 * fit the same shape the draft must have, or it is thrown away.
 */
function validate(raw: unknown) {
  if (typeof raw !== "string") {
    lastFailure = `not text: ${typeof raw}`;
    return null;
  }

  // Small models like to wrap JSON in prose or a fenced block.
  const start = raw.indexOf("{");
  const end = raw.lastIndexOf("}");
  if (start === -1 || end <= start) {
    lastFailure = "the model replied with no JSON in it";
    return null;
  }

  try {
    const parsed = InvoiceDraft.safeParse(JSON.parse(raw.slice(start, end + 1)));
    if (!parsed.success) {
      lastFailure = `the model's reply did not fit the shape: ${parsed.error.issues
        .map((i) => i.path.join('.'))
        .join(', ')
        .slice(0, 120)}`;
      return null;
    }
    return tidy(parsed.data);
  } catch (error) {
    lastFailure = `unreadable json: ${error instanceof Error ? error.message : ''}`;
    return null;
  }
}

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "content-type": "application/json" },
  });
}
