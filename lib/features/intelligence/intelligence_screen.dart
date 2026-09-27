import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../copilot/copilot_engine.dart';
import '../partners/partner_stores.dart';
import 'agents.dart';
import 'intelligence_engine.dart';
import 'intelligence_stores.dart';
import 'payment_guard.dart';

const _indigo = Color(0xFF4B45F5);
const _coral = Color(0xFFEF7F5D);
const _green = Color(0xFF0F9D6B);

String _n(int naira) => CopilotEngine.formatNaira(naira);

/// Future Mode, Goals, Autopilot, Firewall, Friday Roast and the agent
/// network: everything the homepage calls "the intelligence behind your
/// money", computed from the user's own transactions.
class IntelligenceScreen extends ConsumerWidget {
  const IntelligenceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Intelligence', style: TextStyle(fontWeight: FontWeight.w700)),
          bottom: const TabBar(isScrollable: true, tabAlignment: TabAlignment.start, tabs: [
            Tab(text: 'Future Mode'),
            Tab(text: 'Goals'),
            Tab(text: 'Autopilot'),
            Tab(text: 'Firewall'),
            Tab(text: 'Friday Roast'),
            Tab(text: 'Agents'),
          ]),
        ),
        body: const TabBarView(children: [
          _FutureTab(),
          _GoalsTab(),
          _AutopilotTab(),
          _FirewallTab(),
          _RoastTab(),
          _AgentsTab(),
        ]),
      ),
    );
  }
}

Widget _page(List<Widget> children) => ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
          ),
        ),
      ],
    );

class _Card extends StatelessWidget {
  final Widget child;
  final Color? color;
  const _Card({required this.child, this.color});
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color ?? context.colors.bgSoft,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: context.colors.border),
        ),
        child: child,
      );
}

Widget _h(BuildContext c, String t, [String? sub]) => Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(t, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: c.colors.ink, letterSpacing: -0.5)),
        if (sub != null) ...[
          const SizedBox(height: 4),
          Text(sub, style: TextStyle(color: c.colors.inkSoft, height: 1.4)),
        ],
      ]),
    );

Widget _row(BuildContext c, String k, String v, {Color? color, bool bold = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: [
        Expanded(child: Text(k, style: TextStyle(color: c.colors.inkSoft))),
        Text(v, style: TextStyle(fontWeight: bold ? FontWeight.w800 : FontWeight.w700, color: color ?? c.colors.ink)),
      ]),
    );

// ── Future Mode ────────────────────────────────────────────────────────

class _FutureTab extends ConsumerStatefulWidget {
  const _FutureTab();
  @override
  ConsumerState<_FutureTab> createState() => _FutureTabState();
}

class _FutureTabState extends ConsumerState<_FutureTab> {
  double _extra = 0;

  @override
  Widget build(BuildContext context) {
    final engine = ref.watch(intelligenceEngineProvider);
    final goals = ref.watch(goalsProvider);
    final f = engine.forecast();
    final goal = goals.isEmpty ? null : goals.first;
    final w = engine.whatIf(
      extraMonthlyNaira: _extra.round(),
      goalTargetNaira: goal?.targetNaira,
      goalSavedNaira: goal?.savedNaira ?? 0,
    );
    final fmtDate = DateFormat('d MMM');

    return _page([
      _h(context, 'Future Mode', 'Your balance before payday arrives, from your own spending and commitments.'),
      _Card(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Text('NEXT 30 DAYS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1, color: context.colors.inkSoft)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: _green.withValues(alpha: .1), borderRadius: BorderRadius.circular(99)),
              child: Text('${_n(f.safeTodayNaira)} safe today',
                  style: const TextStyle(color: _green, fontWeight: FontWeight.w800, fontSize: 12)),
            ),
          ]),
          const SizedBox(height: 16),
          SizedBox(height: 140, child: CustomPaint(painter: _ForecastPainter(f))),
          const SizedBox(height: 12),
          Row(children: [
            for (final d in const [0, 7, 14, 30])
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(d == 0 ? 'Today' : '$d days', style: TextStyle(fontSize: 11, color: context.colors.inkSoft)),
                  Text(_n(f.at(d)),
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: f.at(d) < 0 ? context.colors.danger : context.colors.ink)),
                ]),
              ),
          ]),
          const SizedBox(height: 10),
          Text('Lowest point: ${_n(f.lowestNaira)} on ${fmtDate.format(f.lowestOn)}',
              style: TextStyle(color: context.colors.inkSoft, fontSize: 13)),
        ]),
      ),
      _Card(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('What if…', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 4),
          Text('I spend ${_n(_extra.round())} more every month',
              style: TextStyle(color: context.colors.inkSoft)),
          Slider(
            value: _extra,
            max: 300000,
            divisions: 30,
            label: _n(_extra.round()),
            onChanged: (v) => setState(() => _extra = v),
          ),
          _row(context, 'Balance in 30 days', '${_n(w.payday30Before)} → ${_n(w.payday30After)}',
              color: w.payday30After < w.payday30Before ? _coral : null),
          if (goal != null)
            _row(
              context,
              '“${goal.name}” reached',
              w.goalBefore == null
                  ? 'Not on current savings'
                  : '${fmtDate.format(w.goalBefore!)} → ${w.goalAfter == null ? 'never' : fmtDate.format(w.goalAfter!)}',
            )
          else
            Text('Add a goal to see how it moves.', style: TextStyle(color: context.colors.inkSoft, fontSize: 13)),
        ]),
      ),
    ]);
  }
}

