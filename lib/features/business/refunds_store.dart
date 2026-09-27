import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/local_json.dart';

/// Refund windows: every sale gets a policy (7 or 14 days by default) and a
/// countdown, so the seller knows exactly when a return stops being their
/// problem and is warned the day before it closes.

enum RefundStatus { open, requested, refunded, closed }

class SaleWindow {
  final String id;
  final String orderRef;
  final String customer;
  final int amountMinor;
  final int policyDays;
  final DateTime soldAt;
  final RefundStatus status;

  const SaleWindow({
    required this.id,
    required this.orderRef,
    required this.customer,
    required this.amountMinor,
    required this.policyDays,
    required this.soldAt,
    required this.status,
  });

  DateTime get closesAt => soldAt.add(Duration(days: policyDays));

  Duration remaining([DateTime? now]) {
    final d = closesAt.difference(now ?? DateTime.now());
    return d.isNegative ? Duration.zero : d;
  }

  /// The status as of [now]: an open window past its date is closed even if
  /// nobody has opened the app since.
  RefundStatus effectiveStatus([DateTime? now]) =>
      status == RefundStatus.open && !(now ?? DateTime.now()).isBefore(closesAt) ? RefundStatus.closed : status;

  bool closingSoon([DateTime? now]) {
    final r = remaining(now);
    return effectiveStatus(now) == RefundStatus.open && r > Duration.zero && r <= const Duration(hours: 24);
  }

  /// Share of the window already used, for the countdown ring.
  double elapsedFraction([DateTime? now]) {
    final total = policyDays * 24 * 60;
    final used = (now ?? DateTime.now()).difference(soldAt).inMinutes;
    return (used / total).clamp(0, 1).toDouble();
  }

  SaleWindow withStatus(RefundStatus s) => SaleWindow(
        id: id,
        orderRef: orderRef,
        customer: customer,
        amountMinor: amountMinor,
        policyDays: policyDays,
        soldAt: soldAt,
        status: s,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'o': orderRef,
        'c': customer,
        'a': amountMinor,
        'p': policyDays,
        'at': soldAt.toIso8601String(),
        's': status.name,
      };

  static SaleWindow? fromJson(Map<String, dynamic> j) {
    final at = readDate(j['at']);
    if (at == null) return null;
    return SaleWindow(
      id: '${j['id']}',
      orderRef: '${j['o']}',
      customer: '${j['c']}',
      amountMinor: (j['a'] as int?) ?? 0,
      policyDays: (j['p'] as int?) ?? 14,
      soldAt: at,
      status: RefundStatus.values.firstWhere((s) => s.name == j['s'], orElse: () => RefundStatus.open),
    );
  }
}

class RefundWindowsNotifier extends StateNotifier<List<SaleWindow>> {
  RefundWindowsNotifier()
      : super(readJsonList(_key).map(SaleWindow.fromJson).whereType<SaleWindow>().toList());

  static const _key = 'gabis.refunds.v1';

  void _save() => writeJson(_key, state.map((w) => w.toJson()).toList());

  void add({
    required String orderRef,
    required String customer,
    required int amountMinor,
    required int policyDays,
    DateTime? soldAt,
  }) {
    state = [
      SaleWindow(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        orderRef: orderRef,
        customer: customer,
        amountMinor: amountMinor,
        policyDays: policyDays,
        soldAt: soldAt ?? DateTime.now(),
        status: RefundStatus.open,
      ),
      ...state,
    ];
    _save();
  }

  void setStatus(String id, RefundStatus s) {
    state = [for (final w in state) if (w.id == id) w.withStatus(s) else w];
    _save();
  }

  void remove(String id) {
    state = state.where((w) => w.id != id).toList();
    _save();
  }
}

final refundWindowsProvider =
    StateNotifierProvider<RefundWindowsNotifier, List<SaleWindow>>((ref) => RefundWindowsNotifier());

/// Windows that close within a day: the reminder list.
final refundsClosingSoonProvider = Provider<List<SaleWindow>>(
    (ref) => ref.watch(refundWindowsProvider).where((w) => w.closingSoon()).toList());
