import re

filepath = "lib/features/home/home_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

# Add url_launcher import
if "package:url_launcher/url_launcher.dart" not in content:
    content = "import 'package:url_launcher/url_launcher.dart';\n" + content

# Locate _buildSecurityBanner
new_banner = """  // --- paynautik.com Payroll Banner ---
  Widget _buildSecurityBanner() {
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
                              colors: [Color(0xFF10B981), Color(0xFF059669)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.hub_rounded, color: Colors.white, size: 12),
                              SizedBox(width: 4),
                              Text('GLOBAL PAYROLL', style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w900)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('• paynautik.com', style: TextStyle(color: context.colors.inkSoft, fontSize: 11, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Frictionless Global Payroll',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white, letterSpacing: -0.3),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Automate salary disbursements across 150+ countries. Let our smart contracts handle the complexity of multi-currency payouts instantly with zero hidden fees.',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.35, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      onPressed: () async {
                        final url = Uri.parse('https://paynautik.com');
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Could not launch paynautik.com')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Launch PayNautik', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                          SizedBox(width: 4),
                          Icon(Icons.launch_rounded, size: 14),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Right: Embedded Global Payout / Smart Contract graphic
              Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(-0.06)
                  ..rotateZ(-0.02),
                alignment: Alignment.center,
                child: Container(
                  width: 160,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E1E38), Color(0xFF0F0F1E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1.0),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Node connection lines
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _PayrollNodesPainter(),
                        ),
                      ),
                      // Overlay currency badges
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.sync_alt_rounded, color: Color(0xFF10B981), size: 24),
                            ),
                            const SizedBox(height: 8),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _CurrencyBadge('USD', Colors.blue),
                                SizedBox(width: 4),
                                _CurrencyBadge('EUR', Colors.purple),
                                SizedBox(width: 4),
                                _CurrencyBadge('NGN', Colors.green),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }"""

# Find exact bounds of _buildSecurityBanner
start_idx = content.find("  // --- Security / Virtual Card Banner with Embedded Real Card ---")
if start_idx == -1:
    start_idx = content.find("  Widget _buildSecurityBanner()")

end_idx = content.find("  // --- Transactions feed ---", start_idx)

if start_idx != -1 and end_idx != -1:
    content = content[:start_idx] + new_banner + "\n\n" + content[end_idx:]

# Append Custom Painter & Widgets at end of file if not present
custom_widgets = """
class _CurrencyBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _CurrencyBadge(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _PayrollNodesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = const Color(0xFF10B981).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    // Draw grid nodes
    canvas.drawLine(Offset(0, size.height * 0.3), Offset(size.width, size.height * 0.3), paint);
    canvas.drawLine(Offset(0, size.height * 0.7), Offset(size.width, size.height * 0.7), paint);
    canvas.drawLine(Offset(size.width * 0.3, 0), Offset(size.width * 0.3, size.height), paint);
    canvas.drawLine(Offset(size.width * 0.7, 0), Offset(size.width * 0.7, size.height), paint);

    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.3), 3, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.3), 3, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.3, size.height * 0.7), 3, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.7, size.height * 0.7), 3, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
"""

if "_PayrollNodesPainter" not in content:
    content += custom_widgets

with open(filepath, 'w') as f:
    f.write(content)

