filepath = "lib/features/home/home_shell.dart"
with open(filepath, 'r') as f:
    content = f.read()

invite_dialog = """  void _showInviteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.bgSoft,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: context.colors.bluePrimary.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(Icons.card_giftcard_rounded, color: context.colors.bluePrimary, size: 22),
            ),
            const SizedBox(width: 12),
            Text('Invite & Earn', style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w900, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Share your referral code with friends and earn ₦5,000 / \$5 for every friend who signs up and funds their account!',
                style: TextStyle(color: context.colors.inkSoft, fontSize: 13)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: context.colors.scaffoldBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.colors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('RAPHAEL2026', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.5, color: Color(0xFF10B981))),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Referral link copied to clipboard!')));
                    },
                    child: Row(
                      children: [
                        Text('Copy', style: TextStyle(color: context.colors.bluePrimary, fontWeight: FontWeight.w800, fontSize: 13)),
                        const SizedBox(width: 4),
                        Icon(Icons.copy_rounded, color: context.colors.bluePrimary, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }
"""

content = content.replace("  Widget _buildSidebarItem", invite_dialog + "\n  Widget _buildSidebarItem")

with open(filepath, 'w') as f:
    f.write(content)
