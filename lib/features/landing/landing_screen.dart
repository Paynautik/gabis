import 'package:flutter/material.dart';
import '../../shared/widgets/nautik_logo.dart';

// ============================================================
// BRAND COLOR PALETTE (from design spec)
// ============================================================
const Color kPrimary         = Color(0xFF006D44); // brand green (kept for accents)
const Color kButtonBlue      = Color(0xFF2563EB); // CTA button deep blue
const Color kOnPrimary       = Color(0xFFFFFFFF);
const Color kPrimaryContainer = Color(0xFF00B876);
const Color kSurface         = Color(0xFFF9F9FF);
const Color kCanvasLight     = Color(0xFFF8FAFC);
const Color kCanvasDark      = Color(0xFF090A10);
const Color kSurfaceDark     = Color(0xFF131520);
const Color kOnBackground    = Color(0xFF141B2C);
const Color kOnSurfaceVariant= Color(0xFF3C4A41);
const Color kBorderLight     = Color(0xFFEDF0F5);
const Color kBorderDark      = Color(0xFF222436);
const Color kSurfaceContainerLow  = Color(0xFFF1F3FF);
const Color kSurfaceContainerLowest = Color(0xFFFFFFFF);
const Color kSurfaceContainer= Color(0xFFE9EDFF);
const Color kSurfaceContainerHigh = Color(0xFFE0E8FF);
const Color kSurfaceVariant  = Color(0xFFDBE2F9);
const Color kSecondaryContainer = Color(0xFF316BF3);
const Color kOutline         = Color(0xFF6C7B70);
const Color kSuccessGreen    = Color(0xFF16A34A);
const Color kWarningAmber    = Color(0xFFF59E0B);
const Color kSecondary       = Color(0xFF0051D5);

// ============================================================
// LANDING SCREEN ENTRY
// ============================================================
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCanvasLight,
      body: SingleChildScrollView(
        child: Column(
          children: const [
            _TopNavBar(),
            _HeroSection(),
            _AILayerSection(),
            _ComplianceSection(),
            _TrustBarSection(),
            _CorporateCardsSection(),
            _FooterSection(),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// TOP NAV BAR
// ============================================================
class _TopNavBar extends StatelessWidget {
  const _TopNavBar();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final mobile = w < 850;
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: kCanvasLight.withOpacity(0.92),
        border: const Border(bottom: BorderSide(color: kBorderLight)),
      ),
      padding: EdgeInsets.symmetric(horizontal: mobile ? 20 : 70),
      child: Row(
        children: [
          // Logo
          Row(
            children: const [
              NautikLogoMark(size: 32),
              SizedBox(width: 10),
              Text(
                'ElumoPay',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: kOnBackground,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Nav links (desktop only)
          if (!mobile) ...[
            _NavLink('Features', '#features'),
            const SizedBox(width: 32),
            _NavLink('AI Layer', '#ai-layer'),
            const SizedBox(width: 32),
            _NavLink('Compliance', '#compliance'),
            const SizedBox(width: 32),
            _NavLink('Cards', '#cards'),
            const SizedBox(width: 32),
          ],
          // Actions
          if (!mobile)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                'Log In',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: kOnBackground,
                ),
              ),
            ),
          _PillButton(
            label: 'Get Started',
            onTap: () {},
            filled: true,
          ),
        ],
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final String href;
  const _NavLink(this.label, this.href);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: kOnSurfaceVariant,
      ),
    );
  }
}

class _PillButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool filled;
  final bool outline;
  final Color? fillColor;
  final Color? textColor;
  const _PillButton({
    required this.label,
    required this.onTap,
    this.filled = false,
    this.outline = false,
    this.fillColor,
    this.textColor,
  });

  @override
  State<_PillButton> createState() => _PillButtonState();
}

class _PillButtonState extends State<_PillButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.filled ? (widget.fillColor ?? kButtonBlue) : Colors.transparent;
    final fg = widget.textColor ?? (widget.filled ? kOnPrimary : kOnBackground);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _hovered ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 28),
            decoration: BoxDecoration(
              color: _hovered && widget.filled ? bg.withOpacity(0.88) : bg,
              border: widget.outline
                  ? Border.all(color: kOutline, width: 1.5)
                  : null,
              borderRadius: BorderRadius.circular(9999),
            ),
            alignment: Alignment.center,
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: fg,
                letterSpacing: -0.1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// HERO SECTION
