filepath = "lib/features/landing/landing_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

# Locate BusinessCopilotTerminal widget and replace it with our beautiful smartphone mockup version
start_idx = content.find("class BusinessCopilotTerminal extends StatefulWidget {")
if start_idx != -1:
    content = content[:start_idx]

# Define the new BusinessCopilotTerminal class with a premium modern phone mockup container!
new_widget_code = """class BusinessCopilotTerminal extends StatefulWidget {
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
    return Center(
      child: Container(
        width: 320,
        height: 560,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A), // Dark smartphone body bezel
          borderRadius: BorderRadius.circular(44),
          border: Border.all(color: const Color(0xFF334155), width: 10), // Solid hardware bezel
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2563EB).withValues(alpha: 0.25),
              blurRadius: 40,
              spreadRadius: 5,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(34), // Clip to screen boundaries
          child: Container(
            color: const Color(0xFF07111F), // Screen background
            child: Column(
              children: [
                // 1. Status Bar & Dynamic Island
                Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  color: const Color(0xFF07111F),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '09:41',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      // Mock Dynamic Island
                      Container(
                        width: 70,
                        height: 15,
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'ELUMO COPILOT',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.psychology_rounded, color: Color(0xFF22D3EE), size: 14),
                    ],
                  ),
                ),
                
                // 3. Chat Messages logs
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, idx) {
                      final msg = _messages[idx];
                      final isAi = msg['sender'] == 'ai';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: isAi ? const Color(0xFF2563EB) : Colors.white24,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isAi ? Icons.psychology_rounded : Icons.person_rounded,
                                color: Colors.white,
                                size: 11,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isAi ? Colors.white.withValues(alpha: 0.04) : Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isAi ? Colors.white.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.12),
                                  ),
                                ),
                                child: Text(
                                  msg['text'] ?? '',
                                  style: TextStyle(
                                    color: isAi ? const Color(0xFFE2E8F0) : Colors.white,
                                    fontSize: 11.5,
                                    height: 1.4,
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 10,
                          height: 10,
                          child: CircularProgressIndicator(strokeWidth: 1.0, color: Color(0xFF2563EB)),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Thinking...',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),

                // 4. Copilot Prompt Choices
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.02),
                    border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.06))),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ASK ELUMO:',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 8.5, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                      ),
                      const SizedBox(height: 6),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _queryChip(
                              label: "Who hasn't paid?",
                              query: "Who hasn't paid?",
                              response: "Outstanding invoices (₦2.8M total):\\n- **Sarah Designs:** ₦150k (34d overdue)\\n- **Emma Watson:** ₦90k (31d overdue)\\n\\n[Send reminder link]",
                            ),
                            const SizedBox(width: 6),
                            _queryChip(
                              label: "Reconciliation review",
                              query: "Reconciliation review",
                              response: "Reconciliation health: **100%**\\n\\nGemini matched INV-1024 with a bank transfer from S. Jenkins automatically.",
                            ),
                            const SizedBox(width: 6),
                            _queryChip(
                              label: "Cash-flow projection",
                              query: "Cash-flow projection",
                              response: "Expected cash in 30 days: **₦14.2M**\\n\\nBased on outstanding invoices + seasonal revenue patterns.",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 5. Home Swipe Indicator
                Container(
                  width: 100,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 8),
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

  Widget _queryChip({required String label, required String query, required String response}) {
    return ActionChip(
      backgroundColor: Colors.white.withValues(alpha: 0.06),
      side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      padding: const EdgeInsets.all(4),
      label: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
      onPressed: () => _askQuestion(query, response),
    );
  }
}
"""

content = content + "\n\n" + new_widget_code

with open(filepath, 'w') as f:
    f.write(content)

print("Mockup widget update successful.")
