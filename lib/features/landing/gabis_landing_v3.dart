import 'dart:math' as math;
import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../shared/widgets/nautik_logo.dart';
import '../business/business_persistence_stub.dart'
    if (dart.library.js_interop) '../business/business_persistence_web.dart';
import 'web_video_panel.dart';

/// Gabis Landing V3
///
/// A deliberately non-template landing page:
/// - oversized editorial typography
/// - kinetic hero canvas
/// - product UI as the visual centerpiece
/// - bold section transitions instead of repeated card grids
/// - responsive down to mobile
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion;
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _motion.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GabisV3.cream,
      body: SelectionArea(
        child: SingleChildScrollView(
          controller: _controller,
          child: Column(
            children: [
              _Hero(motion: _motion),
              const _WordRail(),
              const _CollectionsSection(),
              const _MoneyMovesSection(),
              const _IntelligenceSection(),
              const _InnovationsSection(),
              const _CurrencyStage(),
              const _CardMoment(),
              const _FinalCta(),
              const _ProofSection(),
              const _DownloadSection(),
              const _Footer(),
            ],
          ),
        ),
      ),
    );
  }
}

abstract final class GabisV3 {
  static const ink = Color(0xFF101010);
  static const cream = Color(0xFFF4F0E8);
  static const electric = Color(0xFF4C45FF);
  static const lime = Color(0xFFD9FF43);
  static const sky = Color(0xFFBFE8FF);
  static const coral = Color(0xFFFF7657);
  static const lilac = Color(0xFFD9D0FF);
  static const white = Color(0xFFFFFFFF);
  static const line = Color(0x26101010);

  static double side(double width) {
    if (width >= 1280) return 56;
    if (width >= 800) return 34;
    return 20;
  }
}

class _Hero extends StatelessWidget {
  final Animation<double> motion;

  const _Hero({required this.motion});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final width = c.maxWidth;
        final desktop = width >= 980;
        final side = GabisV3.side(width);

        return Container(
          color: GabisV3.cream,
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(side, 18, side, 0),
                    child: const _Nav(),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      side,
                      desktop ? 52 : 40,
                      side,
                      desktop ? 70 : 48,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1440),
                      child: desktop
                          ? SizedBox(
                              height: 680,
                              child: Row(
                                children: [
                                  const Expanded(
                                    flex: 11,
                                    child: _HeroCopy(),
                                  ),
                                  const SizedBox(width: 20),
                                  Expanded(
                                    flex: 10,
                                    child: _HeroProduct(motion: motion),
                                  ),
                                ],
                              ),
                            )
                          : Column(
                              children: [
                                const _HeroCopy(),
                                const SizedBox(height: 48),
                                SizedBox(
                                  height: width < 600 ? 520 : 600,
                                  child: _HeroProduct(motion: motion),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Public wrappers so the marketing pages share the landing chrome rather
/// than growing a second, drifting copy of it.
class GabisNav extends StatelessWidget {
  const GabisNav({super.key});

  @override
  Widget build(BuildContext context) => const _Nav();
}

class GabisFooter extends StatelessWidget {
  const GabisFooter({super.key});

  @override
  Widget build(BuildContext context) => const _Footer();
}

class _Nav extends StatelessWidget {
  const _Nav();

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 820;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1440),
      child: Container(
        height: 72,
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: GabisV3.line),
          ),
        ),
        child: Row(
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  // From a marketing page this pops back; on home it is a no-op.
                  if (Navigator.canPop(context)) {
                    Navigator.popUntil(context, (r) => r.isFirst);
                  } else {
                    Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
                  }
                },
                child: const GabisLogo(size: 36),
              ),
            ),
            if (desktop) ...[
              const SizedBox(width: 42),
              const _NavText('Money'),
              const _NavText('Cards'),
              const _NavText('Business'),
              const _NavText('Company'),
            ],
            const Spacer(),
            if (desktop)
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                style: TextButton.styleFrom(
                  foregroundColor: GabisV3.ink,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                child: const Text('Sign in'),
              ),
            const SizedBox(width: 8),
            _MagneticButton(
              label: desktop ? 'Get Gabis' : 'Get app',
              onTap: () => Navigator.pushNamed(context, '/login'),
            ),
            if (!desktop) ...[
              const SizedBox(width: 6),
              IconButton(
                onPressed: () => _showMobileMenu(context),
                icon: const Icon(Icons.menu_rounded),
                color: GabisV3.ink,
                tooltip: 'Menu',
              ),
            ],
          ],
        ),
      ),
    );
  }
}