// ============================================================
class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final mobile = w < 900;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: mobile ? 20 : 70,
        vertical: mobile ? 60 : 100,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kCanvasLight, kSurfaceContainer],
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: mobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeroText(),
                  const SizedBox(height: 40),
                  _HeroImage(),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: _HeroText()),
                  const SizedBox(width: 48),
                  Expanded(child: _HeroImage()),
                ],
              ),
      ),
    );
  }
}

class _HeroText extends StatelessWidget {
  const _HeroText();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final mobile = w < 900;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Label chip above headline ──
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: kButtonBlue.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(9999),
            border: Border.all(color: kButtonBlue.withValues(alpha: 0.2)),
          ),
          child: const Text(
            'Built for Africa. Made for Everyone.',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: kButtonBlue,
              letterSpacing: 0.2,
            ),
          ),
        ),
        const SizedBox(height: 20),
        // ── Headline: two tight single lines ──
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            'Send. Get Paid. Grow.',
            maxLines: 1,
            style: TextStyle(
              fontSize: mobile ? 40 : 56,
              fontWeight: FontWeight.w900,
              color: kOnBackground,
              letterSpacing: mobile ? -1.4 : -2.5,
              height: 1.05,
            ),
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            'Your Money, Your Way.',
            maxLines: 1,
            style: TextStyle(
              fontSize: mobile ? 40 : 56,
              fontWeight: FontWeight.w900,
              color: kPrimary,
              letterSpacing: mobile ? -1.4 : -2.5,
              height: 1.1,
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Whether you run a business or just want smarter money — ElumoPay lets you send money, get paid instantly, pay bills, track spending, and stay tax-compliant, all in one place.',
          style: TextStyle(
            fontSize: 17,
            height: 1.65,
            color: kOnSurfaceVariant,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 32),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _PillButton(label: 'Get Started for Free', onTap: () {}, filled: true),
            _OutlineButton(label: 'Watch Demo', icon: Icons.play_circle_rounded, onTap: () {}),
          ],
        ),
      ],
    );
  }
}

class _OutlineButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _OutlineButton({required this.label, required this.icon, required this.onTap});

  @override
  State<_OutlineButton> createState() => _OutlineButtonState();
}

