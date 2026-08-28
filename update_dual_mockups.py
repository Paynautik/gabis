filepath = "lib/features/landing/landing_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

# 1. Update HeroSection build method to include both phone mockups side-by-side on desktop
old_hero_build = """  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: brandNavy,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 80,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final mobile = constraints.maxWidth < 850;

              if (mobile) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _heroText(context),
                    const SizedBox(height: 50),
                    const BusinessCopilotTerminal(),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: _heroText(context),
                  ),
                  const SizedBox(width: 60),
                  const Expanded(
                    child: BusinessCopilotTerminal(),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }"""

new_hero_build = """  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: brandNavy,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 80,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final mobile = constraints.maxWidth < 1100; // Adjusted breakpoint for dual devices

              if (mobile) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _heroText(context),
                    const SizedBox(height: 50),
                    const SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          BusinessCopilotTerminal(),
                          SizedBox(width: 20),
                          BusinessDashboardMockup(),
                        ],
                      ),
                    ),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 5,
                    child: _heroText(context),
                  ),
                  const SizedBox(width: 40),
                  const Expanded(
                    flex: 6,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        BusinessCopilotTerminal(),
                        SizedBox(width: 20),
                        BusinessDashboardMockup(),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }"""

content = content.replace(old_hero_build, new_hero_build)

# 2. Scale down BusinessCopilotTerminal width & height slightly to fit side-by-side (from 320x560 to 230x410)
content = content.replace(
    "        width: 320,\n        height: 560,\n        decoration: BoxDecoration(\n          color: const Color(0xFF0F172A), // Dark smartphone body bezel\n          borderRadius: BorderRadius.circular(44),\n          border: Border.all(color: const Color(0xFF334155), width: 10), // Solid hardware bezel",
    "        width: 230,\n        height: 410,\n        decoration: BoxDecoration(\n          color: const Color(0xFF0F172A), // Dark smartphone body bezel\n          borderRadius: BorderRadius.circular(30),\n          border: Border.all(color: const Color(0xFF334155), width: 6), // Solid hardware bezel"
)
# Update ClipRRect and inner padding sizes
content = content.replace(
    "        child: ClipRRect(\n          borderRadius: BorderRadius.circular(34),",
    "        child: ClipRRect(\n          borderRadius: BorderRadius.circular(24),"
)
content = content.replace("height: 32,", "height: 26,")
content = content.replace("fontSize: 11,", "fontSize: 10,")
content = content.replace("width: 70,\n                        height: 15,", "width: 50,\n                        height: 12,")
content = content.replace("padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),", "padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),")
content = content.replace("fontSize: 9.5,", "fontSize: 8.5,")
content = content.replace("padding: const EdgeInsets.all(16),", "padding: const EdgeInsets.all(12),")
content = content.replace("fontSize: 11.5,", "fontSize: 10.5,")
content = content.replace("padding: const EdgeInsets.all(12),", "padding: const EdgeInsets.all(10),")
content = content.replace("fontSize: 8.5,", "fontSize: 8.0,")

# 3. Replace the entire BusinessSection with the new interactive AI Reconciliation Simulator!
old_business_section = """// ============================================================
// BUSINESS PREVIEW
// ============================================================
class BusinessSection extends StatelessWidget {
  const BusinessSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: brandNavy,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              Column(
                children: [
                  const Text(
                    'ELUMOPAY BUSINESS',
                    style: TextStyle(color: brandCyan, fontWeight: FontWeight.w800, letterSpacing: 2, fontSize: 11),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Reconcile, manage and understand your money.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: brandText, fontSize: 36, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: const Text(
                      'Automate collections and reconciliations from multiple payment channels. Stop manually reviewing accounts.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: brandMuted, fontSize: 15, height: 1.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: brandSlate,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text(
                          'ELUMOPAY BUSINESS SUITE',
                          style: TextStyle(
                            color: brandText,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                        Spacer(),
                        Icon(
                          Icons.more_horiz,
                          color: Colors.white54,
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Wrap(
                      spacing: 15,
                      runSpacing: 15,
                      children: [
                        _metric('Total collected', '₦12.8M', '+18.4%'),
                        _metric('AI Reconciliations', '1,284 Done', '100% Health'),
                        _metric('Suggested Matches', '0 Pending', 'All cleared'),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.show_chart_rounded,
                          size: 90,
                          color: brandCyan,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metric(String title, String value, String change) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: brandMuted,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: brandText,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            change,
            style: const TextStyle(
              color: brandGreen,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}"""