/// The phone nav had nowhere to go — the hamburger jumped straight to login.
/// This is the same set of destinations the desktop footer offers.
void _showMobileMenu(BuildContext context) {
  const groups = <String, List<(String, String)>>{
    'MONEY': [
      ('Multi-currency wallet', '/wallet'),
      ('Global USD account', '/usd-account'),
      ('Virtual cards', '/virtual-cards'),
      ('Instant FX swaps', '/fx'),
      ('Bills & airtime', '/bills'),
    ],
    'BUSINESS': [
      ('gabis Business', '/business'),
      ('Smart invoicing', '/invoicing'),
      ('AI debt recovery', '/debt-recovery'),
      ('Connected payments', '/connected-payments'),
    ],
    'COMPANY': [
      ('About gabis', '/about'),
      ('Help centre', '/help'),
      ('Contact support', '/contact'),
    ],
  };

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: GabisV3.cream,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (sheetContext) => SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * .82,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: GabisV3.ink.withValues(alpha: .18),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              for (final group in groups.entries) ...[
                Text(group.key,
                    style: TextStyle(
                      fontSize: 10.5,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w900,
                      color: GabisV3.ink.withValues(alpha: .42),
                    )),
                const SizedBox(height: 8),
                for (final item in group.value)
                  InkWell(
                    onTap: () {
                      Navigator.pop(sheetContext);
                      Navigator.pushNamed(context, item.$2);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(item.$1,
                                style: const TextStyle(
                                    fontSize: 16.5, fontWeight: FontWeight.w700)),
                          ),
                          Icon(Icons.arrow_forward_rounded,
                              size: 16, color: GabisV3.ink.withValues(alpha: .4)),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 18),
              ],
              const Divider(color: GabisV3.line),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        Navigator.pushNamed(context, '/login');
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: GabisV3.ink,
                        side: const BorderSide(color: GabisV3.ink),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100)),
                      ),
                      child: const Text('Sign in',
                          style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        Navigator.pushNamed(context, '/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GabisV3.ink,
                        foregroundColor: GabisV3.cream,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100)),
                      ),
                      child: const Text('Get gabis',
                          style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _NavText extends StatelessWidget {
  final String text;
  const _NavText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Text(
        text,
        style: const TextStyle(
          color: GabisV3.ink,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  const _HeroCopy();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final desktop = width >= 980;
    final fontSize = desktop ? 92.0 : (width >= 600 ? 70.0 : 54.0);

    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
            decoration: BoxDecoration(
              color: GabisV3.lime,
              border: Border.all(color: GabisV3.ink, width: 1.2),
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Text(
              'AI THAT COLLECTS WHAT YOU ARE OWED',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.4,
              ),
            ),
          ),
          SizedBox(height: desktop ? 22 : 16),
          Text(
            'THE AGENT THAT\nGETS YOU PAID.',
            style: TextStyle(
              fontSize: fontSize * .82,
              height: .9,
              letterSpacing: -4,
              fontWeight: FontWeight.w900,
              color: GabisV3.ink,
            ),
          ),
          SizedBox(height: desktop ? 26 : 18),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Text(
              // Seven lines of copy is a wall on a phone; say it in two.
              desktop
                  ? 'Gabis turns African financial activity into action. It understands your money, speaks to the people who owe you in their own language, and moves you toward the next decision — while every calculation stays deterministic and every movement of money stays under your control.'
                  : 'Gabis speaks to the people who owe you in their own language, understands your money, and keeps every calculation deterministic and every payment under your control.',
              style: TextStyle(
                fontSize: desktop ? 18 : 16.5,
                height: 1.5,
                color: const Color(0xCC101010),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: desktop ? 34 : 24),
          Wrap(
            spacing: 16,
            runSpacing: 14,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _MagneticButton(label: 'Open your account', onTap: () => Navigator.pushNamed(context, '/login')),
              TextButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                iconAlignment: IconAlignment.end,
                icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                style: TextButton.styleFrom(
                  foregroundColor: GabisV3.ink,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                label: const Text('See it in action'),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const _PointsChip(hint: true),
          const SizedBox(height: 20),
          const _MicroProof(),
        ],
      ),
    );
  }
}

class _MicroProof extends StatelessWidget {
  const _MicroProof();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.lock_outline_rounded, size: 19),
        const SizedBox(width: 9),
        Flexible(
          child: Text(
            'Your money. Your controls. Built with security at the core.',
            style: TextStyle(
              fontSize: 13.5,
              height: 1.3,
              color: GabisV3.ink.withValues(alpha: .72),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _MagneticButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _MagneticButton({required this.label, required this.onTap});

  @override
  State<_MagneticButton> createState() => _MagneticButtonState();
}

class _MagneticButtonState extends State<_MagneticButton> {
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
          duration: const Duration(milliseconds: 180),
          transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
          padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 17),
          decoration: BoxDecoration(
            color: GabisV3.ink,
            borderRadius: BorderRadius.circular(8),
            boxShadow: _hovered
                ? const [
                    BoxShadow(
                      color: GabisV3.electric,
                      offset: Offset(5, 5),
                    ),
                  ]
                : const [],
          ),
          child: Text(
            widget.label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroProduct extends StatelessWidget {
  final Animation<double> motion;
  const _HeroProduct({required this.motion});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final center = Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);

        return AnimatedBuilder(
          animation: motion,
          builder: (context, _) {
            final t = motion.value * math.pi * 2;
            return Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Concentric circles & orbiting game perfectly centered on the phone
                Positioned.fill(
                  child: _OrbitGame(motion: motion, center: center),
                ),
                // Rotated lime backing card
                Transform.rotate(
                  angle: -.08,
                  child: Container(
                    width: 360,
                    height: 500,
                    decoration: BoxDecoration(
                      color: GabisV3.lime,
                      borderRadius: BorderRadius.circular(44),
                    ),
                  ),
                ),
                // Phone mockup
                Transform.translate(
                  offset: Offset(0, math.sin(t) * 7),
                  child: const _Phone(),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _Phone extends StatelessWidget {
  const _Phone();

  Widget _phoneBtn(double h, {double w = 2.5}) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: GabisV3.ink.withValues(alpha: .7),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 310,
      height: 660,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // iPhone 17 hardware buttons
          Positioned(left: -2.5, top: 110, child: _phoneBtn(22)), // Action Button
          Positioned(left: -2.5, top: 150, child: _phoneBtn(44)), // Vol+
          Positioned(left: -2.5, top: 200, child: _phoneBtn(44)), // Vol-
          Positioned(right: -2.5, top: 160, child: _phoneBtn(54)), // Power Button
          Positioned(right: -1.5, top: 290, child: _phoneBtn(28, w: 1.5)), // Camera Control
          
          Positioned.fill(
            child: Container(
              padding: const EdgeInsets.all(5), // Thinner bezels for 17
              decoration: BoxDecoration(
                color: GabisV3.ink,
                borderRadius: BorderRadius.circular(44),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33101010),
                    blurRadius: 50,
                    offset: Offset(0, 28),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(39),
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      // Smaller Dynamic Island for iPhone 17
                      Container(
                        width: 66,
                        height: 20,
                        decoration: BoxDecoration(
                          color: GabisV3.ink,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        child: Row(
                          children: [
                            Image.asset('assets/gabis_logo.png', height: 24, fit: BoxFit.contain),
                            const Spacer(),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Welcome back',
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    color: Color(0xFF888888),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Deji Adewusi',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color: GabisV3.ink,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -.2,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 28,
                              height: 28,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: NetworkImage('https://i.pravatar.cc/100?img=33'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 38),
                      const Text(
                        'Total balance',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF888888),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        '₦ 860,000',
                        style: TextStyle(
                          fontSize: 32,
                          color: GabisV3.ink,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18),
                        child: Row(
                          children: [
                            Expanded(
                              child: _PhoneAction(
                                icon: Icons.north_east_rounded,
                                label: 'Send',
                                color: GabisV3.electric,
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: _PhoneAction(
                                icon: Icons.south_west_rounded,
                                label: 'Receive',
                                color: GabisV3.ink,
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: _PhoneAction(
                                icon: Icons.swap_horiz_rounded,
                                label: 'Swap',
                                color: GabisV3.coral,
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: _PhoneAction(
                                icon: Icons.add_rounded,
                                label: 'Deposit',
                                color: GabisV3.lilac,
                                iconColor: GabisV3.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF7F7F7),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(28),
                              topRight: Radius.circular(28),
                            ),
                          ),
                          padding: const EdgeInsets.fromLTRB(22, 28, 22, 0),
                          child: const SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                              Text(
                                'Your currencies',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              SizedBox(height: 18),
                              _WalletRow(symbol: '₦', code: 'NGN', amount: '120,000'),
                              SizedBox(height: 15),
                              _WalletRow(symbol: r'$', code: 'USD', amount: '200.00'),
                              SizedBox(height: 15),
                              _WalletRow(symbol: '£', code: 'GBP', amount: '100.00'),
                              SizedBox(height: 15),
                              _WalletRow(symbol: r'C$', code: 'CAD', amount: '100.00'),
                              SizedBox(height: 15),
                              _WalletRow(symbol: '¥', code: 'JPY', amount: '10,000'),
                              SizedBox(height: 8),
                            ],
                          ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhoneAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  final Color iconColor;

  const _PhoneAction({
    required this.icon,
    required this.label,
    required this.color,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 38,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Center(child: Icon(icon, color: iconColor, size: 16)),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class _WalletRow extends StatelessWidget {
  final String symbol;
  final String code;
  final String amount;

  const _WalletRow({
    required this.symbol,
    required this.code,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(symbol, style: const TextStyle(fontWeight: FontWeight.w900)),
          ),
        ),
        const SizedBox(width: 11),
        Text(code, style: const TextStyle(fontWeight: FontWeight.w800)),
        const Spacer(),
        Text(amount, style: const TextStyle(fontWeight: FontWeight.w900)),
      ],
    );
  }
}

class _BalanceBubble extends StatelessWidget {
  const _BalanceBubble();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 116,
      height: 116,
      decoration: const BoxDecoration(
        color: GabisV3.coral,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text(
          '5\nWALLETS',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 17,
            height: .95,
            fontWeight: FontWeight.w900,
            color: GabisV3.ink,
          ),
        ),
      ),
    );
  }
}

/// Points earned by catching the orbiting balls in the hero.
///
/// These are banked, not decorative: they are written to local storage under a
/// pending key, and the Points wallet claims them the first time the user
/// opens the app. Earning something and then watching it evaporate on sign-in
/// is worse than never offering it.
final gabisPoints = ValueNotifier<int>(_readPendingPoints());

const kPendingPointsKey = 'gabis.points.pending';

int _readPendingPoints() {
  final raw = readRaw(kPendingPointsKey);
  return raw == null ? 0 : (int.tryParse(raw) ?? 0);
}

void _bankPendingPoints(int value) => writeRaw(kPendingPointsKey, '$value');

/// The hero decoration doubles as a small game: catch an orb, earn points.
class _OrbitGame extends StatefulWidget {
  final Animation<double> motion;
  final Offset center;
  const _OrbitGame({required this.motion, required this.center});

  @override
  State<_OrbitGame> createState() => _OrbitGameState();
}

class _OrbitGameState extends State<_OrbitGame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin;
  final _pops = <_Pop>[];
  double _speed = 1;
  bool _played = false;

  DateTime? _outerCaughtAt;
  DateTime? _innerCaughtAt;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  void _catch(Offset at, int worth, bool isOuter) {
    if (isOuter) {
      if (_outerCaughtAt != null && DateTime.now().difference(_outerCaughtAt!).inSeconds < 3) return;
      _outerCaughtAt = DateTime.now();
    } else {
      if (_innerCaughtAt != null && DateTime.now().difference(_innerCaughtAt!).inSeconds < 3) return;
      _innerCaughtAt = DateTime.now();
    }

    gabisPoints.value += worth;
    _bankPendingPoints(gabisPoints.value);
    setState(() {
      _played = true;
      _speed = (_speed + .12).clamp(1.0, 2.4);
      _pops.add(_Pop(at, worth, DateTime.now()));
      _pops.removeWhere(
          (p) => DateTime.now().difference(p.at).inMilliseconds > 900);
    });
  }

  @override
  Widget build(BuildContext context) {
    const rOuter = 390.0;
    const rMiddle = 310.0;
    const rInner = 235.0;
    final center = widget.center;

    // Static 5 Wallets bubble on middle circle
    const bubbleAngle = -math.pi / 4.4;
    final bubbleOffset = Offset(
      center.dx + math.cos(bubbleAngle) * rMiddle - 58,
      center.dy + math.sin(bubbleAngle) * rMiddle - 58,
    );

    return AnimatedBuilder(
      animation: Listenable.merge([widget.motion, _spin]),
      builder: (context, _) {
        final theta = _spin.value * math.pi * 2 * _speed;
        final outerAt = Offset(center.dx + math.cos(theta) * rOuter,
            center.dy + math.sin(theta) * rOuter);
        final innerAt = Offset(
            center.dx + math.cos(-theta + math.pi) * rInner,
            center.dy + math.sin(-theta + math.pi) * rInner);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _OrbitRingsPainter(center: center),
                ),
              ),
            ),
            // Static 5 Wallets card locked onto middle ring
            Positioned(
              left: bubbleOffset.dx,
              top: bubbleOffset.dy,
              child: const _BalanceBubble(),
            ),
            _orb(outerAt, 13, GabisV3.electric, 5, true),
            _orb(innerAt, 10, GabisV3.coral, 10, false),
            for (final pop in _pops) _popLabel(pop),
          ],
        );
      },
    );
  }

  Widget _orb(Offset at, double r, Color color, int worth, bool isOuter) {
    final caughtAt = isOuter ? _outerCaughtAt : _innerCaughtAt;
    final isCaught = caughtAt != null && DateTime.now().difference(caughtAt).inSeconds < 3;

    return Positioned(
      left: at.dx - r * 2.4,
      top: at.dy - r * 2.4,
      width: r * 4.8,
      height: r * 4.8,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => _catch(at, worth, isOuter),
          child: Center(
            child: AnimatedScale(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              scale: isCaught ? 0.0 : 1.0,
              child: Container(
                width: r * 2,
                height: r * 2,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: color.withValues(alpha: .38),
                        blurRadius: 12,
                        spreadRadius: 4),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _popLabel(_Pop pop) {
    final age = DateTime.now().difference(pop.at).inMilliseconds / 900;
    if (age >= 1) return const SizedBox.shrink();
    return Positioned(
      left: pop.where.dx - 24,
      top: pop.where.dy - 26 - age * 30,
      child: IgnorePointer(
        child: Opacity(
          opacity: (1 - age).clamp(0, 1),
          child: Text(
            '+${pop.worth}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: GabisV3.ink,
            ),
          ),
        ),
      ),
    );
  }
}

class _Pop {
  final Offset where;
  final int worth;
  final DateTime at;
  const _Pop(this.where, this.worth, this.at);
}

class _PointsChip extends StatelessWidget {
  final bool hint;
  const _PointsChip({required this.hint});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: gabisPoints,
      builder: (context, points, _) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: GabisV3.ink,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                  color: GabisV3.lime, shape: BoxShape.circle),
            ),
            const SizedBox(width: 9),
            Text(
              hint
                  ? 'Catch the orbs — earn gabis points'
                  : 'gabis points  $points  ·  saved to your wallet',
              style: const TextStyle(
                color: GabisV3.cream,
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                letterSpacing: .2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rings only — the balls are widgets now, so they can be caught.
class _OrbitRingsPainter extends CustomPainter {
  final Offset center;
  const _OrbitRingsPainter({required this.center});

  @override
  void paint(Canvas canvas, Size size) {
    // 3 Concentric Circles: Outer (390), Middle (310), Inner (235)
    const rings = [
      (390.0, 0.16),
      (310.0, 0.12),
      (235.0, 0.14),
    ];

    for (final (r, alpha) in rings) {
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..color = GabisV3.ink.withValues(alpha: alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _OrbitPainter extends CustomPainter {
  final double progress;
  const _OrbitPainter(this.progress);

  void _system(
    Canvas canvas,
    Offset center,
    double radius,
    double phase,
    Color outerColor,
    Color innerColor,
  ) {
    final inner = radius * .68;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = GabisV3.ink.withValues(alpha: .16)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    canvas.drawCircle(
      center,
      inner,
      Paint()
        ..color = GabisV3.ink.withValues(alpha: .10)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );

    final theta = progress * math.pi * 2 + phase;

    final outer = Offset(
      center.dx + math.cos(theta) * radius,
      center.dy + math.sin(theta) * radius,
    );
    final innerDot = Offset(
      center.dx + math.cos(-theta + math.pi) * inner,
      center.dy + math.sin(-theta + math.pi) * inner,
    );

    void ball(Offset at, Color color, double r) {
      canvas.drawCircle(at, r * 2.6, Paint()..color = color.withValues(alpha: .16));
      canvas.drawCircle(at, r, Paint()..color = color);
      canvas.drawCircle(
        at.translate(-r * .3, -r * .3),
        r * .34,
        Paint()..color = Colors.white.withValues(alpha: .55),
      );
    }

    ball(outer, outerColor, 11);
    ball(innerDot, innerColor, 8);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.min(size.width, size.height) * .40;

    // Single orbit system on the right.
    _system(canvas, Offset(size.width * .72, size.height * .5), r, 0,
        GabisV3.electric, GabisV3.coral);
  }

  @override
  bool shouldRepaint(_OrbitPainter oldDelegate) => oldDelegate.progress != progress;
}

class _WordRail extends StatelessWidget {
  const _WordRail();

  /// Each word goes somewhere, which is the whole change.
  ///
  /// The rail used to be eight words and a repeat, scaled to fit and clickable
  /// nowhere — decoration that named the six things this product does and then
  /// asked the reader to go and find them. Every one of them has a page, so
  /// every one of them is now a way in. SAVE and GROW are gone because nothing
  /// is behind them yet, and a word that leads nowhere is worse on a landing
  /// page than one that was never there.
  static const _stops = <(String, IconData, String)>[
    ('SEND', Icons.north_east_rounded, '/wallet'),
    ('SPEND', Icons.credit_card_rounded, '/virtual-cards'),
    ('RECEIVE', Icons.download_rounded, '/usd-account'),
    ('SWAP', Icons.swap_horiz_rounded, '/fx'),
    ('INVOICE', Icons.receipt_long_rounded, '/invoicing'),
    ('COLLECT', Icons.campaign_rounded, '/debt-recovery'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: GabisV3.ink,
      padding: const EdgeInsets.symmetric(vertical: 14),
      // Ink needs a Material above it or a tap lands with no ripple, which on
      // a dark strip reads as a dead word.
      child: Material(
        type: MaterialType.transparency,
        // Centred when the six fit, scrolling from the left when they do not.
        // A horizontal scroller lays its child out at the start whatever the
        // width, which on a desktop leaves the rail hard against the left edge
        // of a very wide band; giving the row the viewport as a minimum width
        // lets it centre itself, and it still overflows into a scroll on a
        // phone.
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: (constraints.maxWidth - 32).clamp(0.0, double.infinity),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              for (var i = 0; i < _stops.length; i++) ...[
                if (i > 0)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text('✦',
                        style: TextStyle(
                          color: GabisV3.lime,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        )),
                  ),
                  _RailStop(
                    label: _stops[i].$1,
                    icon: _stops[i].$2,
                    route: _stops[i].$3,
                  ),
                ],
              ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RailStop extends StatefulWidget {
  const _RailStop({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;

  @override
  State<_RailStop> createState() => _RailStopState();
}

class _RailStopState extends State<_RailStop> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final lit = _hovered;

    return Semantics(
      button: true,
      label: '${widget.label} — read more',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: InkWell(
          borderRadius: BorderRadius.circular(100),
          onTap: () => Navigator.pushNamed(context, widget.route),
          child: ConstrainedBox(
            // What a thumb can actually hit, one-handed, on a phone.
            constraints: const BoxConstraints(minHeight: 48),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: lit ? GabisV3.lime.withValues(alpha: .12) : null,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.icon,
                    size: 17,
                    color: lit ? GabisV3.lime : GabisV3.cream,
                  ),
                  const SizedBox(width: 9),
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.4,
                      height: 1.1,
                      color: lit ? GabisV3.lime : GabisV3.cream,
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

class _MoneyMovesSection extends StatelessWidget {
  const _MoneyMovesSection();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final width = c.maxWidth;
        final desktop = width >= 900;
        final side = GabisV3.side(width);

        return Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(side, 110, side, 120),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1320),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ONE ACCOUNT.\nEVERY MOVE.',
                  style: TextStyle(
                    color: GabisV3.ink,
                    fontSize: desktop ? 72 : 48,
                    height: .94,
                    letterSpacing: -3.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 22),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Text(
                    'The wallet is the infrastructure underneath the agent. Hold, send, '
                    'spend and settle across five currencies — so when the money is '
                    'collected, it has somewhere to land.',
                    style: TextStyle(
                      color: GabisV3.ink.withValues(alpha: .62),
                      fontSize: desktop ? 18 : 16,
                      height: 1.55,
                    ),
                  ),
                ),
                const SizedBox(height: 46),
                const _MoveMarquee(),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// One capability, told in a line.
class _Move {
  final String index;
  final String title;
  final String body;
  final Color color;
  final IconData icon;

  /// What opens when the card is tapped: the longer story and the concrete
  /// things the feature actually does.
  final String detail;
  final List<String> points;

  const _Move(
    this.index,
    this.title,
    this.body,
    this.color,
    this.icon, {
    required this.detail,
    required this.points,
  });
}

const _moves = <_Move>[
  _Move('01', 'SEND', 'Across borders, without turning it into a project.', GabisV3.sky, Icons.north_east_rounded,
      detail:
          'Send to a bank account, a phone number or a gabis tag. You see the rate and the fee before you confirm, and the recipient sees the money land — not a pending status that means nothing.',
      points: [
        'Bank, mobile money or @gabis tag',
        'Rate and fee shown before you confirm',
        'Most transfers settle in under 60 seconds',
        'Every transfer has a receipt you can share',
      ]),
  _Move('02', 'HOLD', 'NGN, USD, GBP, CAD and JPY in one place.', GabisV3.lilac, Icons.account_balance_wallet_outlined,
      detail:
          'Five balances under one login. Money stays in the currency you were paid in until you decide otherwise, so you are never forced to convert at somebody else\u2019s timing.',
      points: [
        'NGN, USD, GBP, CAD and JPY',
        'No forced conversion on receipt',
        'Per-currency statements you can export',
        'Total value in your home currency at a glance',
      ]),
  _Move('03', 'SPEND', 'A card that feels native to your life.', GabisV3.coral, Icons.credit_card_rounded,
      detail:
          'Virtual instantly, physical when you want it. Spend from whichever balance makes sense, freeze it the moment your bag goes missing and unfreeze it when it turns up.',
      points: [
        'Virtual card in seconds, physical on request',
        'Choose which balance a card spends from',
        'Freeze and unfreeze from the app',
        'Rotate the card details without a new card',
      ]),
  _Move('04', 'COLLECT', 'An AI caller chases overdue customers in their language.', GabisV3.lime, Icons.record_voice_over_rounded,
      detail:
          'Chasing debts is the work nobody wants. The AI caller rings your overdue customers in English, Pidgin, Yoruba, Hausa or Igbo, keeps the tone polite and hands you a transcript plus a promise-to-pay date.',
      points: [
        'Calls in English, Pidgin, Yoruba, Hausa and Igbo',
        'Transcript and outcome for every call',
        'Captures a promise-to-pay date',
        'Stops the moment the invoice is paid',
      ]),
  _Move('05', 'INVOICE', 'Sent, overdue, paid — reflected in your totals at once.', GabisV3.sky, Icons.receipt_long_rounded,
      detail:
          'Raise an invoice, send it, and watch the status change on its own when the money arrives. Your outstanding figure is always the real one, not a spreadsheet you meant to update.',
      points: [
        'Send by WhatsApp, email or link',
        'Payment marks the invoice paid automatically',
        'Outstanding and collection rate always live',
        'Reminders before and after the due date',
      ]),
  _Move('06', 'PLAN', 'Instalments with reminders ten days before they are due.', GabisV3.lilac, Icons.event_repeat_rounded,
      detail:
          'Split a bill into instalments a customer can actually meet. Everyone sees the same schedule, and the reminder lands ten days out — early enough to do something about it.',
      points: [
        'Custom instalment schedules',
        'Reminders ten days ahead of each date',
        'Part payments tracked against the plan',
        'Schedule visible to both sides',
      ]),
  _Move('07', 'FILE', 'Tax from revenue you actually collected.', GabisV3.coral, Icons.account_balance_rounded,
      detail:
          'Filings built from money that actually cleared, not from invoices you hoped would. Figures come straight off your ledger, so filing stops being a week of reconstruction.',
      points: [
        'VAT and income summaries from cleared payments',
        'Period-by-period breakdowns',
        'Export for your accountant',
        'Nothing counted twice',
      ]),
  _Move('08', 'RECEIVE', 'US routing details, so ACH and wires land directly.', GabisV3.lime, Icons.south_west_rounded,
      detail:
          'Your own US account and routing number, plus GBP details. Clients pay you the way they pay anyone local, and it arrives in your balance without a middleman taking a cut on the way.',
      points: [
        'US account and routing number',
        'GBP account details',
        'ACH, wire and local transfers',
        'Funds land in the currency they were sent in',
      ]),
  _Move('09', 'SWAP', 'Mid-market rates, settled against your balance.', GabisV3.sky, Icons.swap_horiz_rounded,
      detail:
          'Convert between your balances at a rate you can check against the market, with the fee stated up front. No hidden spread buried in a rounded number.',
      points: [
        'Mid-market rate with the fee shown',
        'Any of your five balances, either direction',
        'Settles instantly against your balance',
        'Rate locked while you confirm',
      ]),
  _Move('10', 'SETTLE', 'Nigeria, Kenya and Ghana, with webhooks for your ledger.', GabisV3.lilac, Icons.public_rounded,
      detail:
          'Collect from customers across three markets and settle into one account. Webhooks push every event to your own systems, so your ledger does not depend on somebody remembering to reconcile.',
      points: [
        'Nigeria, Kenya and Ghana collections',
        'Single settlement account',
        'Webhooks on every payment event',
        'Retries and a full event log',
      ]),
  _Move('11', 'PAY BILLS', 'Airtime, tokens and subscriptions, receipts on clearing.', GabisV3.coral, Icons.bolt_rounded,
      detail:
          'Airtime, data, electricity tokens and subscriptions from the same balance. The receipt arrives when the payment clears — not when it was submitted.',
      points: [
        'Airtime, data and electricity tokens',
        'Recurring subscriptions on a schedule',
        'Receipt issued on clearing',
        'Saved billers for the ones you repeat',
      ]),
  _Move('12', 'ASK', 'A copilot that reads your own transactions.', GabisV3.lime, Icons.auto_awesome_rounded,
      detail:
          'Ask a plain question about your own money and get an answer built from your transactions, with the figures it used shown. It explains; it never moves money on its own.',
      points: [
        'Answers grounded in your transactions',
        'Shows the numbers behind each answer',
        'Spots subscriptions and duplicate charges',
        'Suggests, never acts without approval',
      ]),
  _Move('13', 'SWEEP', 'Moves what is genuinely spare into savings.', GabisV3.sky, Icons.savings_rounded,
      detail:
          'On payday the copilot works out what is genuinely spare after your reserve, and offers to move it to savings. You set the cap, you approve each sweep, and you can undo the last one.',
      points: [
        'Holds back a reserve you choose',
        'Cap per sweep, so nothing alarming moves',
        'Every sweep approved by you',
        'Undo the last sweep at any time',
      ]),
];

/// One row drifting past, looping seamlessly.
///
/// Thirteen capabilities as a static grid is a wall the eye has to work
/// through. Drifting past in a single line, it reads as one list rather than
/// two competing ones, and takes half the height again. Motion pauses on
/// hover so anything can actually be read.
class _MoveMarquee extends StatefulWidget {
  const _MoveMarquee();

  @override
  State<_MoveMarquee> createState() => _MoveMarqueeState();
}

class _MoveMarqueeState extends State<_MoveMarquee>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  bool _paused = false;

  @override
  void initState() {
    super.initState();
    // One row carries every card, so the loop is nearly twice as long as the
    // old two-row split — the duration follows, keeping the drift speed the
    // same rather than doubling it.
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 86))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _paused = true),
      onExit: (_) => setState(() => _paused = false),
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => _MarqueeRow(
          items: _moves,
          progress: _c.value,
          reverse: false,
          paused: _paused,
        ),
      ),
    );
  }
}

class _MarqueeRow extends StatelessWidget {
  final List<_Move> items;
  final double progress;
  final bool reverse;
  final bool paused;

  const _MarqueeRow({
    required this.items,
    required this.progress,
    required this.reverse,
    required this.paused,
  });

  static const _cardWidth = 268.0;
  static const _gap = 16.0;

  @override
  Widget build(BuildContext context) {
    final span = items.length * (_cardWidth + _gap);
    // Duplicated once so the tail meets the head with no visible seam.
    final shift = (paused ? 0.0 : progress) * span;
    final dx = reverse ? -span + shift : -shift;

    return SizedBox(
      height: 178,
      child: ClipRect(
        child: OverflowBox(
          maxWidth: double.infinity,
          alignment: Alignment.centerLeft,
          child: Transform.translate(
            offset: Offset(dx, 0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var pass = 0; pass < 2; pass++)
                  for (final m in items)
                    Padding(
                      padding: const EdgeInsets.only(right: _gap),
                      child: _MoveCard(
                        move: m,
                        width: _cardWidth,
                        onTap: () => showMoveDetail(context, m),
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

class _MoveCard extends StatefulWidget {
  final _Move move;
  final double width;
  final VoidCallback onTap;

  const _MoveCard({
    required this.move,
    required this.width,
    required this.onTap,
  });

  @override
  State<_MoveCard> createState() => _MoveCardState();
}

class _MoveCardState extends State<_MoveCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final move = widget.move;
    final width = widget.width;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          transform: Matrix4.translationValues(0, _hover ? -4 : 0, 0),
          child: _cardBody(move, width),
        ),
      ),
    );
  }

  Widget _cardBody(_Move move, double width) {
    // Thirteen saturated fills drifting past reads as a quilt: the colour
    // competes with itself and none of it means anything. One white surface,
    // with colour carrying the icon and the rule, keeps the palette and lets
    // the words do the work.
    return Container(
      width: width,
      height: 172,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: GabisV3.ink, width: 1.3),
        borderRadius: BorderRadius.circular(10),
        boxShadow: _hover
            ? [
                BoxShadow(
                  color: GabisV3.ink.withValues(alpha: .10),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(move.index,
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      color: GabisV3.ink.withValues(alpha: .45))),
              const Spacer(),
              // The card's colour, concentrated into one mark.
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: move.color,
                  border: Border.all(color: GabisV3.ink, width: 1.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(move.icon, size: 16),
              ),
            ],
          ),
          const Spacer(),
          Text(
            move.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
              height: 1,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            move.body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.35,
              color: GabisV3.ink.withValues(alpha: .74),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('See how it works',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .2,
                    color: GabisV3.ink.withValues(alpha: _hover ? .95 : .6),
                  )),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward_rounded,
                  size: 12,
                  color: GabisV3.ink.withValues(alpha: _hover ? .95 : .6)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Bitso-style detail panel: the card opens into the same colour, with the
/// longer story and the concrete things the feature does.
void showMoveDetail(BuildContext context, _Move move) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: move.title,
    barrierColor: GabisV3.ink.withValues(alpha: .55),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (context, a1, a2) => const SizedBox.shrink(),
    transitionBuilder: (context, anim, _, __) {
      final curved = Curves.easeOutCubic.transform(anim.value);
      return Opacity(
        opacity: anim.value,
        child: Transform.translate(
          offset: Offset(0, (1 - curved) * 26),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: _MoveDetailPanel(move: move),
            ),
          ),
        ),
      );
    },
  );
}

class _MoveDetailPanel extends StatelessWidget {
  final _Move move;

  const _MoveDetailPanel({required this.move});

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 720;

    return Material(
      color: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 620),
        child: Container(
          decoration: BoxDecoration(
            color: GabisV3.cream,
            border: Border.all(color: GabisV3.ink, width: 1.4),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(color: Color(0x55000000), blurRadius: 50, offset: Offset(0, 26)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Coloured head, so the panel reads as the card enlarged.
              Container(
                padding: EdgeInsets.fromLTRB(narrow ? 20 : 28, 20, 16, 20),
                decoration: BoxDecoration(
                  color: move.color,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                  border: Border(bottom: BorderSide(color: GabisV3.ink, width: 1.4)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(move.icon, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(move.index,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w900, fontSize: 11.5)),
                          const SizedBox(height: 4),
                          Text(
                            move.title,
                            style: TextStyle(
                              fontSize: narrow ? 30 : 38,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.6,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded, size: 20),
                      tooltip: 'Close',
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(narrow ? 20 : 28, 22, narrow ? 20 : 28, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        move.detail,
                        style: TextStyle(
                          fontSize: 15.5,
                          height: 1.6,
                          color: GabisV3.ink.withValues(alpha: .82),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('WHAT IT DOES',
                          style: TextStyle(
                            fontSize: 10.5,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w900,
                            color: GabisV3.ink.withValues(alpha: .45),
                          )),
                      const SizedBox(height: 12),
                      for (final point in move.points)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 5),
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: move.color,
                                  border: Border.all(color: GabisV3.ink, width: 1.1),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 11),
                              Expanded(
                                child: Text(
                                  point,
                                  style: const TextStyle(
                                      fontSize: 14.5,
                                      height: 1.45,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).pushNamed('/login');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: GabisV3.ink,
                              foregroundColor: GabisV3.cream,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 22, vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100)),
                            ),
                            child: const Text('Open your account',
                                style: TextStyle(fontWeight: FontWeight.w800)),
                          ),
                          const SizedBox(width: 10),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('Back to features',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: GabisV3.ink.withValues(alpha: .7))),
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
      ),
    );
  }
}


/// Collections gets its own block: it is the one thing here that works while
/// the business owner is doing something else, and it was getting lost as one
/// card in a drifting row.
class _CollectionsSection extends StatelessWidget {
  const _CollectionsSection();

  static const _steps = [
    (
      '01',
      'Add whoever owes you',
      'Import your debtors once — name, number, what they owe, when it was due.',
      Icons.group_add_rounded,
      GabisV3.sky,
    ),
    (
      '02',
      'Reminders go out on time',
      'Ten days before, on the day, and after. You never have to remember a date again.',
      Icons.schedule_rounded,
      GabisV3.lilac,
    ),
    (
      '03',
      'The agent does the asking',
      'It negotiates in the customer’s own language, understands a payment promise, sets the follow-up date and updates the invoice itself.',
      Icons.record_voice_over_rounded,
      GabisV3.lime,
    ),
    (
      '04',
      'Payment clears the invoice',
      'A one-tap link on WhatsApp. When it lands, the ledger updates itself.',
      Icons.task_alt_rounded,
      GabisV3.coral,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final width = c.maxWidth;
        final desktop = width >= 980;
        final side = GabisV3.side(width);

        return Container(
          color: GabisV3.cream,
          padding: EdgeInsets.fromLTRB(side, desktop ? 74 : 60, side, desktop ? 78 : 64),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: GabisV3.lime,
                      border: Border.all(color: GabisV3.ink, width: 1.2),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Text('THE INNOVATION',
                        style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5)),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          'MOST BUSINESSES ARE OWED\nMONEY THEY NEVER ASK FOR TWICE.',
                          style: TextStyle(
                            fontSize: desktop ? 46 : 32,
                            height: .98,
                            letterSpacing: -2,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      if (desktop)
                        const SizedBox(
                          width: 330,
                          child: Text(
                            'The agent asks for them — in English, Pidgin, Yoruba, Hausa or Igbo. '
                            'It hears the promise, sets the follow-up, and clears the invoice when the money lands.',
                            style: TextStyle(
                                fontSize: 15.5,
                                height: 1.55,
                                fontWeight: FontWeight.w500,
                                color: Color(0xB3101010)),
                          ),
                        ),
                    ],
                  ),
                  if (!desktop) ...[
                    const SizedBox(height: 14),
                    const Text(
                      'The agent asks for them — in English, Pidgin, Yoruba, Hausa or Igbo. '
                      'It hears the promise, sets the follow-up, and clears the invoice when the money lands.',
                      style: TextStyle(
                          fontSize: 15,
                          height: 1.55,
                          fontWeight: FontWeight.w500,
                          color: Color(0xB3101010)),
                    ),
                  ],
                  const SizedBox(height: 30),
                  if (desktop)
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = 0; i < _steps.length; i++) ...[
                            if (i > 0) const SizedBox(width: 12),
                            Expanded(child: _CollectStep(step: _steps[i])),
                          ],
                        ],
                      ),
                    )
                  else
                    Column(
                      children: [
                        for (final step in _steps)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _CollectStep(step: step),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CollectStep extends StatelessWidget {
  final (String, String, String, IconData, Color) step;

  const _CollectStep({required this.step});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: step.$5,
        border: Border.all(color: GabisV3.ink, width: 1.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(step.$1,
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900)),
              const Spacer(),
              Icon(step.$4, size: 17),
            ],
          ),
          const SizedBox(height: 22),
          Text(step.$2,
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.5,
                  height: 1.15)),
          const SizedBox(height: 7),
          Text(step.$3,
              style: TextStyle(
                fontSize: 12.5,
                height: 1.45,
                fontWeight: FontWeight.w500,
                color: GabisV3.ink.withValues(alpha: .74),
              )),
        ],
      ),
    );
  }
}


/// The architecture argument, stated plainly: a deterministic core that cannot
/// hallucinate a number, with a model on top for language and judgement.
class _IntelligenceSection extends StatelessWidget {
  const _IntelligenceSection();

  static const _layers = [
    (
      'AJO SAVING CIRCLE',
      'Rotate funds with trust',
      'Join or create saving circles with your community. Gabis automates the collection and payout schedules, ensuring everyone gets paid on time without the administrative headache.',
      Icons.groups_rounded,
      GabisV3.lime,
    ),
    (
      'SECURE ESCROW',
      'Protect every transaction',
      'Buy and sell with complete confidence. Gabis holds the funds securely until both parties are satisfied, making fraud impossible and resolving disputes fairly.',
      Icons.lock_outline_rounded,
      GabisV3.sky,
    ),
    (
      'ALWAYS',
      'You approve before money moves',
      'Transparency is built-in. Every contribution, payout, and escrow release waits for your approval. No automation here can spend on your behalf.',
      Icons.verified_user_outlined,
      GabisV3.lilac,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final width = c.maxWidth;
        final desktop = width >= 980;
        final side = GabisV3.side(width);

        return Container(
          color: GabisV3.ink,
          padding: EdgeInsets.fromLTRB(side, desktop ? 72 : 58, side, desktop ? 76 : 62),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .08),
                          border: Border.all(color: Colors.white.withValues(alpha: .2)),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: const Text('COMMUNITY & TRUST',
                            style: TextStyle(
                                color: GabisV3.cream,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'THE FUNDS ARE SECURE.\nTHE COMMUNITY IS EMPOWERED.',
                    style: TextStyle(
                      color: GabisV3.cream,
                      fontSize: desktop ? 42 : 28,
                      height: 1.02,
                      letterSpacing: -1.8,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Text(
                      'Most finance apps ask a model to do arithmetic and hope it is right. '
                      'We do the opposite: the numbers come from your own transactions, and the model is used where it is genuinely better than code — language, context and judgement.',
                      style: TextStyle(
                        color: GabisV3.cream.withValues(alpha: .74),
                        fontSize: 16,
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  if (desktop)
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = 0; i < _layers.length; i++) ...[
                            if (i > 0) const SizedBox(width: 14),
                            Expanded(child: _LayerCard(layer: _layers[i])),
                          ],
                        ],
                      ),
                    )
                  else
                    Column(
                      children: [
                        for (final layer in _layers)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _LayerCard(layer: layer),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LayerCard extends StatelessWidget {
  final (String, String, String, IconData, Color) layer;

  const _LayerCard({required this.layer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .06),
        border: Border.all(color: Colors.white.withValues(alpha: .16)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(layer.$1,
                  style: TextStyle(
                      color: layer.$5,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.4)),
              const Spacer(),
              Icon(layer.$4, size: 17, color: layer.$5),
            ],
          ),
          const SizedBox(height: 20),
          Text(layer.$2,
              style: const TextStyle(
                  color: GabisV3.cream,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.6,
                  height: 1.15)),
          const SizedBox(height: 9),
          Text(layer.$3,
              style: TextStyle(
                color: GabisV3.cream.withValues(alpha: .68),
                fontSize: 13.5,
                height: 1.5,
                fontWeight: FontWeight.w500,
              )),
        ],
      ),
    );
  }
}


class _InnovationsCurvePainter extends CustomPainter {
  final Color color;
  final Color fillColor;

  const _InnovationsCurvePainter({
    required this.color,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path();
    path.moveTo(0, h * 0.7);
    path.cubicTo(w * 0.25, h * 0.9, w * 0.45, h * 0.2, w * 0.65, h * 0.35);
    path.cubicTo(w * 0.8, h * 0.45, w * 0.9, h * 0.1, w, h * 0.15);

    final fillPath = Path.from(path)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [fillColor.withValues(alpha: .35), fillColor.withValues(alpha: .02)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, linePaint);

    // Draw peak point
    final peak = Offset(w * 0.45, h * 0.2);
    canvas.drawCircle(peak, 5, Paint()..color = Colors.white);
    canvas.drawCircle(peak, 3, Paint()..color = color);

    final endPt = Offset(w * 0.98, h * 0.16);
    canvas.drawCircle(endPt, 4.5, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _InnovationsRipplePainter extends CustomPainter {
  final Color color;

  const _InnovationsRipplePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radiuses = [38.0, 56.0, 76.0, 96.0];
    final opacities = [0.25, 0.15, 0.08, 0.04];

    for (int i = 0; i < radiuses.length; i++) {
      final paint = Paint()
        ..color = color.withValues(alpha: opacities[i])
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(center, radiuses[i], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SpokeCirclePainter extends CustomPainter {
  final Color color;

  const _SpokeCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    const spokeCount = 16;

    for (int i = 0; i < spokeCount; i++) {
      final angle = (i * 2 * 3.1415926535) / spokeCount;
      final p1 = Offset(center.dx + (r - 10) * math.cos(angle), center.dy + (r - 10) * math.sin(angle));
      final p2 = Offset(center.dx + r * math.cos(angle), center.dy + r * math.sin(angle));

      final paint = Paint()
        ..color = color.withValues(alpha: .5)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(p1, p2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _InnovationsSection extends StatelessWidget {
  const _InnovationsSection();

  Widget _pillTag({required String text, required Color bgColor, required Color textColor, IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: textColor, size: 14),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBox(IconData icon, Color bg, Color iconColor) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Icon(icon, color: iconColor, size: 24),
      ),
    );
  }

  // --- CARD 1: Autonomous Forex Sniping ---
  Widget _buildForexCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEAFBF3), Color(0xFFF2FDF8)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0x2810B981), width: 1.5),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 24, offset: Offset(0, 10)),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final stackCol = c.maxWidth < 480;
          return Flex(
            direction: stackCol ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: stackCol ? 0 : 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _iconBox(Icons.trending_up_rounded, const Color(0xFFD1FAE5), const Color(0xFF059669)),
                    const SizedBox(height: 16),
                    const Text(
                      'Autonomous\nForex Sniping',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF111827), height: 1.15, letterSpacing: -.4),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Set a goal, and the Gabis AI will automatically swipe the best exchange rates 24/7 to dollar-cost average into your foreign wallets.',
                      style: TextStyle(fontSize: 13.5, color: Color(0xFF4B5563), height: 1.5, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 20),
                    _pillTag(
                      text: 'Higher rates. Lower costs.',
                      bgColor: const Color(0xFFD1FAE5),
                      textColor: const Color(0xFF047857),
                      icon: Icons.auto_awesome,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20, height: 20),
              Expanded(
                flex: stackCol ? 0 : 6,
                child: SizedBox(
                  height: 170,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Smooth curve
                      const Positioned.fill(
                        child: CustomPaint(
                          painter: _InnovationsCurvePainter(
                            color: Color(0xFF10B981),
                            fillColor: Color(0xFF10B981),
                          ),
                        ),
                      ),
                      // Tooltip pill at peak
                      Positioned(
                        top: 2,
                        left: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(color: Color(0x15000000), blurRadius: 18, offset: Offset(0, 6)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Best rate found', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 9.5, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 3),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('₦1,620', style: TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w900, fontSize: 13)),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(6)),
                                    child: const Text('+2.4%', style: TextStyle(color: Color(0xFF16A34A), fontSize: 10, fontWeight: FontWeight.w800)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Currency pair selector pill at bottom
                      Positioned(
                        bottom: 0,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(color: const Color(0x15000000)),
                            boxShadow: const [BoxShadow(color: Color(0x0C000000), blurRadius: 12)],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('🇺🇸', style: TextStyle(fontSize: 14)),
                              SizedBox(width: 4),
                              Text('USD', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF374151))),
                              SizedBox(width: 8),
                              Icon(Icons.swap_horiz_rounded, size: 14, color: Color(0xFF9CA3AF)),
                              SizedBox(width: 8),
                              Text('🇳🇬', style: TextStyle(fontSize: 14)),
                              SizedBox(width: 4),
                              Text('NGN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF374151))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- CARD 2: Voice-to-Execute ---
  Widget _buildVoiceCard() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF5F3FF), Color(0xFFFAF5FF)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0x288B5CF6), width: 1.5),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 24, offset: Offset(0, 10)),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final stackCol = c.maxWidth < 480;
          return Flex(
            direction: stackCol ? Axis.vertical : Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: stackCol ? 0 : 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _iconBox(Icons.mic_none_rounded, const Color(0xFFEDE9FE), const Color(0xFF6D28D9)),
                    const SizedBox(height: 16),
                    const Text(
                      'Voice-to-Execute',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF111827), letterSpacing: -.4),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Zero taps required. Hold the mic and tell Gabis what you need. It parses and executes instantly.',
                      style: TextStyle(fontSize: 13.5, color: Color(0xFF4B5563), height: 1.5, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 20),
                    _pillTag(
                      text: 'Just speak. It happens.',
                      bgColor: const Color(0xFFEDE9FE),
                      textColor: const Color(0xFF6D28D9),
                      icon: Icons.graphic_eq_rounded,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20, height: 20),
              Expanded(
                flex: stackCol ? 0 : 6,
                child: SizedBox(
                  height: 170,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      // Expanding Ripples
                      const SizedBox(
                        width: 200,
                        height: 200,
                        child: CustomPaint(
                          painter: _InnovationsRipplePainter(color: Color(0xFF8B5CF6)),
                        ),
                      ),
                      // Glowing Blue Microphone Button
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2563EB).withValues(alpha: .45),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(Icons.mic_rounded, color: Colors.white, size: 28),
                        ),
                      ),
                      // Floating Speech Bubble
                      Positioned(
                        top: 4,
                        right: -10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(color: Color(0x12000000), blurRadius: 16, offset: Offset(0, 4)),
                            ],
                          ),
                          child: const Text(
                            '"Swap 50k NGN to USD..."',
                            style: TextStyle(
                              color: Color(0xFF2563EB),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- CARD 3: Roast My Spending ---
  Widget _buildRoastCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF1EE), Color(0xFFFFF7F5)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0x28F43F5E), width: 1.5),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 24, offset: Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _iconBox(Icons.camera_alt_outlined, const Color(0xFFFFE4E6), const Color(0xFFE11D48)),
              const Spacer(),
              // Tilted Roast Card
              Transform.rotate(
                angle: -0.08,
                child: Container(
                  width: 150,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111827),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(color: Color(0x20000000), blurRadius: 16, offset: Offset(0, 8)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(color: Color(0xFFEA580C), shape: BoxShape.circle),
                            child: const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 10),
                          ),
                          const SizedBox(width: 4),
                          const Text('Gabis Roast', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'You spent ₦45,000\non Uber this month.\nAre your legs broken? 💀',
                        style: TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.w700, height: 1.25),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white.withValues(alpha: .2)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.camera_alt_rounded, color: Colors.white, size: 8),
                              SizedBox(width: 4),
                              Text('Share to Instagram', style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w800)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Roast My Spending',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF111827), letterSpacing: -.4),
          ),
          const SizedBox(height: 8),
          const Text(
            'Get hyper-personalized, hilariously brutal AI roasts of your monthly spending habits. Share directly to socials.',
            style: TextStyle(fontSize: 12.5, color: Color(0xFF4B5563), height: 1.45, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          // Share Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFF43F5E),
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.share_rounded, color: Colors.white, size: 13),
                SizedBox(width: 6),
                Text(
                  'Share the roast',
                  style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- CARD 4: Level Up Your Agent ---
  Widget _buildLevelCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF0FDF4), Color(0xFFF7FEFA)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0x2810B981), width: 1.5),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 24, offset: Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _iconBox(Icons.smart_toy_rounded, const Color(0xFFD1FAE5), const Color(0xFF059669)),
              const Spacer(),
              // Level Spoke Dial
              SizedBox(
                width: 120,
                height: 100,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const SizedBox(
                      width: 90,
                      height: 90,
                      child: CustomPaint(
                        painter: _SpokeCirclePainter(color: Color(0xFF10B981)),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('AGENT LEVEL', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Color(0xFF6B7280), letterSpacing: .8)),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(color: Color(0xFFD9FF43), shape: BoxShape.circle),
                              child: const Center(child: Text('15', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF111827)))),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward_rounded, size: 10, color: Color(0xFF9CA3AF)),
                            const SizedBox(width: 4),
                            Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(color: Color(0xFF111827), shape: BoxShape.circle),
                              child: const Center(child: Text('16', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white))),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text('Zero-fee transfers\nUNLOCKED!', textAlign: TextAlign.center, style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Level Up Your Agent',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF111827), letterSpacing: -.4),
          ),
          const SizedBox(height: 8),
          const Text(
            'Catch orbs, maintain savings streaks, and earn points to level up your AI Agent.',
            style: TextStyle(fontSize: 12.5, color: Color(0xFF4B5563), height: 1.45, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          _pillTag(
            text: 'Play. Save. Earn.',
            bgColor: const Color(0xFFD1FAE5),
            textColor: const Color(0xFF047857),
            icon: Icons.star_rounded,
          ),
        ],
      ),
    );
  }

  // --- CARD 5: Tokyo Trip Fund (Squad Wealth) ---
  Widget _buildSquadCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFBEB), Color(0xFFFEFCE8)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0x28F59E0B), width: 1.5),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 24, offset: Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _iconBox(Icons.account_balance_wallet_rounded, const Color(0xFFEDE9FE), const Color(0xFF6D28D9)),
              const Spacer(),
              // Mini Tokyo Trip Card
              Container(
                width: 140,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Color(0x10000000), blurRadius: 16, offset: Offset(0, 6)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.flight_takeoff_rounded, size: 10, color: Color(0xFF4F46E5)),
                        SizedBox(width: 4),
                        Text('Tokyo Trip Fund', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                      ],
                    ),
                    const SizedBox(height: 6),
                    _squadMiniRow('S', const Color(0xFF8B5CF6), 'Sarah', r'$120 owed', const Color(0xFFFFE4E6), const Color(0xFFE11D48)),
                    const SizedBox(height: 4),
                    _squadMiniRow('D', const Color(0xFF3B82F6), 'Deji', 'Paid ✅', const Color(0xFFDCFCE7), const Color(0xFF16A34A)),
                    const SizedBox(height: 4),
                    _squadMiniRow('Y', const Color(0xFF3B82F6), 'You', 'Paid ✅', const Color(0xFFDCFCE7), const Color(0xFF16A34A)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Tokyo Trip Fund',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF111827), letterSpacing: -.4),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create shared wallets for trips, Gabis tracks who owes what and gently nudges your friends.',
            style: TextStyle(fontSize: 12.5, color: Color(0xFF4B5563), height: 1.45, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          _pillTag(
            text: 'Plan together',
            bgColor: const Color(0xFFEDE9FE),
            textColor: const Color(0xFF6D28D9),
            icon: Icons.calendar_month_rounded,
          ),
        ],
      ),
    );
  }

  static Widget _squadMiniRow(String initial, Color circleCol, String name, String status, Color statusBg, Color statusText) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: circleCol, shape: BoxShape.circle),
          child: Center(child: Text(initial, style: const TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w900))),
        ),
        const SizedBox(width: 4),
        Text(name, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Color(0xFF374151))),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(4)),
          child: Text(status, style: TextStyle(fontSize: 6.5, fontWeight: FontWeight.w800, color: statusText)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final width = c.maxWidth;
        final desktop = width >= 980;
        final side = GabisV3.side(width);

        return Container(
          color: const Color(0xFFFAFAFD),
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: desktop ? 100 : 64),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: side),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Clean Header Copy without floating visual
                    _pillTag(
                      text: 'The Agent That Gets You Paid',
                      bgColor: const Color(0xFFEDE9FE),
                      textColor: const Color(0xFF4F46E5),
                      icon: Icons.auto_awesome,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Irresistible',
                      style: TextStyle(
                        fontSize: desktop ? 54 : 38,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF111827),
                        letterSpacing: desktop ? -2 : -1.5,
                        height: 1.0,
                      ),
                    ),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF9333EA)],
                      ).createShader(bounds),
                      child: Text(
                        'Innovations',
                        style: TextStyle(
                          fontSize: desktop ? 54 : 38,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: desktop ? -2 : -1.5,
                          height: 1.05,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Finance shouldn't be boring. Gabis is packed with next-generation\nAI features that feel like magic.",
                      style: TextStyle(
                        fontSize: desktop ? 16 : 15,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B7280),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        // Start using Gabis -> Button
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB),
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2563EB).withValues(alpha: .32),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Start using Gabis', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Explore features Button
                        const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.play_circle_outline_rounded, color: Color(0xFF4B5563), size: 18),
                            SizedBox(width: 6),
                            Text('Explore features', style: TextStyle(color: Color(0xFF374151), fontWeight: FontWeight.w700, fontSize: 14)),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 48),

                    // BENTO ROW 1: Two Wide Cards
                    if (desktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildForexCard()),
                          const SizedBox(width: 20),
                          Expanded(child: _buildVoiceCard()),
                        ],
                      )
                    else ...[
                      _buildForexCard(),
                      const SizedBox(height: 18),
                      _buildVoiceCard(),
                    ],

                    const SizedBox(height: 20),

                    // BENTO ROW 2: Three Cards
                    if (desktop)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildRoastCard()),
                          const SizedBox(width: 20),
                          Expanded(child: _buildLevelCard()),
                          const SizedBox(width: 20),
                          Expanded(child: _buildSquadCard()),
                        ],
                      )
                    else ...[
                      _buildRoastCard(),
                      const SizedBox(height: 18),
                      _buildLevelCard(),
                      const SizedBox(height: 18),
                      _buildSquadCard(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CurrencyStage extends StatelessWidget {
  const _CurrencyStage();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final width = c.maxWidth;
        final desktop = width >= 940;
        final side = GabisV3.side(width);

        return Container(
          color: GabisV3.electric,
          padding: EdgeInsets.fromLTRB(side, desktop ? 86 : 72, side, desktop ? 90 : 76),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: desktop
                  ? const Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(flex: 6, child: _CurrencyCopy()),
                        SizedBox(width: 64),
                        Expanded(flex: 5, child: _CurrencyVisual()),
                      ],
                    )
                  : const Column(
                      children: [
                        _CurrencyCopy(),
                        SizedBox(height: 44),
                        _CurrencyVisual(),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}

class _CurrencyCopy extends StatelessWidget {
  const _CurrencyCopy();

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 940;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'YOUR MONEY\nSPEAKS MORE THAN\nONE LANGUAGE.',
          style: TextStyle(
            color: Colors.white,
            fontSize: desktop ? 52 : 38,
            height: .98,
            letterSpacing: -2.2,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 18),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: const Text(
            'Switch between balances without losing the thread. Know what you have, what you sent and what comes next.',
            style: TextStyle(
              color: Color(0xE6FFFFFF),
              fontSize: 16.5,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

/// One flat panel, dense rows, hairline rules — the balance list reads like a
/// ledger rather than a stack of coloured pills.
class _CurrencyVisual extends StatelessWidget {
  const _CurrencyVisual();

  static const _rows = [
    ('NGN', 'Nigerian naira', '₦120,000.00', GabisV3.lime, true),
    ('USD', 'US dollar', r'$200.00', GabisV3.sky, false),
    ('GBP', 'Pound sterling', '£100.00', GabisV3.lilac, false),
    ('CAD', 'Canadian dollar', r'C$100.00', GabisV3.coral, false),
    ('JPY', 'Japanese yen', '¥10,000', GabisV3.sky, false),
  ];

  @override
  Widget build(BuildContext context) {
    final panel = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0x2A0B1020), blurRadius: 40, offset: Offset(0, 22)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            child: Row(
              children: [
                const Text('Wallets',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: GabisV3.ink.withValues(alpha: .06),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Text('6',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                ),
                const Spacer(),
                Text('Live rates',
                    style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: GabisV3.ink.withValues(alpha: .45))),
              ],
            ),
          ),
          ValueListenableBuilder<int>(
            valueListenable: gabisPoints,
            builder: (context, points, _) => _BalanceRow(
              code: 'PTS',
              name: 'Gabis Points',
              amount: '$points pts',
              accent: GabisV3.lime,
              active: false,
            ),
          ),
          for (final r in _rows)
            _BalanceRow(
              code: r.$1,
              name: r.$2,
              amount: r.$3,
              accent: r.$4,
              active: r.$5,
            ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
            decoration: BoxDecoration(
              color: GabisV3.ink.withValues(alpha: .035),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
            ),
            child: Row(
              children: [
                Text('Total value',
                    style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: GabisV3.ink.withValues(alpha: .55))),
                const Spacer(),
                const Text('≈ ₦860,000',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -.5)),
              ],
            ),
          ),
        ],
      ),
    );

    // The lime slab sits a few degrees off behind the panel, so the list has
    // something to lift off instead of floating on flat blue.
    return Stack(
      children: [
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.only(left: 18, top: 18),
            child: Transform.rotate(
              angle: .045,
              child: Container(
                decoration: BoxDecoration(
                  color: GabisV3.lime,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16, bottom: 16),
          child: panel,
        ),
      ],
    );
  }
}

