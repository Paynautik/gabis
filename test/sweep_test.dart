import 'package:flutter_test/flutter_test.dart';
import 'package:nautik_money/features/copilot/copilot_engine.dart';
import 'package:nautik_money/features/copilot/sweep_store.dart';
import 'package:nautik_money/shared/providers/app_providers.dart';

void main() {
  test('sweep computes real headroom and respects the cap', () {
    final txs = TransactionsNotifier().state;
    final engine = CopilotEngine(transactions: txs, balanceNaira: 1250000);
    final plan = engine.computeSweep(reserveWeeks: 2);

    print('recommended: ${CopilotEngine.formatNaira(plan.recommendedNaira)}');
    print('reserve held: ${CopilotEngine.formatNaira(plan.reserveNaira)}');
    print('days to payday: ${plan.daysToPayday}');
    for (final r in plan.reasoning) {
      print('  - $r');
    }

    final notifier = SweepNotifier();
    notifier.setCap(200000);
    final moved = notifier.sweep(plan.recommendedNaira);
    print('moved after cap: ${CopilotEngine.formatNaira(moved)}');
    print('savings now: ${CopilotEngine.formatNaira(notifier.state.savingsNaira)}');

    expect(plan.recommendedNaira, greaterThan(0));
    expect(moved, lessThanOrEqualTo(200000));
    expect(notifier.state.savingsNaira, moved);

    notifier.undoLast();
    expect(notifier.state.savingsNaira, 0);
    print('undo restored savings to zero');
  });
}
