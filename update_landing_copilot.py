filepath = "lib/features/landing/landing_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

# 1. Update Hero Text (Heading and Subheading)
old_hero_texts = """        const SizedBox(height: 25),
        const Text(
          'Move money.\nBuild business.\nGo further.',
          style: TextStyle(
            fontSize: 56,
            height: 1.05,
            fontWeight: FontWeight.w900,
            color: navy,
          ),
        ),
        const SizedBox(height: 25),
        const Text(
          'Payments and financial tools designed '
          'for the way Africa moves money.',
          style: TextStyle(
            fontSize: 18,
            height: 1.6,
            color: muted,
          ),
        ),"""

new_hero_texts = """        const SizedBox(height: 25),
        const Text(
          'Your business has the data.\\nElumo gives it intelligence.',
          style: TextStyle(
            fontSize: 48,
            height: 1.1,
            fontWeight: FontWeight.w900,
            color: navy,
            letterSpacing: -1.0,
          ),
        ),
        const SizedBox(height: 25),
        const Text(
          'ElumoPay is an AI-powered financial operating system helping African businesses collect, reconcile and understand their money.',
          style: TextStyle(
            fontSize: 18,
            height: 1.6,
            color: muted,
          ),
        ),"""

content = content.replace(old_hero_texts, new_hero_texts)

# 2. Swap CTA Buttons
old_ctas = """            FilledButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              style: FilledButton.styleFrom(
                backgroundColor: blue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 18,
                ),
              ),
              child: const Text('Get started', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 18,
                ),
              ),
              child: const Text('Explore ElumoPay', style: TextStyle(fontWeight: FontWeight.bold)),
            ),"""

new_ctas = """            FilledButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              style: FilledButton.styleFrom(
                backgroundColor: blue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 18,
                ),
              ),
              child: const Text('Get started', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            OutlinedButton.icon(
              onPressed: () {
                // Focus on Copilot simulation
              },
              icon: const Icon(Icons.psychology_rounded, size: 18),
              label: const Text('Try Elumo Copilot', style: TextStyle(fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 18,
                ),
              ),
            ),"""

content = content.replace(old_ctas, new_ctas)

# 3. Swap PaymentNetwork in HeroSection layout with BusinessCopilotTerminal
content = content.replace("const PaymentNetwork(),", "const BusinessCopilotTerminal(),")
content = content.replace("const Expanded(\n                    child: PaymentNetwork(),\n                  ),", "const Expanded(\n                    child: BusinessCopilotTerminal(),\n                  ),")

# 4. Inject BusinessCopilotTerminal definition
copilot_terminal_widget = """// ============================================================
// INTERACTIVE ELUMO BUSINESS COPILOT WIDGET
// ============================================================
class BusinessCopilotTerminal extends StatefulWidget {
  const BusinessCopilotTerminal({super.key});

  @override
  State<BusinessCopilotTerminal> createState() => _BusinessCopilotTerminalState();
}

class _BusinessCopilotTerminalState extends State<BusinessCopilotTerminal> {
  final List<Map<String, String>> _messages = [
    {
      'sender': 'ai',
      'text': 'Good morning, Raphael 👋\\nYour business received ₦12.8M this month (+18.4% vs July).\\n\\n💡 **Elumo Intelligence:** Collections are strong, but outstanding invoices grew by 31%. You have ₦640K in pending payments.'
    }
  ];
  bool _isThinking = false;

  void _askQuestion(String query, String response) async {
    if (_isThinking) return;
    setState(() {
      _messages.add({'sender': 'user', 'text': query});
      _isThinking = true;
    });

    await Future.delayed(const Duration(milliseconds: 1000));

    if (!mounted) return;
    setState(() {
      _isThinking = false;
      _messages.add({'sender': 'ai', 'text': response});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 480,
      decoration: BoxDecoration(
        color: const Color(0xFF07111F),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.15),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                ),
                const SizedBox(width: 10),
                const Text(
                  'ELUMO BUSINESS COPILOT',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.terminal_rounded, color: Colors.white38, size: 16),
              ],
            ),
          ),
          
          // Chat logs
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length,
              itemBuilder: (context, idx) {
                final msg = _messages[idx];
                final isAi = msg['sender'] == 'ai';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isAi ? const Color(0xFF2563EB) : Colors.white24,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isAi ? Icons.psychology_rounded : Icons.person_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isAi ? Colors.white.withValues(alpha: 0.04) : Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isAi ? Colors.white.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                          child: Text(
                            msg['text'] ?? '',
                            style: TextStyle(
                              color: isAi ? const Color(0xFFE2E8F0) : Colors.white,
                              fontSize: 12.5,
                              height: 1.45,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          if (_isThinking)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 1.5, color: Color(0xFF2563EB)),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Elumo Copilot is thinking...',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),

          // Action choices
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
              border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ASK ELUMO:',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 9.5, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _queryChip(
                        label: "Which customers haven't paid?",
                        query: "Which customers haven't paid?",
                        response: "You have 14 outstanding invoices worth ₦2.8M.\\n\\n🔴 **Overdue Top Balances:**\\n- Sarah Designs: ₦150,000 (34 days overdue)\\n- Emma Watson: ₦90,000 (31 days overdue)\\n\\n[Send reminder link] [View invoices]",
                      ),
                      const SizedBox(width: 8),
                      _queryChip(
                        label: "Explain recent cash-flow forecasts",
                        query: "Explain recent cash-flow forecasts",
                        response: "📊 **Elumo Cash-Flow Forecast**\\nExpected cash position in 30 days: **₦14.2M**\\n\\nEstimates calculated based on:\\n✓ Verified payroll recurrences (₦1.4M scheduled expense)\\n✓ Unpaid invoices expected collections (₦2.1M high probability)\\n✓ Historic seasonal trend (+12% average revenue boost in September)",
                      ),
                      const SizedBox(width: 8),
                      _queryChip(
                        label: "Show transactions above ₦500,000",
                        query: "Show transactions above ₦500,000",
                        response: "🔎 **Filtered Transactions (>₦500,000):**\\n\\n1. **Acme Ltd** • ₦850,000 (Bank Transfer - Reconciled)\\n2. **Sarah Designs** • ₦600,000 (Invoice #109 - *Unreconciled*)\\n3. **Zenith Bank Payout** • ₦1,200,000 (Vendor Payment - Successful)",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _queryChip({required String label, required String query, required String response}) {
    return ActionChip(
      backgroundColor: Colors.white.withValues(alpha: 0.08),
      side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
      label: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
      onPressed: () => _askQuestion(query, response),
    );
  }
}
"""

content = content + "\n\n" + copilot_terminal_widget

with open(filepath, 'w') as f:
    f.write(content)

print("Landing page repositioning completed.")