class _ForecastPainter extends CustomPainter {
  final Forecast f;
  _ForecastPainter(this.f);

  @override
  void paint(Canvas canvas, Size size) {
    final pts = f.points;
    if (pts.length < 2) return;
    final vals = pts.map((p) => p.balanceNaira.toDouble()).toList();
    var lo = vals.reduce((a, b) => a < b ? a : b);
    var hi = vals.reduce((a, b) => a > b ? a : b);
    if (hi == lo) {
      hi += 1;
      lo -= 1;
    }
    Offset at(int i) => Offset(
          i / (pts.length - 1) * size.width,
          size.height - 8 - (vals[i] - lo) / (hi - lo) * (size.height - 16),
        );

    final path = Path()..moveTo(at(0).dx, at(0).dy);
    for (var i = 1; i < pts.length; i++) {
      path.lineTo(at(i).dx, at(i).dy);
    }
    final fill = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(
        fill,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_indigo.withValues(alpha: .22), _indigo.withValues(alpha: 0)],
          ).createShader(Offset.zero & size));
    canvas.drawPath(
        path,
        Paint()
          ..color = _indigo
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round);

    if (lo < 0 && hi > 0) {
      final zy = size.height - 8 - (0 - lo) / (hi - lo) * (size.height - 16);
      canvas.drawLine(Offset(0, zy), Offset(size.width, zy), Paint()..color = _coral.withValues(alpha: .5));
    }
    final low = pts.indexWhere((p) => p.balanceNaira == f.lowestNaira);
    canvas.drawCircle(at(low), 5, Paint()..color = _coral);
    canvas.drawCircle(at(0), 5, Paint()..color = _indigo);
    for (var i = 0; i < pts.length; i++) {
      if (pts[i].isPayday) {
        final x = at(i).dx;
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), Paint()..color = _green.withValues(alpha: .35));
      }
    }
  }

  @override
  bool shouldRepaint(_ForecastPainter old) => old.f != f;
}

// ── Goals ──────────────────────────────────────────────────────────────

class _GoalsTab extends ConsumerWidget {
  const _GoalsTab();

  /// Understands "Save ₦2M by December", "2.5m by 31 Mar", "500k in 6 months".
  static (int, DateTime)? parse(String text, DateTime now) {
    final t = text.toLowerCase();
    final m = RegExp(r'([\d,.]+)\s*(k|m)?').firstMatch(t.replaceAll('₦', ''));
    if (m == null) return null;
    var amount = double.tryParse(m.group(1)!.replaceAll(',', '')) ?? 0;
    if (m.group(2) == 'k') amount *= 1000;
    if (m.group(2) == 'm') amount *= 1000000;
    if (amount <= 0) return null;

    DateTime? deadline;
    final inMonths = RegExp(r'in\s+(\d+)\s+months?').firstMatch(t);
    if (inMonths != null) {
      deadline = DateTime(now.year, now.month + int.parse(inMonths.group(1)!), now.day);
    } else {
      const months = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec'];
      for (var i = 0; i < months.length; i++) {
        if (RegExp('\\b${months[i]}').hasMatch(t.split('by').last)) {
          var y = now.year;
          if (i + 1 <= now.month) y += 1;
          deadline = DateTime(y, i + 2, 0); // last day of that month
          break;
        }
      }
    }
    deadline ??= DateTime(now.year, now.month + 6, now.day);
    return (amount.round(), deadline);
  }

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final ctrl = TextEditingController();
    final said = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tell gabis your goal'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Save ₦2M by December'),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, ctrl.text), child: const Text('Plan it')),
        ],
      ),
    );
    if (said == null || !context.mounted) return;
    final p = parse(said, DateTime.now());
    if (p == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Try something like “Save ₦2M by December”.')));
      return;
    }
    ref.read(goalsProvider.notifier).add(name: said, targetNaira: p.$1, deadline: p.$2);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalsProvider);
    final engine = ref.watch(intelligenceEngineProvider);
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _add(context, ref),
        icon: const Icon(Icons.flag_rounded),
        label: const Text('New goal'),
      ),
      body: _page([
        _h(context, 'Goals', 'Say what you want in everyday language. gabis works out the monthly plan.'),
        if (goals.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Text('No goals yet. Try “Save ₦2M by December”.',
                textAlign: TextAlign.center, style: TextStyle(color: context.colors.inkSoft)),
          ),
        for (final g in goals) _GoalCard(g, engine.planGoal(targetNaira: g.targetNaira, deadline: g.deadline, savedNaira: g.savedNaira)),
      ]),
    );
  }
}

