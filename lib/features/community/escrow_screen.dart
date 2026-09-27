import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_theme.dart';
import '../partners/partner_rails.dart';
import '../partners/partner_stores.dart';

const _indigo = Color(0xFF4B45F5);
const _green = Color(0xFF0F9D6B);

/// The app theme makes outlined buttons full-width, which breaks a Wrap of actions.
final _compact = OutlinedButton.styleFrom(minimumSize: const Size(0, 44));

String _n(int minor) => '₦${NumberFormat('#,##0').format(minor / 100)}';

/// Escrow: the buyer's money is held by the custody partner until delivery
/// is confirmed. Release always needs the buyer's explicit approval.
class EscrowScreen extends ConsumerWidget {
  const EscrowScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deals = ref.watch(escrowProvider);
    final sandbox = ref.watch(partnerModeProvider) == PartnerMode.sandbox;
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => const CreateEscrowSheet(),
        ),
        icon: const Icon(Icons.shield_outlined),
        label: const Text('New escrow'),
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        if (sandbox)
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFFBF1DC), borderRadius: BorderRadius.circular(12)),
            child: const Text(
              'Sandbox: deals and every step are recorded, but no money is held. Live, each step is signed by the buyer or seller in ORPay.',
              style: TextStyle(fontSize: 12, color: Color(0xFF9A6207), fontWeight: FontWeight.w600),
            ),
          ),
        if (deals.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 60),
            child: Text('No escrow deals yet. Buy or sell with the money held safely until delivery.',
                textAlign: TextAlign.center, style: TextStyle(color: context.colors.inkSoft)),
          ),
        for (final d in deals) _DealCard(d),
      ]),
    );
  }
}

class _DealCard extends ConsumerWidget {
  final EscrowDeal d;
  const _DealCard(this.d);

  static const _stepCopy = {
    EscrowStep.release: ('Release payment', 'Pay the seller now. Only do this once you have what you paid for. It cannot be undone.'),
    EscrowStep.refund: ('Refund', 'Return the money to the buyer and close the deal.'),
    EscrowStep.dispute: ('Dispute', 'Freeze the escrow and ask the arbiter to decide.'),
    EscrowStep.dispatch: ('Mark dispatched', 'Tell the buyer the item is on its way.'),
    EscrowStep.claim: ('Claim payment', 'The buyer did not respond in the review period. Claim what you are owed.'),
  };