class _BalanceRow extends StatelessWidget {
  final String code;
  final String name;
  final String amount;
  final Color accent;
  final bool active;

  const _BalanceRow({
    required this.code,
    required this.name,
    required this.amount,
    required this.accent,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
      decoration: BoxDecoration(
        color: active ? accent.withValues(alpha: .16) : null,
        border: Border(
          top: BorderSide(color: GabisV3.ink.withValues(alpha: .07)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(
              code.substring(0, 1),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(code,
                  style: const TextStyle(
                      fontSize: 13.5, fontWeight: FontWeight.w900, height: 1.1)),
              Text(name,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                      color: GabisV3.ink.withValues(alpha: .45))),
            ],
          ),
          const Spacer(),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              letterSpacing: -.4,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardMoment extends StatelessWidget {
  const _CardMoment();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final width = c.maxWidth;
        final desktop = width >= 980;
        final side = GabisV3.side(width);

        final copy = Column(
          crossAxisAlignment:
              desktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            Text(
              'A CARD THAT DOESN’T\nMAKE YOU THINK\nABOUT THE CARD.',
              textAlign: desktop ? TextAlign.left : TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: desktop ? 46 : 34,
                height: .98,
                letterSpacing: -2,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 14),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Text(
                'Freeze it. Unfreeze it. See what you spent. Keep moving. The controls stay close, and the experience stays quiet.',
                textAlign: desktop ? TextAlign.left : TextAlign.center,
                style: const TextStyle(
                  color: Color(0xCCFFFFFF),
                  fontSize: 17,
                  height: 1.55,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 18),
            // Three concrete controls, so the dark band carries substance
            // instead of empty margin.
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment:
                  desktop ? Alignment.centerLeft : Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  _CardPill(icon: Icons.ac_unit_rounded, label: 'Freeze instantly'),
                  SizedBox(width: 8),
                  _CardPill(icon: Icons.bolt_rounded, label: 'Spend in 5 currencies'),
                  SizedBox(width: 8),
                  _CardPill(icon: Icons.lock_rounded, label: 'Details you can rotate'),
                ],
              ),
            ),
          ],
        );

        return Container(
          color: GabisV3.ink,
          padding: EdgeInsets.fromLTRB(side, desktop ? 46 : 44, side, desktop ? 50 : 48),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: desktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(flex: 5, child: copy),
                        const SizedBox(width: 40),
                        const Expanded(flex: 6, child: Center(child: _CardFan())),
                      ],
                    )
                  : Column(
                      children: [
                        copy,
                        const SizedBox(height: 46),
                        const _CardFan(),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}

class _CardPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CardPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.white.withValues(alpha: .14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: GabisV3.lime),
          const SizedBox(width: 7),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _CardFan extends StatelessWidget {
  const _CardFan();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final scale = width < 600 ? .54 : (width < 1180 ? .60 : .66);

    // Five cards fanned out from the centre, back to front.
    const spread = [
      (-2.0, -.30, GabisV3.lilac, true, _Network.mastercard, '2261'),
      (-1.0, -.16, GabisV3.lime, true, _Network.visa, '7714'),
      (2.0, .30, GabisV3.sky, true, _Network.visa, '8890'),
      (1.0, .16, GabisV3.coral, true, _Network.visa, '5183'),
      (0.0, .0, GabisV3.electric, false, _Network.mastercard, '4028'),
    ];

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: SizedBox(
        width: 760 * scale,
        height: 360 * scale,
        child: Stack(
          alignment: Alignment.center,
          children: [
            for (final card in spread)
              Transform.translate(
                offset: Offset(card.$1 * 118 * scale, card.$1.abs() * 13),
                child: Transform.rotate(
                  angle: card.$2,
                  child: _Card(
                    color: card.$3,
                    scale: scale,
                    darkText: card.$4,
                    network: card.$5,
                    last4: card.$6,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

enum _Network { visa, mastercard }

class _Card extends StatelessWidget {
  final Color color;
  final double scale;
  final bool darkText;
  final _Network network;
  final String last4;
  final String holder;

  const _Card({
    required this.color,
    required this.scale,
    this.darkText = false,
    this.network = _Network.visa,
    this.last4 = '4028',
    this.holder = 'DEJI ADEWUSI',
  });

  @override
  Widget build(BuildContext context) {
    final fg = darkText ? GabisV3.ink : Colors.white;

    return Container(
      width: 360 * scale,
      height: 224 * scale,
      padding: EdgeInsets.all(22 * scale),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20 * scale),
        // A card catches light across its face rather than sitting flat.
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(color, Colors.white, .18)!,
            color,
            Color.lerp(color, Colors.black, .22)!,
          ],
          stops: const [0, .55, 1],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: .18)),
        boxShadow: const [
          BoxShadow(color: Color(0x55000000), blurRadius: 30, offset: Offset(0, 18)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                darkText
                    ? 'assets/gabis_logo.png'
                    : 'assets/gabis_logo_white.png',
                height: 34 * scale,
                fit: BoxFit.contain,
              ),
              const Spacer(),
              Text('DEBIT',
                  style: TextStyle(
                      color: fg.withValues(alpha: .7),
                      fontSize: 9 * scale,
                      letterSpacing: 1.6,
                      fontWeight: FontWeight.w800)),
            ],
          ),

          SizedBox(height: 16 * scale),

          // Chip and contactless, the two things every real card carries.
          Row(
            children: [
              CustomPaint(
                size: Size(38 * scale, 29 * scale),
                painter: _ChipPainter(darkText: darkText),
              ),
              SizedBox(width: 12 * scale),
              CustomPaint(
                size: Size(16 * scale, 18 * scale),
                painter: _ContactlessPainter(color: fg.withValues(alpha: .85)),
              ),
            ],
          ),

          const Spacer(),

          // A card number is one thing: at a narrow width it should get
          // smaller, not wrap or spill over the edge of the card.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                _digits('••••', fg, scale),
                SizedBox(width: 11 * scale),
                _digits('••••', fg, scale),
                SizedBox(width: 11 * scale),
                _digits('••••', fg, scale),
                SizedBox(width: 11 * scale),
                _digits(last4, fg, scale),
              ],
            ),
          ),

          SizedBox(height: 14 * scale),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // A long name is the variable thing on a card of fixed width, so
              // it is the thing that gives.
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('CARDHOLDER',
                        style: TextStyle(
                            color: fg.withValues(alpha: .55),
                            fontSize: 7 * scale,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w700)),
                    SizedBox(height: 3 * scale),
                    Text(holder,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: fg,
                            fontSize: 11.5 * scale,
                            letterSpacing: .8,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              SizedBox(width: 18 * scale),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('VALID THRU',
                      style: TextStyle(
                          color: fg.withValues(alpha: .55),
                          fontSize: 7 * scale,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700)),
                  SizedBox(height: 3 * scale),
                  Text('09/29',
                      style: TextStyle(
                          color: fg,
                          fontSize: 11.5 * scale,
                          letterSpacing: .8,
                          fontWeight: FontWeight.w700)),
                ],
              ),
              const Spacer(),
              if (network == _Network.visa)
                CustomPaint(
                  size: Size(64 * scale, 22 * scale),
                  painter: _VisaPainter(color: fg),
                )
              else
                CustomPaint(
                  size: Size(52 * scale, 40 * scale),
                  painter: _MastercardPainter(darkText: darkText),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _digits(String text, Color fg, double s) => Text(
        text,
        style: TextStyle(
          color: fg,
          fontSize: 17 * s,
          letterSpacing: 1.4,
          fontWeight: FontWeight.w800,
          shadows: [
            Shadow(color: Colors.black.withValues(alpha: .18), offset: const Offset(0, 1)),
          ],
        ),
      );
}

/// EMV chip: gold plate with the contact tracks etched across it.
class _ChipPainter extends CustomPainter {
  final bool darkText;
  const _ChipPainter({required this.darkText});

  @override
  void paint(Canvas canvas, Size size) {
    final r = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(size.height * .22),
    );
    canvas.drawRRect(
      r,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF7DFA2), Color(0xFFD9B45F), Color(0xFFEBD08A)],
        ).createShader(Offset.zero & size),
    );

