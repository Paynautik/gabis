import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../shared/widgets/nautik_logo.dart';

// ─── Brand Colors (ElumoPay Official Palette) ─────────────────────────────────
const Color kElumoGreen       = Color(0xFF00C16A); // Vibrant ElumoPay Green
const Color kElumoBlue        = Color(0xFF2563EB); // Signature Cobalt Blue
const Color kElumoAmber       = Color(0xFFF59E0B); // Warm Gold / Amber Accent
const Color kElumoDeepGreen   = Color(0xFF006D44); // Deep Forest Green
const Color kElumoDark        = Color(0xFF0B0F1A); // Slate Black / Dark
const Color kElumoNavy        = Color(0xFF141B2C); // Soft Dark Charcoal
const Color kElumoSurface     = Color(0xFFFFFFFF);
const Color kElumoCanvas      = Color(0xFFF8FAFC); // Main page background
const Color kElumoMuted       = Color(0xFF64748B); // Slate 500
const Color kElumoBorder      = Color(0xFFE2E8F0); // Slate 200

// Pastel Card Backgrounds (ElumoPay brand tints)
const Color kPastelMint       = Color(0xFFDCFCE7); // Elumo Green Pastel
const Color kPastelBlue       = Color(0xFFDBEAFE); // Elumo Blue Pastel
const Color kPastelAmber      = Color(0xFFFEF3C7); // Elumo Amber Pastel
const Color kPastelIndigo     = Color(0xFFEDE9FE); // Elumo Indigo Pastel

// ─── Navigation Global Keys ───────────────────────────────────────────────────
final _walletsKey     = GlobalKey();
final _usdAccountKey  = GlobalKey();
final _transfersKey   = GlobalKey();
final _cardsKey       = GlobalKey();
final _billsKey       = GlobalKey();
final _complianceKey  = GlobalKey();

// ============================================================================
// MAIN LANDING SCREEN
// ============================================================================
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const _NavHeader(),
            const _HeroSection(),
            _PastelFeatureSection(
              key: _walletsKey,
              backgroundColor: kPastelMint,
              titlePrefix: 'One Account,\n',
              titleHighlight: 'Multiple Currencies.',
              titleSuffix: '\nNo borders.',
              description: 'Manage NGN, USD, GBP, and EUR seamlessly. Track customer installment plans, send automated reminders, and collect payments effortlessly.',
              linkText: 'Open a Multi-Currency Account →',
              isImageRight: true,
              screenType: _MockupType.walletBalances,
            ),
            _PastelFeatureSection(
              key: _usdAccountKey,
              backgroundColor: kPastelBlue,
              titlePrefix: 'Open a USD bank\n',
              titleHighlight: 'account in minutes',
              titleSuffix: '',
              description: 'Get dedicated US routing and account numbers. Receive payments from global clients, platforms, and employers with zero friction.',
              linkText: 'Get a USD Account →',
              isImageRight: false,
              screenType: _MockupType.usdAccount,
            ),
            _PastelFeatureSection(
              key: _transfersKey,
              backgroundColor: kPastelAmber,
              titlePrefix: 'Smart Invoicing &\n',
              titleHighlight: 'Global Transfers',
              titleSuffix: '',
              description: 'Generate professional invoices, track installments for schools and businesses, and move funds across Africa and beyond at real-time rates.',
              linkText: 'Explore Invoicing & Transfers →',
              isImageRight: true,
              screenType: _MockupType.smartInvoices,
            ),
            _PastelFeatureSection(
              backgroundColor: kPastelIndigo,
              titlePrefix: 'Instant Currency\n',
              titleHighlight: 'conversion at best value',
              titleSuffix: '',
              description: 'Swap between African and global currencies instantly with transparent, bank-beating FX rates and zero hidden charges.',
              linkText: 'View Live Exchange Rates →',
              isImageRight: false,
              screenType: _MockupType.currencySwap,
            ),
            _DarkShowcaseSection(key: _cardsKey),
            _BillsPaymentSection(key: _billsKey),
            _SecurityComplianceSection(key: _complianceKey),
            const _DownloadCtaSection(),
            const _FooterSection(),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 1. NAVIGATION HEADER
// ============================================================================
class _NavHeader extends StatelessWidget {
  const _NavHeader();

