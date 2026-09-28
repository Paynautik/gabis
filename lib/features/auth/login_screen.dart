import '../../shared/widgets/nautik_logo.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/firebase/auth_service.dart';
import '../../core/session/session.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/widgets/coming_soon.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _nameController = TextEditingController();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  /// One screen, two modes — a separate sign-up page is a wall for someone
  /// who just wants in.
  bool _creatingAccount = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final name = _nameController.text.trim();
    final email = _identifierController.text.trim();
    final password = _passwordController.text;

    // The name is what the app then calls them everywhere — on the card, in
    // the greeting — so a new account cannot start without one.
    if (_creatingAccount && name.length < 2) {
      setState(() => _error = 'Enter the name on the account.');
      return;
    }
    if (!email.contains('@')) {
      setState(() => _error = 'Enter the email address on your account.');
      return;
    }
    if (password.length < 6) {
      setState(() => _error = 'Passwords are at least six characters.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final auth = ref.read(authServiceProvider);
      // A bound on the network call itself: some mobile browsers stall
      // writing the auth session to storage rather than failing outright,
      // which otherwise leaves this button spinning forever instead of
      // showing a retry-able error.
      final user = await (_creatingAccount
              ? auth.signUp(email, password, name: name)
              : auth.signIn(email, password))
          .timeout(const Duration(seconds: 20));

      if (!mounted) return;
      ref.read(authStateProvider.notifier).state = true;
      // If this browser's local copy belongs to somebody else, it goes before
      // anything reads it. The account's own preferences arrive from Firestore.
      ref.read(sessionProvider).adoptUser(user.uid);
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = AuthService.describe(error);
      });
    }
  }

  Future<void> _resetPassword() async {
    final email = _identifierController.text.trim();
    if (!email.contains('@')) {
      setState(() => _error = 'Enter your email address first, then tap reset.');
      return;
    }
    try {
      await ref.read(authServiceProvider).sendReset(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reset link sent to $email.')),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = AuthService.describe(error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bgSoft,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            final wide = c.maxWidth >= 940;
            final form = Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: c.maxWidth < 520 ? 22 : 40,
                  vertical: 32,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: _formCard(context, wide: wide),
                ),
              ),
            );

            if (!wide) return form;

            return Row(
              children: [
                const Expanded(flex: 5, child: _BrandPanel()),
                Expanded(flex: 6, child: form),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _formCard(BuildContext context, {required bool wide}) {
    final card = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(Icons.arrow_back_ios_new_rounded,
                  color: context.colors.ink, size: 18),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 14),
            const NautikLogoMark(size: 34),
          ],
        ),
        const SizedBox(height: 30),
        Text(
          _creatingAccount ? 'Create your account' : 'Welcome back',
          style: const TextStyle(
              fontSize: 27, fontWeight: FontWeight.w800, letterSpacing: -0.6),
        ),
        const SizedBox(height: 6),
        Text(
          _creatingAccount
              ? 'A few seconds, and your money follows you everywhere.'
              : 'Log in to your gabis account',
          style: TextStyle(color: context.colors.inkSoft, fontSize: 14.5),
        ),
        const SizedBox(height: 26),
        if (_creatingAccount) ...[
          const Text('Full name',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 7),
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            keyboardType: TextInputType.name,
            decoration: const InputDecoration(hintText: 'Ada Okonkwo'),
          ),
          const SizedBox(height: 16),
        ],
        const Text('Email',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        const SizedBox(height: 7),
        TextField(
          controller: _identifierController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(hintText: 'you@example.com'),
        ),
        const SizedBox(height: 16),
        const Text('Password',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        const SizedBox(height: 7),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: const InputDecoration(hintText: '••••••••'),
        ),
        if (!_creatingAccount)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _resetPassword,
              child: Text('Forgot password?',
                  style: TextStyle(
                      color: context.colors.bluePrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5)),
            ),
          ),
        if (_creatingAccount) const SizedBox(height: 18),
        if (_error != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1EE),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFFD5CB)),
            ),
            child: Text(_error!,
                style: const TextStyle(
                    color: Color(0xFFB3341C), fontSize: 13, height: 1.4)),
          ),
        ],
        const SizedBox(height: 6),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _loading ? null : _login,
            child: _loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.4, color: Colors.white),
                  )
                : Text(_creatingAccount ? 'Create account' : 'Log in'),
          ),
        ),
        const SizedBox(height: 22),
        Center(
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: context.colors.inkSoft, fontSize: 14),
              children: [
                TextSpan(
                    text: _creatingAccount
                        ? 'Already have an account? '
                        : 'New to gabis? '),
                TextSpan(
                  text: _creatingAccount ? 'Log in' : 'Create an account',
                  style: TextStyle(
                      color: context.colors.bluePrimary,
                      fontWeight: FontWeight.w700),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => setState(() {
                          _creatingAccount = !_creatingAccount;
                          _error = null;
                        }),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    // On a phone the form is the page; on a wide screen it sits on a card so it
    // reads as a panel rather than a stretched form.
    return Container(
      padding: EdgeInsets.all(wide ? 34 : 4),
      decoration: wide
          ? BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: context.colors.ink.withValues(alpha: .07)),
              boxShadow: [
                BoxShadow(
                  color: context.colors.ink.withValues(alpha: .06),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            )
          : null,
      child: card,
    );
  }
}

/// Wide screens get a brand column instead of blank space either side.
class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF101828);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF141F3A), ink],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(56, 56, 48, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/gabis_logo_white.png', height: 40),
          const SizedBox(height: 34),
          const Text(
            'Money,\nwithout the wait.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 42,
              height: 1.05,
              letterSpacing: -1.6,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          const SizedBox(
            width: 380,
            child: Text(
              'Send, receive and spend across currencies from one account built for how Africa actually moves money.',
              style: TextStyle(
                color: Color(0xB3FFFFFF),
                fontSize: 15.5,
                height: 1.55,
              ),
            ),
          ),
          const SizedBox(height: 34),
          const _BrandPoint(
              icon: Icons.lock_rounded, text: 'Bank-grade security on every transfer'),
          const SizedBox(height: 14),
          const _BrandPoint(
              icon: Icons.bolt_rounded, text: 'Balances in 5 currencies, one login'),
          const SizedBox(height: 14),
          const _BrandPoint(
              icon: Icons.support_agent_rounded, text: 'Support that answers in minutes'),
        ],
      ),
    );
  }
}

class _BrandPoint extends StatelessWidget {
  final IconData icon;
  final String text;

  const _BrandPoint({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 15, color: const Color(0xFF00B876)),
        ),
        const SizedBox(width: 12),
        Text(text,
            style: const TextStyle(
                color: Color(0xD9FFFFFF),
                fontSize: 14,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}
