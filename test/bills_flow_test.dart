import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nautik_money/core/theme/app_theme.dart';
import 'package:nautik_money/features/bills/bills_screen.dart';
import 'package:nautik_money/shared/models/transaction.dart';
import 'package:nautik_money/shared/providers/app_providers.dart';

void main() {
  late ProviderContainer container;

  Future<void> open(WidgetTester t) async {
    t.view.physicalSize = const Size(900, 1800);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    container = ProviderContainer(overrides: [
      accountsProvider.overrideWith((ref) => AccountsNotifier(demo: true)),
      transactionsProvider.overrideWith((ref) => TransactionsNotifier(demo: true)),
      demoDataProvider.overrideWith((ref) => DemoDataNotifier(sync: false)),
    ]);
    addTearDown(container.dispose);
    await t.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(theme: AppTheme.getTheme(Brightness.light), home: const BillsScreen()),
    ));
    await t.pump();
  }

  Finder field(int i) => find.descendant(of: find.byType(BottomSheet), matching: find.byType(TextField)).at(i);

  int ngn() => container.read(accountsProvider).firstWhere((a) => a.currency == 'NGN').balance.minorUnits;
  int billTxs() => container.read(transactionsProvider).where((x) => x.type == TransactionType.billPayment).length;

  testWidgets('a bad phone number and a missing amount are refused', (t) async {
    await open(t);
    await t.tap(find.text('Buy airtime'));
    await t.pumpAndSettle();
    await t.enterText(field(0), '12345');
    await t.tap(find.text('Review payment'));
    await t.pumpAndSettle();
    expect(find.textContaining('11-digit Nigerian number'), findsOneWidget);
    expect(find.text('Enter an amount.'), findsOneWidget);
    expect(find.text('Review payment'), findsOneWidget); // still on the form
  });

  testWidgets('a valid airtime purchase is reviewed, paid, recorded and receipted', (t) async {
    await open(t);
    final before = ngn();
    final txBefore = billTxs();

    await t.tap(find.text('Buy airtime'));
    await t.pumpAndSettle();
    await t.tap(find.text('Airtel'));
    await t.pump();
    await t.enterText(field(0), '08012345678');
    await t.enterText(field(1), '500');
    await t.tap(find.text('Review payment'));
    await t.pumpAndSettle();

    expect(find.text('Review payment'), findsOneWidget); // heading of the review step
    expect(find.text('Pay ₦500'), findsOneWidget);
    expect(ngn(), before); // nothing charged yet

    await t.tap(find.text('Pay ₦500'));
    await t.pumpAndSettle();

    expect(find.text('Payment successful'), findsOneWidget);
    expect(ngn(), before - 50000);
    expect(billTxs(), txBefore + 1);
    final tx = container.read(transactionsProvider).firstWhere((x) => x.description == 'Airtel airtime (08012345678)');
    expect(tx.amount.minorUnits, 50000);
    expect(tx.isCredit, isFalse);
    expect(t.takeException(), isNull);
  });

  testWidgets('a payment bigger than the wallet is stopped and charges nothing', (t) async {
    await open(t);
    final before = ngn();
    final txBefore = billTxs();

    await t.tap(find.text('Remita'));
    await t.pumpAndSettle();
    await t.enterText(field(0), 'RRR-1234-5678');
    await t.enterText(field(1), '4000000');
    await t.tap(find.text('Review payment'));
    await t.pumpAndSettle();
    await t.tap(find.textContaining('Pay ₦4,000,000'));
    await t.pumpAndSettle();

    expect(find.textContaining('not enough'), findsOneWidget);
    expect(find.text('Payment successful'), findsNothing);
    expect(ngn(), before);
    expect(billTxs(), txBefore);
  });
}
