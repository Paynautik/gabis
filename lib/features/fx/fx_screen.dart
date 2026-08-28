import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/models/money.dart';
import '../../shared/models/transaction.dart';
import '../../shared/providers/app_providers.dart';
import '../transfers/send_success_screen.dart';

class FxScreen extends ConsumerStatefulWidget {
  const FxScreen({super.key});

  @override
  ConsumerState<FxScreen> createState() => _FxScreenState();
}

class _FxScreenState extends ConsumerState<FxScreen> {
  final _controller = TextEditingController(text: '500000');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rate = ref.watch(fxRateProvider);
    final accounts = ref.watch(accountsProvider);
    final ngnAccount = accounts.firstWhere((a) => a.currency == 'NGN');
    
    final amount = double.tryParse(_controller.text) ?? 0;
    final fee = amount * 0.002; // 0.2% fee
    final amountWithFee = amount + fee;
    final receive = amount / rate;

    return Scaffold(
      appBar: AppBar(title: const Text('Exchange')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('From', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: context.colors.inkSoft, letterSpacing: 1.0)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: context.colors.border)),
              child: Row(
                children: [
                  Text('NGN', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: context.colors.ink)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                      textAlign: TextAlign.right,
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: context.colors.ink),
                      decoration: const InputDecoration(border: InputBorder.none, isDense: true, filled: false),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Available: ${ngnAccount.balance.format()}', 
              style: TextStyle(color: context.colors.inkSoft, fontSize: 12, fontWeight: FontWeight.w600)
            ),
            const SizedBox(height: 12),
            Center(child: Icon(Icons.arrow_downward_rounded, color: context.colors.bluePrimary)),
            const SizedBox(height: 12),
            Text('To', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: context.colors.inkSoft, letterSpacing: 1.0)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: context.colors.border)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('USD', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: context.colors.ink)),
                  Text(
                    '\$${receive.toStringAsFixed(2)}', 
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: context.colors.ink, letterSpacing: -0.2)
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _row('Exchange Rate', '1 USD = ₦${rate.toStringAsFixed(0)}'),
            _row('Elumo Fee (0.2%)', '₦${fee.toStringAsFixed(2)}'),
            _row('Total Cost', '₦${amountWithFee.toStringAsFixed(2)}'),
            const Spacer(),
            ElevatedButton(
              onPressed: amount > 0 ? () => _showExchangeReviewSheet(context, amount, receive, fee, rate) : null, 
              child: const Text('Review exchange'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: context.colors.inkSoft, fontSize: 13.5, fontWeight: FontWeight.w600)),
          Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: context.colors.ink)),
        ],
      ),
    );
  }

  // --- Review FX Exchange Sheet ---
  void _showExchangeReviewSheet(BuildContext context, double amount, double receive, double fee, double rate) {
    final amountMinor = ((amount + fee) * 100).toInt();
    final receiveMinor = (receive * 100).toInt();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Confirm Exchange',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: context.colors.ink),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Sell NGN', style: TextStyle(color: context.colors.inkSoft, fontWeight: FontWeight.w700)),
                        Text('₦${amount.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.w900, color: context.colors.ink)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Buy USD', style: TextStyle(color: context.colors.inkSoft, fontWeight: FontWeight.w700)),
                        Text('\$${receive.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.w900, color: context.colors.ink)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Fee', style: TextStyle(color: context.colors.inkSoft, fontWeight: FontWeight.w700)),
                        Text('₦${fee.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.w800, color: context.colors.ink)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  final ngnAccount = ref.read(accountsProvider).firstWhere((a) => a.currency == 'NGN');
                  if (ngnAccount.balance.minorUnits < amountMinor) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: context.colors.danger,
                        content: Text('Insufficient NGN balance to cover exchange!'),
                      ),
                    );
                    return;
                  }

                  // Perform exchange
                  ref.read(accountsProvider.notifier).subtractBalance('NGN', amountMinor);
                  ref.read(accountsProvider.notifier).addBalance('USD', receiveMinor);

                  // Add Transactions (two legs for auditability)
                  ref.read(transactionsProvider.notifier).addTransaction(
                        AppTransaction(
                          id: 'fx_sell_${DateTime.now().millisecondsSinceEpoch}',
                          type: TransactionType.fx,
                          status: TransactionStatus.completed,
                          amount: Money(minorUnits: amountMinor, currency: 'NGN'),
                          description: 'Exchanged NGN to USD',
                          counterparty: 'FX Wallet',
                          createdAt: DateTime.now(),
                          isCredit: false,
                        ),
                      );

                  Navigator.pop(context); // Close sheet
                  Navigator.pop(context); // Pop exchange screen

                  // Show gorgeous success confetti screen!
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SendSuccessScreen(
                        recipient: 'USD Account',
                        amountMinor: amountMinor, // Will show converted value in Naira sent
                      ),
                    ),
                  );
                },
                child: const Text('Confirm Exchange'),
              ),
            ],
          ),
        );
      },
    );
  }
}
