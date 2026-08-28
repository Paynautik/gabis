import re

filepath = "lib/features/home/home_shell.dart"
with open(filepath, 'r') as f:
    content = f.read()

settings_dialog = """
  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: context.colors.bgSoft,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Settings', style: TextStyle(color: context.colors.ink, fontSize: 20, fontWeight: FontWeight.w900)),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: context.colors.inkSoft),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.colors.bluePrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.colors.bluePrimary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.workspace_premium_rounded, color: context.colors.bluePrimary, size: 32),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Premium User', style: TextStyle(color: context.colors.bluePrimary, fontWeight: FontWeight.w900, fontSize: 16)),
                          const SizedBox(height: 2),
                          Text('All features unlocked', style: TextStyle(color: context.colors.inkSoft, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: Icon(Icons.dark_mode_rounded, color: context.colors.ink),
                  title: Text('Dark Mode', style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w700)),
                  trailing: Switch(
                    value: Theme.of(context).brightness == Brightness.dark,
                    onChanged: (val) {
                      // Handled by riverpod in full implementation
                    },
                    activeColor: context.colors.bluePrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
"""

if "_showSettingsDialog" not in content or "void _showSettingsDialog" not in content:
    content = content.replace("  Widget _buildSidebarItem", settings_dialog + "\n  Widget _buildSidebarItem")

with open(filepath, 'w') as f:
    f.write(content)
