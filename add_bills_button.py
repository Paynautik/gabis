import re

filepath = "lib/features/home/home_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

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

content = content.replace("                      ],\n        ),", bills_card)

with open(filepath, 'w') as f:
    f.write(content)
