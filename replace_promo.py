import re

filepath = "lib/features/home/home_screen.dart"

with open(filepath, 'r') as f:
    content = f.read()

new_banner = """
  Widget _buildPromoBanner() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), Color(0xFF1E3A8A), Color(0xFF2563EB)],
          stops: [0.0, 0.5, 1.0],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1.5),
        boxShadow: [
          BoxShadow(color: const Color(0xFF2563EB).withValues(alpha: 0.3), blurRadius: 24, offset: const Offset(0, 10)),
        ],
      ),
      child: Stack(
        children: [
          // Background abstract graphic
          Positioned(
            right: -60,
            bottom: -60,
            child: Transform.rotate(
              angle: -0.2,
              child: Icon(Icons.public_rounded, size: 280, color: Colors.white.withValues(alpha: 0.05)),
            ),
          ),
          // Subtle glow orb
          Positioned(
            left: -50,
            top: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF60A5FA).withValues(alpha: 0.15),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 600;
                
                final textAndButton = [
                  Expanded(
                    flex: isMobile ? 0 : 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Frictionless Global Payroll.',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.white, letterSpacing: -0.5),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Automate salary disbursements across 150+ countries. Let our smart contracts handle the complexity of multi-currency payouts instantly with zero hidden fees.',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13.5, fontWeight: FontWeight.w500, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  if (isMobile) const SizedBox(height: 20) else const SizedBox(width: 32),
                  // Call to Action Button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 12, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text('Visit Paynautik.com', style: TextStyle(color: Color(0xFF1E3A8A), fontSize: 13, fontWeight: FontWeight.w900)),
                              SizedBox(width: 6),
                              Icon(Icons.arrow_forward_rounded, color: Color(0xFF1E3A8A), size: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ];

                return Row(
                  crossAxisAlignment: isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                  children: [
                    // Abstract Graphics Container
                    SizedBox(
                      width: 64,
                      height: 64,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            left: 0,
                            top: 0,
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                              ),
                              child: const Icon(Icons.currency_exchange_rounded, color: Colors.white54, size: 20),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Color(0xFF60A5FA), Color(0xFF2563EB)],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
                                boxShadow: [
                                  BoxShadow(color: const Color(0xFF1D4ED8).withValues(alpha: 0.5), blurRadius: 12, offset: const Offset(0, 4)),
                                ],
                              ),
                              child: const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 24),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    
                    if (isMobile)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: textAndButton,
                        ),
                      )
                    else
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: textAndButton,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          
          // Close button
          Positioned(
            right: 8,
            top: 8,
            child: IconButton(
              icon: Icon(Icons.close_rounded, color: Colors.white.withValues(alpha: 0.4), size: 20),
              onPressed: () => setState(() => _showPromoBanner = false),
            ),
          ),
        ],
      ),
    );
  }
"""

# Find the start and end precisely using string find
start_idx = content.find("  Widget _buildPromoBanner() {")
end_idx = content.find("  Widget _buildQuickActionsSection", start_idx)

if start_idx != -1 and end_idx != -1:
    new_content = content[:start_idx] + new_banner.strip() + "\n\n" + content[end_idx:]
    with open(filepath, 'w') as f:
        f.write(new_content)
    print("Updated promo banner successfully.")
else:
    print("Could not find _buildPromoBanner block.")

