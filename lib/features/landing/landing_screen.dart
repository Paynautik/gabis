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

// ─── Constants ─────────────────────────────────────────────────────────────
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
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final _scrollController = ScrollController();
  final _showcaseKey = GlobalKey();
  final _useCasesKey = GlobalKey();
  final _comparisonKey = GlobalKey();
  final _cardsKey = GlobalKey();
  final _securityKey = GlobalKey();
  final _faqKey = GlobalKey();

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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            GabisPayHero(
              onScrollTo: _scrollTo,
              showcaseKey: _showcaseKey,
              useCasesKey: _useCasesKey,
              cardsKey: _cardsKey,
              comparisonKey: _comparisonKey,
              faqKey: _faqKey,
            ),
            _InteractiveFeatureSlideSection(key: _showcaseKey),
            _UseCasesSection(key: _useCasesKey),
            _ValueComparisonSection(key: _comparisonKey),
            _DarkCardsShowcaseSection(key: _cardsKey),
            _SecurityComplianceSection(key: _securityKey),
            const _TestimonialsSection(),
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
// MAIN HERO (BENCHMARKED FROM BITSO)
// ============================================================

class GabisPayHero extends StatefulWidget {
  final void Function(GlobalKey)? onScrollTo;
  final GlobalKey? showcaseKey;
  final GlobalKey? useCasesKey;
  final GlobalKey? cardsKey;
  final GlobalKey? comparisonKey;
  final GlobalKey? faqKey;

  const GabisPayHero({
    super.key,
    this.onScrollTo,
    this.showcaseKey,
    this.useCasesKey,
    this.cardsKey,
    this.comparisonKey,
    this.faqKey,
  });

  @override
  State<GabisPayHero> createState() => _GabisPayHeroState();
}

class _GabisPayHeroState extends State<GabisPayHero> {
  int currentSlide = 0;
  Timer? slideTimer;

  final List<Map<String, String>> slides = [
    {
      'headline': 'Discover what your\nmoney\nis capable of',
      'body':
          'One app, every opportunity to build your future. Send, receive, earn, and spend globally in just a few taps.',
      'cta': 'Open your account',
    },
    {
      'headline': 'New gabis app:\npowerfully simple',
      'body':
          'The gabis app has a new look. It\'s been redesigned to simplify and enhance your global multi-currency payments, evolving with you and the future of your finances.',
      'cta': 'Download the new app',
    },
  ];

