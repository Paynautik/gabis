import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../shared/widgets/nautik_logo.dart';

// ─── Colors ───────────────────────────────────────────────────
const Color kInk        = Color(0xFF0B0F1A);   // near-black hero bg
const Color kInkSoft    = Color(0xFF141B2C);   // dark text
const Color kGreen      = Color(0xFF00C16A);   // vibrant brand green
const Color kGreenDark  = Color(0xFF006D44);   // deep green
const Color kBlue       = Color(0xFF2563EB);   // CTA blue
const Color kCanvas     = Color(0xFFF8FAFC);   // page bg
const Color kSurface    = Color(0xFFFFFFFF);
const Color kMuted      = Color(0xFF6B7280);
const Color kBorder     = Color(0xFFE5E7EB);
const Color kBorderDark = Color(0xFF1F2937);
const Color kAmber      = Color(0xFFF59E0B);
const Color kGreenLight = Color(0xFFDCFCE7);
const Color kBlueLight  = Color(0xFFDBEAFE);

// ─── Landing Screen ───────────────────────────────────────────
class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCanvas,
      body: SingleChildScrollView(
        child: Column(children: const [
          _Nav(),
          _Hero(),
          _StatsBar(),
          _ForEveryoneSection(),
          _AISection(),
          _ComplianceSection(),
          _CtaBanner(),
          _Footer(),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// NAV
// ─────────────────────────────────────────────────────────────
class _Nav extends StatelessWidget {
  const _Nav();

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.of(context).size.width < 800;
    return Container(
      height: 72,
      padding: EdgeInsets.symmetric(horizontal: mobile ? 20 : 64),
      decoration: const BoxDecoration(
        color: kSurface,
        border: Border(bottom: BorderSide(color: kBorder)),
      ),
      child: Row(children: [
        const NautikLogoMark(size: 30),
        const SizedBox(width: 10),
        const Text('ElumoPay',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: kInkSoft, letterSpacing: -0.3)),
        const Spacer(),
        if (!mobile) ...[
          _Link('Personal'),
          const SizedBox(width: 28),
          _Link('Business'),
          const SizedBox(width: 28),
          _Link('AI Features'),
          const SizedBox(width: 28),
          _Link('Compliance'),
          const SizedBox(width: 32),
          _Link('Log In'),
          const SizedBox(width: 14),
        ],
        _Btn('Get Started', kBlue, kSurface),
      ]),
    );
  }
}

class _Link extends StatelessWidget {
  final String t;
  const _Link(this.t);
  @override
  Widget build(BuildContext context) => Text(t,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: kMuted));
}

class _Btn extends StatefulWidget {
  final String label;
  final Color bg;
  final Color fg;
  const _Btn(this.label, this.bg, this.fg);
  @override
  State<_Btn> createState() => _BtnState();
}

class _BtnState extends State<_Btn> {
  bool _hov = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hov = true),
      onExit:  (_) => setState(() => _hov = false),
      child: GestureDetector(
        onTap: () {},
        child: AnimatedScale(
          scale: _hov ? 0.97 : 1,
          duration: const Duration(milliseconds: 100),
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 22),
            decoration: BoxDecoration(
              color: widget.bg,
              borderRadius: BorderRadius.circular(9999),
            ),
            alignment: Alignment.center,
            child: Text(widget.label,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: widget.fg)),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// HERO — dark, clean, phone-centred
// ─────────────────────────────────────────────────────────────
class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final mobile = w < 860;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kCanvas, kSurface],
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: mobile ? 24 : 64,
        vertical: mobile ? 64 : 96,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: mobile
            ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _HeroCopy(mobile: true),
                const SizedBox(height: 56),
                const _PremiumHeroImage(mobile: true),
              ])
            : Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Expanded(flex: 5, child: _HeroCopy(mobile: false)),
                const SizedBox(width: 48),
                const Expanded(flex: 4, child: _PremiumHeroImage(mobile: false)),
              ]),
      ),
    );
  }
}

