filepath = "lib/features/business/business_dashboard_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

# 1. Add state variables for the dynamic overview tab inside the class variables area
content = content.replace(
    "  String _selectedTaxCountry = 'Nigeria 🇳🇬';",
    "  String _selectedTaxCountry = 'Nigeria 🇳🇬';\n  String _overviewPeriod = 'This Month';\n  double _seasonalFactor = 12.0;\n  double _simulatedForecast = 14250000.0;"
)

# 2. Overwrite the _buildOverviewTab, _buildMetricsGrid, and _buildForecasterCard methods with dynamic versions
dynamic_overview_code = """
  // ============================================================
  // TAB 1: DYNAMIC OVERVIEW & AI FORECASTING
  // ============================================================
  Widget _buildOverviewTab(bool isDesktop) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period Selector Filter Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Financial Console',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                children: ['Today', 'This Week', 'This Month', 'This Year'].map((String p) {
                  final active = _overviewPeriod == p;
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ChoiceChip(
                      label: Text(p, style: TextStyle(color: active ? Colors.black : Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                      selected: active,
                      selectedColor: const Color(0xFF22D3EE),
                      backgroundColor: const Color(0xFF1E293B),
                      onSelected: (val) {
                        if (val) {
                          setState(() {
                            _overviewPeriod = p;
                            _updatePeriodValues();
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          _buildMetricsGrid(),
          const SizedBox(height: 24),
          
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: _buildForecasterCard()),
                const SizedBox(width: 24),
                Expanded(flex: 4, child: Column(
                  children: [
                    _buildInsightsSummaryCard(),
                    const SizedBox(height: 24),
                    _buildOverviewActivityChart(),
                  ],
                )),
              ],
            )
          else ...[
            _buildForecasterCard(),
            const SizedBox(height: 24),
            _buildInsightsSummaryCard(),
            const SizedBox(height: 24),
            _buildOverviewActivityChart(),
          ],
        ],
      ),
    );
  }

  double _totalCollectedValue = 12840250.0;
  int _reconciledMatchesValue = 1284;
  int _unreconciledInvoicesValue = 2;

  void _updatePeriodValues() {
    if (_overviewPeriod == 'Today') {
      _totalCollectedValue = 480000.0;
      _reconciledMatchesValue = 48;
      _unreconciledInvoicesValue = 0;
    } else if (_overviewPeriod == 'This Week') {
      _totalCollectedValue = 3150000.0;
      _reconciledMatchesValue = 312;
      _unreconciledInvoicesValue = 1;
    } else if (_overviewPeriod == 'This Month') {
      _totalCollectedValue = 12840250.0;
      _reconciledMatchesValue = 1284;
      _unreconciledInvoicesValue = 2;
    } else if (_overviewPeriod == 'This Year') {
      _totalCollectedValue = 148200000.0;
      _reconciledMatchesValue = 14820;
      _unreconciledInvoicesValue = 8;
    }
    _recalculateForecast();
  }

  void _recalculateForecast() {
    // Forecast model: Collected + Outstanding * (1 + factor)
    double outstandingBase = 2100000.0;
    if (_overviewPeriod == 'Today') outstandingBase = 120000.0;
    else if (_overviewPeriod == 'This Week') outstandingBase = 450000.0;
    else if (_overviewPeriod == 'This Year') outstandingBase = 18000000.0;

    setState(() {
      _simulatedForecast = _totalCollectedValue + (outstandingBase * (1.0 + _seasonalFactor / 100.0));
    });
  }

  Widget _buildMetricsGrid() {
    String changeText = '+18.4% vs July';
    if (_overviewPeriod == 'Today') changeText = '+8.5% vs Yesterday';
    else if (_overviewPeriod == 'This Week') changeText = '+12.1% vs Last Week';
    else if (_overviewPeriod == 'This Year') changeText = '+28.4% YoY Growth';

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildMetricBox(
          title: 'Total Collected',
          value: '₦' + _formatMoney(_totalCollectedValue),
          change: changeText,
          icon: Icons.trending_up_rounded,
          color: const Color(0xFF10B981),
        ),
        _buildMetricBox(
          title: 'AI Reconciled Matches',
          value: '$_reconciledMatchesValue Matches',
          change: 'Reconciliation Health: 100%',
          icon: Icons.verified_user_rounded,
          color: const Color(0xFF22D3EE),
        ),
        _buildMetricBox(
          title: 'Unreconciled Invoices',
          value: '$_unreconciledInvoicesValue pending',
          change: _unreconciledInvoicesValue > 0 ? 'Action Required' : 'All Clear',
          icon: Icons.warning_amber_rounded,
          color: _unreconciledInvoicesValue > 0 ? const Color(0xFFFBBF24) : const Color(0xFF10B981),
        ),
      ],
    );
  }

  String _formatMoney(double val) {
    if (val >= 1000000) {
      return (val / 1000000).toStringAsFixed(2) + 'M';
    } else if (val >= 1000) {
      return (val / 1000).toStringAsFixed(0) + 'K';
    }
    return val.toStringAsFixed(0);
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
              Text('AI Cash-Flow Forecasting Simulator', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Expected cash position in 30 days based on historic patterns, outstanding receivables, and custom seasonal factors.',
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
                  Text('₦' + _formatMoney(_totalCollectedValue), style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const Icon(Icons.arrow_forward_rounded, color: Color(0xFF22D3EE), size: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('ELUMO 30-DAY FORECAST', style: TextStyle(color: Color(0xFF22D3EE), fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('₦' + _formatMoney(_simulatedForecast), style: const TextStyle(color: Color(0xFF22D3EE), fontSize: 22, fontWeight: FontWeight.w900)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Seasonal Booster Simulator Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Seasonal Sales Booster Impact:', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
              Text('${_seasonalFactor.toStringAsFixed(0)}% boost', style: const TextStyle(color: Color(0xFF22D3EE), fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          Slider(
            value: _seasonalFactor,
            min: 0.0,
            max: 50.0,
            divisions: 10,
            activeColor: const Color(0xFF22D3EE),
            inactiveColor: Colors.white.withValues(alpha: 0.08),
            onChanged: (val) {
              setState(() {
                _seasonalFactor = val;
                _recalculateForecast();
              });
            },
          ),
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Gemini Prediction Factors:', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                _predictionRow('Outstanding invoice collections estimated.', true),
                const SizedBox(height: 6),
                _predictionRow('Scheduled payroll expenses locked.', true),
                const SizedBox(height: 6),
                _predictionRow('Seasonal sales booster model activated.', _seasonalFactor > 0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _predictionRow(String label, bool active) {
    return Row(
      children: [
        Icon(
          active ? Icons.check_circle_rounded : Icons.circle_outlined,
          color: active ? const Color(0xFF10B981) : const Color(0xFF475569),
          size: 14,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: active ? const Color(0xFF94A3B8) : const Color(0xFF475569),
            fontSize: 11.5,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewActivityChart() {
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
          const Text('Weekly Sales Performance', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _barColumn('Mon', 45, const Color(0xFF22D3EE)),
                _barColumn('Tue', 70, const Color(0xFF22D3EE)),
                _barColumn('Wed', 55, const Color(0xFF22D3EE)),
                _barColumn('Thu', 85, const Color(0xFF22D3EE)),
                _barColumn('Fri', 100, const Color(0xFF10B981)),
                _barColumn('Sat', 90, const Color(0xFF22D3EE)),
                _barColumn('Sun', 60, const Color(0xFF22D3EE)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _barColumn(String label, double heightPercent, Color barColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          width: 24,
          height: heightPercent,
          decoration: BoxDecoration(
            color: barColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }
"""

# Let's replace _buildOverviewTab, _buildMetricsGrid, _buildMetricBox, _buildForecasterCard inside the file
# We search for:
#   Widget _buildOverviewTab(bool isDesktop) {
# Up to the start of Widget _buildInsightsSummaryCard()

start_tag = "  Widget _buildOverviewTab(bool isDesktop) {"
end_tag = "  Widget _buildInsightsSummaryCard() {"

start_idx = content.find(start_tag)
end_idx = content.find(end_tag)

if start_idx != -1 and end_idx != -1:
    content = content[:start_idx] + dynamic_overview_code + "\n\n  " + content[end_idx:]

with open(filepath, 'w') as f:
    f.write(content)

print("Overview tab has been made dynamic with charts and simulators.")
