import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../partners/partner_stores.dart';

const _indigo = Color(0xFF4B45F5);
const _green = Color(0xFF0F9D6B);

String _n(int naira) => '₦${NumberFormat('#,##0').format(naira)}';

/// Ajo / esusu saving circles: everyone contributes each round, one member
/// takes the pot, in an agreed order. gabis keeps the ledger and the
/// schedule; the organiser approves every payout.
class AjoScreen extends ConsumerWidget {
  const AjoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final circles = ref.watch(ajoProvider);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => const CreateAjoSheet(),
        ),
        icon: const Icon(Icons.add),
        label: const Text('New circle'),
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        if (circles.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 60),
            child: Text('No saving circles yet. Start one with the people you already save with.',
                textAlign: TextAlign.center, style: TextStyle(color: context.colors.inkSoft)),
          ),
        for (final c in circles) _CircleCard(c),
      ]),
    );
  }
}

class _CircleCard extends ConsumerWidget {
  final AjoCircle c;
  const _CircleCard(this.c);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(ajoProvider.notifier);
    final missing = c.members.length - c.paidThisRound.length;
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
          Expanded(child: Text(c.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
          Text(c.complete ? 'Complete' : 'Round ${c.round + 1} of ${c.members.length}',
              style: TextStyle(color: c.complete ? _green : _indigo, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 4),
        Text('${c.members.length} members · ${_n(c.contributionNaira)} ${c.frequency}',
            style: TextStyle(color: context.colors.inkSoft)),
        if (!c.complete) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: _indigo.withValues(alpha: .07), borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('This round\'s pot', style: TextStyle(color: context.colors.inkSoft, fontSize: 12)),
                  Text(_n(c.potNaira), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                  Text('to ${c.recipient} · ${DateFormat('EEE d MMM').format(c.nextPayoutOn)}',
                      style: const TextStyle(color: _indigo, fontWeight: FontWeight.w700, fontSize: 13)),
                ]),
              ),
              Text('${c.paidThisRound.length}/${c.members.length} paid', style: const TextStyle(fontWeight: FontWeight.w700)),
            ]),
          ),
          const SizedBox(height: 10),
          Text('Tap a member when their contribution arrives', style: TextStyle(color: context.colors.inkSoft, fontSize: 12)),
          const SizedBox(height: 6),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final m in c.members)
              FilterChip(
                label: Text(m),
                avatar: m == c.recipient ? const Icon(Icons.star_rounded, size: 16) : null,
                selected: c.paidThisRound.contains(m),
                onSelected: c.paidThisRound.contains(m) ? null : (_) => notifier.markPaid(c.id, m),
              ),
          ]),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: c.everyonePaid
                ? () => showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text('Pay ${_n(c.potNaira)} to ${c.recipient}?'),
                        content: const Text('Everyone has contributed this round. Approve to release the pot.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Not yet')),
                          FilledButton(
                            onPressed: () {
                              notifier.payOut(c.id);
                              Navigator.pop(ctx);
                            },
                            child: const Text('Approve payout'),
                          ),
                        ],
                      ),
                    )
                : null,
            style: FilledButton.styleFrom(backgroundColor: _indigo),
            child: Text(c.everyonePaid
                ? 'Pay out to ${c.recipient}'
                : 'Waiting for $missing contribution${missing == 1 ? '' : 's'}'),
          ),
        ],
      ]),
    );
  }
}

class CreateAjoSheet extends ConsumerStatefulWidget {
  const CreateAjoSheet({super.key});
  @override
  ConsumerState<CreateAjoSheet> createState() => _CreateAjoSheetState();
}

class _CreateAjoSheetState extends ConsumerState<CreateAjoSheet> {
  final _name = TextEditingController();
  final _amount = TextEditingController();
  final _members = TextEditingController();
  String _freq = 'monthly';

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    _members.dispose();
    super.dispose();
  }

  List<String> get _memberList =>
      _members.text.split(RegExp(r'[,\n]')).map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

  @override
  Widget build(BuildContext context) {
    final amount = int.tryParse(_amount.text.replaceAll(',', '')) ?? 0;
    final valid = _name.text.trim().isNotEmpty && amount > 0 && _memberList.length >= 2;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Text('Start a saving circle', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 14),
        TextField(controller: _name, decoration: const InputDecoration(labelText: 'Circle name'), onChanged: (_) => setState(() {})),
        TextField(
          controller: _amount,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(labelText: 'Contribution per member', prefixText: '₦'),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'weekly', label: Text('Weekly')),
            ButtonSegment(value: 'monthly', label: Text('Monthly')),
          ],
          selected: {_freq},
          onSelectionChanged: (s) => setState(() => _freq = s.first),
        ),
        TextField(
          controller: _members,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Members in payout order', hintText: 'Amaka, Kemi, Tunde, Femi'),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 8),
        if (_memberList.length >= 2 && amount > 0)
          Text('Each round pays ${_n(amount * _memberList.length)} to one member.',
              style: TextStyle(color: context.colors.inkSoft)),
        const SizedBox(height: 14),
        FilledButton(
          onPressed: valid
              ? () {
                  ref.read(ajoProvider.notifier).create(
                        name: _name.text.trim(),
                        members: _memberList,
                        contributionNaira: amount,
                        frequency: _freq,
                      );
                  Navigator.pop(context);
                }
              : null,
          child: const Text('Create circle'),
        ),
      ]),
    );
  }
}