class _HeroCopy extends StatelessWidget {
  final bool mobile;
  const _HeroCopy({required this.mobile});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tag
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: kGreen.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(9999),
            border: Border.all(color: kGreen.withValues(alpha: 0.3)),
          ),
          child: const Text('Africa\'s All-in-One Money App',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: kGreen, letterSpacing: 0.1)),
        ),
        const SizedBox(height: 24),

        // Headline
        Text.rich(
          TextSpan(children: [
            TextSpan(
              text: 'Send. Get Paid.\n',
              style: TextStyle(
                fontSize: mobile ? 44 : 60,
                fontWeight: FontWeight.w900,
                color: kInkSoft,
                letterSpacing: -2.5,
                height: 1.05,
              ),
            ),
            TextSpan(
              text: 'Grow.',
              style: TextStyle(
                fontSize: mobile ? 44 : 60,
                fontWeight: FontWeight.w900,
                color: kGreen,
                letterSpacing: -2.5,
                height: 1.05,
              ),
            ),
          ]),
        ),
        const SizedBox(height: 20),

        // Subtext
        const Text(
          'For sellers, freelancers, and everyday Africans.\nElumoPay handles payments, receipts, tax, and debt collection — automatically.',
          style: TextStyle(
            fontSize: 16,
            height: 1.7,
            color: kMuted,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 36),

        // CTAs
        Wrap(spacing: 12, runSpacing: 12, children: const [
          _Btn('Get Started for Free', kBlue, Colors.white),
          _GhostBtn('Watch Demo'),
        ]),
        const SizedBox(height: 40),

        // Social proof row
        Row(children: [
          const _AvatarStack(),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('12,000+ waitlisters',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kInkSoft)),
              Text('across Nigeria, Kenya, Ghana & SA',
                  style: TextStyle(fontSize: 12, color: kMuted)),
            ],
          ),
        ]),
      ],
    );
  }
}

class _GhostBtn extends StatefulWidget {
  final String label;
  const _GhostBtn(this.label);
  @override
  State<_GhostBtn> createState() => _GhostBtnState();
}

class _GhostBtnState extends State<_GhostBtn> {
  bool _hov = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hov = true),
      onExit:  (_) => setState(() => _hov = false),
      child: GestureDetector(
        onTap: () {},
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          decoration: BoxDecoration(
            color: _hov ? Colors.black.withValues(alpha: 0.04) : Colors.transparent,
            border: Border.all(color: kBorder),
            borderRadius: BorderRadius.circular(9999),
          ),
          alignment: Alignment.center,
          child: Row(mainAxisSize: MainAxisSize.min, children: const [
            Icon(Icons.play_circle_rounded, color: kMuted, size: 18),
            SizedBox(width: 6),
            Text('Watch Demo', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kInkSoft)),
          ]),
        ),
      ),
    );
  }
}