class _OutlineButtonState extends State<_OutlineButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: _hovered ? kSurfaceContainerLow : Colors.transparent,
            border: Border.all(color: kOutline, width: 1.5),
            borderRadius: BorderRadius.circular(9999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: kOnBackground, size: 20),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: kOnBackground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  const _HeroImage();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final mobile = w < 900;

    // Fixed dimensions matching the reference composition
    const double compositionH = 640.0;
    const double photoW       = 340.0;   // person card width
    const double phoneScale   = 1.0;     // full size phone

    return SizedBox(
      width: double.infinity,
      height: mobile ? 520 : compositionH,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Person photo card (left, behind) ──
          Positioned(
            left: 0,
            top: mobile ? 20 : 0,
            bottom: 0,
            child: Container(
              width: mobile ? 200 : photoW,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.22),
                    blurRadius: 48,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                'hero_person.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  decoration: const BoxDecoration(color: Color(0xFF1E293B)),
                ),
              ),
            ),
          ),

          // ── Phone mockup (right, in front) — same height as photo ──
          Positioned(
            right: mobile ? -10 : 0,
            top: mobile ? 0 : 20,
            bottom: mobile ? 20 : 0,
            child: Transform.scale(
              scale: mobile ? 0.72 : phoneScale,
              alignment: Alignment.centerRight,
              child: const _PhoneMockup(),
            ),
          ),

          // ── "Used by 12,000+ sellers" social proof badge ──
          Positioned(
            bottom: 28,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Stacked avatar dots
                  SizedBox(
                    width: 52,
                    height: 24,
                    child: Stack(
                      children: List.generate(3, (i) => Positioned(
                        left: i * 16.0,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: [kButtonBlue, kPrimary, kWarningAmber][i],
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Center(
                            child: Text(
                              ['A', 'K', 'O'][i],
                              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                      )),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text('12,000+ sellers', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: kOnBackground)),
                      Text('across Africa', style: TextStyle(fontSize: 10, color: kOnSurfaceVariant)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// REALISTIC 2026 PHONE MOCKUP
// ============================================================
class _PhoneMockup extends StatelessWidget {
  const _PhoneMockup();

  @override
  Widget build(BuildContext context) {
    const double phoneW = 310;
    const double phoneH = 600;
    const double cornerRadius = 48.0;

    return SizedBox(
      width: phoneW + 16,
      height: phoneH + 16,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ── Drop shadow beneath phone ──
          Container(
            width: phoneW,
            height: phoneH,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(cornerRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 80,
                  spreadRadius: 10,
                  offset: const Offset(0, 30),
                ),
                BoxShadow(
                  color: kPrimary.withValues(alpha: 0.12),
                  blurRadius: 60,
                  spreadRadius: 0,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
          ),

          // ── Left hardware buttons (volume + silent) ──
          Positioned(
            left: 0,
            top: 130,
            child: Column(
              children: [
                // Silent toggle
                Container(
                  width: 4,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A4A52),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 14),
                // Volume up
                Container(
                  width: 4,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A4A52),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 10),
                // Volume down
                Container(
                  width: 4,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A4A52),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
          ),

          // ── Right power/lock button ──
          Positioned(
            right: 0,
            top: 160,
            child: Container(
              width: 4,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF4A4A52),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // ── Titanium chassis (outer ring) ──
          Container(
            width: phoneW,
            height: phoneH,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(cornerRadius),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF6E6E73),
                  Color(0xFF3A3A3C),
                  Color(0xFF5A5A60),
                  Color(0xFF2C2C2E),
                ],
                stops: [0.0, 0.35, 0.65, 1.0],
              ),
            ),
          ),

          // ── Glass screen inset (inner bezel) ──
          Positioned(
            top: 6,
            left: 6,
            right: 6,
            bottom: 6,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(cornerRadius - 6),
                color: const Color(0xFF050508),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  // App screen content
                  const _MockAppScreen(),

                  // ── Glossy glass sheen overlay ──
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 180,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.07),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── Dynamic Island (pill notch) ──
                  Positioned(
                    top: 14,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 108,
                        height: 33,
                        decoration: BoxDecoration(
                          color: const Color(0xFF050508),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF2A2A2E),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Front camera dot
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1C1C1E),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF3A3A3C),
                                  width: 1,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            // Infrared/Face ID sensor
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF2C2C2E),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ── Home indicator bar ──
                  Positioned(
                    bottom: 8,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 120,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MockAppScreen extends StatelessWidget {
  const _MockAppScreen();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0A0F1E),
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Greeting row ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Good morning', style: TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w500)),
                  SizedBox(height: 2),
                  Text('Adebayo', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
                ],
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [kPrimary, Color(0xFF00A86B)]),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // ── Main balance card ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF006D44), Color(0xFF00A86B), Color(0xFF004D32)],
                stops: [0, 0.55, 1],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: kPrimary.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Total Revenue', style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                    Text('EP', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('₦2,847,500', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.8)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text('+18.4%', style: TextStyle(color: Color(0xFF6DFCB3), fontSize: 10, fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(width: 6),
                    const Text('vs last month', style: TextStyle(color: Colors.white38, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Stat chips ──
          Row(
            children: [
              Expanded(child: _StatChip('Outstanding', '₦340K', kWarningAmber)),
              const SizedBox(width: 10),
              Expanded(child: _StatChip('Reconciled', '97%', kSuccessGreen)),
            ],
          ),
          const SizedBox(height: 18),

          // ── Transactions header ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Transactions', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: -0.2)),
              Text('See all', style: TextStyle(color: Color(0xFF00B876), fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          _TxnRow('Sarah Okafor', 'Payment received', '+₦85,000', true),
          const SizedBox(height: 10),
          _TxnRow('Chukwuemeka Ltd', 'Instalment #2/4', '+₦45,000', true),
          const SizedBox(height: 10),
          _TxnRow('FIRS - VAT Q3', 'Tax remittance', '-₦12,500', false),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  const _StatChip(this.label, this.value, this.valueColor);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1F2937), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: valueColor, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: -0.3)),
        ],
      ),
    );
  }
}

