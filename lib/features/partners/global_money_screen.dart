import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../intelligence/agents.dart';
import 'partner_rails.dart';
import 'partner_stores.dart';

const _indigo = Color(0xFF4B45F5);
const _green = Color(0xFF0F9D6B);
const _usdcBlue = Color(0xFF2775CA);

/// Currencies USDC can be paid out to, matching the tax corridors.
const payoutCurrencies = [
  ('NGN', '₦', 'Naira'),
  ('KES', 'KSh', 'Kenyan shilling'),
  ('GHS', 'GH₵', 'Cedi'),
  ('UGX', 'USh', 'Ugandan shilling'),
  ('TZS', 'TSh', 'Tanzanian shilling'),
  ('SSP', 'SSP ', 'South Sudanese pound'),
  ('LRD', 'L\$', 'Liberian dollar'),
];

String _usd(int cents) => '\$${NumberFormat('#,##0.00').format(cents / 100)}';
String _local(String sym, int minor) => '$sym${NumberFormat('#,##0').format(minor / 100)}';

Widget _sandboxBanner(BuildContext context) => Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFFBF1DC), borderRadius: BorderRadius.circular(12)),
      child: const Row(children: [
        Icon(Icons.science_outlined, size: 18, color: Color(0xFF9A6207)),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            'Sandbox: balances and conversions are simulated and rates are reference figures, not market data. Real USDC settlement starts when the stablecoin partner is connected.',
            style: TextStyle(fontSize: 12, color: Color(0xFF9A6207), fontWeight: FontWeight.w600),
          ),
        ),
      ]),
    );

/// USDC wallet (stablecoin rails) and the FX agent, both through the
/// partner seams in partner_rails.dart.
class GlobalMoneyScreen extends ConsumerWidget {
  const GlobalMoneyScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Global money', style: TextStyle(fontWeight: FontWeight.w700)),
          bottom: const TabBar(tabs: [Tab(text: 'USDC wallet'), Tab(text: 'FX agent')]),
        ),
        body: const TabBarView(children: [_UsdcTab(), _FxAgentTab()]),
      ),
    );
  }
}

Widget _page(List<Widget> c) => ListView(padding: const EdgeInsets.all(20), children: [
      Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: c),
        ),
      ),
    ]);

BoxDecoration _box(BuildContext c) => BoxDecoration(
      color: c.colors.bgSoft,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: c.colors.border),
    );

// ── USDC ───────────────────────────────────────────────────────────────

class _UsdcTab extends ConsumerStatefulWidget {
  const _UsdcTab();
  @override
  ConsumerState<_UsdcTab> createState() => _UsdcTabState();
}

class _UsdcTabState extends ConsumerState<_UsdcTab> {
  String _cur = 'NGN';
  final _amount = TextEditingController();
  RateQuote? _quote;
  Timer? _tick;
  bool _busy = false;

  @override
  void dispose() {
    _tick?.cancel();
    _amount.dispose();
    super.dispose();
  }

  int get _cents => ((double.tryParse(_amount.text.replaceAll(',', '')) ?? 0) * 100).round();

