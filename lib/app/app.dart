import '../features/landing/landing_screen.dart';
import '../features/bills/bills_screen.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/splash_screen.dart';
import '../features/cards/cards_screen.dart';
import '../features/fx/fx_screen.dart';
import '../features/home/home_shell.dart';
import '../features/transfers/send_money_screen.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../shared/providers/app_providers.dart';

class GabisApp extends ConsumerWidget {
  const GabisApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'gabis — One account. Every currency. Zero borders.',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.getTheme(Brightness.light),
      darkTheme: AppTheme.getTheme(Brightness.dark),
      initialRoute: '/',
      routes: {
        '/': (_) => const LandingScreen(),
        '/splash': (_) => const SplashScreen(),
        '/landing': (_) => const LandingScreen(),
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const HomeShell(),
        '/send': (_) => const SendMoneyScreen(),
        '/cards': (_) => const CardsScreen(),
        '/fx': (_) => const FxScreen(),
        '/bills': (_) => const BillsScreen(),
      },
    );
  }
}
