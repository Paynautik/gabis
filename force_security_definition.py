filepath = "lib/features/home/home_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

security_banner_method = """  // --- Standalone Real Virtual Card / Security Banner ---
  Widget _buildRealSecurityBanner() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            child: GestureDetector(
              onTap: () => setState(() => _showSecurityBanner = false),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8), size: 16),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left text info
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.shield_rounded, color: Colors.white, size: 12),
                              SizedBox(width: 4),
                              Text('Virtual Platinum', style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w900)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('• Secure & Instant', style: TextStyle(color: context.colors.inkSoft, fontSize: 11, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Global Virtual Debit Card',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white, letterSpacing: -0.3),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Spend internationally anywhere Visa is accepted with 0% FX fees and bank-grade 3D-Secure protection.',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.35, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pushNamed('/cards'),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Manage Cards', style: TextStyle(color: context.colors.bluePrimary, fontSize: 13, fontWeight: FontWeight.w900)),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded, color: context.colors.bluePrimary, size: 14),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Right: Embedded Real 3D Virtual Card
              GestureDetector(
                onTap: () => Navigator.of(context).pushNamed('/cards'),
                child: Transform(
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(-0.08)
                    ..rotateZ(-0.02),
                  alignment: Alignment.center,
                  child: Container(
                    width: 175,
                    height: 110,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E293B), Color(0xFF090D16)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.0),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1D4ED8).withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.6),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Top row: EMV Chip + NFC + Logo
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                // Golden EMV Chip
                                Container(
                                  width: 22,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFFFDF79), Color(0xFFC79224)],
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: const Color(0xFFE5B53A), width: 0.5),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.contactless_rounded, color: Colors.white70, size: 14),
                              ],
                            ),
                            const Text(
                              'ELUMO',
                              style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                            ),
                          ],
                        ),
                        // Middle Card Number
                        const Text(
                          '•••• •••• •••• 4821',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                        // Bottom row: Holder + Visa
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('RAPHAEL MOMOH', style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w800)),
                                SizedBox(height: 1),
                                Text('08/29', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 6.5, fontWeight: FontWeight.w700)),
                              ],
                            ),
                            // VISA Logo Mockup
                            const Text(
                              'VISA',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                fontStyle: FontStyle.italic,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
"""

content = content.replace("Widget _buildCarouselBanner()", security_banner_method + "\n\n  Widget _buildCarouselBanner()")

with open(filepath, 'w') as f:
    f.write(content)
