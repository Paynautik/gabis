import re

filepath = "lib/features/home/home_shell.dart"
with open(filepath, 'r') as f:
    content = f.read()

# Change sidebar background back to dark
content = content.replace("color: context.colors.bgSoft, // Card background color", "color: const Color(0xFF0F172A), // Dark obsidian sidebar")

# Fix indices
content = content.replace("_buildSidebarItem(3, Icons.receipt_long_rounded, 'Transactions')", "_buildSidebarItem(4, Icons.receipt_long_rounded, 'Transactions')")
content = content.replace("_buildSidebarItem(3, Icons.bar_chart_rounded, 'Analytics')", "_buildSidebarItem(5, Icons.bar_chart_rounded, 'Analytics')")
content = content.replace("_buildSidebarItem(3, Icons.people_rounded, 'Beneficiaries')", "_buildSidebarItem(6, Icons.people_rounded, 'Beneficiaries')")
content = content.replace("_buildSidebarItem(3, Icons.settings_rounded, 'Settings')", "_buildSidebarItem(7, Icons.settings_rounded, 'Settings')")
content = content.replace("_buildSidebarItem(3, Icons.help_outline_rounded, 'Support')", "_buildSidebarItem(8, Icons.help_outline_rounded, 'Support')")

# Fix _buildSidebarItem so that non-selected items are readable on the dark background!
# isSelected ? Colors.white : context.colors.inkSoft -> isSelected ? Colors.white : const Color(0xFF94A3B8)
content = content.replace("color: isSelected ? Colors.white : context.colors.inkSoft,", "color: isSelected ? Colors.white : const Color(0xFF94A3B8),")

# And for the background of selected item:
# isSelected ? context.colors.blueHighlight : Colors.transparent -> isSelected ? context.colors.bluePrimary.withValues(alpha: 0.2) : Colors.transparent
content = content.replace("color: isSelected ? context.colors.blueHighlight : Colors.transparent,", "color: isSelected ? context.colors.bluePrimary.withValues(alpha: 0.2) : Colors.transparent,")

with open(filepath, 'w') as f:
    f.write(content)