    final line = Paint()
      ..color = const Color(0xFF9C7C33).withValues(alpha: .75)
      ..strokeWidth = size.height * .045;

    final w = size.width, h = size.height;
    canvas.drawLine(Offset(0, h * .32), Offset(w * .3, h * .32), line);
    canvas.drawLine(Offset(0, h * .68), Offset(w * .3, h * .68), line);
    canvas.drawLine(Offset(w * .7, h * .32), Offset(w, h * .32), line);
    canvas.drawLine(Offset(w * .7, h * .68), Offset(w, h * .68), line);
    canvas.drawRect(
      Rect.fromLTRB(w * .3, h * .16, w * .7, h * .84),
      line..style = PaintingStyle.stroke,
    );
    canvas.drawLine(Offset(w * .5, h * .16), Offset(w * .5, h * .84), line);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// The contactless waves.
class _ContactlessPainter extends CustomPainter {
  final Color color;
  const _ContactlessPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width * .13;

    for (var i = 1; i <= 3; i++) {
      final radius = size.width * .28 * i;
      canvas.drawArc(
        Rect.fromCircle(center: Offset(0, size.height / 2), radius: radius),
        -0.9,
        1.8,
        false,
        p,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Mastercard's interlocking circles.
class _MastercardPainter extends CustomPainter {
  final bool darkText;
  const _MastercardPainter({this.darkText = true});

  @override
  void paint(Canvas canvas, Size size) {
    // Marks sit on the upper band; the wordmark sits under them.
    final markH = size.height * .72;
    final r = markH / 2;
    final cy = r;
    final left = Offset(size.width / 2 - r * .62, cy);
    final right = Offset(size.width / 2 + r * .62, cy);

    canvas.drawCircle(left, r, Paint()..color = const Color(0xFFEB001B));
    canvas.drawCircle(right, r, Paint()..color = const Color(0xFFF79E1B));

    // True intersection, so the overlap reads as Mastercard's third shape.
    final overlap = Path.combine(
      PathOperation.intersect,
      Path()..addOval(Rect.fromCircle(center: left, radius: r)),
      Path()..addOval(Rect.fromCircle(center: right, radius: r)),
    );
    canvas.drawPath(overlap, Paint()..color = const Color(0xFFFF5F00));

    final tp = TextPainter(
      text: TextSpan(
        text: 'mastercard',
        style: TextStyle(
          fontSize: size.height * .19,
          fontWeight: FontWeight.w600,
          letterSpacing: -.2,
          color: darkText ? GabisV3.ink : Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset((size.width - tp.width) / 2, markH + size.height * .04));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Visa wordmark: the slanted capitals with the clipped V notch.
class _VisaPainter extends CustomPainter {
  final Color color;
  const _VisaPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final tp = TextPainter(
      text: TextSpan(
        text: 'VISA',
        style: TextStyle(
          fontSize: size.height,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
          letterSpacing: -size.height * .03,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    canvas.save();
    canvas.translate(size.width - tp.width, 0);
    tp.paint(canvas, Offset.zero);

    // The gold notch cut into the V, as on the real mark.
    final notch = Path()
      ..moveTo(tp.width * .055, tp.height * .30)
      ..lineTo(tp.width * .175, tp.height * .30)
      ..lineTo(tp.width * .135, tp.height * .40)
      ..close();
    canvas.drawPath(notch, Paint()..color = const Color(0xFFF7B600));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_VisaPainter oldDelegate) => oldDelegate.color != color;
}


class _ProofSection extends StatelessWidget {
  const _ProofSection();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final width = c.maxWidth;
        final desktop = width >= 900;
        final side = GabisV3.side(width);

        return Container(
          color: GabisV3.cream,
          padding: EdgeInsets.fromLTRB(side, desktop ? 62 : 54, side, desktop ? 66 : 58),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1320),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LESS FRICTION.\nMORE LIFE.',
                    style: TextStyle(
                      fontSize: desktop ? 48 : 36,
                      height: .96,
                      letterSpacing: -2.2,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const _ProofRow(
                    number: '01',
                    title: 'Know where your money is.',
                    body: 'Balances, activity and controls are designed to be readable at a glance.',
                  ),
                  const _ProofRow(
                    number: '02',
                    title: 'Move it without a maze.',
                    body: 'The important actions are obvious. The interface gets out of your way.',
                  ),
                  const _ProofRow(
                    number: '03',
                    title: 'Stay in control.',
                    body: 'Card and account controls are close enough to use before stress becomes a support ticket.',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProofRow extends StatelessWidget {
  final String number;
  final String title;
  final String body;

  const _ProofRow({required this.number, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final desktop = MediaQuery.sizeOf(context).width >= 760;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: GabisV3.line)),
      ),
      child: desktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                    width: 74,
                    child: Text(number,
                        style: const TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 13))),
                Expanded(
                  flex: 6,
                  child: Text(title,
                      style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -.7)),
                ),
                const SizedBox(width: 26),
                Expanded(
                  flex: 5,
                  child: Text(body,
                      style: const TextStyle(
                          fontSize: 14.5, height: 1.45, fontWeight: FontWeight.w500)),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(number,
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 12.5)),
                const SizedBox(height: 10),
                Text(title,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -.7)),
                const SizedBox(height: 8),
                Text(body,
                    style: const TextStyle(fontSize: 14.5, height: 1.45)),
              ],
            ),
    );
  }
}

/// Closing card: a warm stone panel carrying the mark, the line and the action,
/// with the photograph filling the other half and bleeding to the rounded edge.
class _FinalCta extends StatelessWidget {
  const _FinalCta();

  static const _stone = Color(0xFFE7E0D9);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final width = c.maxWidth;
      final desktop = width > 900;
      final side = GabisV3.side(width);

      final panel = Container(
        color: _stone,
        padding: EdgeInsets.fromLTRB(
          desktop ? 56 : 28,
          desktop ? 64 : 40,
          desktop ? 48 : 28,
          desktop ? 64 : 40,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const GabisLogo(size: 40),
            SizedBox(height: desktop ? 34 : 24),
            Text(
              'money should\nfeel this easy',
              style: TextStyle(
                color: GabisV3.ink,
                fontSize: desktop ? 46 : 32,
                height: 1.12,
                letterSpacing: -1.8,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: desktop ? 24 : 18),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Text(
                'Open an account in minutes, hold the currencies you actually use, '
                'and move your first payment the same day.',
                style: TextStyle(
                  color: GabisV3.ink.withValues(alpha: .72),
                  fontSize: desktop ? 16.5 : 15,
                  height: 1.6,
                ),
              ),
            ),
            SizedBox(height: desktop ? 34 : 26),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/login'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 20),
                  decoration: BoxDecoration(
                    color: GabisV3.electric,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Open your account',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

      const photo = WebVideoPanel(
        src: 'media/testimonial_loop.mp4',
        posterAsset: 'assets/images/testimonial_hero_african.jpg',
      );

      return Container(
        width: double.infinity,
        color: GabisV3.cream,
        padding: EdgeInsets.fromLTRB(side, desktop ? 96 : 64, side, desktop ? 96 : 64),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1320),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: desktop
                  ? IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(flex: 1, child: panel),
                          Expanded(flex: 1, child: photo),
                        ],
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        panel,
                        SizedBox(height: 300, width: double.infinity, child: photo),
                      ],
                    ),
            ),
          ),
        ),
      );
    });
  }
}

