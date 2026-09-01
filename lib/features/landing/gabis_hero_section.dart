import 'package:flutter/material.dart';
import '../../shared/widgets/gabis_phone_frame.dart';
import '../../shared/widgets/nautik_logo.dart';

/// Gabis landing hero — V2
///
/// Drop-in replacement for the current `GabisHeroSection`.
/// The public API is intentionally unchanged, so the existing LandingScreen can
/// continue to use `const GabisHeroSection()`.
class GabisHeroSection extends StatelessWidget {
  /// Called with a nav label so the page can scroll to the matching section.
  final void Function(String label)? onNavTap;

  const GabisHeroSection({super.key, this.onNavTap});

  static const accent = Color(0xFF2F4BFF);
  static const accentDark = Color(0xFF2439CF);
  static const ink = Color(0xFF0D1830);
  static const muted = Color(0xFF667385);
  static const canvas = Color(0xFFF7F8FC);
  static const softAccent = Color(0xFFEEF1FF);
  static const border = Color(0xFFE8EBF2);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final desktop = width >= 1040;
        final tablet = width >= 720 && !desktop;

        return DecoratedBox(
          decoration: const BoxDecoration(
            color: Colors.white,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFFFFF),
                Color(0xFFFAFAFE),
                Color(0xFFF1F3FF),
              ],
              stops: [0, .52, 1],
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Positioned.fill(child: _HeroBackdrop()),
              SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: desktop ? 48 : (tablet ? 32 : 20),
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1280),
                          child: _Navbar(onNavTap: onNavTap),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        desktop ? 48 : (tablet ? 32 : 20),
                        desktop ? 28 : 22,
                        desktop ? 48 : (tablet ? 32 : 20),
                        0,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1280),
                          child: desktop
                              ? SizedBox(
                                  height: 620,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        flex: 10,
                                        child: _HeroCopy(onNavTap: onNavTap),
                                      ),
                                      SizedBox(width: 26),
                                      Expanded(
                                        flex: 10,
                                        child: _ProductVisual(),
                                      ),
                                    ],
                                  ),
                                )
                              : Column(
                                  children: [
                                    _HeroCopy(onNavTap: onNavTap),
                                    SizedBox(height: 34),
                                    _ProductVisual(),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const _TrustStrip(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeroBackdrop extends StatelessWidget {
  const _HeroBackdrop();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          right: -190,
          top: 70,
          child: Container(
            width: 720,
            height: 720,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  GabisHeroSection.accent.withValues(alpha: .11),
                  GabisHeroSection.accent.withValues(alpha: .025),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: -220,
          bottom: -300,
          child: Container(
            width: 640,
            height: 640,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF7ED8FF).withValues(alpha: .06),
            ),
          ),
        ),
      ],
    );
  }
}

class _Navbar extends StatelessWidget {
  final void Function(String label)? onNavTap;
  const _Navbar({this.onNavTap});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= 980;