class _GoalCard extends ConsumerWidget {
  final SavingsGoal g;
  final GoalPlan plan;
  const _GoalCard(this.g, this.plan);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _Card(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
                color: _indigo,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16), topRight: Radius.circular(16), bottomLeft: Radius.circular(16))),
            child: Text(g.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          plan.onTrack
              ? '${_n(plan.monthlyNaira)} a month gets you there by ${DateFormat('d MMM yyyy').format(g.deadline)}.'
              : '${_n(plan.monthlyNaira)} a month is more than your usual spare ${_n(plan.spareMonthlyNaira ?? 0)}. Consider a later date.',
          style: TextStyle(color: context.colors.ink, height: 1.4),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: plan.progress,
            minHeight: 10,
            color: _indigo,
            backgroundColor: _indigo.withValues(alpha: .12),
          ),
        ),
        const SizedBox(height: 8),
        _row(context, 'Saved', '${_n(g.savedNaira)} of ${_n(g.targetNaira)}'),
        _row(context, 'Months left', '${plan.monthsLeft}'),
        const SizedBox(height: 8),
        Row(children: [
          FilledButton.tonal(
            onPressed: () => showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text('Move ${_n(plan.monthlyNaira)} to “${g.name}”?'),
                content: const Text('This records this month\'s contribution. You approve every move.'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Not now')),
                  FilledButton(
                    onPressed: () {
                      ref.read(goalsProvider.notifier).contribute(g.id, plan.monthlyNaira);
                      Navigator.pop(ctx);
                    },
                    child: const Text('Approve'),
                  ),
                ],
              ),
            ),
            child: Text('Add ${_n(plan.monthlyNaira)}'),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Delete goal',
            onPressed: () => ref.read(goalsProvider.notifier).remove(g.id),
            icon: const Icon(Icons.delete_outline),
          ),
        ]),
      ]),
    );
  }
}

// ── Autopilot ──────────────────────────────────────────────────────────

class _AutopilotTab extends ConsumerWidget {
  const _AutopilotTab();

