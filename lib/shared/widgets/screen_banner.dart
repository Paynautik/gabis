import 'package:flutter/material.dart';

import '../../features/business/business_persistence_stub.dart'
    if (dart.library.js_interop) '../../features/business/business_persistence_web.dart';

/// What one screen's header banner says.
class BannerSpec {
  final String eyebrow;
  final String title;
  final String body;
  final String image;
  final Color tint;
  final Alignment focus;

  const BannerSpec({
    required this.eyebrow,
    required this.title,
    required this.body,
    required this.image,
    this.tint = const Color(0xFF16123A),
    this.focus = Alignment.center,
  });
}

/// The banner for each sidebar screen, keyed by HomeTab index.
const screenBanners = <int, BannerSpec>{
  9: BannerSpec(
      eyebrow: 'COPILOT',
      title: 'Ask your money anything.',
      body: 'Answers come from your own transactions: what is recurring, what changed, what you can safely spend.',
      image: 'assets/images/usecase_creators.jpg',
      focus: Alignment(0.15, -0.55)),
  11: BannerSpec(
      eyebrow: 'INTELLIGENCE',
      title: 'See payday before it arrives.',
      body: 'Forecasts, goals, autopilot and five agents that flag what needs you.',
      image: 'assets/images/lifestyle_pay_moment.jpg',
      tint: Color(0xFF2B2380)),
  12: BannerSpec(
      eyebrow: 'GLOBAL MONEY',
      title: 'Get paid from anywhere.',
      body: 'Hold USDC, convert to 7 African currencies, and let the FX agent watch the rate.',
      image: 'assets/images/hero_bitso_holding_phone.jpg',
      tint: Color(0xFF0E3B66)),
  1: BannerSpec(
      eyebrow: 'ACCOUNTS',
      title: 'Twelve currencies. One account.',
      body: '7 African and 5 global wallets, each with its own details.',
      image: 'assets/images/hero_person.jpg',
      focus: Alignment(0, -.4)),
  2: BannerSpec(
      eyebrow: 'CARDS',
      title: 'Spend anywhere, stay in control.',
      body: 'Freeze, set limits and see every card payment the moment it happens.',
      image: 'assets/images/gabis_metal_card.jpg'),
  4: BannerSpec(
      eyebrow: 'TRANSACTIONS',
      title: 'Every naira, accounted for.',
      body: 'Search, filter and open a receipt for any payment in or out.',
      image: 'assets/images/testimonial_hero_african.jpg',
      focus: Alignment(0, -.3)),
  5: BannerSpec(
      eyebrow: 'ANALYTICS',
      title: 'Know where it goes.',
      body: 'Spending by category, month on month, from your real history.',
      image: 'assets/images/african_person_mockup.jpg',
      tint: Color(0xFF2B2380),
      focus: Alignment(0, -0.65)),
  6: BannerSpec(
      eyebrow: 'BENEFICIARIES',
      title: 'The people you pay, in one place.',
      body: 'Saved details, so family, staff and suppliers are one tap away.',
      image: 'assets/images/cta_hero_cozy_african.jpg'),
  10: BannerSpec(
      eyebrow: 'COMMUNITY & TRUST',
      title: 'Save together. Trade safely.',
      body: 'Ajo circles with reminders and payouts, and escrow where both sides sign.',
      image: 'assets/images/tailor.jpg',
      tint: Color(0xFF3B2A1A)),
  7: BannerSpec(
      eyebrow: 'SETTINGS',
      title: 'Your account, your rules.',
      body: 'Security, notifications, demo data and how gabis talks to you.',
      image: 'assets/images/photog.jpg',
      focus: Alignment(0, -.3)),
  8: BannerSpec(
      eyebrow: 'SUPPORT',
      title: 'How can we help you?',
      body: 'Our 24/7 dedicated fintech support is ready, over chat, email or WhatsApp.',
      image: 'assets/images/testimonial_hero_african_prev.jpg',
      tint: Color(0xFF0B4D34)),
};

/// A screen with its banner on top. The banner can be closed, and stays
/// closed for that screen on this device.
class BannerFrame extends StatefulWidget {
  final int tab;
  final Widget child;
  const BannerFrame({super.key, required this.tab, required this.child});

  @override
  State<BannerFrame> createState() => _BannerFrameState();
}

class _BannerFrameState extends State<BannerFrame> {
  String get _key => 'gabis.banner.hidden.${widget.tab}';
  late bool _hidden = readRaw(_key) == '1';

  @override
  Widget build(BuildContext context) {
    final spec = screenBanners[widget.tab];
    if (spec == null || _hidden) return widget.child;
    return Column(children: [
      ScreenBanner(
        spec: spec,
        onClose: () {
          writeRaw(_key, '1');
          setState(() => _hidden = true);
        },
      ),
      Expanded(child: widget.child),
    ]);
  }
}

class ScreenBanner extends StatelessWidget {
  final BannerSpec spec;
  final VoidCallback? onClose;
  const ScreenBanner({super.key, required this.spec, this.onClose});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      final wide = box.maxWidth > 640;
      final height = wide ? 164.0 : 128.0;
      final text = Padding(
        padding: EdgeInsets.fromLTRB(wide ? 28 : 18, 0, wide ? 20 : 44, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(spec.eyebrow,
                style: const TextStyle(color: Color(0xFFDFF76A), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.4)),
            const SizedBox(height: 6),
            Text(spec.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.white, fontSize: wide ? 24 : 19, fontWeight: FontWeight.w900, height: 1.1, letterSpacing: -.5)),
            const SizedBox(height: 6),
            Text(spec.body,
                maxLines: wide ? 2 : 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.white.withValues(alpha: .78), fontSize: wide ? 13.5 : 12, height: 1.4)),
          ],
        ),
      );
      final photo = Image.asset(spec.image, fit: BoxFit.cover, alignment: spec.focus, errorBuilder: (_, _, _) => const SizedBox());

      return Padding(
        padding: EdgeInsets.fromLTRB(wide ? 20 : 14, 12, wide ? 20 : 14, 4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: SizedBox(
            height: height,
            child: Stack(children: [
              Positioned.fill(child: ColoredBox(color: spec.tint)),
              if (wide)
                Positioned(top: 0, bottom: 0, right: 0, width: box.maxWidth * .38, child: photo)
              else
                Positioned.fill(child: photo),
              // Fade the photo into the colour so the text always reads.
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      stops: wide ? const [.6, .8] : const [.35, 1],
                      colors: wide
                          ? [spec.tint, spec.tint.withValues(alpha: 0)]
                          : [spec.tint.withValues(alpha: .95), spec.tint.withValues(alpha: .55)],
                    ),
                  ),
                ),
              ),
              Positioned.fill(child: Align(alignment: Alignment.centerLeft, child: SizedBox(width: wide ? box.maxWidth * .62 : box.maxWidth, child: text))),
              if (onClose != null)
                Positioned(
                  top: 6,
                  right: 6,
                  child: IconButton(
                    tooltip: 'Hide banner',
                    onPressed: onClose,
                    icon: const Icon(Icons.close_rounded, size: 18, color: Colors.white),
                    style: IconButton.styleFrom(backgroundColor: Colors.black.withValues(alpha: .25)),
                  ),
                ),
            ]),
          ),
        ),
      );
    });
  }
}