class _TxnRow extends StatelessWidget {
  final String name;
  final String desc;
  final String amount;
  final bool positive;
  const _TxnRow(this.name, this.desc, this.amount, this.positive);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: positive
                ? kSuccessGreen.withValues(alpha: 0.12)
                : kWarningAmber.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            positive ? Icons.south_west_rounded : Icons.north_east_rounded,
            color: positive ? kSuccessGreen : kWarningAmber,
            size: 15,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
              Text(desc, style: const TextStyle(color: Color(0xFF4B5563), fontSize: 10)),
            ],
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            color: positive ? kSuccessGreen : const Color(0xFFF87171),
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// AI LAYER SECTION
// ============================================================
class _AILayerSection extends StatelessWidget {
  const _AILayerSection();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final mobile = w < 850;
    return Container(
      color: kSurfaceContainerLowest,
      padding: EdgeInsets.symmetric(horizontal: mobile ? 20 : 70, vertical: 80),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: kOnBackground, letterSpacing: -1.5),
                children: [
                  TextSpan(text: 'The '),
                  TextSpan(text: 'AI Layer', style: TextStyle(color: kPrimary)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Supercharge your operations with intelligent tools built for modern African businesses.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: kOnSurfaceVariant, height: 1.6),
            ),
            const SizedBox(height: 56),
            mobile
                ? Column(
                    children: [
                      _AICard(icon: Icons.auto_awesome_rounded, title: 'Gemini Reconciliation Engine', body: 'Automatically map bank transfers to invoices with unparalleled accuracy. Eliminate manual entry and balance your books instantly.'),
                      const SizedBox(height: 24),
                      _AICard(icon: Icons.record_voice_over_rounded, title: 'AI Voice Reminders', body: 'Deploy automated robot calls for gentle debt collection and payment reminders in local accents and dialects.'),
                      const SizedBox(height: 24),
                      _AICard(icon: Icons.receipt_long_rounded, title: 'AI Invoice Assistant', body: 'Create, send, and track professional invoices using simple natural language commands right from your mobile device.'),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _AICard(icon: Icons.auto_awesome_rounded, title: 'Gemini Reconciliation Engine', body: 'Automatically map bank transfers to invoices with unparalleled accuracy. Eliminate manual entry and balance your books instantly.')),
                      const SizedBox(width: 24),
                      Expanded(child: _AICard(icon: Icons.record_voice_over_rounded, title: 'AI Voice Reminders', body: 'Deploy automated robot calls for gentle debt collection and payment reminders in local accents and dialects.')),
                      const SizedBox(width: 24),
                      Expanded(child: _AICard(icon: Icons.receipt_long_rounded, title: 'AI Invoice Assistant', body: 'Create, send, and track professional invoices using simple natural language commands right from your mobile device.')),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}

class _AICard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const _AICard({required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: kSurface,
        border: Border.all(color: kBorderLight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: kPrimaryContainer.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: kPrimary, size: 24),
          ),
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kOnBackground, letterSpacing: -0.4)),
          const SizedBox(height: 12),
          Text(body, style: const TextStyle(fontSize: 15, color: kOnSurfaceVariant, height: 1.6)),
        ],
      ),
    );
  }
}

// ============================================================
// COMPLIANCE SECTION
// ============================================================
class _ComplianceSection extends StatelessWidget {
  const _ComplianceSection();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final mobile = w < 900;
    return Container(
      decoration: const BoxDecoration(
        color: kSurfaceContainerLow,
        border: Border.symmetric(horizontal: BorderSide(color: kBorderLight)),
      ),
      padding: EdgeInsets.symmetric(horizontal: mobile ? 20 : 70, vertical: 80),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: mobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ComplianceText(),
                  const SizedBox(height: 40),
                  _ComplianceVisual(),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: _ComplianceText()),
                  const SizedBox(width: 60),
                  Expanded(child: _ComplianceVisual()),
                ],
              ),
      ),
    );
  }
}

class _ComplianceText extends StatelessWidget {
  const _ComplianceText();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final mobile = w < 900;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Compliance Built-In',
          style: TextStyle(
            fontSize: mobile ? 36 : 48,
            fontWeight: FontWeight.w900,
            color: kOnBackground,
            letterSpacing: -1.5,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Stay on the right side of the law without the headache. ElumoPay automates tax calculation and remittance across major African markets.',
          style: TextStyle(fontSize: 18, color: kOnSurfaceVariant, height: 1.6),
        ),
        const SizedBox(height: 36),
        Wrap(
          spacing: 24,
          runSpacing: 16,
          children: const [
            _ComplianceItem('Nigeria (FIRS)'),
            _ComplianceItem('Kenya (KRA)'),
            _ComplianceItem('Ghana (GRA)'),
            _ComplianceItem('South Africa (SARS)'),
          ],
        ),
      ],
    );
  }
}

