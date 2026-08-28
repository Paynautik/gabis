import '../../shared/widgets/nautik_logo.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/widgets/coming_soon.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    ref.read(authStateProvider.notifier).state = true;
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.colors.ink, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  const NautikLogoMark(size: 36),
                  const SizedBox(width: 12),
                  Text(
                    'Elumo',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: context.colors.ink),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              const Text(
                'Welcome back',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5),
              ),
              const SizedBox(height: 8),
              Text(
                'Log in to your Elumo account',
                style: TextStyle(color: context.colors.inkSoft, fontSize: 15),
              ),
              const SizedBox(height: 32),
              const Text('Email, phone or Elumo ID', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
              const SizedBox(height: 8),
              TextField(
                controller: _identifierController,
                decoration: const InputDecoration(hintText: 'you@example.com or @yourname'),
              ),
              const SizedBox(height: 20),
              const Text('Password', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(hintText: '••••••••'),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => showComingSoon(context, 'Password reset'),
                  child: Text('Forgot password?', style: TextStyle(color: context.colors.bluePrimary, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                      )
                    : const Text('Log in'),
              ),
              const SizedBox(height: 28),
              Center(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(color: context.colors.inkSoft, fontSize: 14.5),
                    children: [
                      const TextSpan(text: 'New to Elumo? '),
                      TextSpan(
                        text: 'Create an account',
                        style: TextStyle(color: context.colors.bluePrimary, fontWeight: FontWeight.w700),
                        recognizer: TapGestureRecognizer()..onTap = () => showComingSoon(context, 'Sign up'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