  Future<void> _edit(BuildContext context, WidgetRef ref, AutopilotState ap, int i) async {
    final r = ap.rules[i];
    final ctrl = TextEditingController(
        text: r.fixedNaira != null ? '${r.fixedNaira}' : ((r.percentOfRemainder ?? 0) * 100).toStringAsFixed(0));
    final v = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(r.label),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            prefixText: r.fixedNaira != null ? '₦' : null,
            suffixText: r.fixedNaira != null ? null : '% of what is left',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, ctrl.text), child: const Text('Save')),
        ],
      ),
    );
    final n = int.tryParse(v ?? '');
    if (n == null) return;
    final rules = [...ap.rules];
    rules[i] = r.fixedNaira != null
        ? WaterfallRule(id: r.id, label: r.label, fixedNaira: n)
        : WaterfallRule(id: r.id, label: r.label, percentOfRemainder: (n.clamp(0, 100)) / 100);
    ref.read(autopilotProvider.notifier).setRules(rules);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ap = ref.watch(autopilotProvider);
    final pending = ref.watch(pendingIncomeProvider);
    final engine = ref.watch(intelligenceEngineProvider);
    final example = pending != null ? (pending.amount.minorUnits / 100).round() : (engine.core.averageMonthlyIncome > 0 ? engine.core.averageMonthlyIncome : 1200000);
    final steps = ap.split(example);

    return _page([
      _h(context, 'Autopilot', 'Give your money a plan. When income lands, gabis proposes the split and you approve it.'),
      _Card(
        child: SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: ap.armed,
          onChanged: ref.read(autopilotProvider.notifier).setArmed,
          title: const Text('Offer a split when income arrives', style: TextStyle(fontWeight: FontWeight.w700)),
          subtitle: const Text('Nothing moves without your approval.'),
        ),
      ),
      if (pending != null)
        _Card(
          color: _green.withValues(alpha: .08),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('INCOME DETECTED · ${pending.counterparty ?? pending.description ?? ''}',
                style: const TextStyle(color: _green, fontWeight: FontWeight.w800, fontSize: 12)),
            const SizedBox(height: 6),
            Text(_n(example), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            FilledButton(
              onPressed: () {
                ref.read(autopilotProvider.notifier).markHandled(pending.id);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Split approved. Your allocations are recorded.')));
              },
              child: const Text('Approve this split'),
            ),
            TextButton(
              onPressed: () => ref.read(autopilotProvider.notifier).markHandled(pending.id),
              child: const Text('Skip this time'),
            ),
          ]),
        ),
      _Card(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(pending != null ? 'This income would split like this' : 'Example with ${_n(example)} income',
              style: TextStyle(color: context.colors.inkSoft, fontSize: 13)),
          const SizedBox(height: 10),
          for (var i = 0; i < steps.length; i++)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: i == steps.length - 1 ? _indigo : context.colors.scaffoldBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: ListTile(
                onTap: i < ap.rules.length ? () => _edit(context, ref, ap, i) : null,
                title: Text(steps[i].label,
                    style: TextStyle(
                        fontWeight: FontWeight.w700, color: i == steps.length - 1 ? Colors.white : context.colors.ink)),
                subtitle: i < ap.rules.length
                    ? Text(
                        ap.rules[i].fixedNaira != null
                            ? 'Fixed amount · tap to change'
                            : '${((ap.rules[i].percentOfRemainder ?? 0) * 100).toStringAsFixed(0)}% of what is left · tap to change',
                        style: TextStyle(color: context.colors.inkSoft, fontSize: 12))
                    : const Text('Yours to spend', style: TextStyle(color: Colors.white70, fontSize: 12)),
                trailing: Text(_n(steps[i].naira),
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: i == steps.length - 1 ? Colors.white : context.colors.ink)),
              ),
            ),
        ]),
      ),
    ]);
  }
}

// ── Firewall ───────────────────────────────────────────────────────────

class _FirewallTab extends ConsumerWidget {
  const _FirewallTab();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final log = ref.watch(guardLogProvider);
    return _page([
      _h(context, 'Financial Firewall',
          'Before money leaves, gabis checks for a first-time recipient, an unusually large amount, a just-added beneficiary and late-night transfers. It pauses and explains; you decide.'),
      _Card(
        child: Row(children: [
          const Icon(Icons.shield_rounded, color: _green, size: 32),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              log.isEmpty ? 'Active. Nothing unusual yet.' : 'Active. ${log.length} payment${log.length == 1 ? '' : 's'} paused for review.',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ]),
      ),
      for (final e in log)
        _Card(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: Text('₦${NumberFormat('#,##0').format(e.amountMinor / 100)} → ${e.recipient}',
                    style: const TextStyle(fontWeight: FontWeight.w800)),
              ),
              Text(switch (e.outcome) { 'approved' => 'You approved', 'cancelled' => 'Cancelled', _ => 'Reviewed' },
                  style: TextStyle(
                      fontWeight: FontWeight.w700, color: e.outcome == 'cancelled' ? _green : context.colors.inkSoft)),
            ]),
            const SizedBox(height: 6),
            for (final r in e.reasons) Text('• $r', style: TextStyle(color: context.colors.inkSoft)),
            const SizedBox(height: 4),
            Text(DateFormat('d MMM, h:mm a').format(e.at), style: TextStyle(color: context.colors.inkSoft, fontSize: 12)),
          ]),
        ),
    ]);
  }
}

// ── Friday Roast ───────────────────────────────────────────────────────

