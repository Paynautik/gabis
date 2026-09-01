import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import 'points_store.dart';

/// The Gabis Points wallet: what you have, how it was earned, and what it
/// turns into. Redeeming actually moves the balance and writes a ledger entry.
class PointsScreen extends ConsumerWidget {
  const PointsScreen({super.key});

  static const _lime = Color(0xFFD9FF43);
  static const _ink = Color(0xFF101010);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final points = ref.watch(pointsProvider);
    final categories = <String, List<Reward>>{};
    for (final r in rewardCatalogue) {
      categories.putIfAbsent(r.category, () => []).add(r);
    }

    return Scaffold(
      backgroundColor: context.colors.scaffoldBg,
      appBar: AppBar(
        title: const Text('Gabis Points'),
        backgroundColor: context.colors.scaffoldBg,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          _BalanceCard(points: points),
          const SizedBox(height: 26),

          _SectionTitle('Redeem'),
          const SizedBox(height: 4),
          Text('Points come off your balance the moment you redeem.',
              style: TextStyle(color: context.colors.inkSoft, fontSize: 13)),
          const SizedBox(height: 14),
          for (final entry in categories.entries) ...[
            Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 10),
              child: Text(entry.key,
                  style: TextStyle(
                    fontSize: 10.5,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w900,
                    color: context.colors.inkSoft,
                  )),
            ),
            for (final reward in entry.value)
              _RewardTile(reward: reward, balance: points.balance),
            const SizedBox(height: 10),
          ],

          const SizedBox(height: 16),
          _SectionTitle('How you earn'),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: context.colors.bgSoft,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.colors.border),
            ),
            child: Column(
              children: [
                for (var i = 0; i < earnRules.length; i++)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      border: i == 0
                          ? null
                          : Border(top: BorderSide(color: context.colors.border)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(earnRules[i].$1,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700, fontSize: 14.5)),
                              const SizedBox(height: 3),
                              Text(earnRules[i].$3,
                                  style: TextStyle(
                                      color: context.colors.inkSoft, fontSize: 12.5)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(earnRules[i].$2,
                            style: const TextStyle(
                                fontWeight: FontWeight.w900, fontSize: 12.5)),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 26),
          _SectionTitle('Activity'),
          const SizedBox(height: 12),
          if (points.entries.isEmpty)
            Text('Nothing yet. Points appear here as you use the account.',
                style: TextStyle(color: context.colors.inkSoft, fontSize: 13))
          else
            ...points.entries.take(20).map((e) => _EntryRow(entry: e)),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final PointsState points;
  const _BalanceCard({required this.points});

  @override
  Widget build(BuildContext context) {
    final progress = points.toNextTier == 0
        ? 1.0
        : (points.lifetimeEarned >= 3000
            ? (points.lifetimeEarned - 3000) / 7000
            : points.lifetimeEarned / 3000);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2B2F12), PointsScreen._ink],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PointsScreen._lime.withValues(alpha: .35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: PointsScreen._lime,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(points.tier.toUpperCase(),
                    style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                        color: PointsScreen._ink)),
              ),
              const Spacer(),
              Text('${points.lifetimeEarned} earned all time',
                  style: const TextStyle(color: Color(0x99FFFFFF), fontSize: 11.5)),
            ],
          ),
          const SizedBox(height: 18),
          const Text('Balance',
              style: TextStyle(color: Color(0x99FFFFFF), fontSize: 12.5)),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('${points.balance}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.8)),
              const SizedBox(width: 8),
              const Text('pts',
                  style: TextStyle(
                      color: PointsScreen._lime,
                      fontSize: 15,
                      fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: .12),
              valueColor: const AlwaysStoppedAnimation(PointsScreen._lime),
            ),
          ),
          const SizedBox(height: 9),
          Text(
            points.toNextTier == 0
                ? 'Gold — the top tier. Nothing left to climb.'
                : '${points.toNextTier} pts to ${points.tier == 'Bronze' ? 'Silver' : 'Gold'}',
            style: const TextStyle(color: Color(0x99FFFFFF), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _RewardTile extends ConsumerWidget {
  final Reward reward;
  final int balance;

  const _RewardTile({required this.reward, required this.balance});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final affordable = balance >= reward.cost;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.bgSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.colors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reward.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 15)),
                const SizedBox(height: 3),
                Text(reward.detail,
                    style:
                        TextStyle(color: context.colors.inkSoft, fontSize: 12.5)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Fixed width on purpose: a Row gives non-flex children unbounded
          // width, so a bare button here swallows the space and squeezes the
          // text beside it to one character per line.
          SizedBox(
            width: 108,
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${reward.cost} pts',
                  style: const TextStyle(
                      fontWeight: FontWeight.w900, fontSize: 13)),
              const SizedBox(height: 6),
              SizedBox(
                height: 30,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: affordable
                      ? () => _confirm(context, ref)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PointsScreen._ink,
                    foregroundColor: PointsScreen._lime,
                    disabledBackgroundColor:
                        context.colors.inkSoft.withValues(alpha: .16),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100)),
                  ),
                  child: Text(affordable ? 'Redeem' : 'Short',
                      style: const TextStyle(
                          fontSize: 11.5, fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
          ),
        ],
      ),
    );
  }

  void _confirm(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Redeem ${reward.title}?'),
        content: Text(
            '${reward.cost} points will come off your balance. ${reward.detail}'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final ok = ref.read(pointsProvider.notifier).redeem(reward);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(ok
                    ? '${reward.title} redeemed. It is on its way.'
                    : 'Not enough points for that yet.'),
                backgroundColor:
                    ok ? const Color(0xFF10B981) : const Color(0xFFEF4444),
              ));
            },
            child: const Text('Redeem'),
          ),
        ],
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  final PointsEntry entry;
  const _EntryRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final earned = entry.kind == PointsKind.earned;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: earned
                  ? PointsScreen._lime.withValues(alpha: .25)
                  : context.colors.inkSoft.withValues(alpha: .12),
              shape: BoxShape.circle,
            ),
            child: Icon(
                earned ? Icons.add_rounded : Icons.redeem_rounded,
                size: 16,
                color: context.colors.ink),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.reason,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14)),
                const SizedBox(height: 2),
                Text(_when(entry.at),
                    style:
                        TextStyle(color: context.colors.inkSoft, fontSize: 11.5)),
              ],
            ),
          ),
          Text('${earned ? '+' : ''}${entry.amount}',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 14,
                color: earned ? const Color(0xFF10B981) : context.colors.ink,
              )),
        ],
      ),
    );
  }

  String _when(DateTime at) {
    final days = DateTime.now().difference(at).inDays;
    if (days == 0) return 'Today';
    if (days == 1) return 'Yesterday';
    if (days < 30) return '$days days ago';
    return '${at.day}/${at.month}/${at.year}';
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, letterSpacing: -.6));
}
