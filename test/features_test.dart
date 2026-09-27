import 'package:flutter_test/flutter_test.dart';
import 'package:nautik_money/features/business/refunds_store.dart';
import 'package:nautik_money/features/business/tax_rules.dart';
import 'package:nautik_money/features/copilot/copilot_engine.dart';
import 'package:nautik_money/features/intelligence/agents.dart';
import 'package:nautik_money/features/intelligence/intelligence_engine.dart';
import 'package:nautik_money/features/intelligence/intelligence_stores.dart';
import 'package:nautik_money/features/intelligence/payment_guard.dart';
import 'package:nautik_money/features/partners/partner_rails.dart';
import 'package:nautik_money/features/partners/partner_stores.dart';
import 'package:nautik_money/shared/models/money.dart';
import 'package:nautik_money/shared/models/transaction.dart';
import 'package:nautik_money/shared/providers/app_providers.dart';

AppTransaction _tx(String id, int naira, {bool credit = false, String? to, DateTime? at}) => AppTransaction(
      id: id,
      type: TransactionType.transfer,
      status: TransactionStatus.completed,
      amount: Money(minorUnits: naira * 100, currency: 'NGN'),
      counterparty: to,
      createdAt: at ?? DateTime.now().subtract(const Duration(days: 3)),
      isCredit: credit,
    );

