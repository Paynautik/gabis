import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/login_screen.dart';
import '../firebase/auth_service.dart';

/// Guards a route that needs an account.
///
/// Typing /home or /business-dashboard used to be enough to walk past the
/// login screen entirely. Now the route resolves to whoever is actually
/// signed in, and to the login screen when that is nobody.
class AuthGate extends ConsumerWidget {
  final Widget child;

  const AuthGate({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authUserProvider);

    return auth.when(
      data: (user) => user == null ? const LoginScreen() : child,
      // A brief wait, not a spinner-shaped hole: this resolves in milliseconds
      // from a cached token.
      loading: () => const Scaffold(
        body: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.2),
          ),
        ),
      ),
      // If auth itself is broken, asking someone to sign in is the honest
      // outcome — better than showing an account we cannot verify.
      error: (_, __) => const LoginScreen(),
    );
  }
}