class _ComplianceItem extends StatelessWidget {
  final String label;
  const _ComplianceItem(this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle_rounded, color: kSuccessGreen, size: 22),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kOnBackground)),
      ],
    );
  }
}

class _ComplianceVisual extends StatelessWidget {
  const _ComplianceVisual();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: kCanvasDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorderDark),
        boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 24, offset: Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Q3 Tax Remittance', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
              Row(
                children: const [
                  Icon(Icons.verified_rounded, color: kSuccessGreen, size: 16),
                  SizedBox(width: 4),
                  Text('Completed', style: TextStyle(color: kSuccessGreen, fontSize: 12, fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
          const Divider(color: kBorderDark, height: 32),
          _TaxLine('Value Added Tax (VAT)', '\$4,250.00'),
          const SizedBox(height: 16),
          _TaxLine('Withholding Tax', '\$1,120.00'),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(9999),
            child: const LinearProgressIndicator(
              value: 1.0,
              minHeight: 10,
              backgroundColor: kBorderDark,
              valueColor: AlwaysStoppedAnimation<Color>(kPrimary),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Automatically calculated and filed on Oct 15, 2024',
            style: TextStyle(color: kOnSurfaceVariant, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _TaxLine extends StatelessWidget {
  final String label;
  final String amount;
  const _TaxLine(this.label, this.amount);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 14)),
        Text(amount, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

// ============================================================
// TRUST BAR SECTION
// ============================================================
class _TrustBarSection extends StatelessWidget {
  const _TrustBarSection();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final mobile = w < 700;
    return Container(
      color: kSurfaceContainerLowest,
      padding: EdgeInsets.symmetric(horizontal: mobile ? 20 : 70, vertical: 56),
      child: Column(
        children: [
          const Text(
            'TRUSTED BY GLOBAL PARTNERS',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.0,
              color: kOutline,
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 48,
            runSpacing: 24,
            children: const [
              _TrustBadge(Icons.account_balance_rounded, 'BankCorp'),
              _TrustBadge(Icons.security_rounded, 'SecurePay'),
              _TrustBadge(Icons.language_rounded, 'GlobalX'),
              _TrustBadge(Icons.verified_rounded, 'Verified Trust'),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrustBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _TrustBadge(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.5,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28, color: kOnBackground),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kOnBackground)),
        ],
      ),
    );
  }
}

// ============================================================
// CORPORATE CARDS SECTION
// ============================================================
class _CorporateCardsSection extends StatelessWidget {
  const _CorporateCardsSection();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final mobile = w < 900;
    return Padding(
      padding: EdgeInsets.fromLTRB(mobile ? 20 : 70, 0, mobile ? 20 : 70, 80),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Container(
          decoration: BoxDecoration(
            color: kSurfaceDark,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: kBorderDark),
            boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 40, offset: Offset(0, 16))],
          ),
          clipBehavior: Clip.antiAlias,
          child: mobile
              ? Column(
                  children: [
                    Padding(padding: const EdgeInsets.all(40), child: _CardsText()),
                    _StackedCards(mobile: true),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: Padding(padding: const EdgeInsets.all(72), child: _CardsText())),
                    SizedBox(height: 500, width: 420, child: _StackedCards(mobile: false)),
                  ],
                ),
        ),
      ),
    );
  }
}

class _CardsText extends StatelessWidget {
  const _CardsText();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1, height: 1.15),
            children: [
              TextSpan(text: 'Corporate Cards for '),
              TextSpan(text: 'Your Team', style: TextStyle(color: kPrimary)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Issue physical and virtual cards instantly. Control spend with custom limits, track expenses in real-time, and empower your team to move faster while staying on budget.',
          style: TextStyle(fontSize: 16, color: kSurfaceVariant, height: 1.6),
        ),
        const SizedBox(height: 32),
        _PillButton(label: 'Issue Corporate Cards', onTap: () {}, filled: true),
      ],
    );
  }
}

class _StackedCards extends StatelessWidget {
  final bool mobile;
  const _StackedCards({required this.mobile});

