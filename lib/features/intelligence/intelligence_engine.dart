import '../copilot/copilot_engine.dart';

/// Forecasts, goal plans and the Friday Roast, all derived from the same
/// transaction history the copilot reads. Nothing here is scripted: with no
/// history the forecast is flat and the roast says it has nothing to go on.

class ForecastPoint {
  final int day;
  final DateTime date;
  final int balanceNaira;
  final bool isPayday;

  const ForecastPoint({
    required this.day,
    required this.date,
    required this.balanceNaira,
    this.isPayday = false,
  });
}

class Forecast {
  final List<ForecastPoint> points;
  final int safeTodayNaira;
  final int lowestNaira;
  final DateTime lowestOn;

  const Forecast({
    required this.points,
    required this.safeTodayNaira,
    required this.lowestNaira,
    required this.lowestOn,
  });

  int at(int day) => points[day.clamp(0, points.length - 1)].balanceNaira;
}

class GoalPlan {
  final int targetNaira;
  final int savedNaira;
  final DateTime deadline;
  final int monthsLeft;
  final int monthlyNaira;

  /// What the forecast says is spare each month; null when there is no
  /// income history to judge by.
  final int? spareMonthlyNaira;

  const GoalPlan({
    required this.targetNaira,
    required this.savedNaira,
    required this.deadline,
    required this.monthsLeft,
    required this.monthlyNaira,
    required this.spareMonthlyNaira,
  });

  bool get onTrack => spareMonthlyNaira == null || monthlyNaira <= spareMonthlyNaira!;
  double get progress => targetNaira == 0 ? 0 : (savedNaira / targetNaira).clamp(0, 1);
}

class WhatIf {
  final int extraMonthlyNaira;
  final DateTime? goalBefore;
  final DateTime? goalAfter;
  final int payday30Before;
  final int payday30After;

  const WhatIf({
    required this.extraMonthlyNaira,
    required this.goalBefore,
    required this.goalAfter,
    required this.payday30Before,
    required this.payday30After,
  });
}

class IntelligenceEngine {
  final CopilotEngine core;
  IntelligenceEngine(this.core);

  DateTime get _today => DateTime(core.now.year, core.now.month, core.now.day);

  /// Commitments still due this month, keyed by the day they usually land.
  Map<int, int> _dueByDayOfMonth() {
    final out = <int, int>{};
    for (final c in core.recurringCommitments()) {
      out.update(c.lastSeen.day, (v) => v + c.monthlyNaira, ifAbsent: () => c.monthlyNaira);
    }
    return out;
  }

  /// Everyday spending per day, with recurring commitments taken out so they
  /// are not counted twice (they are applied on their own dates).
  int get discretionaryDailyNaira {
    final lastMonthSpend = core.spendInMonth(1);
    if (lastMonthSpend == 0) return 0;
    final days = DateTime(core.now.year, core.now.month, 0).day;
    final discretionary = lastMonthSpend - core.totalMonthlyCommitments;
    return (discretionary <= 0 ? 0 : discretionary) ~/ days;
  }

  /// Day-by-day balance for the next [days] days: income on payday,
  /// commitments on the day they usually leave, everyday spending in between.
  Forecast forecast({int days = 30, int extraMonthlyNaira = 0}) {
    final due = _dueByDayOfMonth();
    final income = core.averageMonthlyIncome;
    final daily = discretionaryDailyNaira + extraMonthlyNaira ~/ 30;
    final payday = core.nextPayday;

    var balance = core.balanceNaira;
    final points = <ForecastPoint>[
      ForecastPoint(day: 0, date: _today, balanceNaira: balance),
    ];
    for (var d = 1; d <= days; d++) {
      final date = _today.add(Duration(days: d));
      balance -= daily;
      balance -= due[date.day] ?? 0;
      final isPayday = date.day == payday.day;
      if (isPayday) balance += income;
      points.add(ForecastPoint(day: d, date: date, balanceNaira: balance, isPayday: isPayday));
    }

    var lowest = points.first;
    for (final p in points) {
      if (p.balanceNaira < lowest.balanceNaira) lowest = p;
    }

    // Safe to spend today: what can go without the balance dipping below a
    // one-week buffer before the next payday.
    final beforePayday = points.where((p) => !p.date.isAfter(payday)).toList();
    final floor = beforePayday.isEmpty
        ? balance
        : beforePayday.map((p) => p.balanceNaira).reduce((a, b) => a < b ? a : b);
    final buffer = discretionaryDailyNaira * 7;
    final safe = floor - buffer;

    return Forecast(
      points: points,
      safeTodayNaira: safe < 0 ? 0 : safe,
      lowestNaira: lowest.balanceNaira,
      lowestOn: lowest.date,
    );
  }

