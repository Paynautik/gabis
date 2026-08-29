import 'dart:async';
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

// Pastel Card Backgrounds
const Color kPastelMint       = Color(0xFFDCFCE7);
const Color kPastelBlue       = Color(0xFFDBEAFE);
const Color kPastelAmber      = Color(0xFFFEF3C7);
const Color kPastelIndigo     = Color(0xFFEDE9FE);

// ─── Navigation Global Keys ───────────────────────────────────────────────────
final _showcaseKey    = GlobalKey();
final _useCasesKey    = GlobalKey();
final _comparisonKey  = GlobalKey();
final _cardsKey       = GlobalKey();
final _securityKey    = GlobalKey();
final _faqKey         = GlobalKey();

void _scrollTo(GlobalKey key) {
  if (key.currentContext != null) {
    Scrollable.ensureVisible(
      key.currentContext!,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
    );
  }
}

// ============================================================
// COLORS
// ============================================================

class AppColors {
  static const navy = Color(0xFF11163F);
  static const indigo = Color(0xFF292083);
  static const purple = Color(0xFF5535E8);
  static const violet = Color(0xFF6B3DF5);
  static const blue = Color(0xFF3155D9);

  static const softPurple = Color(0xFFF1EFFF);
  static const softBlue = Color(0xFFEEF2FF);

  static const muted = Color(0xFF65708F);
  static const border = Color(0x1F1F244B);
}

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
            const GabisPayHero(),
            _InteractiveFeatureSlideSection(key: _showcaseKey),
            _UseCasesSection(key: _useCasesKey),
            _ValueComparisonSection(key: _comparisonKey),
            _DarkCardsShowcaseSection(key: _cardsKey),
            _SecurityComplianceSection(key: _securityKey),
            _FaqSection(key: _faqKey),
            const _DownloadCtaSection(),
            const _FooterSection(),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// MAIN HERO
// ============================================================

class GabisPayHero extends StatefulWidget {
  const GabisPayHero({super.key});

  @override
  State<GabisPayHero> createState() => _GabisPayHeroState();
}

class _GabisPayHeroState extends State<GabisPayHero> {
  bool showingPay = true;

  Timer? logoTimer;

