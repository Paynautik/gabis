import re

filepath = "lib/features/home/home_shell.dart"
with open(filepath, 'r') as f:
    content = f.read()

# 1. Revert onTap behavior in _buildSidebarItem
old_ontap = """onTap: () {
        if (index < _screens.length) {
          setState(() => _index = index);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${label} coming soon!')));
        }
      },"""
new_ontap = "onTap: () => setState(() => _index = index),"
content = content.replace(old_ontap, new_ontap)

# 2. Update _screens list
old_screens = """  static const _screens = [
    HomeScreen(),
    AccountsScreen(),
    CardsScreen(),
    ProfileScreen(),
  ];"""
new_screens = """  static const _screens = [
    HomeScreen(),
    AccountsScreen(),
    CardsScreen(),
    ProfileScreen(),
    PlaceholderScreen('Transactions'),
    PlaceholderScreen('Analytics'),
    PlaceholderScreen('Beneficiaries'),
    PlaceholderScreen('Settings'),
    PlaceholderScreen('Support'),
  ];"""
content = content.replace(old_screens, new_screens)

# 3. Add PlaceholderScreen class at the end
placeholder_class = """
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.scaffoldBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction_rounded, size: 64, color: context.colors.bluePrimary.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              '$title',
              style: TextStyle(color: context.colors.ink, fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              'This module is being built.',
              style: TextStyle(color: context.colors.inkSoft, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
"""
if "class PlaceholderScreen" not in content:
    content += placeholder_class

with open(filepath, 'w') as f:
    f.write(content)
