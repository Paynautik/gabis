import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/providers/app_providers.dart';
import 'dart:async';

class BusinessDashboardScreen extends ConsumerStatefulWidget {
  const BusinessDashboardScreen({super.key});

  @override
  ConsumerState<BusinessDashboardScreen> createState() => _BusinessDashboardScreenState();
}

class _BusinessDashboardScreenState extends ConsumerState<BusinessDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 750;

    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF09090B),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
              child: const Icon(Icons.business_center_rounded, color: Colors.black, size: 16),
            ),
            const SizedBox(width: 12),
            const Text('Elumo Business', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16, letterSpacing: -0.5)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton.icon(
              onPressed: () => ref.read(isBusinessModeProvider.notifier).state = false,
              icon: const Icon(Icons.swap_horiz_rounded, color: Color(0xFFA1A1AA), size: 16),
              label: const Text('Personal Account', style: TextStyle(color: Color(0xFFA1A1AA), fontWeight: FontWeight.w500, fontSize: 13)),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFF27272A), width: 1))),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 2,
              labelColor: Colors.white,
              unselectedLabelColor: const Color(0xFFA1A1AA),
              labelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
              isScrollable: !isDesktop,
              tabs: const [
                Tab(text: 'Smart Invoices'),
                Tab(text: 'Installment Ledgers'),
                Tab(text: 'AI Debt Collection'),
                Tab(text: 'Multi-Currency Tax'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _SmartInvoicesTab(),
          _InstallmentLedgersTab(),
          _AIDebtCollectionTab(),
          _MultiCurrencyTaxTab(),
        ],
      ),
    );
  }
}

// ============================================================================
// SHARED INPUT FIELD BUILDER
// ============================================================================
Widget _buildField(String label, String hint, TextEditingController ctrl, {bool isNumber = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: Color(0xFFE4E4E7), fontSize: 13, fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      TextField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF52525B)),
          filled: true,
          fillColor: const Color(0xFF09090B),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF27272A))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF27272A))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF3B82F6))),
        ),
      ),
    ],
  );
}

// ============================================================================
// 1. SMART INVOICE GENERATION
// ============================================================================
class _SmartInvoicesTab extends StatefulWidget {
  const _SmartInvoicesTab();
  @override
  State<_SmartInvoicesTab> createState() => _SmartInvoicesTabState();
}

class _SmartInvoicesTabState extends State<_SmartInvoicesTab> {
  final _clientCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _isGenerating = false;

  final List<Map<String, String>> _invoices = [
    {'client': 'Acme Corp', 'amount': '₦450,000', 'desc': 'Q3 Software License', 'status': 'Sent', 'date': 'Aug 28'},
    {'client': 'TechBridge Ltd', 'amount': '₦1,200,000', 'desc': 'Cloud Infrastructure Setup', 'status': 'Paid', 'date': 'Aug 25'},
  ];

  void _generate() async {
    final client = _clientCtrl.text.trim();
    final amount = _amountCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    if (client.isEmpty || amount.isEmpty) return;

    setState(() => _isGenerating = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() {
      _invoices.insert(0, {
        'client': client,
        'amount': '₦$amount',
        'desc': desc.isEmpty ? 'General Services' : desc,
        'status': 'Generated',
        'date': 'Just now',
      });
      _isGenerating = false;
      _clientCtrl.clear();
      _amountCtrl.clear();
      _descCtrl.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Invoice for $client created successfully.'),
      backgroundColor: const Color(0xFF10B981),
    ));
  }

  @override
  void dispose() {
    _clientCtrl.dispose();
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Smart Invoice Generation', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('Instantly generate and send professional invoices with automated follow-ups.', style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 13, height: 1.5)),
          const SizedBox(height: 32),

          // ── Form ──
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: const Color(0xFF18181B), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF27272A))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('New Invoice', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 20),
                _buildField('Client Name', 'e.g. Acme Corp', _clientCtrl),
                const SizedBox(height: 16),
                _buildField('Amount (NGN)', 'e.g. 500000', _amountCtrl, isNumber: true),
                const SizedBox(height: 16),
                _buildField('Description', 'e.g. Web Development', _descCtrl),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    onPressed: _isGenerating ? null : _generate,
                    child: _isGenerating
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Generate Invoice', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),

          // ── Recent list ──
          const SizedBox(height: 32),
          const Text('Recent Invoices', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          ..._invoices.map((inv) {
            final isPaid = inv['status'] == 'Paid';
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFF18181B), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF27272A))),
              child: Row(
                children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(inv['client']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(inv['desc']!, style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 12)),
                    ]),
                  ),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(inv['amount']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 4),
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                        width: 6, height: 6,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: isPaid ? const Color(0xFF10B981) : const Color(0xFF3B82F6)),
                      ),
                      const SizedBox(width: 6),
                      Text('${inv['status']} · ${inv['date']}', style: TextStyle(color: isPaid ? const Color(0xFF10B981) : const Color(0xFF3B82F6), fontSize: 12)),
                    ]),
                  ]),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ============================================================================
