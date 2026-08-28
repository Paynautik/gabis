filepaths = [
    "lib/main.dart",
    "lib/shared/models/app_contact.dart",
    "lib/shared/providers/contacts_provider.dart",
    "lib/features/home/home_screen.dart"
]

# 1. Fix main.dart
with open("lib/main.dart", 'r') as f:
    main_content = f.read()
main_content = main_content.replace("NautikOneApp", "ElumoApp")
with open("lib/main.dart", 'w') as f:
    f.write(main_content)

# 2. Fix app_contact.dart
with open("lib/shared/models/app_contact.dart", 'r') as f:
    contact_content = f.read()
contact_content = contact_content.replace("hasNautikOne", "hasElumo")
with open("lib/shared/models/app_contact.dart", 'w') as f:
    f.write(contact_content)

# 3. Fix contacts_provider.dart
with open("lib/shared/providers/contacts_provider.dart", 'r') as f:
    provider_content = f.read()
provider_content = provider_content.replace("hasNautikOne", "hasElumo")
with open("lib/shared/providers/contacts_provider.dart", 'w') as f:
    f.write(provider_content)

# 4. Fix home_screen.dart
with open("lib/features/home/home_screen.dart", 'r') as f:
    home_content = f.read()

# Replace _buildPromoBanner() call with _buildCarouselBanner()
home_content = home_content.replace("_buildPromoBanner(),", "_buildCarouselBanner(),")

# Comment out / remove the redundant bottom security banner call
home_content = home_content.replace(
"""                    // ================= SECURITY BANNER =================
                    if (_showSecurityBanner) ...[
                      _buildSecurityBanner(),
                      const SizedBox(height: 24),
                    ],""",
"// Combined Security Banner into top Carousel"
)

with open("lib/features/home/home_screen.dart", 'w') as f:
    f.write(home_content)

print("Compilation fixes applied successfully.")
