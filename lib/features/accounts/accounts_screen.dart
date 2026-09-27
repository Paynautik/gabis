import 'package:flutter/material.dart';
import '../../shared/wallets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/models/account.dart';
import '../../shared/models/money.dart';
import '../../shared/models/transaction.dart';
import '../../shared/providers/app_providers.dart';
import '../partners/partner_rails.dart';

class AccountsScreen extends ConsumerStatefulWidget {
  const AccountsScreen({super.key});

  @override
  ConsumerState<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsScreen> {
  String? _selected;
  String _searchQuery = '';

  /// Naira value of a balance, for the total. NGN and USD use the app's rate;
  /// the rest go through the reference rates until a live FX feed is wired.
  double _toNaira(Money m, double fxRate) {
    final major = m.minorUnits / 100;
    if (m.currency == 'NGN') return major;
    if (m.currency == 'USD') return major * fxRate;
    final perUsd = sandboxReferenceRates['USD/${m.currency}'];
    return perUsd == null ? 0 : major / perUsd * fxRate;
  }

  String _naira(double v) {
    final s = v.round().toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return '₦$b';
  }

  @override
  Widget build(BuildContext context) {
    final accounts = ref.watch(accountsProvider);
    final allTransactions = ref.watch(transactionsProvider);
    final fxRate = ref.watch(fxRateProvider);
    final current = accounts.firstWhere((a) => a.currency == _selected, orElse: () => accounts.first);
    final total = accounts.fold(0.0, (t, a) => t + _toNaira(a.balance, fxRate));

    final filteredTransactions = allTransactions.where((tx) {
      final q = _searchQuery.toLowerCase();
      final matchesSearch = q.isEmpty ||
          tx.counterparty?.toLowerCase().contains(q) == true ||
          tx.description?.toLowerCase().contains(q) == true;
      return matchesSearch && tx.amount.currency == current.currency;
    }).toList();

    return Scaffold(
      backgroundColor: context.colors.scaffoldBg,
      appBar: AppBar(
        title: Text('Accounts & Wallets', style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w900)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 30),
            children: [
              // Total across every wallet.
              Text('Total balance', style: TextStyle(color: context.colors.inkSoft, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(_naira(total),
                  style: TextStyle(color: context.colors.ink, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1)),
              Text('across ${accounts.length} wallet${accounts.length == 1 ? '' : 's'}',
                  style: TextStyle(color: context.colors.inkSoft, fontSize: 12)),
              const SizedBox(height: 18),

              // Wallet tiles.
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: IntrinsicHeight(
                  child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    for (final acc in accounts) _walletTile(context, acc, acc.currency == current.currency),
                    _openTile(context, accounts.length),
                  ]),
                ),
              ),
              const SizedBox(height: 16),

              _buildDetailedAccountCard(context, current, fxRate),
              const SizedBox(height: 26),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${current.currency} ACTIVITY',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: context.colors.inkSoft, letterSpacing: 1.0)),
                  Text('${filteredTransactions.length} item${filteredTransactions.length == 1 ? '' : 's'}',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: context.colors.inkSoft)),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                style: TextStyle(color: context.colors.ink, fontSize: 13),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search_rounded, color: context.colors.inkSoft, size: 20),
                  hintText: 'Search ${current.currency} activity',
                  hintStyle: TextStyle(color: context.colors.inkSoft, fontSize: 13),
                  filled: true,
                  fillColor: context.colors.bgSoft,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: context.colors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: context.colors.border)),
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
              const SizedBox(height: 14),
              if (filteredTransactions.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  child: Column(children: [
                    Icon(Icons.receipt_long_outlined, size: 32, color: context.colors.inkSoft.withValues(alpha: 0.5)),
                    const SizedBox(height: 8),
                    Text(_searchQuery.isEmpty ? 'No ${current.currency} activity yet' : 'Nothing matches “$_searchQuery”',
                        style: TextStyle(color: context.colors.inkSoft, fontWeight: FontWeight.w600)),
                  ]),
                )
              else
                for (final tx in filteredTransactions) _buildTransactionRow(context, tx),
            ],
          ),
        ),
      ),
    );
  }

  Widget _walletTile(BuildContext context, Account acc, bool selected) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _selected = acc.currency),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 150,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? context.colors.ink : context.colors.bgSoft,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? context.colors.ink : context.colors.border),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(_getFlag(acc.currency), style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(acc.currency,
                  style: TextStyle(fontWeight: FontWeight.w800, color: selected ? Colors.white : context.colors.ink)),
            ]),
            const SizedBox(height: 14),
            Text(acc.balance.format(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 15, color: selected ? Colors.white : context.colors.ink)),
          ]),
        ),
      ),
    );
  }

  Widget _openTile(BuildContext context, int held) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _showOpenAccountDialog(context),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.colors.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.add_rounded, color: context.colors.bluePrimary),
          const SizedBox(height: 10),
          Text('Open a wallet', style: TextStyle(fontWeight: FontWeight.w800, color: context.colors.ink)),
          Text('$held of ${walletCurrencies.length} held', style: TextStyle(fontSize: 11, color: context.colors.inkSoft)),
        ]),
      ),
    );
  }

  Widget _buildDetailedAccountCard(BuildContext context, Account account, double fxRate) {
    final w = walletFor(account.currency);
    final accountNumber = switch (account.currency) { 'NGN' => '9928371102', 'USD' => '0294817492', _ => null };
    final bankName = switch (account.currency) {
      'NGN' => 'gabis Partner Bank (Providus)',
      'USD' => 'Evolve Bank & Trust / gabis US',
      _ => w?.details ?? 'Partner bank',
    };
    final approx = account.currency == 'NGN'
        ? '≈ \$${(account.balance.minorUnits / 100 / fxRate).toStringAsFixed(2)}'
        : '≈ ${_naira(_toNaira(account.balance, fxRate))}';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.bgSoft,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(w?.flag ?? '🌐', style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(w?.name ?? account.currency,
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: context.colors.ink)),
              Text(bankName, style: TextStyle(color: context.colors.inkSoft, fontSize: 12)),
            ]),
          ),
        ]),
        const SizedBox(height: 18),
        Text(account.balance.format(),
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 30, color: context.colors.ink, letterSpacing: -1)),
        Text(approx, style: TextStyle(color: context.colors.inkSoft, fontSize: 12)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(color: context.colors.scaffoldBg, borderRadius: BorderRadius.circular(14)),
          child: Row(children: [
            Icon(Icons.account_balance_outlined, size: 16, color: context.colors.inkSoft),
            const SizedBox(width: 10),
            Expanded(
              child: Text(accountNumber == null ? 'Account details issued once the ${account.currency} partner is live' : 'Account $accountNumber',
                  style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w600, fontSize: 13)),
            ),
            if (accountNumber != null)
              TextButton.icon(
                style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: accountNumber));
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('${account.currency} account number copied')));
                },
                icon: const Icon(Icons.copy_rounded, size: 14),
                label: const Text('Copy'),
              ),
          ]),
        ),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(child: _buildActionButton(icon: Icons.add_rounded, label: 'Top up', color: context.colors.bluePrimary, onTap: () => _showTopUpSheet(context, account))),
          Expanded(child: _buildActionButton(icon: Icons.north_east_rounded, label: 'Send', color: const Color(0xFF4B45F5), onTap: () => Navigator.of(context).pushNamed('/send'))),
          Expanded(child: _buildActionButton(icon: Icons.swap_horiz_rounded, label: 'Convert', color: const Color(0xFFE0643C), onTap: () => Navigator.of(context).pushNamed('/fx'))),
          Expanded(child: _buildActionButton(icon: Icons.receipt_long_outlined, label: 'Statement', color: const Color(0xFF7C3AED), onTap: () => _showAccountStatement(context, account))),
        ]),
      ]),
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
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: context.colors.scaffoldBg, shape: BoxShape.circle, border: Border.all(color: context.colors.border)),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 6),
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: context.colors.ink, fontSize: 12, fontWeight: FontWeight.w600)),
        ]),
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
