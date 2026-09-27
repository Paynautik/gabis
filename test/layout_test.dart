import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nautik_money/core/theme/app_theme.dart';
import 'package:nautik_money/features/accounts/accounts_screen.dart';
import 'package:nautik_money/features/community/ajo_screen.dart';
import 'package:nautik_money/features/fx/fx_screen.dart';
import 'package:nautik_money/features/community/escrow_screen.dart';
import 'package:nautik_money/features/intelligence/intelligence_screen.dart';
import 'package:nautik_money/features/partners/global_money_screen.dart';
import 'package:nautik_money/features/partners/partner_rails.dart';
import 'package:nautik_money/features/partners/partner_stores.dart';
import 'package:nautik_money/shared/providers/app_providers.dart';
import 'package:nautik_money/shared/widgets/screen_banner.dart';

/// The app theme gives outlined buttons an infinite minimum width. These
/// screens put them in rows and wraps, which must still lay out sensibly.
void main() {
  Future<void> pump(WidgetTester t, Widget w, {List<Override> overrides = const [], Size size = const Size(1400, 1000)}) async {
    t.view.physicalSize = size;
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(ProviderScope(
      // No Firebase in tests: hand the screens local data directly.
      overrides: [
        accountsProvider.overrideWith((ref) => AccountsNotifier(demo: true)),
        transactionsProvider.overrideWith((ref) => TransactionsNotifier(demo: true)),
        ...overrides,
      ],
      child: MaterialApp(theme: AppTheme.getTheme(Brightness.light), home: w),
    ));
    await t.pump();
  }

  testWidgets('USDC balance is not squeezed by the Receive button', (t) async {
    await pump(t, const GlobalMoneyScreen());
    final label = t.getSize(find.text('USDC balance'));
    expect(label.width, greaterThan(60));
    expect(t.takeException(), isNull);
  });

  testWidgets('escrow action buttons lay out in a wrap', (t) async {
    final n = EscrowNotifier(SandboxEscrowCustodian());
    await n.create(title: 'Laptop', counterparty: '@s', iAmBuyer: false, amountMinor: 100);
    n.simulateFunding(n.debugState.single.id);
    await pump(t, const Scaffold(body: EscrowScreen()),
        overrides: [escrowProvider.overrideWith((ref) => n)]);
    expect(find.text('Mark dispatched'), findsOneWidget);
    expect(t.getSize(find.widgetWithText(OutlinedButton, 'Refund')).width, lessThan(400));
    expect(t.takeException(), isNull);
  });

  for (final size in const [Size(390, 844), Size(1400, 1000)]) {
    testWidgets('accounts screen lays out at ${size.width.toInt()}px', (t) async {
      await pump(t, const AccountsScreen(), size: size);
      expect(find.text('Total balance'), findsOneWidget);
      expect(find.text('Open a wallet'), findsOneWidget);
      await t.tap(find.text('USD').first);
      await t.pump();
      expect(find.text('USD ACTIVITY'), findsOneWidget);
      expect(t.takeException(), isNull);
    });

    testWidgets('agents tab lays out at ${size.width.toInt()}px', (t) async {
      await pump(t, const IntelligenceScreen(), size: size);
      await t.ensureVisible(find.text('Agents'));
      await t.tap(find.text('Agents'));
      for (var i = 0; i < 12; i++) {
        await t.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('Money Agent'), findsOneWidget);
      await t.tap(find.text('Money Agent'));
      for (var i = 0; i < 8; i++) {
        await t.pump(const Duration(milliseconds: 100));
      }
      expect(find.text('WHAT IT CHECKS'), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  }

  for (final size in const [Size(390, 844), Size(1400, 1000)]) {
    testWidgets('ajo circle lays out at ${size.width.toInt()}px', (t) async {
      final n = AjoNotifier();
      n.create(name: 'Christmas chicken', members: const ['Collins', 'Raphael', 'Jesse', 'Mummy'], contributionNaira: 1000, frequency: 'monthly');
      n.markPaid(n.debugState.single.id, 'Raphael');
      await pump(t, const Scaffold(body: AjoScreen()), size: size, overrides: [ajoProvider.overrideWith((ref) => n)]);
      expect(find.text('SCHEDULE'), findsOneWidget);
      expect(find.textContaining('Remind 3 on WhatsApp'), findsOneWidget);
      expect(t.takeException(), isNull);
    });
  }

  testWidgets('exchange form stays a centred column and blocks a short balance', (t) async {
    await pump(t, const FxScreen(), overrides: [accountsProvider.overrideWith((ref) => AccountsNotifier())]);
    await t.enterText(find.byType(TextField), '500,000');
    await t.pump();
    final button = find.widgetWithText(ElevatedButton, 'Not enough NGN');
    expect(button, findsOneWidget);
    expect(t.getSize(button).width, lessThanOrEqualTo(520));
    expect(t.widget<ElevatedButton>(button).onPressed, isNull);
    expect(t.takeException(), isNull);
  });

  for (final size in const [Size(390, 844), Size(1400, 1000)]) {
    testWidgets('every screen banner fits at ${size.width.toInt()}px', (t) async {
      for (final tab in screenBanners.keys) {
        await pump(t, Scaffold(body: BannerFrame(tab: tab, child: const SizedBox.expand())), size: size);
        expect(find.text(screenBanners[tab]!.title), findsOneWidget);
        expect(t.takeException(), isNull, reason: 'banner $tab');
      }
    });
  }
}
