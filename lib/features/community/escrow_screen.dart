import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:url_launcher/url_launcher.dart';

class EscrowScreen extends StatelessWidget {
  const EscrowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (ctx) => const CreateEscrowSheet(),
          );
        },
        icon: const Icon(Icons.shield_outlined),
        label: const Text('New Escrow'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildEscrowCard(context, 'Macbook Pro 2021', 'NGN 850,000', 'Awaiting Delivery', 'Seller'),
        ],
      ),
    );
  }

  Widget _buildEscrowCard(BuildContext context, String item, String amount, String status, String role) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.bgSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              Text(amount, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Role: $role', style: TextStyle(color: context.colors.inkSoft, fontSize: 14)),
              Text(status, style: TextStyle(color: context.colors.bluePrimary, fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

class CreateEscrowSheet extends StatefulWidget {
  const CreateEscrowSheet({super.key});
  @override
  State<CreateEscrowSheet> createState() => _CreateEscrowSheetState();
}

class _CreateEscrowSheetState extends State<CreateEscrowSheet> {
  final _name = TextEditingController();
  final _amount = TextEditingController();
  final _counterparty = TextEditingController();
  bool _isLoading = false;

  Future<void> _create() async {
    setState(() => _isLoading = true);
    try {
      final res = await FirebaseFunctions.instance.httpsCallable('createEscrow').call({
        'itemName': _name.text,
        'amount': int.parse(_amount.text),
        'counterpartyId': _counterparty.text,
      });
      Navigator.pop(context);
      
      final url = res.data['fundingUrl'];
      if (url != null) {
        await launchUrl(Uri.parse(url));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 24, left: 24, right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: context.colors.scaffoldBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Create Escrow', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('Secure your transaction. Funds are held until delivery is confirmed.', style: TextStyle(color: context.colors.inkSoft)),
          const SizedBox(height: 24),
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Item Name')),
          const SizedBox(height: 16),
          TextField(controller: _amount, decoration: const InputDecoration(labelText: 'Amount'), keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          TextField(controller: _counterparty, decoration: const InputDecoration(labelText: 'Counterparty Email / ID')),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _isLoading ? null : _create,
            child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Lock Funds'),
          ),
        ],
      ),
    );
  }
}