class _AvatarStack extends StatelessWidget {
  const _AvatarStack();
  @override
  Widget build(BuildContext context) {
    const colors = [Color(0xFF2563EB), Color(0xFF00C16A), Color(0xFFF59E0B), Color(0xFF8B5CF6)];
    const initials = ['A', 'K', 'O', 'F'];
    return SizedBox(
      width: 70,
      height: 30,
      child: Stack(
        children: List.generate(4, (i) => Positioned(
          left: i * 15.0,
          child: Container(
            width: 30, height: 30,
            decoration: BoxDecoration(
              color: colors[i],
              shape: BoxShape.circle,
              border: Border.all(color: kCanvas, width: 2),
            ),
            alignment: Alignment.center,
            child: Text(initials[i],
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
          ),
        )),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// PREMIUM HERO IMAGE COMPOSITION
// ─────────────────────────────────────────────────────────────
class _PremiumHeroImage extends StatelessWidget {
  final bool mobile;
  const _PremiumHeroImage({required this.mobile});

  @override
  Widget build(BuildContext context) {
    const double compositionH = 640.0;
    const double photoW       = 320.0;
    const double phoneScale   = 0.95;

    return SizedBox(
      width: double.infinity,
      height: mobile ? 520 : compositionH,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // ── Person photo card (left, behind) ──
          Positioned(
            left: mobile ? 0 : -20,
            top: mobile ? 20 : 20,
            bottom: mobile ? 60 : 40,
            child: Container(
              width: mobile ? 220 : photoW,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(color: kGreen.withValues(alpha: 0.1), blurRadius: 60, spreadRadius: 10),
                  BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 40, offset: const Offset(0, 16)),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                'hero_person.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: kBorder),
              ),
            ),
          ),

          // ── Phone mockup (right, in front) ──
          Positioned(
            right: mobile ? -10 : 0,
            top: mobile ? 0 : 40,
            bottom: mobile ? 20 : 0,
            child: Transform.scale(
              scale: mobile ? 0.75 : phoneScale,
              alignment: Alignment.centerRight,
              child: const _PhoneMockup(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// PHONE MOCKUP
// ─────────────────────────────────────────────────────────────
class _PhoneMockup extends StatelessWidget {
  const _PhoneMockup();

  @override
  Widget build(BuildContext context) {
    const double w = 288;
    const double h = 580;
    const double r = 44.0;

    return SizedBox(
      width: w + 12,
      height: h + 12,
      child: Stack(alignment: Alignment.center, children: [
        // Shadow
        Container(
          width: w, height: h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(r),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 80, spreadRadius: 8, offset: const Offset(0, 28)),
              BoxShadow(color: kGreen.withValues(alpha: 0.15), blurRadius: 60, offset: const Offset(0, 20)),
            ],
          ),
        ),
        // Left buttons
        Positioned(
          left: 0, top: 120,
          child: Column(children: [
            _SideBtn(32), const SizedBox(height: 12),
            _SideBtn(42), const SizedBox(height: 10),
            _SideBtn(42),
          ]),
        ),
        // Right button
        Positioned(right: 0, top: 150, child: _SideBtn(60)),
        // Chassis
        Container(
          width: w, height: h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(r),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF5A5A5F), Color(0xFF2C2C2E), Color(0xFF4A4A52), Color(0xFF1C1C1E)],
              stops: [0, 0.3, 0.7, 1],
            ),
          ),
        ),
        // Screen
        Positioned(
          top: 5, left: 5, right: 5, bottom: 5,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(r - 5),
              color: const Color(0xFF060A14),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(children: [
              const _AppScreen(),
              // Glass sheen
              Positioned(
                top: 0, left: 0, right: 0,
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white.withValues(alpha: 0.06), Colors.transparent],
                    ),
                  ),
                ),
              ),
              // Dynamic Island
              Positioned(
                top: 12, left: 0, right: 0,
                child: Center(
                  child: Container(
                    width: 100, height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFF060A14),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFF1E2030), width: 1.5),
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(width: 9, height: 9, decoration: BoxDecoration(color: const Color(0xFF1A1A1E), shape: BoxShape.circle, border: Border.all(color: const Color(0xFF333340), width: 1))),
                      const SizedBox(width: 5),
                      Container(width: 5, height: 5, decoration: const BoxDecoration(color: Color(0xFF252530), shape: BoxShape.circle)),
                    ]),
                  ),
                ),
              ),
              // Home bar
              Positioned(
                bottom: 7, left: 0, right: 0,
                child: Center(
                  child: Container(
                    width: 110, height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _SideBtn extends StatelessWidget {
  final double h;
  const _SideBtn(this.h);
  @override
  Widget build(BuildContext context) => Container(
    width: 4, height: h,
    decoration: BoxDecoration(
      color: const Color(0xFF48484A),
      borderRadius: BorderRadius.circular(3),
    ),
  );
}

// ─────────────────────────────────────────────────────────────
// APP SCREEN CONTENT
// ─────────────────────────────────────────────────────────────
class _AppScreen extends StatelessWidget {
  const _AppScreen();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF060A14),
      padding: const EdgeInsets.fromLTRB(18, 56, 18, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Greeting row
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            Text('Good morning,', style: TextStyle(color: Color(0xFF475569), fontSize: 10, fontWeight: FontWeight.w500)),
            SizedBox(height: 1),
            Text('Adebayo', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: -0.4)),
          ]),
          Container(
            width: 34, height: 34,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [kGreen, Color(0xFF00A86B)]),
            ),
            alignment: Alignment.center,
            child: const Text('A', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
          ),
        ]),
        const SizedBox(height: 16),

        // Balance card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF006D44), Color(0xFF00A86B), Color(0xFF003D26)],
              stops: [0, 0.5, 1],
            ),
            boxShadow: [BoxShadow(color: kGreen.withValues(alpha: 0.35), blurRadius: 18, offset: const Offset(0, 8))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [
              Text('Total Revenue', style: TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 0.4)),
              Text('EP', style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
            ]),
            const SizedBox(height: 6),
            const Text('₦2,847,500', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.8)),
            const SizedBox(height: 6),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                child: const Text('+18.4%', style: TextStyle(color: Color(0xFF6DFCB3), fontSize: 9, fontWeight: FontWeight.w800)),
              ),
              const SizedBox(width: 5),
              const Text('vs last month', style: TextStyle(color: Colors.white38, fontSize: 9)),
            ]),
          ]),
        ),
        const SizedBox(height: 12),

        // Quick actions row
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _QuickAction(Icons.send_rounded, 'Send'),
          _QuickAction(Icons.south_west_rounded, 'Receive'),
          _QuickAction(Icons.receipt_long_rounded, 'Invoice'),
          _QuickAction(Icons.account_balance_rounded, 'Tax'),
        ]),
        const SizedBox(height: 14),

        // Transactions
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [
          Text('Transactions', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
          Text('See all', style: TextStyle(color: kGreen, fontSize: 10, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 10),
        _Txn('Sarah Okafor', 'Payment received', '+₦85,000', true),
        const SizedBox(height: 8),
        _Txn('Chukwuemeka Ltd', 'Instalment #2/4', '+₦45,000', true),
        const SizedBox(height: 8),
        _Txn('FIRS - VAT Q3', 'Tax remittance', '-₦12,500', false),
      ]),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  const _QuickAction(this.icon, this.label);
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        width: 42, height: 42,
        decoration: BoxDecoration(color: const Color(0xFF0F1929), borderRadius: BorderRadius.circular(13), border: Border.all(color: const Color(0xFF1E2A3A))),
        child: Icon(icon, color: kGreen, size: 18),
      ),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(color: Color(0xFF475569), fontSize: 9, fontWeight: FontWeight.w600)),
    ]);
  }
}

