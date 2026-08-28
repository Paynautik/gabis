filepath = "lib/features/home/home_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

old_bills_card = """            _buildActionCard(
              icon: Icons.receipt_long_rounded,
              title: 'Bills',
              subtitle: 'Pay utilities',
              color: const Color(0xFFE11D48),
              bg: const Color(0x1AE11D48),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bill Payments coming soon!')));
              },
            ),"""

new_bills_card = """            _buildActionCard(
              icon: Icons.receipt_long_rounded,
              title: 'Bills',
              subtitle: 'Pay utilities',
              color: const Color(0xFFE11D48),
              bg: const Color(0x1AE11D48),
              onTap: () => Navigator.of(context).pushNamed('/bills'),
            ),"""

content = content.replace(old_bills_card, new_bills_card)

with open(filepath, 'w') as f:
    f.write(content)