void main() {
  group('tax', () {
    test('WHT is charged on the net amount, not on VAT', () {
      final t = taxInvoice(netMinor: 15000000, vatRate: 0.075, whtRate: 0.05);
      expect(t.vatMinor, 1125000); // ₦11,250
      expect(t.whtMinor, 750000); // ₦7,500
      expect(t.receivedMinor, 15375000); // ₦153,750
    });

    test('seven corridors, South Africa removed', () {
      expect(taxCorridors.map((c) => c.code), ['NG', 'KE', 'GH', 'UG', 'TZ', 'SS', 'LR']);
      expect(corridorFor('LR').taxName, 'GST');
      expect(corridorFor('SS').taxName, 'Sales tax');
      expect(corridorFor('UG').needsConfirmation, isTrue);
      expect(corridorFor('NG').needsConfirmation, isFalse);
    });
  });

  group('refund windows', () {
    final sold = DateTime(2026, 9, 1, 12);
    final w = SaleWindow(
      id: '1',
      orderRef: '#0139',
      customer: 'Sarah',
      amountMinor: 100,
      policyDays: 14,
      soldAt: sold,
      status: RefundStatus.open,
    );

    test('counts down and closes itself', () {
      expect(w.closesAt, DateTime(2026, 9, 15, 12));
      expect(w.remaining(DateTime(2026, 9, 12, 12)).inDays, 3);
      expect(w.effectiveStatus(DateTime(2026, 9, 16)), RefundStatus.closed);
    });

    test('warns within the last 24 hours only', () {
      expect(w.closingSoon(DateTime(2026, 9, 14, 13)), isTrue);
      expect(w.closingSoon(DateTime(2026, 9, 13, 11)), isFalse);
    });
  });

  group('firewall', () {
    final history = [
      for (var i = 0; i < 6; i++) _tx('t$i', 50000, to: 'Mum'),
    ];

    test('a familiar payee at a normal amount goes straight through', () {
      final v = PaymentGuard(history).check(recipient: 'Mum', amountMinor: 5000000);
      expect(v.shouldPause, isFalse);
    });

    test('new recipient and 8× the usual amount pauses, with reasons', () {
      final v = PaymentGuard(history).check(recipient: 'Stranger', amountMinor: 40000000);
      expect(v.shouldPause, isTrue);
      expect(v.signals.map((s) => s.reason).join(' '), contains('First payment'));
      expect(v.signals.map((s) => s.reason).join(' '), contains('8.0×'));
    });
  });

  group('autopilot', () {
    test('splits top to bottom and leaves the rest safe to spend', () {
      const ap = AutopilotState(armed: true, rules: AutopilotState.defaults, handledIncomeIds: {});
      final s = ap.split(1200000);
      expect(s.map((x) => x.naira), [180000, 255000, 76000, 689000]);
      expect(s.fold(0, (a, x) => a + x.naira), 1200000);
    });
  });

  group('intelligence', () {
    final txs = TransactionsNotifier(demo: true).state;
    final engine = IntelligenceEngine(CopilotEngine(transactions: txs, balanceNaira: 1250000));

    test('forecast covers 30 days from today', () {
      final f = engine.forecast();
      expect(f.points.length, 31);
      expect(f.at(0), 1250000);
      expect(f.safeTodayNaira, greaterThanOrEqualTo(0));
    });

    test('spending more never improves the 30-day balance', () {
      final w = engine.whatIf(extraMonthlyNaira: 80000);
      expect(w.payday30After, lessThan(w.payday30Before));
    });

    test('goal plan rounds up to the next thousand', () {
      final p = engine.planGoal(targetNaira: 2000000, deadline: DateTime.now().add(const Duration(days: 150)));
      expect(p.monthlyNaira % 1000, 0);
      expect(p.monthlyNaira * p.monthsLeft, greaterThanOrEqualTo(2000000));
    });

    test('roast is written from real figures', () {
      final lines = engine.roast();
      expect(lines, isNotEmpty);
      expect(lines.join(' '), contains('₦'));
    });

    test('empty history gets an honest roast', () {
      final empty = IntelligenceEngine(CopilotEngine(transactions: const [], balanceNaira: 0));
      expect(empty.roast().single, contains('Nothing to roast'));
    });
  });

  group('partners (sandbox)', () {
    test('quotes expire and cannot be converted after expiry', () async {
      final rail = SandboxStablecoinRail(SandboxFxFeed(1));
      final q = await rail.quote(usdcCents: 125000, currency: 'NGN');
      expect(q.outMinor, greaterThan(0));
      final stale = RateQuote(
          usdcCents: 1, currency: 'NGN', rate: 1500, expiresAt: DateTime.now().subtract(const Duration(seconds: 1)));
      expect((await rail.convert(stale)).ok, isFalse);
    });

    test('ajo pays out only when everyone has paid, then rotates', () {
      final c = AjoCircle(
        id: 'a',
        name: 'Rent',
        members: const ['Amaka', 'Kemi', 'Tunde'],
        contributionNaira: 50000,
        frequency: 'monthly',
        round: 0,
        paidThisRound: const {'Amaka', 'Kemi'},
        startedAt: DateTime(2026, 9, 1),
      );
      expect(c.potNaira, 150000);
      expect(c.recipient, 'Amaka');
      expect(c.everyonePaid, isFalse);
      final paid = c.copyWith(paidThisRound: {'Amaka', 'Kemi', 'Tunde'});
      expect(paid.everyonePaid, isTrue);
      expect(paid.copyWith(round: 1).recipient, 'Kemi');
    });
  });
  group('agents', () {
    test('no data, no findings', () {
      expect(runAgents(_snap()), isEmpty);
    });

    test('money agent warns before the balance runs out', () {
      final now = DateTime(2026, 9, 10);
      // Rent of ₦300k leaves on the 12th every month; no income on record.
      final rent = [
        for (final m in [6, 7, 8]) _tx('r$m', 300000, to: 'Landlord', at: DateTime(2026, m, 12)),
      ];
      final short = moneyAgent(_snap(txs: rent, balance: 100000, now: now));
      expect(short.single.severity, Severity.urgent);
      expect(short.single.title, contains('12 Sep'));
      expect(moneyAgent(_snap(txs: rent, balance: 5000000, now: now)), isEmpty);
    });

    test('wealth agent proposes the autopilot split for new income', () {
      final f = wealthAgent(_snap(income: _tx('sal', 1200000, credit: true)));
      expect(f.single.action, ActionKind.approveSplit);
      expect(f.single.detail, contains('Safe to spend'));
    });

    test('wealth agent flags a goal that has fallen behind, with the exact catch-up', () {
      final now = DateTime(2026, 9, 27);
      final g = SavingsGoal(
        id: 'g', name: 'Laptop', targetNaira: 1000000, savedNaira: 0,
        deadline: DateTime(2026, 12, 27), createdAt: DateTime(2026, 8, 27));
      final f = wealthAgent(_snap(goals: [g], now: now)).single;
      expect(f.action, ActionKind.contribute);
      expect(f.amountNaira! % 1000, 0);
      expect(f.amountNaira, closeTo(1000000 * 31 / 122, 1000));
    });

    test('security agent follows up on a flagged payment the user approved', () {
      final f = securityAgent(_snap(guard: [
        GuardEvent(recipient: 'Stranger', amountMinor: 1, reasons: const ['First payment'], outcome: 'approved', at: DateTime.now()),
      ]));
      expect(f.single.severity, Severity.warn);
    });

    test('bills agent warns about a refund window closing today', () {
      final now = DateTime(2026, 9, 14, 13);
      final w = SaleWindow(id: '1', orderRef: '#0139', customer: 'S', amountMinor: 1, policyDays: 14,
          soldAt: DateTime(2026, 9, 1, 12), status: RefundStatus.open);
      expect(billsAgent(_snap(refunds: [w], now: now)).single.title, contains('#0139'));
    });
  });

  group('escrow (ORPay model)', () {
    EscrowDeal deal({required bool buyer, required EscrowStage stage}) => EscrowDeal(
        id: 'e', title: 'Laptop', counterparty: 'x', iAmBuyer: buyer, amountMinor: 1, stage: stage,
        log: const [], createdAt: DateTime(2026, 9, 1));

    test('each party is offered only the steps they may sign', () {
      expect(deal(buyer: true, stage: EscrowStage.awaitingFunding).stepsForMe(), isEmpty);
      expect(deal(buyer: true, stage: EscrowStage.funded).stepsForMe(),
          [EscrowStep.release, EscrowStep.dispute, EscrowStep.refund]);
      expect(deal(buyer: false, stage: EscrowStage.funded).stepsForMe(), contains(EscrowStep.dispatch));
      expect(deal(buyer: false, stage: EscrowStage.funded).stepsForMe(), isNot(contains(EscrowStep.release)));
      expect(deal(buyer: false, stage: EscrowStage.dispatched).stepsForMe(), contains(EscrowStep.claim));
      expect(deal(buyer: true, stage: EscrowStage.released).stepsForMe(), isEmpty);
    });

    test('sandbox: open, fund, dispatch, release', () async {
      final n = EscrowNotifier(SandboxEscrowCustodian());
      await n.create(title: 'Laptop', counterparty: '@seller', iAmBuyer: true, amountMinor: 85000000);
      final id = n.debugState.single.id;
      expect(n.debugState.single.stage, EscrowStage.awaitingFunding);
      n.simulateFunding(id);
      expect((await n.step(id, EscrowStep.release)).signUrl, isNull);
      expect(n.debugState.single.stage, EscrowStage.released);
    });

    test('live: a step returns a link to sign and does not change state here', () async {
      final calls = <String>[];
      final live = OpenReserveEscrowCustodian((name, data) async {
        calls.add(name);
        return switch (name) {
          'createEscrow' => {'id': 'doc1', 'orpayId': 'esc_1', 'fundingUrl': 'https://pay/fund/esc_1'},
          'escrowAction' => {'url': 'https://pay/escrow/esc_1?action=${data['action']}'},
          _ => {'status': 'cancelled'},
        };
      });
      final n = EscrowNotifier(live);
      final o = await n.create(title: 'Laptop', counterparty: '@seller', iAmBuyer: true, amountMinor: 100);
      expect(o.fundingUrl, 'https://pay/fund/esc_1');
      final id = n.debugState.single.id;
      n.applyPartnerStatus('doc1', 'funded');
      expect(n.debugState.single.stage, EscrowStage.funded);
      final out = await n.step(id, EscrowStep.release);
      expect(out.signUrl, contains('action=release'));
      expect(n.debugState.single.stage, EscrowStage.funded); // unchanged until the webhook
      n.applyPartnerStatus('doc1', 'completed');
      expect(n.debugState.single.stage, EscrowStage.released);
      expect(calls, ['createEscrow', 'escrowAction']);
    });

    test('cancel before funding', () async {
      final n = EscrowNotifier(SandboxEscrowCustodian());
      await n.create(title: 'Phone', counterparty: '@s', iAmBuyer: true, amountMinor: 100);
      expect((await n.cancel(n.debugState.single.id)).ok, isTrue);
      expect(n.debugState.single.stage, EscrowStage.cancelled);
    });
  });

}

// ── Agents: each one reacts to real data, and is silent without it ───────
AgentSnapshot _snap({
  List<AppTransaction> txs = const [],
  int balance = 0,
  List<SavingsGoal> goals = const [],
  AppTransaction? income,
  List<GuardEvent> guard = const [],
  List<SaleWindow> refunds = const [],
  List<RateWatch> watches = const [],
  DateTime? now,
}) =>
    AgentSnapshot(
      engine: IntelligenceEngine(CopilotEngine(transactions: txs, balanceNaira: balance, now: now)),
      goals: goals,
      pendingIncome: income,
      autopilot: const AutopilotState(armed: true, rules: AutopilotState.defaults, handledIncomeIds: {}),
      guardLog: guard,
      refundWindows: refunds,
      watches: watches,
      now: now ?? DateTime.now(),
    );
