filepath = "lib/features/home/home_shell.dart"
with open(filepath, 'r') as f:
    content = f.read()

# 1. Add imports
imports = """import 'dart:convert';
import '../business/business_dashboard_screen.dart';
import '../../shared/widgets/nautik_logo.dart';"""

content = content.replace("import '../../shared/widgets/nautik_logo.dart';", imports)

# 2. Add isBusinessMode check in build
old_build_start = """  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;"""

new_build_start = """  @override
  Widget build(BuildContext context) {
    final isBusinessMode = ref.watch(isBusinessModeProvider);
    if (isBusinessMode) {
      return const BusinessDashboardScreen();
    }
    final width = MediaQuery.of(context).size.width;"""

content = content.replace(old_build_start, new_build_start)

# 3. Update CircleAvatar in sidebar
old_sidebar_avatar = """                            CircleAvatar(
                              radius: 18,
                              backgroundColor: context.colors.bluePrimary.withValues(alpha: 0.2),
                              child: const Text('R', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                            ),"""

new_sidebar_avatar = """                            CircleAvatar(
                              radius: 18,
                              backgroundColor: context.colors.bluePrimary.withValues(alpha: 0.2),
                              backgroundImage: ref.watch(userAvatarProvider) != null
                                  ? MemoryImage(base64Decode(ref.watch(userAvatarProvider)!))
                                  : null,
                              child: ref.watch(userAvatarProvider) == null
                                  ? const Text('R', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900))
                                  : null,
                            ),"""

content = content.replace(old_sidebar_avatar, new_sidebar_avatar)

# 4. Update PopupMenuButton logic to include business mode switch and route logout to /landing
old_popup_selected = """                      onSelected: (value) {
                        if (value == 'settings') {
                          _showSettingsDialog(context);
                        } else if (value == 'logout') {
                          Navigator.of(context).pushReplacementNamed('/login');
                        }
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'settings',
                          child: Row(
                            children: [
                              Icon(Icons.settings_rounded, color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text('Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(height: 1),
                        PopupMenuItem<String>(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(Icons.logout_rounded, color: Colors.redAccent, size: 18),
                              SizedBox(width: 8),
                              Text('Log Out', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),"""

new_popup_selected = """                      onSelected: (value) {
                        if (value == 'settings') {
                          _showSettingsDialog(context);
                        } else if (value == 'logout') {
                          ref.read(authStateProvider.notifier).state = false;
                          Navigator.of(context).pushReplacementNamed('/landing');
                        } else if (value == 'business') {
                          ref.read(isBusinessModeProvider.notifier).state = true;
                        }
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'settings',
                          child: Row(
                            children: [
                              Icon(Icons.settings_rounded, color: Colors.white, size: 18),
                              SizedBox(width: 8),
                              Text('Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'business',
                          child: Row(
                            children: [
                              Icon(Icons.business_center_rounded, color: Colors.white70, size: 18),
                              SizedBox(width: 8),
                              Text('Switch to Business', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(height: 1),
                        PopupMenuItem<String>(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(Icons.logout_rounded, color: Colors.redAccent, size: 18),
                              SizedBox(width: 8),
                              Text('Log Out', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),"""

content = content.replace(old_popup_selected, new_popup_selected)

# 5. Add Business Mode switcher in settings dialog
old_settings_list = """                ListTile(
                  leading: Icon(Icons.dark_mode_rounded, color: context.colors.ink),
                  title: Text('Dark Mode', style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w700)),
                  trailing: Switch(
                    value: ref.watch(themeModeProvider) == ThemeMode.dark,
                    onChanged: (val) {
                      ref.read(themeModeProvider.notifier).state = val ? ThemeMode.dark : ThemeMode.light;
                    },
                    activeThumbColor: context.colors.bluePrimary,
                  ),
                ),"""

new_settings_list = """                ListTile(
                  leading: Icon(Icons.dark_mode_rounded, color: context.colors.ink),
                  title: Text('Dark Mode', style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w700)),
                  trailing: Switch(
                    value: ref.watch(themeModeProvider) == ThemeMode.dark,
                    onChanged: (val) {
                      ref.read(themeModeProvider.notifier).state = val ? ThemeMode.dark : ThemeMode.light;
                    },
                    activeThumbColor: context.colors.bluePrimary,
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.business_center_rounded, color: context.colors.ink),
                  title: Text('Business Account', style: TextStyle(color: context.colors.ink, fontWeight: FontWeight.w700)),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () {
                    Navigator.pop(context);
                    ref.read(isBusinessModeProvider.notifier).state = true;
                  },
                ),"""

content = content.replace(old_settings_list, new_settings_list)

with open(filepath, 'w') as f:
    f.write(content)

print("HomeShell modifications completed.")