        return SizedBox(
          height: 76,
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(right: 6),
                child: GabisLogo(size: 36),
              ),
              if (desktop) ...[
                const SizedBox(width: 34),
                _NavLink(label: 'Personal', onTap: onNavTap),
                _NavLink(label: 'Business', onTap: onNavTap),
                _NavLink(label: 'Cards', onTap: onNavTap),
                _NavLink(label: 'About', onTap: onNavTap),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  style: TextButton.styleFrom(
                    foregroundColor: GabisHeroSection.ink,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    'Log in',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  style: FilledButton.styleFrom(
                    backgroundColor: GabisHeroSection.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Get Gabis',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ] else ...[
                const Spacer(),
                FilledButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  style: FilledButton.styleFrom(
                    backgroundColor: GabisHeroSection.accent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: const Text(
                    'Get Gabis',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  tooltip: 'Menu',
                  icon: const Icon(Icons.menu_rounded),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final void Function(String label)? onTap;

  const _NavLink({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextButton(
        onPressed: () => onTap?.call(label),
        style: TextButton.styleFrom(
          foregroundColor: GabisHeroSection.ink,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  final void Function(String label)? onNavTap;
  const _HeroCopy({this.onNavTap});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final desktop = width >= 1040;
    final mobile = width < 620;

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 650),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Eyebrow(),
            SizedBox(height: desktop ? 24 : 20),
            Text.rich(
              TextSpan(
                children: const [
                  TextSpan(text: 'Your money should move\n'),
                  TextSpan(text: 'as freely as '),
                  TextSpan(
                    text: 'you do.',
                    style: TextStyle(color: GabisHeroSection.accent),
                  ),
                ],
              ),
              style: TextStyle(
                color: GabisHeroSection.ink,
                fontSize: desktop ? 67 : (mobile ? 45 : 57),
                height: 1.015,
                letterSpacing: desktop ? -3.1 : -2.2,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 23),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 590),
              child: Text(
                'Send, spend and receive money across Africa and beyond — from one beautifully simple account.',
                style: TextStyle(
                  color: GabisHeroSection.muted,
                  fontSize: mobile ? 17 : 18.5,
                  height: 1.55,
                  letterSpacing: -.15,
                ),
              ),
            ),
            const SizedBox(height: 28),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                FilledButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  style: FilledButton.styleFrom(
                    backgroundColor: GabisHeroSection.accent,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: mobile ? 23 : 27,
                      vertical: 19,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Get Gabis',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward_rounded, size: 19),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => onNavTap?.call('Personal'),
                  style: TextButton.styleFrom(
                    foregroundColor: GabisHeroSection.ink,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 18,
                    ),
                  ),
                  icon: const Icon(
                    Icons.play_circle_outline_rounded,
                    size: 21,
                  ),
                  label: const Text(
                    'See how it works',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 27),
            const Wrap(
              spacing: 22,
              runSpacing: 12,
              children: [
                _MicroBenefit(
                  icon: Icons.swap_horiz_rounded,
                  label: 'Send & receive',
                ),
                _MicroBenefit(
                  icon: Icons.credit_card_rounded,
                  label: 'Spend globally',
                ),
                _MicroBenefit(
                  icon: Icons.shield_outlined,
                  label: 'Secure by design',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .74),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: GabisHeroSection.border),
        boxShadow: [
          BoxShadow(
            color: GabisHeroSection.ink.withValues(alpha: .035),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LiveDot(),
          SizedBox(width: 9),
          Text(
            'MONEY WITHOUT BORDERS',
            style: TextStyle(
              color: GabisHeroSection.ink,
              fontSize: 11.5,
              letterSpacing: 1.25,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveDot extends StatelessWidget {
  const _LiveDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9,
      height: 9,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF12B76A),
      ),
    );
  }
}

class _MicroBenefit extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MicroBenefit({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: GabisHeroSection.accent),
        const SizedBox(width: 7),
        Text(
          label,
          style: const TextStyle(
            color: GabisHeroSection.muted,
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ProductVisual extends StatelessWidget {
  const _ProductVisual();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final desktop = width >= 1040;
    final mobile = width < 600;
    final height = desktop ? 600.0 : (mobile ? 510.0 : 570.0);

    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final visualWidth = constraints.maxWidth;
          final phoneWidth = desktop
              ? 306.0
              : (visualWidth < 390 ? visualWidth * .68 : 286.0);
          final phoneHeight = phoneWidth * 1.84;

          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Positioned(
                top: desktop ? 45 : 30,
                child: Container(
                  width: desktop ? 510 : 430,
                  height: desktop ? 510 : 430,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        GabisHeroSection.accent.withValues(alpha: .12),
                        GabisHeroSection.accent.withValues(alpha: .035),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              if (!mobile)
                Positioned(
                  left: desktop ? 4 : 0,
                  top: desktop ? 118 : 95,
                  child: const _FloatingBalanceCard(),
                ),
              if (!mobile)
                Positioned(
                  right: desktop ? 0 : 6,
                  top: desktop ? 220 : 205,
                  child: const _FloatingTransferCard(),
                ),
              Positioned(
                top: desktop ? 28 : 20,
                child: Transform.rotate(
                  angle: desktop ? .035 : .02,
                  child: _PhoneMockup(
                    width: phoneWidth,
                    height: phoneHeight,
                  ),
                ),
              ),
              Positioned(
                left: mobile ? 3 : (desktop ? 25 : 22),
                bottom: desktop ? 46 : 22,
                child: const _FloatingCardPreview(),
              ),
              Positioned(
                right: mobile ? 2 : (desktop ? 16 : 18),
                bottom: desktop ? 96 : 78,
                child: const _FloatingSuccessChip(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PhoneMockup extends StatelessWidget {
  final double width;
  final double height;

  const _PhoneMockup({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    final scale = width / 306;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(44 * scale),
        boxShadow: [
          BoxShadow(
            color: GabisHeroSection.ink.withValues(alpha: .18),
            blurRadius: 48,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      child: GabisPhoneFrame(
        width: width,
        height: height,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            18 * scale,
            16 * scale,
            18 * scale,
            18 * scale,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 35 * scale,
                    height: 35 * scale,
                    decoration: BoxDecoration(
                      color: GabisHeroSection.softAccent,
                      borderRadius: BorderRadius.circular(11 * scale),
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      size: 18 * scale,
                      color: GabisHeroSection.accent,
                    ),
                  ),
                  SizedBox(width: 10 * scale),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Good morning',
                          style: TextStyle(
                            fontSize: 10.5 * scale,
                            color: GabisHeroSection.muted,
                          ),
                        ),
                        Text(
                          'Your Gabis account',
                          style: TextStyle(
                            fontSize: 12 * scale,
                            fontWeight: FontWeight.w800,
                            color: GabisHeroSection.ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.notifications_none_rounded,
                    size: 21 * scale,
                    color: GabisHeroSection.ink,
                  ),
                ],
              ),
              SizedBox(height: 22 * scale),
              Text(
                'TOTAL BALANCE',
                style: TextStyle(
                  fontSize: 9.5 * scale,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w800,
                  color: GabisHeroSection.muted,
                ),
              ),
              SizedBox(height: 6 * scale),
              Text(
                '₦1,485,050.50',
                style: TextStyle(
                  fontSize: 27 * scale,
                  letterSpacing: -1.1,
                  fontWeight: FontWeight.w900,
                  color: GabisHeroSection.ink,
                ),
              ),
              SizedBox(height: 22 * scale),
              Row(
                children: [
                  Expanded(
                    child: _PhoneAction(
                      icon: Icons.arrow_upward_rounded,
                      label: 'Send',
                      scale: scale,
                    ),
                  ),
                  SizedBox(width: 8 * scale),
                  Expanded(
                    child: _PhoneAction(
                      icon: Icons.arrow_downward_rounded,
                      label: 'Receive',
                      scale: scale,
                    ),
                  ),
                  SizedBox(width: 8 * scale),
                  Expanded(
                    child: _PhoneAction(
                      icon: Icons.credit_card_rounded,
                      label: 'Cards',
                      scale: scale,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24 * scale),
              Text(
                'Your wallets',
                style: TextStyle(
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w900,
                  color: GabisHeroSection.ink,
                ),
              ),
              SizedBox(height: 10 * scale),
              _WalletTile(
                flag: '🇳🇬',
                code: 'NGN',
                name: 'Nigerian Naira',
                amount: '₦1,320,000',
                scale: scale,
              ),
              SizedBox(height: 8 * scale),
              _WalletTile(
                flag: '🇺🇸',
                code: 'USD',
                name: 'US Dollar',
                amount: r'$98.25',
                scale: scale,
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(13 * scale),
                decoration: BoxDecoration(
                  color: GabisHeroSection.softAccent,
                  borderRadius: BorderRadius.circular(16 * scale),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 33 * scale,
                      height: 33 * scale,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10 * scale),
                      ),
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        size: 16 * scale,
                        color: GabisHeroSection.accent,
                      ),
                    ),
                    SizedBox(width: 9 * scale),
                    Expanded(
                      child: Text(
                        'Everything you need in one account',
                        style: TextStyle(
                          fontSize: 10.5 * scale,
                          height: 1.3,
                          fontWeight: FontWeight.w700,
                          color: GabisHeroSection.ink,
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
}

class _PhoneAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final double scale;

  const _PhoneAction({
    required this.icon,
    required this.label,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 11 * scale),
      decoration: BoxDecoration(
        color: GabisHeroSection.accent,
        borderRadius: BorderRadius.circular(13 * scale),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 17 * scale),
          SizedBox(height: 5 * scale),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 9.5 * scale,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletTile extends StatelessWidget {
  final String flag;
  final String code;
  final String name;
  final String amount;
  final double scale;

  const _WalletTile({
    required this.flag,
    required this.code,
    required this.name,
    required this.amount,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(11 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFBFD),
        borderRadius: BorderRadius.circular(14 * scale),
        border: Border.all(color: GabisHeroSection.border),
      ),
      child: Row(
        children: [
          Text(flag, style: TextStyle(fontSize: 20 * scale)),
          SizedBox(width: 9 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  code,
                  style: TextStyle(
                    fontSize: 11 * scale,
                    fontWeight: FontWeight.w900,
                    color: GabisHeroSection.ink,
                  ),
                ),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 9 * scale,
                    color: GabisHeroSection.muted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 10.5 * scale,
              fontWeight: FontWeight.w800,
              color: GabisHeroSection.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingBalanceCard extends StatelessWidget {
  const _FloatingBalanceCard();

  @override
  Widget build(BuildContext context) {
    return const _GlassCard(
      width: 185,
      child: Row(
        children: [
          _FloatIcon(icon: Icons.account_balance_wallet_outlined),
          SizedBox(width: 11),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Multi-currency',
                style: TextStyle(
                  color: GabisHeroSection.muted,
                  fontSize: 11,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'NGN  •  USD',
                style: TextStyle(
                  color: GabisHeroSection.ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FloatingTransferCard extends StatelessWidget {
  const _FloatingTransferCard();

  @override
  Widget build(BuildContext context) {
    return const _GlassCard(
      width: 190,
      child: Row(
        children: [
          _FloatIcon(icon: Icons.south_west_rounded),
          SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Money received',
                  style: TextStyle(
                    color: GabisHeroSection.muted,
                    fontSize: 11,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  '+ ₦85,000',
                  style: TextStyle(
                    color: GabisHeroSection.ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatIcon extends StatelessWidget {
  final IconData icon;

  const _FloatIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: GabisHeroSection.softAccent,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Icon(icon, size: 18, color: GabisHeroSection.accent),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final double width;
  final Widget child;

  const _GlassCard({required this.width, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .92),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: GabisHeroSection.ink.withValues(alpha: .09),
            blurRadius: 28,
            offset: const Offset(0, 13),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _FloatingCardPreview extends StatelessWidget {
  const _FloatingCardPreview();

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 600;
    final width = mobile ? 155.0 : 188.0;

    return Transform.rotate(
      angle: -.08,
      child: Container(
        width: width,
        height: width * .59,
        padding: EdgeInsets.all(mobile ? 13 : 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF17223F),
              Color(0xFF2F4BFF),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: GabisHeroSection.ink.withValues(alpha: .18),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                GabisLogo(size: 20, isWhite: true),
                Spacer(),
                Icon(Icons.contactless_rounded, color: Colors.white70, size: 19),
              ],
            ),
            const Spacer(),
            Text(
              '••••  4821',
              style: TextStyle(
                color: Colors.white,
                fontSize: mobile ? 10.5 : 12,
                letterSpacing: .7,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'VIRTUAL CARD',
              style: TextStyle(
                color: Colors.white70,
                fontSize: mobile ? 7.5 : 8.5,
                letterSpacing: 1.1,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingSuccessChip extends StatelessWidget {
  const _FloatingSuccessChip();

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.sizeOf(context).width < 600;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: mobile ? 10 : 13,
        vertical: mobile ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: GabisHeroSection.border),
        boxShadow: [
          BoxShadow(
            color: GabisHeroSection.ink.withValues(alpha: .08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFEAFBF2),
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 14,
              color: Color(0xFF079455),
            ),
          ),
          const SizedBox(width: 7),
          Text(
            'Transfer complete',
            style: TextStyle(
              color: GabisHeroSection.ink,
              fontSize: mobile ? 9.5 : 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustStrip extends StatelessWidget {
  const _TrustStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: GabisHeroSection.border),
          bottom: BorderSide(color: GabisHeroSection.border),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: const Wrap(
            alignment: WrapAlignment.spaceEvenly,
            runAlignment: WrapAlignment.center,
            spacing: 24,
            runSpacing: 13,
            children: [
              _TrustItem(
                icon: Icons.language_rounded,
                title: 'Multi-currency',
                caption: 'One account, more reach',
              ),
              _TrustItem(
                icon: Icons.bolt_rounded,
                title: 'Fast transfers',
                caption: 'Built for everyday movement',
              ),
              _TrustItem(
                icon: Icons.credit_card_rounded,
                title: 'Cards that travel',
                caption: 'Pay online and on the go',
              ),
              _TrustItem(
                icon: Icons.shield_outlined,
                title: 'Secure by design',
                caption: 'Protection at every step',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrustItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String caption;

  const _TrustItem({
    required this.icon,
    required this.title,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 230,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: GabisHeroSection.softAccent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: GabisHeroSection.accent),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: GabisHeroSection.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: GabisHeroSection.muted,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