// 2. INSTALLMENT LEDGER TRACKING
// ============================================================================
class _InstallmentLedgersTab extends StatefulWidget {
  const _InstallmentLedgersTab();
  @override
  State<_InstallmentLedgersTab> createState() => _InstallmentLedgersTabState();
}

class _InstallmentLedgersTabState extends State<_InstallmentLedgersTab> {
  final _clientCtrl = TextEditingController();
  final _totalCtrl = TextEditingController();
  final _installmentsCtrl = TextEditingController();

  final List<Map<String, dynamic>> _ledgers = [
    {'client': 'TechCorp Office Setup', 'total': 1200000.0, 'paid': 400000.0, 'installments': 3, 'current': 1},
    {'client': 'Marketing Retainer — Q3', 'total': 600000.0, 'paid': 600000.0, 'installments': 4, 'current': 4},
    {'client': 'Sarah Designs Branding', 'total': 300000.0, 'paid': 100000.0, 'installments': 3, 'current': 1},
  ];

  String _formatCurrency(double val) {
    if (val >= 1000000) return '₦${(val / 1000000).toStringAsFixed(1)}M';
    if (val >= 1000) return '₦${(val / 1000).toStringAsFixed(0)}K';
    return '₦${val.toStringAsFixed(0)}';
  }

  void _addLedger() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF18181B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('New Installment Ledger', style: TextStyle(color: Colors.white)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          _buildField('Client / Project', 'e.g. Acme Corp', _clientCtrl),
          const SizedBox(height: 12),
          _buildField('Total Amount', 'e.g. 500000', _totalCtrl, isNumber: true),
          const SizedBox(height: 12),
          _buildField('Number of Installments', 'e.g. 3', _installmentsCtrl, isNumber: true),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: Color(0xFFA1A1AA)))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
            onPressed: () {
              final client = _clientCtrl.text.trim();
              final total = double.tryParse(_totalCtrl.text.trim()) ?? 0;
              final installments = int.tryParse(_installmentsCtrl.text.trim()) ?? 1;
              if (client.isEmpty || total <= 0) return;
              setState(() {
                _ledgers.insert(0, {'client': client, 'total': total, 'paid': 0.0, 'installments': installments, 'current': 0});
              });
              _clientCtrl.clear();
              _totalCtrl.clear();
              _installmentsCtrl.clear();
              Navigator.pop(ctx);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _recordPayment(int index) {
    final ledger = _ledgers[index];
    final perInstallment = (ledger['total'] as double) / (ledger['installments'] as int);
    setState(() {
      ledger['paid'] = ((ledger['paid'] as double) + perInstallment).clamp(0.0, ledger['total'] as double);
      ledger['current'] = ((ledger['current'] as int) + 1).clamp(0, ledger['installments'] as int);
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Payment of ${_formatCurrency(perInstallment)} recorded for ${ledger['client']}.'),
      backgroundColor: const Color(0xFF10B981),
    ));
  }

  @override
  void dispose() {
    _clientCtrl.dispose();
    _totalCtrl.dispose();
    _installmentsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Installment Ledger Tracking', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
                  SizedBox(height: 8),
                  Text('Track partial payments and automatically reconcile scheduled installments.', style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 13, height: 1.5)),
                ]),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                onPressed: _addLedger,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('New Ledger'),
              ),
            ],
          ),
          const SizedBox(height: 32),

          ..._ledgers.asMap().entries.map((entry) {
            final i = entry.key;
            final l = entry.value;
            final double progress = (l['paid'] as double) / (l['total'] as double);
            final bool completed = progress >= 1.0;
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: const Color(0xFF18181B), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF27272A))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(l['client'] as String, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: (completed ? const Color(0xFF10B981) : const Color(0xFFF59E0B)).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(completed ? 'Settled' : 'Active', style: TextStyle(color: completed ? const Color(0xFF10B981) : const Color(0xFFF59E0B), fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ]),
                const SizedBox(height: 20),
                Row(children: [
                  _stat('Total', _formatCurrency(l['total'] as double)),
                  const SizedBox(width: 32),
                  _stat('Paid', _formatCurrency(l['paid'] as double)),
                  const SizedBox(width: 32),
                  _stat('Installment', '${l['current']} of ${l['installments']}'),
                  const Spacer(),
                  if (!completed)
                    TextButton(
                      onPressed: () => _recordPayment(i),
                      child: const Text('Record Payment →', style: TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.w600)),
                    ),
                ]),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: const Color(0xFF27272A),
                    valueColor: AlwaysStoppedAnimation<Color>(completed ? const Color(0xFF10B981) : const Color(0xFF3B82F6)),
                  ),
                ),
              ]),
            );
          }),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 12)),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
    ]);
  }
}

