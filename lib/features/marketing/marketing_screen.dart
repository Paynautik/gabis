import 'package:flutter/material.dart';

import '../landing/gabis_landing_v3.dart';
import 'marketing_content.dart';

/// One renderer for every footer destination: hero, proof strip, feature grid,
/// long-form sections, FAQ, CTA — then the same nav and footer as the landing
/// page, so a visitor never lands somewhere that feels like a different site.
class MarketingScreen extends StatelessWidget {
  final MarketingPage page;

  const MarketingScreen({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GabisV3.cream,
      body: LayoutBuilder(
        builder: (context, c) {
          final width = c.maxWidth;
          final desktop = width >= 940;
          final side = GabisV3.side(width);

          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(side, 18, side, 0),
                  child: const GabisNav(),
                ),
                _hero(context, desktop, side),
                if (page.features.isNotEmpty) _features(desktop, side),
                if (page.sections.isNotEmpty) _sections(desktop, side),
                if (page.faqs.isNotEmpty) _faqs(desktop, side),
                _cta(context, desktop, side),
                const GabisFooter(),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── hero ──────────────────────────────────────────────────────────────
  Widget _hero(BuildContext context, bool desktop, double side) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(side, desktop ? 64 : 44, side, desktop ? 56 : 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Crumb(eyebrow: page.eyebrow),
              const SizedBox(height: 20),
              Text(
                page.title,
                style: TextStyle(
                  fontSize: desktop ? 60 : 38,
                  height: .96,
                  letterSpacing: desktop ? -2.8 : -1.6,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 20),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Text(
                  page.lede,
                  style: TextStyle(
                    fontSize: desktop ? 18 : 16,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                    color: GabisV3.ink.withValues(alpha: .74),
                  ),
                ),
              ),
              if (page.highlights.isNotEmpty) ...[
                const SizedBox(height: 26),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final h in page.highlights)
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                        decoration: BoxDecoration(
                          color: GabisV3.lime,
                          border: Border.all(color: GabisV3.ink, width: 1.2),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(h,
                            style: const TextStyle(
                                fontSize: 12.5, fontWeight: FontWeight.w800)),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 30),
              _PrimaryButton(
                label: 'Open your account',
                onTap: () => Navigator.pushNamed(context, '/login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── feature grid ──────────────────────────────────────────────────────
  Widget _features(bool desktop, double side) {
    const palette = [GabisV3.sky, GabisV3.lilac, GabisV3.lime, GabisV3.coral];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(side, 0, side, desktop ? 20 : 12),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: LayoutBuilder(
            builder: (context, c) {
              final columns = c.maxWidth >= 900 ? 2 : 1;
              final cardWidth =
                  (c.maxWidth - (columns - 1) * 14) / columns;
              return Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  for (var i = 0; i < page.features.length; i++)
                    SizedBox(
                      width: cardWidth,
                      child: _FeatureCard(
                        feature: page.features[i],
                        colour: palette[i % palette.length],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ── prose ─────────────────────────────────────────────────────────────
  Widget _sections(bool desktop, double side) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(side, desktop ? 40 : 30, side, 10),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final section in page.sections)
                Padding(
                  padding: const EdgeInsets.only(bottom: 26),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(section.heading,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -.7)),
                      const SizedBox(height: 9),
                      Text(section.body,
                          style: TextStyle(
                            fontSize: 15.5,
                            height: 1.65,
                            fontWeight: FontWeight.w500,
                            color: GabisV3.ink.withValues(alpha: .76),
                          )),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── faq ───────────────────────────────────────────────────────────────
  Widget _faqs(bool desktop, double side) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(side, desktop ? 46 : 34, side, 10),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('FREQUENTLY ASKED',
                  style: TextStyle(
                    fontSize: 10.5,
                    letterSpacing: 1.6,
                    fontWeight: FontWeight.w900,
                    color: GabisV3.ink.withValues(alpha: .45),
                  )),
              const SizedBox(height: 16),
              for (final faq in page.faqs) _FaqTile(faq: faq),
            ],
          ),
        ),
      ),
    );
  }

  // ── closing cta ───────────────────────────────────────────────────────
  Widget _cta(BuildContext context, bool desktop, double side) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(side, desktop ? 56 : 42, side, desktop ? 64 : 48),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(desktop ? 40 : 26),
            decoration: BoxDecoration(
              color: GabisV3.ink,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(page.ctaTitle,
                    style: TextStyle(
                      color: GabisV3.cream,
                      fontSize: desktop ? 34 : 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.2,
                    )),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: Text(page.ctaBody,
                      style: TextStyle(
                        color: GabisV3.cream.withValues(alpha: .72),
                        fontSize: 15.5,
                        height: 1.55,
                      )),
                ),
                const SizedBox(height: 22),
                Wrap(spacing: 12, runSpacing: 12, children: [
                  _PrimaryButton(
                    label: 'Open your account',
                    onTap: () => Navigator.pushNamed(context, '/login'),
                    light: true,
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.popUntil(context, (r) => r.isFirst),
                    child: Text('Back to home',
                        style: TextStyle(
                            color: GabisV3.cream.withValues(alpha: .8),
                            fontWeight: FontWeight.w700)),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Crumb extends StatelessWidget {
  final String eyebrow;
  const _Crumb({required this.eyebrow});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => Navigator.popUntil(context, (r) => r.isFirst),
            child: Opacity(
              opacity: .55,
              child: Image.asset('assets/gabis_logo.png', height: 16, fit: BoxFit.contain, semanticLabel: 'gabis'),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text('/',
              style: TextStyle(
                  fontSize: 11.5, color: GabisV3.ink.withValues(alpha: .3))),
        ),
        Text(eyebrow.toUpperCase(),
            style: const TextStyle(
                fontSize: 11.5, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final MarketingFeature feature;
  final Color colour;

  const _FeatureCard({required this.feature, required this.colour});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: BoxDecoration(
        color: colour,
        border: Border.all(color: GabisV3.ink, width: 1.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(feature.icon, size: 20),
          const SizedBox(height: 14),
          Text(feature.title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.6,
                  height: 1.15)),
          const SizedBox(height: 8),
          Text(feature.body,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.5,
                fontWeight: FontWeight.w500,
                color: GabisV3.ink.withValues(alpha: .76),
              )),
        ],
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  final MarketingFaq faq;
  const _FaqTile({required this.faq});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: GabisV3.line)),
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => setState(() => _open = !_open),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(widget.faq.question,
                          style: const TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -.4)),
                    ),
                    const SizedBox(width: 14),
                    Icon(_open ? Icons.remove_rounded : Icons.add_rounded, size: 19),
                  ],
                ),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 160),
                  crossFadeState:
                      _open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                  firstChild: const SizedBox(width: double.infinity),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 10, right: 32),
                    child: Text(widget.faq.answer,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          fontWeight: FontWeight.w500,
                          color: GabisV3.ink.withValues(alpha: .74),
                        )),
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

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool light;

  const _PrimaryButton({
    required this.label,
    required this.onTap,
    this.light = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: light ? GabisV3.lime : GabisV3.ink,
        foregroundColor: light ? GabisV3.ink : GabisV3.cream,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
      ),
      child: Text(label,
          style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800)),
    );
  }
}
