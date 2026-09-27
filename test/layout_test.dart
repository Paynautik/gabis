import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nautik_money/core/theme/app_theme.dart';
import 'package:nautik_money/features/community/escrow_screen.dart';
import 'package:nautik_money/features/partners/global_money_screen.dart';
import 'package:nautik_money/features/partners/partner_rails.dart';
import 'package:nautik_money/features/partners/partner_stores.dart';

/// The app theme gives outlined buttons an infinite minimum width. These
/// screens put them in rows and wraps, which must still lay out sensibly.
void main() {
  Future<void> pump(WidgetTester t, Widget w, {List<Override> overrides = const []}) async {
    t.view.physicalSize = const Size(1400, 1000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(ProviderScope(
      overrides: overrides,
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
}