  Future<bool> _confirm(BuildContext context, String title, String body) async =>
      await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Continue')),
          ],
        ),
      ) ==
      true;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = ref.read(escrowProvider.notifier);
    final sandbox = ref.watch(partnerModeProvider) == PartnerMode.sandbox;
    const labels = ['Opened', 'Funded', 'Dispatched', 'Released'];
    final reached = switch (d.stage) {
      EscrowStage.awaitingFunding => 0,
      EscrowStage.funded => 1,
      EscrowStage.dispatched => 2,
      EscrowStage.released => 3,
      _ => 1,
    };
    void snack(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

    final ended = switch (d.stage) {
      EscrowStage.refunded => 'Refunded to buyer',
      EscrowStage.disputed => 'In dispute · the arbiter decides',
      EscrowStage.cancelled => 'Cancelled before funding',
      _ => null,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.colors.bgSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(child: Text(d.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800))),
          Text(_n(d.amountMinor), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        ]),
        Text('${d.iAmBuyer ? 'Buying from' : 'Selling to'} ${d.counterparty}', style: TextStyle(color: context.colors.inkSoft)),
        const SizedBox(height: 14),
        if (ended != null)
          Text(ended,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: d.stage == EscrowStage.disputed ? Colors.orange : context.colors.inkSoft))
        else
          Row(children: [
            for (var i = 0; i < labels.length; i++) ...[
              Column(children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: i < reached || d.stage == EscrowStage.released
                      ? _green
                      : i == reached
                          ? _indigo
                          : context.colors.border,
                  child: i < reached || d.stage == EscrowStage.released
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : Text('${i + 1}', style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(height: 4),
                Text(labels[i], style: TextStyle(fontSize: 11, color: context.colors.inkSoft)),
              ]),
              if (i < labels.length - 1)
                Expanded(
                    child: Container(
                        height: 2,
                        margin: const EdgeInsets.only(bottom: 16),
                        color: i < reached ? _green : context.colors.border)),
            ],
          ]),
        const SizedBox(height: 12),
        if (d.stage == EscrowStage.awaitingFunding)
          Wrap(spacing: 8, runSpacing: 8, children: [
            if (d.iAmBuyer)
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: _indigo),
                onPressed: () async {
                  if (d.fundingUrl != null) {
                    await launchUrl(Uri.parse(d.fundingUrl!), mode: LaunchMode.externalApplication);
                  } else if (sandbox) {
                    n.simulateFunding(d.id);
                  }
                },
                child: Text(d.fundingUrl != null ? 'Fund in ORPay' : 'Fund (sandbox)'),
              ),
            if (d.iAmBuyer)
              OutlinedButton(
                style: _compact,
                onPressed: () async {
                  if (!await _confirm(context, 'Cancel this escrow?', 'Nothing has been paid in yet, so it simply closes.')) return;
                  final r = await n.cancel(d.id);
                  snack(r.message);
                },
                child: const Text('Cancel'),
              ),
            if (!d.iAmBuyer)
              Text('Waiting for ${d.counterparty} to fund it.', style: TextStyle(color: context.colors.inkSoft)),
          ]),
        if (d.stepsForMe().isNotEmpty)
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final st in d.stepsForMe())
              st == EscrowStep.release || st == EscrowStep.dispatch || st == EscrowStep.claim
                  ? FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: _indigo),
                      onPressed: () => _run(context, ref, st),
                      child: Text(_stepCopy[st]!.$1),
                    )
                  : OutlinedButton(style: _compact, onPressed: () => _run(context, ref, st), child: Text(_stepCopy[st]!.$1)),
          ]),
        if (!sandbox && d.stepsForMe().isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('You sign each step yourself in ORPay. gabis cannot move this money.',
                style: TextStyle(fontSize: 12, color: context.colors.inkSoft)),
          ),
        const SizedBox(height: 8),
        for (final l in d.log) Text('• $l', style: TextStyle(fontSize: 12, color: context.colors.inkSoft)),
      ]),
    );
  }

  Future<void> _run(BuildContext context, WidgetRef ref, EscrowStep st) async {
    final copy = _stepCopy[st]!;
    if (!await _confirm(context, '${copy.$1}: ${_n(d.amountMinor)}?', copy.$2)) return;
    final out = await ref.read(escrowProvider.notifier).step(d.id, st);
    if (out.signUrl != null) {
      await launchUrl(Uri.parse(out.signUrl!), mode: LaunchMode.externalApplication);
    }
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(out.message)));
  }
}

class CreateEscrowSheet extends ConsumerStatefulWidget {
  const CreateEscrowSheet({super.key});
  @override
  ConsumerState<CreateEscrowSheet> createState() => _CreateEscrowSheetState();
}

class _CreateEscrowSheetState extends ConsumerState<CreateEscrowSheet> {
  final _title = TextEditingController();
  final _who = TextEditingController();
  final _amount = TextEditingController();
  bool _buyer = true;
  bool _busy = false;

  @override
  void dispose() {
    _title.dispose();
    _who.dispose();
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final amount = int.tryParse(_amount.text.replaceAll(',', '')) ?? 0;
    final valid = _title.text.trim().isNotEmpty && _who.text.trim().isNotEmpty && amount > 0;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Text('New escrow', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(value: true, label: Text('I am buying')),
            ButtonSegment(value: false, label: Text('I am selling')),
          ],
          selected: {_buyer},
          onSelectionChanged: (s) => setState(() => _buyer = s.first),
        ),
        TextField(controller: _title, decoration: const InputDecoration(labelText: 'What is being sold'), onChanged: (_) => setState(() {})),
        TextField(
            controller: _who,
            decoration: InputDecoration(labelText: _buyer ? 'Seller (ORPay username)' : 'Buyer'),
            onChanged: (_) => setState(() {})),
        TextField(
          controller: _amount,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(labelText: 'Amount', prefixText: '₦'),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: valid && !_busy
              ? () async {
                  setState(() => _busy = true);
                  final o = await ref.read(escrowProvider.notifier).create(
                        title: _title.text.trim(),
                        counterparty: _who.text.trim(),
                        iAmBuyer: _buyer,
                        amountMinor: amount * 100,
                      );
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(o.result.message)));
                  if (_buyer && o.fundingUrl != null) {
                    await launchUrl(Uri.parse(o.fundingUrl!), mode: LaunchMode.externalApplication);
                  }
                }
              : null,
          child: Text(_busy ? 'Opening escrow…' : 'Open escrow'),
        ),
      ]),
    );
  }
}
