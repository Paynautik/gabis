import { initializeApp, applicationDefault } from 'firebase-admin/app';
import { getFirestore, type Firestore } from 'firebase-admin/firestore';

/**
 * Copies what gabis already wrote in (default) into the `gabis` database.
 *
 * Only `users/{uid}/gabis/**` moves — that is the whole of gabis's footprint,
 * and touching anything else would be reaching into trustos's data.
 *
 * It copies rather than moves. Nothing is deleted from (default) by this
 * script: if the new database turns out wrong, the old copy is still there,
 * and deleting it later is one console operation once you are satisfied.
 *
 * Usage:
 *   GOOGLE_APPLICATION_CREDENTIALS=<service-account.json> \
 *     npx tsx scripts/migrate.ts [--commit]
 *
 * Without --commit it reports what it would copy and writes nothing.
 */

const commit = process.argv.includes('--commit');

initializeApp({ credential: applicationDefault(), projectId: 'paynautic' });

const from = getFirestore('(default)');
const to = getFirestore('gabis');

/** Recurses into subcollections, because gabis keeps attempts under one. */
async function copyDoc(
  source: Firestore,
  target: Firestore,
  path: string,
): Promise<number> {
  const snap = await source.doc(path).get();
  let copied = 0;

  if (snap.exists) {
    if (commit) await target.doc(path).set(snap.data()!);
    copied++;
    console.log(`${commit ? 'copied' : 'would copy'} ${path}`);
  }

  for (const sub of await source.doc(path).listCollections()) {
    for (const child of await sub.listDocuments()) {
      copied += await copyDoc(source, target, child.path);
    }
  }

  return copied;
}

async function main() {
  const users = await from.collection('users').listDocuments();
  let copied = 0;

  for (const user of users) {
    // gabis lives in exactly one subcollection of each user document. The
    // user document itself belongs to whoever created it, so it stays put.
    const gabis = user.collection('gabis');
    for (const doc of await gabis.listDocuments()) {
      copied += await copyDoc(from, to, doc.path);
    }
  }

  console.log(
    commit
      ? `\nDone. ${copied} document(s) copied into the gabis database. Nothing was deleted from (default).`
      : `\n${copied} document(s) would be copied. Re-run with --commit to do it.`,
  );
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
