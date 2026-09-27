import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/providers/app_providers.dart';
import '../business/refunds_store.dart';
import '../intelligence/agents.dart';
import '../intelligence/intelligence_stores.dart';

/// One-tap shortcuts to the features that live off the bottom bar, with a
/// live line from each so the strip says something rather than just links.
class ExploreStrip extends ConsumerWidget {
  const ExploreStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safe = ref.watch(intelligenceEngineProvider).forecast().safeTodayNaira;
    final goals = ref.watch(goalsProvider).length;
    final pending = ref.watch(pendingIncomeProvider);
    final closing = ref.watch(refundsClosingSoonProvider).length;
    final findings = ref.watch(agentFindingsProvider);

    String n(int v) {
      final s = v.toString();
      final b = StringBuffer();
      for (var i = 0; i < s.length; i++) {
        if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
        b.write(s[i]);
      }
      return '₦$b';
    }

    final items = [
      (Icons.hub_rounded, 'Your agents', findings.isEmpty ? 'All clear' : '${findings.length} need${findings.length == 1 ? 's' : ''} you', HomeTab.intelligence, findings.isEmpty ? const Color(0xFF16123A) : const Color(0xFFD9432B)),
      (Icons.insights_rounded, 'Future Mode', '${n(safe)} safe today', HomeTab.intelligence, const Color(0xFF4B45F5)),
      (Icons.flag_rounded, 'Goals', goals == 0 ? 'Set your first goal' : '$goals active', HomeTab.intelligence, const Color(0xFF10B981)),
      (Icons.bolt_rounded, 'Autopilot', pending != null ? 'Income to split' : 'Plan your income', HomeTab.intelligence, const Color(0xFFF59E0B)),
      (Icons.public_rounded, 'Global money', 'USDC & FX agent', HomeTab.globalMoney, const Color(0xFF2775CA)),
      (Icons.diversity_3_rounded, 'Ajo & Escrow', closing > 0 ? '$closing refund closing' : 'Save & trade safely', HomeTab.community, const Color(0xFFEF7F5D)),
    ];

    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final it = items[i];
          return InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => ref.read(homeTabProvider.notifier).state = it.$4,
            child: Container(
              width: 168,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: context.colors.bgSoft,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: context.colors.border),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(color: it.$5, borderRadius: BorderRadius.circular(9)),
                  child: Icon(it.$1, color: Colors.white, size: 17),
                ),
                const Spacer(),
                Text(it.$2, style: TextStyle(fontWeight: FontWeight.w800, color: context.colors.ink)),
                Text(it.$3,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: context.colors.inkSoft)),
              ]),
            ),
          );
        },
      ),
    );
  }
}
