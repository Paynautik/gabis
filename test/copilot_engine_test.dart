import 'package:flutter_test/flutter_test.dart';
import 'package:nautik_money/features/copilot/copilot_engine.dart';
import 'package:nautik_money/shared/providers/app_providers.dart';

void main() {
  test('copilot reasons over the seeded history', () {
    final txs = TransactionsNotifier().state;
    final engine = CopilotEngine(transactions: txs, balanceNaira: 1250000);

    print('transactions: ${txs.length}');
    print('avg monthly income: ${CopilotEngine.formatNaira(engine.averageMonthlyIncome)}');
    print('spent this month: ${CopilotEngine.formatNaira(engine.spendInMonth(0))}');
    print('monthly commitments: ${CopilotEngine.formatNaira(engine.totalMonthlyCommitments)}');
    print('daily burn: ${CopilotEngine.formatNaira(engine.dailyBurnNaira)}');
    print('days to payday: ${engine.daysToPayday}');
    print('projected at payday: ${CopilotEngine.formatNaira(engine.projectedBalanceAtPayday)}');

    print('\nrecurring detected:');
    for (final c in engine.recurringCommitments().take(6)) {
      print('  ${c.counterparty}: ${CopilotEngine.formatNaira(c.monthlyNaira)}/mo x${c.occurrences} [${c.category.label}]');
    }

    print('\ncategory shifts:');
    for (final s in engine.categoryShifts()) {
      print('  ${s.category.label}: ${s.percentChange.toStringAsFixed(0)}%');
    }

    print('\ntrimmable subs: ${engine.trimmableSubscriptions().map((c) => c.counterparty).join(", ")}');

    final v = engine.canIAfford(250000);
    print('\nQ: can I afford ₦250,000?  -> ${v.affordable ? "YES" : "NO"}');
    for (final r in v.reasoning) {
      print('  - $r');
    }
    print('  actions: ${v.actions.map((a) => a.label).join(" | ")}');

    expect(txs.length, greaterThan(30));
    expect(engine.recurringCommitments(), isNotEmpty);
    expect(engine.totalMonthlyCommitments, greaterThan(0));
  });
}
