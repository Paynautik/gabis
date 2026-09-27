import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

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

  static const _palette = [Color(0xFF8B5CF6), Color(0xFFEF7F5D), Color(0xFF0F9D6B), Color(0xFF3B82F6), Color(0xFFE3A008), Color(0xFF4B45F5)];

  /// WhatsApp formatting: *bold*, one fact per line, and a gabis link last so
  /// WhatsApp shows the preview card with the gabis logo.
  String _reminder(List<String> who) {
    final date = DateFormat('EEE d MMM').format(c.nextPayoutOn);
    return [
      '*gabis · Ajo reminder*',
      '',
      'Hi ${who.length == 1 ? who.first : 'everyone'},',
      'your contribution to *${c.name}* is due.',
      '',
      'Amount: *${_n(c.contributionNaira)}*',
      'Round: *${c.round + 1} of ${c.members.length}*',
      'This round: *${c.recipient}* receives *${_n(c.potNaira)}* on *$date*',
      'Paid so far: ${c.paidThisRound.length} of ${c.members.length}',
      '',
      'Thank you for keeping the circle strong.',
      'https://gabis.pages.dev/ajo',
    ].join('\n');
  }

  Future<void> _remind(BuildContext context, WidgetRef ref, List<String> who) async {
    final url = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(_reminder(who))}');
    await launchUrl(url, mode: LaunchMode.externalApplication);
    ref.read(ajoProvider.notifier).logReminder(c.id, who);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(ajoProvider.notifier);
    final days = c.nextPayoutOn.difference(DateTime.now()).inDays;
    final progress = c.paidThisRound.length / c.members.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.bgSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(c.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              Text('${c.members.length} members · ${_n(c.contributionNaira)} ${c.frequency}',
                  style: TextStyle(color: context.colors.inkSoft)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: (c.complete ? _green : _indigo).withValues(alpha: .1),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(c.complete ? 'Complete' : 'Round ${c.round + 1} of ${c.members.length}',
                style: TextStyle(color: c.complete ? _green : _indigo, fontWeight: FontWeight.w700, fontSize: 12)),
          ),
        ]),
        const SizedBox(height: 18),
        if (!c.complete)
          LayoutBuilder(builder: (context, box) {
            final wide = box.maxWidth > 560;
            final ring = _Ring(circle: c, palette: _palette);
            final panel = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('This round\'s pot', style: TextStyle(color: context.colors.inkSoft, fontSize: 12)),
              Text(_n(c.potNaira), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -.5)),
              Text('to ${c.recipient} · ${days <= 0 ? 'due today' : 'in $days day${days == 1 ? '' : 's'}'} (${DateFormat('EEE d MMM').format(c.nextPayoutOn)})',
                  style: const TextStyle(color: _indigo, fontWeight: FontWeight.w700, fontSize: 13)),
              const SizedBox(height: 14),
              Row(children: [
                Text('${c.paidThisRound.length} of ${c.members.length} paid', style: const TextStyle(fontWeight: FontWeight.w700)),
                const Spacer(),
                Text(_n(c.paidThisRound.length * c.contributionNaira), style: TextStyle(color: context.colors.inkSoft)),
              ]),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(value: progress, minHeight: 8, color: _green, backgroundColor: _green.withValues(alpha: .12)),
              ),
            ]);
            return wide
                ? Row(children: [ring, const SizedBox(width: 24), Expanded(child: panel)])
                : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Center(child: ring), const SizedBox(height: 16), panel]);
          }),
        if (!c.complete) ...[
          const SizedBox(height: 16),
          Text('Tap a member when their contribution arrives', style: TextStyle(color: context.colors.inkSoft, fontSize: 12)),
          const SizedBox(height: 8),
          for (final m in c.members)
            _MemberRow(
              name: m,
              color: _palette[c.members.indexOf(m) % _palette.length],
              paid: c.paidThisRound.contains(m),
              receives: m == c.recipient,
              onPaid: () {
                final auto = notifier.markPaid(c.id, m);
                if (auto) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Everyone paid. ${_n(c.potNaira)} sent to ${c.recipient} automatically.')));
                }
              },
              onRemind: () => _remind(context, ref, [m]),
            ),
          const SizedBox(height: 10),
          Row(children: [
            if (c.unpaid.isNotEmpty)
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(minimumSize: const Size(0, 46)),
                  onPressed: () => _remind(context, ref, c.unpaid),
                  icon: const Icon(Icons.chat_rounded, size: 18),
                  label: Text('Remind ${c.unpaid.length} on WhatsApp'),
                ),
              ),
            if (c.unpaid.isNotEmpty) const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: _indigo, minimumSize: const Size(0, 46)),
                onPressed: c.everyonePaid
                    ? () => showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text('Pay ${_n(c.potNaira)} to ${c.recipient}?'),
                            content: const Text('Everyone has contributed this round.'),
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
                child: Text(c.everyonePaid ? 'Pay out to ${c.recipient}' : 'Payout unlocks when all have paid'),
              ),
            ),
          ]),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: c.autoPayout,
            onChanged: (v) => notifier.setAutoPayout(c.id, v),
            title: const Text('Auto-payout', style: TextStyle(fontWeight: FontWeight.w700)),
            subtitle: const Text('Pay the pot out the moment the last contribution arrives. You approve this once, for every round.'),
          ),
        ],
        const Divider(height: 28),
        Text('SCHEDULE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1, color: context.colors.inkSoft)),
        const SizedBox(height: 8),
        for (var r = 0; r < c.members.length; r++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(children: [
              Icon(
                r < c.round ? Icons.check_circle_rounded : r == c.round ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
                size: 18,
                color: r < c.round ? _green : r == c.round ? _indigo : context.colors.border,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text('Round ${r + 1} · ${c.members[r]}', style: TextStyle(fontWeight: r == c.round ? FontWeight.w800 : FontWeight.w500))),
              Text(r < c.round ? 'Received' : DateFormat('d MMM').format(c.payoutOn(r)), style: TextStyle(color: context.colors.inkSoft, fontSize: 13)),
            ]),
          ),
        if (c.history.isNotEmpty) ...[
          const Divider(height: 28),
          Text('ACTIVITY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1, color: context.colors.inkSoft)),
          const SizedBox(height: 6),
          for (final e in c.history.reversed.take(6))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(children: [
                Expanded(child: Text(e.text, style: const TextStyle(fontSize: 13))),
                Text(DateFormat('d MMM, h:mm a').format(e.at), style: TextStyle(color: context.colors.inkSoft, fontSize: 12)),
              ]),
            ),
        ],
      ]),
    );
  }
}

