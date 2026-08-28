import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../models/money.dart';
import 'animated_balance_text.dart';
import 'sleek_trend_chart.dart';

class GradientBalanceCard extends StatelessWidget {
  final String label;
  final Money amount;
  final String? subtitle;

  const GradientBalanceCard({
    super.key,
    required this.label,
    required this.amount,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.transparent, // Completely borderless & transparent
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: context.colors.inkSoft,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 6),
          // Giant borderless balance display
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              AnimatedBalanceText(
                amount: amount,
                style: TextStyle(
                  color: context.colors.ink,
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.8,
                ),
              ),
              const SizedBox(width: 8),
              // Currency code indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: context.colors.blueHighlight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  amount.currency,
                  style: TextStyle(
                    color: context.colors.bluePrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: TextStyle(
                color: context.colors.inkSoft,
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 20),
          const SleekTrendChart(),
        ],
      ),
    );
  }
}
