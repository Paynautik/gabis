import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Per-user documents in Firestore, so a balance earned on a phone is there on
/// a laptop. Local storage stays the fast path and the offline fallback; this
/// is the copy that follows the account.
///
/// Everything lives under users/{uid}, which keeps gabis clear of the other
/// app sharing this Firebase project.
class UserSync {
  final FirebaseFirestore _db;

  UserSync([FirebaseFirestore? db]) : _db = db ?? FirebaseFirestore.instance;

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

  Stream<Map<String, dynamic>?> watch(String name) {
    final doc = _doc(name);
    if (doc == null) return Stream.value(null);
    return doc.snapshots().map((s) => s.data()).handleError((_) => null);
  }
}
