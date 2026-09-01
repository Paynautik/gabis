import '../../shared/models/money.dart';
import '../../shared/models/transaction.dart';

/// Financial reasoning over the user's real transaction history.
///
/// Everything here is computed from [AppTransaction] data — no scripted
/// answers. A frontier model can sit on top of this to phrase the response and
/// handle open-ended questions, but the numbers, commitments and projections
/// are derived on-device so they stay correct and work offline.

enum SpendCategory {
  income,
  housing,
  family,
  telecom,
  utilities,
  subscriptions,
  food,
  transport,
  other,
}

extension SpendCategoryLabel on SpendCategory {
  String get label => switch (this) {
        SpendCategory.income => 'Income',
        SpendCategory.housing => 'Rent & housing',
        SpendCategory.family => 'Family support',
        SpendCategory.telecom => 'Airtime & data',
        SpendCategory.utilities => 'Utilities',
        SpendCategory.subscriptions => 'Subscriptions',
        SpendCategory.food => 'Food & groceries',
        SpendCategory.transport => 'Transport',
        SpendCategory.other => 'Other',
      };
}

/// A charge that repeats on a roughly monthly cadence.
class RecurringCommitment {
  final String counterparty;
  final String description;
  final SpendCategory category;
  final int monthlyNaira;
  final int occurrences;
  final DateTime lastSeen;

  const RecurringCommitment({
    required this.counterparty,
    required this.description,
    required this.category,
    required this.monthlyNaira,
    required this.occurrences,
    required this.lastSeen,
  });

  Money get monthly => Money(minorUnits: monthlyNaira * 100, currency: 'NGN');
}

/// A month-over-month movement in one category.
class CategoryShift {
  final SpendCategory category;
  final int thisMonthNaira;
  final int lastMonthNaira;

  const CategoryShift({
    required this.category,
    required this.thisMonthNaira,
    required this.lastMonthNaira,
  });

  double get percentChange {
    if (lastMonthNaira == 0) return 0;
    return ((thisMonthNaira - lastMonthNaira) / lastMonthNaira) * 100;
  }

  bool get isIncrease => thisMonthNaira > lastMonthNaira;
}

/// The answer to "can I afford X?".
class AffordabilityVerdict {
  final bool affordable;
  final int requestedNaira;
  final int projectedBalanceNaira;
  final int committedNaira;
  final int safeToSpendNaira;
  final int daysToPayday;
  final List<String> reasoning;
  final List<CopilotAction> actions;

  const AffordabilityVerdict({
    required this.affordable,
    required this.requestedNaira,
    required this.projectedBalanceNaira,
    required this.committedNaira,
    required this.safeToSpendNaira,
    required this.daysToPayday,
    required this.reasoning,
    required this.actions,
  });
}

/// What a payday sweep would move, and the reasoning behind the figure.
class SweepPlan {
  final int recommendedNaira;
  final int safeToSpendNaira;
  final int committedNaira;
  final int reserveNaira;
  final DateTime payday;
  final int daysToPayday;
  final List<String> reasoning;

  const SweepPlan({
    required this.recommendedNaira,
    required this.safeToSpendNaira,
    required this.committedNaira,
    required this.reserveNaira,
    required this.payday,
    required this.daysToPayday,
    required this.reasoning,
  });

  bool get hasHeadroom => recommendedNaira > 0;
}

/// Something the copilot can carry out, once the user approves it.
class CopilotAction {
  final String label;
  final String detail;
  final int? amountNaira;

  const CopilotAction({
    required this.label,
    required this.detail,
    this.amountNaira,
  });
}

class CopilotEngine {
  final List<AppTransaction> transactions;
  final int balanceNaira;
  final DateTime now;

  CopilotEngine({
    required this.transactions,
    required this.balanceNaira,
    DateTime? now,
  }) : now = now ?? DateTime.now();

  // ── categorisation ─────────────────────────────────────────────────────

  static SpendCategory categorise(AppTransaction t) {
    if (t.isCredit) return SpendCategory.income;
    final text = '${t.description ?? ''} ${t.counterparty ?? ''}'.toLowerCase();

    bool has(List<String> keys) => keys.any(text.contains);

    if (has(['rent', 'lekki', 'landlord', 'housing'])) return SpendCategory.housing;
    if (has(['family', 'support', 'mrs ', 'mr '])) return SpendCategory.family;
    if (has(['mtn', 'airtel', 'glo', 'airtime', 'data bundle'])) return SpendCategory.telecom;
    if (has(['electric', 'ikedc', 'water', 'waste', 'utility'])) return SpendCategory.utilities;
    if (has(['netflix', 'spotify', 'dstv', 'multichoice', 'gym', 'i-fitness', 'subscription', 'premium'])) {
      return SpendCategory.subscriptions;
    }
    if (has(['grocer', 'shoprite', 'restaurant', 'chicken', 'food', 'market'])) return SpendCategory.food;
    if (has(['fuel', 'total', 'bolt', 'uber', 'transport', 'ride'])) return SpendCategory.transport;
    return SpendCategory.other;
  }