  /// What a month of income minus commitments and everyday spending leaves.
  int? get spareMonthlyNaira {
    final income = core.averageMonthlyIncome;
    if (income == 0) return null;
    return income - core.totalMonthlyCommitments - discretionaryDailyNaira * 30;
  }

  GoalPlan planGoal({
    required int targetNaira,
    required DateTime deadline,
    int savedNaira = 0,
  }) {
    final months = _monthsBetween(_today, deadline);
    final remaining = (targetNaira - savedNaira).clamp(0, targetNaira);
    final monthly = months <= 0 ? remaining : (remaining / months).ceil();
    return GoalPlan(
      targetNaira: targetNaira,
      savedNaira: savedNaira,
      deadline: deadline,
      monthsLeft: months,
      monthlyNaira: (monthly / 1000).ceil() * 1000,
      spareMonthlyNaira: spareMonthlyNaira,
    );
  }

  /// When a goal would be reached if every spare naira went to it.
  DateTime? goalReachedOn({required int targetNaira, int savedNaira = 0, int extraMonthlyNaira = 0}) {
    final spare = spareMonthlyNaira;
    if (spare == null) return null;
    final perMonth = spare - extraMonthlyNaira;
    if (perMonth <= 0) return null;
    final remaining = targetNaira - savedNaira;
    if (remaining <= 0) return _today;
    final days = (remaining / perMonth * 30.4).ceil();
    return _today.add(Duration(days: days));
  }

  /// "If I spend ₦80k more a month on dining, what happens?"
  WhatIf whatIf({required int extraMonthlyNaira, int? goalTargetNaira, int goalSavedNaira = 0}) {
    final before = forecast();
    final after = forecast(extraMonthlyNaira: extraMonthlyNaira);
    return WhatIf(
      extraMonthlyNaira: extraMonthlyNaira,
      goalBefore: goalTargetNaira == null
          ? null
          : goalReachedOn(targetNaira: goalTargetNaira, savedNaira: goalSavedNaira),
      goalAfter: goalTargetNaira == null
          ? null
          : goalReachedOn(
              targetNaira: goalTargetNaira,
              savedNaira: goalSavedNaira,
              extraMonthlyNaira: extraMonthlyNaira),
      payday30Before: before.at(30),
      payday30After: after.at(30),
    );
  }

  // ── Friday Roast ─────────────────────────────────────────────────────

  /// A few lines of accountability, written from this month's real numbers.
  /// [spicy] only changes the tone, never the figures.
  List<String> roast({bool spicy = true}) {
    final lines = <String>[];
    final totals = core.categoryTotals(0)..remove(SpendCategory.income);
    final spent = core.spendInMonth(0);
    final lastMonth = core.spendInMonth(1);
    final fmt = CopilotEngine.formatNaira;

    if (spent == 0) {
      return ['Nothing to roast yet. Spend some money and come back on Friday.'];
    }

    final top = totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    if (top.isNotEmpty) {
      final c = top.first;
      lines.add(spicy
          ? '${fmt(c.value)} on ${c.key.label.toLowerCase()} this month. At this point it is not spending, it is a lifestyle.'
          : 'Your biggest category this month is ${c.key.label.toLowerCase()} at ${fmt(c.value)}.');
    }

    for (final s in core.categoryShifts().where((s) => s.isIncrease).take(1)) {
      lines.add(spicy
          ? '${s.category.label} is up ${s.percentChange.toStringAsFixed(0)}% on last month. Whatever you are doing, the vendors love you.'
          : '${s.category.label} rose ${s.percentChange.toStringAsFixed(0)}% compared with last month.');
    }

    final subs = core.trimmableSubscriptions();
    if (subs.length >= 2) {
      final total = subs.fold(0, (s, c) => s + c.monthlyNaira);
      lines.add(spicy
          ? '${subs.length} subscriptions costing ${fmt(total)} a month. Be honest: which one did you open this week?'
          : 'You pay ${fmt(total)} a month across ${subs.length} subscriptions.');
    }

    if (lastMonth > 0) {
      lines.add(spent < lastMonth
          ? (spicy
              ? 'Good news: you have spent ${fmt(lastMonth - spent)} less than last month. Bad news: the month is not over.'
              : 'You are ${fmt(lastMonth - spent)} under last month so far.')
          : (spicy
              ? 'You have already outspent last month by ${fmt(spent - lastMonth)}. Bold.'
              : 'You are ${fmt(spent - lastMonth)} over last month.'));
    }
    return lines;
  }

  static int _monthsBetween(DateTime a, DateTime b) {
    final m = (b.year - a.year) * 12 + (b.month - a.month);
    return m < 1 ? 1 : m;
  }
}
