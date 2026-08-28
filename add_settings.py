import re

filepath = "lib/features/home/home_shell.dart"
with open(filepath, 'r') as f:
    content = f.read()

# Make the profile box clickable
profile_pattern = r"                  Container\(\n                    padding: const EdgeInsets\.all\(12\),\n                    decoration: BoxDecoration\(\n                      color: context\.colors\.border,\n                      borderRadius: BorderRadius\.circular\(16\),\n                    \),\n                    child: Row\("

new_profile = """                  InkWell(
                    onTap: () => _showSettingsDialog(context),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.colors.border,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row("""
content = re.sub(profile_pattern, new_profile, content)

# Inject _showSettingsDialog just before the end of _HomeShellState
settings_dialog = """
  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.white,
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
                    const Text('Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF101828))),
                    IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 24),
                // Profile & Premium badge
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: const Color(0xFF1858F2),
                      child: const Text('RM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Raphael Momoh', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF101828))),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Premium User', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800)),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.person_outline_rounded, color: Color(0xFF101828)),
                  title: const Text('Account Details', style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.security_rounded, color: Color(0xFF101828)),
                  title: const Text('Security & Privacy', style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {},
                ),
                Consumer(
                  builder: (context, ref, _) {
                    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
                    return SwitchListTile(
                      activeColor: const Color(0xFF1858F2),
                      secondary: Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded, color: const Color(0xFF101828)),
                      title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w600)),
                      value: isDark,
                      onChanged: (val) {
                        ref.read(themeModeProvider.notifier).state = val ? ThemeMode.dark : ThemeMode.light;
                      },
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
                  title: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFEF4444))),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
"""

content = content.replace("                      ],\n                    ),\n                  ),", "                      ],\n                    ),\n                  ),\n                  ),")
content = content.replace("}\n}", settings_dialog + "\n}\n}")

with open(filepath, 'w') as f:
    f.write(content)