  void _scrollTo(GlobalKey key) {
    if (key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Container(
      height: 76,
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 64 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.black.withOpacity(0.06))),
      ),
      child: Row(
        children: [
          Row(
            children: [
              const NautikLogoMark(size: 32),
              const SizedBox(width: 10),
              const Text(
                'ElumoPay',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: kElumoDark,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (isDesktop) ...[
            _NavLink('Accounts & FX', onTap: () => _scrollTo(_walletsKey)),
            const SizedBox(width: 28),
            _NavLink('USD Banking', onTap: () => _scrollTo(_usdAccountKey)),
            const SizedBox(width: 28),
            _NavLink('Smart Invoices', onTap: () => _scrollTo(_transfersKey)),
            const SizedBox(width: 28),
            _NavLink('Virtual Cards', onTap: () => _scrollTo(_cardsKey)),
            const SizedBox(width: 28),
            _NavLink('Bill Payments', onTap: () => _scrollTo(_billsKey)),
            const SizedBox(width: 28),
            _NavLink('Security & Tax', onTap: () => _scrollTo(_complianceKey)),
            const SizedBox(width: 36),
            _TextButton(
              'Log In',
              onTap: () => Navigator.pushNamed(context, '/login'),
            ),
            const SizedBox(width: 14),
          ],
          _PrimaryPillButton(
            'Get Started',
            onTap: () => Navigator.pushNamed(context, '/login'),
            backgroundColor: kElumoGreen,
          ),
        ],
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  final String title;
  final VoidCallback onTap;
  const _NavLink(this.title, {required this.onTap});

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Text(
          widget.title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _hovered ? kElumoGreen : const Color(0xFF4B5563),
          ),
        ),
      ),
    );
  }
}

class _TextButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _TextButton(this.text, {required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: Text(
        text,
        style: const TextStyle(
          color: kElumoDark,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _PrimaryPillButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color textColor;
  const _PrimaryPillButton(
    this.text, {
    required this.onTap,
    this.backgroundColor = kElumoGreen,
    this.textColor = Colors.white,
  });

  @override
  State<_PrimaryPillButton> createState() => _PrimaryPillButtonState();
}

class _PrimaryPillButtonState extends State<_PrimaryPillButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: _hovered ? widget.backgroundColor.withOpacity(0.9) : widget.backgroundColor,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            widget.text,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: widget.textColor,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 2. HERO SECTION (ElumoPay Vibrant Green & Cobalt Palette)
// ============================================================================
class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Color(0xFFF0FDF4), // Mint wash
            Color(0xFFF8FAFC),
          ],
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64 : 20,
        vertical: isDesktop ? 60 : 40,
      ),
      child: Column(
        children: [
          // Badge Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: kElumoGreen.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kElumoGreen.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bolt_rounded, color: kElumoGreen, size: 16),
                const SizedBox(width: 6),
                const Text(
                  "Africa's All-in-One Borderless Money Platform",
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: kElumoGreen,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Main Multi-Color Headline (ElumoPay Colors)
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'Instant ',
                  style: TextStyle(
                    color: kElumoGreen,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.5,
                  ),
                ),
                const TextSpan(
                  text: 'Payments\n',
                  style: TextStyle(
                    color: kElumoDark,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.5,
                  ),
                ),
                const TextSpan(
                  text: 'Anywhere',
                  style: TextStyle(
                    color: kElumoBlue,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.5,
                  ),
                ),
                const TextSpan(
                  text: ', ',
                  style: TextStyle(
                    color: kElumoAmber,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const TextSpan(
                  text: 'Anytime',
                  style: TextStyle(
                    color: kElumoGreen,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.5,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isDesktop ? 62 : 38,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 20),

          // Subtitle
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: const Text(
              'From multi-currency accounts and virtual cards to smart installment tracking, robot debt collection calls, and pan-African tax compliance.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                color: Color(0xFF4B5563),
                height: 1.6,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Store CTAs (ElumoPay Styling)
          Wrap(
            spacing: 16,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _StoreButton(
                icon: Icons.android_rounded,
                label: 'Get on Android',
                onTap: () => Navigator.pushNamed(context, '/login'),
                backgroundColor: kElumoDark,
              ),
              _StoreButton(
                icon: Icons.apple_rounded,
                label: 'Get on iPhone',
                onTap: () => Navigator.pushNamed(context, '/login'),
                backgroundColor: kElumoDark,
              ),
            ],
          ),
          const SizedBox(height: 50),

          // Dual Angled Phone Mockups with floating badges
          _DualAngledHeroMockups(isDesktop: isDesktop),
        ],
      ),
    );
  }
}

class _StoreButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color backgroundColor;
  const _StoreButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.backgroundColor = kElumoDark,
  });

  @override
  State<_StoreButton> createState() => _StoreButtonState();
}