class _RoastTab extends ConsumerWidget {
  const _RoastTab();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(roastPrefsProvider);
    final lines = ref.watch(intelligenceEngineProvider).roast(spicy: prefs.spicy);
    return _page([
      _h(context, 'Friday Roast', 'Brutally witty spending accountability, every Friday at 6 PM. From your real numbers.'),
      _Card(
        child: Column(children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Send me the Friday Roast'),
            value: prefs.enabled,
            onChanged: (v) => ref.read(roastPrefsProvider.notifier).set(enabled: v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Spicy'),
            subtitle: const Text('Off gives you the same facts, politely.'),
            value: prefs.spicy,
            onChanged: prefs.enabled ? (v) => ref.read(roastPrefsProvider.notifier).set(spicy: v) : null,
          ),
        ]),
      ),
      if (prefs.enabled)
        _Card(
          color: const Color(0xFF16123A),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Text('THIS WEEK\'S ROAST',
                style: TextStyle(color: Color(0xFFDFF76A), fontWeight: FontWeight.w800, fontSize: 12, letterSpacing: 1)),
            const SizedBox(height: 12),
            for (final l in lines)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(l, style: const TextStyle(color: Colors.white, height: 1.45)),
              ),
          ]),
        ),
    ]);
  }
}

// ── Agents ─────────────────────────────────────────────────────────────

const _agentMeta = {
  AgentKind.money: (Icons.psychology_rounded, 'Money Agent', 'Cash flow & affordability', Color(0xFF8B5CF6)),
  AgentKind.security: (Icons.shield_rounded, 'Security Agent', 'Fraud intercept & firewall', Color(0xFFEF4444)),
  AgentKind.fx: (Icons.flight_takeoff_rounded, 'Travel & FX Agent', 'Rate watches & conversion', Color(0xFF3B82F6)),
  AgentKind.wealth: (Icons.savings_rounded, 'Wealth Agent', 'Goals & income waterfall', Color(0xFF10B981)),
  AgentKind.bills: (Icons.receipt_long_rounded, 'Bills Agent', 'Commitments & refund windows', Color(0xFFF59E0B)),
};

class _AgentsTab extends ConsumerWidget {
  const _AgentsTab();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final findings = ref.watch(agentFindingsProvider);
    final fx = ref.watch(fxAgentProvider);
    final watching = ref.watch(rateWatchProvider).where((w) => w.firedAt == null).length;

    String status(AgentKind k) {
      final mine = findings.where((f) => f.agent == k).length;
      if (mine > 0) return '$mine thing${mine == 1 ? '' : 's'} need${mine == 1 ? 's' : ''} you';
      return switch (k) {
        AgentKind.fx => fx.history.isEmpty ? 'Starting…' : 'Watching 7 rates · $watching alert${watching == 1 ? '' : 's'} set',
        AgentKind.security => 'Checking every transfer',
        _ => 'All clear',
      };
    }

    return _page([
      _h(context, 'Your agent network',
          'Each agent reads your own data, flags what needs you and proposes one action. Nothing moves without your approval.'),
      Wrap(spacing: 10, runSpacing: 10, children: [
        for (final k in AgentKind.values)
          Container(
            width: 220,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colors.bgSoft,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.colors.border),
            ),
            child: Row(children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: _agentMeta[k]!.$4, borderRadius: BorderRadius.circular(10)),
                child: Icon(_agentMeta[k]!.$1, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_agentMeta[k]!.$2, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                  Text(status(k),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 11,
                          color: findings.any((f) => f.agent == k) ? _coral : context.colors.inkSoft,
                          fontWeight: FontWeight.w600)),
                ]),
              ),
            ]),
          ),
      ]),
      const SizedBox(height: 20),
      Text(findings.isEmpty ? 'Nothing needs you right now.' : 'Needs your attention',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
      const SizedBox(height: 10),
      for (final f in findings) _FindingCard(f),
    ]);
  }
}

class _FindingCard extends ConsumerWidget {
  final AgentFinding f;
  const _FindingCard(this.f);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final m = _agentMeta[f.agent]!;
    final edge = switch (f.severity) { Severity.urgent => const Color(0xFFD9432B), Severity.warn => _coral, Severity.info => context.colors.border };
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.bgSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: edge, width: f.severity == Severity.info ? 1 : 1.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(m.$1, size: 16, color: m.$4),
          const SizedBox(width: 6),
          Text(m.$2.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: m.$4, letterSpacing: .6)),
        ]),
        const SizedBox(height: 8),
        Text(f.title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
        const SizedBox(height: 4),
        Text(f.detail, style: TextStyle(color: context.colors.inkSoft, height: 1.4)),
        const SizedBox(height: 10),
        Row(children: [
          if (f.actionLabel != null)
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: _indigo),
              onPressed: () {
                performAgentAction(ref, f);
                if (f.action != ActionKind.open) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Done: ${f.actionLabel}')));
                }
              },
              child: Text(f.actionLabel!),
            ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => ref.read(dismissedFindingsProvider.notifier).dismiss(f.id),
            child: const Text('Dismiss'),
          ),
        ]),
      ]),
    );
  }
}
