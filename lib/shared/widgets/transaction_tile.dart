import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../models/transaction.dart';

class TransactionTile extends StatelessWidget {
  final AppTransaction transaction;

  const TransactionTile({super.key, required this.transaction});

  IconData get _icon {
    switch (transaction.type) {
      case TransactionType.billPayment:
        return Icons.receipt_long_rounded;
      case TransactionType.transfer:
        return Icons.swap_horiz_rounded;
      case TransactionType.fx:
        return Icons.currency_exchange_rounded;
      case TransactionType.cardPayment:
        return Icons.credit_card_rounded;
      case TransactionType.deposit:
        return Icons.south_west_rounded;
      case TransactionType.withdrawal:
        return Icons.north_east_rounded;
      case TransactionType.fee:
        return Icons.receipt_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.isCredit;
    final sign = isCredit ? '+' : '-';
    final color = isCredit ? context.colors.success : context.colors.ink;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: context.colors.bgSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(_icon, color: context.colors.ink, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.counterparty ?? transaction.description ?? 'Transaction',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5, color: context.colors.ink),
                ),
                const SizedBox(height: 3),
                Text(
                  _relativeTime(transaction.createdAt),
                  style: TextStyle(color: context.colors.inkSoft, fontSize: 12.5, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          Text(
            '$sign ${transaction.amount.format(showSymbol: true)}',
            style: TextStyle(
              fontWeight: FontWeight.w800, 
              fontSize: 15, 
              color: color,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