new_business_section = """// ============================================================
// AI RECONCILIATION WORKFLOW SIMULATOR (BUSINESS SECTION)
// ============================================================
class BusinessSection extends StatefulWidget {
  const BusinessSection({super.key});

  @override
  State<BusinessSection> createState() => _BusinessSectionState();
}

class _BusinessSectionState extends State<BusinessSection> {
  bool _isReconciled = false;
  bool _isLoading = false;

  void _simulateReconciliation() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _isReconciled = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: brandNavy,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              Column(
                children: [
                  const Text(
                    'AI WORKFLOW SIMULATOR',
                    style: TextStyle(color: brandCyan, fontWeight: FontWeight.w800, letterSpacing: 2, fontSize: 11),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'How Elumo automates invoice reconciliation',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: brandText, fontSize: 36, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: const Text(
                      'Watch our semantic engine map inbound bank statement settlements directly to unpaid invoice drafts in real-time.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: brandMuted, fontSize: 15, height: 1.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),
              LayoutBuilder(
                builder: (context, constraints) {
                  final mobile = constraints.maxWidth < 800;
                  final contentWidgets = [
                    // Invoice Panel
                    Expanded(
                      flex: mobile ? 0 : 4,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: brandSlate,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('INV-1024', style: TextStyle(color: brandCyan, fontWeight: FontWeight.bold, fontSize: 12)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _isReconciled ? brandGreen.withValues(alpha: 0.1) : Colors.amber.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _isReconciled ? 'PAID' : 'UNPAID',
                                    style: TextStyle(color: _isReconciled ? brandGreen : Colors.amber, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text('Sarah Jenkins', style: TextStyle(color: brandText, fontWeight: FontWeight.bold, fontSize: 15)),
                            const Text('Logo Design & Brand Identity', style: TextStyle(color: brandMuted, fontSize: 12)),
                            const SizedBox(height: 20),
                            const Text('₦150,000.00', style: TextStyle(color: brandText, fontWeight: FontWeight.w950, fontSize: 18)),
                          ],
                        ),
                      ),
                    ),
                    
                    // Match Connector
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isReconciled ? Icons.verified_user_rounded : Icons.psychology_rounded,
                            color: _isReconciled ? brandGreen : brandCyan,
                            size: 32,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: brandSlate, borderRadius: BorderRadius.circular(10)),
                            child: Text(
                              _isReconciled ? '100% Match Link' : '98% Match Suggestion',
                              style: TextStyle(color: _isReconciled ? brandGreen : brandCyan, fontSize: 9.5, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Bank Statement Feed
                    Expanded(
                      flex: mobile ? 0 : 4,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: brandSlate,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('BANK FEED (Z-12)', style: TextStyle(color: brandMuted, fontWeight: FontWeight.bold, fontSize: 12)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _isReconciled ? brandGreen.withValues(alpha: 0.1) : Colors.amber.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _isReconciled ? 'LINKED' : 'UNMATCHED',
                                    style: TextStyle(color: _isReconciled ? brandGreen : Colors.amber, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text('S. JENKINS TRANSFER', style: TextStyle(color: brandText, fontWeight: FontWeight.bold, fontSize: 15)),
                            const Text('Ref: FT/2026/08/982103', style: TextStyle(color: brandMuted, fontSize: 12)),
                            const SizedBox(height: 20),
                            const Text('₦150,000.00', style: TextStyle(color: brandText, fontWeight: FontWeight.w950, fontSize: 18)),
                          ],
                        ),
                      ),
                    ),
                  ];

                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: brandSlate,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
                        ),
                        child: mobile
                            ? Column(
                                children: [
                                  contentWidgets[0], // Invoice
                                  contentWidgets[1], // Match Info
                                  contentWidgets[2], // Bank Feed
                                ],
                              )
                            : Row(
                                children: [
                                  contentWidgets[0], // Invoice
                                  contentWidgets[1], // Match Info
                                  contentWidgets[2], // Bank Feed
                                ],
                              ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _isReconciled || _isLoading ? null : _simulateReconciliation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isReconciled ? brandGreen : brandBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: _isLoading
                            ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Icon(_isReconciled ? Icons.check_circle_rounded : Icons.bolt_rounded, size: 16),
                        label: Text(
                          _isLoading
                              ? 'Running Semantic Linking...'
                              : _isReconciled
                                  ? 'Matched Successfully'
                                  : 'Simulate Gemini Link',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                        ),
                      ),
                      if (_isReconciled) ...[
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () => setState(() => _isReconciled = false),
                          child: const Text('Reset Simulator', style: TextStyle(color: brandMuted, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}"""

