import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../partners/partner_rails.dart';
import 'business_dashboard_screen.dart' show GabisPalette;
import 'business_store.dart';
import 'refunds_store.dart';
import 'tax_rules.dart';

String _money(String symbol, int minor) => '$symbol${NumberFormat('#,##0').format(minor / 100)}';

Widget _sandboxNote(String text) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: GabisPalette.warnSurface, borderRadius: BorderRadius.circular(10)),
      child: Row(children: [
        const Icon(Icons.science_outlined, size: 16, color: GabisPalette.warn),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: GabisPalette.warn, fontWeight: FontWeight.w600))),
      ]),
    );

BoxDecoration _card() => BoxDecoration(
      color: GabisPalette.surface,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: GabisPalette.line),
    );

// ============================================================================
// TAX: seven corridors, VAT/GST/sales tax + WHT, remitted through the partner
// ============================================================================

class TaxCorridorsTab extends ConsumerStatefulWidget {
  const TaxCorridorsTab({super.key});
  @override
  ConsumerState<TaxCorridorsTab> createState() => _TaxCorridorsTabState();
}

class _TaxCorridorsTabState extends ConsumerState<TaxCorridorsTab> {
  String _code = 'NG';
  final _net = TextEditingController();
  int _band = 0;
  bool _clientWithholds = true;
  bool _remitting = false;

  @override
  void dispose() {
    _net.dispose();
    super.dispose();
  }

  int get _netMinor => ((double.tryParse(_net.text.replaceAll(',', '')) ?? 0) * 100).round();