class _StoreButtonState extends State<_StoreButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: _hovered ? widget.backgroundColor.withOpacity(0.9) : widget.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black.withOpacity(0.15), width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: 22, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// DUAL ANGLED HERO PHONE MOCKUPS (Left -6 deg, Right +6 deg with floating coins)
// ============================================================================
class _DualAngledHeroMockups extends StatelessWidget {
  final bool isDesktop;
  const _DualAngledHeroMockups({required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    if (!isDesktop) {
      return Center(
        child: Transform.scale(
          scale: 0.85,
          child: const _SingleHeroPhone(type: _MockupType.walletBalances),
        ),
      );
    }

    return SizedBox(
      height: 580,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background decorative green/blue glow
          Positioned(
            bottom: 0,
            child: Container(
              width: 800,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(400),
                gradient: RadialGradient(
                  colors: [
                    kElumoGreen.withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Left Tilted Phone (-6 degrees)
          Positioned(
            left: MediaQuery.of(context).size.width * 0.15,
            top: 20,
            child: Transform.rotate(
              angle: -0.08,
              child: const _SingleHeroPhone(type: _MockupType.walletBalances),
            ),
          ),

          // Right Tilted Phone (+6 degrees)
          Positioned(
            right: MediaQuery.of(context).size.width * 0.15,
            top: 40,
            child: Transform.rotate(
              angle: 0.08,
              child: const _SingleHeroPhone(type: _MockupType.smartInvoices),
            ),
          ),

          // Floating Payment Inflow Badge (+₦120,000)
          Positioned(
            top: 160,
            right: MediaQuery.of(context).size.width * 0.22,
            child: _FloatingInflowBadge(
              amount: '+₦120,000.00',
              title: 'Tuition Installment Inflow',
              subtitle: 'skill-sch.com · Amara J.',
              color: kElumoGreen,
            ),
          ),

          // Floating Payment Success Badge (Left)
          Positioned(
            bottom: 120,
            left: MediaQuery.of(context).size.width * 0.18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: kElumoGreen.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded, color: kElumoGreen, size: 16),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Payment Successful', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: kElumoDark)),
                      Text('USD Debit Card · \$45.00', style: TextStyle(fontSize: 10, color: kElumoMuted)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Floating Gold Coin Badge
          Positioned(
            top: 50,
            left: MediaQuery.of(context).size.width * 0.12,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD54F), Color(0xFFF59E0B)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: kElumoAmber.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Text('₦', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingInflowBadge extends StatelessWidget {
  final String amount;
  final String title;
  final String subtitle;
  final Color color;
  const _FloatingInflowBadge({
    required this.amount,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_downward_rounded, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: kElumoDark)),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: kElumoMuted)),
            ],
          ),
          const SizedBox(width: 20),
          Text(
            amount,
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: color),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 3. ALTERNATING PASTEL FEATURE SECTIONS (ElumoPay Colors)
// ============================================================================
class _PastelFeatureSection extends StatelessWidget {
  final Color backgroundColor;
  final String titlePrefix;
  final String titleHighlight;
  final String titleSuffix;
  final String description;
  final String linkText;
  final bool isImageRight;
  final _MockupType screenType;

  const _PastelFeatureSection({
    super.key,
    required this.backgroundColor,
    required this.titlePrefix,
    required this.titleHighlight,
    required this.titleSuffix,
    required this.description,
    required this.linkText,
    required this.isImageRight,
    required this.screenType,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    final copyContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: titlePrefix),
              TextSpan(
                text: titleHighlight,
                style: const TextStyle(color: kElumoGreen),
              ),
              TextSpan(text: titleSuffix),
            ],
          ),
          style: TextStyle(
            fontSize: isDesktop ? 44 : 32,
            fontWeight: FontWeight.w800,
            color: kElumoDark,
            letterSpacing: -1.2,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          description,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF4B5563),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 28),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/login'),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  linkText,
                  style: const TextStyle(
                    color: kElumoGreen,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    final mockupContainer = Container(
      width: isDesktop ? 480 : double.infinity,
      height: 480,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.black, width: 4),
      ),
      child: Center(
        child: Transform.scale(
          scale: 0.78,
          child: _SingleHeroPhone(type: screenType),
        ),
      ),
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 24,
        vertical: isDesktop ? 80 : 40,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: isDesktop
            ? Row(
                children: isImageRight
                    ? [
                        Expanded(flex: 5, child: copyContent),
                        const SizedBox(width: 60),
                        Expanded(flex: 5, child: mockupContainer),
                      ]
                    : [
                        Expanded(flex: 5, child: mockupContainer),
                        const SizedBox(width: 60),
                        Expanded(flex: 5, child: copyContent),
                      ],
              )
            : Column(
                children: [
                  copyContent,
                  const SizedBox(height: 36),
                  mockupContainer,
                ],
              ),
      ),
    );
  }
}

// ============================================================================
// 4. DARK SHOWCASE SECTION ("And that is not all" + Virtual Cards Fan + Bento)
// ============================================================================
class _DarkShowcaseSection extends StatelessWidget {
  const _DarkShowcaseSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Container(
      width: double.infinity,
      color: kElumoDark,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64 : 24,
        vertical: isDesktop ? 100 : 60,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            // Section Header
            const Text(
              'And that is not all.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 44,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Packed with intelligent features for everyday spending, debt collection, and cross-border operations.',
              style: TextStyle(
                color: Color(0xFFA1A1AA),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 60),

            // Virtual Card Fan Showcase Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isDesktop ? 48 : 24),
              decoration: BoxDecoration(
                color: const Color(0xFF18181B),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: const Color(0xFF27272A)),
              ),
              child: isDesktop
                  ? Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(text: 'A '),
                                    TextSpan(text: 'Better ', style: TextStyle(color: kElumoAmber)),
                                    TextSpan(text: 'Way\n', style: TextStyle(color: kElumoGreen)),
                                    TextSpan(text: 'to Spend'),
                                  ],
                                ),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 42,
                                  fontWeight: FontWeight.w800,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Create instant multi-currency virtual cards for global subscriptions (Netflix, AWS, Apple) with zero decline rates and automated spending limits.',
                                style: TextStyle(
                                  color: Color(0xFFA1A1AA),
                                  fontSize: 15,
                                  height: 1.6,
                                ),
                              ),
                              const SizedBox(height: 32),
                              _PrimaryPillButton(
                                'Get a Virtual Card',
                                onTap: () => Navigator.pushNamed(context, '/login'),
                                backgroundColor: kElumoGreen,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 40),
                        const Expanded(
                          flex: 6,
                          child: _VirtualCardsFan(),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        const Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(text: 'A '),
                              TextSpan(text: 'Better ', style: TextStyle(color: kElumoAmber)),
                              TextSpan(text: 'Way ', style: TextStyle(color: kElumoGreen)),
                              TextSpan(text: 'to Spend'),
                            ],
                          ),
                          style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Create instant multi-currency virtual cards for global subscriptions.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 14),
                        ),
                        const SizedBox(height: 32),
                        const _VirtualCardsFan(),
                      ],
                    ),
            ),
            const SizedBox(height: 32),

            // 2-Column Bento Grid: AI Debt Collection + Cross Border Stacks
            Row(
              children: [
                Expanded(
                  child: _BentoFeatureCard(
                    title: 'AI Debt Collection &\nRobot Phone Callers',
                    description: 'Dispatch automated AI phone calls via Africa\'s Talking to follow up on overdue student or customer invoices.',
                    badgeText: 'Live Audio AI',
                    badgeColor: kElumoAmber,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _callDialogRow('AI Agent', 'Calling David O. (INV-492) · ₦150,000 overdue', kElumoBlue),
                        const SizedBox(height: 8),
                        _callDialogRow('Status', 'Call Connected — Payment link sent to WhatsApp', kElumoGreen),
                      ],
                    ),
                  ),
                ),
                if (isDesktop) const SizedBox(width: 24),
                if (isDesktop)
                  Expanded(
                    child: _BentoFeatureCard(
                      title: 'Cross-Border Payments\nMade Simple',
                      description: 'Real-time transaction tracking across Nigeria, Kenya, Ghana, and international banks.',
                      badgeText: 'Instant Settlements',
                      badgeColor: kElumoGreen,
                      child: Column(
                        children: [
                          _transactionPill('Received money', '+₦120,000.00', 'Inflow Received · School Fee', kElumoGreen),
                          const SizedBox(height: 10),
                          _transactionPill('USD Converted', '+\$500.00', 'Exchange Swap Settled', kElumoAmber),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _callDialogRow(String label, String text, Color dotColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF09090B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF27272A)),
      ),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor)),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _transactionPill(String title, String amount, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF09090B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF27272A)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
            Text(subtitle, style: const TextStyle(color: Color(0xFF71717A), fontSize: 11)),
          ]),
          Text(amount, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 14)),
        ],
      ),
    );
  }
}

