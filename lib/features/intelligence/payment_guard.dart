import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/local_json.dart';
import '../../shared/models/transaction.dart';
import '../../shared/providers/app_providers.dart';

/// The Financial Firewall: a second opinion before money leaves.
///
/// It never blocks on its own. It explains what looks unusual and asks the
/// person to review; they can always approve. Signals are deliberately plain
/// so the explanation can be read back word for word.

class GuardSignal {
  final String reason;
  final int weight;
  const GuardSignal(this.reason, this.weight);
}

class GuardVerdict {
  final List<GuardSignal> signals;
  const GuardVerdict(this.signals);

  int get score => signals.fold(0, (s, g) => s + g.weight);

  /// Two independent signals, or one strong one, earn a pause.
  bool get shouldPause => score >= 3;
}

class PaymentGuard {
  final List<AppTransaction> history;
  final DateTime now;

  PaymentGuard(this.history, {DateTime? now}) : now = now ?? DateTime.now();

  int get _averageOutgoingMinor {
    final out = history
        .where((t) => !t.isCredit && t.type == TransactionType.transfer && t.status == TransactionStatus.completed)
        .map((t) => t.amount.minorUnits)
        .toList();
    if (out.isEmpty) return 0;
    return out.reduce((a, b) => a + b) ~/ out.length;
  }

  GuardVerdict check({
    required String recipient,
    required int amountMinor,
    DateTime? recipientAddedAt,
  }) {
    final signals = <GuardSignal>[];
    final name = recipient.trim().toLowerCase();

    final paidBefore = history.any((t) => !t.isCredit && (t.counterparty ?? '').trim().toLowerCase() == name);
    if (!paidBefore) {
      signals.add(const GuardSignal('First payment to this recipient', 2));
    }

    final avg = _averageOutgoingMinor;
    if (avg > 0 && amountMinor >= avg * 4) {
      final times = (amountMinor / avg).toStringAsFixed(1);
      signals.add(GuardSignal('Amount is $times× your average transfer', amountMinor >= avg * 7 ? 3 : 2));
    }

    if (recipientAddedAt != null && now.difference(recipientAddedAt).inMinutes < 30) {
      final mins = now.difference(recipientAddedAt).inMinutes;
      signals.add(GuardSignal('Recipient added ${mins < 1 ? 'just now' : '$mins minutes ago'}', 2));
    }

    final hour = now.hour;
    if (amountMinor >= 10000000 && (hour < 5 || hour >= 23)) {
      signals.add(const GuardSignal('Large transfer late at night', 1));
    }

    return GuardVerdict(signals);
  }
}

final paymentGuardProvider = Provider<PaymentGuard>((ref) => PaymentGuard(ref.watch(transactionsProvider)));

// ── What the firewall has stopped ────────────────────────────────────────

class GuardEvent {
  final String recipient;
  final int amountMinor;
  final List<String> reasons;
  final String outcome; // 'reviewed', 'approved', 'cancelled'
  final DateTime at;

  const GuardEvent({
    required this.recipient,
    required this.amountMinor,
    required this.reasons,
    required this.outcome,
    required this.at,
  });

  Map<String, dynamic> toJson() => {
        'r': recipient,
        'a': amountMinor,
        'why': reasons,
        'o': outcome,
        'at': at.toIso8601String(),
      };

  static GuardEvent? fromJson(Map<String, dynamic> j) {
    final at = readDate(j['at']);
    if (at == null) return null;
    return GuardEvent(
      recipient: '${j['r']}',
      amountMinor: (j['a'] as int?) ?? 0,
      reasons: ((j['why'] as List?) ?? const []).map((e) => '$e').toList(),
      outcome: '${j['o']}',
      at: at,
    );
  }
}

class GuardLogNotifier extends StateNotifier<List<GuardEvent>> {
  GuardLogNotifier() : super(readJsonList(_key).map(GuardEvent.fromJson).whereType<GuardEvent>().toList());
  static const _key = 'gabis.firewall.log.v1';

  void record(GuardEvent e) {
    state = [e, ...state].take(50).toList();
    writeJson(_key, state.map((x) => x.toJson()).toList());
  }
}

final guardLogProvider = StateNotifierProvider<GuardLogNotifier, List<GuardEvent>>((ref) => GuardLogNotifier());
