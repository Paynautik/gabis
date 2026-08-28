filepath = "lib/features/home/home_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

# First revert the damage
bills_card = """            _buildActionCard(
              icon: Icons.receipt_long_rounded,
              title: 'Bills',
              subtitle: 'Pay utilities',
              color: const Color(0xFFE11D48),
              bg: const Color(0x1AE11D48),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bill Payments coming soon!')));
              },
            ),
                      ],
        ),"""

content = content.replace(bills_card, "                      ],\n        ),")

# Now inject it precisely. Look for Exchange card.
exchange_card = """            _buildActionCard(
              icon: Icons.swap_horiz_rounded,
              title: 'Exchange',
              subtitle: 'Convert currency',
              color: const Color(0xFFF79009),
              bg: const Color(0x1AF79009),
              onTap: () => Navigator.of(context).pushNamed('/fx'),
            ),"""

bills_card_clean = """            _buildActionCard(
              icon: Icons.swap_horiz_rounded,
              title: 'Exchange',
              subtitle: 'Convert currency',
              color: const Color(0xFFF79009),
              bg: const Color(0x1AF79009),
              onTap: () => Navigator.of(context).pushNamed('/fx'),
            ),
            _buildActionCard(
              icon: Icons.receipt_long_rounded,
              title: 'Bills',
              subtitle: 'Pay utilities',
              color: const Color(0xFFE11D48),
              bg: const Color(0x1AE11D48),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bill Payments coming soon!')));
              },
            ),"""

content = content.replace(exchange_card, bills_card_clean)

with open(filepath, 'w') as f:
    f.write(content)