// 4-Card Virtual Cards Fan (Black, Green, Blue, Amber)
class _VirtualCardsFan extends StatelessWidget {
  const _VirtualCardsFan();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Black Card (Bottom)
          Positioned(
            bottom: 0,
            left: 20,
            child: Transform.rotate(
              angle: -0.12,
              child: _SingleVirtualCard(
                color: const Color(0xFF1E1E1E),
                title: 'Elumo Black',
                currency: 'USD CARD',
              ),
            ),
          ),
          // 2. Green Card
          Positioned(
            bottom: 20,
            left: 60,
            child: Transform.rotate(
              angle: -0.04,
              child: _SingleVirtualCard(
                color: kElumoDeepGreen,
                title: 'Elumo Business',
                currency: 'EUR CARD',
              ),
            ),
          ),
          // 3. Amber Gold Card
          Positioned(
            bottom: 40,
            left: 100,
            child: Transform.rotate(
              angle: 0.04,
              child: _SingleVirtualCard(
                color: kElumoAmber,
                title: 'Elumo Premier',
                currency: 'GBP CARD',
              ),
            ),
          ),
          // 4. Vibrant Elumo Green Card (Top)
          Positioned(
            bottom: 60,
            left: 140,
            child: Transform.rotate(
              angle: 0.12,
              child: _SingleVirtualCard(
                color: kElumoGreen,
                title: 'Elumo Global',
                currency: 'NGN CARD',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SingleVirtualCard extends StatelessWidget {
  final Color color;
  final String title;
  final String currency;
  const _SingleVirtualCard({
    required this.color,
    required this.title,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      height: 155,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              Text(currency, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
            ],
          ),
          const Icon(Icons.nfc_rounded, color: Colors.white70, size: 20),
          const Text('•••• •••• •••• 8842', style: TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 2.0, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _BentoFeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final String badgeText;
  final Color badgeColor;
  final Widget child;

  const _BentoFeatureCard({
    required this.title,
    required this.description,
    required this.badgeText,
    required this.badgeColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFF18181B),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF27272A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(badgeText, style: TextStyle(color: badgeColor, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, height: 1.2)),
          const SizedBox(height: 10),
          Text(description, style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 14, height: 1.5)),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }
}

// ============================================================================
// 5. BILL PAYMENTS SECTION (Airtime, Data, Electricity, Cable)
// ============================================================================
class _BillsPaymentSection extends StatelessWidget {
  const _BillsPaymentSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Container(
      width: double.infinity,
      color: const Color(0xFFF8FAFC),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64 : 24,
        vertical: isDesktop ? 80 : 50,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: isDesktop
            ? Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pay Your Bills\nWithout Stress',
                          style: TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w800,
                            color: kElumoDark,
                            height: 1.1,
                            letterSpacing: -1.0,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'From airtime and data purchases to electricity tokens and cable TV subscriptions — manage all utility bills with instant automated receipts.',
                          style: TextStyle(fontSize: 16, color: Color(0xFF4B5563), height: 1.6),
                        ),
                        const SizedBox(height: 28),
                        _PrimaryPillButton(
                          'Pay a Bill Now →',
                          onTap: () => Navigator.pushNamed(context, '/login'),
                          backgroundColor: kElumoGreen,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 60),
                  Expanded(
                    flex: 5,
                    child: _BillsGridPreview(),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pay Your Bills Without Stress', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: kElumoDark)),
                  const SizedBox(height: 12),
                  const Text('From airtime and data to electricity tokens — manage all bills in one place.', style: TextStyle(color: Color(0xFF4B5563))),
                  const SizedBox(height: 24),
                  _BillsGridPreview(),
                ],
              ),
      ),
    );
  }
}

class _BillsGridPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _billItem(Icons.phone_android_rounded, 'Airtime & Data', 'MTN, Airtel, Glo', kElumoGreen),
              const SizedBox(width: 16),
              _billItem(Icons.electric_bolt_rounded, 'Electricity', 'IKEDC, EKEDC, AEDC', kElumoAmber),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _billItem(Icons.tv_rounded, 'Cable TV', 'DStv, GOtv, StarTimes', kElumoBlue),
              const SizedBox(width: 16),
              _billItem(Icons.wifi_rounded, 'Internet Fiber', 'Spectranet, Smile, Fibre', const Color(0xFF00D2B4)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _billItem(IconData icon, String title, String sub, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE4E4E7)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: kElumoDark)),
            const SizedBox(height: 4),
            Text(sub, style: const TextStyle(color: kElumoMuted, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 6. SECURITY & REGULATORY COMPLIANCE SECTION
// ============================================================================
class _SecurityComplianceSection extends StatelessWidget {
  const _SecurityComplianceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Container(
      width: double.infinity,
      color: kElumoDark,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64 : 24,
        vertical: isDesktop ? 100 : 60,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Keeping your money safe is our business.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.0,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Trust is our currency. We are committed to institutional security and pan-African compliance.',
              style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 16),
            ),
            const SizedBox(height: 48),

            isDesktop
                ? Row(
                    children: const [
                      Expanded(child: _SecurityCard(
                        icon: Icons.shield_rounded,
                        title: 'Top-Notch Security',
                        desc: 'End-to-end 256-bit AES encryption, biometric 2FA authentication, and zero-knowledge ledger safety.',
                      )),
                      SizedBox(width: 24),
                      Expanded(child: _SecurityCard(
                        icon: Icons.account_balance_rounded,
                        title: 'Pan-African Tax Compliance',
                        desc: 'Automated VAT and withholding tax filings across Nigeria (FIRS), Kenya (KRA), Ghana (GRA), and South Africa (SARS).',
                      )),
                      SizedBox(width: 24),
                      Expanded(child: _SecurityCard(
                        icon: Icons.support_agent_rounded,
                        title: '24/7 Dedicated Support',
                        desc: 'Live customer intelligence available via in-app chat, email, phone, and WhatsApp around the clock.',
                      )),
                    ],
                  )
                : Column(
                    children: const [
                      _SecurityCard(
                        icon: Icons.shield_rounded,
                        title: 'Top-Notch Security',
                        desc: 'End-to-end 256-bit AES encryption and 2FA authentication.',
                      ),
                      SizedBox(height: 16),
                      _SecurityCard(
                        icon: Icons.account_balance_rounded,
                        title: 'Pan-African Tax Compliance',
                        desc: 'Automated VAT and tax filings across Nigeria, Kenya, Ghana, and South Africa.',
                      ),
                      SizedBox(height: 16),
                      _SecurityCard(
                        icon: Icons.support_agent_rounded,
                        title: '24/7 Dedicated Support',
                        desc: 'Live customer intelligence available around the clock.',
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}

class _SecurityCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  const _SecurityCard({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF18181B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF27272A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kElumoGreen.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: kElumoGreen, size: 24),
          ),
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(desc, style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }
}

// ============================================================================
// 7. DOWNLOAD CTA & FOOTER
// ============================================================================
class _DownloadCtaSection extends StatelessWidget {
  const _DownloadCtaSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: kElumoDeepGreen,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Column(
        children: [
          const Text(
            'Ready to take control of your finances?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.0,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          const Text(
            'Join thousands of freelancers, students, and businesses scaling with ElumoPay.',
            style: TextStyle(color: Colors.white70, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 36),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _StoreButton(
                icon: Icons.android_rounded,
                label: 'Get on Android',
                onTap: () => Navigator.pushNamed(context, '/login'),
                backgroundColor: kElumoDark,
              ),
              _StoreButton(
                icon: Icons.apple_rounded,
                label: 'Get on iPhone',
                onTap: () => Navigator.pushNamed(context, '/login'),
                backgroundColor: kElumoDark,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FooterSection extends StatelessWidget {
  const _FooterSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF09090B),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const NautikLogoMark(size: 28),
                  const SizedBox(width: 10),
                  const Text('ElumoPay', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              const Text(
                '© 2024 Elumopay. A Paynautik Limited Product. All rights reserved.',
                style: TextStyle(color: Color(0xFF71717A), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// REALISTIC PHONE MOCKUP RENDERER
// ============================================================================
enum _MockupType { walletBalances, usdAccount, smartInvoices, currencySwap }

class _SingleHeroPhone extends StatelessWidget {
  final _MockupType type;
  const _SingleHeroPhone({required this.type});

  @override
  Widget build(BuildContext context) {
    const double w = 280;
    const double h = 560;

    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: const Color(0xFF09090B),
        borderRadius: BorderRadius.circular(44),
        border: Border.all(color: const Color(0xFF27272A), width: 6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(38),
        child: Column(
          children: [
            // Phone Notch / Island
            Container(
              height: 24,
              color: const Color(0xFF09090B),
              alignment: Alignment.center,
              child: Container(
                width: 70,
                height: 10,
                decoration: BoxDecoration(color: const Color(0xFF27272A), borderRadius: BorderRadius.circular(10)),
              ),
            ),
            Expanded(child: _buildScreenContent(type)),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenContent(_MockupType type) {
    switch (type) {
      case _MockupType.walletBalances:
        return Container(
          color: const Color(0xFF09090B),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total Net Balance', style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 11)),
              const SizedBox(height: 4),
              const Text('₦14,820,000.00', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _balancePill('NGN Wallet', '₦10,400,000.00', kElumoGreen),
              const SizedBox(height: 8),
              _balancePill('USD Account', '\$5,420.00', kElumoBlue),
              const SizedBox(height: 8),
              _balancePill('GBP Account', '£1,850.00', kElumoAmber),
            ],
          ),
        );
      case _MockupType.usdAccount:
        return Container(
          color: const Color(0xFF09090B),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('USD Checking Details', style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 11)),
              const SizedBox(height: 6),
              const Text('\$8,450.00', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _detailRow('Bank Name', 'Lead Bank US'),
              _detailRow('Routing Number', '021000021'),
              _detailRow('Account Number', '•••• 4920'),
              _detailRow('Status', 'Active & Verified', isStatus: true),
            ],
          ),
        );
      case _MockupType.smartInvoices:
        return Container(
          color: const Color(0xFF09090B),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Smart Invoices & Ledgers', style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 11)),
              const SizedBox(height: 12),
              _invoiceItem('Skill School (skill-sch.com)', 'Amara Johnson · Inst 2/4', '₦100,000', kElumoGreen),
              const SizedBox(height: 8),
              _invoiceItem('SolarGrid Energy', 'Emmanuel A. · Inst 4/6', '₦200,000', kElumoAmber),
              const SizedBox(height: 8),
              _invoiceItem('Acme Corp Software', 'Q3 Retainer', '\$1,200', kElumoBlue),
            ],
          ),
        );
      case _MockupType.currencySwap:
        return Container(
          color: const Color(0xFF09090B),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Instant Currency Swap', style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 11)),
              const SizedBox(height: 16),
              _swapBox('You Pay', '1,500.00', 'USD (\$)'),
              const Center(child: Icon(Icons.swap_vert_rounded, color: kElumoAmber, size: 24)),
              _swapBox('You Get', '2,400,000.00', 'NGN (₦)'),
            ],
          ),
        );
    }
  }

  Widget _balancePill(String name, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF18181B), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF27272A))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          Text(amount, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String val, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 11)),
          Text(val, style: TextStyle(color: isStatus ? kElumoGreen : Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _invoiceItem(String title, String sub, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF18181B), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF27272A))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            Text(sub, style: const TextStyle(color: Color(0xFF71717A), fontSize: 9.5)),
          ]),
          Text(amount, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _swapBox(String label, String amount, String curr) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF18181B), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF27272A))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(color: Color(0xFFA1A1AA), fontSize: 9.5)),
            Text(amount, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
          ]),
          Text(curr, style: const TextStyle(color: kElumoGreen, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
