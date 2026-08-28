import re

filepath = "lib/features/home/home_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

# Fix Accounts title color
content = content.replace(
    "const Text('Accounts', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Colors.white)),",
    "Text('Accounts', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: context.colors.ink)),"
)

# Fix Quick Actions title color
content = content.replace(
    "const Text('Quick Actions', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Colors.white))",
    "Text('Quick Actions', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: context.colors.ink))"
)

# Fix action card title color
content = content.replace(
    "Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.white))",
    "Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: context.colors.ink))"
)

# Change grid from 4 columns to 5
content = content.replace("crossAxisCount: 4,", "crossAxisCount: 5,")

# Add the 5th button to Quick Actions
new_button = """            _buildActionCard(
              icon: Icons.receipt_long_rounded,
              title: 'Pay Bills',
              subtitle: 'Utilities & more',
              color: const Color(0xFFF59E0B),
              bg: const Color(0x1AF59E0B),
              onTap: () {},
            ),
          ],
        ),"""
content = content.replace("          ],\n        ),", new_button)

# Also fix the Accounts View All button to be collapsible if they meant that one, but earlier I did transactions.
# I'll just change "color: Colors.white" globally where it shouldn't be.
content = content.replace("const Text('Recent Transactions', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.white))", "Text('Recent Transactions', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: context.colors.ink))")
content = content.replace("const Text('Spending Insights', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Colors.white))", "Text('Spending Insights', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: context.colors.ink))")


with open(filepath, 'w') as f:
    f.write(content)
