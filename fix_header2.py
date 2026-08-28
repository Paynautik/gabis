import re

filepath = "lib/features/home/home_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

pattern = r"  Widget _buildHeader\(BuildContext context\) \{.*?\n  \}\n\n  // --- Net Worth Card ---"

new_header = """  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: context.colors.scaffoldBg,
        border: Border(bottom: BorderSide(color: context.colors.border, width: 1.0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side: Avatar + Hi, Name
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: context.colors.bluePrimary.withValues(alpha: 0.3), width: 2),
                ),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: context.colors.blueHighlight,
                  child: const Text('RM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
                ),
              ),
              const SizedBox(width: 10),
              Text('Hi, RAPHAEL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: context.colors.ink, letterSpacing: -0.3)),
            ],
          ),
          
          // Right side: Icons
          Row(
            children: [
              IconButton(
                onPressed: () => _showHelpSupportSheet(context),
                icon: Icon(Icons.support_agent_rounded, color: context.colors.ink, size: 24),
              ),
              IconButton(
                onPressed: () => _showScannerDialog(context),
                icon: Icon(Icons.qr_code_scanner_rounded, color: context.colors.ink, size: 22),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: () => _showNotificationsSheet(context),
                    icon: Icon(Icons.notifications_none_rounded, color: context.colors.ink, size: 26),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: context.colors.scaffoldBg, width: 1.5),
                      ),
                      child: const Text('99+', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Net Worth Card ---"""

content = re.sub(pattern, new_header, content, flags=re.DOTALL)

with open(filepath, 'w') as f:
    f.write(content)
