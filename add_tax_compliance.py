filepath = "lib/features/business/business_dashboard_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

# 1. Update TabController length from 4 to 5
content = content.replace(
    "_tabController = TabController(length: 4, vsync: this);",
    "_tabController = TabController(length: 5, vsync: this);"
)

# 2. Add Tax Calculator states to class variables
tax_states = """  late TabController _tabController;

  // Tax Calculator state
  final _taxAmountController = TextEditingController(text: '500000');
  String _selectedServiceType = 'Consulting / Professional Services (5% WHT)';
  double _calculatedVat = 37500.0;
  double _calculatedWht = 25000.0;
  double _calculatedNet = 475000.0;
  bool _isRemittingTax = false;"""

content = content.replace("  late TabController _tabController;", tax_states)

# 3. Add Tax tab to TabBar bottom
old_tabs = """          tabs: const [
            Tab(text: 'Overview & Forecast'),
            Tab(text: 'AI Reconciliation'),
            Tab(text: 'Invoicing & Payroll'),
            Tab(text: 'Developer & Search'),
          ],"""

new_tabs = """          tabs: const [
            Tab(text: 'Overview & Forecast'),
            Tab(text: 'AI Reconciliation'),
            Tab(text: 'Invoicing & Payroll'),
            Tab(text: 'Tax & Compliance'),
            Tab(text: 'Developer & Search'),
          ],"""

content = content.replace(old_tabs, new_tabs)

# 4. Add Tax tab view to TabBarView children
old_tabviews = """      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(isDesktop),
          _buildReconciliationTab(),
          _buildInvoicingPayrollTab(isDesktop),
          _buildDeveloperTab(isDesktop),
        ],
      ),"""

new_tabviews = """      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(isDesktop),
          _buildReconciliationTab(),
          _buildInvoicingPayrollTab(isDesktop),
          _buildTaxComplianceTab(isDesktop),
          _buildDeveloperTab(isDesktop),
        ],
      ),"""

content = content.replace(old_tabviews, new_tabviews)

# 5. Define _buildTaxComplianceTab method and calculateTax helper inside state class
tax_method_code = """
  // ============================================================
  // TAB 4: TAX & FIRS COMPLIANCE HUB
  // ============================================================
  void _recalculateTax(String val) {
    final amt = double.tryParse(val.replaceAll(',', '').trim()) ?? 0.0;
    double whtPercent = 0.05; // Default Consulting
    if (_selectedServiceType.contains('10%')) {
      whtPercent = 0.10;
    } else if (_selectedServiceType.contains('2.5%')) {
      whtPercent = 0.025;
    }

    setState(() {
      _calculatedVat = amt * 0.075; // Standard Nigerian VAT is 7.5%
      _calculatedWht = amt * whtPercent;
      _calculatedNet = amt - _calculatedWht;
    });
  }

  void _executeFirsRemittance() async {
    setState(() => _isRemittingTax = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _isRemittingTax = false);

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
            const Text('FIRS Remitted', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Tax remittance payment successfully processed. FIRS e-receipt generated and logged under certificate clearance ledger. Ref: FIRS-TX-9082A.',
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5, height: 1.4),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // FIRS Overview Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
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
                      const Text('FIRS Tax Compliance Score: 98%', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(
                        'Your business is fully compliant with Nigeria\\'s Finance Act tax amendments. Next Tax Clearance Certificate (TCC) review: January 2027.',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12, height: 1.35),
                      ),
                    ],
                  ),
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
              Icon(Icons.calculate_rounded, color: Color(0xFF22D3EE), size: 20),
              SizedBox(width: 8),
              Text('FIRS WHT & VAT Calculator', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Calculate mandatory Withholding Tax (WHT) and Value Added Tax (VAT) deductions under current Nigerian tax laws.',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.35),
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
                items: const [
                  DropdownMenuItem(
                    value: 'Consulting / Professional Services (5% WHT)',
                    child: Text('Consulting Services (5% WHT)', style: TextStyle(color: Colors.white, fontSize: 12.5)),
                  ),
                  DropdownMenuItem(
                    value: 'Corporate Supplies / Goods (2.5% WHT)',
                    child: Text('Supplies of Goods (2.5% WHT)', style: TextStyle(color: Colors.white, fontSize: 12.5)),
                  ),
                  DropdownMenuItem(
                    value: 'Construction / Building Contracts (10% WHT)',
                    child: Text('Construction Contracts (10% WHT)', style: TextStyle(color: Colors.white, fontSize: 12.5)),
                  ),
                ],
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
            label: 'Invoice Gross Amount (NGN)',
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
                _taxRow('VAT Collected (7.5%)', '₦' + _calculatedVat.toStringAsFixed(2), const Color(0xFF10B981)),
                const SizedBox(height: 8),
                _taxRow('WHT Deducted', '₦' + _calculatedWht.toStringAsFixed(2), const Color(0xFFFBBF24)),
                const Divider(color: Colors.white10, height: 24),
                _taxRow('Net Invoice Payable', '₦' + _calculatedNet.toStringAsFixed(2), const Color(0xFF22D3EE), isBold: true),
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
          const Text('Auto-Deducted Tax Records', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text(
            'FIRS-compliant audit ledger showing VAT collections and WHT certificates associated with client transfers.',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 11.5, height: 1.35),
          ),
          const SizedBox(height: 20),
          
          _taxLedgerRow('Acme Ltd (Database Migration)', '₦2.5M gross', 'WHT Deducted: ₦125,000 (5%)', 'VAT: ₦187,500'),
          const Divider(color: Colors.white10),
          _taxLedgerRow('Sarah Designs (Logo Design)', '₦150k gross', 'WHT Deducted: ₦7,500 (5%)', 'VAT: ₦11,250'),
          const Divider(color: Colors.white10),
          _taxLedgerRow('Access Bank Supplier payout', '₦1.2M gross', 'WHT Withheld: ₦60,000 (5%)', 'VAT Exempted'),
          
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
              label: const Text('Remit Pending Taxes to FIRS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
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
"""

content = content.replace(
    "  // ============================================================\n  // TAB 4: DEVELOPER & SEMANTIC SEARCH",
    tax_method_code + "\n\n  // ============================================================\n  // TAB 4: DEVELOPER & SEMANTIC SEARCH"
)

with open(filepath, 'w') as f:
    f.write(content)

print("Tax Compliance Hub added successfully.")
