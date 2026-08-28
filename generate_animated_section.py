import base64
import os

image_path = "/Users/raphaelgab-momoh/.gemini/antigravity/brain/13b53fa4-ead6-421d-8831-33d876290ba1/african_trader_elumo_1787949046442.jpg"

if not os.path.exists(image_path):
    print("Error: Generated image path does not exist.")
    exit(1)

with open(image_path, "rb") as image_file:
    encoded_string = base64.b64encode(image_file.read()).decode('utf-8')

# Write the widget code containing the base64 encoded image
widget_code = f"""
// ============================================================
// ANIMATED MERCHANT SPOTLIGHT (KEN BURNS SIMULATED VIDEO EFFECT)
// ============================================================
const String _merchantBase64 = "{encoded_string}";

class MerchantSpotlightSection extends StatefulWidget {{
  const MerchantSpotlightSection({{super.key}});

  @override
  State<MerchantSpotlightSection> createState() => _MerchantSpotlightSectionState();
}}

class _MerchantSpotlightSectionState extends State<MerchantSpotlightSection> with SingleTickerProviderStateMixin {{
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Alignment> _alignAnimation;

  @override
  void initState() {{
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 14),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _alignAnimation = AlignmentTween(
      begin: const Alignment(-0.05, -0.05),
      end: const Alignment(0.05, 0.05),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }}

  @override
  void dispose() {{
    _controller.dispose();
    super.dispose();
  }}

  @override
  Widget build(BuildContext context) {{
    return Container(
      width: double.infinity,
      color: brandNavy,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: LayoutBuilder(
            builder: (context, constraints) {{
              final mobile = constraints.maxWidth < 850;

              final imageWidget = Container(
                width: mobile ? double.infinity : 400,
                height: 400,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {{
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        alignment: _alignAnimation.value,
                        child: child,
                      );
                    }},
                    child: Image.memory(
                      base64Decode(_merchantBase64),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );

              final textWidget = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: brandCyan.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.movie_creation_outlined, color: brandCyan, size: 12),
                        SizedBox(width: 6),
                        Text(
                          'LIVE SPOTLIGHT',
                          style: TextStyle(color: brandCyan, fontSize: 9.5, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Powering Nigeria's retail merchants",
                    style: TextStyle(color: brandText, fontSize: 32, fontWeight: FontWeight.w900, height: 1.15),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '\"With ElumoPay, I can collect transfers from customers and pay my wholesale suppliers in seconds. The automated AI reconciliation matches my transactions without me lifting a finger.\"',
                    style: TextStyle(color: brandMuted, fontSize: 16, fontStyle: FontStyle.italic, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '— Funke Adebayo, Adebayo Finance & Retail',
                    style: TextStyle(color: brandText, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              );

              if (mobile) {{
                return Column(
                  children: [
                    imageWidget,
                    const SizedBox(height: 35),
                    textWidget,
                  ],
                );
              }}

              return Row(
                children: [
                  imageWidget,
                  const SizedBox(width: 60),
                  Expanded(child: textWidget),
                ],
              );
            }},
          ),
        ),
      ),
    );
  }}
}}
"""

# Read landing_screen.dart
landing_file = "lib/features/landing/landing_screen.dart"
with open(landing_file, 'r') as f:
    content = f.read()

# Inject MerchantSpotlightSection inside the column list of LandingScreen
content = content.replace(
    "          children: [\n            const Navbar(),\n            const HeroSection(),\n            const ProductShowcaseSection(),",
    "          children: [\n            const Navbar(),\n            const HeroSection(),\n            const MerchantSpotlightSection(),\n            const ProductShowcaseSection(),"
)

# Append the base64 widget code to the end of the file
content = content + "\n\n" + widget_code

with open(landing_file, 'w') as f:
    f.write(content)

print("Merchant spotlight injected with Base64 asset animation.")
