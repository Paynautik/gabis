import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nautik_money/core/theme/app_theme.dart';
import 'package:nautik_money/features/bills/bills_api.dart';
import 'package:nautik_money/features/bills/bills_screen.dart';
import 'package:nautik_money/shared/models/transaction.dart';
import 'package:nautik_money/shared/providers/app_providers.dart';

/// Demo mode on, without the account sync that needs Firebase.
class _DemoOn extends DemoDataNotifier {
  _DemoOn() : super(sync: false) {
    state = true;
  }
}

/// A biller that answers from a script instead of the network.
class FakeBillsApi extends BillsApi {
  FakeBillsApi({
    this.payResult,
    this.statuses = const [],
    this.check = const BillAccountCheck(valid: true, name: 'ADA OBI'),
    this.planList = const [BillPlan(code: 'mtn-1gb', name: '1GB - 30 days', amount: 500)],
  });

  BillPayResult? payResult;
  List<BillPayResult> statuses;
  BillAccountCheck check;
  List<BillPlan> planList;

  final payCalls = <Map<String, Object?>>[];
  int statusCalls = 0;
  int verifyCalls = 0;

  @override
  Future<List<BillPlan>> plans(String serviceId) async => planList;

  @override
  Future<BillAccountCheck> verify({required String kind, required String provider, required String account}) async {
    verifyCalls++;
    return check;
  }

  @override
  Future<BillPayResult> pay({
    required String kind,
    required String provider,
    required String account,
    required int amount,
    required String requestId,
    String? phone,
    String? planCode,
  }) async {
    payCalls.add({'kind': kind, 'provider': provider, 'account': account, 'amount': amount, 'requestId': requestId, 'phone': phone, 'planCode': planCode});
    return payResult!;
  }

  @override
  Future<BillPayResult> status(String requestId) async {
    final i = statusCalls++;
    return i < statuses.length ? statuses[i] : statuses.last;
  }
}

BillPayResult delivered({String? token}) =>
    BillPayResult(outcome: BillOutcome.delivered, reference: 'r', token: token, units: token == null ? null : '12.4');
const pending = BillPayResult(outcome: BillOutcome.pending, reference: 'r');
const failed = BillPayResult(outcome: BillOutcome.failed, reference: 'r', message: 'INSUFFICIENT');

