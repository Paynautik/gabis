import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Shared visual language for the Gabis landing page.
/// Matches the V2 hero so every section feels like the same product.
class LandingUi {
  static const canvas = Color(0xFFF7F8FC);
  static const card = Colors.white;
  static const border = Color(0xFFE8EBF2);
  static const ink = Color(0xFF0D1830);
  static const inkSoft = Color(0xFF667385);
  static const accent = Color(0xFF2F4BFF);
  static const accentDark = Color(0xFF2439CF);
  static const accentSoft = Color(0xFFEEF1FF);

  static const radius = 22.0;

  static BoxDecoration softCard({Color? color, double? r}) => BoxDecoration(
        color: color ?? card,
        borderRadius: BorderRadius.circular(r ?? radius),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: ink.withValues(alpha: 0.045),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      );
}

class SectionHeading extends StatelessWidget {
  final String? eyebrow;
  final String title;
  final String? circled;
  final String? subtitle;
  final double titleSize;
  final Color accent;

  const SectionHeading({
    super.key,
    this.eyebrow,
    required this.title,
    this.circled,
    this.subtitle,
    this.titleSize = 36,
    this.accent = LandingUi.accent,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final effectiveTitleSize = width < 600 ? titleSize * .84 : titleSize;
    final titleStyle = TextStyle(
      fontSize: effectiveTitleSize,
      fontWeight: FontWeight.w900,
      color: LandingUi.ink,
      letterSpacing: -1.15,
      height: 1.12,
    );

    return Column(
      children: [
        if (eyebrow != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: LandingUi.accentSoft,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              eyebrow!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
                color: accent,
              ),
            ),
          ),
          const SizedBox(height: 14),
        ],
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(title, textAlign: TextAlign.center, style: titleStyle),
            if (circled != null)
              Padding(
                padding: const EdgeInsets.only(left: 9),
                child: _CircledWord(
                  text: circled!,
                  style: titleStyle,
                  color: accent,
                ),
              ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 15),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15.5,
                height: 1.55,
                color: LandingUi.inkSoft,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _CircledWord extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color color;

  const _CircledWord({
    required this.text,
    required this.style,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _HandCirclePainter(color: color),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(text, style: style.copyWith(color: color)),
      ),
    );
  }
}

class _HandCirclePainter extends CustomPainter {
  final Color color;

  const _HandCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: .88)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.1
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final rx = size.width / 2 + 2;
    final ry = size.height / 2 + 1;
    final path = Path();

    const start = -.35;
    const sweep = math.pi * 2 + .48;
    const steps = 60;

    for (var i = 0; i <= steps; i++) {
      final t = start + sweep * (i / steps);
      final wobble = 1 + .012 * math.sin(t * 3);
      final x = cx + rx * wobble * math.cos(t);
      final y = cy + ry * wobble * math.sin(t) * 1.06;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_HandCirclePainter oldDelegate) =>
      oldDelegate.color != color;
}