  @override
  void initState() {
    super.initState();
    slideTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (mounted) {
        setState(() {
          currentSlide = (currentSlide + 1) % slides.length;
        });
      }
    });
  }

  @override
  void dispose() {
    slideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 950;
        final slide = slides[currentSlide];

        return Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFFFAF9F6),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFFFFF),
                Color(0xFFF7F5F0),
              ],
            ),
          ),
          child: Column(
            children: [
              // Top Navigation Bar
              _BitsoNavigation(
                onScrollTo: widget.onScrollTo,
                showcaseKey: widget.showcaseKey,
                useCasesKey: widget.useCasesKey,
                cardsKey: widget.cardsKey,
                comparisonKey: widget.comparisonKey,
                faqKey: widget.faqKey,
              ),

              const SizedBox(height: 20),

              // Hero Body
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 24 : 64,
                ),
                child: isMobile
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _HeroSlideCopy(
                            slide: slide,
                            isMobile: true,
                          ),
                          const SizedBox(height: 40),
                          _HeroLifestyleVisual(
                            isMobile: true,
                          ),
                        ],
                      )
                    : SizedBox(
                        height: 560,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 50,
                              child: _HeroSlideCopy(
                                slide: slide,
                                isMobile: false,
                              ),
                            ),
                            const SizedBox(width: 32),
                            Expanded(
                              flex: 50,
                              child: _HeroLifestyleVisual(
                                isMobile: false,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),

              const SizedBox(height: 30),

              // Bottom Carousel Navigation Controls (< [—— —— ——] >)
              _CarouselControls(
                currentIndex: currentSlide,
                totalCount: slides.length,
                onSelect: (index) {
                  setState(() {
                    currentSlide = index;
                  });
                },
                onPrev: () {
                  setState(() {
                    currentSlide = (currentSlide - 1 + slides.length) % slides.length;
                  });
                },
                onNext: () {
                  setState(() {
                    currentSlide = (currentSlide + 1) % slides.length;
                  });
                },
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
// BITSO-STYLE NAVIGATION
// ============================================================

class _BitsoNavigation extends StatelessWidget {
  final void Function(GlobalKey)? onScrollTo;
  final GlobalKey? showcaseKey;
  final GlobalKey? useCasesKey;
  final GlobalKey? cardsKey;
  final GlobalKey? comparisonKey;
  final GlobalKey? faqKey;

  const _BitsoNavigation({
    this.onScrollTo,
    this.showcaseKey,
    this.useCasesKey,
    this.cardsKey,
    this.comparisonKey,
    this.faqKey,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 950;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 55,
        vertical: 18,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Official gabis Logo
          Row(
            children: [
              const GabisLogo(size: 34),
              if (!isMobile) ...[
                const SizedBox(width: 42),
                _NavDropdownItem('About gabis', onTap: () {
                  if (comparisonKey != null) onScrollTo?.call(comparisonKey!);
                }),
                _NavDropdownItem('Products', onTap: () {
                  if (showcaseKey != null) onScrollTo?.call(showcaseKey!);
                }),
                _NavDropdownItem('Cards', onTap: () {
                  if (cardsKey != null) onScrollTo?.call(cardsKey!);
                }),
                _NavDropdownItem('Business', onTap: () {
                  if (useCasesKey != null) onScrollTo?.call(useCasesKey!);
                }),
                _NavDropdownItem('Support', onTap: () {
                  if (faqKey != null) onScrollTo?.call(faqKey!);
                }),
              ],
            ],
          ),

          // Right: Action Buttons
          Row(
            children: [
              if (!isMobile) ...[
                _NavDropdownItem('Download app', showArrow: true),
                const SizedBox(width: 14),
                const Row(
                  children: [
                    Icon(Icons.language, size: 16, color: Color(0xFF22263C)),
                    SizedBox(width: 4),
                    Text(
                      'US',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF22263C),
                      ),
                    ),
                    Icon(Icons.keyboard_arrow_down, size: 14, color: Color(0xFF22263C)),
                  ],
                ),
                const SizedBox(width: 20),
              ],
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/login'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEBE9FE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Log in',
                    style: TextStyle(
                      color: Color(0xFF4F46E5),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/login'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F46E5).withValues(alpha: 0.25),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Sign up',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavDropdownItem extends StatelessWidget {
  final String title;
  final bool showArrow;
  final VoidCallback? onTap;

  const _NavDropdownItem(this.title, {this.showArrow = true, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E2442),
              ),
            ),
            if (showArrow) ...[
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down,
                size: 14,
                color: Color(0xFF555B77),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================================
// HERO SLIDE COPY
// ============================================================

class _HeroSlideCopy extends StatelessWidget {
  final Map<String, String> slide;
  final bool isMobile;

  const _HeroSlideCopy({
    required this.slide,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Large Bold Headline
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: Text(
            slide['headline'] ?? '',
            key: ValueKey(slide['headline']),
            style: TextStyle(
              fontSize: isMobile ? 40 : 58,
              height: 1.08,
              fontWeight: FontWeight.w800,
              letterSpacing: -2.0,
              color: const Color(0xFF0F172A),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Subtitle Description
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: Text(
            slide['body'] ?? '',
            key: ValueKey(slide['body']),
            style: const TextStyle(
              fontSize: 17,
              height: 1.55,
              fontWeight: FontWeight.w400,
              color: Color(0xFF475569),
            ),
          ),
        ),

        const SizedBox(height: 34),

        // Pill CTA Button
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/login'),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 30,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF4F46E5),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.30),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Text(
              slide['cta'] ?? 'Open your account',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// HERO LIFESTYLE VISUAL
// ============================================================

class _HeroLifestyleVisual extends StatelessWidget {
  final bool isMobile;

  const _HeroLifestyleVisual({
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isMobile ? 360 : 520,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Lifestyle Photography Image
            Image.asset(
              'assets/images/hero_bitso_holding_phone.jpg',
              fit: BoxFit.cover,
            ),

            // Subtle Glassmorphism Live Notification Badge
            Positioned(
              bottom: 24,
              left: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4F46E5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.trending_up,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Total Balance',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          '₦14,850,500.00',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ],
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
// CAROUSEL CONTROLS
// ============================================================

class _CarouselControls extends StatelessWidget {
  final int currentIndex;
  final int totalCount;
  final ValueChanged<int> onSelect;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _CarouselControls({
    required this.currentIndex,
    required this.totalCount,
    required this.onSelect,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Prev Arrow
        InkWell(
          onTap: onPrev,
          borderRadius: BorderRadius.circular(20),
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(
              Icons.arrow_back_ios_new,
              size: 13,
              color: Color(0xFF64748B),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Indicator Bars
        Row(
          children: List.generate(totalCount, (index) {
            final isActive = index == currentIndex;
            return GestureDetector(
              onTap: () => onSelect(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 38 : 22,
                height: 4,
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF4F46E5) : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ),

        const SizedBox(width: 8),

        // Next Arrow
        InkWell(
          onTap: onNext,
          borderRadius: BorderRadius.circular(20),
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(
              Icons.arrow_forward_ios,
              size: 13,
              color: Color(0xFF64748B),
            ),
          ),
        ),
      ],
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
                                height: 600,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(32),
                                  border: Border.all(color: const Color(0xFFF1F5F9)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 32,
                                      offset: const Offset(0, 16),
                                    ),
                                    BoxShadow(
                                      color: currentSlide.accentColor.withValues(alpha: 0.06),
                                      blurRadius: 40,
                                      offset: const Offset(0, 20),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Soft ambient studio glow in background
                                    Positioned(
                                      top: 40,
                                      child: Container(
                                        width: 280,
                                        height: 280,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: currentSlide.accentColor.withValues(alpha: 0.10),
                                        ),
                                      ),
                                    ),
                                    // High-Definition Standing Phone Mockup
                                    Center(
                                      child: _SingleHeroPhone(type: currentSlide.mockupType),
                                    ),
                                  ],
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
                              height: 540,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(color: const Color(0xFFF1F5F9)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 24,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Positioned(
                                    top: 30,
                                    child: Container(
                                      width: 220,
                                      height: 220,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: currentSlide.accentColor.withValues(alpha: 0.08),
                                      ),
                                    ),
                                  ),
                                  Center(
                                    child: Transform.scale(
                                      scale: 0.88,
                                      child: _SingleHeroPhone(type: currentSlide.mockupType),
                                    ),
                                  ),
                                ],
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
    final isDesktop = MediaQuery.of(context).size.width >= 960;

    return Container(
      width: double.infinity,
      color: const Color(0xFFFAFBFD),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 48 : 20,
        vertical: isDesktop ? 90 : 50,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1160),
          child: Column(
            children: [
              // Top Brand Logo
              Image.asset(
                'assets/gabis_pay_logo.png',
                height: 42,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),

              // Section Headline
              const Text(
                'Virtual Cards for Global Ambition',
                style: TextStyle(
                  color: Color(0xFF11163F),
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Section Subtitle
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: const Text(
                  'Create instant multi-currency cards for Netflix, AWS, Apple, and international vendor spending with zero decline rates.',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 16,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 44),

              // Main Card Showcase White Container
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 48 : 24,
                  vertical: isDesktop ? 50 : 36,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF11163F).withOpacity(0.06),
                      blurRadius: 36,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 5,
                            child: _buildLeftCardCopy(context),
                          ),
                          const SizedBox(width: 40),
                          const Expanded(
                            flex: 6,
                            child: _RealisticVirtualCardsFan(),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _buildLeftCardCopy(context),
                          const SizedBox(height: 44),
                          const _RealisticVirtualCardsFan(),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeftCardCopy(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w800,
              color: Color(0xFF11163F),
              letterSpacing: -1.5,
              height: 1.15,
            ),
            children: [
              TextSpan(text: 'A '),
              TextSpan(
                text: 'Better ',
                style: TextStyle(color: Color(0xFF5535E8)),
              ),
              TextSpan(text: 'Way\nto Spend Globally'),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Instant 3D-secure virtual debit cards in USD, GBP, EUR, and NGN. Set custom transaction limits, freeze cards in 1-tap, and eliminate payment rejections.',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 15,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 32),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/login'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 15),
            decoration: BoxDecoration(
              color: const Color(0xFF4322DC),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4322DC).withOpacity(0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Get a Virtual Card',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                SizedBox(width: 10),
                Icon(Icons.arrow_forward, color: Colors.white, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── 4 Realistic Fanned Virtual Cards ─────────────────────────────────────────
class _RealisticVirtualCardsFan extends StatelessWidget {
  const _RealisticVirtualCardsFan();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // 1. Bottom Matte Black Card
          Positioned(
            left: 0,
            bottom: 10,
            child: Transform.rotate(
              angle: -0.14,
              child: _buildMatteBlackCard(),
            ),
          ),

          // 2. Pure White Card (Mastercard)
          Positioned(
            left: 30,
            bottom: 35,
            child: Transform.rotate(
              angle: -0.06,
              child: _buildWhiteMastercard(),
            ),
          ),

          // 3. Deep Slate Blue Card
          Positioned(
            left: 110,
            bottom: 55,
            child: Transform.rotate(
              angle: 0.02,
              child: _buildSlateBlueCard(),
            ),
          ),

          // 4. Front Royal Indigo Metallic Card (Visa)
          Positioned(
            left: 170,
            bottom: 45,
            child: Transform.rotate(
              angle: 0.08,
              child: _buildFrontRoyalIndigoCard(),
            ),
          ),
        ],
      ),
    );
  }

  // Card 1: Matte Black
  Widget _buildMatteBlackCard() {
    return Container(
      width: 270,
      height: 165,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF18181B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF27272A)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildEmvChip(size: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('4279 8820 •••• 1042', style: TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 1.0, fontFamily: 'monospace')),
                  SizedBox(height: 2),
                  Text('VALID THRU 12/28', style: TextStyle(color: Colors.white38, fontSize: 8)),
                ],
              ),
              _buildVisaTextLogo(color: Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  // Card 2: Pure White Mastercard
  Widget _buildWhiteMastercard() {
    return Container(
      width: 270,
      height: 165,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF11163F).withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset('assets/gabis_pay_logo.png', height: 20, fit: BoxFit.contain),
          _buildEmvChip(size: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('5170 1200 4882 9912', style: TextStyle(color: Color(0xFF334155), fontSize: 11, letterSpacing: 1.0, fontWeight: FontWeight.w600, fontFamily: 'monospace')),
                  SizedBox(height: 2),
                  Text('VALID THRU 12/28', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 8)),
                ],
              ),
              _buildMastercardLogo(size: 26),
            ],
          ),
        ],
      ),
    );
  }

  // Card 3: Deep Slate Blue Card
  Widget _buildSlateBlueCard() {
    return Container(
      width: 270,
      height: 165,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.35),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset('assets/gabis_pay_logo_white.png', height: 18, fit: BoxFit.contain),
          _buildEmvChip(size: 28),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('4829 9920 1834 5501', style: TextStyle(color: Colors.white, fontSize: 11, letterSpacing: 1.0, fontWeight: FontWeight.w600, fontFamily: 'monospace')),
              SizedBox(height: 2),
              Text('VALID THRU 12/28', style: TextStyle(color: Colors.white54, fontSize: 8)),
            ],
          ),
        ],
      ),
    );
  }

  // Card 4: Top Royal Indigo Card (Main Feature Card)
  Widget _buildFrontRoyalIndigoCard() {
    return Container(
      width: 285,
      height: 175,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E0E62),
            Color(0xFF292083),
            Color(0xFF381EA5),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.18), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E0E62).withOpacity(0.40),
            blurRadius: 30,
            offset: const Offset(0, 16),
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
              Image.asset('assets/gabis_pay_logo_white.png', height: 22, fit: BoxFit.contain),
              const Text(
                'NGN CARD',
                style: TextStyle(color: Colors.white70, fontSize: 9.5, fontWeight: FontWeight.w800, letterSpacing: 0.8),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildEmvChip(size: 32),
              const Icon(Icons.wifi_rounded, color: Colors.white70, size: 20),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '5591  2320  7701  8842',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      letterSpacing: 1.8,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'monospace',
                    ),
                  ),
                  SizedBox(height: 4),
                  Text('VALID THRU 12/28', style: TextStyle(color: Colors.white60, fontSize: 8.5)),
                ],
              ),
              _buildVisaTextLogo(color: Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  // Realistic EMV Chip
  Widget _buildEmvChip({double size = 30}) {
    return Container(
      width: size * 1.25,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37),
        borderRadius: BorderRadius.circular(5),
        gradient: const LinearGradient(
          colors: [Color(0xFFFFDF73), Color(0xFFB8860B), Color(0xFFE6CA65)],
        ),
      ),
      child: CustomPaint(
        painter: _ChipGridPainter(),
      ),
    );
  }

  // Mastercard Interlocking Circles Logo
  Widget _buildMastercardLogo({double size = 26}) {
    return SizedBox(
      width: size * 1.5,
      height: size,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            child: Container(
              width: size,
              height: size,
              decoration: const BoxDecoration(
                color: Color(0xFFEB001B),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 0,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: const Color(0xFFF79E1B).withOpacity(0.88),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // VISA Text Logo
  Widget _buildVisaTextLogo({required Color color}) {
    return Text(
      'VISA',
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.w900,
        fontSize: 18,
        letterSpacing: 0.5,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}

class _ChipGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF785900).withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final w = size.width;
    final h = size.height;

    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.2, h * 0.2, w * 0.6, h * 0.6), const Radius.circular(2)), paint);
    canvas.drawLine(Offset(0, h * 0.5), Offset(w, h * 0.5), paint);
    canvas.drawLine(Offset(w * 0.5, 0), Offset(w * 0.5, h), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================================
// 7. SECURITY SECTION (TRUSTED ACROSS AFRICA)
// ============================================================================
class _SecurityComplianceSection extends StatelessWidget {
  const _SecurityComplianceSection({super.key});

  static const List<Map<String, dynamic>> _securityFeatures = [
    {
      'icon': Icons.shield_rounded,
      'title': 'Top-Notch Security',
      'description':
          'End-to-end 256-bit AES encryption, biometric authentication, zero-knowledge architecture, and enterprise-grade infrastructure.',
    },
    {
      'icon': Icons.receipt_long_rounded,
      'title': 'Pan-African Tax Compliance',
      'description':
          'Automated VAT, withholding tax, and regulatory compliance across Nigeria, Kenya, Ghana, and South Africa.',
    },
    {
      'icon': Icons.headset_mic_rounded,
      'title': '24/7 Dedicated Support',
      'description':
          'Dedicated customer intelligence via chat, email, phone, and WhatsApp whenever you need help.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 992;

    return Container(
      width: double.infinity,
      color: const Color(0xFF05070A),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 48 : 20,
        vertical: isDesktop ? 68 : 44,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background Emerald Glow
          Positioned(
            right: -120,
            top: -100,
            child: Container(
              width: 450,
              height: 450,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF10B981).withValues(alpha: 0.08),
              ),
            ),
          ),

          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.10),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          size: 14,
                          color: Color(0xFF34D399),
                        ),
                        SizedBox(width: 6),
                        Text(
                          'TRUSTED ACROSS AFRICA',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2.0,
                            color: Color(0xFFA1A1AA),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Heading
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: isDesktop ? 42 : 28,
                          fontWeight: FontWeight.w700,
                          height: 1.05,
                          letterSpacing: -1.5,
                          color: Colors.white,
                          fontFamily: 'Arial',
                        ),
                        children: const [
                          TextSpan(text: 'Keeping your money '),
                          TextSpan(
                            text: 'safe',
                            style: TextStyle(
                              color: Color(0xFF34D399),
                            ),
                          ),
                          TextSpan(text: ' is our business.'),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Subtitle
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 580),
                    child: const Text(
                      'Trust is our currency. We are committed to institutional security, pan-African compliance, and always-on support for businesses across Africa.',
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFFA1A1AA),
                      ),
                    ),
                  ),

                  const SizedBox(height: 38),

                  // Cards Grid
                  isDesktop
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _securityFeatures.map((f) {
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: _InteractiveSecurityCard(feature: f),
                              ),
                            );
                          }).toList(),
                        )
                      : Column(
                          children: _securityFeatures.map((f) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: _InteractiveSecurityCard(feature: f),
                            );
                          }).toList(),
                        ),

                  const SizedBox(height: 36),

                  // Bottom Trust Bar
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 20),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                    ),
                    child: Wrap(
                      spacing: 24,
                      runSpacing: 12,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: const [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.shield_outlined,
                              size: 14,
                              color: Color(0xFF34D399),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Bank-grade Security',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Color(0xFF71717A),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'ISO 27001 Aligned',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF71717A),
                          ),
                        ),
                        Text(
                          'Built for Africa',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF71717A),
                          ),
                        ),
                      ],
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

