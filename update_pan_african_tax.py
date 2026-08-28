filepath = "lib/features/business/business_dashboard_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

# 1. Add _selectedTaxCountry to the class variables
content = content.replace(
    "  bool _isRemittingTax = false;",
    "  bool _isRemittingTax = false;\n  String _selectedTaxCountry = 'Nigeria 🇳🇬';"
)

# 2. Overwrite the _recalculateTax, _executeFirsRemittance, _buildTaxComplianceTab, and helper methods with dynamic pan-African versions
pan_african_tax_code = """
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
"""

# Let's replace our previously injected Nigeria-only tax hub with this pan-African dynamic one!
# We search for:
#   // ============================================================
#   // TAB 4: TAX & FIRS COMPLIANCE HUB
#   // ============================================================
# Up to the start of TAB 4: DEVELOPER & SEMANTIC SEARCH

start_tag = "  // ============================================================\n  // TAB 4: TAX & FIRS COMPLIANCE HUB\n  // ============================================================"
end_tag = "  // ============================================================\n  // TAB 4: DEVELOPER & SEMANTIC SEARCH"

start_idx = content.find(start_tag)
end_idx = content.find(end_tag)

if start_idx != -1 and end_idx != -1:
    content = content[:start_idx] + pan_african_tax_code + "\n\n" + content[end_idx:]

with open(filepath, 'w') as f:
    f.write(content)

print("Pan-African Tax compliance hub integrated successfully.")