content = content.replace(old_business_section, new_business_section)

# 4. Append BusinessDashboardMockup widget code to the end of the file
dashboard_mockup_widget = """// ============================================================
// SECOND PHONE MOCKUP: BUSINESS DASHBOARD PREVIEW
// ============================================================
class BusinessDashboardMockup extends StatelessWidget {
  const BusinessDashboardMockup({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 230,
        height: 410,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A), // Dark smartphone body bezel
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFF334155), width: 6), // Solid hardware bezel
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10B981).withValues(alpha: 0.20), // Green glow for business portal
              blurRadius: 40,
              spreadRadius: 3,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24), // Clip to screen boundaries
          child: Container(
            color: const Color(0xFF07111F), // Screen background
            child: Column(
              children: [
                // 1. Status Bar & Dynamic Island
                Container(
                  height: 26,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  color: const Color(0xFF07111F),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '09:41',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                      // Mock Dynamic Island
                      Container(
                        width: 50,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const Row(
                        children: [
                          Icon(Icons.signal_cellular_alt_rounded, color: Colors.white, size: 10),
                          SizedBox(width: 4),
                          Icon(Icons.wifi, color: Colors.white, size: 10),
                          SizedBox(width: 4),
                          Icon(Icons.battery_5_bar_rounded, color: Colors.white, size: 10),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // 2. Terminal Header / App bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(color: Color(0xFF22D3EE), shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'ELUMO BUSINESS',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.verified_user_rounded, color: Color(0xFF10B981), size: 12),
                    ],
                  ),
                ),
                
                // 3. Mini Dashboard Panels
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Metric 1: Total Collected
                        _miniMetricBox(
                          title: 'Total Collected',
                          value: '₦12.8M',
                          change: '+18.4% growth',
                          color: const Color(0xFF10B981),
                        ),
                        const SizedBox(height: 10),
                        
                        // Metric 2: AI Reconciled Invoices
                        _miniMetricBox(
                          title: 'AI Reconciliations',
                          value: '1,284 Done',
                          change: '100% health',
                          color: const Color(0xFF22D3EE),
                        ),
                        const SizedBox(height: 10),
                        
                        // Metric 3: Suggested Matches
                        _miniMetricBox(
                          title: 'Suggested Matches',
                          value: '0 Pending',
                          change: 'All cleared',
                          color: const Color(0xFFFBBF24),
                        ),
                        const SizedBox(height: 12),
                        
                        // Mini Bar Graph Graphic representing weekly trends
                        const Text('WEEKLY ACTIVITY', style: TextStyle(color: Colors.white54, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                        const SizedBox(height: 8),
                        Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _bar(12),
                              _bar(25),
                              _bar(18),
                              _bar(32),
                              _bar(45),
                              _bar(30),
                              _bar(48),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // 4. Home Swipe Indicator
                Container(
                  width: 80,
                  height: 3,
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _miniMetricBox({
    required String title,
    required String value,
    required String change,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.white64, fontSize: 8, fontWeight: FontWeight.bold)),
              Container(width: 4, height: 4, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w950)),
          const SizedBox(height: 2),
          Text(change, style: TextStyle(color: color, fontSize: 7.5, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _bar(double height) {
    return Container(
      width: 12,
      height: height,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF22D3EE), Color(0xFF2563EB)],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
"""

content = content + "\n\n" + dashboard_mockup_widget

with open(filepath, 'w') as f:
    f.write(content)

print("Dual phone mockups and Simulator update completed.")
