import re

filepath = "lib/features/home/home_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

# 1. Upgrade Net Worth Card to a Premium Gradient
old_net_worth = """      decoration: BoxDecoration(
        color: context.colors.bluePrimary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: context.colors.bluePrimary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),"""
new_net_worth = """      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8), Color(0xFF1E3A8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D4ED8).withValues(alpha: 0.4),
            blurRadius: 24,
            spreadRadius: -4,
            offset: const Offset(0, 12),
          ),
        ],
      ),"""
content = content.replace(old_net_worth, new_net_worth)

# 2. Upgrade Account Cards (Soft shadows, better border, slightly more rounded)
old_acct_card = """              decoration: BoxDecoration(
                color: context.colors.bgSoft,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: context.colors.border),
              ),"""
new_acct_card = """              decoration: BoxDecoration(
                color: context.colors.bgSoft,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: context.colors.border.withValues(alpha: 0.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),"""
content = content.replace(old_acct_card, new_acct_card)

# 3. Upgrade Quick Actions (Add a delicate shadow to the icon circle)
old_action = """          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
            child: Icon(icon, color: color, size: 26),
          ),"""
new_action = """          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: bg, 
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 26),
          ),"""
content = content.replace(old_action, new_action)

# 4. Upgrade the "Receive Money" and "Add Money" Bottom Sheets buttons
old_btn = """                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.bluePrimary,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),"""
new_btn = """                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.bluePrimary,
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shadowColor: context.colors.bluePrimary.withValues(alpha: 0.5),
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),"""
content = content.replace(old_btn, new_btn)

with open(filepath, 'w') as f:
    f.write(content)
