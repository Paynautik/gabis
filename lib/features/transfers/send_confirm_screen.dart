import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'send_success_screen.dart';

class SendConfirmScreen extends StatefulWidget {
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
  State<SendConfirmScreen> createState() => _SendConfirmScreenState();
}

class _SendConfirmScreenState extends State<SendConfirmScreen> {
  bool _submitting = false;

  Future<void> _confirm() async {
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
