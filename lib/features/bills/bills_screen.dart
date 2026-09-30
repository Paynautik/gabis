import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final t = item.title;
    if (t == 'Buy airtime' || t == 'Buy data') {
      final data = t == 'Buy data';
      _openForm(
        context,
        _BillForm(
          title: data ? 'Buy internet data' : 'Buy mobile airtime',
          providerLabel: 'Network',
          providers: const ['MTN', 'Airtel', 'Glo', '9mobile'],
          accountLabel: 'Phone number',
          accountHint: '08012345678',
          accountIcon: Icons.phone_iphone_rounded,
          keyboard: TextInputType.phone,
          validateAccount: _validatePhone,
          minNaira: data ? 100 : 50,
          maxNaira: 50000,
          quick: data ? const [500, 1000, 2000, 5000] : const [100, 200, 500, 1000],
          describe: (p, a) => '$p ${data ? 'data' : 'airtime'} ($a)',
        ),
      );
    } else if (t == 'Electricity & Water' || t == 'Utilities') {
      _openForm(
        context,
        _BillForm(
          title: 'Pay electricity bill',
          providerLabel: 'Distribution company',
          providers: const ['Ikeja Electric', 'Eko Electric', 'Abuja Electric', 'Ibadan Electric'],
          accountLabel: 'Meter number',
          accountHint: '11 or 13 digits',
          accountIcon: Icons.electric_bolt_rounded,
          keyboard: TextInputType.number,
          validateAccount: _validateMeter,
          minNaira: 500,
          maxNaira: 500000,
          quick: const [1000, 2000, 5000, 10000],
          describe: (p, a) => '$p prepaid electricity ($a)',
          isPower: true,
        ),
      );
    } else if (t == 'Cable TV') {
      _openForm(
        context,
        _BillForm(
          title: 'Cable TV subscription',
          providerLabel: 'Provider',
          providers: const ['DSTV', 'GOtv', 'StarTimes', 'Showmax'],
          accountLabel: 'Smartcard / IUC number',
          accountHint: '10 or 11 digits',
          accountIcon: Icons.credit_card_rounded,
          keyboard: TextInputType.number,
          validateAccount: _validateSmartcard,
          minNaira: 500,
          maxNaira: 200000,
          quick: const [2000, 4500, 8500, 14500],
          describe: (p, a) => '$p subscription ($a)',
        ),
      );
    } else {
      _openForm(
        context,
        _BillForm(
          title: item.title,
          accountLabel: 'Account / reference / ID number',
          accountHint: 'As shown on your invoice',
          accountIcon: Icons.tag_rounded,
          keyboard: TextInputType.text,
          validateAccount: _validateReference,
          minNaira: 100,
          maxNaira: 5000000,
          quick: const [1000, 5000, 10000, 50000],
          describe: (p, a) => '${item.title} ($a)',
        ),
      );
    }
  }

  // --- Validation -----------------------------------------------------------

  static String? _validatePhone(String v) {
    final d = v.replaceAll(RegExp(r'[\s-]'), '');
    if (d.isEmpty) return 'Enter the phone number.';
    if (!RegExp(r'^0[789][01]\d{8}$').hasMatch(d)) {
      return 'Use an 11-digit Nigerian number, like 08012345678.';
    }
    return null;
  }

  static String? _validateMeter(String v) {
    final d = v.trim();
    if (d.isEmpty) return 'Enter the meter number.';
    if (!RegExp(r'^\d{11}$|^\d{13}$').hasMatch(d)) return 'A meter number has 11 or 13 digits.';
    return null;
  }

  static String? _validateSmartcard(String v) {
    final d = v.trim();
    if (d.isEmpty) return 'Enter the smartcard number.';
    if (!RegExp(r'^\d{10,11}$').hasMatch(d)) return 'A smartcard number has 10 or 11 digits.';
    return null;
  }

  static String? _validateReference(String v) {
    if (v.trim().length < 4) return 'Enter the account or reference number.';
    return null;
  }

  // --- The flow: details, review, pay, receipt ------------------------------

  int _nairaBalanceMinor() {
    for (final a in ref.read(accountsProvider)) {
      if (a.currency == 'NGN') return a.balance.minorUnits;
    }
    return 0;
  }

  void _openForm(BuildContext context, _BillForm form) {
    String? provider = form.providers?.first;
    final account = TextEditingController();
    final amount = TextEditingController();
    String? accountError;
    String? amountError;
    String? payError;
    var reviewing = false;

    showModalBottomSheet<void>(
      context: this.context,
      isScrollControlled: true,
      backgroundColor: this.context.colors.bgSoft,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          final balance = _nairaBalanceMinor();

          int? parsedAmount() => int.tryParse(amount.text.replaceAll(RegExp(r'[,\s₦]'), ''));

          void review() {
            final accErr = form.validateAccount(account.text);
            final amt = parsedAmount();
            String? amtErr;
            if (amt == null) {
              amtErr = 'Enter an amount.';
            } else if (amt < form.minNaira) {
              amtErr = 'The smallest amount is ₦${_group(form.minNaira)}.';
            } else if (amt > form.maxNaira) {
              amtErr = 'The most you can pay here is ₦${_group(form.maxNaira)}.';
            }
            setSheet(() {
              accountError = accErr;
              amountError = amtErr;
              payError = null;
              reviewing = accErr == null && amtErr == null;
            });
          }

          Future<void> pay() async {
            final naira = parsedAmount()!;
            final minor = naira * 100;
            if (_nairaBalanceMinor() < minor) {
              setSheet(() => payError = 'Your naira wallet has ${Money(minorUnits: balance, currency: 'NGN').format()}, '
                  'which is not enough. Add money first.');
              return;
            }
            final reference = _newReference();
            final now = DateTime.now();
            final acct = account.text.trim();
            final desc = form.describe(provider ?? '', acct);

            ref.read(accountsProvider.notifier).subtractBalance('NGN', minor);
            ref.read(transactionsProvider.notifier).addTransaction(
                  AppTransaction(
                    id: reference,
                    type: TransactionType.billPayment,
                    status: TransactionStatus.completed,
                    amount: Money(minorUnits: minor, currency: 'NGN'),
                    description: desc,
                    counterparty: provider ?? form.title,
                    createdAt: now,
                    isCredit: false,
                  ),
                );
            Navigator.pop(ctx);
            if (!mounted) return;
            _showReceipt(
              form: form,
              provider: provider,
              account: acct,
              naira: naira,
              reference: reference,
              when: now,
            );
          }

          InputDecoration deco(String label, {String? hint, IconData? icon, String? prefix, String? error}) => InputDecoration(
                labelText: label,
                hintText: hint,
                errorText: error,
                labelStyle: TextStyle(color: ctx.colors.inkSoft),
                prefixIcon: icon == null ? null : Icon(icon, color: ctx.colors.inkSoft, size: 20),
                prefixText: prefix,
                prefixStyle: TextStyle(color: ctx.colors.ink, fontWeight: FontWeight.w900),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: ctx.colors.border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: ctx.colors.bluePrimary, width: 2)),
              );

          final Widget body;
          if (reviewing) {
            final naira = parsedAmount() ?? 0;
            body = Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Review payment', style: TextStyle(color: ctx.colors.ink, fontSize: 18, fontWeight: FontWeight.w900)),
                const SizedBox(height: 14),
                _reviewRow('Paying', provider ?? form.title),
                _reviewRow(form.accountLabel, account.text.trim()),
                _reviewRow('Amount', '₦${_group(naira)}'),
                _reviewRow('Fee', '₦0'),
                Divider(color: ctx.colors.border),
                _reviewRow('Total', '₦${_group(naira)}', strong: true),
                _reviewRow('From', 'Naira wallet · ${Money(minorUnits: balance, currency: 'NGN').format()}'),
                if (payError != null) ...[
                  const SizedBox(height: 10),
                  Text(payError!, style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13, fontWeight: FontWeight.w600)),
                ],
                const SizedBox(height: 18),
                Row(children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setSheet(() {
                        reviewing = false;
                        payError = null;
                      }),
                      style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: pay,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ctx.colors.bluePrimary,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text('Pay ₦${_group(naira)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
                    ),
                  ),
                ]),
              ],
            );
          } else {
            body = Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(form.title, style: TextStyle(color: ctx.colors.ink, fontSize: 18, fontWeight: FontWeight.w900))),
                    IconButton(icon: Icon(Icons.close_rounded, color: ctx.colors.inkSoft), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                Text('Naira wallet: ${Money(minorUnits: balance, currency: 'NGN').format()}',
                    style: TextStyle(color: ctx.colors.inkSoft, fontSize: 12.5, fontWeight: FontWeight.w600)),
                const SizedBox(height: 14),
                if (form.providers != null) ...[
                  Text(form.providerLabel, style: TextStyle(color: ctx.colors.inkSoft, fontSize: 12, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final p in form.providers!)
                        ChoiceChip(
                          label: Text(p),
                          selected: provider == p,
                          onSelected: (_) => setSheet(() => provider = p),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                ],
                TextField(
                  controller: account,
                  keyboardType: form.keyboard,
                  style: TextStyle(color: ctx.colors.ink, fontWeight: FontWeight.w700),
                  decoration: deco(form.accountLabel, hint: form.accountHint, icon: form.accountIcon, error: accountError),
                  onChanged: (_) {
                    if (accountError != null) setSheet(() => accountError = null);
                  },
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: amount,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: ctx.colors.ink, fontWeight: FontWeight.w900, fontSize: 18),
                  decoration: deco('Amount', prefix: '₦ ', error: amountError),
                  onChanged: (_) {
                    if (amountError != null) setSheet(() => amountError = null);
                  },
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final q in form.quick)
                      ActionChip(
                        label: Text('₦${_group(q)}'),
                        onPressed: () => setSheet(() {
                          amount.text = '$q';
                          amountError = null;
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: review,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ctx.colors.bluePrimary,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Review payment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white)),
                ),
              ],
            );
          }

          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
            child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [body, const SizedBox(height: 24)])),
          );
        },
      ),
    );
  }

  Widget _reviewRow(String label, String value, {bool strong = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: context.colors.inkSoft, fontSize: 13.5, fontWeight: FontWeight.w600)),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(color: context.colors.ink, fontSize: strong ? 16 : 13.5, fontWeight: strong ? FontWeight.w900 : FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _showReceipt({
    required _BillForm form,
    required String? provider,
    required String account,
    required int naira,
    required String reference,
    required DateTime when,
  }) {
    final demo = ref.read(demoDataProvider);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.bgSoft,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(children: [
          const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 28),
          const SizedBox(width: 10),
          Expanded(child: Text('Payment successful', style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w900, fontSize: 18))),
        ]),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _reviewRow('Paid', provider ?? form.title),
              _reviewRow(form.accountLabel, account),
              _reviewRow('Amount', '₦${_group(naira)}', strong: true),
              _reviewRow('Reference', reference),
              _reviewRow('Date', _formatWhen(when)),
              if (demo) ...[
                const SizedBox(height: 10),
                Text(
                  'Demo mode: this payment only changed the example balance. No biller was charged.'
                  '${form.isPower ? ' A real purchase would show the meter token here.' : ''}',
                  style: TextStyle(color: context.colors.inkSoft, fontSize: 12, height: 1.4),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: reference));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reference copied')));
            },
            child: const Text('Copy reference'),
          ),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Done')),
        ],
      ),
    );
  }

  static String _newReference() {
    final t = DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase();
    return 'GB$t';
  }

  static String _group(int n) {
    final s = n.toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
      b.write(s[i]);
    }
    return b.toString();
  }

  static String _formatWhen(DateTime d) {
    const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final mm = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${m[d.month - 1]} ${d.year}, $h:$mm ${d.hour < 12 ? 'AM' : 'PM'}';
  }
}

/// What one kind of bill asks for: who it goes to, the account number that
/// identifies you, and the limits on the amount.
class _BillForm {
  final String title;
  final String providerLabel;
  final List<String>? providers;
  final String accountLabel;
  final String accountHint;
  final IconData accountIcon;
  final TextInputType keyboard;
  final String? Function(String) validateAccount;
  final int minNaira;
  final int maxNaira;
  final List<int> quick;
  final String Function(String provider, String account) describe;
  final bool isPower;

  const _BillForm({
    required this.title,
    this.providerLabel = '',
    this.providers,
    required this.accountLabel,
    required this.accountHint,
    required this.accountIcon,
    required this.keyboard,
    required this.validateAccount,
    required this.minNaira,
    required this.maxNaira,
    required this.quick,
    required this.describe,
    this.isPower = false,
  });
}
