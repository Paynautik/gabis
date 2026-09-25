import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class AjoScreen extends StatelessWidget {
  const AjoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (ctx) => const CreateAjoSheet(),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Circle'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAjoCard(context, 'Weekend Trip', 'NGN 50,000 / week', '3 members', true),
          const SizedBox(height: 16),
          _buildAjoCard(context, 'New Laptop', 'NGN 10,000 / month', '5 members', false),
        ],
      ),
    );
  }

  Widget _buildAjoCard(BuildContext context, String title, String amount, String members, bool isActive) {
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
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(isActive ? 'Active' : 'Pending', 
                  style: TextStyle(color: isActive ? Colors.green : Colors.orange, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(amount, style: TextStyle(color: context.colors.inkSoft, fontSize: 15)),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.group_rounded, size: 16, color: context.colors.inkSoft),
              const SizedBox(width: 6),
              Text(members, style: TextStyle(color: context.colors.inkSoft, fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}

class CreateAjoSheet extends StatefulWidget {
  const CreateAjoSheet({super.key});
  @override
  State<CreateAjoSheet> createState() => _CreateAjoSheetState();
}

class _CreateAjoSheetState extends State<CreateAjoSheet> {
  final _name = TextEditingController();
  final _amount = TextEditingController();
  final _freq = TextEditingController();
  bool _isLoading = false;

  Future<void> _create() async {
    setState(() => _isLoading = true);
    try {
      final res = await FirebaseFunctions.instance.httpsCallable('createAjo').call({
        'circleName': _name.text,
        'contribution': int.parse(_amount.text),
        'frequency': _freq.text,
      });
      Navigator.pop(context);
      
      final url = res.data['checkoutUrl'];
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
          const Text('Create Saving Circle', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('Automate collections and payouts with OpenReserve.', style: TextStyle(color: context.colors.inkSoft)),
          const SizedBox(height: 24),
          TextField(controller: _name, decoration: const InputDecoration(labelText: 'Circle Name (e.g. Rent)')),
          const SizedBox(height: 16),
          TextField(controller: _amount, decoration: const InputDecoration(labelText: 'Contribution Amount'), keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          TextField(controller: _freq, decoration: const InputDecoration(labelText: 'Frequency (Weekly/Monthly)')),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _isLoading ? null : _create,
            child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Initialize Circle'),
          ),
        ],
      ),
    );
  }
}