  int _naira(AppTransaction t) => (t.amount.minorUnits / 100).round();

  bool _inMonth(DateTime d, int monthsAgo) {
    final target = DateTime(now.year, now.month - monthsAgo);
    return d.year == target.year && d.month == target.month;
  }

  // ── aggregates ─────────────────────────────────────────────────────────

  int spendInMonth(int monthsAgo) => transactions
      .where((t) => !t.isCredit && _inMonth(t.createdAt, monthsAgo))
      .fold(0, (sum, t) => sum + _naira(t));

  int incomeInMonth(int monthsAgo) => transactions
      .where((t) => t.isCredit && _inMonth(t.createdAt, monthsAgo))
      .fold(0, (sum, t) => sum + _naira(t));

  /// Average monthly income across the months that actually have data.
  int get averageMonthlyIncome {
    final months = <int>[];
    for (var m = 1; m <= 3; m++) {
      final v = incomeInMonth(m);
      if (v > 0) months.add(v);
    }
    if (months.isEmpty) return incomeInMonth(0);
    return months.reduce((a, b) => a + b) ~/ months.length;
  }

  Map<SpendCategory, int> categoryTotals(int monthsAgo) {
    final map = <SpendCategory, int>{};
    for (final t in transactions) {
      if (t.isCredit || !_inMonth(t.createdAt, monthsAgo)) continue;
      final c = categorise(t);
      map[c] = (map[c] ?? 0) + _naira(t);
    }
    return map;
  }

  /// Categories that moved materially since last month, biggest swing first.
  List<CategoryShift> categoryShifts({double thresholdPercent = 15}) {
    final thisMonth = categoryTotals(0);
    final lastMonth = categoryTotals(1);
    final shifts = <CategoryShift>[];

    for (final entry in thisMonth.entries) {
      final prev = lastMonth[entry.key] ?? 0;
      if (prev == 0) continue;
      final shift = CategoryShift(
        category: entry.key,
        thisMonthNaira: entry.value,
        lastMonthNaira: prev,
      );
      if (shift.percentChange.abs() >= thresholdPercent) shifts.add(shift);
    }

    shifts.sort((a, b) => b.percentChange.abs().compareTo(a.percentChange.abs()));
    return shifts;
  }

  /// Charges seen in at least two separate months from the same counterparty.
  List<RecurringCommitment> recurringCommitments() {
    final byParty = <String, List<AppTransaction>>{};
    for (final t in transactions) {
      if (t.isCredit) continue;
      final key = (t.counterparty ?? t.description ?? '').trim();
      if (key.isEmpty) continue;
      byParty.putIfAbsent(key, () => []).add(t);
    }

    final out = <RecurringCommitment>[];
    byParty.forEach((party, list) {
      final months = list.map((t) => '${t.createdAt.year}-${t.createdAt.month}').toSet();
      if (months.length < 2) return;

      final total = list.fold(0, (s, t) => s + _naira(t));
      final monthly = total ~/ months.length;
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      out.add(RecurringCommitment(
        counterparty: party,
        description: list.first.description ?? party,
        category: categorise(list.first),
        monthlyNaira: monthly,
        occurrences: list.length,
        lastSeen: list.first.createdAt,
      ));
    });

    out.sort((a, b) => b.monthlyNaira.compareTo(a.monthlyNaira));
    return out;
  }

  int get totalMonthlyCommitments =>
      recurringCommitments().fold(0, (s, c) => s + c.monthlyNaira);

  /// Discretionary subscriptions — the first place to look for slack.
  List<RecurringCommitment> trimmableSubscriptions() => recurringCommitments()
      .where((c) => c.category == SpendCategory.subscriptions)
      .toList();

  // ── projection ─────────────────────────────────────────────────────────

  /// Salary lands on the 28th in this dataset; fall back to month end.
  DateTime get nextPayday {
    final candidate = DateTime(now.year, now.month, 28);
    return candidate.isAfter(now) ? candidate : DateTime(now.year, now.month + 1, 28);
  }

  int get daysToPayday => nextPayday.difference(now).inDays.clamp(0, 60);

  /// Average daily discretionary burn, measured over the last full month.
  int get dailyBurnNaira {
    final lastMonthSpend = spendInMonth(1);
    if (lastMonthSpend == 0) return 0;
    final daysInLastMonth = DateTime(now.year, now.month, 0).day;
    return lastMonthSpend ~/ daysInLastMonth;
  }

  /// Balance expected at payday if behaviour continues unchanged.
  int get projectedBalanceAtPayday {
    final upcoming = recurringCommitments()
        .where((c) => c.lastSeen.month != now.month)
        .fold(0, (s, c) => s + c.monthlyNaira);
    return balanceNaira - (dailyBurnNaira * daysToPayday) - upcoming;
  }

  // ── the question that matters ──────────────────────────────────────────