void main() {
  late ProviderContainer container;

  Future<void> open(WidgetTester t, {FakeBillsApi? api, bool demo = true}) async {
    t.view.physicalSize = const Size(900, 1800);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    container = ProviderContainer(overrides: [
      accountsProvider.overrideWith((ref) => AccountsNotifier(demo: true)),
      transactionsProvider.overrideWith((ref) => TransactionsNotifier(demo: true)),
      demoDataProvider.overrideWith((ref) => demo ? _DemoOn() : DemoDataNotifier(sync: false)),
      billsConfigProvider.overrideWith((ref) async => api == null ? BillsConfig.off : const BillsConfig(enabled: true)),
      if (api != null) billsApiProvider.overrideWithValue(api),
      billsPollDelayProvider.overrideWithValue(Duration.zero),
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
  List<AppTransaction> billTxs() => container.read(transactionsProvider).where((x) => x.type == TransactionType.billPayment).toList();

  Future<void> openBill(WidgetTester t, String title) async {
    await t.tap(find.text(title));
    await t.pumpAndSettle();
  }

  group('example payments (demo mode, no biller connected)', () {
    testWidgets('a bad phone number and a missing amount are refused', (t) async {
      await open(t);
      await openBill(t, 'Buy airtime');
      await t.enterText(field(0), '12345');
      await t.tap(find.text('Review payment'));
      await t.pumpAndSettle();
      expect(find.textContaining('11-digit Nigerian number'), findsOneWidget);
      expect(find.text('Enter an amount.'), findsOneWidget);
    });

    testWidgets('a valid airtime purchase is reviewed, paid, recorded and receipted', (t) async {
      await open(t);
      final before = ngn();
      final txBefore = billTxs().length;

      await openBill(t, 'Buy airtime');
      await t.tap(find.text('Airtel'));
      await t.pump();
      await t.enterText(field(0), '08012345678');
      await t.enterText(field(1), '500');
      await t.tap(find.text('Review payment'));
      await t.pumpAndSettle();

      expect(find.text('Pay ₦500'), findsOneWidget);
      expect(ngn(), before); // nothing charged yet

      await t.tap(find.text('Pay ₦500'));
      await t.pumpAndSettle();

      expect(find.text('Payment successful'), findsOneWidget);
      expect(find.textContaining('No biller was charged'), findsOneWidget);
      expect(ngn(), before - 50000);
      expect(billTxs().length, txBefore + 1);
      expect(t.takeException(), isNull);
    });

    testWidgets('a payment bigger than the wallet is stopped and charges nothing', (t) async {
      await open(t);
      final before = ngn();
      final txBefore = billTxs().length;

      await openBill(t, 'Remita');
      await t.enterText(field(0), 'RRR-1234-5678');
      await t.enterText(field(1), '4000000');
      await t.tap(find.text('Review payment'));
      await t.pumpAndSettle();
      await t.tap(find.textContaining('Pay ₦4,000,000'));
      await t.pumpAndSettle();

      expect(find.textContaining('not enough'), findsOneWidget);
      expect(ngn(), before);
      expect(billTxs().length, txBefore);
    });
  });

  testWidgets('with no biller connected and no demo data, nothing is paid', (t) async {
    await open(t, demo: false);
    await t.tap(find.text('Buy airtime'));
    await t.pumpAndSettle();
    expect(find.textContaining('not available yet'), findsOneWidget);
    expect(find.text('Review payment'), findsNothing);
  });

  group('real payments through the biller', () {
    Future<void> enterMeterAndPay(WidgetTester t, {String amount = '2000'}) async {
      await openBill(t, 'Electricity & Water');
      await t.enterText(field(0), '1111111111111');
      await t.enterText(field(1), '08012345678');
      await t.enterText(field(2), amount);
      await t.tap(find.text('Review payment'));
      await t.pumpAndSettle();
    }

    testWidgets('electricity: the meter is checked, paid, and the token shown', (t) async {
      final api = FakeBillsApi(payResult: delivered(token: '1234-5678-9012'));
      await open(t, api: api);
      final before = ngn();

      await enterMeterAndPay(t);
      expect(api.verifyCalls, 1);
      expect(find.text('ADA OBI'), findsOneWidget); // whose meter it is, before paying
      expect(ngn(), before);

      await t.tap(find.text('Pay ₦2,000'));
      await t.pumpAndSettle();

      expect(find.text('Payment successful'), findsOneWidget);
      expect(find.text('1234-5678-9012'), findsOneWidget);
      expect(find.textContaining('No biller was charged'), findsNothing);
      expect(ngn(), before - 200000);
      expect(billTxs().first.status, TransactionStatus.completed);

      final call = api.payCalls.single;
      expect(call['kind'], 'electricity');
      expect(call['provider'], 'Ikeja Electric');
      expect(call['account'], '1111111111111');
      expect(call['phone'], '08012345678');
      expect(call['amount'], 2000);
      expect(call['requestId'], matches(RegExp(r'^\d{12}[a-z0-9]{10}$')));
    });

    testWidgets('a meter the biller does not know is refused before any payment', (t) async {
      final api = FakeBillsApi(payResult: delivered(), check: const BillAccountCheck(valid: false));
      await open(t, api: api);
      await enterMeterAndPay(t);
      expect(find.textContaining('could not find that meter'), findsOneWidget);
      expect(find.text('Review payment'), findsWidgets); // still on the form
      expect(api.payCalls, isEmpty);
    });

    testWidgets('data is bought from the plan list, at the plan price', (t) async {
      final api = FakeBillsApi(payResult: delivered());
      await open(t, api: api);
      final before = ngn();

      await openBill(t, 'Buy data');
      await t.enterText(field(0), '08031234567');
      await t.tap(find.byType(DropdownButtonFormField<String>));
      await t.pumpAndSettle();
      await t.tap(find.textContaining('1GB - 30 days').last);
      await t.pumpAndSettle();
      await t.tap(find.text('Review payment'));
      await t.pumpAndSettle();
      expect(find.text('Pay ₦500'), findsOneWidget);
      await t.tap(find.text('Pay ₦500'));
      await t.pumpAndSettle();

      expect(find.text('Payment successful'), findsOneWidget);
      expect(ngn(), before - 50000);
      expect(api.payCalls.single['planCode'], 'mtn-1gb');
      expect(api.payCalls.single['kind'], 'data');
    });

    testWidgets('a payment the biller refuses charges nothing and can be tried again', (t) async {
      final api = FakeBillsApi(payResult: failed);
      await open(t, api: api);
      final before = ngn();
      final txBefore = billTxs().length;

      await enterMeterAndPay(t);
      await t.tap(find.text('Pay ₦2,000'));
      await t.pumpAndSettle();

      expect(find.textContaining('You have not been charged'), findsOneWidget);
      expect(find.text('Payment successful'), findsNothing);
      expect(ngn(), before);
      expect(billTxs().length, txBefore);

      // Trying again is a new payment with a new id.
      api.payResult = delivered(token: '1111');
      await t.tap(find.text('Pay ₦2,000'));
      await t.pumpAndSettle();
      expect(find.text('Payment successful'), findsOneWidget);
      expect(api.payCalls.length, 2);
      expect(api.payCalls[0]['requestId'], isNot(api.payCalls[1]['requestId']));
      expect(ngn(), before - 200000);
    });

    testWidgets('a payment still processing is looked at again and lands once', (t) async {
      final api = FakeBillsApi(payResult: pending, statuses: [pending, delivered(token: '9999-8888')]);
      await open(t, api: api);
      final before = ngn();

      await enterMeterAndPay(t);
      await t.tap(find.text('Pay ₦2,000'));
      await t.pumpAndSettle();

      expect(find.text('Payment successful'), findsOneWidget);
      expect(find.text('9999-8888'), findsOneWidget);
      expect(api.payCalls.length, 1); // never paid twice
      expect(ngn(), before - 200000); // charged once
      expect(billTxs().where((x) => x.id == api.payCalls.single['requestId']).length, 1);
    });

    testWidgets('one that stays pending is recorded as processing, then refunded if it fails', (t) async {
      final api = FakeBillsApi(payResult: pending, statuses: [pending, pending, pending, failed]);
      await open(t, api: api);
      final before = ngn();

      await enterMeterAndPay(t);
      await t.tap(find.text('Pay ₦2,000'));
      await t.pumpAndSettle();

      // Settled in the background: it failed, so the money is back.
      expect(ngn(), before);
      final tx = billTxs().firstWhere((x) => x.id == api.payCalls.single['requestId']);
      expect(tx.status, TransactionStatus.reversed);
      expect(tx.description, contains('refunded'));
    });
  });
}
