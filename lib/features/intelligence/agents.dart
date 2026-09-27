import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/local_json.dart';
import '../../shared/models/transaction.dart';
import '../../shared/providers/app_providers.dart';
import '../business/refunds_store.dart';
import '../copilot/copilot_engine.dart';
import '../partners/partner_rails.dart';
import '../partners/partner_stores.dart';
import 'intelligence_engine.dart';
import 'intelligence_stores.dart';
import 'payment_guard.dart';

/// The five agents. Each is a set of rules that reads the user's own data,
/// finds something that needs attention, and proposes one concrete action.
/// Nothing here is scripted: with no data, an agent has nothing to say.
///
/// Agents propose; people approve. The only thing an agent does on its own
/// is what the user explicitly allowed it to do (the FX agent converting when
/// a watch has "convert automatically" switched on).

enum AgentKind { money, security, fx, wealth, bills }

enum Severity { info, warn, urgent }

enum ActionKind { open, approveSplit, contribute, none }

class AgentFinding {
  /// Stable per situation, so dismissing it keeps it dismissed until the
  /// situation changes (a new date, a new amount).
  final String id;
  final AgentKind agent;
  final Severity severity;
  final String title;
  final String detail;
  final String? actionLabel;
  final ActionKind action;
  final int? tab;
  final String? targetId;
  final int? amountNaira;

  const AgentFinding({
    required this.id,
    required this.agent,
    required this.severity,
    required this.title,
    required this.detail,
    this.actionLabel,
    this.action = ActionKind.none,
    this.tab,
    this.targetId,
    this.amountNaira,
  });
}

String _n(int v) => CopilotEngine.formatNaira(v);
const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
String _d(DateTime d) => '${d.day} ${_months[d.month - 1]}';

/// Everything the agents read, gathered once so the rules stay pure.
class AgentSnapshot {
  final IntelligenceEngine engine;
  final List<SavingsGoal> goals;
  final AppTransaction? pendingIncome;
  final AutopilotState autopilot;
  final List<GuardEvent> guardLog;
  final List<SaleWindow> refundWindows;
  final List<RateWatch> watches;
  final DateTime now;

  const AgentSnapshot({
    required this.engine,
    required this.goals,
    required this.pendingIncome,
    required this.autopilot,
    required this.guardLog,
    required this.refundWindows,
    required this.watches,
    required this.now,
  });
}

// ── Money Agent: cash flow ────────────────────────────────────────────────

List<AgentFinding> moneyAgent(AgentSnapshot s) {
  final out = <AgentFinding>[];
  if (s.engine.core.transactions.isEmpty) return out;
  final f = s.engine.forecast();
  final buffer = s.engine.discretionaryDailyNaira * 7;

  if (f.lowestNaira < 0) {
    out.add(AgentFinding(
      id: 'money.short.${f.lowestOn.toIso8601String().substring(0, 10)}',
      agent: AgentKind.money,
      severity: Severity.urgent,
      title: 'You will run short on ${_d(f.lowestOn)}',
      detail: 'At your usual pace your balance falls to ${_n(f.lowestNaira)} before money comes in. '
          'Cutting ${_n(-f.lowestNaira ~/ 1000 * 1000 + 1000)} of spending before then avoids it.',
      actionLabel: 'See the forecast',
      action: ActionKind.open,
      tab: HomeTab.intelligence,
    ));
  } else if (buffer > 0 && f.lowestNaira < buffer) {
    out.add(AgentFinding(
      id: 'money.thin.${f.lowestOn.toIso8601String().substring(0, 10)}',
      agent: AgentKind.money,
      severity: Severity.warn,
      title: 'Your cushion gets thin around ${_d(f.lowestOn)}',
      detail: 'Your balance dips to ${_n(f.lowestNaira)}, under a week of normal spending (${_n(buffer)}).',
      actionLabel: 'See the forecast',
      action: ActionKind.open,
      tab: HomeTab.intelligence,
    ));
  }
  return out;
}

// ── Bills Agent: what is about to leave ───────────────────────────────────

