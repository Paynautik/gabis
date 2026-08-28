filepath = "lib/features/home/home_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

# 1. Add _buildBusinessInsightsCard call to build method
content = content.replace(
"""                    // ================= STANDALONE SECURITY BANNER =================
                    if (_showSecurityBanner) ...[
                      _buildRealSecurityBanner(),
                      const SizedBox(height: 24),
                    ],""",
"""                    // ================= STANDALONE SECURITY BANNER =================
                    if (_showSecurityBanner) ...[
                      _buildRealSecurityBanner(),
                      const SizedBox(height: 24),
                    ],
                    
                    // ================= BUSINESS INSIGHTS GATEWAY =================
                    _buildBusinessInsightsCard(context),
                    const SizedBox(height: 24),"""
)

# 2. Inject _buildBusinessInsightsCard definition before _buildRealSecurityBanner definition
insights_card_method = """  // --- Business Insights Gateway Card ---
  Widget _buildBusinessInsightsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.bgSoft,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: context.colors.border, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Icon + Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFE6F7F0), // Teal/green highlight
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  color: Color(0xFF00B97A), // Official Business Green
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Business Insights',
                style: TextStyle(
                  color: context.colors.ink,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Label: Today's Sales
          Text(
            "Today's Sales",
            style: TextStyle(
              color: context.colors.inkSoft,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),

          // Value: ₦0.00
          Text(
            "₦0.00",
            style: TextStyle(
              color: context.colors.ink,
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 20),

          // Grid: Transactions & Customers
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: context.colors.scaffoldBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.colors.border.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transactions',
                        style: TextStyle(
                          color: context.colors.inkSoft,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '0',
                        style: TextStyle(
                          color: context.colors.ink,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: context.colors.scaffoldBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.colors.border.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customers',
                        style: TextStyle(
                          color: context.colors.inkSoft,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '0',
                        style: TextStyle(
                          color: context.colors.ink,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Button: Manage Business
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                ref.read(isBusinessModeProvider.notifier).state = true;
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00B97A), // Shop Green
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Manage Business',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }"""

content = content.replace("  Widget _buildRealSecurityBanner()", insights_card_method + "\n\n  Widget _buildRealSecurityBanner()")

with open(filepath, 'w') as f:
    f.write(content)

print("Insights card injected successfully.")