// ============================================================================
// 3. AI DEBT COLLECTION CALLS
// ============================================================================
class _AIDebtCollectionTab extends StatefulWidget {
  const _AIDebtCollectionTab();
  @override
  State<_AIDebtCollectionTab> createState() => _AIDebtCollectionTabState();
}

class _AIDebtCollectionTabState extends State<_AIDebtCollectionTab> {
  bool _isCalling = false;
  String _callStatus = '';
  final List<String> _transcript = [];
  String _selectedTone = 'Polite & Helpful';

  final List<Map<String, String>> _debtors = [
    {'name': 'David O.', 'invoice': 'INV-492', 'amount': '₦150,000', 'days': '14 days'},
    {'name': 'Sarah K.', 'invoice': 'INV-501', 'amount': '₦85,000', 'days': '7 days'},
    {'name': 'Michael A.', 'invoice': 'INV-478', 'amount': '₦320,000', 'days': '30 days'},
  ];
  int _selectedDebtor = 0;

  void _startCall() async {
    final debtor = _debtors[_selectedDebtor];
    setState(() {
      _isCalling = true;
      _callStatus = 'Dialing ${debtor['name']}...';
      _transcript.clear();
    });

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _callStatus = 'Call Connected — AI Agent speaking');

    final lines = [
      "AI: Hello, am I speaking with ${debtor['name']}?",
      "${debtor['name']}: Yes, who is this?",
      "AI: Hi ${debtor['name']}, I'm calling on behalf of Elumo Business regarding invoice ${debtor['invoice']} for ${debtor['amount']}.",
      "${debtor['name']}: Oh right, I forgot about that.",
      "AI: No problem at all. I can send a quick payment link to your phone right now. Would that work?",
      "${debtor['name']}: Yes, please send it.",
      "AI: Done! Payment link sent. Once paid, your ledger will clear automatically. Have a great day!",
    ];

    for (final line in lines) {
      await Future.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;
      setState(() => _transcript.add(line));
    }

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() {
      _callStatus = 'Call completed — Payment link sent to ${debtor['name']}';
      _isCalling = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('AI Debt Collection Calls', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('Dispatch conversational AI agents to follow up on overdue invoices via phone calls.', style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 13, height: 1.5)),
          const SizedBox(height: 32),

          // ── Debtor selector + tone ──
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: const Color(0xFF18181B), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF27272A))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Select Debtor', style: TextStyle(color: Color(0xFFE4E4E7), fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 12),
              ..._debtors.asMap().entries.map((e) {
                final i = e.key;
                final d = e.value;
                final selected = i == _selectedDebtor;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDebtor = i),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: selected ? const Color(0xFF3B82F6).withOpacity(0.08) : const Color(0xFF09090B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: selected ? const Color(0xFF3B82F6) : const Color(0xFF27272A)),
                    ),
                    child: Row(children: [
                      Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: selected ? const Color(0xFF3B82F6) : const Color(0xFF52525B), size: 18),
                      const SizedBox(width: 12),
                      Expanded(child: Text('${d['name']} — ${d['invoice']}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500))),
                      Text(d['amount']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 12),
                      Text('${d['days']} overdue', style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 12)),
                    ]),
                  ),
                );
              }),

              const SizedBox(height: 20),
              const Text('AI Tone', style: TextStyle(color: Color(0xFFE4E4E7), fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: const Color(0xFF09090B), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF27272A))),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedTone,
                    dropdownColor: const Color(0xFF18181B),
                    isExpanded: true,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFA1A1AA)),
                    items: ['Polite & Helpful', 'Professional & Firm', 'Urgent & Direct'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (v) { if (v != null) setState(() => _selectedTone = v); },
                  ),
                ),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isCalling ? const Color(0xFFEF4444) : const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _isCalling ? null : _startCall,
                  icon: Icon(_isCalling ? Icons.phone_in_talk : Icons.phone, size: 18),
                  label: Text(_isCalling ? 'Call in Progress...' : 'Initiate AI Call', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ]),
          ),

          // ── Live transcript ──
          if (_callStatus.isNotEmpty) ...[
            const SizedBox(height: 32),
            const Text('Live Call Transcript', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: const Color(0xFF09090B), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF27272A))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  if (_isCalling) ...[
                    const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF10B981))),
                    const SizedBox(width: 12),
                  ],
                  Expanded(child: Text(_callStatus, style: TextStyle(color: _isCalling ? const Color(0xFF10B981) : const Color(0xFFA1A1AA), fontWeight: FontWeight.w600))),
                ]),
                if (_transcript.isNotEmpty) const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Color(0xFF27272A))),
                ..._transcript.map((line) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(line, style: TextStyle(
                    color: line.startsWith('AI:') ? const Color(0xFF3B82F6) : Colors.white,
                    fontSize: 14,
                    height: 1.6,
                  )),
                )),
              ]),
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================================
// 4. MULTI-CURRENCY TAX FILING
// ============================================================================
class _MultiCurrencyTaxTab extends StatefulWidget {
  const _MultiCurrencyTaxTab();
  @override
  State<_MultiCurrencyTaxTab> createState() => _MultiCurrencyTaxTabState();
}