class _MemberRow extends StatelessWidget {
  final String name;
  final Color color;
  final bool paid;
  final bool receives;
  final VoidCallback onPaid;
  final VoidCallback onRemind;
  const _MemberRow({required this.name, required this.color, required this.paid, required this.receives, required this.onPaid, required this.onRemind});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        CircleAvatar(radius: 16, backgroundColor: color, child: Text(name.isEmpty ? '?' : name[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800))),
        const SizedBox(width: 10),
        Expanded(
          child: Row(children: [
            Flexible(child: Text(name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700))),
            if (receives) ...[
              const SizedBox(width: 6),
              const Icon(Icons.star_rounded, size: 16, color: Color(0xFFE3A008)),
            ],
          ]),
        ),
        if (paid)
          const Row(children: [Icon(Icons.check_circle_rounded, color: _green, size: 18), SizedBox(width: 4), Text('Paid', style: TextStyle(color: _green, fontWeight: FontWeight.w700))])
        else ...[
          IconButton(tooltip: 'Remind on WhatsApp', onPressed: onRemind, icon: const Icon(Icons.chat_outlined, size: 18)),
          TextButton(onPressed: onPaid, child: const Text('Mark paid')),
        ],
      ]),
    );
  }
}

/// Members around a ring, paid ones ticked, this round's recipient
/// highlighted, the pot in the middle.
class _Ring extends StatelessWidget {
  final AjoCircle circle;
  final List<Color> palette;
  const _Ring({required this.circle, required this.palette});

  @override
  Widget build(BuildContext context) {
    const size = 190.0, r = 74.0;
    final n = circle.members.length;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _RingPainter(circle.paidThisRound.length / n, context.colors.border),
          ),
        ),
        Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('${circle.paidThisRound.length}/$n', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            Text('paid', style: TextStyle(fontSize: 11, color: context.colors.inkSoft)),
          ]),
        ),
        for (var i = 0; i < n; i++)
          Builder(builder: (_) {
            final a = -math.pi / 2 + i * 2 * math.pi / n;
            final m = circle.members[i];
            final cur = m == circle.recipient;
            final d = cur ? 38.0 : 30.0;
            return Positioned(
              left: size / 2 + math.cos(a) * r - d / 2,
              top: size / 2 + math.sin(a) * r - d / 2,
              child: Container(
                width: d,
                height: d,
                decoration: BoxDecoration(
                  color: palette[i % palette.length],
                  shape: BoxShape.circle,
                  border: Border.all(color: cur ? const Color(0xFFDFF76A) : Colors.white, width: cur ? 4 : 2),
                ),
                alignment: Alignment.center,
                child: circle.paidThisRound.contains(m)
                    ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                    : Text(m.isEmpty ? '?' : m[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
              ),
            );
          }),
      ]),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double fraction;
  final Color track;
  _RingPainter(this.fraction, this.track);
  @override
  void paint(Canvas canvas, Size s) {
    final rect = Rect.fromCircle(center: s.center(Offset.zero), radius: 74);
    canvas.drawArc(rect, 0, math.pi * 2, false, Paint()..color = track..style = PaintingStyle.stroke..strokeWidth = 6);
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * fraction, false,
        Paint()..color = _green..style = PaintingStyle.stroke..strokeWidth = 6..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_RingPainter o) => o.fraction != fraction;
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
  bool _auto = false;

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
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _auto,
          onChanged: (v) => setState(() => _auto = v),
          title: const Text('Auto-payout'),
          subtitle: const Text('Pay each round out as soon as everyone has contributed'),
        ),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: valid
              ? () {
                  ref.read(ajoProvider.notifier).create(
                        name: _name.text.trim(),
                        members: _memberList,
                        contributionNaira: amount,
                        frequency: _freq,
                        autoPayout: _auto,
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
