import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/models/transaction.dart';
import '../../shared/models/money.dart';
import '../../shared/providers/app_providers.dart';

// --- Transactions Screen ---
class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  String _filter = 'ALL';
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final transactions = ref.watch(transactionsProvider);

    final filtered = transactions.where((tx) {
      final matchesSearch = (tx.counterparty ?? '').toLowerCase().contains(_query.toLowerCase()) ||
          (tx.description ?? '').toLowerCase().contains(_query.toLowerCase());
      if (!matchesSearch) return false;
      if (_filter == 'INFLOW') return tx.isCredit;
      if (_filter == 'OUTFLOW') return !tx.isCredit;
      if (_filter == 'BILLS') return tx.type == TransactionType.billPayment;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: context.colors.scaffoldBg,
      appBar: AppBar(
        title: Text('Transaction History', style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.file_download_outlined, color: context.colors.bluePrimary),
            tooltip: 'Export Statement',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Transaction report exported to PDF & CSV!')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              children: [
                // Search Bar
                Container(
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
                          style: TextStyle(color: context.colors.ink, fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Search counterparty, description...',
                            hintStyle: TextStyle(color: context.colors.inkSoft, fontSize: 13),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onChanged: (val) => setState(() => _query = val),
                        ),
                      ),
                      if (_query.isNotEmpty)
                        GestureDetector(
                          onTap: () => setState(() => _query = ''),
                          child: Icon(Icons.close_rounded, size: 16, color: context.colors.inkSoft),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Filter chips
                Row(
                  children: [
                    _filterChip('ALL', 'All'),
                    _filterChip('INFLOW', 'Inflow'),
                    _filterChip('OUTFLOW', 'Outflow'),
                    _filterChip('BILLS', 'Bills'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 48, color: context.colors.inkSoft.withValues(alpha: 0.4)),
                        const SizedBox(height: 12),
                        Text('No transactions found', style: TextStyle(color: context.colors.inkSoft, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final tx = filtered[index];
                      final isCredit = tx.isCredit;
                      return Container(
                        decoration: BoxDecoration(
                          color: context.colors.bgSoft,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: context.colors.border),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          leading: CircleAvatar(
                            backgroundColor: isCredit ? const Color(0x1A16A34A) : const Color(0x1AEF4444),
                            child: Icon(
                              isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                              color: isCredit ? const Color(0xFF16A34A) : const Color(0xFFEF4444),
                              size: 18,
                            ),
                          ),
                          title: Text(tx.counterparty ?? 'Unknown', style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w800, fontSize: 14)),
                          subtitle: Text(tx.description ?? '', style: TextStyle(color: context.colors.inkSoft, fontSize: 12)),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${isCredit ? '+' : '-'}${tx.amount.format()}',
                                style: TextStyle(
                                  color: isCredit ? const Color(0xFF16A34A) : context.colors.ink,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text('Success', style: TextStyle(color: const Color(0xFF16A34A), fontSize: 10, fontWeight: FontWeight.w700)),
                            ],
                          ),
                          onTap: () => _showTxDetails(context, tx),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String key, String label) {
    final isSelected = _filter == key;
    return GestureDetector(
      onTap: () => setState(() => _filter = key),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? context.colors.bluePrimary : context.colors.bgSoft,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? context.colors.bluePrimary : context.colors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : context.colors.ink,
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  void _showTxDetails(BuildContext context, AppTransaction tx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.bgSoft,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(color: Color(0x1A16A34A), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 30),
            ),
            const SizedBox(height: 12),
            Text('Transaction Receipt', style: TextStyle(color: context.colors.ink, fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(tx.amount.format(), style: TextStyle(color: context.colors.ink, fontSize: 28, fontWeight: FontWeight.w900)),
            const Divider(height: 32),
            _row(context, 'Recipient / Source', tx.counterparty ?? 'N/A'),
            const SizedBox(height: 10),
            _row(context, 'Payment Type', tx.type.name.toUpperCase()),
            const SizedBox(height: 10),
            _row(context, 'Description', tx.description ?? 'Transfer'),
            const SizedBox(height: 10),
            _row(context, 'Reference ID', tx.id),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Receipt PDF saved to device!')));
              },
              icon: const Icon(Icons.download_rounded, color: Colors.white),
              label: const Text('Share / Download PDF', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.bluePrimary,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: context.colors.inkSoft, fontSize: 13)),
        Text(value, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w800, fontSize: 13)),
      ],
    );
  }
}

// --- Analytics Screen ---
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _period = 'Month';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.scaffoldBg,
      appBar: AppBar(
        title: Text('Financial Analytics', style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _periodBtn('Week'),
                const SizedBox(width: 8),
                _periodBtn('Month'),
                const SizedBox(width: 8),
                _periodBtn('Year'),
              ],
            ),
            const SizedBox(height: 20),

            // Summary Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF1D4ED8).withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Outflow This Month', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  const Text('₦10,525,000.00', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _summaryStat('Income', '₦45,000,000.00', Icons.arrow_downward_rounded, const Color(0xFF4ADE80)),
                      _summaryStat('Savings', '₦12,400,000.00', Icons.savings_rounded, Colors.amberAccent),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            Text('SPENDING BREAKDOWN', style: TextStyle(color: context.colors.inkSoft, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
            const SizedBox(height: 16),
            _buildStatBar(context, 'Shopping & Logistics', 0.45, '₦4,736,250.00', context.colors.bluePrimary),
            const SizedBox(height: 14),
            _buildStatBar(context, 'Food, Groceries & Dining', 0.25, '₦2,631,250.00', Colors.orange),
            const SizedBox(height: 14),
            _buildStatBar(context, 'Bills, Power & Internet', 0.15, '₦1,578,750.00', Colors.purple),
            const SizedBox(height: 14),
            _buildStatBar(context, 'Transport & Fuel', 0.10, '₦1,052,500.00', Colors.teal),
            const SizedBox(height: 14),
            _buildStatBar(context, 'Entertainment & Streaming', 0.05, '₦526,250.00', Colors.pinkAccent),
          ],
        ),
      ),
    );
  }

  Widget _periodBtn(String label) {
    final isSelected = _period == label;
    return GestureDetector(
      onTap: () => setState(() => _period = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? context.colors.bluePrimary : context.colors.bgSoft,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? context.colors.bluePrimary : context.colors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : context.colors.ink,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _summaryStat(String label, String amount, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
            Text(amount, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatBar(BuildContext context, String label, double percentage, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
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
              Text(label, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w800, fontSize: 13)),
              Text(amount, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w900, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: context.colors.scaffoldBg,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Beneficiaries Screen ---
class BeneficiariesScreen extends StatelessWidget {
  const BeneficiariesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final names = ['Alice Smith', 'Bob Johnson', 'Charlie Davis', 'Diana Evans', 'Evan Miller'];
    return Scaffold(
      backgroundColor: context.colors.scaffoldBg,
      appBar: AppBar(
        title: Text('Beneficiaries', style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [IconButton(icon: Icon(Icons.add_rounded, color: context.colors.ink), onPressed: () => _showAddBeneficiary(context))],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: names.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final name = names[index];
          final initials = name.split(' ').map((e) => e[0]).join('');
          return Container(
            decoration: BoxDecoration(
              color: context.colors.bgSoft,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.colors.border),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: CircleAvatar(
                radius: 22,
                backgroundColor: context.colors.bluePrimary.withValues(alpha: 0.1),
                child: Text(initials, style: TextStyle(color: context.colors.bluePrimary, fontSize: 15, fontWeight: FontWeight.w900)),
              ),
              title: Text(name, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w800, fontSize: 15)),
              subtitle: Text('Guaranty Trust Bank • 0192837412', style: TextStyle(color: context.colors.inkSoft, fontSize: 12)),
              trailing: IconButton(
                onPressed: () => _showSendToBeneficiary(context, name),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: context.colors.bluePrimary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.send_rounded, color: context.colors.bluePrimary, size: 16),
                ),
              ),
              onTap: () => _showSendToBeneficiary(context, name),
            ),
          );
        },
      ),
    );
  }

  void _showSendToBeneficiary(BuildContext context, String name) {
    final amountController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.bgSoft,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Send to $name', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: context.colors.ink)),
                  IconButton(icon: Icon(Icons.close_rounded, color: context.colors.inkSoft), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w800),
                decoration: InputDecoration(
                  labelText: 'Amount (₦)',
                  labelStyle: TextStyle(color: context.colors.inkSoft),
                  prefixText: '₦ ',
                  prefixStyle: TextStyle(color: context.colors.ink, fontWeight: FontWeight.bold),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: context.colors.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: context.colors.bluePrimary, width: 2)),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('₦${amountController.text.isEmpty ? "5,000.00" : amountController.text} sent to $name!')));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.bluePrimary,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Send Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _showAddBeneficiary(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.bgSoft,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Add Beneficiary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: context.colors.ink)),
                  IconButton(icon: Icon(Icons.close_rounded, color: context.colors.inkSoft), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                style: TextStyle(color: context.colors.ink),
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  labelStyle: TextStyle(color: context.colors.inkSoft),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: context.colors.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: context.colors.bluePrimary, width: 2)),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                keyboardType: TextInputType.number,
                style: TextStyle(color: context.colors.ink),
                decoration: InputDecoration(
                  labelText: 'Account Number',
                  labelStyle: TextStyle(color: context.colors.inkSoft),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: context.colors.border)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: context.colors.bluePrimary, width: 2)),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('New Beneficiary saved!')));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.bluePrimary,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Save Beneficiary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