  @override
  Widget build(BuildContext context) {
    if (mobile) {
      return SizedBox(
        height: 280,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Positioned(left: 20, bottom: 20, child: _VirtualCard(color: kSecondaryContainer, teamLabel: 'Sales', rotate: 6, logoInvert: true)),
            Positioned(left: 10, bottom: 10, child: _VirtualCard(color: kWarningAmber, teamLabel: 'Ops', rotate: 0, logoInvert: false)),
            Positioned(right: 20, bottom: 20, child: _VirtualCard(color: kPrimary, teamLabel: 'Mktg', rotate: -6, logoInvert: true)),
            Positioned(right: 10, bottom: 10, child: _VirtualCard(color: kSurfaceVariant, teamLabel: 'Corp', rotate: -12, logoInvert: false)),
          ],
        ),
      );
    }
    return SizedBox.expand(
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned(right: -30, top: 80, child: _VirtualCard(color: kSurfaceVariant, teamLabel: 'Corporate', rotate: -12, logoInvert: false)),
          Positioned(right: -10, top: 90, child: _VirtualCard(color: kPrimary, teamLabel: 'Marketing', rotate: -6, logoInvert: true)),
          Positioned(right: 10, top: 100, child: _VirtualCard(color: kWarningAmber, teamLabel: 'Operations', rotate: 0, logoInvert: false)),
          Positioned(right: 30, top: 110, child: _VirtualCard(color: kSecondaryContainer, teamLabel: 'Sales', rotate: 6, logoInvert: true)),
        ],
      ),
    );
  }
}

class _VirtualCard extends StatelessWidget {
  final Color color;
  final String teamLabel;
  final double rotate;
  final bool logoInvert;
  const _VirtualCard({required this.color, required this.teamLabel, required this.rotate, required this.logoInvert});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotate * 3.14159 / 180,
      child: Container(
        width: 280,
        height: 168,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 20, offset: Offset(0, 8))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('EP', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.white)),
                Text(
                  teamLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: logoInvert ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.5),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                'VISA',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 1,
                  color: logoInvert ? Colors.white : Colors.black.withOpacity(0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// FOOTER SECTION
// ============================================================
class _FooterSection extends StatelessWidget {
  const _FooterSection();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final mobile = w < 700;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: mobile ? 20 : 70, vertical: 80),
      decoration: const BoxDecoration(
        color: kCanvasLight,
        border: Border(top: BorderSide(color: kBorderLight)),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: mobile
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FooterBrand(),
                  const SizedBox(height: 40),
                  Wrap(
                    spacing: 40,
                    runSpacing: 32,
                    children: const [
                      _FooterCol('Product', ['Payments', 'Corporate Cards', 'API Docs']),
                      _FooterCol('Company', ['About Us', 'Careers', 'Blog']),
                      _FooterCol('Legal', ['Privacy Policy', 'Terms of Service', 'Compliance']),
                      _FooterCol('Support', ['Help Center', 'Contact Us', 'Status']),
                    ],
                  ),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _FooterBrand()),
                  const Expanded(child: _FooterCol('Product', ['Payments', 'Corporate Cards', 'API Docs'])),
                  const Expanded(child: _FooterCol('Company', ['About Us', 'Careers', 'Blog'])),
                  const Expanded(child: _FooterCol('Legal', ['Privacy Policy', 'Terms of Service', 'Compliance'])),
                  const Expanded(child: _FooterCol('Support', ['Help Center', 'Contact Us', 'Status'])),
                ],
              ),
      ),
    );
  }
}

class _FooterBrand extends StatelessWidget {
  const _FooterBrand();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            NautikLogoMark(size: 30),
            SizedBox(width: 8),
            Text('ElumoPay', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: kOnBackground)),
          ],
        ),
        SizedBox(height: 16),
        SizedBox(
          width: 240,
          child: Text(
            '© 2024 Elumopay Technologies. All rights reserved. The Pan-African Business Operating System.',
            style: TextStyle(fontSize: 12, color: kOnSurfaceVariant, height: 1.6),
          ),
        ),
      ],
    );
  }
}

class _FooterCol extends StatelessWidget {
  final String heading;
  final List<String> links;
  const _FooterCol(this.heading, this.links);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(heading, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: kOnBackground)),
        const SizedBox(height: 12),
        ...links.map((l) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(l, style: const TextStyle(fontSize: 12, color: kOnSurfaceVariant, fontWeight: FontWeight.w500)),
        )),
      ],
    );
  }
}
