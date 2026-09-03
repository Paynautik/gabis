/**
 * The slice of the Firestore REST API this needs, and the tedious part of it:
 * Firestore's JSON wraps every value in its type, so nothing here can just be
 * read or written as plain JSON.
 */

export type Value = Record<string, unknown>;

export function decode(fields: Record<string, Value> | undefined): any {
  const out: Record<string, unknown> = {};
  for (const [key, value] of Object.entries(fields ?? {})) {
    out[key] = decodeValue(value);
  }
  return out;
}

function decodeValue(value: Value): unknown {
  if ('stringValue' in value) return value.stringValue;
  if ('integerValue' in value) return Number(value.integerValue);
  if ('doubleValue' in value) return value.doubleValue;
  if ('booleanValue' in value) return value.booleanValue;
  if ('nullValue' in value) return null;
  if ('timestampValue' in value) return value.timestampValue;
  if ('mapValue' in value) {
    return decode((value.mapValue as { fields?: Record<string, Value> }).fields);
  }
  if ('arrayValue' in value) {
    const values = (value.arrayValue as { values?: Value[] }).values ?? [];
    return values.map(decodeValue);
  }
  return null;
}

export function encode(data: Record<string, unknown>): Record<string, Value> {
  const fields: Record<string, Value> = {};
  for (const [key, value] of Object.entries(data)) {
    fields[key] = encodeValue(value);
  }
  return fields;
}

function encodeValue(value: unknown): Value {
  if (value === null || value === undefined) return { nullValue: null };
  if (typeof value === 'string') return { stringValue: value };
  if (typeof value === 'boolean') return { booleanValue: value };
  if (typeof value === 'number') {
    return Number.isInteger(value)
      ? { integerValue: String(value) }
      : { doubleValue: value };
  }
  if (Array.isArray(value)) {
    return { arrayValue: { values: value.map(encodeValue) } };
  }
  return { mapValue: { fields: encode(value as Record<string, unknown>) } };
}

export class Firestore {
  readonly base: string;
  readonly token: string;

  constructor(token: string, project: string, database = '(default)') {
    this.token = token;
    this.base = `https://firestore.googleapis.com/v1/projects/${project}/databases/${encodeURIComponent(database)}/documents`;
  }

  private headers() {
    return {
      authorization: `Bearer ${this.token}`,
      'content-type': 'application/json',
    };
  }

  /** Runs a structured query under `parent` ('' for the database root). */
  async query(parent: string, structuredQuery: unknown): Promise<
    { name: string; fields?: Record<string, Value> }[]
  > {
    const response = await fetch(`${this.base}${parent}:runQuery`, {
      method: 'POST',
      headers: this.headers(),
      body: JSON.stringify({ structuredQuery }),
    });
    if (!response.ok) {
      throw new Error(`query failed: ${response.status} ${await response.text()}`);
    }
    const rows = (await response.json()) as { document?: any }[];
    return rows.filter((r) => r.document).map((r) => r.document);
  }

  async createDocument(
    collectionPath: string,
    data: Record<string, unknown>,
  ): Promise<void> {
    const response = await fetch(`${this.base}/${collectionPath}`, {
      method: 'POST',
      headers: this.headers(),
      body: JSON.stringify({ fields: encode(data) }),
    });
    if (!response.ok) {
      throw new Error(`write failed: ${response.status} ${await response.text()}`);
    }
  }

  /** Patches named fields, leaving the rest of the document alone. */
  async patch(
    documentPath: string,
    data: Record<string, unknown>,
  ): Promise<void> {
    const mask = Object.keys(data)
      .map((f) => `updateMask.fieldPaths=${encodeURIComponent(f)}`)
      .join('&');
    const response = await fetch(`${this.base}/${documentPath}?${mask}`, {
      method: 'PATCH',
      headers: this.headers(),
      body: JSON.stringify({ fields: encode(data) }),
    });
    if (!response.ok) {
      throw new Error(`patch failed: ${response.status} ${await response.text()}`);
    }
  }
}

/** users/{uid}/gabis/collections → the uid, for building paths under it. */
export function uidOf(documentName: string): string | null {
  const match = documentName.match(/\/documents\/users\/([^/]+)\//);
  return match ? match[1] : null;
}
