import re

filepath = "lib/features/home/home_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

# First revert the damage
damage_pattern = r"_buildActionCard\(\s+icon: Icons\.receipt_long_rounded,\s+title: 'Pay Bills',\s+subtitle: 'Utilities & more',\s+color: const Color\(0xFFF59E0B\),\s+bg: const Color\(0x1AF59E0B\),\s+onTap: \(\) \{\},\s+\),\s+\],\s+\),"
content = re.sub(damage_pattern, "          ],\n        ),", content)

# Now add it safely to the Quick Actions
# Find the exact Quick Actions grid array end
grid_end_pattern = r"_buildActionCard\(\s+icon: Icons\.swap_calls_rounded,\s+title: 'Exchange',\s+subtitle: 'Convert currency',\s+color: const Color\(0xFFF59E0B\),\s+bg: const Color\(0x1AF59E0B\),\s+onTap: \(\) => showComingSoon\(context, 'Exchange'\),\s+\),\s+\]"

replacement = """_buildActionCard(
              icon: Icons.swap_calls_rounded,
              title: 'Exchange',
              subtitle: 'Convert currency',
              color: const Color(0xFFF59E0B),
              bg: const Color(0x1AF59E0B),
              onTap: () => showComingSoon(context, 'Exchange'),
            ),
            _buildActionCard(
              icon: Icons.receipt_long_rounded,
              title: 'Pay Bills',
              subtitle: 'Utilities & more',
              color: const Color(0xFF3B82F6),
              bg: const Color(0x1A3B82F6),
              onTap: () => showComingSoon(context, 'Pay Bills'),
            ),
          ]"""

content = re.sub(grid_end_pattern, replacement, content)

with open(filepath, 'w') as f:
    f.write(content)
