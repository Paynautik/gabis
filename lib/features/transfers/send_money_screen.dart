import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/models/app_contact.dart';
import '../../shared/providers/contacts_provider.dart';
import '../../shared/widgets/in_app_notification.dart';
import 'send_confirm_screen.dart';

class SendMoneyScreen extends ConsumerStatefulWidget {
  const SendMoneyScreen({super.key, this.payee, this.amountMinor});

  /// Set when the screen is opened from a scanned code, so the user lands on
  /// the amount rather than searching for someone they just pointed a camera at.
  final AppContact? payee;

  /// An amount the code carried, if it had one.
  final int? amountMinor;

  @override
  ConsumerState<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends ConsumerState<SendMoneyScreen> {
  final _searchController = TextEditingController();
  final _amountController = TextEditingController();
  
  AppContact? _selectedContact;
  String _searchQuery = '';
  bool _notificationShown = false;

  static const _feeMinor = 5000; // ₦50

  @override
  void initState() {
    super.initState();
    _selectedContact = widget.payee;
    if (widget.amountMinor != null && widget.amountMinor! > 0) {
      _amountController.text = (widget.amountMinor! / 100).toStringAsFixed(2);
    }
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
    
    // Simulate contact joined notification shortly after opening
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && !_notificationShown) {
        InAppNotification.show(
          context,
          title: 'New Contact on gabis! 🎉',
          message: 'Your friend Sarah Jenkins just joined. Send her a welcome gift!',
        );
        _notificationShown = true;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.scaffoldBg,
      appBar: AppBar(
        title: Text('Send Money', style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w800)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: context.colors.ink),
      ),
      body: _selectedContact == null ? _buildContactsList() : _buildAmountEntry(),
    );
  }

  Widget _buildContactsList() {
    final allContacts = ref.watch(contactsProvider);
    final filteredContacts = allContacts.where((c) {
      return c.name.toLowerCase().contains(_searchQuery) || c.phone.contains(_searchQuery);
    }).toList();

    final onGabis = filteredContacts.where((c) => c.hasGabis).toList();
    final notOnGabis = filteredContacts.where((c) => !c.hasGabis).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: context.colors.bgSoft,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.colors.border),
            ),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'Search name, @username, or phone...',
                hintStyle: TextStyle(color: context.colors.inkSoft, fontWeight: FontWeight.w500),
                prefixIcon: Icon(Icons.search_rounded, color: context.colors.inkSoft),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: ListView(
              children: [
                if (onGabis.isNotEmpty) ...[
                  Text('On gabis', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: context.colors.inkSoft, letterSpacing: 0.5)),
                  const SizedBox(height: 12),
                  ...onGabis.map((c) => _buildContactTile(c)),
                  const SizedBox(height: 24),
                ],
                
                if (notOnGabis.isNotEmpty) ...[
                  Text('Invite to gabis', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: context.colors.inkSoft, letterSpacing: 0.5)),
                  const SizedBox(height: 12),
                  ...notOnGabis.map((c) => _buildContactTile(c)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile(AppContact contact) {
    return GestureDetector(
      onTap: () {
        if (contact.hasGabis) {
          setState(() => _selectedContact = contact);
        } else {
          // Trigger invite logic mock
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invite sent to ${contact.name}!', style: const TextStyle(fontWeight: FontWeight.w700))),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.colors.bgSoft,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.colors.border),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: contact.hasGabis ? context.colors.bluePrimary : context.colors.inkSoft.withValues(alpha: 0.2),
              child: Text(
                contact.initials,
                style: TextStyle(color: contact.hasGabis ? Colors.white : context.colors.ink, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(contact.name, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: context.colors.ink)),
                  const SizedBox(height: 2),
                  Text(contact.phone, style: TextStyle(color: context.colors.inkSoft, fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            if (contact.hasGabis)
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: context.colors.inkSoft)
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: context.colors.blueHighlight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('Invite', style: TextStyle(color: context.colors.bluePrimary, fontSize: 12, fontWeight: FontWeight.w800)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountEntry() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final amountMinor = (amount * 100).round();
    final totalMinor = amountMinor + _feeMinor;
    final canContinue = amountMinor > 0;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selected Contact Header
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back_rounded, color: context.colors.ink),
                onPressed: () => setState(() {
                  _selectedContact = null;
                  _amountController.clear();
                }),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 16),
              CircleAvatar(
                radius: 18,
                backgroundColor: context.colors.bluePrimary,
                child: Text(_selectedContact!.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sending to', style: TextStyle(fontSize: 11, color: context.colors.inkSoft, fontWeight: FontWeight.w600)),
                  Text(_selectedContact!.name, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: context.colors.ink)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          Text('Enter Amount', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: context.colors.inkSoft)),
          const SizedBox(height: 8),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            autofocus: true,
            onChanged: (_) => setState(() {}),
            style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: context.colors.ink, letterSpacing: -1.5),
            decoration: InputDecoration(
              hintText: '₦0',
              hintStyle: TextStyle(color: context.colors.inkSoft.withValues(alpha: 0.5)),
              border: InputBorder.none,
              prefixText: '₦',
              prefixStyle: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: context.colors.ink),
            ),
          ),
          
          const Spacer(),
          
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.colors.bgSoft,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: context.colors.border),
            ),
            child: Column(
              children: [
                _row('Transfer Fee', '₦${(_feeMinor / 100).toStringAsFixed(2)}'),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                _row('Total Debit', '₦${(totalMinor / 100).toStringAsFixed(2)}', bold: true),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.bluePrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              onPressed: canContinue
                  ? () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SendConfirmScreen(
                            recipient: _selectedContact!.name,
                            amountMinor: amountMinor,
                            feeMinor: _feeMinor,
                          ),
                        ),
                      );
                    }
                  : null,
              child: const Text('Continue', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: bold ? context.colors.ink : context.colors.inkSoft, fontSize: bold ? 15 : 14, fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
        Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: bold ? 17 : 14, color: context.colors.ink)),
      ],
    );
  }
}
