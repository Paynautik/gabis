filepath = "lib/features/home/home_shell.dart"
with open(filepath, 'r') as f:
    content = f.read()

# Make HomeShell a ConsumerStatefulWidget
content = content.replace("class HomeShell extends StatefulWidget {", "import 'package:flutter_riverpod/flutter_riverpod.dart';\nimport '../../shared/providers/app_providers.dart';\n\nclass HomeShell extends ConsumerStatefulWidget {")
content = content.replace("State<HomeShell> createState() => _HomeShellState();", "ConsumerState<HomeShell> createState() => _HomeShellState();")
content = content.replace("class _HomeShellState extends State<HomeShell> {", "class _HomeShellState extends ConsumerState<HomeShell> {")

# Fix Logout navigation
content = content.replace(
"""                      onSelected: (value) {
                        if (value == 'settings') {
                          _showSettingsDialog(context);
                        }
                      },""",
"""                      onSelected: (value) {
                        if (value == 'settings') {
                          _showSettingsDialog(context);
                        } else if (value == 'logout') {
                          Navigator.of(context).pushReplacementNamed('/login');
                        }
                      },"""
)

# Fix Invite Now button
content = content.replace(
"""                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: context.colors.bluePrimary,
                                  minimumSize: const Size.fromHeight(36),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('Invite Now', style: TextStyle(fontSize: 12)),
                              ),""",
"""                              ElevatedButton(
                                onPressed: () => _showInviteDialog(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: context.colors.bluePrimary,
                                  minimumSize: const Size.fromHeight(36),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text('Invite Now', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                              ),"""
)

# Wire Dark Mode switch in _showSettingsDialog
content = content.replace(
"""                  trailing: Switch(
                    value: Theme.of(context).brightness == Brightness.dark,
                    onChanged: (val) {
                      // Handled by riverpod in full implementation
                    },
                    activeColor: context.colors.bluePrimary,
                  ),""",
"""                  trailing: Switch(
                    value: ref.watch(themeModeProvider) == ThemeMode.dark,
                    onChanged: (val) {
                      ref.read(themeModeProvider.notifier).state = val ? ThemeMode.dark : ThemeMode.light;
                    },
                    activeThumbColor: context.colors.bluePrimary,
                  ),"""
)

# Add _showInviteDialog
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

if "_showInviteDialog" not in content:
    content = content.replace("  Widget _buildSidebarItem", invite_dialog + "\n  Widget _buildSidebarItem")

with open(filepath, 'w') as f:
    f.write(content)
