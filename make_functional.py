import re

filepath = "lib/features/home/home_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

# 1. Add _isBalanceHidden state
state_pattern = r"class _HomeScreenState extends ConsumerState<HomeScreen> \{\n  String _selectedPeriod = '7D';\n  bool _showPromoBanner = true;\n  bool _showSecurityBanner = true;"
new_state = """class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedPeriod = '7D';
  bool _showPromoBanner = true;
  bool _showSecurityBanner = true;
  bool _isBalanceHidden = false;"""
content = re.sub(state_pattern, new_state, content)

# 2. Rewrite _buildNetWorthCard
net_worth_pattern = r"  Widget _buildNetWorthCard\(Money balance\) \{.*?\n  \}\n\n  // --- Accounts Section ---"
new_net_worth = """  Widget _buildNetWorthCard(Money balance) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF00B876), // Vibrant Fintech Green
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00B876).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Shield + Available Balance + Eye + History
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => setState(() => _isBalanceHidden = !_isBalanceHidden),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    const Icon(Icons.verified_user_rounded, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    const Text('Available Balance', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Icon(_isBalanceHidden ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.white, size: 16),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => showComingSoon(context, 'Transaction History'),
                child: Row(
                  children: const [
                    Text('Transaction History', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                    SizedBox(width: 2),
                    Icon(Icons.chevron_right_rounded, color: Colors.white, size: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Middle Row: Big Balance + Add Money Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => setState(() => _isBalanceHidden = !_isBalanceHidden),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _isBalanceHidden ? '****' : balance.format(),
                      style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1.0),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 24),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _showAddMoneySheet(context, ref),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                  child: const Text('+ Add Money', style: TextStyle(color: Color(0xFF00B876), fontWeight: FontWeight.w900, fontSize: 13)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Bottom Strip (Business Service)
          GestureDetector(
            onTap: () => _showBusinessInsights(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.storefront_rounded, color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      const Text("Business Service - Today's Sales: ", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                      Text(_isBalanceHidden ? '****' : '₦0.00', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Accounts Section ---"""
content = re.sub(net_worth_pattern, new_net_worth, content, flags=re.DOTALL)

# 3. Add _showBusinessInsights method right after _showAddMoneySheet
business_insights_method = """  void _showBusinessInsights(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: const Color(0xFF00B876).withValues(alpha: 0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.storefront_rounded, color: Color(0xFF00B876)),
                  ),
                  const SizedBox(width: 12),
                  const Text('Business Insights', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF101828))),
                ],
              ),
              const SizedBox(height: 24),
              const Text("Today's Sales", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF667085))),
              const SizedBox(height: 8),
              const Text('₦0.00', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF101828))),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Transactions', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF667085))),
                          SizedBox(height: 4),
                          Text('0', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF101828))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Customers', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF667085))),
                          SizedBox(height: 4),
                          Text('0', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF101828))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B876),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Manage Business', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
"""

# Find a good place to insert _showBusinessInsights (before the last closing brace)
content = re.sub(r"\}\n$", business_insights_method + "\n}", content)

with open(filepath, 'w') as f:
    f.write(content)
