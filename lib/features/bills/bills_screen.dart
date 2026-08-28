import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/models/money.dart';
import '../../shared/models/transaction.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/widgets/glowing_background.dart';

class BillCategory {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String? subtitle;

  const BillCategory({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    this.subtitle,
  });
}

class BillsScreen extends ConsumerStatefulWidget {
  const BillsScreen({super.key});

  @override
  ConsumerState<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends ConsumerState<BillsScreen> {
  String _searchQuery = '';

  static const List<BillCategory> _categories = [
    BillCategory(
      title: 'Buy airtime',
      icon: Icons.signal_cellular_alt_rounded,
      iconColor: Color(0xFF9333EA),
      bgColor: Color(0xFFF3E8FF),
    ),
    BillCategory(
      title: 'Buy data',
      icon: Icons.wifi_rounded,
      iconColor: Color(0xFF2563EB),
      bgColor: Color(0xFFDBEAFE),
    ),
    BillCategory(
      title: 'Airlines, Travels & Transportation/Logistics',
      icon: Icons.flight_rounded,
      iconColor: Color(0xFF0284C7),
      bgColor: Color(0xFFE0F2FE),
    ),
    BillCategory(
      title: 'Cable TV',
      icon: Icons.tv_rounded,
      iconColor: Color(0xFF0D9488),
      bgColor: Color(0xFFCCFBF1),
    ),
    BillCategory(
      title: 'Capital Market & Investments',
      icon: Icons.trending_up_rounded,
      iconColor: Color(0xFFD97706),
      bgColor: Color(0xFFFEF3C7),
    ),
    BillCategory(
      title: 'Distributors & Agent Payments',
      icon: Icons.assignment_rounded,
      iconColor: Color(0xFFDB2777),
      bgColor: Color(0xFFFCE7F3),
    ),
    BillCategory(
      title: 'Electricity & Water',
      icon: Icons.water_drop_rounded,
      iconColor: Color(0xFF0284C7),
      bgColor: Color(0xFFE0F2FE),
    ),
    BillCategory(
      title: 'Entertainment & E-Vouchers',
      icon: Icons.confirmation_number_rounded,
      iconColor: Color(0xFF65A30D),
      bgColor: Color(0xFFECFCCB),
    ),
    BillCategory(
      title: 'Estates & Associations',
      icon: Icons.home_work_rounded,
      iconColor: Color(0xFF4F46E5),
      bgColor: Color(0xFFE0E7FF),
    ),
    BillCategory(
      title: 'Financial Institutions',
      icon: Icons.account_balance_rounded,
      iconColor: Color(0xFF9333EA),
      bgColor: Color(0xFFF3E8FF),
    ),
    BillCategory(
      title: 'NIBSSEBILLSPAY',
      icon: Icons.bolt_rounded,
      iconColor: Color(0xFF16A34A),
      bgColor: Color(0xFFDCFCE7),
    ),
    BillCategory(
      title: 'PAYDIRECT',
      icon: Icons.send_and_archive_rounded,
      iconColor: Color(0xFF65A30D),
      bgColor: Color(0xFFECFCCB),
    ),
    BillCategory(
      title: 'Religious Institutions & NGO',
      icon: Icons.church_rounded,
      iconColor: Color(0xFFDB2777),
      bgColor: Color(0xFFFCE7F3),
    ),
    BillCategory(
      title: 'Remita',
      icon: Icons.sync_alt_rounded,
      iconColor: Color(0xFFEA580C),
      bgColor: Color(0xFFFFEDD5),
    ),
    BillCategory(
      title: 'Schools & Professional Bodies',
      icon: Icons.school_rounded,
      iconColor: Color(0xFFDC2626),
      bgColor: Color(0xFFFEE2E2),
    ),
    BillCategory(
      title: 'Shipping Line Payment',
      icon: Icons.inventory_2_rounded,
      iconColor: Color(0xFFEA580C),
      bgColor: Color(0xFFFFEDD5),
    ),
    BillCategory(
      title: 'Sports and Gaming',
      icon: Icons.sports_tennis_rounded,
      iconColor: Color(0xFF16A34A),
      bgColor: Color(0xFFDCFCE7),
    ),
    BillCategory(
      title: 'Toll Fees - LCC',
      icon: Icons.directions_car_rounded,
      iconColor: Color(0xFFDC2626),
      bgColor: Color(0xFFFEE2E2),
    ),
    BillCategory(
      title: 'Utilities',
      icon: Icons.cottage_rounded,
      iconColor: Color(0xFFD97706),
      bgColor: Color(0xFFFEF3C7),
    ),
    BillCategory(
      title: 'VISA Fee Payment',
      icon: Icons.layers_rounded,
      iconColor: Color(0xFF4F46E5),
      bgColor: Color(0xFFE0E7FF),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _categories.where((cat) {
      return cat.title.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: context.colors.scaffoldBg,
      appBar: AppBar(
        title: Text(
          'Payments',
          style: TextStyle(
            color: context.colors.ink,
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.colors.ink, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: GlowingBackground(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: context.colors.bgSoft,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: context.colors.border),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, color: context.colors.inkSoft, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        style: TextStyle(color: context.colors.ink, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Search billers, utilities, services...',
                          hintStyle: TextStyle(color: context.colors.inkSoft, fontSize: 14),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onChanged: (val) => setState(() => _searchQuery = val),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: () => setState(() => _searchQuery = ''),
                        child: Icon(Icons.close_rounded, size: 18, color: context.colors.inkSoft),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Payments List
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, size: 48, color: context.colors.inkSoft.withValues(alpha: 0.4)),
                          const SizedBox(height: 12),
                          Text('No payment categories match your search', style: TextStyle(color: context.colors.inkSoft, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        indent: 64,
                        endIndent: 16,
                        color: context.colors.border.withValues(alpha: 0.5),
                      ),
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: item.bgColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(item.icon, color: item.iconColor, size: 22),
                          ),
                          title: Text(
                            item.title,
                            style: TextStyle(
                              color: context.colors.ink,
                              fontWeight: FontWeight.w700,
                              fontSize: 14.5,
                            ),
                          ),
                          trailing: Icon(
                            Icons.chevron_right_rounded,
                            color: context.colors.inkSoft.withValues(alpha: 0.6),
                            size: 20,
                          ),
                          onTap: () => _handleCategoryTap(context, item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleCategoryTap(BuildContext context, BillCategory item) {
    if (item.title == 'Buy airtime' || item.title == 'Buy data') {
      _showAirtimeDataSheet(context, isData: item.title == 'Buy data');
    } else if (item.title == 'Electricity & Water' || item.title == 'Utilities') {
      _showElectricitySheet(context);
    } else if (item.title == 'Cable TV') {
      _showCableTvSheet(context);
    } else {
      _showGenericPaymentSheet(context, item);
    }
  }

  void _showAirtimeDataSheet(BuildContext context, {required bool isData}) {
    String selectedNetwork = 'MTN';
    final phoneController = TextEditingController(text: '08139284719');
    final amountController = TextEditingController(text: isData ? '2500' : '1000');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.bgSoft,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isData ? 'Buy Internet Data' : 'Buy Mobile Airtime',
                      style: TextStyle(color: context.colors.ink, fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                    IconButton(icon: Icon(Icons.close_rounded, color: context.colors.inkSoft), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Select Network Provider:', style: TextStyle(color: context.colors.inkSoft, fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Row(
                  children: ['MTN', 'Airtel', 'Glo', '9mobile'].map((net) {
                    final isSel = selectedNetwork == net;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setSheetState(() => selectedNetwork = net),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSel ? context.colors.bluePrimary : context.colors.scaffoldBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isSel ? context.colors.bluePrimary : context.colors.border),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            net,
                            style: TextStyle(
                              color: isSel ? Colors.white : context.colors.ink,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    labelStyle: TextStyle(color: context.colors.inkSoft),
                    prefixIcon: Icon(Icons.phone_iphone_rounded, color: context.colors.inkSoft, size: 20),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: context.colors.border)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: context.colors.bluePrimary, width: 2)),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w900, fontSize: 18),
                  decoration: InputDecoration(
                    labelText: 'Amount (₦)',
                    labelStyle: TextStyle(color: context.colors.inkSoft),
                    prefixText: '₦ ',
                    prefixStyle: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w900),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: context.colors.border)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: context.colors.bluePrimary, width: 2)),
                  ),
                ),
                const SizedBox(height: 22),
                ElevatedButton(
                  onPressed: () {
                    final amt = int.tryParse(amountController.text) ?? 1000;
                    final minor = amt * 100;
                    ref.read(accountsProvider.notifier).subtractBalance('NGN', minor);
                    ref.read(transactionsProvider.notifier).addTransaction(
                      AppTransaction(
                        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
                        type: TransactionType.billPayment,
                        status: TransactionStatus.completed,
                        amount: Money(minorUnits: minor, currency: 'NGN'),
                        description: '$selectedNetwork ${isData ? "Data Topup" : "Airtime"} (${phoneController.text})',
                        counterparty: selectedNetwork,
                        createdAt: DateTime.now(),
                        isCredit: false,
                      ),
                    );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('₦$amt $selectedNetwork ${isData ? "Data" : "Airtime"} purchased successfully!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.bluePrimary,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    'Pay Now',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showElectricitySheet(BuildContext context) {
    String selectedDisco = 'IKEDC (Ikeja Electric)';
    final meterController = TextEditingController(text: '04291847291');
    final amountController = TextEditingController(text: '5000');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.bgSoft,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Pay Electricity Bill', style: TextStyle(color: context.colors.ink, fontSize: 18, fontWeight: FontWeight.w900)),
                    IconButton(icon: Icon(Icons.close_rounded, color: context.colors.inkSoft), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedDisco,
                  dropdownColor: context.colors.bgSoft,
                  style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    labelText: 'Distribution Company (Disco)',
                    labelStyle: TextStyle(color: context.colors.inkSoft),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: context.colors.border)),
                  ),
                  items: [
                    'IKEDC (Ikeja Electric)',
                    'EKEDC (Eko Electric)',
                    'AEDC (Abuja Electric)',
                    'IBEDC (Ibadan Electric)',
                  ].map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(fontSize: 13)))).toList(),
                  onChanged: (v) => setSheetState(() => selectedDisco = v!),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: meterController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    labelText: 'Meter Number / Account Number',
                    labelStyle: TextStyle(color: context.colors.inkSoft),
                    prefixIcon: Icon(Icons.electric_bolt_rounded, color: context.colors.inkSoft, size: 20),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: context.colors.border)),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w900, fontSize: 18),
                  decoration: InputDecoration(
                    labelText: 'Amount (₦)',
                    labelStyle: TextStyle(color: context.colors.inkSoft),
                    prefixText: '₦ ',
                    prefixStyle: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w900),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: context.colors.border)),
                  ),
                ),
                const SizedBox(height: 22),
                ElevatedButton(
                  onPressed: () {
                    final amt = int.tryParse(amountController.text) ?? 5000;
                    final minor = amt * 100;
                    ref.read(accountsProvider.notifier).subtractBalance('NGN', minor);
                    ref.read(transactionsProvider.notifier).addTransaction(
                      AppTransaction(
                        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
                        type: TransactionType.billPayment,
                        status: TransactionStatus.completed,
                        amount: Money(minorUnits: minor, currency: 'NGN'),
                        description: 'Electricity Token (${meterController.text})',
                        counterparty: selectedDisco.split(' ')[0],
                        createdAt: DateTime.now(),
                        isCredit: false,
                      ),
                    );
                    Navigator.pop(ctx);
                    _showTokenSuccessDialog(context, meterController.text, amt.toString());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.bluePrimary,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Purchase Power Token', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showTokenSuccessDialog(BuildContext context, String meter, String amount) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.bgSoft,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 28),
            const SizedBox(width: 10),
            Text('Power Token Ready', style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w900, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Payment of ₦$amount for Meter #$meter was successful.', style: TextStyle(color: context.colors.inkSoft, fontSize: 13)),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.colors.scaffoldBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.colors.border),
              ),
              child: Column(
                children: [
                  const Text('PREPAID TOKEN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey)),
                  const SizedBox(height: 6),
                  const Text('4829-1092-3819-0928-1192', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Color(0xFF10B981))),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Done')),
        ],
      ),
    );
  }

  void _showCableTvSheet(BuildContext context) {
    String selectedProvider = 'DSTV';
    final cardController = TextEditingController(text: '7029184719');
    final amountController = TextEditingController(text: '14500');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.bgSoft,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Cable TV Subscription', style: TextStyle(color: context.colors.ink, fontSize: 18, fontWeight: FontWeight.w900)),
                    IconButton(icon: Icon(Icons.close_rounded, color: context.colors.inkSoft), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: ['DSTV', 'GOtv', 'StarTimes', 'Showmax'].map((provider) {
                    final isSel = selectedProvider == provider;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setSheetState(() => selectedProvider = provider),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isSel ? context.colors.bluePrimary : context.colors.scaffoldBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isSel ? context.colors.bluePrimary : context.colors.border),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            provider,
                            style: TextStyle(
                              color: isSel ? Colors.white : context.colors.ink,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: cardController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    labelText: 'IUC / Smartcard Number',
                    labelStyle: TextStyle(color: context.colors.inkSoft),
                    prefixIcon: Icon(Icons.credit_card_rounded, color: context.colors.inkSoft, size: 20),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: context.colors.border)),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w900, fontSize: 18),
                  decoration: InputDecoration(
                    labelText: 'Package Amount (₦)',
                    labelStyle: TextStyle(color: context.colors.inkSoft),
                    prefixText: '₦ ',
                    prefixStyle: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w900),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: context.colors.border)),
                  ),
                ),
                const SizedBox(height: 22),
                ElevatedButton(
                  onPressed: () {
                    final amt = int.tryParse(amountController.text) ?? 14500;
                    final minor = amt * 100;
                    ref.read(accountsProvider.notifier).subtractBalance('NGN', minor);
                    ref.read(transactionsProvider.notifier).addTransaction(
                      AppTransaction(
                        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
                        type: TransactionType.billPayment,
                        status: TransactionStatus.completed,
                        amount: Money(minorUnits: minor, currency: 'NGN'),
                        description: '$selectedProvider Renewal (${cardController.text})',
                        counterparty: selectedProvider,
                        createdAt: DateTime.now(),
                        isCredit: false,
                      ),
                    );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$selectedProvider subscription renewed successfully!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.bluePrimary,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Renew Subscription', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showGenericPaymentSheet(BuildContext context, BillCategory item) {
    final refController = TextEditingController();
    final amountController = TextEditingController(text: '5000');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.bgSoft,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: TextStyle(color: context.colors.ink, fontSize: 17, fontWeight: FontWeight.w900),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(icon: Icon(Icons.close_rounded, color: context.colors.inkSoft), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: refController,
              style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                labelText: 'Account / Reference / ID Number',
                labelStyle: TextStyle(color: context.colors.inkSoft),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: context.colors.border)),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w900, fontSize: 18),
              decoration: InputDecoration(
                labelText: 'Amount (₦)',
                labelStyle: TextStyle(color: context.colors.inkSoft),
                prefixText: '₦ ',
                prefixStyle: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w900),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: context.colors.border)),
              ),
            ),
            const SizedBox(height: 22),
            ElevatedButton(
              onPressed: () {
                final amt = int.tryParse(amountController.text) ?? 5000;
                final minor = amt * 100;
                ref.read(accountsProvider.notifier).subtractBalance('NGN', minor);
                ref.read(transactionsProvider.notifier).addTransaction(
                  AppTransaction(
                    id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
                    type: TransactionType.billPayment,
                    status: TransactionStatus.completed,
                    amount: Money(minorUnits: minor, currency: 'NGN'),
                    description: '${item.title} Payment',
                    counterparty: item.title,
                    createdAt: DateTime.now(),
                    isCredit: false,
                  ),
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${item.title} payment of ₦$amt completed!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.bluePrimary,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Proceed with Payment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
