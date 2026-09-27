import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/local_json.dart';
import '../../shared/models/transaction.dart';
import '../../shared/providers/app_providers.dart';
import '../copilot/copilot_engine.dart';
import 'intelligence_engine.dart';

/// The engine for whoever is signed in, rebuilt when their money changes.
final intelligenceEngineProvider = Provider<IntelligenceEngine>((ref) {
  final txs = ref.watch(transactionsProvider);
  final total = ref.watch(totalBalanceNgnProvider);
  return IntelligenceEngine(CopilotEngine(
    transactions: txs,
    balanceNaira: (total.minorUnits / 100).round(),
  ));
});

// ── Goals ────────────────────────────────────────────────────────────────

class SavingsGoal {
  final String id;
  final String name;
  final int targetNaira;
  final int savedNaira;
  final DateTime deadline;
  final DateTime createdAt;

  const SavingsGoal({
    required this.id,
    required this.name,
    required this.targetNaira,
    required this.savedNaira,
    required this.deadline,
    required this.createdAt,
  });

  SavingsGoal copyWith({int? savedNaira}) => SavingsGoal(
        id: id,
        name: name,
        targetNaira: targetNaira,
        savedNaira: savedNaira ?? this.savedNaira,
        deadline: deadline,
        createdAt: createdAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'target': targetNaira,
        'saved': savedNaira,
        'deadline': deadline.toIso8601String(),
        'created': createdAt.toIso8601String(),
      };

  static SavingsGoal? fromJson(Map<String, dynamic> j) {
    final deadline = readDate(j['deadline']);
    if (deadline == null || j['target'] is! int) return null;
    return SavingsGoal(
      id: '${j['id']}',
      name: '${j['name'] ?? 'Goal'}',
      targetNaira: j['target'] as int,
      savedNaira: (j['saved'] as int?) ?? 0,
      deadline: deadline,
      createdAt: readDate(j['created']) ?? DateTime.now(),
    );
  }
}

class GoalsNotifier extends StateNotifier<List<SavingsGoal>> {
  GoalsNotifier()
      : super(readJsonList(_key).map(SavingsGoal.fromJson).whereType<SavingsGoal>().toList());

  static const _key = 'gabis.goals.v1';

  void _save() => writeJson(_key, state.map((g) => g.toJson()).toList());

  SavingsGoal add({required String name, required int targetNaira, required DateTime deadline}) {
    final g = SavingsGoal(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.trim().isEmpty ? 'Savings goal' : name.trim(),
      targetNaira: targetNaira,
      savedNaira: 0,
      deadline: deadline,
      createdAt: DateTime.now(),
    );
    state = [...state, g];
    _save();
    return g;
  }

  /// Records a contribution the user approved. It moves nothing by itself.
  void contribute(String id, int naira) {
    state = [
      for (final g in state)
        if (g.id == id) g.copyWith(savedNaira: (g.savedNaira + naira).clamp(0, g.targetNaira)) else g
    ];
    _save();
  }

  void remove(String id) {
    state = state.where((g) => g.id != id).toList();
    _save();
  }
}

final goalsProvider =
    StateNotifierProvider<GoalsNotifier, List<SavingsGoal>>((ref) => GoalsNotifier());

// ── Autopilot (income waterfall) ─────────────────────────────────────────

/// One step of the waterfall: a fixed amount or a share of what is left.
class WaterfallRule {
  final String id;
  final String label;
  final int? fixedNaira;
  final double? percentOfRemainder;

  const WaterfallRule({required this.id, required this.label, this.fixedNaira, this.percentOfRemainder});

  Map<String, dynamic> toJson() =>
      {'id': id, 'label': label, 'fixed': fixedNaira, 'pct': percentOfRemainder};

  static WaterfallRule fromJson(Map<String, dynamic> j) => WaterfallRule(
        id: '${j['id']}',
        label: '${j['label']}',
        fixedNaira: j['fixed'] as int?,
        percentOfRemainder: (j['pct'] as num?)?.toDouble(),
      );
}

class WaterfallStep {
  final String label;
  final int naira;
  const WaterfallStep(this.label, this.naira);
}

class AutopilotState {
  final bool armed;
  final List<WaterfallRule> rules;

  /// Income transactions already offered, so the same salary is not split twice.
  final Set<String> handledIncomeIds;

