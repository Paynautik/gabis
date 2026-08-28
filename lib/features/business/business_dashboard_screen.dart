import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/providers/app_providers.dart';

class BusinessDashboardScreen extends ConsumerStatefulWidget {
  const BusinessDashboardScreen({super.key});

  @override
  ConsumerState<BusinessDashboardScreen> createState() => _BusinessDashboardScreenState();
}

class _BusinessDashboardScreenState extends ConsumerState<BusinessDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Tax Calculator state
  final _taxAmountController = TextEditingController(text: '500000');
  String _selectedServiceType = 'Consulting / Professional Services (5% WHT)';
  double _calculatedVat = 37500.0;
  double _calculatedWht = 25000.0;
  double _calculatedNet = 475000.0;
  bool _isRemittingTax = false;
  String _selectedTaxCountry = 'Nigeria 🇳🇬';

  // Invoice creator state
  final _invoicePromptController = TextEditingController(text: 'Create an invoice for ABC Technologies for ₦450,000 for cloud consulting.');
  Map<String, String>? _draftedInvoice;
  bool _isDraftingInvoice = false;

  // Semantic search state
  final _searchController = TextEditingController();
  String _activeSearchQuery = '';

  // Reconciliation state
  final List<Map<String, String>> _unreconciledMatches = [
    {
      'id': 'recon_1',
      'invoice': 'INV-1024 (₦250,000) • Sarah Jenkins',
      'bank': 'Bank Transfer: ₦250,000 received from S. JENKINS',
      'confidence': '98%',
      'counterparty': 'Sarah Jenkins',
      'amount': '₦250,000.00'
    },
    {
      'id': 'recon_2',
      'invoice': 'INV-1025 (₦480,000) • Acme Ltd',
      'bank': 'Bank Transfer: ₦480,000 received from ACME NIGERIA',
      'confidence': '85%',
      'counterparty': 'Acme Ltd',
      'amount': '₦480,000.00'
    },
  ];
  int _reconciledCount = 0;

  // Payroll runner state
  final _employeeNameController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCountry = 'Nigeria 🇳🇬';
  String _selectedCurrency = 'NGN';
  bool _showSecretKey = false;
  bool _isProcessingPayroll = false;

  final List<Map<String, String>> _payoutHistory = [
    {
      'name': 'David O.',
      'country': 'Nigeria 🇳🇬',
      'amount': '₦450,000.00',
      'status': 'Successful',
      'ref': 'TX-PAY-89211'
    },
    {
      'name': 'Emma Watson',
      'country': 'United Kingdom 🇬🇧',
      'amount': '£2,800.00',
      'status': 'Successful',
      'ref': 'TX-PAY-72301'
    },
    {
      'name': 'Michael Chen',
      'country': 'United States 🇺🇸',
      'amount': '\$4,500.00',
      'status': 'Successful',
      'ref': 'TX-PAY-11204'
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _invoicePromptController.dispose();
    _searchController.dispose();
    _employeeNameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _draftInvoice() async {
    final prompt = _invoicePromptController.text.trim();
    if (prompt.isEmpty) return;

    setState(() => _isDraftingInvoice = true);
    await Future.delayed(const Duration(milliseconds: 1200));

    // Simple natural language parsing
    String recipient = 'ABC Technologies';
    String amount = '₦450,000.00';
    String desc = 'Cloud consulting';

    if (prompt.toLowerCase().contains('sarah')) {
      recipient = 'Sarah Designs';
      amount = '₦150,000.00';
      desc = 'Logo + Brand Identity';
    } else if (prompt.toLowerCase().contains('acme')) {
      recipient = 'Acme Ltd';
      amount = '₦2,500,000.00';
      desc = 'Database Migration';
    } else {
      // Regex parsing fallback
      final amountRegex = RegExp(r'[₦$]?\s*(\d{1,3}(,\d{3})*(\.\d{2})?|\d+)');
      final match = amountRegex.firstMatch(prompt);
      if (match != null) {
        amount = '₦${match.group(1)}';
      }
    }

    if (!mounted) return;
    setState(() {
      _isDraftingInvoice = false;
      _draftedInvoice = {
        'recipient': recipient,
        'amount': amount,
        'desc': desc,
        'status': 'DRAFT',
        'ref': 'INV-${DateTime.now().millisecond + 1000}'
      };
    });
  }

  void _reconcileMatch(String id, String counterpart, String amount) async {
    setState(() {
      _unreconciledMatches.removeWhere((m) => m['id'] == id);
      _reconciledCount++;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
              child: const Icon(Icons.verified_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('AI Reconciled', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Gemini matching successfully linked invoice to $counterpart\'s transfer of $amount. Transaction reconciled and accounting ledger updated.',
          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _executeDisbursement() async {
    final name = _employeeNameController.text.trim();
    final amount = _amountController.text.trim();

    if (name.isEmpty || amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in employee name and payout amount.')),
      );
      return;
    }

    setState(() => _isProcessingPayroll = true);
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() {
      _isProcessingPayroll = false;
      _payoutHistory.insert(0, {
        'name': name,
        'country': _selectedCountry,
        'amount': '$_selectedCurrency $amount',
        'status': 'Successful',
        'ref': 'TX-PAY-${DateTime.now().millisecond + 40000}'
      });
      _employeeNameController.clear();
      _amountController.clear();
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Payout Executed', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Smart contract payout of $_selectedCurrency $amount to $name has been completed instantly with zero hidden fees.',
          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 750;

    return Scaffold(
      backgroundColor: const Color(0xFF070F1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF070F1E),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF00D2FF)]),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.business_center_rounded, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
            const Text(
              'ELUMO BUSINESS SUITE',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton.icon(
              onPressed: () {
                ref.read(isBusinessModeProvider.notifier).state = false;
              },
              icon: const Icon(Icons.swap_horiz_rounded, color: Color(0xFF22D3EE), size: 18),
              label: const Text(
                'Personal Account',
                style: TextStyle(color: Color(0xFF22D3EE), fontWeight: FontWeight.bold, fontSize: 12.5),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF22D3EE),
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFF64748B),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'Overview & Forecast'),
            Tab(text: 'AI Reconciliation'),
            Tab(text: 'Invoices & Installments'),
            Tab(text: 'Tax & Compliance'),
            Tab(text: 'Developer & Search'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(isDesktop),
          _buildReconciliationTab(),
          _buildInvoicingPayrollTab(isDesktop),
          _buildTaxComplianceTab(isDesktop),
          _buildDeveloperTab(isDesktop),
        ],
      ),
    );
  }

  // ============================================================
  // TAB 1: OVERVIEW & FORECASTING
  // ============================================================
  Widget _buildOverviewTab(bool isDesktop) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMetricsGrid(),
          const SizedBox(height: 24),
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: _buildForecasterCard()),
                const SizedBox(width: 24),
                Expanded(flex: 4, child: _buildInsightsSummaryCard()),
              ],
            )
          else ...[
            _buildForecasterCard(),
            const SizedBox(height: 24),
            _buildInsightsSummaryCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildMetricBox(
          title: 'Total Collected',
          value: '₦12,840,250.00',
          change: '+18.4%',
          icon: Icons.trending_up_rounded,
          color: const Color(0xFF10B981),
        ),
        _buildMetricBox(
          title: 'AI Reconciled Matches',
          value: '$_reconciledCount Matches',
          change: 'Reconciliation Health: 100%',
          icon: Icons.verified_user_rounded,
          color: const Color(0xFF22D3EE),
        ),
        _buildMetricBox(
          title: 'Unreconciled Invoices',
          value: '${_unreconciledMatches.length} pending',
          change: 'Action Required',
          icon: Icons.warning_amber_rounded,
          color: const Color(0xFFFBBF24),
        ),
      ],
    );
  }

  Widget _buildMetricBox({
    required String title,
    required String value,
    required String change,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.bold)),
              Icon(icon, color: color, size: 18),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5),
          ),
          const SizedBox(height: 6),
          Text(
            change,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _buildForecasterCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.timeline_rounded, color: Color(0xFF22D3EE), size: 20),
              SizedBox(width: 8),
              Text('AI Cash-Flow Forecasting', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Expected cash position in 30 days based on historic patterns, verified receivables, and seasonal transaction flows.',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.35),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('CURRENT BALANCE', style: TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('₦12,840,250.00', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const Icon(Icons.arrow_forward_rounded, color: Color(0xFF22D3EE), size: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('ELUMO 30-DAY FORECAST', style: TextStyle(color: Color(0xFF22D3EE), fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('₦14,250,000.00', style: TextStyle(color: Color(0xFF22D3EE), fontSize: 22, fontWeight: FontWeight.w900)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Gemini Prediction Factors:', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 14),
                    SizedBox(width: 8),
                    Text('Outstanding invoice payments (₦2.1M expected)', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5)),
                  ],
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 14),
                    SizedBox(width: 8),
                    Text('Scheduled payroll expenses (₦1.4M outflow)', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5)),
                  ],
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 14),
                    SizedBox(width: 8),
                    Text('Seasonal sales booster pattern (+12% projected)', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.insights_rounded, color: Color(0xFF10B981), size: 20),
              SizedBox(width: 8),
              Text('Elumo Financial Insights', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Actionable, data-driven financial health summaries compiled directly from your sales patterns.',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.35),
          ),
          const SizedBox(height: 20),
          _insightRow('Unpaid Receivables', 'Your outstanding customer invoices grew by 31% this month. Reconciling them will increase cash reserves by ₦2.8M.'),
          const Divider(color: Colors.white10),
          _insightRow('Failed Payment Recovery', 'Automatic payment recovery links successfully re-billed and secured ₦120K in previously failed card payments.'),
        ],
      ),
    );
  }

  Widget _insightRow(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(desc, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5, height: 1.4)),
        ],
      ),
    );
  }

  // ============================================================
  // TAB 2: AI RECONCILIATION
  // ============================================================
  Widget _buildReconciliationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF2563EB).withValues(alpha: 0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.psychology_rounded, color: Color(0xFF22D3EE), size: 24),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('AI-Native Reconciliation Engine', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.5)),
                      SizedBox(height: 4),
                      Text(
                        'Gemini automatically scans outstanding invoices and matching bank transfer descriptions, suggesting 95%+ accurate links.',
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Suggested Reconciliation Matches', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (_unreconciledMatches.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white10),
              ),
              child: const Column(
                children: [
                  Icon(Icons.done_all_rounded, color: Color(0xFF10B981), size: 40),
                  SizedBox(height: 12),
                  Text('All Clear!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  SizedBox(height: 4),
                  Text('Every payment has been reconciled successfully.', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _unreconciledMatches.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final match = _unreconciledMatches[index];
                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.bolt_rounded, color: Color(0xFF10B981), size: 12),
                                    const SizedBox(width: 4),
                                    Text('Gemini Match: ${match['confidence']}', style: const TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Text(match['amount'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.receipt_long_rounded, color: Color(0xFF64748B), size: 16),
                          const SizedBox(width: 8),
                          Expanded(child: Text(match['invoice'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.account_balance_rounded, color: Color(0xFF64748B), size: 16),
                          const SizedBox(width: 8),
                          Expanded(child: Text(match['bank'] ?? '', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12.5))),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _reconcileMatch(match['id'] ?? '', match['counterparty'] ?? '', match['amount'] ?? ''),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.check_rounded, size: 14),
                            label: const Text('Auto-Reconcile Match', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ============================================================
  // TAB 3: INVOICING & PAYROLL
  // ============================================================

  // ============================================================
  // TAB 3: INVOICES & INSTALLMENTS lifecycle operations
  // ============================================================
  Widget _buildInvoicingPayrollTab(bool isDesktop) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: _buildInvoiceAssistantCard()),
                const SizedBox(width: 24),
                Expanded(flex: 5, child: Column(
                  children: [
                    _buildInstallmentLedgerCard(),
                    const SizedBox(height: 24),
                    _buildRefundManagerCard(),
                  ],
                )),
              ],
            )
          else ...[
            _buildInvoiceAssistantCard(),
            const SizedBox(height: 24),
            _buildInstallmentLedgerCard(),
            const SizedBox(height: 24),
            _buildRefundManagerCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildInvoiceAssistantCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.history_edu_rounded, color: Color(0xFF22D3EE), size: 20),
              SizedBox(width: 8),
              Text('AI Invoice Assistant', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "Type a sentence to automatically draft a completed invoice using Elumo's semantic parser.",
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.35),
          ),
          const SizedBox(height: 20),
          _buildDarkField(
            label: 'Voice / Text Invoice Description',
            hint: 'e.g. Create an invoice for ABC Technologies...',
            controller: _invoicePromptController,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: _isDraftingInvoice ? null : _draftInvoice,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isDraftingInvoice
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Draft Invoice via Gemini', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
            ),
          ),
          if (_draftedInvoice != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_draftedInvoice!['ref'] ?? '', style: const TextStyle(color: Color(0xFF22D3EE), fontWeight: FontWeight.bold, fontSize: 12)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(8)),
                        child: Text(_draftedInvoice!['status'] ?? '', style: const TextStyle(color: Colors.yellow, fontSize: 9.5, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(_draftedInvoice!['recipient'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(_draftedInvoice!['desc'] ?? '', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12.5)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_draftedInvoice!['amount'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17)),
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: const Color(0xFF0F172A),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              title: const Text('Payment Link Active', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              content: const Text(
                                'Payment request link generated: elumo.to/pay/abc-49821. Reconcile matching bank statement triggers instantly.',
                                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, height: 1.45),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Copy Link', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Review & Send Link', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInstallmentLedgerCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.payment_rounded, color: Color(0xFF22D3EE), size: 20),
              SizedBox(width: 8),
              Text('Installment & Receivables Ledger', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Track customer installment milestones, outstanding balances, payment deadlines, and service cut-offs.',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 11.5, height: 1.35),
          ),
          const SizedBox(height: 20),
          
          _installmentRow(
            name: 'Mwangi Kamau',
            service: 'Photography Consulting',
            amountPaid: 'KES 100,000',
            amountRemaining: 'KES 50,000',
            deadline: '3 days remaining',
            color: const Color(0xFF22D3EE),
            actionText: 'Send Reminder',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Payment reminder dispatched to Mwangi Kamau: "Sarah\'s KES 50,000 installment is due in 3 days."')),
              );
            },
          ),
          const Divider(color: Colors.white10, height: 24),
          _installmentRow(
            name: 'Sarah Okafor',
            service: 'E-commerce Audit',
            amountPaid: '₦50,000',
            amountRemaining: '₦50,000',
            deadline: 'OVERDUE (1d)',
            color: Colors.redAccent,
            actionText: 'Trigger AI Voice Call',
            onTap: () {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const _RobotCallSimulatorDialog(
                  customerName: 'Sarah Okafor',
                  phoneNumber: '+234 803 241 8902',
                  debtAmount: '₦50,000',
                  serviceName: 'E-commerce Audit',
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _installmentRow({
    required String name,
    required String service,
    required String amountPaid,
    required String amountRemaining,
    required String deadline,
    required Color color,
    required String actionText,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
              child: Text(deadline, style: TextStyle(color: color, fontSize: 9.5, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(service, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('PAID TO DATE', style: TextStyle(color: Color(0xFF475569), fontSize: 8.5, fontWeight: FontWeight.bold)),
                Text(amountPaid, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('REMAINING DUE', style: TextStyle(color: Color(0xFF475569), fontSize: 8.5, fontWeight: FontWeight.bold)),
                Text(amountRemaining, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: color.withValues(alpha: 0.15),
                foregroundColor: color,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(actionText, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRefundManagerCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.assignment_return_rounded, color: Color(0xFF10B981), size: 20),
              SizedBox(width: 8),
              Text('Refund Policy & Deadline Tracker', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Monitor refund windows and return policies. Receive alerts before customer refund deadlines expire.',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 11.5, height: 1.35),
          ),
          const SizedBox(height: 20),
          
          _refundRow(
            customer: 'Funke Adebayo',
            policy: '14-day full return policy',
            timeRemaining: '2 days remaining',
            color: const Color(0xFF10B981),
            amount: '₦150,000.00',
            actionText: 'Send e-Receipt',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('e-Receipt dispatch completed. Reference locked under transaction ledger.')),
              );
            },
          ),
          const Divider(color: Colors.white10, height: 24),
          _refundRow(
            customer: 'Amara Diallo',
            policy: '7-day cancellation policy',
            timeRemaining: '4 days remaining',
            color: const Color(0xFF22D3EE),
            amount: 'GHS 420.00',
            actionText: 'Process Refund',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Refund request initiated. Settlement scheduled instantly.')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _refundRow({
    required String customer,
    required String policy,
    required String timeRemaining,
    required Color color,
    required String amount,
    required String actionText,
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(customer, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(policy, style: const TextStyle(color: Color(0xFF64748B), fontSize: 10.5)),
            const SizedBox(height: 6),
            Text(amount, style: const TextStyle(color: Colors.white70, fontSize: 12.5, fontWeight: FontWeight.bold)),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
              child: Text(timeRemaining, style: TextStyle(color: color, fontSize: 9.5, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: color.withValues(alpha: 0.15),
                foregroundColor: color,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(actionText, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ],
    );
  }


  // ============================================================
  // TAB 4: TAX & PAN-AFRICAN COMPLIANCE HUB
  // ============================================================
  String _getTaxAuthority() {
    if (_selectedTaxCountry.contains('Kenya')) return 'KRA';
    if (_selectedTaxCountry.contains('Ghana')) return 'GRA';
    if (_selectedTaxCountry.contains('South')) return 'SARS';
    return 'FIRS';
  }

  String _getTaxCurrency() {
    if (_selectedTaxCountry.contains('Kenya')) return 'KES ';
    if (_selectedTaxCountry.contains('Ghana')) return 'GHS ';
    if (_selectedTaxCountry.contains('South')) return 'ZAR ';
    return '₦';
  }

  double _getVatRate() {
    if (_selectedTaxCountry.contains('Kenya')) return 0.16; // 16% standard VAT
    if (_selectedTaxCountry.contains('Ghana')) return 0.15; // 15% standard VAT
    if (_selectedTaxCountry.contains('South')) return 0.15; // 15% standard VAT
    return 0.075; // 7.5% standard VAT Nigeria
  }

  List<String> _getServiceOptions() {
    if (_selectedTaxCountry.contains('Kenya')) {
      return const [
        'Professional / Management Services (5% WHT)',
        'Contractual / Construction Services (3% WHT)',
        'Consultancy & Agency Fees (10% WHT)',
      ];
    } else if (_selectedTaxCountry.contains('Ghana')) {
      return const [
        'Professional / Consulting Services (7.5% WHT)',
        'Works & Construction Contracts (5% WHT)',
        'Supply of Goods / Commodities (3% WHT)',
      ];
    } else if (_selectedTaxCountry.contains('South')) {
      return const [
        'Services by Non-Residents (15% WHT)',
        'Royalties & Interest Payments (10% WHT)',
        'Dividends & Corporate Payouts (5% WHT)',
      ];
    } else {
      return const [
        'Consulting / Professional Services (5% WHT)',
        'Corporate Supplies / Goods (2.5% WHT)',
        'Construction / Building Contracts (10% WHT)',
      ];
    }
  }

  void _recalculateTax(String val) {
    final amt = double.tryParse(val.replaceAll(',', '').trim()) ?? 0.0;
    double whtPercent = 0.05; // Default Consulting

    if (_selectedServiceType.contains('15%')) {
      whtPercent = 0.15;
    } else if (_selectedServiceType.contains('10%')) {
      whtPercent = 0.10;
    } else if (_selectedServiceType.contains('7.5%')) {
      whtPercent = 0.075;
    } else if (_selectedServiceType.contains('5%')) {
      whtPercent = 0.05;
    } else if (_selectedServiceType.contains('3%')) {
      whtPercent = 0.03;
    } else if (_selectedServiceType.contains('2.5%')) {
      whtPercent = 0.025;
    }

    setState(() {
      _calculatedVat = amt * _getVatRate();
      _calculatedWht = amt * whtPercent;
      _calculatedNet = amt - _calculatedWht;
    });
  }

  void _executeFirsRemittance() async {
    setState(() => _isRemittingTax = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isRemittingTax = false);

    final auth = _getTaxAuthority();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
              child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text('$auth Remitted', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Tax remittance payment successfully processed. $auth e-receipt generated and logged under certificate clearance ledger. Ref: $auth-TX-9082A.',
          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Download Receipt', style: TextStyle(color: Color(0xFF22D3EE), fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildTaxComplianceTab(bool isDesktop) {
    final auth = _getTaxAuthority();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Pan-African Country Selector & Summary Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tax Jurisdiction:', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          dropdownColor: const Color(0xFF0F172A),
                          value: _selectedTaxCountry,
                          items: const [
                            DropdownMenuItem(value: 'Nigeria 🇳🇬', child: Text('Nigeria 🇳🇬 (FIRS)', style: TextStyle(color: Colors.white, fontSize: 12))),
                            DropdownMenuItem(value: 'Kenya 🇰🇪', child: Text('Kenya 🇰🇪 (KRA)', style: TextStyle(color: Colors.white, fontSize: 12))),
                            DropdownMenuItem(value: 'Ghana 🇬🇭', child: Text('Ghana 🇬🇭 (GRA)', style: TextStyle(color: Colors.white, fontSize: 12))),
                            DropdownMenuItem(value: 'South Africa 🇿🇦', child: Text('South Africa 🇿🇦 (SARS)', style: TextStyle(color: Colors.white, fontSize: 12))),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedTaxCountry = val;
                                _selectedServiceType = _getServiceOptions().first;
                                _recalculateTax(_taxAmountController.text);
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.white10, height: 24),
                Row(
                  children: [
                    CircularProgressIndicator(
                      value: 0.98,
                      strokeWidth: 6,
                      color: const Color(0xFF10B981),
                      backgroundColor: Colors.white.withValues(alpha: 0.05),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$auth Tax Compliance Score: 98%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 4),
                          Text(
                            'Your business is fully compliant with tax mandates. Next local $auth Tax Clearance Certificate (TCC) review scheduled.',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11.5, height: 1.35),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: _buildTaxCalculatorCard()),
                const SizedBox(width: 24),
                Expanded(flex: 5, child: _buildTaxLedgerCard()),
              ],
            )
          else ...[
            _buildTaxCalculatorCard(),
            const SizedBox(height: 24),
            _buildTaxLedgerCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildTaxCalculatorCard() {
    final auth = _getTaxAuthority();
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calculate_rounded, color: Color(0xFF22D3EE), size: 20),
              const SizedBox(width: 8),
              Text('$auth WHT & VAT Calculator', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Calculate mandatory Withholding Tax (WHT) and Value Added Tax (VAT) deductions under current local $auth regulations.',
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.35),
          ),
          const SizedBox(height: 20),
          
          // Dropdown selector for service type
          const Text('Transaction Service Type', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF070F1E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                dropdownColor: const Color(0xFF0F172A),
                value: _selectedServiceType,
                items: _getServiceOptions().map((String opt) {
                  return DropdownMenuItem<String>(
                    value: opt,
                    child: Text(opt, style: const TextStyle(color: Colors.white, fontSize: 11.5), overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedServiceType = val;
                      _recalculateTax(_taxAmountController.text);
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          _buildDarkField(
            label: 'Invoice Gross Amount (${_getTaxCurrency().trim()})',
            hint: 'e.g. 500000',
            controller: _taxAmountController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          
          // Real-time calculation summary block
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Column(
              children: [
                _taxRow('VAT Collected (' + (_getVatRate() * 100).toStringAsFixed(1) + '%)', _getTaxCurrency() + _calculatedVat.toStringAsFixed(2), const Color(0xFF10B981)),
                const SizedBox(height: 8),
                _taxRow('WHT Deducted', _getTaxCurrency() + _calculatedWht.toStringAsFixed(2), const Color(0xFFFBBF24)),
                const Divider(color: Colors.white10, height: 24),
                _taxRow('Net Invoice Payable', _getTaxCurrency() + _calculatedNet.toStringAsFixed(2), const Color(0xFF22D3EE), isBold: true),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () {
                _recalculateTax(_taxAmountController.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Calculate Taxes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _taxRow(String label, String value, Color color, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.bold)),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTaxLedgerCard() {
    final auth = _getTaxAuthority();
    final cur = _getTaxCurrency().trim();
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Auto-Deducted $auth Ledger', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(
            'Local $auth-compliant audit ledger showing VAT collections and WHT certificates associated with client transfers.',
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5, height: 1.35),
          ),
          const SizedBox(height: 20),
          
          _taxLedgerRow('Acme Ltd (Server Migration)', '$cur 250,000 gross', 'WHT Deducted: $cur 12,500', 'VAT: $cur 18,750'),
          const Divider(color: Colors.white10),
          _taxLedgerRow('Funke Adebayo (Baking Flour Supply)', '$cur 150,000 gross', 'WHT Deducted: $cur 3,750', 'VAT: $cur 11,250'),
          const Divider(color: Colors.white10),
          _taxLedgerRow('Access Partner Payout (Suppliers)', '$cur 1,200,000 gross', 'WHT Withheld: $cur 60,000', 'VAT Exempted'),
          
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _isRemittingTax ? null : _executeFirsRemittance,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: _isRemittingTax
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.account_balance_rounded, size: 16),
              label: Text('Remit Pending Taxes to $auth', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _taxLedgerRow(String title, String gross, String wht, String vat) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              Text(gross, style: const TextStyle(color: Color(0xFF22D3EE), fontSize: 11.5, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(wht, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
              Text(vat, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }


  // ============================================================
  // TAB 4: DEVELOPER & SEMANTIC SEARCH
  // ============================================================
  Widget _buildDeveloperTab(bool isDesktop) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildSemanticSearchCard(),
          const SizedBox(height: 24),
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: _buildDeveloperCard()),
                const SizedBox(width: 24),
                Expanded(flex: 5, child: _buildPayoutHistoryCard()),
              ],
            )
          else ...[
            _buildDeveloperCard(),
            const SizedBox(height: 24),
            _buildPayoutHistoryCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildSemanticSearchCard() {
    // Simulated database search
    final allTxs = [
      {'title': 'Acme Ltd Invoice', 'counterparty': 'Acme Ltd', 'amount': '₦850,000.00', 'details': 'Database Migration', 'location': 'Lagos, NG', 'reconciled': 'Yes'},
      {'title': 'Sarah Designs Billing', 'counterparty': 'Sarah Designs', 'amount': '₦150,000.00', 'details': 'Logo Design', 'location': 'Lagos, NG', 'reconciled': 'No'},
      {'title': 'Zenith Bank Payout', 'counterparty': 'Zenith Bank', 'amount': '₦1,200,000.00', 'details': 'Supplier Payout', 'location': 'Abuja, NG', 'reconciled': 'Yes'},
      {'title': 'Netflix Media Inc', 'counterparty': 'Netflix', 'amount': '₦4,500.00', 'details': 'Monthly Subscription', 'location': 'California, US', 'reconciled': 'Yes'},
    ];

    List<Map<String, String>> filteredTxs = allTxs;
    if (_activeSearchQuery.isNotEmpty) {
      final q = _activeSearchQuery.toLowerCase();
      filteredTxs = allTxs.where((tx) {
        if (q.contains('lagos') && !tx['location']!.toLowerCase().contains('lagos')) return false;
        if (q.contains('reconciled') && tx['reconciled'] != 'Yes') return false;
        if (q.contains('unreconciled') && tx['reconciled'] != 'No') return false;
        if (q.contains('above') || q.contains('>') || q.contains('500') || q.contains('100')) {
          final amt = double.parse(tx['amount']!.replaceAll('₦', '').replaceAll(',', '').trim());
          if (q.contains('500') && amt <= 500000) return false;
          if (q.contains('100') && amt <= 100000) return false;
        }
        return tx['title']!.toLowerCase().contains(q) ||
            tx['counterparty']!.toLowerCase().contains(q) ||
            tx['details']!.toLowerCase().contains(q);
      }).toList();
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.manage_search_rounded, color: Color(0xFF22D3EE), size: 20),
              SizedBox(width: 8),
              Text('AI Transaction Semantic Search', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Search collections, locations, amounts, or reconciliation status using normal natural language queries.',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.35),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'e.g. Payments from Lagos above ₦100,000 that are reconciled',
                    hintStyle: const TextStyle(color: Color(0xFF475569), fontSize: 12.5),
                    fillColor: const Color(0xFF070F1E),
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF22D3EE), width: 1.5)),
                  ),
                  onChanged: (val) {
                    setState(() => _activeSearchQuery = val);
                  },
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                style: IconButton.styleFrom(backgroundColor: const Color(0xFF22D3EE)),
                icon: const Icon(Icons.search_rounded, color: Color(0xFF07111F)),
                onPressed: () {
                  setState(() => _activeSearchQuery = _searchController.text);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Presets
          Row(
            children: [
              const Text('PRESETS:', style: TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              _searchPresetChip('Lagos payments > ₦100k', 'Lagos payments above ₦100,000'),
              const SizedBox(width: 8),
              _searchPresetChip('Unreconciled invoices', 'unreconciled'),
            ],
          ),
          const SizedBox(height: 20),
          // Results
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredTxs.length,
            separatorBuilder: (context, index) => Divider(color: Colors.white.withValues(alpha: 0.05)),
            itemBuilder: (context, index) {
              final tx = filteredTxs[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tx['title'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 2),
                        Text('${tx['details']} • ${tx['location']}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(tx['amount'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13.5)),
                        const SizedBox(height: 2),
                        Text(
                          tx['reconciled'] == 'Yes' ? 'RECONCILED' : 'UNRECONCILED',
                          style: TextStyle(color: tx['reconciled'] == 'Yes' ? const Color(0xFF10B981) : Colors.yellow, fontSize: 9.5, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _searchPresetChip(String label, String query) {
    return ActionChip(
      backgroundColor: Colors.white.withValues(alpha: 0.04),
      side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      padding: const EdgeInsets.all(4),
      label: Text(label, style: const TextStyle(color: Color(0xFF22D3EE), fontSize: 10, fontWeight: FontWeight.bold)),
      onPressed: () {
        _searchController.text = query;
        setState(() {
          _activeSearchQuery = query;
        });
      },
    );
  }

  Widget _buildDeveloperCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.code_rounded, color: Color(0xFF22D3EE), size: 20),
                  SizedBox(width: 8),
                  Text('Developer API Portal', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              IconButton(
                icon: Icon(
                  _showSecretKey ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: const Color(0xFF94A3B8),
                  size: 18,
                ),
                onPressed: () => setState(() => _showSecretKey = !_showSecretKey),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Integrate global payments directly into your products using clean, robust Elumo developer tools.',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.35),
          ),
          const SizedBox(height: 16),
          _buildApiKeyBlock(
            label: 'Public Live Key (pk_live)',
            value: 'pk_live_elumo_9a82fbc193b0ce93847da',
          ),
          const SizedBox(height: 12),
          _buildApiKeyBlock(
            label: 'Secret Live Key (sk_live)',
            value: _showSecretKey ? 'sk_live_elumo_552a8182bdf1011883b276ff1' : 'sk_live_elumo_•••••••••••••••••••••••••',
          ),
          const SizedBox(height: 16),
          const Text('Webhook Target URL', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF070F1E),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'https://api.yourdomain.com/elumo-webhook',
                    style: TextStyle(color: Color(0xFF94A3B8), fontFamily: 'monospace', fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.copy_all_rounded, color: Color(0xFF22D3EE), size: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApiKeyBlock({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF070F1E),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 11.5),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('API key copied to clipboard!')),
                  );
                },
                child: const Icon(Icons.copy_rounded, color: Color(0xFF22D3EE), size: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDarkField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF475569), fontSize: 13),
            fillColor: const Color(0xFF070F1E),
            filled: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildPayoutHistoryCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent Payroll Transactions', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _payoutHistory.length,
            separatorBuilder: (context, index) => Divider(color: Colors.white.withValues(alpha: 0.05)),
            itemBuilder: (context, index) {
              final tx = _payoutHistory[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: const Color(0xFF1E293B), shape: BoxShape.circle),
                          child: const Icon(Icons.outbox_rounded, color: Color(0xFF10B981), size: 16),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tx['name'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
                            const SizedBox(height: 3),
                            Text('${tx['country']} • Ref: ${tx['ref']}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(tx['amount'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 4),
                            Text(tx['status'] ?? '', style: const TextStyle(color: Color(0xFF10B981), fontSize: 10.5, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}



// ============================================================
// AI VOICE REMINDER / ROBOT CALL SIMULATOR DIALOG
// ============================================================
class _RobotCallSimulatorDialog extends StatefulWidget {
  final String customerName;
  final String phoneNumber;
  final String debtAmount;
  final String serviceName;

  const _RobotCallSimulatorDialog({
    required this.customerName,
    required this.phoneNumber,
    required this.debtAmount,
    required this.serviceName,
  });

  @override
  State<_RobotCallSimulatorDialog> createState() => _RobotCallSimulatorDialogState();
}

class _RobotCallSimulatorDialogState extends State<_RobotCallSimulatorDialog> {
  int _callStep = 0; // 0: Preview, 1: Connecting, 2: Ringing, 3: Answered, 4: Recited, 5: Completed
  bool _isMuted = false;

  void _startRobotCall() async {
    setState(() => _callStep = 1);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() => _callStep = 2);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() => _callStep = 3);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _callStep = 4);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _callStep = 5);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF0F172A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      contentPadding: const EdgeInsets.all(24),
      content: SizedBox(
        width: 400,
        child: _callStep == 0 ? _buildCallPreview() : _buildActiveCallSimulator(),
      ),
    );
  }

  Widget _buildCallPreview() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.redAccent.withValues(alpha: 0.15), shape: BoxShape.circle),
              child: const Icon(Icons.ring_volume_rounded, color: Colors.redAccent, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('AI Voice Reminder', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Send an automated robot call reminder to ${widget.customerName} regarding their overdue balance of ${widget.debtAmount}.',
          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13, height: 1.4),
        ),
        const SizedBox(height: 16),
        const Text('VOICE CALL SCRIPT PREVIEW:', style: TextStyle(color: Color(0xFF475569), fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.02), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withValues(alpha: 0.06))),
          child: Text(
            '"Hello ${widget.customerName}, this is an automated voice reminder from Adebayo Retail. Your installment payment of ${widget.debtAmount} for ${widget.serviceName} is overdue. Please settle this balance via elumo.to/p/sarah-59. Thank you."',
            style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 11.5, fontStyle: FontStyle.italic, height: 1.45),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: _startRobotCall,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.phone_forwarded_rounded, size: 14),
              label: const Text('Initiate Call Now', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActiveCallSimulator() {
    String callStatusText = 'Connecting...';
    Color pulseColor = Colors.amber;
    IconData stepIcon = Icons.phone_callback_rounded;

    if (_callStep == 1) {
      callStatusText = 'Dialing ${widget.phoneNumber}...';
      pulseColor = Colors.amber;
    } else if (_callStep == 2) {
      callStatusText = 'Ringing...';
      pulseColor = Colors.cyan;
    } else if (_callStep == 3) {
      callStatusText = 'Customer Answered • Reciting Script';
      pulseColor = const Color(0xFF10B981);
    } else if (_callStep == 4) {
      callStatusText = 'Reading Script... (80% read)';
      pulseColor = const Color(0xFF10B981);
    } else if (_callStep == 5) {
      callStatusText = 'Call Finished • Status: Acknowledged';
      pulseColor = const Color(0xFF10B981);
      stepIcon = Icons.check_circle_rounded;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        // Pulsing phone animation
        TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.8, end: 1.1),
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
          builder: (context, val, child) {
            return Transform.scale(scale: _callStep == 5 ? 1.0 : val, child: child);
          },
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: pulseColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(stepIcon, color: pulseColor, size: 40),
          ),
        ),
        const SizedBox(height: 24),
        Text(widget.customerName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(widget.phoneNumber, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
        const SizedBox(height: 16),
        Text(callStatusText, style: TextStyle(color: pulseColor, fontSize: 13.5, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        
        // Checklist progress indicator
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.02), borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              _stepItem('[✓] Dialing recipient', _callStep >= 1),
              const SizedBox(height: 6),
              _stepItem('[✓] Ringing', _callStep >= 2),
              const SizedBox(height: 6),
              _stepItem('[✓] Answered by customer', _callStep >= 3),
              const SizedBox(height: 6),
              _stepItem('[✓] AI Voice reciting script', _callStep >= 4),
              const SizedBox(height: 6),
              _stepItem('[✓] Call finished & logged', _callStep >= 5),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(_isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded, color: Colors.white60),
              onPressed: () => setState(() => _isMuted = !_isMuted),
            ),
            if (_callStep == 5)
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
              )
            else
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Hang Up', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ],
    );
  }

  Widget _stepItem(String text, bool active) {
    return Row(
      children: [
        Icon(
          active ? Icons.check_circle_rounded : Icons.circle_outlined,
          color: active ? const Color(0xFF10B981) : const Color(0xFF475569),
          size: 14,
        ),
        const SizedBox(width: 8),
        Text(
          text.substring(4),
          style: TextStyle(
            color: active ? Colors.white70 : const Color(0xFF475569),
            fontSize: 12,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