  AffordabilityVerdict canIAfford(int amountNaira, {String? what}) {
    final committed = recurringCommitments()
        .where((c) => c.lastSeen.month != now.month)
        .fold(0, (s, c) => s + c.monthlyNaira);

    final burn = dailyBurnNaira * daysToPayday;
    final projected = balanceNaira - burn - committed;
    // Keep a week of normal spending back as a buffer.
    final buffer = dailyBurnNaira * 7;
    final safe = projected - buffer;
    final affordable = amountNaira <= safe;

    final reasoning = <String>[
      'Balance today is ${_fmt(balanceNaira)}.',
      if (committed > 0)
        'Still due before payday: ${_fmt(committed)} across ${recurringCommitments().where((c) => c.lastSeen.month != now.month).length} recurring commitments.',
      'At your recent rate of ${_fmt(dailyBurnNaira)}/day, normal spending over the next $daysToPayday days comes to ${_fmt(burn)}.',
      'That projects to ${_fmt(projected)} at payday, before this purchase.',
      'Holding back a one-week buffer of ${_fmt(buffer)} leaves ${_fmt(safe)} genuinely free.',
    ];

    final actions = <CopilotAction>[];
    if (affordable) {
      reasoning.add('${_fmt(amountNaira)} fits inside that with ${_fmt(safe - amountNaira)} to spare.');
      final spare = safe - amountNaira;
      if (spare > 20000) {
        actions.add(CopilotAction(
          label: 'Move ${_fmt((spare * 0.4) ~/ 1000 * 1000)} to savings',
          detail: 'Still leaves your buffer and this purchase covered.',
          amountNaira: (spare * 0.4) ~/ 1000 * 1000,
        ));
      }
    } else {
      final gap = amountNaira - safe;
      reasoning.add('${_fmt(amountNaira)} overshoots by ${_fmt(gap)}.');

      final trims = trimmableSubscriptions();
      final trimTotal = trims.fold(0, (s, c) => s + c.monthlyNaira);
      if (trimTotal > 0) {
        reasoning.add(
            'Cancelling ${trims.length} subscription${trims.length == 1 ? '' : 's'} would free ${_fmt(trimTotal)}/month — ${trimTotal >= gap ? 'enough to close the gap' : 'still ${_fmt(gap - trimTotal)} short'}.');
        for (final t in trims.take(2)) {
          actions.add(CopilotAction(
            label: 'Cancel ${t.counterparty}',
            detail: 'Frees ${_fmt(t.monthlyNaira)} every month.',
            amountNaira: t.monthlyNaira,
          ));
        }
      }
      actions.add(CopilotAction(
        label: 'Split across two months',
        detail: 'Pay ${_fmt(amountNaira ~/ 2)} now and the rest after payday.',
        amountNaira: amountNaira ~/ 2,
      ));
    }

    return AffordabilityVerdict(
      affordable: affordable,
      requestedNaira: amountNaira,
      projectedBalanceNaira: projected,
      committedNaira: committed,
      safeToSpendNaira: safe,
      daysToPayday: daysToPayday,
      reasoning: reasoning,
      actions: actions,
    );
  }

  /// What is genuinely spare on payday, after commitments still due, normal
  /// spending, and a reserve the user keeps back. Rounded down to the nearest
  /// thousand so the number reads like a decision rather than a calculation.
  SweepPlan computeSweep({double reserveWeeks = 2}) {
    final committed = recurringCommitments()
        .where((c) => c.lastSeen.month != now.month)
        .fold(0, (s, c) => s + c.monthlyNaira);

    final burn = dailyBurnNaira * daysToPayday;
    final reserve = (dailyBurnNaira * 7 * reserveWeeks).round();
    final projected = balanceNaira - burn - committed;
    final spare = projected - reserve;
    final recommended = spare <= 0 ? 0 : (spare ~/ 1000) * 1000;

    final reasoning = <String>[
      'Balance today is ${_fmt(balanceNaira)}.',
      if (committed > 0)
        'Still due before payday: ${_fmt(committed)}.',
      'Normal spending over $daysToPayday days at ${_fmt(dailyBurnNaira)}/day comes to ${_fmt(burn)}.',
      'Keeping a ${reserveWeeks.toStringAsFixed(0)}-week reserve of ${_fmt(reserve)} back.',
      recommended > 0
          ? 'That leaves ${_fmt(recommended)} genuinely spare to move.'
          : 'Nothing is spare this cycle — the sweep will sit out.',
    ];

    return SweepPlan(
      recommendedNaira: recommended,
      safeToSpendNaira: spare,
      committedNaira: committed,
      reserveNaira: reserve,
      payday: nextPayday,
      daysToPayday: daysToPayday,
      reasoning: reasoning,
    );
  }

  static String _fmt(int naira) {
    final s = naira.abs().toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return '${naira < 0 ? '-' : ''}₦$buf';
  }

  static String formatNaira(int naira) => _fmt(naira);
}
