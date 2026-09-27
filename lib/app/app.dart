// On the web, "/" is the static homepage (web/landing); SiteHome sends the
// app there. Native builds still show the in-app landing screen.
import '../features/marketing/marketing_content.dart';
import '../core/session/auth_gate.dart';
import '../features/kyc/kyc_screen.dart';
import '../features/points/points_screen.dart';
import '../features/business/business_dashboard_screen.dart';
import '../features/marketing/marketing_screen.dart';
import '../features/bills/bills_screen.dart';
import 'package:flutter/material.dart';
import '../core/util/site_home.dart';
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
        '/': (_) => const SiteHome(),
        '/splash': (_) => const SplashScreen(),
        '/landing': (_) => const SiteHome(),
        '/login': (_) => const LoginScreen(),
        // Anything holding money or customer data sits behind the gate.
        '/home': (_) => const AuthGate(child: HomeShell()),
        '/send': (_) => const AuthGate(child: SendMoneyScreen()),
        '/cards': (_) => const AuthGate(child: CardsScreen()),
        '/fx': (_) => const AuthGate(child: FxScreen()),
        '/bills': (_) => const AuthGate(child: BillsScreen()),
        '/points': (_) => const AuthGate(child: PointsScreen()),
        '/verify': (_) => const AuthGate(child: KycScreen()),
        '/business-dashboard': (_) =>
            const AuthGate(child: BusinessDashboardScreen()),
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
        builder: (_) => const SiteHome(),
      ),
    );
  }
}