List<AgentFinding> billsAgent(AgentSnapshot s) {
  final out = <AgentFinding>[];
  final today = DateTime(s.now.year, s.now.month, s.now.day);

  for (final c in s.engine.core.recurringCommitments()) {
    // Already paid this month: nothing to warn about.
    if (c.lastSeen.year == s.now.year && c.lastSeen.month == s.now.month) continue;
    var due = DateTime(s.now.year, s.now.month, c.lastSeen.day);
    if (due.isBefore(today)) continue;
    final days = due.difference(today).inDays;
    if (days > 3) continue;
    out.add(AgentFinding(
      id: 'bills.due.${c.counterparty}.${due.month}',
      agent: AgentKind.bills,
      severity: days <= 1 ? Severity.warn : Severity.info,
      title: '${c.counterparty} ${_n(c.monthlyNaira)} due ${days == 0 ? 'today' : days == 1 ? 'tomorrow' : 'in $days days'}',
      detail: 'Seen ${c.occurrences} times before, usually around the ${c.lastSeen.day}${_th(c.lastSeen.day)}.',
    ));
  }

  final subs = s.engine.core.trimmableSubscriptions();
  if (subs.length >= 3) {
    final total = subs.fold(0, (a, c) => a + c.monthlyNaira);
    out.add(AgentFinding(
      id: 'bills.subs.${subs.length}.$total',
      agent: AgentKind.bills,
      severity: Severity.info,
      title: '${subs.length} subscriptions cost ${_n(total)} a month',
      detail: subs.map((c) => '${c.counterparty} ${_n(c.monthlyNaira)}').join(' · '),
      actionLabel: 'Ask the copilot what to cancel',
      action: ActionKind.open,
      tab: HomeTab.copilot,
    ));
  }

  for (final w in s.refundWindows.where((w) => w.closingSoon(s.now))) {
    out.add(AgentFinding(
      id: 'bills.refund.${w.id}',
      agent: AgentKind.bills,
      severity: Severity.warn,
      title: 'Refund window for ${w.orderRef} closes within 24 hours',
      detail: '${w.customer} · ${w.policyDays}-day policy. After it closes, the sale is final.',
    ));
  }
  return out;
}

String _th(int d) => (d >= 11 && d <= 13)
    ? 'th'
    : switch (d % 10) { 1 => 'st', 2 => 'nd', 3 => 'rd', _ => 'th' };

// ── Wealth Agent: goals and income ────────────────────────────────────────

List<AgentFinding> wealthAgent(AgentSnapshot s) {
  final out = <AgentFinding>[];

  final p = s.pendingIncome;
  if (p != null) {
    final naira = (p.amount.minorUnits / 100).round();
    final steps = s.autopilot.split(naira);
    out.add(AgentFinding(
      id: 'wealth.income.${p.id}',
      agent: AgentKind.wealth,
      severity: Severity.warn,
      title: '${_n(naira)} landed. Split it?',
      detail: steps.map((x) => '${x.label} ${_n(x.naira)}').join(' · '),
      actionLabel: 'Approve split',
      action: ActionKind.approveSplit,
      targetId: p.id,
    ));
  }

  for (final g in s.goals) {
    if (g.savedNaira >= g.targetNaira) continue;
    final total = g.deadline.difference(g.createdAt).inDays;
    if (total <= 0) continue;
    final elapsed = s.now.difference(g.createdAt).inDays.clamp(0, total);
    final expected = (g.targetNaira * elapsed / total).round();
    final behind = expected - g.savedNaira;
    // Ignore the first week and small gaps: nagging over ₦2k is noise.
    if (elapsed < 7 || behind < 5000) continue;
    final catchUp = (behind / 1000).ceil() * 1000;
    out.add(AgentFinding(
      id: 'wealth.behind.${g.id}.${catchUp ~/ 10000}',
      agent: AgentKind.wealth,
      severity: Severity.warn,
      title: '“${g.name}” is ${_n(catchUp)} behind',
      detail: 'To be on track by today you would have ${_n(expected)}; you have ${_n(g.savedNaira)}.',
      actionLabel: 'Catch up ${_n(catchUp)}',
      action: ActionKind.contribute,
      targetId: g.id,
      amountNaira: catchUp,
    ));
  }
  return out;
}

// ── Security Agent: the firewall's recent calls ───────────────────────────

List<AgentFinding> securityAgent(AgentSnapshot s) {
  final out = <AgentFinding>[];
  final recent = s.guardLog.where((e) => s.now.difference(e.at).inDays < 7).toList();
  for (final e in recent.where((e) => e.outcome == 'approved')) {
    out.add(AgentFinding(
      id: 'security.approved.${e.at.toIso8601String()}',
      agent: AgentKind.security,
      severity: Severity.warn,
      title: 'You approved a flagged payment to ${e.recipient}',
      detail: '${e.reasons.join(' · ')}. If you did not expect this recipient, contact your bank now.',
      actionLabel: 'Review the firewall log',
      action: ActionKind.open,
      tab: HomeTab.intelligence,
    ));
  }
  final stopped = recent.where((e) => e.outcome == 'cancelled').length;
  if (stopped > 0) {
    out.add(AgentFinding(
      id: 'security.stopped.$stopped',
      agent: AgentKind.security,
      severity: Severity.info,
      title: 'Stopped $stopped risky payment${stopped == 1 ? '' : 's'} this week',
      detail: 'You cancelled after the firewall explained what looked unusual.',
    ));
  }
  return out;
}

// ── FX Agent: rate watches ────────────────────────────────────────────────

