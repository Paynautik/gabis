import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Real authentication, replacing the boolean that used to stand in for it.
///
/// Everything user-scoped keys off the uid this exposes, so points and the
/// business ledger follow the person rather than the browser.
class AuthService {
  final FirebaseAuth _auth;

  AuthService([FirebaseAuth? auth]) : _auth = auth ?? FirebaseAuth.instance;

  Stream<User?> get changes => _auth.authStateChanges();
  User? get current => _auth.currentUser;

  Future<User> signIn(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return result.user!;
  }

  Future<User> signUp(String email, String password, {String? name}) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    if (name != null && name.trim().isNotEmpty) {
      await result.user!.updateDisplayName(name.trim());
    }
    return result.user!;
  }

  Future<void> sendReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  Future<void> signOut() => _auth.signOut();

  /// Firebase's codes are not sentences; these are.
  static String describe(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'That email address does not look right.';
        case 'user-not-found':
        case 'invalid-credential':
          return 'No account with those details. Check the email and password.';
        case 'wrong-password':
          return 'That password is not right.';
        case 'email-already-in-use':
          return 'There is already an account with that email. Try signing in.';
        case 'weak-password':
          return 'Pick a longer password — at least six characters.';
        case 'network-request-failed':
          return 'No connection. Check your network and try again.';
        case 'too-many-requests':
          return 'Too many attempts. Wait a moment and try again.';
        default:
          return error.message ?? 'That did not work. Try again.';
      }
    }
    return 'Something went wrong. Try again.';
  }
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// The signed-in user, or null. Null means the landing page.
final authUserProvider = StreamProvider<User?>(
  (ref) => ref.watch(authServiceProvider).changes,
);
