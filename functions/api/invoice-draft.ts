import Anthropic from "@anthropic-ai/sdk";
import { zodOutputFormat } from "@anthropic-ai/sdk/helpers/zod";
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
  ANTHROPIC_API_KEY?: string;
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

export const onRequestPost: PagesFunction<Env> = async ({ request, env }) => {
  if (!env.ANTHROPIC_API_KEY) {
    // The app falls back to its own parser when drafting is not configured.
    return json({ error: "not_configured" }, 503);
  }

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

  const client = new Anthropic({ apiKey: env.ANTHROPIC_API_KEY });

  try {
    const response = await client.messages.parse({
      model: "claude-opus-5",
      max_tokens: 2000,
      system: SYSTEM,
      // Extraction, not reasoning — low effort keeps it quick and cheap.
      output_config: {
        effort: "low",
        format: zodOutputFormat(InvoiceDraft),
      },
      messages: [{ role: "user", content: prompt }],
    });

    if (response.stop_reason === "refusal" || !response.parsed_output) {
      return json({ error: "no_draft" }, 422);
    }

    return json(response.parsed_output);
  } catch (error) {
    const status =
      error instanceof Anthropic.RateLimitError
        ? 429
        : error instanceof Anthropic.APIStatusError
          ? 502
          : 500;
    return json({ error: "upstream" }, status);
  }
};

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "content-type": "application/json" },
  });
}
