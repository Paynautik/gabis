import 'package:flutter/material.dart';
import '../../shared/widgets/gabis_phone_frame.dart';
import '../../shared/widgets/nautik_logo.dart';

/// Gabis landing-page hero.
///
/// Inspired by the supplied overseas-transfer reference while keeping the
/// existing Gabis phone frame/mockup and Gabis branding.
class GabisHeroSection extends StatelessWidget {
  final void Function(String label)? onNavTap;

  const GabisHeroSection({super.key, this.onNavTap});

  static const green = Color(0xFF00C16A);
  static const greenDark = Color(0xFF006D44);
  static const lime = Color(0xFFB8F238);
  static const ink = Color(0xFF09251B);
  static const muted = Color(0xFF5F6F68);
  static const border = Color(0xFFE6ECE9);
  static const softGreen = Color(0xFFF0FAF5);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final desktop = width >= 1040;
        final tablet = width >= 720 && !desktop;
        final horizontal = desktop ? 48.0 : (tablet ? 32.0 : 20.0);

        return DecoratedBox(
          decoration: const BoxDecoration(color: Colors.white),
          child: Stack(
            children: [
              const Positioned.fill(child: _BackgroundArt()),
              SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontal),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1320),
                          child: _Navbar(onNavTap: onNavTap),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontal,
                        desktop ? 42 : 28,
                        horizontal,
                        desktop ? 48 : 34,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1320),
                          child: desktop
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      flex: 10,
                                      child: _HeroCopy(onNavTap: onNavTap),
                                    ),
                                    const SizedBox(width: 46),
                                    const Expanded(
                                      flex: 10,
                                      child: _HeroVisual(),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    _HeroCopy(onNavTap: onNavTap),
                                    const SizedBox(height: 44),
                                    const _HeroVisual(),
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
        );
      },
    );
  }
}

class _BackgroundArt extends StatelessWidget {
  const _BackgroundArt();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          right: -170,
          top: 120,
          child: Container(
            width: 620,
            height: 620,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  GabisHeroSection.lime.withValues(alpha: .14),
                  GabisHeroSection.green.withValues(alpha: .035),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: -220,
          bottom: -260,
          child: Container(
            width: 520,
            height: 520,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: GabisHeroSection.green.withValues(alpha: .035),
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

        return Container(
          height: 78,
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .94),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: GabisHeroSection.border),
            boxShadow: [
              BoxShadow(
                color: GabisHeroSection.ink.withValues(alpha: .055),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: GabisLogo(size: 36),
              ),
              if (desktop) ...[
                const SizedBox(width: 32),
                _NavLink(label: 'Features', onTap: onNavTap),
                _NavLink(label: 'How it works', onTap: onNavTap),
                _NavLink(label: 'Security', onTap: onNavTap),
                _NavLink(label: 'Support', onTap: onNavTap),
                _NavLink(label: 'About us', onTap: onNavTap),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  style: TextButton.styleFrom(
                    foregroundColor: GabisHeroSection.ink,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 16,
                    ),
                  ),
                  child: const Text(
                    'Log in',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  style: FilledButton.styleFrom(
                    backgroundColor: GabisHeroSection.greenDark,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 17,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 0,
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
                    backgroundColor: GabisHeroSection.greenDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: const Text('Get Gabis'),
                ),
                const SizedBox(width: 6),
                IconButton(
                  onPressed: () {},
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
    return TextButton(
      onPressed: () => onTap?.call(label),
      style: TextButton.styleFrom(
        foregroundColor: GabisHeroSection.ink,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const _BrandPill(),
            SizedBox(height: desktop ? 25 : 20),
            Text.rich(
              const TextSpan(
                children: [
                  TextSpan(text: 'One app for all\nyour overseas\n'),
                  TextSpan(
                    text: 'transfers',
                    style: TextStyle(color: GabisHeroSection.greenDark),
                  ),
                ],
              ),
              style: TextStyle(
                color: GabisHeroSection.ink,
                fontSize: desktop ? 67 : (mobile ? 45 : 56),
                height: 1.03,
                letterSpacing: desktop ? -3.2 : -2.1,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 24),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 590),
              child: Text(
                'Send money on the go with Gabis. Move money across borders with simple setup, competitive rates, and a smooth experience from start to finish.',
                style: TextStyle(
                  color: GabisHeroSection.muted,
                  fontSize: mobile ? 16.5 : 18,
                  height: 1.55,
                ),
              ),
            ),
            const SizedBox(height: 25),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BenefitRow(text: 'Streamlined digital transfers on the go.'),
                SizedBox(height: 13),
                _BenefitRow(text: 'Check live exchange rates before you send.'),
                SizedBox(height: 13),
                _BenefitRow(text: 'Fast, reliable transfers in just a few taps.'),
              ],
            ),
            const SizedBox(height: 29),
            const Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _StoreButton(
                  icon: Icons.apple_rounded,
                  overline: 'Download on the',
                  title: 'App Store',
                ),
                _StoreButton(
                  icon: Icons.play_arrow_rounded,
                  overline: 'GET IT ON',
                  title: 'Google Play',
                ),
              ],
            ),
            const SizedBox(height: 30),
            const _TrustRow(),
          ],
        ),
      ),
    );
  }
}