  Future<void> _getQuote() async {
    if (_cents <= 0) return;
    final q = await ref.read(usdcWalletProvider.notifier).quote(_cents, _cur);
    if (!mounted) return;
    setState(() => _quote = q);
    _tick?.cancel();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {});
      if (_quote?.expired ?? true) _tick?.cancel();
    });
  }

  Future<void> _convert() async {
    final q = _quote;
    if (q == null) return;
    final sym = payoutCurrencies.firstWhere((c) => c.$1 == q.currency).$2;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Convert now?'),
        content: Text('${_usd(q.usdcCents)} USDC → ${_local(sym, q.outMinor)} at ${q.rate.toStringAsFixed(2)}.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Approve')),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _busy = true);
    final r = await ref.read(usdcWalletProvider.notifier).convert(q);
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (r.ok) {
        _quote = null;
        _amount.clear();
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(r.message)));
  }

  Future<void> _simulate() async {
    final from = TextEditingController(text: 'Adeola Studio Ltd, London');
    final amt = TextEditingController(text: '1250');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Simulate a client payment'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: from, decoration: const InputDecoration(labelText: 'From')),
          TextField(
              controller: amt,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount', prefixText: '\$')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Receive')),
        ],
      ),
    );
    if (ok != true) return;
    final cents = ((double.tryParse(amt.text) ?? 0) * 100).round();
    if (cents > 0) {
      ref.read(usdcWalletProvider.notifier).simulateIncoming(from: from.text.trim(), usdcCents: cents);
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(usdcWalletProvider);
    final balance = ref.read(usdcWalletProvider.notifier).balanceCents;
    final sandbox = ref.watch(partnerModeProvider) == PartnerMode.sandbox;
    final q = _quote;
    final secs = q == null ? 0 : q.expiresAt.difference(DateTime.now()).inSeconds.clamp(0, 30);
    final sym = payoutCurrencies.firstWhere((c) => c.$1 == _cur).$2;

    return _page([
      if (sandbox) _sandboxBanner(context),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: _box(context),
        child: Row(children: [
          const CircleAvatar(radius: 24, backgroundColor: _usdcBlue, child: Text('\$', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800))),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('USDC balance', style: TextStyle(color: context.colors.inkSoft)),
              Text('${NumberFormat('#,##0.00').format(balance / 100)} USDC',
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
            ]),
          ),
          if (sandbox)
            OutlinedButton.icon(onPressed: _simulate, icon: const Icon(Icons.call_received_rounded), label: const Text('Receive')),
        ]),
      ),
      const SizedBox(height: 14),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: _box(context),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('Pay out to', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final c in payoutCurrencies)
              ChoiceChip(
                label: Text('${c.$2.trim()} ${c.$1}'),
                selected: _cur == c.$1,
                onSelected: (_) => setState(() {
                  _cur = c.$1;
                  _quote = null;
                }),
              ),
          ]),
          const SizedBox(height: 12),
          TextField(
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
            decoration: const InputDecoration(labelText: 'USDC to convert', prefixText: '\$'),
            onChanged: (_) => setState(() => _quote = null),
          ),
          const SizedBox(height: 12),
          if (q != null && !q.expired) ...[
            Row(children: [
              Expanded(
                child: Text('You get ${_local(sym, q.outMinor)}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              ),
              Row(children: [
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: _green, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text('0:${secs.toString().padLeft(2, '0')}', style: const TextStyle(fontWeight: FontWeight.w800)),
              ]),
            ]),
            Text('Rate locked: 1 USDC = ${q.rate.toStringAsFixed(2)} $_cur',
                style: TextStyle(color: context.colors.inkSoft, fontSize: 13)),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _busy || _cents > balance ? null : _convert,
              style: FilledButton.styleFrom(backgroundColor: _indigo),
              child: Text(_cents > balance ? 'Not enough USDC' : 'Convert to ${payoutCurrencies.firstWhere((c) => c.$1 == _cur).$3.toLowerCase()}'),
            ),
          ] else
            FilledButton(
              onPressed: _cents > 0 ? _getQuote : null,
              style: FilledButton.styleFrom(backgroundColor: _indigo),
              child: Text(q != null ? 'Quote expired. Get a new rate' : 'Get a rate'),
            ),
        ]),
      ),
      const SizedBox(height: 18),
      const Text('Activity', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
      const SizedBox(height: 6),
      if (entries.isEmpty)
        Text('No USDC activity yet.', style: TextStyle(color: context.colors.inkSoft)),
      for (final e in entries)
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(e.usdcCents >= 0 ? Icons.south_west_rounded : Icons.swap_horiz_rounded,
              color: e.usdcCents >= 0 ? _green : _indigo),
          title: Text(e.label),
          subtitle: Text('${DateFormat('d MMM, h:mm a').format(e.at)} · ${e.reference}'),
          trailing: Text(
            e.usdcCents >= 0
                ? '+${_usd(e.usdcCents)}'
                : '${_usd(e.usdcCents)}\n${e.outCurrency} ${NumberFormat('#,##0').format((e.outMinor ?? 0) / 100)}',
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
    ]);
  }
}

// ── FX agent ───────────────────────────────────────────────────────────

class _FxAgentTab extends ConsumerStatefulWidget {
  const _FxAgentTab();
  @override
  ConsumerState<_FxAgentTab> createState() => _FxAgentTabState();
}

class _FxAgentTabState extends ConsumerState<_FxAgentTab> {
  String _pair = 'USD/NGN';