List<AgentFinding> fxAgent(AgentSnapshot s) => [
      for (final w in s.watches.where((w) => w.firedAt != null && s.now.difference(w.firedAt!).inDays < 3))
        AgentFinding(
          id: 'fx.fired.${w.id}',
          agent: AgentKind.fx,
          severity: Severity.info,
          title: '${w.pair} reached ${w.target.toStringAsFixed(2)}',
          detail: w.autoConvert
              ? 'Converted \$${(w.usdcCents / 100).toStringAsFixed(2)} USDC as you asked.'
              : 'Your target was hit. Convert now while the rate holds.',
          actionLabel: 'Open Global money',
          action: ActionKind.open,
          tab: HomeTab.globalMoney,
        ),
    ];

List<AgentFinding> runAgents(AgentSnapshot s) {
  final all = [
    ...moneyAgent(s),
    ...securityAgent(s),
    ...wealthAgent(s),
    ...billsAgent(s),
    ...fxAgent(s),
  ];
  all.sort((a, b) => b.severity.index.compareTo(a.severity.index));
  return all;
}

// ── Orchestrator ──────────────────────────────────────────────────────────

class DismissedNotifier extends StateNotifier<Set<String>> {
  DismissedNotifier() : super(readJsonList(_key).map((e) => '${e['id']}').toSet());
  static const _key = 'gabis.agents.dismissed.v1';
  void dismiss(String id) {
    state = {...state, id};
    writeJson(_key, state.map((e) => {'id': e}).toList());
  }
}

final dismissedFindingsProvider =
    StateNotifierProvider<DismissedNotifier, Set<String>>((ref) => DismissedNotifier());

/// What the agents currently want the user to see, dismissed ones removed.
final agentFindingsProvider = Provider<List<AgentFinding>>((ref) {
  final snap = AgentSnapshot(
    engine: ref.watch(intelligenceEngineProvider),
    goals: ref.watch(goalsProvider),
    pendingIncome: ref.watch(pendingIncomeProvider),
    autopilot: ref.watch(autopilotProvider),
    guardLog: ref.watch(guardLogProvider),
    refundWindows: ref.watch(refundWindowsProvider),
    watches: ref.watch(rateWatchProvider),
    now: DateTime.now(),
  );
  final dismissed = ref.watch(dismissedFindingsProvider);
  return runAgents(snap).where((f) => !dismissed.contains(f.id)).toList();
});

/// Carries out an agent's proposed action. Called only from a button the
/// user pressed.
void performAgentAction(WidgetRef ref, AgentFinding f) {
  switch (f.action) {
    case ActionKind.open:
      if (f.tab != null) ref.read(homeTabProvider.notifier).state = f.tab!;
    case ActionKind.approveSplit:
      if (f.targetId != null) ref.read(autopilotProvider.notifier).markHandled(f.targetId!);
    case ActionKind.contribute:
      if (f.targetId != null && f.amountNaira != null) {
        ref.read(goalsProvider.notifier).contribute(f.targetId!, f.amountNaira!);
      }
    case ActionKind.none:
      break;
  }
  ref.read(dismissedFindingsProvider.notifier).dismiss(f.id);
}

// ── FX agent service: runs while the app is open, not only on its screen ──

class FxAgentState {
  final Map<String, List<double>> history;
  final String? lastMessage;
  const FxAgentState(this.history, [this.lastMessage]);
}

class FxAgentService extends StateNotifier<FxAgentState> {
  FxAgentService(this._ref) : super(const FxAgentState({})) {
    _sample();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) => _sample());
  }

  final Ref _ref;
  Timer? _timer;
  bool _busy = false;

  static const currencies = ['NGN', 'KES', 'GHS', 'UGX', 'TZS', 'SSP', 'LRD'];

  Future<void> _sample() async {
    if (_busy) return;
    _busy = true;
    try {
      final feed = _ref.read(fxRateFeedProvider);
      final h = {for (final e in state.history.entries) e.key: [...e.value]};
      for (final c in currencies) {
        final r = await feed.rate('USD', c);
        final list = h.putIfAbsent('USD/$c', () => []);
        list.add(r);
        if (list.length > 60) list.removeAt(0);
      }
      String? msg;
      for (final w in _ref.read(rateWatchProvider).where((w) => w.firedAt == null)) {
        final rate = h[w.pair]?.last;
        if (rate == null || rate < w.target) continue;
        _ref.read(rateWatchProvider.notifier).markFired(w.id);
        msg = '${w.pair} reached ${rate.toStringAsFixed(2)} (target ${w.target.toStringAsFixed(2)}).';
        if (w.autoConvert) {
          final wallet = _ref.read(usdcWalletProvider.notifier);
          final q = await wallet.quote(w.usdcCents, w.pair.split('/').last);
          final r = await wallet.convert(q);
          msg += r.ok ? ' Converted as you asked.' : ' Could not convert: ${r.message}';
        }
      }
      if (mounted) state = FxAgentState(h, msg);
    } finally {
      _busy = false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final fxAgentProvider =
    StateNotifierProvider<FxAgentService, FxAgentState>((ref) => FxAgentService(ref));