class _MultiCurrencyTaxTabState extends State<_MultiCurrencyTaxTab> {
  String _currency = 'NGN';
  final _revenueCtrl = TextEditingController();
  double _taxAmount = 0.0;
  bool _isFiling = false;

  final _currencySymbols = {'NGN': '₦', 'USD': '\$', 'GBP': '£', 'EUR': '€'};

  final List<Map<String, String>> _filingHistory = [
    {'period': 'Q2 2024', 'currency': 'NGN', 'amount': '₦318,750', 'status': 'Filed'},
    {'period': 'Q1 2024', 'currency': 'NGN', 'amount': '₦195,200', 'status': 'Filed'},
  ];

  void _calculateTax(String val) {
    final rev = double.tryParse(val) ?? 0.0;
    setState(() => _taxAmount = rev * 0.075);
  }

  void _fileTax() async {
    if (_taxAmount <= 0) return;
    setState(() => _isFiling = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final sym = _currencySymbols[_currency]!;
    final formatted = '$sym${_taxAmount.toStringAsFixed(2)}';

    setState(() {
      _filingHistory.insert(0, {
        'period': 'Q3 2024',
        'currency': _currency,
        'amount': formatted,
        'status': 'Filed',
      });
      _isFiling = false;
      _revenueCtrl.clear();
      _taxAmount = 0.0;
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Tax successfully filed and remitted.'),
      backgroundColor: Color(0xFF10B981),
    ));
  }

  @override
  void dispose() {
    _revenueCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sym = _currencySymbols[_currency]!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Multi-Currency Tax Filing', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('Calculate and remit taxes across different currencies and jurisdictions.', style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 13, height: 1.5)),
          const SizedBox(height: 32),

          // ── Tax calculator ──
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: const Color(0xFF18181B), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF27272A))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('File New Tax', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Currency', style: TextStyle(color: Color(0xFFE4E4E7), fontSize: 13, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(color: const Color(0xFF09090B), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF27272A))),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _currency,
                          dropdownColor: const Color(0xFF18181B),
                          isExpanded: true,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFA1A1AA)),
                          items: _currencySymbols.entries.map((e) => DropdownMenuItem(value: e.key, child: Text('${e.key} (${e.value})'))).toList(),
                          onChanged: (v) { if (v != null) setState(() => _currency = v); },
                        ),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Declarable Revenue', style: TextStyle(color: Color(0xFFE4E4E7), fontSize: 13, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _revenueCtrl,
                      keyboardType: TextInputType.number,
                      onChanged: _calculateTax,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'e.g. 5000000',
                        hintStyle: const TextStyle(color: Color(0xFF52525B)),
                        filled: true,
                        fillColor: const Color(0xFF09090B),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF27272A))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF27272A))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF3B82F6))),
                      ),
                    ),
                  ]),
                ),
              ]),

              const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Divider(color: Color(0xFF27272A))),

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Tax Liability (7.5% VAT)', style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 14)),
                Text('$sym${_taxAmount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w600, letterSpacing: -0.5)),
              ]),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  onPressed: (_taxAmount > 0 && !_isFiling) ? _fileTax : null,
                  child: _isFiling
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('File & Remit Tax', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ]),
          ),

          // ── Filing history ──
          const SizedBox(height: 32),
          const Text('Filing History', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          ..._filingHistory.map((f) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF18181B), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF27272A))),
            child: Row(children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
              const SizedBox(width: 12),
              Text(f['period']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFF27272A), borderRadius: BorderRadius.circular(4)),
                child: Text(f['currency']!, style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 11)),
              ),
              const Spacer(),
              Text(f['amount']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ]),
          )),
        ],
      ),
    );
  }
}
