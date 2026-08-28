filepath = "lib/features/landing/landing_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

# 1. Add const VoiceReminderSection() inside LandingScreen column children list
content = content.replace(
    "          children: [\n            const Navbar(),\n            const HeroSection(),\n            const MerchantSpotlightSection(),\n            const ProductShowcaseSection(),\n            const BusinessSection(),\n            const DeveloperSection(),",
    "          children: [\n            const Navbar(),\n            const HeroSection(),\n            const MerchantSpotlightSection(),\n            const ProductShowcaseSection(),\n            const BusinessSection(),\n            const VoiceReminderSection(),\n            const DeveloperSection(),"
)

# 2. Add the VoiceReminderSection StatefulWidget definition to the end of the file
voice_reminder_section_code = """
// ============================================================
// AUTOMATED AI VOICE REMINDERS / ROBOT CALLS MARKETING BLOCK
// ============================================================
class VoiceReminderSection extends StatefulWidget {
  const VoiceReminderSection({super.key});

  @override
  State<VoiceReminderSection> createState() => _VoiceReminderSectionState();
}

class _VoiceReminderSectionState extends State<VoiceReminderSection> {
  int _callProgress = 0; // 0: Idle, 1: Calling, 2: Ringing, 3: Answered & Reciting, 4: Finished/Recovered
  bool _isPlaying = false;

  void _triggerSimulatedCall() async {
    setState(() {
      _callProgress = 1;
      _isPlaying = true;
    });
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _callProgress = 2);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _callProgress = 3);
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    setState(() => _callProgress = 4);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _callProgress = 0;
      _isPlaying = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 90),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final mobile = constraints.maxWidth < 850;

              final textContent = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: brandBlue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.phone_in_talk_rounded, color: brandBlue, size: 13),
                        SizedBox(width: 6),
                        Text(
                          'AUTOMATED DEBT RECOVERY',
                          style: TextStyle(color: brandBlue, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Get paid.\\nWithout the chase.",
                    style: TextStyle(color: brandText, fontSize: 36, fontWeight: FontWeight.w900, height: 1.15),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "With ElumoPay, you don't have to chase customers for payments. We automatically reconcile your income, track outstanding balances, and send timely robot calls on your behalf—helping you spend less time following up on debt and more time running your business.",
                    style: TextStyle(color: brandMuted, fontSize: 15, height: 1.55),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "For overdue installments, our system places friendly, automated voice reminders to customers, guiding them to payment channels professionally and consistently.",
                    style: TextStyle(color: brandMuted, fontSize: 14, height: 1.55),
                  ),
                ],
              );

              final callSimulator = Container(
                width: mobile ? double.infinity : 380,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: brandSlate,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.circle, color: brandGreen, size: 8),
                            SizedBox(width: 8),
                            Text('ELUMO CALL ENGINE', style: TextStyle(color: brandMuted, fontSize: 9.5, fontWeight: FontWeight.w800)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _isPlaying ? Colors.redAccent.withValues(alpha: 0.1) : Colors.black12,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _isPlaying ? 'ACTIVE CALL' : 'IDLE',
                            style: TextStyle(
                              color: _isPlaying ? Colors.redAccent : brandMuted,
                              fontSize: 8.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.black12, height: 24),
                    const SizedBox(height: 10),
                    
                    // Call Status Animation Screen
                    if (_callProgress == 0) ...[
                      const Icon(Icons.phone_disabled_rounded, color: brandMuted, size: 48),
                      const SizedBox(height: 16),
                      const Text('Ready to Simulate Call', style: TextStyle(color: brandText, fontWeight: FontWeight.bold, fontSize: 15)),
                      const Text('Target debtor: Sarah Okafor (₦50,000)', style: TextStyle(color: brandMuted, fontSize: 12)),
                    ] else ...[
                      // Pulsing Call Indicator
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 0.9, end: 1.1),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeInOut,
                        builder: (context, scale, child) {
                          return Transform.scale(scale: _callProgress == 4 ? 1.0 : scale, child: child);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: _callProgress == 4 ? const Color(0xFFE6F7F0) : const Color(0xFFFFF6E6),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _callProgress == 4 ? Icons.check_circle_rounded : Icons.phone_in_talk_rounded,
                            color: _callProgress == 4 ? brandGreen : Colors.orangeAccent,
                            size: 32,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _callProgress == 1
                            ? 'Dialing Sarah Okafor...'
                            : _callProgress == 2
                                ? 'Ringing...'
                                : _callProgress == 3
                                    ? 'Customer Answered'
                                    : 'Call Completed',
                        style: const TextStyle(color: brandText, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _callProgress == 3
                            ? '"Hello Sarah, friendly installment reminder..."'
                            : _callProgress == 4
                                ? '₦50,000 Recovered Successfully'
                                : 'Connecting call...',
                        style: TextStyle(
                          color: _callProgress == 4 ? brandGreen : brandMuted,
                          fontSize: 12,
                          fontStyle: _callProgress == 3 ? FontStyle.italic : FontStyle.normal,
                          fontWeight: _callProgress == 4 ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 30),
                    
                    // Trigger Button
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: _isPlaying ? null : _triggerSimulatedCall,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brandBlue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.bolt_rounded, size: 14),
                        label: const Text('Simulate Robot Call', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                      ),
                    ),
                  ],
                ),
              );

              if (mobile) {
                return Column(
                  children: [
                    textContent,
                    const SizedBox(height: 45),
                    callSimulator,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: textContent),
                  const SizedBox(width: 60),
                  callSimulator,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
"""

content = content + "\n\n" + voice_reminder_section_code

with open(filepath, 'w') as f:
    f.write(content)

print("VoiceReminderSection successfully injected on Landing Page.")