class _Txn extends StatelessWidget {
  final String name, desc, amt;
  final bool pos;
  const _Txn(this.name, this.desc, this.amt, this.pos);
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 30, height: 30,
        decoration: BoxDecoration(
          color: pos ? kGreen.withValues(alpha: 0.1) : kAmber.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(pos ? Icons.south_west_rounded : Icons.north_east_rounded,
            color: pos ? kGreen : kAmber, size: 14),
      ),
      const SizedBox(width: 8),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
        Text(desc, style: const TextStyle(color: Color(0xFF374151), fontSize: 9)),
      ])),
      Text(amt, style: TextStyle(color: pos ? kGreen : const Color(0xFFF87171), fontSize: 10, fontWeight: FontWeight.w800)),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────
// STATS BAR
// ─────────────────────────────────────────────────────────────
class _StatsBar extends StatelessWidget {
  const _StatsBar();

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.of(context).size.width < 700;
    return Container(
      color: kInkSoft,
      padding: EdgeInsets.symmetric(horizontal: mobile ? 24 : 64, vertical: 28),
      child: Wrap(
        alignment: WrapAlignment.spaceAround,
        runSpacing: 20,
        spacing: 40,
        children: const [
          _Stat('₦2.8B+', 'Processed monthly'),
          _Stat('12,000+', 'Active users'),
          _Stat('4', 'African markets'),
          _Stat('97%', 'Reconciliation accuracy'),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value, label;
  const _Stat(this.value, this.label);
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: kGreen, letterSpacing: -0.8)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), fontWeight: FontWeight.w500)),
    ],
  );
}

