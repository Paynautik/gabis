filepath = "lib/features/landing/landing_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

# 1. Update the Hero Tagline Badge to include payments
content = content.replace(
    "'AI FINANCIAL OPERATING SYSTEM',",
    "'AI-POWERED PAYMENTS & FINANCIAL OS',"
)

# 2. Update the Hero Subheading text to explicitly mention consumer features (borders, cards, utility bills, business)
content = content.replace(
    "const Text(\n          'ElumoPay is an AI-powered financial operating system helping African businesses collect, reconcile and understand their money.',",
    "const Text(\n          'ElumoPay is an AI-powered financial super app. Send money across borders, spend globally with virtual debit cards, pay bills, and automate business collections and reconciliations in one platform.',"
)

# 3. Add FeatureBadge wrap list below the NDIC text row in _heroText
old_ndic_row = """        Row(
          children: [
            Icon(
              Icons.verified_user_rounded,
              size: 18,
              color: brandGreen.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 8),
            const Text(
              'NDIC Insured Partner Banks • CBN Licensed Remittances',
              style: TextStyle(
                color: brandMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),"""

new_ndic_row = """        Row(
          children: [
            Icon(
              Icons.verified_user_rounded,
              size: 18,
              color: brandGreen.withValues(alpha: 0.8),
            ),
            const SizedBox(width: 8),
            const Text(
              'NDIC Insured Partner Banks • CBN Licensed Remittances',
              style: TextStyle(
                color: brandMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            FeatureBadge(label: 'Cross-Border Transfers'),
            FeatureBadge(label: 'Utility & Bill Payments'),
            FeatureBadge(label: 'Virtual Debit Cards'),
            FeatureBadge(label: 'AI Business Intelligence'),
          ],
        ),"""

content = content.replace(old_ndic_row, new_ndic_row)

# 4. Append FeatureBadge definition to the end of the file
feature_badge_code = """// ============================================================
// INLINE FEATURE CHECKMARK BADGE
// ============================================================
class FeatureBadge extends StatelessWidget {
  final String label;
  const FeatureBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle_outline_rounded, color: brandCyan, size: 13),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: brandMuted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
"""

content = content + "\n\n" + feature_badge_code

with open(filepath, 'w') as f:
    f.write(content)

print("Payments and transfers focus added successfully.")
