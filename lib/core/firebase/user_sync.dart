import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Per-user documents in Firestore, so a balance earned on a phone is there on
/// a laptop. Local storage stays the fast path and the offline fallback; this
/// is the copy that follows the account.
///
/// Everything lives under users/{uid} in the `gabis` database — a second
/// Firestore database in the shared paynautic project, so gabis and trustos no
/// longer run on one set of security rules that either side's deploy could
/// overwrite. The path scoping stays as well: two doors are better than one.
class UserSync {
  /// The database gabis owns. Rules for it are in firestore.gabis.rules and
  /// deploy only to that target.
  ///
  /// It defaults to (default) because that is where the data still is: making
  /// a second database needs the project on Blaze, and a build that pointed at
  /// a database nobody had created yet would quietly stop syncing for everyone
  /// already signed in. Once `gabis` exists and scripts/migrate.ts has run,
  /// build with --dart-define=FIRESTORE_DB=gabis and this becomes true of the
  /// app as well as of the rules.
  static const databaseId =
      String.fromEnvironment('FIRESTORE_DB', defaultValue: '(default)');

  final FirebaseFirestore _db;

  UserSync([FirebaseFirestore? db]) : _db = db ?? _gabisDatabase();

  static FirebaseFirestore _gabisDatabase() {
    try {
      // The plain instance for (default) rather than naming it: the SDK's own
      // path for the default database is well travelled, and there is no
      // reason to find out whether it treats the literal string differently.
      if (databaseId == '(default)') return FirebaseFirestore.instance;

      return FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: databaseId,
      );
    } catch (_) {
      // Firebase never came up; the caller's local storage is the fallback and
      // every method here already tolerates a dead connection.
      return FirebaseFirestore.instance;
    }
  }

  static String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  DocumentReference<Map<String, dynamic>>? _doc(String name) {
    final uid = _uid;
    if (uid == null) return null;
    return _db.collection('users').doc(uid).collection('gabis').doc(name);
  }

  /// Writes are fire-and-forget: a sync failure must never block the UI or
  /// lose the local copy. The result is there for the few callers that have
  /// to tell the user whether it landed — turning on something that acts on
  /// this document without them, say — and is ignored everywhere else.
  Future<bool> put(String name, Map<String, dynamic> data) async {
    final doc = _doc(name);
    if (doc == null) return false;
    try {
      await doc.set({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (_) {
      // Local storage already holds it; the next write will try again.
      return false;
    }
  }

  Future<Map<String, dynamic>?> get(String name) async {
    final doc = _doc(name);
    if (doc == null) return null;
    try {
      final snap = await doc.get();
      return snap.data();
    } catch (_) {
      return null;
    }
  }

  /// Documents in a subcollection of one of this account's documents — the
  /// payments the chaser records, and the attempts it writes down.
  Future<List<Map<String, dynamic>>> list(String name, String sub) async {
    final doc = _doc(name);
    if (doc == null) return const [];
    try {
      final snap = await doc.collection(sub).get();
      return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
    } catch (_) {
      return const [];
    }
  }

  /// Deletes one document from such a subcollection, used to tick a payment
  /// off once it has been written into the local ledger.
  Future<void> remove(String name, String sub, String id) async {
    final doc = _doc(name);
    if (doc == null) return;
    try {
      await doc.collection(sub).doc(id).delete();
    } catch (_) {
      // It will come round again on the next pass; a payment applied twice is
      // prevented by the ledger, not by this delete.
    }
  }

  /// The signed-in user's ID token, for the few calls that go to gabis's own
  /// worker rather than to Firestore.
  static Future<String?> idToken() async {
    try {
      return await FirebaseAuth.instance.currentUser?.getIdToken();
    } catch (_) {
      return null;
    }
  }

  Stream<Map<String, dynamic>?> watch(String name) {
    final doc = _doc(name);
    if (doc == null) return Stream.value(null);
    return doc.snapshots().map((s) => s.data()).handleError((_) => null);
  }
}