  @override
  void initState() {
    super.initState();

    logoTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) {
        if (mounted) {
          setState(() {
            showingPay = !showingPay;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    logoTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 850;

        return Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.7, -0.1),
              radius: 1.1,
              colors: [
                Color(0xFFF3F1FF),
                Colors.white,
              ],
            ),
          ),
          child: Column(
            children: [
              _Navigation(
                showingPay: showingPay,
              ),

              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 20 : 55,
                ),
                child: isMobile
                    ? Column(
                        children: [
                          _HeroCopy(
                            showingPay: showingPay,
                            centered: true,
                          ),
                          const SizedBox(height: 40),
                          _HeroVisual(
                            showingPay: showingPay,
                            mobile: true,
                          ),
                        ],
                      )
                    : SizedBox(
                        height: 690,
                        child: Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 45,
                              child: _HeroCopy(
                                showingPay: showingPay,
                              ),
                            ),
                            Expanded(
                              flex: 55,
                              child: _HeroVisual(
                                showingPay: showingPay,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================
// NAVIGATION
// ============================================================

class _Navigation extends StatelessWidget {
  final bool showingPay;

  const _Navigation({
    required this.showingPay,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: width < 850 ? 20 : 55,
        vertical: 25,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GabisLogo(
            showingPay: showingPay,
            size: 43,
          ),

          if (width > 850)
            Row(
              children: [
                _NavLink('Features', onTap: () => _scrollTo(_showcaseKey)),
                _NavLink('For Business', onTap: () => _scrollTo(_useCasesKey)),
                _NavLink('Cards', onTap: () => _scrollTo(_cardsKey)),
                _NavLink('Why gabism', onTap: () => _scrollTo(_comparisonKey)),
                _NavLink('FAQ', onTap: () => _scrollTo(_faqKey)),
                const SizedBox(width: 25),
                _NavButton(),
              ],
            ),
        ],
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const _NavLink(this.text, {this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 17),
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF343B5C),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/login'),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          color: AppColors.indigo,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Get Started',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// GABISPAY / GABISM LOGO
// ============================================================

class GabisLogo extends StatelessWidget {
  final bool showingPay;
  final double size;

  const GabisLogo({
    super.key,
    required this.showingPay,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          'gabis',
          style: TextStyle(
            fontSize: size,
            height: 0.9,
            fontWeight: FontWeight.w500,
            letterSpacing: -size * .075,
            color: AppColors.indigo,
          ),
        ),

        // ----------------------------------------------------
        // ONLY THIS SECTION ANIMATES
        // ----------------------------------------------------

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,

          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, .12),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },

          child: Text(
            showingPay ? 'Pay' : 'm',
            key: ValueKey(showingPay),
            style: TextStyle(
              fontSize: size,
              height: 0.9,
              fontWeight: FontWeight.w500,
              letterSpacing: -size * .075,
              color: showingPay
                  ? AppColors.purple
                  : AppColors.indigo,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// HERO COPY
// ============================================================

class _HeroCopy extends StatelessWidget {
  final bool showingPay;
  final bool centered;

  const _HeroCopy({
    required this.showingPay,
    this.centered = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: centered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        // ----------------------------------------------------
        // EYEBROW
        // ----------------------------------------------------

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: AppColors.softPurple,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: AppColors.purple.withOpacity(.12),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 21,
                height: 21,
                decoration: const BoxDecoration(
                  color: AppColors.purple,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 13,
                ),
              ),
              const SizedBox(width: 9),
              const Text(
                'Smart Payments. Real People.',
                style: TextStyle(
                  color: AppColors.indigo,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // ----------------------------------------------------
        // HEADLINE
        // ----------------------------------------------------

        RichText(
          textAlign: centered
              ? TextAlign.center
              : TextAlign.left,
          text: const TextSpan(
            style: TextStyle(
              fontFamily: 'Arial',
              fontSize: 70,
              height: .98,
              letterSpacing: -4,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
            children: [
              TextSpan(
                text: 'Business payments\n',
              ),
              TextSpan(
                text: 'that ',
              ),
              TextSpan(
                text: 'just work',
                style: TextStyle(
                  color: AppColors.purple,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // ----------------------------------------------------
        // DESCRIPTION
        // ----------------------------------------------------

        SizedBox(
          width: 510,
          child: Text(
            'Send, receive and manage payments seamlessly. '
            'Built for modern businesses and the people behind them.',
            textAlign:
                centered ? TextAlign.center : TextAlign.left,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 18,
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),

        const SizedBox(height: 32),

        // ----------------------------------------------------
        // BUTTONS
        // ----------------------------------------------------

        Wrap(
          alignment: centered
              ? WrapAlignment.center
              : WrapAlignment.start,
          spacing: 14,
          runSpacing: 12,
          children: [
            _PrimaryButton(),
            _SecondaryButton(),
          ],
        ),
      ],
    );
  }
}

// ============================================================
// BUTTONS
// ============================================================

class _PrimaryButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/login'),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 25,
          vertical: 17,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppColors.purple,
              AppColors.violet,
            ],
          ),
          borderRadius: BorderRadius.circular(13),
          boxShadow: [
            BoxShadow(
              color: AppColors.purple.withOpacity(.25),
              blurRadius: 25,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Get Started',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            SizedBox(width: 18),
            Icon(
              Icons.arrow_forward,
              color: Colors.white,
              size: 19,
            ),
          ],
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/login'),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 25,
          vertical: 17,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: const Text(
          'Learn More',
          style: TextStyle(
            color: AppColors.navy,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// HERO VISUAL
// ============================================================

class _HeroVisual extends StatelessWidget {
  final bool showingPay;
  final bool mobile;

  const _HeroVisual({
    required this.showingPay,
    this.mobile = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: mobile ? 610 : 680,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // --------------------------------------------------
          // BACK PHONE
          // --------------------------------------------------

          Positioned(
            right: mobile ? 10 : 0,
            top: 70,
            child: Transform.rotate(
              angle: 5 * math.pi / 180,
              child: _Phone(
                showingPay: showingPay,
                invoiceMode: true,
                scale: mobile ? .78 : .9,
              ),
            ),
          ),

          // --------------------------------------------------
          // FRONT PHONE
          // --------------------------------------------------

          Positioned(
            left: mobile ? 0 : 45,
            top: 35,
            child: Transform.rotate(
              angle: -5 * math.pi / 180,
              child: _Phone(
                showingPay: showingPay,
                invoiceMode: false,
                scale: mobile ? .78 : .9,
              ),
            ),
          ),

          // --------------------------------------------------
          // TOP TRANSACTION CARD
          // --------------------------------------------------

          Positioned(
            right: mobile ? -10 : -25,
            top: 15,
            child: const _PaymentCard(),
          ),

          // --------------------------------------------------
          // BOTTOM TRANSACTION CARD
          // --------------------------------------------------

          Positioned(
            left: mobile ? -10 : -35,
            bottom: 30,
            child: const _TransactionCard(),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PHONE
// ============================================================

class _Phone extends StatelessWidget {
  final bool showingPay;
  final bool invoiceMode;
  final double scale;

  const _Phone({
    required this.showingPay,
    required this.invoiceMode,
    this.scale = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: 310,
        height: 620,
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(45),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF111329),
              Color(0xFF45465B),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.indigo.withOpacity(.20),
              blurRadius: 60,
              offset: const Offset(0, 30),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(37),
          child: Container(
            color: const Color(0xFFFCFCFF),
            child: Stack(
              children: [
                Column(
                  children: [
                    const SizedBox(height: 16),

                    // Top bar
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 21,
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '9:41',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.softPurple,
                              borderRadius:
                                  BorderRadius.circular(50),
                            ),
                            child: const Text(
                              'Live',
                              style: TextStyle(
                                color: AppColors.purple,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // App logo
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 21,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: GabisLogo(
                          showingPay: showingPay,
                          size: 25,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    if (!invoiceMode)
                      const _WalletContent()
                    else
                      const _InvoiceContent(),
                  ],
                ),

                // Dynamic island
                Positioned(
                  top: 16,
                  left: 105,
                  child: Container(
                    width: 85,
                    height: 25,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),

                // Bottom navigation
                const Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _PhoneBottomNav(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// WALLET CONTENT
// ============================================================

class _WalletContent extends StatelessWidget {
  const _WalletContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 21),
            child: Text(
              'Total Net Balance',
              style: TextStyle(
                color: Color(0xFF78809A),
                fontSize: 13,
              ),
            ),
          ),
        ),

        const SizedBox(height: 7),

        const Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 21),
            child: Text(
              '₦14,820,000.00',
              style: TextStyle(
                color: AppColors.navy,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.5,
              ),
            ),
          ),
        ),

        const SizedBox(height: 18),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 21),
          child: Row(
            children: [
              Expanded(
                child: _PhoneAction(
                  text: 'Send',
                  primary: true,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: _PhoneAction(
                  text: 'Receive',
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        const _AccountCard(
          name: 'NGN Wallet',
          amount: '₦10,400,000.00',
          color: AppColors.purple,
        ),

        const _AccountCard(
          name: 'USD Account',
          amount: '\$5,420.00',
          color: AppColors.blue,
        ),

        const _AccountCard(
          name: 'GBP Account',
          amount: '£1,850.00',
          color: Color(0xFFE58B1B),
        ),
      ],
    );
  }
}

// ============================================================
// INVOICE CONTENT
// ============================================================

class _InvoiceContent extends StatelessWidget {
  const _InvoiceContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 21),
            child: Text(
              'Smart Invoices & Ledgers',
              style: TextStyle(
                color: Color(0xFF69718D),
                fontSize: 13,
              ),
            ),
          ),
        ),

        const SizedBox(height: 13),

        const _InvoiceCard(
          name: 'Skill School',
          amount: '₦100,000',
          meta: 'Amara J. · Inst 2/4',
          status: 'PAID',
        ),

        const _InvoiceCard(
          name: 'SolarGrid Energy',
          amount: '₦200,000',
          meta: 'Emmanuel A. · Inst 4/6',
          status: 'DUE',
          due: true,
        ),

        const _InvoiceCard(
          name: 'Acme Corp Software',
          amount: '\$1,200',
          meta: 'Q3 Retainer',
          status: 'PAID',
        ),

        Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 21,
            vertical: 13,
          ),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.softPurple,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.bolt,
                color: AppColors.purple,
                size: 17,
              ),
              SizedBox(width: 6),
              Text(
                '10-Day Automated SMS Reminders Active',
                style: TextStyle(
                  color: AppColors.purple,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// PHONE ACTION
// ============================================================

class _PhoneAction extends StatelessWidget {
  final String text;
  final bool primary;

  const _PhoneAction({
    required this.text,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: primary
            ? AppColors.purple
            : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: primary
              ? AppColors.purple
              : const Color(0xFFE0E2EC),
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: primary
                ? Colors.white
                : AppColors.navy,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ACCOUNT CARD
// ============================================================

class _AccountCard extends StatelessWidget {
  final String name;
  final String amount;
  final Color color;

  const _AccountCard({
    required this.name,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        left: 21,
        right: 21,
        bottom: 9,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0x19282B48),
        ),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(
              color: Color(0xFF303650),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// INVOICE CARD
// ============================================================

class _InvoiceCard extends StatelessWidget {
  final String name;
  final String amount;
  final String meta;
  final String status;
  final bool due;

  const _InvoiceCard({
    required this.name,
    required this.amount,
    required this.meta,
    required this.status,
    this.due = false,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor =
        due ? const Color(0xFFE58B1B) : AppColors.purple;

    return Container(
      margin: const EdgeInsets.only(
        left: 21,
        right: 21,
        bottom: 9,
      ),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0x19282B48),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: Color(0xFF20263E),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                amount,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          Text(
            meta,
            style: const TextStyle(
              color: Color(0xFF8790A9),
              fontSize: 10,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PHONE BOTTOM NAVIGATION
// ============================================================

class _PhoneBottomNav extends StatelessWidget {
  const _PhoneBottomNav();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.97),
        border: const Border(
          top: BorderSide(
            color: Color(0x14202540),
          ),
        ),
      ),
      child: const Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceAround,
        children: [
          _BottomItem(
            icon: Icons.home_rounded,
            label: 'Home',
            active: true,
          ),
          _BottomItem(
            icon: Icons.receipt_long_outlined,
            label: 'Invoices',
          ),
          _BottomItem(
            icon: Icons.bolt_outlined,
            label: 'Payments',
          ),
          _BottomItem(
            icon: Icons.settings_outlined,
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _BottomItem({
    required this.icon,
    required this.label,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment:
          MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 16,
          color: active
              ? AppColors.purple
              : const Color(0xFF7B8299),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w700,
            color: active
                ? AppColors.purple
                : const Color(0xFF7B8299),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// PAYMENT CONFIRMATION CARD
// ============================================================

class _PaymentCard extends StatelessWidget {
  const _PaymentCard();

  @override
  Widget build(BuildContext context) {
    return const _FloatingCard(
      width: 305,
      icon: Icons.check,
      title: 'Payment Successful!',
      amount: '+₦1,200 Upwork Direct ACH',
      subtitle: 'NGN Bank Transfer',
    );
  }
}

// ============================================================
// TRANSACTION CONFIRMATION CARD
// ============================================================

class _TransactionCard extends StatelessWidget {
  const _TransactionCard();

  @override
  Widget build(BuildContext context) {
    return const _FloatingCard(
      width: 300,
      icon: Icons.check,
      title: 'Transaction Confirmed!',
      amount: '₦120,000',
      subtitle: 'Tuition Settled · skill-sch.com',
    );
  }
}

// ============================================================
// FLOATING CARD
// ============================================================

class _FloatingCard extends StatefulWidget {
  final double width;
  final IconData icon;
  final String title;
  final String amount;
  final String subtitle;

  const _FloatingCard({
    required this.width,
    required this.icon,
    required this.title,
    required this.amount,
    required this.subtitle,
  });

  @override
  State<_FloatingCard> createState() =>
      _FloatingCardState();
}

class _FloatingCardState
    extends State<_FloatingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, child) {
        final y =
            math.sin(controller.value * math.pi) * 10;

        return Transform.translate(
          offset: Offset(0, -y),
          child: child,
        );
      },
      child: Container(
        width: widget.width,
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.97),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0x19282B48),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.indigo.withOpacity(.14),
              blurRadius: 45,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.softPurple,
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.icon,
                color: AppColors.purple,
                size: 20,
              ),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    widget.amount,
                    style: const TextStyle(
                      color: AppColors.navy,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    widget.subtitle,
                    style: const TextStyle(
                      color: Color(0xFF77809B),
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 3. INTERACTIVE FEATURE SLIDE SECTION (All Mockups in an Interactive Switcher)
// ============================================================================
class _FeatureSlideItem {
  final String tag;
  final String title;
  final String subtitle;
  final String description;
  final List<String> bulletPoints;
  final String ctaText;
  final Color accentColor;
  final Color bgGradientStart;
  final _MockupType mockupType;

  const _FeatureSlideItem({
    required this.tag,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.bulletPoints,
    required this.ctaText,
    required this.accentColor,
    required this.bgGradientStart,
    required this.mockupType,
  });
}

class _InteractiveFeatureSlideSection extends StatefulWidget {
  const _InteractiveFeatureSlideSection({super.key});

  @override
  State<_InteractiveFeatureSlideSection> createState() => _InteractiveFeatureSlideSectionState();
}

class _InteractiveFeatureSlideSectionState extends State<_InteractiveFeatureSlideSection> {
  int _selectedIndex = 0;
  Timer? _autoSlideTimer;

  static const List<_FeatureSlideItem> _slides = [
    _FeatureSlideItem(
      tag: 'Multi-Currency Accounts',
      title: 'One Global Account,',
      subtitle: 'Infinite Currencies.',
      description: 'Hold, convert, and manage NGN, USD, GBP, and EUR balances in real time with bank-beating institutional rates.',
      bulletPoints: [
        'Instant multi-currency wallet creation with zero opening fees',
        'Direct local bank account transfers across African banks',
        'Real-time automated conversion ledgers',
      ],
      ctaText: 'Open a Multi-Currency Account →',
      accentColor: kElumoGreen,
      bgGradientStart: Color(0xFFDCFCE7),
      mockupType: _MockupType.walletBalances,
    ),
    _FeatureSlideItem(
      tag: 'US Checking & Banking',
      title: 'Open a US Bank Account',
      subtitle: 'in Under 2 Minutes.',
      description: 'Get verified US routing numbers and checking account details to receive ACH and Wire payments from employers and global platforms.',
      bulletPoints: [
        'Dedicated US Account & ACH Routing number via US partner banks',
        'Zero receiving fees from Upwork, Stripe, Deel, and Amazon',
        'Instant withdrawal directly to local African currency accounts',
      ],
      ctaText: 'Get Your US Account →',
      accentColor: kElumoBlue,
      bgGradientStart: Color(0xFFDBEAFE),
      mockupType: _MockupType.usdAccount,
    ),
    _FeatureSlideItem(
      tag: 'Smart Invoicing & Installments',
      title: 'Tuition Installment Tracking',
      subtitle: '& Automated Ledgers.',
      description: 'Built for schools (like skill-sch.com) and businesses to issue installment plans with automatic 10-day SMS reminders.',
      bulletPoints: [
        'Flexible 2, 4, or 6-part installment payment schedules',
        'Automated SMS & email reminders before each payment due date',
        'Instant automated receipts and real-time reconciliation',
      ],
      ctaText: 'Explore Smart Invoicing →',
      accentColor: kElumoAmber,
      bgGradientStart: Color(0xFFFEF3C7),
      mockupType: _MockupType.smartInvoices,
    ),
    _FeatureSlideItem(
      tag: 'Instant Currency Swap',
      title: 'Instant FX Swaps',
      subtitle: 'at Bank-Beating Rates.',
      description: 'Convert between Naira, US Dollars, British Pounds, and Euros at true mid-market rates with transparent, zero hidden spread fees.',
      bulletPoints: [
        'Live streaming exchange rate calculations',
        'Instant balance settlement with zero delays',
        'Transparent 0.3% low FX margin vs traditional 5% bank spread',
      ],
      ctaText: 'Check Live Exchange Rates →',
      accentColor: Color(0xFF00D2B4),
      bgGradientStart: Color(0xFFE0F2FE),
      mockupType: _MockupType.currencySwap,
    ),
    _FeatureSlideItem(
      tag: 'AI Voice Robot Debt Calls',
      title: 'Automated AI Phone Callers',
      subtitle: 'for Overdue Invoices.',
      description: 'Dispatch automated conversational AI voice phone calls to follow up with overdue customers and send instant 1-tap WhatsApp payment links.',
      bulletPoints: [
        'Automated Africa\'s Talking telecom audio caller dispatch',
        'Conversational voice assistant handles polite invoice reminders',
        'One-click instant payment link sent directly to customer WhatsApp',
      ],
      ctaText: 'Learn About AI Debt Recovery →',
      accentColor: kElumoDeepGreen,
      bgGradientStart: Color(0xFFD1FAE5),
      mockupType: _MockupType.aiVoiceCall,
    ),
    _FeatureSlideItem(
      tag: 'Pan-African Settlements',
      title: 'Real-Time Cross-Border',
      subtitle: 'Settlements & Payouts.',
      description: 'Unify and track merchant and freelancer transactions across Nigeria, Kenya, Ghana, and global international accounts.',
      bulletPoints: [
        'Instant multi-country settlement stream (NGN, KSh, GH₵, USD)',
        'Webhook automation for developers and enterprise ledgers',
        'Zero paperwork for cross-border African commerce',
      ],
      ctaText: 'View Settlement Infrastructure →',
      accentColor: kElumoBlue,
      bgGradientStart: Color(0xFFEDE9FE),
      mockupType: _MockupType.crossBorderFeed,
    ),
    _FeatureSlideItem(
      tag: 'Utility & Bill Payments',
      title: 'Pay Everyday Bills,',
      subtitle: 'Instant & Stress-Free.',
      description: 'Recharge airtime & data, purchase electricity tokens, and renew cable TV subscriptions with instant automated tokens and receipts.',
      bulletPoints: [
        'Instant Airtime & Data top-ups for MTN, Airtel, Glo, 9mobile',
        'Prepaid & Postpaid Electricity tokens (IKEDC, EKEDC, AEDC, IBEDC)',
        'Instant cable TV renewals (DStv, GOtv, StarTimes) & fiber internet',
      ],
      ctaText: 'Explore Bill Payments →',
      accentColor: kElumoAmber,
      bgGradientStart: Color(0xFFFEF3C7),
      mockupType: _MockupType.billPayments,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 7), (_) {
      if (mounted) {
        setState(() {
          _selectedIndex = (_selectedIndex + 1) % _slides.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;
    final currentSlide = _slides[_selectedIndex];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            currentSlide.bgGradientStart.withOpacity(0.45),
            currentSlide.bgGradientStart.withOpacity(0.12),
            Colors.white,
          ],
          stops: const [0.0, 0.45, 1.0],
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 24,
        vertical: isDesktop ? 80 : 40,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              // Section Header
              const Text(
                'Explore the Platform',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: kElumoGreen,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Everything You Need to Move Money Globally',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isDesktop ? 36 : 26,
                  fontWeight: FontWeight.w800,
                  color: kElumoDark,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(height: 28),

              // Interactive Slide Selector Tabs
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_slides.length, (index) {
                    final item = _slides[index];
                    final isSelected = index == _selectedIndex;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _selectedIndex = index);
                            _startAutoSlide(); // Reset timer on user click
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? kElumoDark : Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: isSelected ? kElumoDark : const Color(0xFFE2E8F0),
                                width: 1.5,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.12),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected ? item.accentColor : const Color(0xFF94A3B8),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  item.tag,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                    color: isSelected ? Colors.white : const Color(0xFF475569),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 48),

              // Slide Body (Left Copy + Right Immersive Photo Mockup Showcase)
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: isDesktop
                    ? Row(
                        key: ValueKey<int>(_selectedIndex),
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 6,
                            child: _buildSlideCopy(currentSlide),
                          ),
                          const SizedBox(width: 50),
                          Expanded(
                            flex: 5,
                            child: Center(
                              child: Container(
                                width: double.infinity,
                                height: 590,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(32),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 28,
                                      offset: const Offset(0, 12),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(32),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    alignment: Alignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/images/african_person_mockup.jpg',
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(color: const Color(0xFFF1F5F9)),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.black.withOpacity(0.35),
                                              Colors.black.withOpacity(0.15),
                                              Colors.black.withOpacity(0.65),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Center(
                                        child: _SingleHeroPhone(type: currentSlide.mockupType),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        key: ValueKey<int>(_selectedIndex),
                        children: [
                          _buildSlideCopy(currentSlide),
                          const SizedBox(height: 36),
                          Center(
                            child: Container(
                              width: double.infinity,
                              height: 520,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 24,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(28),
                                child: Stack(
                                  fit: StackFit.expand,
                                  alignment: Alignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/african_person_mockup.jpg',
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(color: const Color(0xFFF1F5F9)),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.black.withOpacity(0.30),
                                            Colors.black.withOpacity(0.15),
                                            Colors.black.withOpacity(0.70),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: Transform.scale(
                                        scale: 0.85,
                                        child: _SingleHeroPhone(type: currentSlide.mockupType),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlideCopy(_FeatureSlideItem slide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: slide.accentColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: slide.accentColor.withOpacity(0.3)),
          ),
          child: Text(
            slide.tag,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: slide.accentColor,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: '${slide.title}\n'),
              TextSpan(
                text: slide.subtitle,
                style: TextStyle(color: slide.accentColor),
              ),
            ],
          ),
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w800,
            color: kElumoDark,
            letterSpacing: -1.2,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          slide.description,
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF4B5563),
            height: 1.6,
          ),
        ),
        const SizedBox(height: 24),
        ...slide.bulletPoints.map((point) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 3),
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: slide.accentColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.check_rounded, size: 12, color: slide.accentColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      point,
                      style: const TextStyle(
                        fontSize: 14.5,
                        color: Color(0xFF334155),
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )),
        const SizedBox(height: 24),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/login'),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  slide.ctaText,
                  style: TextStyle(
                    color: slide.accentColor,
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
  }
}

// ============================================================================
// 4. USE CASES SECTION ("Made for Hustlers, Movers & Shakers")
// ============================================================================
class _UseCasesSection extends StatelessWidget {
  const _UseCasesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64 : 24,
        vertical: isDesktop ? 90 : 60,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1240),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: kElumoGreen.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kElumoGreen.withOpacity(0.25)),
              ),
              child: const Text(
                'Built for Africa\'s Builders',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: kElumoGreen,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Made for Hustlers, Movers & Shakers',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w800,
                color: kElumoDark,
                letterSpacing: -1.2,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'From ambitious students and tech freelancers to borderless merchants and scaling institutions.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF64748B), fontSize: 16),
            ),
            const SizedBox(height: 52),

            // 4 Photo Cards Grid
            isDesktop
                ? Column(
                    children: [
                      Row(
                        children: const [
                          Expanded(
                            child: _PhotoUseCaseCard(
                              imagePath: 'assets/images/usecase_schools.jpg',
                              tag: 'Schools & Universities',
                              title: 'Tuition & Smart Installments',
                              description: 'Flexible 2-to-6 part installment plans with automated 10-day SMS reminders and instant receipts.',
                              statBadge: '99.4% Inflow Rate',
                              accentColor: kElumoGreen,
                              ctaText: 'Explore School Invoicing',
                            ),
                          ),
                          SizedBox(width: 24),
                          Expanded(
                            child: _PhotoUseCaseCard(
                              imagePath: 'assets/images/usecase_freelancers.jpg',
                              tag: 'Freelancers & Tech Talent',
                              title: 'Direct Global Client Payouts',
                              description: 'Receive USD, GBP, and EUR from Upwork, Stripe, and Deel with dedicated US checking and routing details.',
                              statBadge: '0.3% Mid-Market FX',
                              accentColor: kElumoBlue,
                              ctaText: 'Get US Bank Account',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: const [
                          Expanded(
                            child: _PhotoUseCaseCard(
                              imagePath: 'assets/images/usecase_traders.jpg',
                              tag: 'Pan-African Commerce',
                              title: 'Cross-Border Settlement & Cards',
                              description: 'Pay suppliers across China, US, Kenya, and Ghana with zero-decline multi-currency virtual cards.',
                              statBadge: '< 0.1% Declines',
                              accentColor: kElumoAmber,
                              ctaText: 'Start Cross-Border Trading',
                            ),
                          ),
                          SizedBox(width: 24),
                          Expanded(
                            child: _PhotoUseCaseCard(
                              imagePath: 'assets/images/usecase_creators.jpg',
                              tag: 'Digital Creators & Remote Pros',
                              title: 'Global Monetization & Payroll',
                              description: 'Collect earnings from YouTube, Patreon, and global employers directly into multi-currency accounts.',
                              statBadge: 'Instant Settlements',
                              accentColor: Color(0xFF00D2B4),
                              ctaText: 'Explore Creator Monetization',
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Column(
                    children: const [
                      _PhotoUseCaseCard(
                        imagePath: 'assets/images/usecase_schools.jpg',
                        tag: 'Schools & Universities',
                        title: 'Tuition & Smart Installments',
                        description: 'Flexible 2-to-6 part installment plans with automated 10-day SMS reminders and instant receipts.',
                        statBadge: '99.4% Inflow Rate',
                        accentColor: kElumoGreen,
                        ctaText: 'Explore School Invoicing',
                      ),
                      SizedBox(height: 20),
                      _PhotoUseCaseCard(
                        imagePath: 'assets/images/usecase_freelancers.jpg',
                        tag: 'Freelancers & Tech Talent',
                        title: 'Direct Global Client Payouts',
                        description: 'Receive USD, GBP, and EUR from Upwork, Stripe, and Deel with dedicated US checking and routing details.',
                        statBadge: '0.3% Mid-Market FX',
                        accentColor: kElumoBlue,
                        ctaText: 'Get US Bank Account',
                      ),
                      SizedBox(height: 20),
                      _PhotoUseCaseCard(
                        imagePath: 'assets/images/usecase_traders.jpg',
                        tag: 'Pan-African Commerce',
                        title: 'Cross-Border Settlement & Cards',
                        description: 'Pay suppliers across China, US, Kenya, and Ghana with zero-decline multi-currency virtual cards.',
                        statBadge: '< 0.1% Declines',
                        accentColor: kElumoAmber,
                        ctaText: 'Start Cross-Border Trading',
                      ),
                      SizedBox(height: 20),
                      _PhotoUseCaseCard(
                        imagePath: 'assets/images/usecase_creators.jpg',
                        tag: 'Digital Creators & Remote Pros',
                        title: 'Global Monetization & Payroll',
                        description: 'Collect earnings from YouTube, Patreon, and global employers directly into multi-currency accounts.',
                        statBadge: 'Instant Settlements',
                        accentColor: Color(0xFF00D2B4),
                        ctaText: 'Explore Creator Monetization',
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}

class _PhotoUseCaseCard extends StatefulWidget {
  final String imagePath;
  final String tag;
  final String title;
  final String description;
  final String statBadge;
  final Color accentColor;
  final String ctaText;

  const _PhotoUseCaseCard({
    required this.imagePath,
    required this.tag,
    required this.title,
    required this.description,
    required this.statBadge,
    required this.accentColor,
    required this.ctaText,
  });

  @override
  State<_PhotoUseCaseCard> createState() => _PhotoUseCaseCardState();
}

class _PhotoUseCaseCardState extends State<_PhotoUseCaseCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/login'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          height: 380,
          transform: Matrix4.translationValues(0, _hovered ? -6 : 0, 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _hovered ? widget.accentColor : Colors.black.withOpacity(0.08),
              width: _hovered ? 2.0 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: _hovered ? widget.accentColor.withOpacity(0.22) : Colors.black.withOpacity(0.08),
                blurRadius: _hovered ? 28 : 14,
                offset: Offset(0, _hovered ? 12 : 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background Human Photo with zoom on hover
                AnimatedScale(
                  scale: _hovered ? 1.06 : 1.0,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  child: Image.asset(
                    widget.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: kElumoDark,
                      child: Center(
                        child: Icon(Icons.person_rounded, size: 60, color: widget.accentColor.withOpacity(0.4)),
                      ),
                    ),
                  ),
                ),

                // Multi-stop Gradient overlay for contrast
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.40),
                        Colors.black.withOpacity(0.15),
                        Colors.black.withOpacity(0.70),
                        Colors.black.withOpacity(0.92),
                      ],
                      stops: const [0.0, 0.35, 0.65, 1.0],
                    ),
                  ),
                ),

                // Card Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top Row: Category Badge + Stat Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.45),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.25), width: 0.8),
                            ),
                            child: Text(
                              widget.tag,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: widget.accentColor.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: widget.accentColor, width: 0.8),
                            ),
                            child: Text(
                              widget.statBadge,
                              style: TextStyle(
                                color: widget.accentColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Bottom Content
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.description,
                            style: const TextStyle(
                              fontSize: 13.5,
                              color: Color(0xFFE2E8F0),
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Text(
                                widget.ctaText,
                                style: TextStyle(
                                  color: widget.accentColor,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(Icons.arrow_forward_rounded, color: widget.accentColor, size: 15),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 5. VALUE COMPARISON SECTION ("Why Choose ElumoPay")
// ============================================================================
class _ValueComparisonSection extends StatelessWidget {
  const _ValueComparisonSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 24,
        vertical: isDesktop ? 80 : 50,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Column(
          children: [
            const Text(
              'The Clear Advantage',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: kElumoGreen,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Why Thousands Switch to gabism',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: kElumoDark,
                letterSpacing: -1.0,
              ),
            ),
            const SizedBox(height: 40),

            // Comparison Table Container
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  children: [
                    // Table Header
                    Container(
                      color: kElumoDark,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Row(
                        children: const [
                          Expanded(flex: 4, child: Text('Features & Capabilities', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
                          Expanded(flex: 3, child: Text('gabism', style: TextStyle(color: kElumoGreen, fontWeight: FontWeight.w800, fontSize: 14))),
                          Expanded(flex: 3, child: Text('Traditional Banks', style: TextStyle(color: Color(0xFFA1A1AA), fontWeight: FontWeight.w600, fontSize: 13))),
                        ],
                      ),
                    ),
                    _comparisonRow('US Bank Account Setup', '< 2 Minutes (Instant)', '2 – 4 Weeks (Paperwork)', true),
                    _comparisonRow('FX Conversion Spread', '0.3% (Mid-Market)', '3.5% – 7.0% Hidden Markup', false),
                    _comparisonRow('Tuition & Debt Recovery', 'AI Voice Calls + WhatsApp', 'Manual In-Branch Visits', true),
                    _comparisonRow('Virtual Card Decline Rate', '< 0.1% (99.9% Success)', '18% – 35% Decline Rates', false),
                    _comparisonRow('Pan-African Tax Automation', 'Automated FIRS/KRA/GRA', 'Manual Paperwork', true),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _comparisonRow(String feature, String elumoVal, String traditionalVal, bool isEven) {
    return Container(
      color: isEven ? const Color(0xFFF8FAFC) : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(feature, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, color: kElumoDark)),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: kElumoGreen, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(elumoVal, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: kElumoGreen)),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                const Icon(Icons.close_rounded, color: Color(0xFF94A3B8), size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(traditionalVal, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12.5)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 6. DARK SHOWCASE SECTION (Virtual Cards Fan Showcase)
// ============================================================================
class _DarkCardsShowcaseSection extends StatelessWidget {
  const _DarkCardsShowcaseSection({super.key});

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
            const Text(
              'Virtual Cards for Global Ambition',
              style: TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Create instant multi-currency cards for Netflix, AWS, Apple, and international vendor spending with zero decline rates.',
              style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

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
                                    TextSpan(text: 'to Spend Globally'),
                                  ],
                                ),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 38,
                                  fontWeight: FontWeight.w800,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Instant 3D-secure virtual debit cards in USD, GBP, EUR, and NGN. Set custom transaction limits, freeze cards in 1-tap, and eliminate payment rejections.',
                                style: TextStyle(color: Color(0xFFA1A1AA), fontSize: 15, height: 1.6),
                              ),
                              const SizedBox(height: 32),
                              GestureDetector(
                                onTap: () => Navigator.pushNamed(context, '/login'),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [AppColors.purple, AppColors.violet],
                                    ),
                                    borderRadius: BorderRadius.circular(30),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.purple.withOpacity(0.35),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: const Text(
                                    'Get a Virtual Card',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 40),
                        const Expanded(flex: 6, child: _VirtualCardsFan()),
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
                          style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800),
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
          ],
        ),
      ),
    );
  }
}

class _VirtualCardsFan extends StatelessWidget {
  const _VirtualCardsFan();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 0,
            left: 20,
            child: Transform.rotate(
              angle: -0.12,
              child: const _SingleVirtualCard(color: Color(0xFF1E1E1E), title: 'gabism Black', currency: 'USD CARD'),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 60,
            child: Transform.rotate(
              angle: -0.04,
              child: const _SingleVirtualCard(color: kElumoDeepGreen, title: 'gabism Business', currency: 'EUR CARD'),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 100,
            child: Transform.rotate(
              angle: 0.04,
              child: const _SingleVirtualCard(color: kElumoAmber, title: 'gabism Premier', currency: 'GBP CARD'),
            ),
          ),
          Positioned(
            bottom: 60,
            left: 140,
            child: Transform.rotate(
              angle: 0.12,
              child: const _SingleVirtualCard(color: kElumoGreen, title: 'gabism Global', currency: 'NGN CARD'),
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
  const _SingleVirtualCard({required this.color, required this.title, required this.currency});

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
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 16, offset: const Offset(0, 8)),
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

// ============================================================================
// 7. SECURITY & PAN-AFRICAN TAX COMPLIANCE SECTION
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
// 9. FAQ ACCORDION SECTION
// ============================================================================
class _FaqSection extends StatefulWidget {
  const _FaqSection({super.key});

  @override
  State<_FaqSection> createState() => _FaqSectionState();
}

class _FaqSectionState extends State<_FaqSection> {
  int? _expandedIndex = 0;

  static const List<Map<String, String>> _faqs = [
    {
      'q': 'How quickly can I open a US Bank Account on gabism?',
      'a': 'Your USD checking account and dedicated ACH routing details are generated in under 2 minutes upon completing instant biometric KYC verification.',
    },
    {
      'q': 'How does the Smart Invoice & Tuition Installment tracking work?',
      'a': 'Schools (such as skill-sch.com) and businesses can create structured 2, 4, or 6-installment payment plans. gabism automatically schedules automated SMS reminders and reconciles inflows in real-time.',
    },
    {
      'q': 'How do the automated AI Debt Collection phone calls work?',
      'a': 'When an invoice exceeds its due date, gabism can automatically dispatch an AI conversational phone caller powered by Africa\'s Talking telecom infrastructure to follow up politely with the student/customer and dispatch a direct 1-tap WhatsApp payment settlement link.',
    },
    {
      'q': 'Which currencies can I hold, convert, and swap?',
      'a': 'You can instantly hold and convert Nigerian Naira (NGN), US Dollars (USD), British Pounds (GBP), and Euros (EUR), with real-time settlement across Kenyan Shillings (KSh) and Ghanaian Cedis (GH₵).',
    },
    {
      'q': 'Are gabism virtual cards accepted globally?',
      'a': 'Yes! Our USD and EUR virtual cards are 3D-secure enabled and work seamlessly for Apple, Netflix, AWS, Google Cloud, Facebook Ads, Shopify, and millions of global merchants with near-zero decline rates.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 80 : 24,
        vertical: isDesktop ? 80 : 50,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Column(
          children: [
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
                color: kElumoGreen,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Got Questions? We\'ve Got Answers.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: kElumoDark,
                letterSpacing: -1.0,
              ),
            ),
            const SizedBox(height: 40),

            ...List.generate(_faqs.length, (i) {
              final isExpanded = _expandedIndex == i;
              final item = _faqs[i];

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: isExpanded ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isExpanded ? kElumoGreen.withOpacity(0.4) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    setState(() {
                      _expandedIndex = isExpanded ? null : i;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                item['q']!,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: isExpanded ? kElumoDeepGreen : kElumoDark,
                                ),
                              ),
                            ),
                            Icon(
                              isExpanded ? Icons.remove_circle_outline_rounded : Icons.add_circle_outline_rounded,
                              color: isExpanded ? kElumoGreen : const Color(0xFF64748B),
                              size: 20,
                            ),
                          ],
                        ),
                        if (isExpanded) ...[
                          const SizedBox(height: 12),
                          Text(
                            item['a']!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF475569),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 10. DOWNLOAD CTA & FOOTER
// ============================================================================
class _DownloadCtaSection extends StatelessWidget {
  const _DownloadCtaSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0B0F2A),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 90),
      child: Column(
        children: [
          const Text(
            'Download the gabism app,\nyour money will thank you',
            style: TextStyle(
              color: Colors.white,
              fontSize: 44,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.2,
              height: 1.15,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: const Text(
              'Thousands of users are already on gabism, and they love it. Once you try it, you\'ll understand the hype. Do it now.',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 16,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 38),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _StoreButton(
                iconWidget: const _GooglePlayLogoWidget(size: 20),
                label: 'Google Play',
                onTap: () => Navigator.pushNamed(context, '/login'),
                backgroundColor: const Color(0xFF1E1B4B),
              ),
              _StoreButton(
                iconWidget: const _AppleLogoWidget(size: 20),
                label: 'App Store',
                onTap: () => Navigator.pushNamed(context, '/login'),
                backgroundColor: const Color(0xFF1E1B4B),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StoreButton extends StatefulWidget {
  final Widget iconWidget;
  final String label;
  final VoidCallback onTap;
  final Color backgroundColor;
  const _StoreButton({
    required this.iconWidget,
    required this.label,
    required this.onTap,
    this.backgroundColor = const Color(0xFF1E1B4B),
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
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          decoration: BoxDecoration(
            color: _hovered ? widget.backgroundColor.withOpacity(0.85) : widget.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.iconWidget,
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
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

class _GooglePlayLogoWidget extends StatelessWidget {
  final double size;
  const _GooglePlayLogoWidget({this.size = 22});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GooglePlayPainter()),
    );
  }
}

class _GooglePlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final bluePath = Path()
      ..moveTo(w * 0.08, h * 0.04)
      ..lineTo(w * 0.62, h * 0.50)
      ..lineTo(w * 0.08, h * 0.96)
      ..close();
    canvas.drawPath(bluePath, Paint()..color = const Color(0xFF00D2FF)..style = PaintingStyle.fill);

    final greenPath = Path()
      ..moveTo(w * 0.08, h * 0.04)
      ..lineTo(w * 0.78, h * 0.36)
      ..lineTo(w * 0.62, h * 0.50)
      ..close();
    canvas.drawPath(greenPath, Paint()..color = const Color(0xFF00E676)..style = PaintingStyle.fill);

    final redPath = Path()
      ..moveTo(w * 0.08, h * 0.96)
      ..lineTo(w * 0.62, h * 0.50)
      ..lineTo(w * 0.78, h * 0.64)
      ..close();
    canvas.drawPath(redPath, Paint()..color = const Color(0xFFFF334B)..style = PaintingStyle.fill);

    final yellowPath = Path()
      ..moveTo(w * 0.62, h * 0.50)
      ..lineTo(w * 0.78, h * 0.36)
      ..lineTo(w * 0.96, h * 0.50)
      ..lineTo(w * 0.78, h * 0.64)
      ..close();
    canvas.drawPath(yellowPath, Paint()..color = const Color(0xFFFFD400)..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AppleLogoWidget extends StatelessWidget {
  final double size;
  final Color color;
  const _AppleLogoWidget({this.size = 22, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _AppleLogoPainter(color: color)),
    );
  }
}

class _AppleLogoPainter extends CustomPainter {
  final Color color;
  const _AppleLogoPainter({this.color = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final w = size.width;
    final h = size.height;

    final leafPath = Path();
    leafPath.moveTo(w * 0.53, h * 0.20);
    leafPath.cubicTo(w * 0.54, h * 0.10, w * 0.64, h * 0.02, w * 0.73, h * 0.02);
    leafPath.cubicTo(w * 0.74, h * 0.13, w * 0.65, h * 0.22, w * 0.53, h * 0.20);
    leafPath.close();
    canvas.drawPath(leafPath, paint);

    final bodyPath = Path();
    bodyPath.moveTo(w * 0.53, h * 0.24);
    bodyPath.cubicTo(w * 0.42, h * 0.24, w * 0.33, h * 0.30, w * 0.27, h * 0.30);
    bodyPath.cubicTo(w * 0.16, h * 0.30, w * 0.06, h * 0.42, w * 0.06, h * 0.62);
    bodyPath.cubicTo(w * 0.06, h * 0.79, w * 0.17, h * 0.98, w * 0.28, h * 0.98);
    bodyPath.cubicTo(w * 0.35, h * 0.98, w * 0.39, h * 0.92, w * 0.49, h * 0.92);
    bodyPath.cubicTo(w * 0.59, h * 0.92, w * 0.63, h * 0.98, w * 0.71, h * 0.98);
    bodyPath.cubicTo(w * 0.81, h * 0.98, w * 0.92, h * 0.81, w * 0.95, h * 0.71);
    bodyPath.cubicTo(w * 0.82, h * 0.67, w * 0.80, h * 0.47, w * 0.94, h * 0.42);
    bodyPath.cubicTo(w * 0.85, h * 0.27, w * 0.70, h * 0.24, w * 0.63, h * 0.24);
    bodyPath.cubicTo(w * 0.58, h * 0.24, w * 0.56, h * 0.26, w * 0.53, h * 0.24);
    bodyPath.close();
    canvas.drawPath(bodyPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
                children: const [
                  GabismWordmark(height: 28, isWhite: true),
                ],
              ),
              const Text(
                '© 2024 gabism. A Paynautik Limited Product. All rights reserved.',
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
// REALISTIC PHONE MOCKUP RENDERER (Titanium iPhone 15 Pro + White Mode UI + Gabism Branding)
// ============================================================================
enum _MockupType { walletBalances, usdAccount, smartInvoices, currencySwap, aiVoiceCall, crossBorderFeed, billPayments }

class _SingleHeroPhone extends StatelessWidget {
  final _MockupType type;
  const _SingleHeroPhone({required this.type});

  @override
  Widget build(BuildContext context) {
    const double w = 295;
    const double h = 570;

    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(48),
        border: Border.all(color: const Color(0xFF1E293B), width: 5.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 36,
            spreadRadius: 1,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: kElumoGreen.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(42),
        child: Column(
          children: [
            // Status Bar + Dynamic Island (Crisp White Mode)
            Container(
              height: 36,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '9:41',
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  // Dynamic Island (Black Pill)
                  Container(
                    width: 74,
                    height: 18,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: const BoxDecoration(
                            color: Color(0xFF1E293B),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Signal & Battery (Dark theme for white screen)
                  Row(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(width: 2, height: 4, color: const Color(0xFF0F172A)),
                          const SizedBox(width: 1),
                          Container(width: 2, height: 6, color: const Color(0xFF0F172A)),
                          const SizedBox(width: 1),
                          Container(width: 2, height: 8, color: const Color(0xFF0F172A)),
                          const SizedBox(width: 1),
                          Container(width: 2, height: 10, color: const Color(0xFF0F172A)),
                        ],
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 18,
                        height: 9,
                        padding: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFF0F172A), width: 1),
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 12,
                          decoration: BoxDecoration(
                            color: kElumoGreen,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // In-App Header with Official Gabism Logo (White Mode)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const GabismWordmark(height: 22),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: kElumoGreen.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: kElumoGreen.withOpacity(0.3)),
                    ),
                    child: const Text(
                      'Live',
                      style: TextStyle(
                        color: kElumoDeepGreen,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Screen Content (Clean White Theme)
            Expanded(
              child: Container(
                color: Colors.white,
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: _buildScreenContent(type),
                ),
              ),
            ),

            // Bottom Home Indicator Bar (White Mode)
            Container(
              height: 16,
              color: Colors.white,
              alignment: Alignment.center,
              child: Container(
                width: 100,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withOpacity(0.25),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScreenContent(_MockupType type) {
    switch (type) {
      case _MockupType.walletBalances:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Total Net Balance', style: TextStyle(color: Color(0xFF64748B), fontSize: 10.5, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              const Text('₦14,820,000.00', style: TextStyle(color: Color(0xFF0F172A), fontSize: 21, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      decoration: BoxDecoration(
                        color: kElumoGreen,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(color: kElumoGreen.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3)),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Text('Send', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.5)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      alignment: Alignment.center,
                      child: const Text('Receive', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 11.5)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _balancePill('NGN Wallet', '₦10,400,000.00', kElumoGreen),
              const SizedBox(height: 6),
              _balancePill('USD Account', '\$5,420.00', kElumoBlue),
              const SizedBox(height: 6),
              _balancePill('GBP Account', '£1,850.00', kElumoAmber),
            ],
          ),
        );
      case _MockupType.usdAccount:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('USD Checking Details', style: TextStyle(color: Color(0xFF64748B), fontSize: 10.5, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              const Text('\$8,450.00', style: TextStyle(color: Color(0xFF0F172A), fontSize: 21, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              _detailRow('Bank Name', 'Lead Bank US'),
              _detailRow('Routing Number', '021000021'),
              _detailRow('Account Number', '•••• 4920'),
              _detailRow('Status', 'Active & Verified', isStatus: true),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: kElumoBlue,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(color: kElumoBlue.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3)),
                  ],
                ),
                alignment: Alignment.center,
                child: const Text('Copy Account Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.5)),
              ),
            ],
          ),
        );
      case _MockupType.smartInvoices:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Smart Invoices & Ledgers', style: TextStyle(color: Color(0xFF64748B), fontSize: 10.5, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              _invoiceItem('Skill School (skill-sch.com)', 'Amara J. · Inst 2/4', '₦100,000', kElumoGreen, isPaid: true),
              const SizedBox(height: 6),
              _invoiceItem('SolarGrid Energy', 'Emmanuel A. · Inst 4/6', '₦200,000', kElumoAmber, isPaid: false),
              const SizedBox(height: 6),
              _invoiceItem('Acme Corp Software', 'Q3 Retainer', '\$1,200', kElumoBlue, isPaid: true),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: kElumoGreen.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.bolt_rounded, color: kElumoDeepGreen, size: 14),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '10-Day Automated SMS Reminders Active',
                        style: TextStyle(color: kElumoDeepGreen, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      case _MockupType.currencySwap:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Instant Currency Swap', style: TextStyle(color: Color(0xFF64748B), fontSize: 10.5, fontWeight: FontWeight.w500)),
              const SizedBox(height: 10),
              _swapBox('You Pay', '1,500.00', 'USD (\$)'),
              const SizedBox(height: 6),
              const Center(child: Icon(Icons.swap_vert_rounded, color: kElumoAmber, size: 20)),
              const SizedBox(height: 6),
              _swapBox('You Get', '2,400,000.00', 'NGN (₦)'),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: kElumoGreen,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(color: kElumoGreen.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3)),
                  ],
                ),
                alignment: Alignment.center,
                child: const Text('Convert Instantly', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.5)),
              ),
            ],
          ),
        );
      case _MockupType.aiVoiceCall:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFEF3C7),
                  border: Border.all(color: kElumoAmber, width: 2),
                ),
                child: const Icon(Icons.record_voice_over_rounded, color: kElumoAmber, size: 24),
              ),
              const SizedBox(height: 8),
              const Text(
                'AI Collections Caller',
                style: TextStyle(color: Color(0xFF0F172A), fontSize: 13.5, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              const Text(
                'Calling David O. · ₦150,000 Overdue',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 10),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('Live Call · 00:42', style: TextStyle(color: kElumoDeepGreen, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Text(
                  '"Hello David, this is gabism AI following up on your Skill School invoice. I have dispatched a secure WhatsApp payment link to your phone."',
                  style: TextStyle(color: Color(0xFF334155), fontSize: 9.5, height: 1.35, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: kElumoGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: const Text('WhatsApp Link Sent', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.call_end_rounded, color: Colors.white, size: 14),
                  ),
                ],
              ),
            ],
          ),
        );
      case _MockupType.crossBorderFeed:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Cross-Border Settlements', style: TextStyle(color: Color(0xFF64748B), fontSize: 10.5, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              const Text('Live Inflow Stream', style: TextStyle(color: Color(0xFF0F172A), fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              _settlementItem('Nigeria (NGN)', 'Tuition · skill-sch.com', '+₦120,000.00', kElumoGreen),
              const SizedBox(height: 6),
              _settlementItem('United States (USD)', 'Stripe US Settlement', '+\$850.00', kElumoBlue),
              const SizedBox(height: 6),
              _settlementItem('Kenya (KES)', 'Supplier Payout', '+KSh 45,000.00', kElumoAmber),
              const SizedBox(height: 6),
              _settlementItem('Ghana (GHS)', 'Freelance Merchant', '+GH₵ 3,200.00', const Color(0xFF00D2B4)),
            ],
          ),
        );
      case _MockupType.billPayments:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Utility Bills & Services', style: TextStyle(color: Color(0xFF64748B), fontSize: 10.5, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              const Text('Quick Recharge Hub', style: TextStyle(color: Color(0xFF0F172A), fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Row(
                children: [
                  _quickBillChip(Icons.phone_android_rounded, 'Airtime', kElumoGreen),
                  const SizedBox(width: 6),
                  _quickBillChip(Icons.electric_bolt_rounded, 'Power', kElumoAmber),
                  const SizedBox(width: 6),
                  _quickBillChip(Icons.tv_rounded, 'Cable TV', kElumoBlue),
                  const SizedBox(width: 6),
                  _quickBillChip(Icons.wifi_rounded, 'Internet', const Color(0xFF00D2B4)),
                ],
              ),
              const SizedBox(height: 10),
              const Text('Recent Token Receipts', style: TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              _invoiceItem('IKEDC Prepaid Token', 'Token: 4920-1182-9930', '₦15,000', kElumoGreen, isPaid: true),
              const SizedBox(height: 6),
              _invoiceItem('MTN 20GB Data Bundle', '0803••••821', '₦5,000', kElumoBlue, isPaid: true),
              const SizedBox(height: 6),
              _invoiceItem('DStv Premium Renewal', 'Smartcard: 2018••••49', '₦29,000', kElumoAmber, isPaid: true),
            ],
          ),
        );
    }
  }

  Widget _quickBillChip(IconData icon, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Color(0xFF0F172A), fontSize: 8.5, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _settlementItem(String country, String desc, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(country, style: const TextStyle(color: Color(0xFF0F172A), fontSize: 10, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
              Text(desc, style: const TextStyle(color: Color(0xFF64748B), fontSize: 8.5)),
            ]),
          ),
          Text(amount, style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _balancePill(String name, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(color: Color(0xFF0F172A), fontSize: 11, fontWeight: FontWeight.w600)),
          Text(amount, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String val, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 10.5)),
          Text(val, style: TextStyle(color: isStatus ? kElumoGreen : const Color(0xFF0F172A), fontSize: 10.5, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _invoiceItem(String title, String sub, String amount, Color color, {bool isPaid = true}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(color: Color(0xFF0F172A), fontSize: 10, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
              Text(sub, style: const TextStyle(color: Color(0xFF64748B), fontSize: 8.5)),
            ]),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.bold)),
              Text(isPaid ? 'PAID' : 'DUE', style: TextStyle(color: isPaid ? kElumoDeepGreen : kElumoAmber, fontSize: 8, fontWeight: FontWeight.w900)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _swapBox(String label, String amount, String curr) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 9)),
            Text(amount, style: const TextStyle(color: Color(0xFF0F172A), fontSize: 13, fontWeight: FontWeight.bold)),
          ]),
          Text(curr, style: const TextStyle(color: kElumoGreen, fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
