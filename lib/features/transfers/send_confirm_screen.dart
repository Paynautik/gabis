import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../intelligence/payment_guard.dart';
import '../../core/theme/app_theme.dart';
import 'send_success_screen.dart';

class SendConfirmScreen extends ConsumerStatefulWidget {
  final String recipient;
  final int amountMinor;
  final int feeMinor;

  const SendConfirmScreen({
    super.key,
    required this.recipient,
    required this.amountMinor,
    required this.feeMinor,
  });

  @override
  ConsumerState<SendConfirmScreen> createState() => _SendConfirmScreenState();
}

class _SendConfirmScreenState extends ConsumerState<SendConfirmScreen> {
  bool _submitting = false;

  /// The Financial Firewall's second opinion. Returns false when the person
  /// decides not to go ahead. It explains and asks; it never blocks alone.
  Future<bool> _firewall() async {
    final verdict = ref.read(paymentGuardProvider).check(
          recipient: widget.recipient,
          amountMinor: widget.amountMinor,
        );
    if (!verdict.shouldPause) return true;

    final reasons = verdict.signals.map((s) => s.reason).toList();
    final go = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.shield_rounded, color: Color(0xFFEF4444), size: 36),
        title: const Text('gabis paused this payment'),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('₦${(widget.amountMinor / 100).toStringAsFixed(2)} → ${widget.recipient}',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 10),
          for (final r in reasons) Text('• $r'),
          const SizedBox(height: 12),
          const Text('“This doesn’t look like you.” If someone is pressuring you to pay, stop and call them back on a number you trust.',
              style: TextStyle(fontStyle: FontStyle.italic)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Approve anyway')),
          FilledButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel payment')),
        ],
      ),
    );
    ref.read(guardLogProvider.notifier).record(GuardEvent(
          recipient: widget.recipient,
          amountMinor: widget.amountMinor,
          reasons: reasons,
          outcome: go == true ? 'approved' : 'cancelled',
          at: DateTime.now(),
        ));
    return go == true;
  }

  Future<void> _confirm() async {
    if (!await _firewall()) {
      if (mounted) Navigator.of(context).pop();
      return;
    }
    if (!mounted) return;
    setState(() => _submitting = true);
    // Sensitive action: in production this step requires biometric/PIN
    // confirmation before the backend executes the transfer.
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => SendSuccessScreen(
          recipient: widget.recipient,
          amountMinor: widget.amountMinor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.amountMinor + widget.feeMinor;

    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Payment')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.colors.bgSoft,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: context.colors.border),
              ),
              child: Column(
                children: [
                  _row('Recipient', widget.recipient),
                  const SizedBox(height: 14),
                  _row('Amount', '₦${(widget.amountMinor / 100).toStringAsFixed(2)}'),
                  const SizedBox(height: 14),
                  _row('Fee', '₦${(widget.feeMinor / 100).toStringAsFixed(2)}'),
                  const Divider(height: 28),
                  _row('Total', '₦${(total / 100).toStringAsFixed(2)}', bold: true),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.fingerprint_rounded, color: context.colors.bluePrimary, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Confirming will ask for biometric or PIN verification.',
                    style: TextStyle(color: context.colors.inkSoft, fontSize: 13),
                  ),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _submitting ? null : _confirm,
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                    )
                  : const Text('Confirm'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: bold ? context.colors.ink : context.colors.inkSoft, fontSize: bold ? 15 : 14, fontWeight: bold ? FontWeight.w800 : FontWeight.w500)),
        Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: bold ? 17 : 14)),
      ],
    );
  }
}
