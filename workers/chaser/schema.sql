-- What the chaser needs to decide whether a reminder may go out, and nothing
-- else. No email, no address, no invoice descriptions: a reminder needs a
-- name, a number, an amount and a date, so that is all this holds.

CREATE TABLE IF NOT EXISTS businesses (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  -- Hashed, never stored raw: the token the app presents when it syncs.
  token_hash TEXT NOT NULL,
  -- Where the money goes, rendered into the reminder's portal link.
  pay_bank TEXT,
  pay_account TEXT,
  pay_name TEXT,
  -- Off until a business turns it on. Nothing goes out for a business that
  -- has not asked for it.
  autonomous INTEGER NOT NULL DEFAULT 0,
  synced_at TEXT
);

CREATE TABLE IF NOT EXISTS debtors (
  business_id TEXT NOT NULL,
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  outstanding REAL NOT NULL,
  currency TEXT NOT NULL DEFAULT 'NGN',
  due_on TEXT NOT NULL,
  -- The lawful basis for holding this number. No basis, no contact.
  consent_basis TEXT,
  do_not_contact INTEGER NOT NULL DEFAULT 0,
  -- The statement link the app built, fragment and all. The worker never
  -- assembles one, so the invoice details never exist on this side.
  portal_link TEXT,
  PRIMARY KEY (business_id, name)
);

CREATE TABLE IF NOT EXISTS attempts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  business_id TEXT NOT NULL,
  debtor_name TEXT NOT NULL,
  placed_at TEXT NOT NULL,
  attempt INTEGER NOT NULL,
  channel TEXT NOT NULL,
  outcome TEXT NOT NULL,
  -- The exact words that went out, so a dispute is settled by the record.
  message TEXT NOT NULL
);

CREATE INDEX IF NOT EXISTS attempts_by_debtor
  ON attempts (business_id, debtor_name, placed_at);