class _BrandPill extends StatelessWidget {
  const _BrandPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(9, 7, 14, 7),
      decoration: BoxDecoration(
        color: GabisHeroSection.softGreen,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: const Color(0xFFDCEFE5)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GabisLogo(size: 28),
          SizedBox(width: 9),
          Text(
            'Your money, anywhere',
            style: TextStyle(
              color: GabisHeroSection.greenDark,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final String text;

  const _BenefitRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: GabisHeroSection.lime,
          ),
          child: const Icon(
            Icons.check_rounded,
            color: GabisHeroSection.greenDark,
            size: 17,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(
              color: GabisHeroSection.ink,
              fontSize: 15.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _StoreButton extends StatelessWidget {
  final IconData icon;
  final String overline;
  final String title;

  const _StoreButton({
    required this.icon,
    required this.overline,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(15),
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: GabisHeroSection.greenDark,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: GabisHeroSection.greenDark.withValues(alpha: .12),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: GabisHeroSection.lime, size: 30),
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  overline,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 9.5,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    height: 1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TrustRow extends StatelessWidget {
  const _TrustRow();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 15,
      runSpacing: 10,
      children: [
        SizedBox(
          width: 112,
          height: 36,
          child: Stack(
            children: List.generate(5, (index) {
              const tones = [
                Color(0xFFE7F6ED),
                Color(0xFFD5EEDE),
                Color(0xFFF5E8D7),
                Color(0xFFE0E6FF),
                Color(0xFFF0DED7),
              ];
              return Positioned(
                left: index * 19,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: tones[index],
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    size: 20,
                    color: GabisHeroSection.ink.withValues(alpha: .7),
                  ),
                ),
              );
            }),
          ),
        ),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '★★★★★',
              style: TextStyle(
                color: Color(0xFF8BCC21),
                letterSpacing: 1.5,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 3),
            Text(
              'Built for global money movement',
              style: TextStyle(
                color: GabisHeroSection.muted,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroVisual extends StatelessWidget {
  const _HeroVisual();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final desktop = width >= 1040;
    final mobile = width < 620;
    final height = desktop ? 650.0 : (mobile ? 500.0 : 590.0);

    return SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final phoneWidth = desktop
              ? 315.0
              : (constraints.maxWidth < 390 ? constraints.maxWidth * .70 : 290.0);
          final phoneHeight = phoneWidth * 1.84;

          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Positioned(
                top: desktop ? 46 : 32,
                child: Container(
                  width: desktop ? 540 : 430,
                  height: desktop ? 540 : 430,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        GabisHeroSection.lime.withValues(alpha: .22),
                        GabisHeroSection.green.withValues(alpha: .055),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              const Positioned.fill(child: _FlightPath()),
              if (!mobile) ...[
                Positioned(
                  left: desktop ? 20 : 4,
                  top: desktop ? 120 : 85,
                  child: const _CurrencyCoin(symbol: '€', size: 70),
                ),
                Positioned(
                  left: desktop ? 150 : 110,
                  top: desktop ? 18 : 8,
                  child: const _CurrencyCoin(symbol: r'$', size: 84),
                ),
                Positioned(
                  right: desktop ? 22 : 4,
                  top: desktop ? 58 : 50,
                  child: const _CurrencyCoin(symbol: '£', size: 68),
                ),
                Positioned(
                  right: desktop ? 2 : 4,
                  top: desktop ? 245 : 215,
                  child: const _CurrencyCoin(symbol: '¥', size: 62),
                ),
              ],
              Positioned(
                top: desktop ? 70 : 54,
                left: desktop ? 155 : null,
                child: Transform.rotate(
                  angle: desktop ? .105 : .055,
                  child: _PhoneMockup(width: phoneWidth, height: phoneHeight),
                ),
              ),
              Positioned(
                right: desktop ? 5 : 2,
                bottom: desktop ? 35 : 18,
                child: Transform.rotate(
                  angle: -.10,
                  child: Icon(
                    Icons.send_rounded,
                    size: desktop ? 155 : 105,
                    color: GabisHeroSection.green,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FlightPath extends StatelessWidget {
  const _FlightPath();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _FlightPathPainter());
  }
}

class _FlightPathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = GabisHeroSection.green.withValues(alpha: .28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final path = Path()
      ..moveTo(size.width * .05, size.height * .38)
      ..cubicTo(
        size.width * .16,
        size.height * .20,
        size.width * .70,
        size.height * .17,
        size.width * .92,
        size.height * .31,
      )
      ..cubicTo(
        size.width * .72,
        size.height * .48,
        size.width * .58,
        size.height * .68,
        size.width * .93,
        size.height * .72,
      );

    const dash = 8.0;
    const gap = 8.0;
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(
            distance,
            distance + dash < metric.length ? distance + dash : metric.length,
          ),
          paint,
        );
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CurrencyCoin extends StatelessWidget {
  final String symbol;
  final double size;

  const _CurrencyCoin({required this.symbol, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: GabisHeroSection.lime,
        border: Border.all(
          color: GabisHeroSection.green.withValues(alpha: .55),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: GabisHeroSection.greenDark.withValues(alpha: .12),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        symbol,
        style: TextStyle(
          color: GabisHeroSection.greenDark,
          fontSize: size * .43,
          height: 1,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Reuses the existing GabisPhoneFrame mockup shell.
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
            color: GabisHeroSection.ink.withValues(alpha: .22),
            blurRadius: 52,
            offset: const Offset(0, 26),
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
            17 * scale,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello,',
                          style: TextStyle(
                            color: GabisHeroSection.muted,
                            fontSize: 10 * scale,
                          ),
                        ),
                        SizedBox(height: 2 * scale),
                        Text(
                          'Gabis 👋',
                          style: TextStyle(
                            color: GabisHeroSection.ink,
                            fontSize: 16 * scale,
                            fontWeight: FontWeight.w900,
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
              SizedBox(height: 21 * scale),
              Text(
                'Send money',
                style: TextStyle(
                  color: GabisHeroSection.ink,
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 10 * scale),
              Row(
                children: [
                  Expanded(
                    child: _CurrencyTile(
                      flag: '🇺🇸',
                      code: 'USD',
                      name: 'US Dollar',
                      scale: scale,
                    ),
                  ),
                  SizedBox(width: 8 * scale),
                  Expanded(
                    child: _CurrencyTile(
                      flag: '🇪🇺',
                      code: 'EUR',
                      name: 'Euro',
                      scale: scale,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 17 * scale),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _QuickAction(icon: Icons.account_balance_rounded, label: 'To bank', scale: scale),
                  _QuickAction(icon: Icons.account_balance_wallet_rounded, label: 'Wallet', scale: scale),
                  _QuickAction(icon: Icons.payments_outlined, label: 'Cash', scale: scale),
                  _QuickAction(icon: Icons.phone_android_rounded, label: 'Top up', scale: scale),
                ],
              ),
              SizedBox(height: 22 * scale),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Recent transfers',
                      style: TextStyle(
                        color: GabisHeroSection.ink,
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    'See all',
                    style: TextStyle(
                      color: GabisHeroSection.muted,
                      fontSize: 8.5 * scale,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8 * scale),
              _TransferTile(initials: 'AM', name: 'Amara M.', route: 'USD → NGN', amount: '₦245,000', scale: scale),
              _TransferTile(initials: 'JL', name: 'James L.', route: 'EUR → NGN', amount: '₦156,000', scale: scale),
              _TransferTile(initials: 'MK', name: 'Maya K.', route: 'GBP → NGN', amount: '₦200,000', scale: scale),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(vertical: 8 * scale),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7FAF8),
                  borderRadius: BorderRadius.circular(14 * scale),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _BottomNav(icon: Icons.home_rounded, label: 'Home', active: true, scale: scale),
                    _BottomNav(icon: Icons.people_outline_rounded, label: 'People', scale: scale),
                    _BottomNav(icon: Icons.send_rounded, label: 'Send', scale: scale),
                    _BottomNav(icon: Icons.receipt_long_outlined, label: 'Activity', scale: scale),
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

class _CurrencyTile extends StatelessWidget {
  final String flag;
  final String code;
  final String name;
  final double scale;

  const _CurrencyTile({
    required this.flag,
    required this.code,
    required this.name,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10 * scale),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF9),
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: GabisHeroSection.border),
      ),
      child: Row(
        children: [
          Text(flag, style: TextStyle(fontSize: 18 * scale)),
          SizedBox(width: 7 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  code,
                  style: TextStyle(
                    color: GabisHeroSection.ink,
                    fontSize: 9.5 * scale,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: GabisHeroSection.muted,
                    fontSize: 7.6 * scale,
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

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final double scale;

  const _QuickAction({required this.icon, required this.label, required this.scale});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 58 * scale,
      child: Column(
        children: [
          Container(
            width: 36 * scale,
            height: 36 * scale,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: GabisHeroSection.lime,
            ),
            child: Icon(icon, color: GabisHeroSection.greenDark, size: 18 * scale),
          ),
          SizedBox(height: 5 * scale),
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: GabisHeroSection.ink,
              fontSize: 7.5 * scale,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransferTile extends StatelessWidget {
  final String initials;
  final String name;
  final String route;
  final String amount;
  final double scale;

  const _TransferTile({
    required this.initials,
    required this.name,
    required this.route,
    required this.amount,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 9 * scale),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: GabisHeroSection.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 31 * scale,
            height: 31 * scale,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: GabisHeroSection.lime,
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: TextStyle(
                color: GabisHeroSection.greenDark,
                fontSize: 8.5 * scale,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          SizedBox(width: 8 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: GabisHeroSection.ink,
                    fontSize: 9 * scale,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2 * scale),
                Text(
                  route,
                  style: TextStyle(
                    color: GabisHeroSection.muted,
                    fontSize: 7.3 * scale,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  color: GabisHeroSection.ink,
                  fontSize: 8.5 * scale,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 2 * scale),
              Text(
                'Completed',
                style: TextStyle(
                  color: GabisHeroSection.greenDark,
                  fontSize: 6.8 * scale,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final double scale;

  const _BottomNav({
    required this.icon,
    required this.label,
    this.active = false,
    required this.scale,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 16 * scale,
          color: active ? GabisHeroSection.greenDark : GabisHeroSection.muted,
        ),
        SizedBox(height: 3 * scale),
        Text(
          label,
          style: TextStyle(
            fontSize: 6.5 * scale,
            color: active ? GabisHeroSection.greenDark : GabisHeroSection.muted,
            fontWeight: active ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