// ─────────────────────────────────────────────────────────────
// FOR EVERYONE SECTION
// ─────────────────────────────────────────────────────────────
class _ForEveryoneSection extends StatelessWidget {
  const _ForEveryoneSection();

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.of(context).size.width < 860;
    return Container(
      color: kCanvas,
      padding: EdgeInsets.symmetric(horizontal: mobile ? 24 : 64, vertical: 88),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(children: [
          // Header
          const Text('Built for everyone in Africa',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: kInkSoft, letterSpacing: -1.2, height: 1.1)),
          const SizedBox(height: 12),
          const Text('Whether you\'re running a market stall or managing payroll — ElumoPay has you covered.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: kMuted, height: 1.6)),
          const SizedBox(height: 64),

          // Two columns
          mobile
              ? Column(children: [
                  _AudienceCard(
                    tag: 'For Sellers & Businesses',
                    tagColor: kBlue,
                    tagBg: kBlueLight,
                    title: 'Get paid on your terms',
                    subtitle: 'Send invoices, track installments, trigger AI voice reminders for overdue payments, and reconcile your books automatically.',
                    features: const ['Smart invoice generation', 'Installment ledger tracking', 'AI debt collection calls', 'Multi-currency tax filing'],
                    accentColor: kBlue,
                  ),
                  const SizedBox(height: 24),
                  _AudienceCard(
                    tag: 'For Individuals',
                    tagColor: kGreenDark,
                    tagBg: kGreenLight,
                    title: 'Your money, smarter',
                    subtitle: 'Send money instantly, pay bills, split costs with friends, and track every naira — all with AI spending insights.',
                    features: const ['Instant money transfers', 'Bill payments & airtime', 'Spending tracker & budgets', 'Virtual & physical cards'],
                    accentColor: kGreen,
                  ),
                ])
              : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: _AudienceCard(
                    tag: 'For Sellers & Businesses',
                    tagColor: kBlue,
                    tagBg: kBlueLight,
                    title: 'Get paid on your terms',
                    subtitle: 'Send invoices, track installments, trigger AI voice reminders for overdue payments, and reconcile your books automatically.',
                    features: const ['Smart invoice generation', 'Installment ledger tracking', 'AI debt collection calls', 'Multi-currency tax filing'],
                    accentColor: kBlue,
                  )),
                  const SizedBox(width: 24),
                  Expanded(child: _AudienceCard(
                    tag: 'For Individuals',
                    tagColor: kGreenDark,
                    tagBg: kGreenLight,
                    title: 'Your money, smarter',
                    subtitle: 'Send money instantly, pay bills, split costs with friends, and track every naira — all with AI spending insights.',
                    features: const ['Instant money transfers', 'Bill payments & airtime', 'Spending tracker & budgets', 'Virtual & physical cards'],
                    accentColor: kGreen,
                  )),
                ]),
        ]),
      ),
    );
  }
}

class _AudienceCard extends StatelessWidget {
  final String tag, title, subtitle;
  final Color tagColor, tagBg, accentColor;
  final List<String> features;
  const _AudienceCard({
    required this.tag, required this.title, required this.subtitle,
    required this.tagColor, required this.tagBg, required this.accentColor,
    required this.features,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorder),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: tagBg, borderRadius: BorderRadius.circular(9999)),
          child: Text(tag, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: tagColor)),
        ),
        const SizedBox(height: 20),
        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: kInkSoft, letterSpacing: -0.5, height: 1.2)),
        const SizedBox(height: 12),
        Text(subtitle, style: const TextStyle(fontSize: 14, color: kMuted, height: 1.65)),
        const SizedBox(height: 28),
        ...features.map((f) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(children: [
            Container(
              width: 20, height: 20,
              decoration: BoxDecoration(color: accentColor.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(Icons.check_rounded, color: accentColor, size: 13),
            ),
            const SizedBox(width: 10),
            Text(f, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kInkSoft)),
          ]),
        )),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// AI SECTION
