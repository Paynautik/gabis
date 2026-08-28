import re

filepath = "lib/features/home/home_screen.dart"

with open(filepath, 'r') as f:
    content = f.read()

new_banner = """
  Widget _buildSecurityBanner() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), Color(0xFF022C22), Color(0xFF065F46)], // Obsidian to Emerald
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1.5),
        boxShadow: [
          BoxShadow(color: const Color(0xFF10B981).withValues(alpha: 0.15), blurRadius: 24, offset: const Offset(0, 10)),
        ],
      ),
      child: Stack(
        children: [
          // Background graphic (huge lock)
          Positioned(
            right: -30,
            bottom: -40,
            child: Transform.rotate(
              angle: -0.2,
              child: Icon(Icons.admin_panel_settings_rounded, size: 180, color: Colors.white.withValues(alpha: 0.04)),
            ),
          ),
          // Subtle glow on the right
          Positioned(
            right: 0,
            top: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF10B981).withValues(alpha: 0.2),
              ),
              // we can't easily add ImageFilter.blur without wrapping, so we rely on radial gradient or just keep it low opacity
            ),
          ),
          
          // Main content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Glowing Shield
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF10B981).withValues(alpha: 0.2),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF34D399).withValues(alpha: 0.3), blurRadius: 16),
                        ],
                      ),
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF34D399), Color(0xFF059669)],
                        ),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF047857), blurRadius: 8, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: const Icon(Icons.shield_rounded, color: Colors.white, size: 20),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ironclad Protection',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Colors.white, letterSpacing: -0.5),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Your funds are secured with military-grade 256-bit encryption and dynamic anomaly detection.',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13, fontWeight: FontWeight.w500, height: 1.4),
                      ),
                      const SizedBox(height: 16),
                      // Action link
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text('Security Center', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
                            SizedBox(width: 6),
                            Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 14),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Close button
          Positioned(
            right: 8,
            top: 8,
            child: IconButton(
              icon: Icon(Icons.close_rounded, color: Colors.white.withValues(alpha: 0.5), size: 20),
              onPressed: () => setState(() => _showSecurityBanner = false),
            ),
          ),
        ],
      ),
    );
  }
"""

# Find the start and end of _buildSecurityBanner
pattern = r"Widget _buildSecurityBanner\(\) \{.*?(?=  Widget _buildTransactionsCard|\Z)"

# Need DOTALL to match across newlines
new_content = re.sub(pattern, new_banner.strip() + "\n\n", content, flags=re.DOTALL)

with open(filepath, 'w') as f:
    f.write(new_content)
    
print("Updated banner!")
