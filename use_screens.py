import re

filepath = "lib/features/home/home_shell.dart"
with open(filepath, 'r') as f:
    content = f.read()

# Add import
if "import 'sidebar_screens.dart';" not in content:
    content = content.replace("import 'home_screen.dart';", "import 'home_screen.dart';\nimport 'sidebar_screens.dart';\nimport '../cards/cards_screen.dart';")

# Replace screens list
old_screens = """  static const _screens = [
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

new_screens = """  static const _screens = [
    HomeScreen(),
    AccountsScreen(),
    CardsScreen(),
    ProfileScreen(),
    TransactionsScreen(),
    AnalyticsScreen(),
    BeneficiariesScreen(),
    SettingsScreen(),
    SupportScreen(),
  ];"""

content = content.replace(old_screens, new_screens)

with open(filepath, 'w') as f:
    f.write(content)