// ─────────────────────────────────────────────────────────────
class _AISection extends StatelessWidget {
  const _AISection();

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.of(context).size.width < 860;
    return Container(
      color: kInk,
      padding: EdgeInsets.symmetric(horizontal: mobile ? 24 : 64, vertical: 88),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(color: kGreen.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(9999), border: Border.all(color: kGreen.withValues(alpha: 0.25))),
            child: const Text('Powered by Google Gemini', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kGreen)),
          ),
          const SizedBox(height: 20),
          const Text('AI does the work for you',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1.2)),
          const SizedBox(height: 12),
          const Text('Stop chasing customers. Stop doing manual bookkeeping. ElumoPay\'s AI layer handles it.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Color(0xFF6B7280), height: 1.6)),
          const SizedBox(height: 56),
          mobile
              ? Column(children: [
                  _AICard(Icons.auto_awesome_rounded, 'Gemini Reconciliation', 'Automatically matches bank transfers to invoices — even with fuzzy names or wrong amounts.'),
                  const SizedBox(height: 16),
                  _AICard(Icons.record_voice_over_rounded, 'AI Voice Reminders', 'Sends automated voice calls in local accents to gently remind debtors of outstanding payments.'),
                  const SizedBox(height: 16),
                  _AICard(Icons.chat_bubble_outline_rounded, 'Natural Language Invoicing', '"Bill Amaka ₦150k for branding" — ElumoPay creates and sends the invoice instantly.'),
                ])
              : Row(children: [
                  Expanded(child: _AICard(Icons.auto_awesome_rounded, 'Gemini Reconciliation', 'Automatically matches bank transfers to invoices — even with fuzzy names or wrong amounts.')),
                  const SizedBox(width: 20),
                  Expanded(child: _AICard(Icons.record_voice_over_rounded, 'AI Voice Reminders', 'Sends automated voice calls in local accents to gently remind debtors of outstanding payments.')),
                  const SizedBox(width: 20),
                  Expanded(child: _AICard(Icons.chat_bubble_outline_rounded, 'Natural Language Invoicing', '"Bill Amaka ₦150k for branding" — ElumoPay creates and sends the invoice instantly.')),
                ]),
        ]),
      ),
    );
  }
}

class _AICard extends StatelessWidget {
  final IconData icon;
  final String title, body;
  const _AICard(this.icon, this.title, this.body);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1929),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E2A3A)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: kGreen.withValues(alpha: 0.12), shape: BoxShape.circle),
          child: Icon(icon, color: kGreen, size: 22),
        ),
        const SizedBox(height: 18),
        Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.3)),
        const SizedBox(height: 10),
        Text(body, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.65)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// COMPLIANCE SECTION
// ─────────────────────────────────────────────────────────────
class _ComplianceSection extends StatelessWidget {
  const _ComplianceSection();

  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.of(context).size.width < 860;
    return Container(
      color: kCanvas,
      padding: EdgeInsets.symmetric(horizontal: mobile ? 24 : 64, vertical: 88),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: mobile
            ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _ComplianceText(),
                const SizedBox(height: 48),
                _ComplianceCard(),
              ])
            : Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Expanded(child: _ComplianceText()),
                const SizedBox(width: 64),
                Expanded(child: _ComplianceCard()),
              ]),
      ),
    );
  }
}

class _ComplianceText extends StatelessWidget {
  const _ComplianceText();
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: kGreenLight, borderRadius: BorderRadius.circular(9999)),
        child: const Text('Tax & Compliance', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: kGreenDark)),
      ),
      const SizedBox(height: 20),
      const Text('Compliance built-in.\nNo accountant needed.',
          style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: kInkSoft, letterSpacing: -1.2, height: 1.15)),
      const SizedBox(height: 16),
      const Text('ElumoPay auto-calculates VAT and Withholding Tax for your jurisdiction, and files directly to the tax authority.',
          style: TextStyle(fontSize: 15, color: kMuted, height: 1.65)),
      const SizedBox(height: 32),
      Wrap(spacing: 16, runSpacing: 14, children: const [
        _CheckItem('Nigeria · FIRS'),
        _CheckItem('Kenya · KRA'),
        _CheckItem('Ghana · GRA'),
        _CheckItem('South Africa · SARS'),
      ]),
    ]);
  }
}

class _CheckItem extends StatelessWidget {
  final String label;
  const _CheckItem(this.label);
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    const Icon(Icons.check_circle_rounded, color: kGreen, size: 18),
    const SizedBox(width: 8),
    Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kInkSoft)),
  ]);
}

class _ComplianceCard extends StatelessWidget {
  const _ComplianceCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: kInk,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorderDark),
        boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 32, offset: Offset(0, 12))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Q3 Tax Remittance', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: kGreen.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(9999)),
            child: Row(children: const [
              Icon(Icons.check_circle_rounded, color: kGreen, size: 12),
              SizedBox(width: 4),
              Text('Filed', style: TextStyle(color: kGreen, fontSize: 11, fontWeight: FontWeight.w700)),
            ]),
          ),
        ]),
        const Divider(color: Color(0xFF1F2937), height: 32),
        _TaxRow('Value Added Tax (VAT) 7.5%', '₦318,750'),
        const SizedBox(height: 14),
        _TaxRow('Withholding Tax (WHT) 2.5%', '₦71,188'),
        const SizedBox(height: 20),
        ClipRRect(
          borderRadius: BorderRadius.circular(9999),
          child: const LinearProgressIndicator(value: 1, minHeight: 8, backgroundColor: Color(0xFF1F2937), valueColor: AlwaysStoppedAnimation<Color>(kGreen)),
        ),
        const SizedBox(height: 14),
        const Text('Auto-calculated & filed · Oct 15, 2024',
            style: TextStyle(color: Color(0xFF4B5563), fontSize: 12)),
      ]),
    );
  }
}