/// Download band: the copy and store badges sit inside the photograph, over a
/// scrim weighted left so the type always holds contrast.
class _DownloadSection extends StatelessWidget {
  const _DownloadSection();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final width = c.maxWidth;
      final desktop = width > 900;
      final side = GabisV3.side(width);

      // Inset rounded band rather than a full-bleed wall — same crop, far less
      // vertical weight.
      return Padding(
        padding: EdgeInsets.fromLTRB(side, 0, side, 34),
        child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: SizedBox(
        width: double.infinity,
        height: desktop ? 420 : 480,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/cta_hero_cozy_african.jpg',
              fit: BoxFit.cover,
              alignment:
                  desktop ? const Alignment(.55, -.62) : const Alignment(0, -.5),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: desktop ? Alignment.centerLeft : Alignment.bottomCenter,
                  end: desktop ? Alignment.centerRight : Alignment.topCenter,
                  colors: [
                    GabisV3.ink.withValues(alpha: .94),
                    GabisV3.ink.withValues(alpha: .78),
                    GabisV3.ink.withValues(alpha: .22),
                  ],
                  stops: const [0, .5, 1],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(desktop ? 52 : 26, 0, 26, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DOWNLOAD\nFOR FREE.',
                        style: TextStyle(
                          color: GabisV3.cream,
                          fontSize: desktop ? 44 : 34,
                          height: 1.0,
                          letterSpacing: -1.8,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 460),
                        child: Text(
                          'One account, every currency, zero borders: send, receive, earn and move money globally in minutes.',
                          style: TextStyle(
                            color: GabisV3.cream.withValues(alpha: .8),
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Wrap(
                        spacing: 14,
                        runSpacing: 14,
                        children: [
                          _StoreBadge(
                            top: 'Download on the',
                            bottom: 'App Store',
                            child: Icon(Icons.apple, size: 26, color: GabisV3.cream),
                          ),
                          _StoreBadge(
                            top: 'Get it on',
                            bottom: 'Google Play',
                            child: CustomPaint(
                              size: const Size(20, 22),
                              painter: _PlayMarkPainter(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
        ),
      );
    });
  }
}

class _StoreBadge extends StatelessWidget {
  final String top;
  final String bottom;
  final Widget child;

  const _StoreBadge({required this.top, required this.bottom, required this.child});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/login'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          decoration: BoxDecoration(
            border: Border.all(color: GabisV3.cream.withValues(alpha: .35)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              child,
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(top.toUpperCase(),
                      style: TextStyle(
                          color: GabisV3.cream.withValues(alpha: .6),
                          fontSize: 8.5,
                          letterSpacing: 1.1,
                          fontWeight: FontWeight.w700)),
                  Text(bottom,
                      style: TextStyle(
                          color: GabisV3.cream,
                          fontSize: 15,
                          fontWeight: FontWeight.w800)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The Play mark, drawn so it needs no asset.
class _PlayMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final p = Paint()..style = PaintingStyle.fill;
    final apex = Offset(w, h / 2);

    p.color = const Color(0xFF34A853);
    canvas.drawPath(Path()..moveTo(0, 0)..lineTo(w * .68, h * .38)..lineTo(0, h * .5)..close(), p);
    p.color = const Color(0xFFFBBC04);
    canvas.drawPath(Path()..moveTo(w * .68, h * .38)..lineTo(apex.dx, apex.dy)..lineTo(w * .68, h * .62)..close(), p);
    p.color = const Color(0xFFEA4335);
    canvas.drawPath(Path()..moveTo(0, h)..lineTo(w * .68, h * .62)..lineTo(0, h * .5)..close(), p);
    p.color = const Color(0xFF4285F4);
    canvas.drawPath(Path()..moveTo(0, 0)..lineTo(0, h)..lineTo(w * .34, h * .5)..close(), p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Footer extends StatefulWidget {
  const _Footer();

  @override
  State<_Footer> createState() => _FooterState();
}

class _FooterState extends State<_Footer> {
  final _email = TextEditingController();
  bool _subscribed = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  /// Label to destination. A route goes through the navigator; anything with a
  /// scheme opens externally. Every entry here resolves to something real.
  static const _columns = <String, List<(String, String)>>{
    'PRODUCTS': [
      ('Multi-currency wallet', '/wallet'),
      ('Global USD account', '/usd-account'),
      ('Virtual cards', '/virtual-cards'),
      ('Smart invoicing', '/invoicing'),
      ('Instant FX swaps', '/fx'),
      ('Bills & airtime', '/bills'),
    ],
    'FOR BUSINESS': [
      ('gabis Business', '/business'),
      ('Tuition invoicing', '/tuition-invoicing'),
      ('AI debt recovery', '/debt-recovery'),
      ('Connected payments', '/connected-payments'),
      ('Bulk payouts', '/bulk-payouts'),
    ],
    'COMPANY': [
      ('About gabis', '/about'),
      ('Investor Deck', '/gabis-deck.pdf'),
      ('Careers', '/careers'),
      ('Press & news', '/press'),
      ('Brand assets', '/brand'),
    ],
    'LEGAL': [
      ('Terms of service', '/terms'),
      ('Privacy policy', '/privacy'),
      ('Security', '/security'),
      ('Tax compliance', '/tax-compliance'),
    ],
    'SUPPORT': [
      ('Help centre', '/help'),
      ('Contact support', '/contact'),
      ('System status', '/status'),
      ('WhatsApp live chat', 'https://wa.me/2347018888303'),
    ],
  };

  void _subscribe() {
    if (!_email.text.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter an email address so we can reach you.')),
      );
      return;
    }
    setState(() => _subscribed = true);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final desktop = c.maxWidth > 900;
      final side = desktop ? 64.0 : 22.0;

      return Container(
        width: double.infinity,
        color: GabisV3.ink,
        padding: EdgeInsets.fromLTRB(side, 84, side, 44),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1320),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Newsletter
                Center(
                  child: Column(
                    children: [
                      Text(
                        'STAY AHEAD OF THE CURVE',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: GabisV3.cream,
                          fontSize: desktop ? 40 : 28,
                          letterSpacing: -1.6,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: Text(
                          'Product updates and new currency corridors. No noise.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: GabisV3.cream.withValues(alpha: .62),
                            fontSize: 15.5,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 26),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: _subscribed
                            ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                decoration: BoxDecoration(
                                  color: GabisV3.lime.withValues(alpha: .15),
                                  border: Border.all(color: GabisV3.lime),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text('Thanks — we will be in touch.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: GabisV3.lime, fontWeight: FontWeight.w700)),
                              )
                            : Row(children: [
                                Expanded(
                                  child: TextField(
                                    controller: _email,
                                    style: TextStyle(color: GabisV3.cream),
                                    decoration: InputDecoration(
                                      hintText: 'Enter your email address',
                                      hintStyle: TextStyle(color: GabisV3.cream.withValues(alpha: .4)),
                                      filled: true,
                                      fillColor: GabisV3.cream.withValues(alpha: .07),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(100),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: _subscribe,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
                                    decoration: BoxDecoration(
                                      color: GabisV3.lime,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Text('Subscribe',
                                        style: TextStyle(color: GabisV3.ink, fontWeight: FontWeight.w900)),
                                  ),
                                ),
                              ]),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 70),
                Divider(color: GabisV3.cream.withValues(alpha: .14)),
                const SizedBox(height: 44),

                // Brand + link columns
                Wrap(
                  spacing: desktop ? 30 : 18,
                  runSpacing: desktop ? 38 : 26,
                  children: [
                    SizedBox(
                      width: desktop ? 236 : double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                if (Navigator.canPop(context)) {
                                  Navigator.popUntil(context, (r) => r.isFirst);
                                } else {
                                  Navigator.pushNamedAndRemoveUntil(
                                      context, '/', (r) => false);
                                }
                              },
                              child: const GabisLogo(size: 34, isWhite: true),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'One account. Every currency. Zero borders.',
                            style: TextStyle(
                              color: GabisV3.cream.withValues(alpha: .6),
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ..._columns.entries.map((e) => SizedBox(
                          // Two columns per row on a phone.
                          width: desktop
                              ? 158
                              : (c.maxWidth - side * 2 - 18) / 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(e.key,
                                  style: TextStyle(
                                      color: GabisV3.cream,
                                      fontSize: 11.5,
                                      letterSpacing: 1.3,
                                      fontWeight: FontWeight.w900)),
                              const SizedBox(height: 16),
                              ...e.value.map((entry) {
                                final link = entry.$1;
                                final target = entry.$2;
                                final isDeck = link == 'Investor Deck';
                                final external =
                                    target.startsWith('http') || target.endsWith('.pdf');
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 11),
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      onTap: () {
                                        if (external) {
                                          launchUrl(Uri.parse(target),
                                              mode: LaunchMode.externalApplication);
                                        } else {
                                          Navigator.pushNamed(context, target);
                                        }
                                      },
                                      child: Text(
                                        link,
                                        style: TextStyle(
                                          color: isDeck
                                              ? GabisV3.lime
                                              : GabisV3.cream.withValues(alpha: .58),
                                          fontSize: 13.5,
                                          fontWeight:
                                              isDeck ? FontWeight.w800 : FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        )),
                  ],
                ),

                const SizedBox(height: 54),
                Divider(color: GabisV3.cream.withValues(alpha: .14)),
                const SizedBox(height: 22),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: Text(
                    'gabis is a financial technology company, not a bank. '
                    'Money remittance and banking services are provided by our licensed '
                    'financial institution partners.',
                    style: TextStyle(
                      color: GabisV3.cream.withValues(alpha: .5),
                      fontSize: 12.5,
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text('© 2026 gabis',
                    style: TextStyle(
                        color: GabisV3.cream.withValues(alpha: .45), fontSize: 12.5)),
              ],
            ),
          ),
        ),
      );
    });
  }
}