class _InteractiveSecurityCard extends StatefulWidget {
  final Map<String, dynamic> feature;
  const _InteractiveSecurityCard({required this.feature});

  @override
  State<_InteractiveSecurityCard> createState() => _InteractiveSecurityCardState();
}

class _InteractiveSecurityCardState extends State<_InteractiveSecurityCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final f = widget.feature;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: _isHovered
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered
                ? const Color(0xFF34D399).withValues(alpha: 0.20)
                : Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                f['icon'] as IconData,
                color: const Color(0xFF34D399),
                size: 22,
              ),
            ),

            const SizedBox(height: 20),

            // Title
            Text(
              f['title'] as String,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 10),

            // Description
            Text(
              f['description'] as String,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.5,
                color: Color(0xFFA1A1AA),
              ),
            ),

            const SizedBox(height: 22),

            // Arrow Button
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isHovered
                      ? const Color(0xFF34D399)
                      : Colors.white.withValues(alpha: 0.10),
                ),
              ),
              child: Icon(
                Icons.arrow_outward_rounded,
                size: 16,
                color: _isHovered
                    ? const Color(0xFF34D399)
                    : const Color(0xFF71717A),
              ),
            ),
          ],
        ),
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
// 8. TESTIMONIALS SECTION (BENCHMARKED FROM BITSO)
// ============================================================================
class _TestimonialsSection extends StatelessWidget {
  const _TestimonialsSection();

