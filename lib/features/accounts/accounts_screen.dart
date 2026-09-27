import 'package:flutter/material.dart';
import '../../shared/wallets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/models/account.dart';
import '../../shared/models/money.dart';
import '../../shared/models/transaction.dart';
import '../../shared/providers/app_providers.dart';
import '../../shared/widgets/glowing_background.dart';

class AccountsScreen extends ConsumerStatefulWidget {
  const AccountsScreen({super.key});

  @override
  ConsumerState<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsScreen> {
  String _selectedCurrency = 'ALL';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountsProvider);
    final allTransactions = ref.watch(transactionsProvider);
    final fxRate = ref.watch(fxRateProvider);

    final filteredTransactions = allTransactions.where((tx) {
      final matchesSearch = tx.counterparty?.toLowerCase().contains(_searchQuery.toLowerCase()) == true ||
          tx.description?.toLowerCase().contains(_searchQuery.toLowerCase()) == true;
      if (_selectedCurrency == 'ALL') return matchesSearch;
      return matchesSearch && tx.amount.currency == _selectedCurrency;
    }).toList();

    return Scaffold(
      backgroundColor: context.colors.scaffoldBg,
      appBar: AppBar(
        title: Text('Accounts & Wallets', style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline_rounded, color: context.colors.bluePrimary),
            tooltip: 'Open New Currency Account',
            onPressed: () => _showOpenAccountDialog(context),
          ),
        ],
      ),
      body: GlowingBackground(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            // Currency selector tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCurrencyFilterChip('ALL', 'All Accounts'),
                  for (final acc in accounts)
                    _buildCurrencyFilterChip(acc.currency, '${_getFlag(acc.currency)} ${acc.currency}'),
                  GestureDetector(
                    onTap: () => _showOpenAccountDialog(context),
                    child: Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: context.colors.border, style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.add, size: 14, color: context.colors.bluePrimary),
                          const SizedBox(width: 4),
                          Text('New', style: TextStyle(color: context.colors.bluePrimary, fontSize: 12, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Account Cards
            for (final acc in accounts)
              if (_selectedCurrency == 'ALL' || _selectedCurrency == acc.currency)
                _buildDetailedAccountCard(context, acc, fxRate),

            const SizedBox(height: 24),

            // Transactions Header & Search
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ACTIVITY',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: context.colors.inkSoft, letterSpacing: 1.0),
                ),
                Text(
                  '${filteredTransactions.length} items',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: context.colors.inkSoft),
                ),
              ],
            ),
            const SizedBox(height: 10),

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
                        hintText: 'Search account activity...',
                        hintStyle: TextStyle(color: context.colors.inkSoft, fontSize: 13),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    GestureDetector(
                      onTap: () => setState(() => _searchQuery = ''),
                      child: Icon(Icons.close_rounded, size: 16, color: context.colors.inkSoft),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Transactions List
            if (filteredTransactions.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 40, color: context.colors.inkSoft.withValues(alpha: 0.5)),
                    const SizedBox(height: 10),
                    Text('No transactions found', style: TextStyle(color: context.colors.inkSoft, fontWeight: FontWeight.w700)),
                  ],
                ),
              )
            else
              for (final tx in filteredTransactions)
                _buildTransactionRow(context, tx),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyFilterChip(String key, String label) {
    final isSelected = _selectedCurrency == key;
    return GestureDetector(
      onTap: () => setState(() => _selectedCurrency = key),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? context.colors.bluePrimary : context.colors.bgSoft,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? context.colors.bluePrimary : context.colors.border),
          boxShadow: isSelected
              ? [BoxShadow(color: context.colors.bluePrimary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : context.colors.ink,
            fontWeight: FontWeight.w800,
            fontSize: 12.5,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailedAccountCard(BuildContext context, Account account, double fxRate) {
    final isNgn = account.currency == 'NGN';
    final flag = _getFlag(account.currency);
    final accountName = isNgn ? 'gabis Nigerian Naira Account' : 'gabis Global USD Multi-Currency Account';
    final accountNumber = isNgn ? '9928371102' : '0294817492';
    final bankName = switch (account.currency) {
      'NGN' => 'gabis Partner Bank (Providus)',
      'USD' => 'Evolve Bank & Trust / gabis US',
      _ => 'gabis · ${walletFor(account.currency)?.details ?? 'Partner bank'}',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.colors.bgSoft,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.colors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Flag + Currency + Details
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Text(flag, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(account.currency, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: context.colors.ink)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: context.colors.bluePrimary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('Active', style: TextStyle(color: context.colors.bluePrimary, fontSize: 10, fontWeight: FontWeight.w800)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(bankName, style: TextStyle(color: context.colors.inkSoft, fontSize: 11, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      account.balance.format(),
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: context.colors.ink, letterSpacing: -0.5),
                    ),
                    if (isNgn)
                      Text('≈ \$${(account.balance.minorUnits / 100 / fxRate).toStringAsFixed(2)} USD',
                          style: TextStyle(color: context.colors.inkSoft, fontSize: 11, fontWeight: FontWeight.w600))
                    else
                      Text('≈ ₦${(account.balance.minorUnits / 100 * fxRate).toStringAsFixed(0)} NGN',
                          style: TextStyle(color: context.colors.inkSoft, fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),

          // Account Details Bar (Virtual account number & copy)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: context.colors.scaffoldBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.account_balance_rounded, size: 16, color: context.colors.inkSoft),
                    const SizedBox(width: 8),
                    Text('Acct: $accountNumber', style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w700, fontSize: 12)),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: accountNumber));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$account.currency Account Number copied to clipboard!')),
                    );
                  },
                  child: Row(
                    children: [
                      Text('Copy', style: TextStyle(color: context.colors.bluePrimary, fontSize: 12, fontWeight: FontWeight.w800)),
                      const SizedBox(width: 4),
                      Icon(Icons.copy_rounded, color: context.colors.bluePrimary, size: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Action Buttons Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.add_rounded,
                    label: 'Top Up',
                    color: context.colors.bluePrimary,
                    onTap: () => _showTopUpSheet(context, account),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.send_rounded,
                    label: 'Transfer',
                    color: const Color(0xFF16A34A),
                    onTap: () => Navigator.of(context).pushNamed('/send'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.swap_horiz_rounded,
                    label: 'Convert',
                    color: const Color(0xFFF79009),
                    onTap: () => Navigator.of(context).pushNamed('/fx'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.receipt_long_rounded,
                    label: 'Statement',
                    color: const Color(0xFF7C3AED),
                    onTap: () => _showAccountStatement(context, account),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionRow(BuildContext context, AppTransaction tx) {
    final isCredit = tx.isCredit;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: context.colors.bgSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: isCredit ? const Color(0x1A16A34A) : const Color(0x1AEF4444),
          child: Icon(
            isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
            color: isCredit ? const Color(0xFF16A34A) : const Color(0xFFEF4444),
            size: 18,
          ),
        ),
        title: Text(tx.counterparty ?? 'Transfer', style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w800, fontSize: 14)),
        subtitle: Text(tx.description ?? '', style: TextStyle(color: context.colors.inkSoft, fontSize: 11)),
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
        onTap: () => _showTransactionReceipt(context, tx),
      ),
    );
  }

  void _showTopUpSheet(BuildContext context, Account account) {
    final amountController = TextEditingController();
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
                Text('Fund ${account.currency} Account', style: TextStyle(color: context.colors.ink, fontSize: 18, fontWeight: FontWeight.w900)),
                IconButton(icon: Icon(Icons.close_rounded, color: context.colors.inkSoft), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 16),
            Text('Enter amount to simulate instant funding:', style: TextStyle(color: context.colors.inkSoft, fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w800, fontSize: 18),
              decoration: InputDecoration(
                prefixText: '${account.balance.symbol.trim()} ',
                labelText: 'Amount',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final doubleVal = double.tryParse(amountController.text) ?? 0.0;
                if (doubleVal > 0) {
                  final minor = (doubleVal * 100).round();
                  ref.read(accountsProvider.notifier).addBalance(account.currency, minor);
                  ref.read(transactionsProvider.notifier).addTransaction(
                    AppTransaction(
                      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
                      type: TransactionType.transfer,
                      status: TransactionStatus.completed,
                      amount: Money(minorUnits: minor, currency: account.currency),
                      description: 'Top-up deposit',
                      counterparty: 'Direct Bank Deposit',
                      createdAt: DateTime.now(),
                      isCredit: true,
                    ),
                  );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Successfully deposited ${account.currency} ${doubleVal.toStringAsFixed(2)}!')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.colors.bluePrimary,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Add Funds Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showTransactionReceipt(BuildContext context, AppTransaction tx) {
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
              width: 48,
              height: 48,
              decoration: const BoxDecoration(color: Color(0x1A16A34A), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 28),
            ),
            const SizedBox(height: 12),
            Text('Transaction Details', style: TextStyle(color: context.colors.ink, fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(tx.amount.format(), style: TextStyle(color: context.colors.ink, fontSize: 26, fontWeight: FontWeight.w900)),
            const Divider(height: 32),
            _receiptRow(context, 'Recipient / Source', tx.counterparty ?? 'N/A'),
            const SizedBox(height: 10),
            _receiptRow(context, 'Description', tx.description ?? 'Transfer'),
            const SizedBox(height: 10),
            _receiptRow(context, 'Status', 'Completed'),
            const SizedBox(height: 10),
            _receiptRow(context, 'Transaction ID', tx.id),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Receipt downloaded as PDF!')));
              },
              icon: const Icon(Icons.download_rounded, color: Colors.white),
              label: const Text('Download Receipt', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
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

  Widget _receiptRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: context.colors.inkSoft, fontSize: 13)),
        Text(value, style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w800, fontSize: 13)),
      ],
    );
  }

  void _showAccountStatement(BuildContext context, Account account) {
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
                Text('${account.currency} Statements', style: TextStyle(color: context.colors.ink, fontSize: 18, fontWeight: FontWeight.w900)),
                IconButton(icon: Icon(Icons.close_rounded, color: context.colors.inkSoft), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.picture_as_pdf_rounded, color: context.colors.bluePrimary),
              title: Text('August 2026 e-Statement', style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w800)),
              subtitle: Text('Full monthly transaction summary', style: TextStyle(color: context.colors.inkSoft, fontSize: 11)),
              trailing: Icon(Icons.download_rounded, color: context.colors.bluePrimary),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Downloading August statement for ${account.currency}...')));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showOpenAccountDialog(BuildContext context) {
    final held = ref.read(accountsProvider).map((a) => a.currency).toSet();
    final available = walletCurrencies.where((w) => !held.contains(w.code)).toList();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.bgSoft,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * .8),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(24),
          children: [
            Text('Open a currency wallet', style: TextStyle(color: context.colors.ink, fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(
                available.isEmpty
                    ? 'You already hold all ${walletCurrencies.length} currencies.'
                    : 'Hold up to ${walletCurrencies.length} currencies: 7 African and 5 global.',
                style: TextStyle(color: context.colors.inkSoft, fontSize: 13)),
            for (final group in [true, false])
              if (available.any((w) => w.african == group)) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 18, bottom: 4),
                  child: Text(group ? 'AFRICAN CURRENCIES' : 'GLOBAL CURRENCIES',
                      style: TextStyle(color: context.colors.inkSoft, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)),
                ),
                for (final w in available.where((w) => w.african == group))
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Text(w.flag, style: const TextStyle(fontSize: 24)),
                    title: Text('${w.name} (${w.code})', style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w800)),
                    subtitle: Text(w.details, style: TextStyle(color: context.colors.inkSoft, fontSize: 11)),
                    trailing: Icon(Icons.add_circle_outline, color: context.colors.bluePrimary),
                    onTap: () {
                      ref.read(accountsProvider.notifier).addAccount(
                            Account(
                              id: 'acc_${w.code.toLowerCase()}',
                              currency: w.code,
                              balance: Money(minorUnits: 0, currency: w.code),
                              type: AccountType.personal,
                            ),
                          );
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${w.code} wallet opened')));
                    },
                  ),
              ],
          ],
        ),
      ),
    );
  }

  String _getFlag(String currency) => walletFor(currency)?.flag ?? '🌐';
}
