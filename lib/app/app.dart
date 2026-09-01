// V3 landing. The previous page is still at landing_screen.dart —
// swap this import back to revert.
import '../features/landing/gabis_landing_v3.dart';
import '../features/marketing/marketing_content.dart';
import '../features/points/points_screen.dart';
import '../features/business/business_dashboard_screen.dart';
import '../features/marketing/marketing_screen.dart';
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
        '/points': (_) => const PointsScreen(),
        // Direct link to the business dashboard — deep-linkable, and the only
        // way to reach it without walking the whole personal shell.
        '/business-dashboard': (_) => const BusinessDashboardScreen(),
      },
      // Every footer destination is a real route with its own page.
      onGenerateRoute: (settings) {
        final page = marketingPages[settings.name];
        if (page == null) return null;
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => MarketingScreen(page: page),
        );
      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        settings: settings,
        builder: (_) => const LandingScreen(),
      ),
    );
  }
}
