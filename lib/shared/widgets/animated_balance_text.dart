import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/money.dart';

class AnimatedBalanceText extends StatelessWidget {
  final Money amount;
  final TextStyle style;
  final Duration duration;

  const AnimatedBalanceText({
    super.key,
    required this.amount,
    required this.style,
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: amount.major),
      duration: duration,
      curve: Curves.easeOutQuint,
      builder: (context, value, child) {
        final formatted = NumberFormat('#,##0.00').format(value);
        return Text(
          '${amount.symbol}$formatted',
          style: style,
        );
      },
    );
  }
}
