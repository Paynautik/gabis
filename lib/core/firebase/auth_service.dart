import 'dart:async';

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

  /// Renames the account. Firebase caches the profile locally, so the user is
  /// reloaded before anything reads displayName back.
  Future<void> updateName(String name) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await user.updateDisplayName(name.trim());
    await user.reload();
  }

  Future<void> sendReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  Future<void> signOut() => _auth.signOut();

  /// Firebase's codes are not sentences; these are.
  static String describe(Object error) {
    if (error is TimeoutException) {
      return 'That is taking too long. Check your connection and try again.';
    }
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
///
/// authStateChanges() normally resolves in milliseconds from a cached
/// token, but on some mobile browsers (Safari private mode, in-app
/// WebViews) the IndexedDB persistence layer it depends on can stall
/// indefinitely. Without a bound on that wait, AuthGate's brief loading
/// spinner never resolves — login looks stuck rather than showing the
/// login screen. A timeout is not a real auth state, so it does not
/// cancel the underlying subscription: if the real event does arrive
/// late, it still comes through and replaces the timeout error.
final authUserProvider = StreamProvider<User?>(
  (ref) => ref
      .watch(authServiceProvider)
      .changes
      .timeout(const Duration(seconds: 6)),
);