class _TaxRow extends StatelessWidget {
  final String label, amount;
  const _TaxRow(this.label, this.amount);
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13)),
      Text(amount, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
    ],
  );
}

// ─────────────────────────────────────────────────────────────
// CTA BANNER
// ─────────────────────────────────────────────────────────────
class _CtaBanner extends StatelessWidget {
  const _CtaBanner();
  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.of(context).size.width < 700;
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF004D32), Color(0xFF006D44), Color(0xFF00A86B)],
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: mobile ? 24 : 64, vertical: 72),
      child: Column(children: [
        Text(
          'ElumoPay — Get paid without the chase.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: mobile ? 28 : 40, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1.2, height: 1.15),
        ),
        const SizedBox(height: 16),
        const Text(
          'Join thousands of Africans running smarter businesses.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Color(0xAAFFFFFF), height: 1.6),
        ),
        const SizedBox(height: 36),
        const _Btn('Create Your Free Account', Colors.white, kGreenDark),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// FOOTER
// ─────────────────────────────────────────────────────────────
class _Footer extends StatelessWidget {
  const _Footer();
  @override
  Widget build(BuildContext context) {
    final mobile = MediaQuery.of(context).size.width < 700;
    return Container(
      color: kInk,
      padding: EdgeInsets.symmetric(horizontal: mobile ? 24 : 64, vertical: 56),
      child: Column(children: [
        mobile
            ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _FooterBrand(),
                const SizedBox(height: 40),
                Wrap(spacing: 40, runSpacing: 28, children: const [
                  _FooterCol('Product', ['Payments', 'Corporate Cards', 'Tax Filing', 'API Docs']),
                  _FooterCol('Company', ['About Us', 'Careers', 'Blog', 'Press']),
                  _FooterCol('Legal', ['Privacy Policy', 'Terms of Service', 'Compliance']),
                  _FooterCol('Support', ['Help Center', 'Contact Us', 'Status']),
                ]),
              ])
            : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(flex: 2, child: _FooterBrand()),
                const Expanded(child: _FooterCol('Product', ['Payments', 'Corporate Cards', 'Tax Filing', 'API Docs'])),
                const Expanded(child: _FooterCol('Company', ['About Us', 'Careers', 'Blog', 'Press'])),
                const Expanded(child: _FooterCol('Legal', ['Privacy Policy', 'Terms of Service', 'Compliance'])),
                const Expanded(child: _FooterCol('Support', ['Help Center', 'Contact Us', 'Status'])),
              ]),
        const SizedBox(height: 48),
        const Divider(color: Color(0xFF1F2937)),
        const SizedBox(height: 20),
        const Text('© 2024 Elumopay Technologies. All rights reserved.',
            style: TextStyle(fontSize: 12, color: Color(0xFF374151))),
      ]),
    );
  }
}

class _FooterBrand extends StatelessWidget {
  const _FooterBrand();
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(mainAxisSize: MainAxisSize.min, children: const [
        NautikLogoMark(size: 28),
        SizedBox(width: 8),
        Text('ElumoPay', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white)),
      ]),
      const SizedBox(height: 12),
      const SizedBox(
        width: 220,
        child: Text('The all-in-one money platform for Africa. Send. Get Paid. Grow.',
            style: TextStyle(fontSize: 12, color: Color(0xFF6B7280), height: 1.65)),
      ),
    ],
  );
}

class _FooterCol extends StatelessWidget {
  final String heading;
  final List<String> links;
  const _FooterCol(this.heading, this.links);
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(heading, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
      const SizedBox(height: 14),
      ...links.map((l) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(l, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), fontWeight: FontWeight.w500)),
      )),
    ],
  );
}
