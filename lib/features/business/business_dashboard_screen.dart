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
    _tabController = TabController(length: 4, vsync: this);
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
            Tab(text: 'Invoicing & Payroll'),
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
                Expanded(flex: 5, child: _buildPayrollRunnerCard()),
              ],
            )
          else ...[
            _buildInvoiceAssistantCard(),
            const SizedBox(height: 24),
            _buildPayrollRunnerCard(),
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
            'Type a sentence to automatically draft a completed invoice using Elumo\'s semantic parser.',
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

  Widget _buildPayrollRunnerCard() {
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
                  Icon(Icons.hub_rounded, color: Color(0xFF10B981), size: 20),
                  SizedBox(width: 8),
                  Text('Global Payroll Runner', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12)),
                child: const Text('150+ Countries supported', style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Disburse salaries, bonuses, and contractor payments globally inside a unified ledger instantly.',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.35),
          ),
          const SizedBox(height: 20),
          _buildDarkField(
            label: 'Employee Full Name / ID',
            hint: 'e.g. Sarah Jenkins',
            controller: _employeeNameController,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Destination Country', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF070F1E),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          dropdownColor: const Color(0xFF0F172A),
                          value: _selectedCountry,
                          items: const [
                            DropdownMenuItem(value: 'Nigeria 🇳🇬', child: Text('Nigeria 🇳🇬', style: TextStyle(color: Colors.white, fontSize: 12))),
                            DropdownMenuItem(value: 'Ghana 🇬🇭', child: Text('Ghana 🇬🇭', style: TextStyle(color: Colors.white, fontSize: 12))),
                            DropdownMenuItem(value: 'Kenya 🇰🇪', child: Text('Kenya 🇰🇪', style: TextStyle(color: Colors.white, fontSize: 12))),
                            DropdownMenuItem(value: 'United Kingdom 🇬🇧', child: Text('United Kingdom 🇬🇧', style: TextStyle(color: Colors.white, fontSize: 12))),
                            DropdownMenuItem(value: 'United States 🇺🇸', child: Text('United States 🇺🇸', style: TextStyle(color: Colors.white, fontSize: 12))),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedCountry = val;
                                if (val.contains('Nigeria')) _selectedCurrency = 'NGN';
                                else if (val.contains('Ghana')) _selectedCurrency = 'GHS';
                                else if (val.contains('Kenya')) _selectedCurrency = 'KES';
                                else if (val.contains('Kingdom')) _selectedCurrency = 'GBP';
                                else if (val.contains('States')) _selectedCurrency = 'USD';
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 4,
                child: _buildDarkField(
                  label: 'Payout Amount ($_selectedCurrency)',
                  hint: 'e.g. 2500',
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isProcessingPayroll ? null : _executeDisbursement,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _isProcessingPayroll
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Execute Payroll Payout', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
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