  Future<void> _remit(TaxCorridor c, InvoiceTax t) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Remit ${c.taxName} to ${c.authority}?'),
        content: Text(
            '${_money(c.symbol, t.vatMinor)} for this period will be filed with ${c.authority}. '
            'You approve every remittance; nothing is paid automatically.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Approve & remit')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _remitting = true);
    final period = DateFormat('MMMM yyyy').format(DateTime.now());
    final r = await ref.read(taxRemitterProvider).remit(
          authority: c.authority,
          taxType: c.taxName,
          amountMinor: t.vatMinor,
          currency: c.currency,
          period: period,
        );
    if (!mounted) return;
    setState(() => _remitting = false);
    if (r.ok) {
      ref.read(businessProvider.notifier).fileTax(TaxFiling(
            currency: c.currency,
            jurisdiction: '${c.country} · ${c.authority} ${c.taxName} · ${r.reference}',
            revenue: t.netMinor / 100,
            rate: c.vatRate,
            filedAt: DateTime.now(),
            period: period,
          ));
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(r.message),
      backgroundColor: r.ok ? GabisPalette.success : GabisPalette.danger,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final c = corridorFor(_code);
    final band = c.whtBands[_band.clamp(0, c.whtBands.length - 1)];
    final t = taxInvoice(netMinor: _netMinor, vatRate: c.vatRate, whtRate: _clientWithholds ? band.rate : 0);
    final filings = ref.watch(businessProvider).filings;
    final sandbox = ref.watch(partnerModeProvider) == PartnerMode.sandbox;
    final pct = NumberFormat('0.##');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Tax across seven corridors',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: GabisPalette.ink)),
            const SizedBox(height: 6),
            const Text('Consumption tax and withholding tax on every invoice, ready to remit.',
                style: TextStyle(color: GabisPalette.inkSoft)),
            const SizedBox(height: 16),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final k in taxCorridors)
                ChoiceChip(
                  label: Text('${k.code} · ${k.country}'),
                  selected: k.code == _code,
                  onSelected: (_) => setState(() {
                    _code = k.code;
                    _band = 0;
                  }),
                ),
            ]),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: _card(),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(
                      child: Text('${c.country} · ${c.authority}',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
                  Text('${c.taxName} ${pct.format(c.vatRate * 100)}%',
                      style: const TextStyle(fontWeight: FontWeight.w700, color: GabisPalette.electric)),
                ]),
                const SizedBox(height: 14),
                TextField(
                  controller: _net,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.,]'))],
                  decoration: InputDecoration(labelText: 'Invoice amount before tax', prefixText: c.symbol),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: _band.clamp(0, c.whtBands.length - 1),
                  decoration: const InputDecoration(labelText: 'Withholding tax type'),
                  items: [
                    for (var i = 0; i < c.whtBands.length; i++)
                      DropdownMenuItem(
                          value: i, child: Text('${c.whtBands[i].label} · ${pct.format(c.whtBands[i].rate * 100)}%')),
                  ],
                  onChanged: (v) => setState(() => _band = v ?? 0),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Client withholds tax on this invoice'),
                  value: _clientWithholds,
                  onChanged: (v) => setState(() => _clientWithholds = v),
                ),
                const Divider(),
                _line('Amount', _money(c.symbol, t.netMinor)),
                _line('${c.taxName} ${pct.format(c.vatRate * 100)}%', '+ ${_money(c.symbol, t.vatMinor)}'),
                if (_clientWithholds)
                  _line('WHT ${pct.format(band.rate * 100)}% (withheld by client)', '− ${_money(c.symbol, t.whtMinor)}',
                      color: GabisPalette.danger),
                const Divider(),
                _line('You receive', _money(c.symbol, t.receivedMinor), bold: true),
                if (_clientWithholds && t.whtMinor > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                        'Ask the client for their WHT credit note for ${_money(c.symbol, t.whtMinor)}; it offsets your income tax.',
                        style: const TextStyle(fontSize: 12, color: GabisPalette.inkSoft)),
                  ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: t.vatMinor > 0 && !_remitting ? () => _remit(c, t) : null,
                    child: Text(_remitting
                        ? 'Remitting…'
                        : 'Remit ${_money(c.symbol, t.vatMinor)} ${c.taxName} to ${c.authority}'),
                  ),
                ),
                const SizedBox(height: 10),
                if (c.needsConfirmation)
                  _sandboxNote('Rates for ${c.country} still need confirming against ${c.authority}\'s current schedule. Check with a tax adviser before relying on them.'),
                if (sandbox) ...[
                  const SizedBox(height: 8),
                  _sandboxNote('Sandbox: filings are recorded but no payment reaches ${c.authority} until the tax-gateway partner is connected.'),
                ],
              ]),
            ),
            const SizedBox(height: 20),
            const Text('Filings', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 8),
            if (filings.isEmpty)
              const Text('No filings yet.', style: TextStyle(color: GabisPalette.inkSoft))
            else
              for (final f in filings.reversed.take(10))
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(f.jurisdiction),
                  subtitle: Text('${f.period} · filed ${DateFormat('d MMM').format(f.filedAt)}'),
                  trailing: Text('${f.currency} ${NumberFormat('#,##0').format(f.taxDue)}',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
          ]),
        ),
      ),
    );
  }

  Widget _line(String k, String v, {bool bold = false, Color? color}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          Expanded(child: Text(k, style: TextStyle(color: GabisPalette.inkSoft, fontWeight: bold ? FontWeight.w700 : FontWeight.w400))),
          Text(v,
              style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: bold ? 18 : 14, color: color ?? GabisPalette.ink)),
        ]),
      );
}

// ============================================================================
// REFUNDS: policy windows with a countdown
// ============================================================================