  // The FX agent runs app-wide (fxAgentProvider); this screen only shows it.
  Map<String, List<double>> get _history => ref.read(fxAgentProvider).history;

  Future<void> _addWatch() async {
    final h = _history[_pair];
    final now = h?.last ?? sandboxReferenceRates[_pair] ?? 0;
    final target = TextEditingController(text: (now * 1.01).toStringAsFixed(2));
    final amount = TextEditingController(text: '200');
    var auto = false;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => AlertDialog(
          title: Text('Watch $_pair'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Now ${now.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w700)),
            TextField(
                controller: target,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Act when the rate reaches')),
            TextField(
                controller: amount,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'USDC to convert', prefixText: '\$')),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Convert automatically'),
              subtitle: const Text('Off: just alert me'),
              value: auto,
              onChanged: (v) => set(() => auto = v),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Start watching')),
          ],
        ),
      ),
    );
    final t = double.tryParse(target.text);
    if (ok != true || t == null) return;
    ref.read(rateWatchProvider.notifier).add(RateWatch(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          pair: _pair,
          target: t,
          usdcCents: ((double.tryParse(amount.text) ?? 0) * 100).round(),
          autoConvert: auto,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final watches = ref.watch(rateWatchProvider);
    final h = ref.watch(fxAgentProvider).history[_pair] ?? const <double>[];
    final sandbox = ref.watch(partnerModeProvider) == PartnerMode.sandbox;
    final first = h.isEmpty ? 0.0 : h.first;
    final last = h.isEmpty ? 0.0 : h.last;
    final change = first == 0 ? 0.0 : (last - first) / first * 100;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addWatch,
        icon: const Icon(Icons.notifications_active_outlined),
        label: const Text('Watch a rate'),
      ),
      body: _page([
        if (sandbox) _sandboxBanner(context),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final c in payoutCurrencies)
            ChoiceChip(
              label: Text('USD → ${c.$1}'),
              selected: _pair == 'USD/${c.$1}',
              onSelected: (_) => setState(() => _pair = 'USD/${c.$1}'),
            ),
        ]),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: _box(context),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              Text(_pair, style: const TextStyle(fontWeight: FontWeight.w800)),
              const Spacer(),
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: _green, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text(sandbox ? 'Sandbox feed' : 'Live', style: const TextStyle(color: _green, fontWeight: FontWeight.w700, fontSize: 12)),
            ]),
            const SizedBox(height: 8),
            Text(last == 0 ? '…' : last.toStringAsFixed(2), style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
            Text('${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}% this session',
                style: TextStyle(color: change >= 0 ? _green : Colors.redAccent, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            SizedBox(height: 110, child: CustomPaint(painter: _SparkPainter(h))),
          ]),
        ),
        const SizedBox(height: 18),
        const Text('Rate watches', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 6),
        if (watches.isEmpty)
          Text('No watches. The agent can alert you, or convert for you, when a rate reaches your target.',
              style: TextStyle(color: context.colors.inkSoft)),
        for (final w in watches)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(w.firedAt != null ? Icons.check_circle : Icons.visibility_outlined,
                color: w.firedAt != null ? _green : _indigo),
            title: Text('${w.pair} ≥ ${w.target.toStringAsFixed(2)}'),
            subtitle: Text(w.firedAt != null
                ? 'Triggered ${DateFormat('d MMM, h:mm a').format(w.firedAt!)}'
                : '${w.autoConvert ? 'Convert' : 'Alert for'} ${_usd(w.usdcCents)}'),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => ref.read(rateWatchProvider.notifier).remove(w.id),
            ),
          ),
      ]),
    );
  }
}

class _SparkPainter extends CustomPainter {
  final List<double> v;
  _SparkPainter(this.v);

  @override
  void paint(Canvas canvas, Size size) {
    if (v.length < 2) return;
    var lo = v.reduce((a, b) => a < b ? a : b);
    var hi = v.reduce((a, b) => a > b ? a : b);
    if (hi == lo) {
      hi += 1;
      lo -= 1;
    }
    final path = Path();
    for (var i = 0; i < v.length; i++) {
      final p = Offset(i / (v.length - 1) * size.width, size.height - (v[i] - lo) / (hi - lo) * size.height);
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
        path,
        Paint()
          ..color = _green
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeJoin = StrokeJoin.round);
  }

  @override
  bool shouldRepaint(_SparkPainter o) => true;
}