// --- Settings Screen ---
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: context.colors.scaffoldBg,
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0x1A10B981), Color(0x0D10B981)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Premium Tier Active', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.w900, fontSize: 16)),
                      const SizedBox(height: 2),
                      Text('Zero conversion fees & unlimited virtual cards', style: TextStyle(color: context.colors.inkSoft, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text('PREFERENCES', style: TextStyle(color: context.colors.inkSoft, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 1.0)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: context.colors.bgSoft,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: context.colors.border),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.dark_mode_rounded, color: context.colors.ink),
                  title: Text('Dark Mode', style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w700)),
                  subtitle: Text('Switch between Light and Dark interface', style: TextStyle(color: context.colors.inkSoft, fontSize: 12)),
                  trailing: Switch(
                    value: isDark,
                    activeThumbColor: context.colors.bluePrimary,
                    onChanged: (v) {
                      ref.read(themeModeProvider.notifier).state = v ? ThemeMode.dark : ThemeMode.light;
                    },
                  ),
                ),
                Divider(height: 1, color: context.colors.border),
                ListTile(
                  leading: Icon(Icons.notifications_rounded, color: context.colors.ink),
                  title: Text('Notifications', style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w700)),
                  subtitle: Text('Transaction alerts, rate changes, promos', style: TextStyle(color: context.colors.inkSoft, fontSize: 12)),
                  trailing: Icon(Icons.chevron_right_rounded, color: context.colors.inkSoft),
                  onTap: () => _showNotificationSettings(context),
                ),
                Divider(height: 1, color: context.colors.border),
                ListTile(
                  leading: Icon(Icons.security_rounded, color: context.colors.ink),
                  title: Text('Security & Privacy', style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w700)),
                  subtitle: Text('Biometrics, Passcode, 2FA & Sessions', style: TextStyle(color: context.colors.inkSoft, fontSize: 12)),
                  trailing: Icon(Icons.chevron_right_rounded, color: context.colors.inkSoft),
                  onTap: () => _showSecuritySettings(context),
                ),
                Divider(height: 1, color: context.colors.border),
                // Off for a real account, on for a demo. Explicit either way,
                // so nobody mistakes example figures for their own money.
                ListTile(
                  leading: Icon(Icons.science_outlined, color: context.colors.ink),
                  title: Text('Example data',
                      style: TextStyle(
                          color: context.colors.ink, fontWeight: FontWeight.w700)),
                  subtitle: Text(
                      'Fill the app with sample balances, transactions and a business book — for demos, not your real money',
                      style: TextStyle(color: context.colors.inkSoft, fontSize: 12)),
                  trailing: Switch(
                    value: ref.watch(demoDataProvider),
                    activeThumbColor: context.colors.bluePrimary,
                    onChanged: (v) {
                      ref.read(demoDataProvider.notifier).set(v);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(v
                            ? 'Example data on. Reload to see it.'
                            : 'Example data off. Reload for a clean account.'),
                      ));
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('ACCOUNT & LEGAL', style: TextStyle(color: context.colors.inkSoft, fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: 1.0)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: context.colors.bgSoft,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: context.colors.border),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.lock_reset_rounded, color: context.colors.ink),
                  title: Text('Change Transfer PIN', style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w700)),
                  trailing: Icon(Icons.chevron_right_rounded, color: context.colors.inkSoft),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN reset link sent to your registered email!')));
                  },
                ),
                Divider(height: 1, color: context.colors.border),
                ListTile(
                  leading: Icon(Icons.description_outlined, color: context.colors.ink),
                  title: Text('Terms & Privacy Policy', style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w700)),
                  trailing: Icon(Icons.chevron_right_rounded, color: context.colors.inkSoft),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening Legal documentation...')));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showNotificationSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.bgSoft,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Notification Settings', style: TextStyle(color: context.colors.ink, fontSize: 18, fontWeight: FontWeight.w900)),
                    IconButton(icon: Icon(Icons.close_rounded, color: context.colors.inkSoft), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: Text('Push Notifications', style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w700)),
                  subtitle: Text('Receive immediate transaction alerts', style: TextStyle(color: context.colors.inkSoft, fontSize: 12)),
                  value: true,
                  activeThumbColor: context.colors.bluePrimary,
                  onChanged: (v) {},
                ),
                SwitchListTile(
                  title: Text('SMS OTP & Receipts', style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w700)),
                  subtitle: Text('Get SMS for transfers above ₦50,000', style: TextStyle(color: context.colors.inkSoft, fontSize: 12)),
                  value: true,
                  activeThumbColor: context.colors.bluePrimary,
                  onChanged: (v) {},
                ),
                SwitchListTile(
                  title: Text('Rate Alert Notifications', style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w700)),
                  subtitle: Text('Notify me when USD/NGN changes significantly', style: TextStyle(color: context.colors.inkSoft, fontSize: 12)),
                  value: false,
                  activeThumbColor: context.colors.bluePrimary,
                  onChanged: (v) {},
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSecuritySettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.bgSoft,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Security & Biometrics', style: TextStyle(color: context.colors.ink, fontSize: 18, fontWeight: FontWeight.w900)),
                IconButton(icon: Icon(Icons.close_rounded, color: context.colors.inkSoft), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text('Face ID / Fingerprint Login', style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w700)),
              subtitle: Text('Quickly unlock without entering password', style: TextStyle(color: context.colors.inkSoft, fontSize: 12)),
              value: true,
              activeThumbColor: context.colors.bluePrimary,
              onChanged: (v) {},
            ),
            SwitchListTile(
              title: Text('Two-Factor Authentication (2FA)', style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w700)),
              subtitle: Text('Require authenticator app code on login', style: TextStyle(color: context.colors.inkSoft, fontSize: 12)),
              value: true,
              activeThumbColor: context.colors.bluePrimary,
              onChanged: (v) {},
            ),
            ListTile(
              title: Text('Active Logged-in Devices', style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w700)),
              subtitle: Text('MacBook Pro (Active now) • iPhone 15 Pro', style: TextStyle(color: context.colors.inkSoft, fontSize: 12)),
              trailing: const Text('2 Devices', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// --- Support Screen ---
class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.scaffoldBg,
      appBar: AppBar(
        title: Text('Customer Support', style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: const Color(0xFF1D4ED8).withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 8)),
              ],
            ),
            child: const Column(
              children: [
                Icon(Icons.headset_mic_rounded, color: Colors.white, size: 48),
                SizedBox(height: 14),
                Text('How can we help you?', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                SizedBox(height: 6),
                Text('Our 24/7 dedicated fintech support is ready', style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildContactTile(
            context,
            Icons.chat_bubble_rounded,
            'Live Chat Support',
            'Typically replies in under 2 minutes',
            () => _showLiveChatDialog(context),
          ),
          const SizedBox(height: 12),
          _buildContactTile(
            context,
            Icons.email_rounded,
            'Email Us',
            'Live chat & ticket support',
            () => _showEmailTicketDialog(context),
          ),
          const SizedBox(height: 12),
          _buildContactTile(
            context,
            Icons.help_center_rounded,
            'Frequently Asked Questions',
            'Instant answers to common questions',
            () => _showFaqDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.bgSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.colors.border),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: context.colors.bluePrimary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: context.colors.bluePrimary, size: 22),
        ),
        title: Text(title, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w800, fontSize: 15)),
        subtitle: Text(subtitle, style: TextStyle(color: context.colors.inkSoft, fontSize: 12)),
        trailing: Icon(Icons.chevron_right_rounded, color: context.colors.inkSoft),
      ),
    );
  }

  void _showLiveChatDialog(BuildContext context) {
    final msgController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.bgSoft,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
        child: SizedBox(
          height: 480,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Color(0xFF10B981),
                        radius: 6,
                      ),
                      const SizedBox(width: 8),
                      Text('gabis Support Bot', style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w900, fontSize: 16)),
                    ],
                  ),
                  IconButton(icon: Icon(Icons.close_rounded, color: context.colors.inkSoft), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView(
                  children: [
                    _chatBubble(context, 'Hi Raphael! How can I assist you with your gabis account today?', false),
                    _chatBubble(context, 'You can ask about transfer speeds, FX rates, or card limits.', false),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: msgController,
                      style: TextStyle(color: context.colors.ink),
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        hintStyle: TextStyle(color: context.colors.inkSoft),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.send_rounded, color: context.colors.bluePrimary),
                    onPressed: () {
                      if (msgController.text.isNotEmpty) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Message sent! An agent will reply momentarily.')),
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chatBubble(BuildContext context, String text, bool isMe) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? context.colors.bluePrimary : context.colors.scaffoldBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          text,
          style: TextStyle(color: isMe ? Colors.white : context.colors.ink, fontSize: 13),
        ),
      ),
    );
  }

  void _showEmailTicketDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.bgSoft,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Contact Support by Email', style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w900)),
        content: Text('Submit a ticket from this app or start a live chat and our team will respond.',
            style: TextStyle(color: context.colors.inkSoft)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Support ticket #NTK-8921 opened!')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: context.colors.bluePrimary),
            child: const Text('Create Ticket', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showFaqDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.bgSoft,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Frequently Asked Questions', style: TextStyle(color: context.colors.ink, fontSize: 18, fontWeight: FontWeight.w900)),
                IconButton(icon: Icon(Icons.close_rounded, color: context.colors.inkSoft), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 16),
            _faqTile(context, 'How fast are USD to NGN conversions?', 'Conversions happen instantly at real-time market rates 24/7 with zero spread fees for Premium users.'),
            _faqTile(context, 'Where can I use my Virtual Visa card?', 'Your virtual card is accepted anywhere Visa is supported internationally, including Apple Pay, Google Pay, and online stores.'),
            _faqTile(context, 'What are the daily transfer limits?', 'Standard accounts can transfer up to ₦5,000,000 / \$5,000 daily. Premium accounts have no limits.'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _faqTile(BuildContext context, String q, String a) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(q, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w800, fontSize: 14)),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(a, style: TextStyle(color: context.colors.inkSoft, fontSize: 13, height: 1.4)),
        ),
      ],
    );
  }
}