class RefundsTab extends ConsumerWidget {
  const RefundsTab({super.key});

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final order = TextEditingController();
    final customer = TextEditingController();
    final amount = TextEditingController();
    var days = 14;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => AlertDialog(
          title: const Text('Track a refund window'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: order, decoration: const InputDecoration(labelText: 'Order reference')),
            TextField(controller: customer, decoration: const InputDecoration(labelText: 'Customer')),
            TextField(
                controller: amount,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount', prefixText: '₦')),
            const SizedBox(height: 12),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 7, label: Text('7 days')),
                ButtonSegment(value: 14, label: Text('14 days')),
                ButtonSegment(value: 30, label: Text('30 days')),
              ],
              selected: {days},
              onSelectionChanged: (s) => set(() => days = s.first),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Start countdown')),
          ],
        ),
      ),
    );
    if (ok == true && order.text.trim().isNotEmpty) {
      ref.read(refundWindowsProvider.notifier).add(
            orderRef: order.text.trim(),
            customer: customer.text.trim().isEmpty ? 'Customer' : customer.text.trim(),
            amountMinor: ((double.tryParse(amount.text.replaceAll(',', '')) ?? 0) * 100).round(),
            policyDays: days,
          );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final windows = ref.watch(refundWindowsProvider);
    final soon = ref.watch(refundsClosingSoonProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _add(context, ref),
        icon: const Icon(Icons.timer_outlined),
        label: const Text('Track a sale'),
      ),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        const Text('Refund windows', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        const Text('Every sale counts down its refund policy. You are warned a day before a window closes.',
            style: TextStyle(color: GabisPalette.inkSoft)),
        const SizedBox(height: 16),
        if (soon.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: GabisPalette.warnSurface, borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              const Icon(Icons.notifications_active_outlined, color: GabisPalette.warn),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(
                      '${soon.length} refund window${soon.length == 1 ? '' : 's'} close${soon.length == 1 ? 's' : ''} within 24 hours: ${soon.map((w) => w.orderRef).join(', ')}',
                      style: const TextStyle(fontWeight: FontWeight.w600, color: GabisPalette.warn))),
            ]),
          ),
        if (windows.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 40),
            child: Center(child: Text('No sales tracked yet.', style: TextStyle(color: GabisPalette.inkSoft))),
          ),
        for (final w in windows) _WindowCard(w),
      ]),
    );
  }
}

class _WindowCard extends ConsumerWidget {
  final SaleWindow w;
  const _WindowCard(this.w);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = w.effectiveStatus();
    final left = w.remaining();
    final open = status == RefundStatus.open;
    final days = left.inDays;
    final hours = left.inHours % 24;
    final color = w.closingSoon() ? GabisPalette.coral : GabisPalette.electric;
    final notifier = ref.read(refundWindowsProvider.notifier);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: _card(),
      child: Row(children: [
        SizedBox(
          width: 64,
          height: 64,
          child: CustomPaint(
            painter: _RingPainter(open ? 1 - w.elapsedFraction() : 0, color),
            child: Center(
              child: open
                  ? Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(days > 0 ? '$days' : '${hours}h',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: color)),
                      Text(days > 0 ? 'days' : 'left', style: const TextStyle(fontSize: 10, color: GabisPalette.inkSoft)),
                    ])
                  : const Icon(Icons.lock_clock, color: GabisPalette.inkFaint),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${w.orderRef} · ${w.customer}', style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text(
                '${w.policyDays}-day policy · ${_money('₦', w.amountMinor)} · ${switch (status) {
                  RefundStatus.open => 'closes ${DateFormat('EEE d MMM, h:mm a').format(w.closesAt)}',
                  RefundStatus.requested => 'refund requested',
                  RefundStatus.refunded => 'refunded',
                  RefundStatus.closed => 'window closed',
                }}',
                style: const TextStyle(fontSize: 12, color: GabisPalette.inkSoft)),
          ]),
        ),
        PopupMenuButton<String>(
          onSelected: (v) {
            switch (v) {
              case 'req':
                notifier.setStatus(w.id, RefundStatus.requested);
              case 'done':
                notifier.setStatus(w.id, RefundStatus.refunded);
              case 'del':
                notifier.remove(w.id);
            }
          },
          itemBuilder: (_) => [
            if (open) const PopupMenuItem(value: 'req', child: Text('Customer asked for a refund')),
            if (status == RefundStatus.requested) const PopupMenuItem(value: 'done', child: Text('Mark refunded')),
            const PopupMenuItem(value: 'del', child: Text('Stop tracking')),
          ],
        ),
      ]),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double fraction;
  final Color color;
  _RingPainter(this.fraction, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final track = Paint()
      ..color = GabisPalette.creamDeep
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    final arc = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect.deflate(3), 0, math.pi * 2, false, track);
    canvas.drawArc(rect.deflate(3), -math.pi / 2, math.pi * 2 * fraction, false, arc);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.fraction != fraction || old.color != color;
}
