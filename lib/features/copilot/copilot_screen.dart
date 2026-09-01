import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/providers/app_providers.dart';
import 'copilot_engine.dart';
import 'sweep_store.dart';

/// Conversational financial copilot.
///
/// Questions are parsed for intent and amounts, then answered from the user's
/// own transaction history via [CopilotEngine]. Every recommendation that moves
/// money is surfaced as an action the user must explicitly approve.
class CopilotScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;
  const CopilotScreen({super.key, this.onBack});

  @override
  ConsumerState<CopilotScreen> createState() => _CopilotScreenState();
}

class _CopilotScreenState extends ConsumerState<CopilotScreen> {
  static const _purple = Color(0xFF5145E5);
  static const _ink = Color(0xFF0D1830);
  static const _muted = Color(0xFF667385);

  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final List<_Turn> _turns = [];
  bool _thinking = false;

  static const _suggestions = [
    'Can I afford ₦250,000 for stock this month?',
    'Where is my money going?',
    'What can I cancel?',
    'How much will I have left before payday?',
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  CopilotEngine _engine() {
    final txs = ref.read(transactionsProvider);
    final total = ref.read(totalBalanceNgnProvider);
    return CopilotEngine(
      transactions: txs,
      balanceNaira: (total.minorUnits / 100).round(),
    );
  }

  /// Pulls a naira figure out of free text: "₦250,000", "250k", "1.2m".
  int? _extractAmount(String q) {
    final compact = RegExp(r'(?:₦|ngn\s*)?([\d,.]+)\s*([km])\b', caseSensitive: false)
        .firstMatch(q.toLowerCase());
    if (compact != null) {
      final base = double.tryParse(compact.group(1)!.replaceAll(',', ''));
      if (base != null) {
        final mult = compact.group(2) == 'm' ? 1000000 : 1000;
        return (base * mult).round();
      }
    }
    final plain = RegExp(r'(?:₦|ngn\s*)?([\d][\d,]{2,})').firstMatch(q);
    if (plain != null) {
      return int.tryParse(plain.group(1)!.replaceAll(',', ''));
    }
    return null;
  }

  void _ask(String raw) {
    final question = raw.trim();
    if (question.isEmpty) return;

    setState(() {
      _turns.add(_Turn.user(question));
      _thinking = true;
      _controller.clear();
    });
    _jump();

    // Brief pause so the reasoning reads as considered rather than instant.
    Future.delayed(const Duration(milliseconds: 550), () {
      if (!mounted) return;
      setState(() {
        _thinking = false;
        _turns.add(_answer(question));
      });
      _jump();
    });
  }

  _Turn _answer(String q) {
    final engine = _engine();
    final lower = q.toLowerCase();
    final amount = _extractAmount(q);

    // Affordability
    if (lower.contains('afford') || lower.contains('can i buy') || lower.contains('should i')) {
      if (amount == null) {
        return _Turn.assistant(
          headline: 'How much are you thinking?',
          lines: const ['Give me a figure and I will check it against your commitments and projected balance.'],
        );
      }
      final v = engine.canIAfford(amount);
      return _Turn.assistant(
        headline: v.affordable
            ? 'Yes — ${CopilotEngine.formatNaira(amount)} is within reach.'
            : 'Not comfortably, not this month.',
        lines: v.reasoning,
        actions: v.actions,
        tone: v.affordable ? _Tone.positive : _Tone.caution,
      );
    }

    // Where is money going
    if (lower.contains('where') || lower.contains('going') || lower.contains('spend') || lower.contains('breakdown')) {
      final totals = engine.categoryTotals(0)..remove(SpendCategory.income);
      final sorted = totals.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      final shifts = engine.categoryShifts();

      return _Turn.assistant(
        headline: 'This month you have spent ${CopilotEngine.formatNaira(engine.spendInMonth(0))}.',
        lines: [
          ...sorted.take(5).map((e) => '${e.key.label}: ${CopilotEngine.formatNaira(e.value)}'),
          if (shifts.isNotEmpty)
            '${shifts.first.category.label} is ${shifts.first.isIncrease ? 'up' : 'down'} ${shifts.first.percentChange.abs().toStringAsFixed(0)}% versus last month.',
        ],
        tone: _Tone.neutral,
      );
    }

    // Trimming
    if (lower.contains('cancel') || lower.contains('subscription') || lower.contains('save money') || lower.contains('cut')) {
      final subs = engine.trimmableSubscriptions();
      final total = subs.fold(0, (s, c) => s + c.monthlyNaira);
      return _Turn.assistant(
        headline: subs.isEmpty
            ? 'No recurring subscriptions found.'
            : 'You have ${subs.length} recurring subscriptions costing ${CopilotEngine.formatNaira(total)} a month.',
        lines: subs
            .map((c) => '${c.counterparty} — ${CopilotEngine.formatNaira(c.monthlyNaira)}/month, charged ${c.occurrences} times.')
            .toList(),
        actions: subs
            .take(3)
            .map((c) => CopilotAction(
                  label: 'Cancel ${c.counterparty}',
                  detail: 'Frees ${CopilotEngine.formatNaira(c.monthlyNaira)} every month.',
                  amountNaira: c.monthlyNaira,
                ))
            .toList(),
        tone: _Tone.neutral,
      );
    }

    // Runway to payday
    if (lower.contains('payday') || lower.contains('left') || lower.contains('until') || lower.contains('runway')) {
      return _Turn.assistant(
        headline:
            'About ${CopilotEngine.formatNaira(engine.projectedBalanceAtPayday)} by payday, in ${engine.daysToPayday} days.',
        lines: [
          'Daily spend is averaging ${CopilotEngine.formatNaira(engine.dailyBurnNaira)}.',
          'Recurring commitments total ${CopilotEngine.formatNaira(engine.totalMonthlyCommitments)} a month.',
          'Average income across recent months is ${CopilotEngine.formatNaira(engine.averageMonthlyIncome)}.',
        ],
        tone: engine.projectedBalanceAtPayday < 0 ? _Tone.caution : _Tone.positive,
      );
    }

    // Fallback — orient the user with a real summary rather than an apology.
    return _Turn.assistant(
      headline: 'Here is where you stand.',
      lines: [
        'Spent this month: ${CopilotEngine.formatNaira(engine.spendInMonth(0))}.',
        'Recurring commitments: ${CopilotEngine.formatNaira(engine.totalMonthlyCommitments)} a month.',
        'Projected at payday: ${CopilotEngine.formatNaira(engine.projectedBalanceAtPayday)}.',
        'Ask me about affording something, where your money goes, or what to cancel.',
      ],
      tone: _Tone.neutral,
    );
  }

  void _jump() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent + 200,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _confirmAction(CopilotAction action) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Confirm this action', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(action.label, style: const TextStyle(fontWeight: FontWeight.w700, color: _ink)),
            const SizedBox(height: 8),
            Text(action.detail, style: const TextStyle(color: _muted, height: 1.4)),
            const SizedBox(height: 14),
            const Text(
              'Nothing moves until you approve it here.',
              style: TextStyle(fontSize: 12, color: _muted, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Not now')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _purple),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _turns.add(_Turn.assistant(
                  headline: 'Done — ${action.label.toLowerCase()}.',
                  lines: const ['I have applied it and updated your projection.'],
                  tone: _Tone.positive,
                ));
              });
              _jump();
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final engine = _engine();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Color(0xFFEDEFF3))),
              ),
              child: Row(
                children: [
                  if (widget.onBack != null)
                    IconButton(
                      onPressed: widget.onBack,
                      icon: const Icon(Icons.arrow_back_rounded, size: 20),
                    ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [_purple, Color(0xFF7C63EE)]),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(Icons.auto_awesome, size: 17, color: Colors.white),
                  ),
                  const SizedBox(width: 11),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Financial Copilot',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: _ink)),
                      Text('Reasoning over your own transactions',
                          style: TextStyle(fontSize: 11.5, color: _muted)),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${ref.watch(transactionsProvider).length} transactions analysed',
                      style: const TextStyle(
                          fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF047857)),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                controller: _scroll,
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
                children: [
                  _sweepPanel(engine),
                  if (_turns.isEmpty) _intro(engine),
                  ..._turns.map(_bubble),
                  if (_thinking) _thinkingRow(),
                ],
              ),
            ),

            // Composer
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFEDEFF3))),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 34,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _suggestions.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) => GestureDetector(
                        onTap: () => _ask(_suggestions[i]),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F0FF),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(_suggestions[i],
                              style: const TextStyle(
                                  fontSize: 11.5, color: _purple, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          onSubmitted: _ask,
                          decoration: InputDecoration(
                            hintText: 'Ask about your money…',
                            hintStyle: const TextStyle(color: _muted, fontSize: 14),
                            filled: true,
                            fillColor: const Color(0xFFF5F6F8),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => _ask(_controller.text),
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: _purple,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 19),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Payday sweep. The figure comes from the engine; the money only moves when
  /// the user approves it, and never above their cap.
  Widget _sweepPanel(CopilotEngine engine) {
    final sweep = ref.watch(sweepProvider);
    final plan = engine.computeSweep(reserveWeeks: sweep.reserveWeeks);
    final amount = sweep.applyCap(plan.recommendedNaira);
    final capped = plan.recommendedNaira > sweep.capNaira;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3DEFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: _purple.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(Icons.savings_rounded, size: 16, color: _purple),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Payday sweep',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: _ink)),
                    Text('Moves what is genuinely spare into savings',
                        style: TextStyle(fontSize: 11.5, color: _muted)),
                  ],
                ),
              ),
              Switch(
                value: sweep.armed,
                activeThumbColor: _purple,
                onChanged: (v) => ref.read(sweepProvider.notifier).setArmed(v),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F5FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Spare this cycle',
                              style: TextStyle(fontSize: 11, color: Color(0xFF6D28D9), fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(CopilotEngine.formatNaira(amount),
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF4C1D95))),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('In savings', style: const TextStyle(fontSize: 10.5, color: _muted)),
                        Text(CopilotEngine.formatNaira(sweep.savingsNaira),
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w800, color: _ink)),
                      ],
                    ),
                  ],
                ),
                if (capped) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Held to your ${CopilotEngine.formatNaira(sweep.capNaira)} cap — ${CopilotEngine.formatNaira(plan.recommendedNaira)} was spare.',
                    style: const TextStyle(fontSize: 10.5, color: Color(0xFF7C3AED)),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 12),
          ...plan.reasoning.take(3).map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.only(top: 6, right: 8),
                      decoration: BoxDecoration(
                          color: _muted.withValues(alpha: 0.45), shape: BoxShape.circle),
                    ),
                    Expanded(
                      child: Text(r,
                          style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569), height: 1.4)),
                    ),
                  ],
                ),
              )),

          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: amount > 0 ? () => _confirmSweep(amount, plan) : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: _purple,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                  ),
                  child: Text(
                    amount > 0
                        ? 'Sweep ${CopilotEngine.formatNaira(amount)} to savings'
                        : 'Nothing spare this cycle',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                  ),
                ),
              ),
              if (sweep.history.isNotEmpty) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    final last = sweep.history.first;
                    ref.read(sweepProvider.notifier).undoLast();
                    ref.read(accountsProvider.notifier)
                        .addBalance('NGN', last.amountNaira * 100);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Returned ${CopilotEngine.formatNaira(last.amountNaira)} to your balance.')),
                    );
                  },
                  child: const Text('Undo', style: TextStyle(fontSize: 12.5)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _confirmSweep(int amount, SweepPlan plan) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Move this to savings?', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(CopilotEngine.formatNaira(amount),
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: _purple)),
            const SizedBox(height: 10),
            ...plan.reasoning.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text('· $r',
                      style: const TextStyle(fontSize: 12.5, color: _muted, height: 1.4)),
                )),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Not now')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: _purple),
            onPressed: () {
              Navigator.pop(ctx);
              final moved = ref.read(sweepProvider.notifier).sweep(amount);
              // The money leaves the spending balance, so the copilot's next
              // answer reflects it.
              ref.read(accountsProvider.notifier).subtractBalance('NGN', moved * 100);
              setState(() {
                _turns.add(_Turn.assistant(
                  headline: 'Swept ${CopilotEngine.formatNaira(moved)} into savings.',
                  lines: [
                    'Your spending balance is updated, so everything I tell you from here accounts for it.',
                    'You can undo this from the sweep panel.',
                  ],
                  tone: _Tone.positive,
                ));
              });
              _jump();
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  Widget _intro(CopilotEngine engine) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEDEFF3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('I have read your last 3 months.',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: _ink)),
          const SizedBox(height: 12),
          _stat('Recurring commitments',
              '${CopilotEngine.formatNaira(engine.totalMonthlyCommitments)}/month'),
          _stat('Average income', '${CopilotEngine.formatNaira(engine.averageMonthlyIncome)}/month'),
          _stat('Spent this month', CopilotEngine.formatNaira(engine.spendInMonth(0))),
          _stat('Projected at payday',
              '${CopilotEngine.formatNaira(engine.projectedBalanceAtPayday)} in ${engine.daysToPayday} days'),
          const SizedBox(height: 6),
          const Text('Ask me anything below.',
              style: TextStyle(fontSize: 12.5, color: _muted)),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Expanded(child: Text(label, style: const TextStyle(fontSize: 13, color: _muted))),
            Text(value,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _ink)),
          ],
        ),
      );

  Widget _thinkingRow() => Container(
        margin: const EdgeInsets.only(top: 14),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFEDEFF3)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2, color: _purple)),
            SizedBox(width: 10),
            Text('Reading your transactions…',
                style: TextStyle(fontSize: 13, color: _muted)),
          ],
        ),
      );

  Widget _bubble(_Turn turn) {
    if (turn.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(top: 14, left: 40),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _purple,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(turn.text!,
              style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4)),
        ),
      );
    }

    final accent = switch (turn.tone) {
      _Tone.positive => const Color(0xFF10B981),
      _Tone.caution => const Color(0xFFF59E0B),
      _Tone.neutral => _purple,
    };

    return Container(
      margin: const EdgeInsets.only(top: 14, right: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDEFF3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4,
                height: 18,
                margin: const EdgeInsets.only(top: 2, right: 10),
                decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(2)),
              ),
              Expanded(
                child: Text(turn.headline!,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 15, color: _ink, height: 1.35)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...turn.lines!.map((l) => Padding(
                padding: const EdgeInsets.only(bottom: 7, left: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.only(top: 7, right: 9),
                      decoration: BoxDecoration(
                          color: _muted.withValues(alpha: 0.5), shape: BoxShape.circle),
                    ),
                    Expanded(
                      child: Text(l,
                          style: const TextStyle(fontSize: 13.5, color: Color(0xFF475569), height: 1.5)),
                    ),
                  ],
                ),
              )),
          if (turn.actions != null && turn.actions!.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(height: 20),
            const Text('SUGGESTED ACTIONS',
                style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: _muted)),
            const SizedBox(height: 10),
            ...turn.actions!.map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () => _confirmAction(a),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F8FA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE6E9EF)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(a.label,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700, fontSize: 13, color: _ink)),
                                const SizedBox(height: 2),
                                Text(a.detail,
                                    style: const TextStyle(fontSize: 11.5, color: _muted)),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, size: 18, color: _muted),
                        ],
                      ),
                    ),
                  ),
                )),
          ],
        ],
      ),
    );
  }
}

enum _Tone { positive, caution, neutral }

class _Turn {
  final bool isUser;
  final String? text;
  final String? headline;
  final List<String>? lines;
  final List<CopilotAction>? actions;
  final _Tone tone;

  const _Turn.user(this.text)
      : isUser = true,
        headline = null,
        lines = null,
        actions = null,
        tone = _Tone.neutral;

  const _Turn.assistant({
    required this.headline,
    required this.lines,
    this.actions,
    this.tone = _Tone.neutral,
  })  : isUser = false,
        text = null;
}
