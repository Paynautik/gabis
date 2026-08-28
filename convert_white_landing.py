filepath = "lib/features/landing/landing_screen.dart"
with open(filepath, 'r') as f:
    content = f.read()

# 1. Update the Brand Color Palette variables
old_palette = """// ============================================================
// BRAND COLOR PALETTE (PREMIUM DARK HYBRID)
// ============================================================
const Color brandNavy = Color(0xFF030712); // Obsidian Black
const Color brandSlate = Color(0xFF0F172A); // Dark Slate container
const Color brandGreen = Color(0xFF10B981); // Emerald Green accent
const Color brandCyan = Color(0xFF22D3EE); // Neon Cyan highlight
const Color brandBlue = Color(0xFF2563EB); // Royal Blue brand
const Color brandMuted = Color(0xFF94A3B8); // Muted grey text"""

new_palette = """// ============================================================
// BRAND COLOR PALETTE (PREMIUM LIGHT HYBRID)
// ============================================================
const Color brandNavy = Colors.white; // Main white background
const Color brandSlate = Color(0xFFF8FAFC); // Light slate container
const Color brandGreen = Color(0xFF10B981); // Emerald Green accent
const Color brandCyan = Color(0xFF0284C7); // High contrast sky blue
const Color brandBlue = Color(0xFF2563EB); // Royal Blue brand
const Color brandMuted = Color(0xFF475569); // Muted dark slate text
const Color brandText = Color(0xFF0F172A); // Heading text color"""

content = content.replace(old_palette, new_palette)

# 2. Update Navbar text color
content = content.replace(
    "style: TextStyle(\n                      fontSize: 22,\n                      fontWeight: FontWeight.w900,\n                      color: Colors.white,",
    "style: TextStyle(\n                      fontSize: 22,\n                      fontWeight: FontWeight.w900,\n                      color: brandText,"
)

# 3. Update Hero heading text color
content = content.replace(
    "            color: Colors.white,\n            letterSpacing: -1.2,",
    "            color: brandText,\n            letterSpacing: -1.2,"
)

# 4. Update Product Showcase text colors
content = content.replace(
    "style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900),",
    "style: TextStyle(color: brandText, fontSize: 36, fontWeight: FontWeight.w900),"
)
content = content.replace(
    "style: TextStyle(color: isSelected ? Colors.white : brandMuted, fontWeight: FontWeight.bold, fontSize: 13)",
    "style: TextStyle(color: isSelected ? brandText : brandMuted, fontWeight: FontWeight.bold, fontSize: 13)"
)
content = content.replace(
    "const Text('Visa Platinum cards with instant freeze', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),",
    "const Text('Visa Platinum cards with instant freeze', style: TextStyle(color: brandText, fontSize: 20, fontWeight: FontWeight.w900)),"
)
content = content.replace(
    "const Text('Instant multi-currency exchange conversion', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),",
    "const Text('Instant multi-currency exchange conversion', style: TextStyle(color: brandText, fontSize: 20, fontWeight: FontWeight.w900)),"
)
content = content.replace(
    "const Text('Frictionless, instant bill settlements', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),",
    "const Text('Frictionless, instant bill settlements', style: TextStyle(color: brandText, fontSize: 20, fontWeight: FontWeight.w900)),"
)
content = content.replace(
    "const Text('Card Status:', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),",
    "const Text('Card Status:', style: TextStyle(color: brandText, fontSize: 13, fontWeight: FontWeight.bold)),"
)
content = content.replace(
    "const Text('FX Rate:', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),",
    "const Text('FX Rate:', style: TextStyle(color: brandText, fontSize: 13, fontWeight: FontWeight.bold)),"
)
content = content.replace(
    "const Text('Processing Time:', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),",
    "const Text('Processing Time:', style: TextStyle(color: brandText, fontSize: 13, fontWeight: FontWeight.bold)),"
)

# 5. Update Business Section text colors
content = content.replace(
    "style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900),",
    "style: TextStyle(color: brandText, fontSize: 36, fontWeight: FontWeight.w900),"
)
content = content.replace(
    "style: TextStyle(\n                            color: Colors.white,\n                            fontWeight: FontWeight.w900,\n                            letterSpacing: 1,\n                          ),",
    "style: TextStyle(\n                            color: brandText,\n                            fontWeight: FontWeight.w900,\n                            letterSpacing: 1,\n                          ),"
)
content = content.replace(
    "value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900,),",
    "value, style: const TextStyle(color: brandText, fontSize: 24, fontWeight: FontWeight.w900,),"
)
content = content.replace(
    "style: const TextStyle(\n              color: Colors.white,\n              fontSize: 24,\n              fontWeight: FontWeight.w900,\n            ),",
    "style: const TextStyle(\n              color: brandText,\n              fontSize: 24,\n              fontWeight: FontWeight.w900,\n            ),"
)

# 6. Update Developer Section text colors
content = content.replace(
    "color: Colors.white,\n                    ),",
    "color: brandText,\n                    ),"
)

# 7. Update Trust Section text colors
content = content.replace(
    "style: const TextStyle(\n                  fontWeight: FontWeight.w900,\n                  fontSize: 18,\n                  color: Colors.white,\n                ),",
    "style: const TextStyle(\n                  fontWeight: FontWeight.w900,\n                  fontSize: 18,\n                  color: brandText,\n                ),"
)
content = content.replace(
    "style: const TextStyle(\n            color: Colors.white,\n            fontSize: 36,\n            height: 1.1,\n            fontWeight: FontWeight.w900,\n          ),",
    "style: const TextStyle(\n            color: brandText,\n            fontSize: 36,\n            height: 1.1,\n            fontWeight: FontWeight.w900,\n          ),"
)

# 8. Update CTA Section text colors
content = content.replace(
    "style: TextStyle(\n              color: Colors.white,\n              fontSize: 48,\n              fontWeight: FontWeight.w900,\n            ),",
    "style: TextStyle(\n              color: brandText,\n              fontSize: 48,\n              fontWeight: FontWeight.w900,\n            ),"
)

# 9. Update Footer text colors
content = content.replace(
    "style: TextStyle(\n              color: Colors.white,\n              fontSize: 22,\n              fontWeight: FontWeight.w900,\n            ),",
    "style: TextStyle(\n              color: brandText,\n              fontSize: 22,\n              fontWeight: FontWeight.w900,\n            ),"
)
content = content.replace(
    "color: const Color(0xFF020617), // Deepest black footer",
    "color: const Color(0xFFF1F5F9), // Light grey footer"
)

with open(filepath, 'w') as f:
    f.write(content)

print("White landing page conversion complete.")
