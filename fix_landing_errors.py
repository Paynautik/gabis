filepath = "lib/features/landing/landing_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

# 1. Fix Elumo's single-quote escape issue on line 346
content = content.replace(
    "Interact with Elumo\\'s core",
    "Interact with Elumo's core"
)
# Wait, let's look at the actual text around line 346 in the file. It is:
# 'Interact with Elumo\'s core...'
# Let's replace the whole Text block:
content = content.replace(
    "child: const Text(\n                      'Interact with Elumo\\'s core consumer tools instantly. Tap the modules below to test our dynamic prototypes.',",
    'child: const Text(\n                      "Interact with Elumo\'s core consumer tools instantly. Tap the modules below to test our dynamic prototypes.",'
)

# 2. Fix w950 issue on line 944
content = content.replace("FontWeight.w950", "FontWeight.w900")

# 3. Fix TrustSection non-const TrustCards call
content = content.replace(
    "class TrustSection extends StatelessWidget {\n  const TrustSection({super.key});\n\n  @override\n  Widget build(BuildContext context) {\n    return const Section(\n      child: Column(\n        children: [\n          SectionHeading(\n            eyebrow: 'TRUST LAYER',\n            title: 'Built around security. Anchored in trust.',\n            subtitle:\n                'End-to-end security compliance, real-time transaction verification, and licensed payment operations.',\n          ),\n          SizedBox(height: 55),\n          TrustCards(),\n        ],\n      ),\n    );\n  }\n}",
    "class TrustSection extends StatelessWidget {\n  const TrustSection({super.key});\n\n  @override\n  Widget build(BuildContext context) {\n    return Section(\n      child: Column(\n        children: [\n          const SectionHeading(\n            eyebrow: 'TRUST LAYER',\n            title: 'Built around security. Anchored in trust.',\n            subtitle:\n                'End-to-end security compliance, real-time transaction verification, and licensed payment operations.',\n          ),\n          const SizedBox(height: 55),\n          TrustCards(),\n        ],\n      ),\n    );\n  }\n}"
)

# 4. Remove const Column from LandingScreen
content = content.replace(
    "          children: const [\n            Navbar(),\n            HeroSection(),\n            ProductShowcaseSection(),\n            BusinessSection(),\n            DeveloperSection(),\n            TrustSection(),\n            CTASection(),\n            Footer(),\n          ],",
    "          children: const [\n            Navbar(),\n            HeroSection(),\n            ProductShowcaseSection(),\n            BusinessSection(),\n            DeveloperSection(),\n            TrustSection(),\n            CTASection(),\n            Footer(),\n          ],"
)
# Wait, because ProductShowcaseSection has state, the list children can't be const!
content = content.replace(
    "          children: const [\n            Navbar(),\n            HeroSection(),\n            ProductShowcaseSection(),",
    "          children: [\n            const Navbar(),\n            const HeroSection(),\n            const ProductShowcaseSection(),"
)
content = content.replace(
    "            BusinessSection(),\n            DeveloperSection(),\n            TrustSection(),\n            CTASection(),\n            Footer(),\n          ],",
    "            const BusinessSection(),\n            const DeveloperSection(),\n            const TrustSection(),\n            const CTASection(),\n            const Footer(),\n          ],"
)

with open(filepath, 'w') as f:
    f.write(content)

print("Landing page error fixes applied.")