  const AutopilotState({required this.armed, required this.rules, required this.handledIncomeIds});

  static const defaults = [
    WaterfallRule(id: 'bills', label: 'Bills & Rent', fixedNaira: 180000),
    WaterfallRule(id: 'save', label: 'Savings', percentOfRemainder: 0.25),
    WaterfallRule(id: 'invest', label: 'Long-term', percentOfRemainder: 0.10),
  ];

  /// Splits [incomeNaira] top to bottom. Whatever is left is safe to spend.
  List<WaterfallStep> split(int incomeNaira) {
    var left = incomeNaira;
    final out = <WaterfallStep>[];
    for (final r in rules) {
      final want = r.fixedNaira ?? ((left * (r.percentOfRemainder ?? 0)) ~/ 1000 * 1000);
      final take = want.clamp(0, left);
      out.add(WaterfallStep(r.label, take));
      left -= take;
    }
    out.add(WaterfallStep('Safe to spend', left));
    return out;
  }
}

class AutopilotNotifier extends StateNotifier<AutopilotState> {
  AutopilotNotifier() : super(_load());

  static const _key = 'gabis.autopilot.v1';

  static AutopilotState _load() {
    final j = readJsonMap(_key);
    if (j == null) {
      return const AutopilotState(armed: false, rules: AutopilotState.defaults, handledIncomeIds: {});
    }
    final rules = (j['rules'] as List?)
            ?.whereType<Map<String, dynamic>>()
            .map(WaterfallRule.fromJson)
            .toList() ??
        AutopilotState.defaults;
    return AutopilotState(
      armed: j['armed'] == true,
      rules: rules,
      handledIncomeIds: ((j['handled'] as List?) ?? const []).map((e) => '$e').toSet(),
    );
  }

  void _save() => writeJson(_key, {
        'armed': state.armed,
        'rules': state.rules.map((r) => r.toJson()).toList(),
        'handled': state.handledIncomeIds.toList(),
      });

  void setArmed(bool v) {
    state = AutopilotState(armed: v, rules: state.rules, handledIncomeIds: state.handledIncomeIds);
    _save();
  }

  void setRules(List<WaterfallRule> rules) {
    state = AutopilotState(armed: state.armed, rules: rules, handledIncomeIds: state.handledIncomeIds);
    _save();
  }

  void markHandled(String incomeId) {
    state = AutopilotState(
        armed: state.armed, rules: state.rules, handledIncomeIds: {...state.handledIncomeIds, incomeId});
    _save();
  }
}

final autopilotProvider =
    StateNotifierProvider<AutopilotNotifier, AutopilotState>((ref) => AutopilotNotifier());

/// The newest income the user has not yet split, if autopilot is armed.
final pendingIncomeProvider = Provider<AppTransaction?>((ref) {
  final ap = ref.watch(autopilotProvider);
  if (!ap.armed) return null;
  final txs = ref.watch(transactionsProvider);
  final incomes = txs
      .where((t) => t.isCredit && t.status == TransactionStatus.completed && t.amount.minorUnits >= 5000000)
      .where((t) => !ap.handledIncomeIds.contains(t.id))
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  if (incomes.isEmpty) return null;
  // Only recent pay counts; last year's salary is history, not a prompt.
  final latest = incomes.first;
  return DateTime.now().difference(latest.createdAt).inDays <= 7 ? latest : null;
});

// ── Friday Roast preference ──────────────────────────────────────────────

class RoastPrefs {
  final bool enabled;
  final bool spicy;
  const RoastPrefs({this.enabled = true, this.spicy = true});
}

class RoastNotifier extends StateNotifier<RoastPrefs> {
  RoastNotifier() : super(_load());
  static const _key = 'gabis.roast.v1';
  static RoastPrefs _load() {
    final j = readJsonMap(_key);
    return RoastPrefs(enabled: j?['enabled'] != false, spicy: j?['spicy'] != false);
  }

  void set({bool? enabled, bool? spicy}) {
    state = RoastPrefs(enabled: enabled ?? state.enabled, spicy: spicy ?? state.spicy);
    writeJson(_key, {'enabled': state.enabled, 'spicy': state.spicy});
  }
}

final roastPrefsProvider = StateNotifierProvider<RoastNotifier, RoastPrefs>((ref) => RoastNotifier());