  static const List<Map<String, String>> _reviews = [
    {
      'title': 'My favorite app since day one.',
      'body': '"For me, the most reliable multi-currency account, 10/10."',
      'store': 'App Store',
      'icon': 'apple',
    },
    {
      'title': 'Excellent',
      'body':
          '"I like the sense of security that comes from how fast deposits, transfers, and real-time rates are."',
      'store': 'App Store',
      'icon': 'apple',
    },
    {
      'title': 'Great app',
      'body':
          '"It\'s super practical, and I see it as a portable tool for my business. Congrats, let\'s keep moving forward!"',
      'store': 'Google Play',
      'icon': 'google',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 992;

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64 : 24,
        vertical: isDesktop ? 90 : 60,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              // Top Sand/Beige Hero Card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E0D8),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: isDesktop
                      ? Row(
                          children: [
                            // Left Content
                            Expanded(
                              flex: 55,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 56,
                                  vertical: 64,
                                ),
                                child: _buildHeroLeftContent(context),
                              ),
                            ),

                            // Right Image
                            Expanded(
                              flex: 45,
                              child: SizedBox(
                                height: 420,
                                child: Image.asset(
                                  'assets/images/testimonial_hero_african.jpg',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(32),
                              child: _buildHeroLeftContent(context),
                            ),
                            SizedBox(
                              height: 280,
                              width: double.infinity,
                              child: Image.asset(
                                'assets/images/testimonial_hero_african.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 48),

              // Bottom 3 Review Cards Grid
              isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _reviews.map((r) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: _ReviewCard(review: r),
                          ),
                        );
                      }).toList(),
                    )
                  : Column(
                      children: _reviews.map((r) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _ReviewCard(review: r),
                        );
                      }).toList(),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroLeftContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'gabis: where Africa\nmoves money',
          style: TextStyle(
            fontSize: 42,
            height: 1.08,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.5,
            color: Color(0xFF1E1E24),
            fontFamily: 'Arial',
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'A record that speaks for itself: gabis has been protecting your money with top security and multi-currency licenses. With gabis, you\'re in trusted hands.',
          style: TextStyle(
            fontSize: 15.5,
            height: 1.55,
            color: Color(0xFF4A4A52),
          ),
        ),
        const SizedBox(height: 28),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/login'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF4F46E5),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.25),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Text(
              'Create your account',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Map<String, String> review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF9F5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEDE8DF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 5 Purple/Blue Stars
          Row(
            children: List.generate(
              5,
              (index) => const Padding(
                padding: EdgeInsets.only(right: 3),
                child: Icon(
                  Icons.star_rounded,
                  color: Color(0xFF4F46E5),
                  size: 18,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Title
          Text(
            review['title']!,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E2442),
            ),
          ),

          const SizedBox(height: 8),

          // Body
          Text(
            review['body']!,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.5,
              color: Color(0xFF64748B),
            ),
          ),

          const SizedBox(height: 20),

          // Store Badge
          Row(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: const BoxDecoration(
                  color: Color(0xFF059669),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 12,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                review['store']!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 10. BITSO-BENCHMARKED CTA SECTION
// ============================================================================
class _DownloadCtaSection extends StatelessWidget {
  const _DownloadCtaSection();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 64 : 24,
        vertical: isDesktop ? 70 : 40,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Container(
            width: double.infinity,
            height: isDesktop ? 340 : 440,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.10),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Photography Background
                  Image.asset(
                    'assets/images/cta_hero_cozy_african.jpg',
                    fit: BoxFit.cover,
                  ),

                  // Contrast Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.black.withValues(alpha: 0.82),
                          Colors.black.withValues(alpha: 0.55),
                          Colors.black.withValues(alpha: 0.10),
                        ],
                        stops: const [0.0, 0.55, 1.0],
                      ),
                    ),
                  ),

                  // Left Hero Copy Content
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop ? 56 : 28,
                      vertical: isDesktop ? 44 : 32,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Try gabis. Start with\njust \$10 USD.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isDesktop ? 44 : 30,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.5,
                            height: 1.05,
                            fontFamily: 'Arial',
                          ),
                        ),
                        const SizedBox(height: 14),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 480),
                          child: const Text(
                            'Discover what your money is capable of: send, receive, earn, and move money globally in minutes.',
                            style: TextStyle(
                              color: Color(0xFFE2E8F0),
                              fontSize: 15,
                              height: 1.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/login'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 28,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4F46E5),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4F46E5).withValues(alpha: 0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Text(
                              'Start now',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 14.5,
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
        ),
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
