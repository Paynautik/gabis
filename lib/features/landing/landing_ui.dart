import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Shared surface + heading language for the landing page.
/// Light neutral canvas, white cards, generous radii, one accent —
/// with a hand-drawn circle flourish on the emphasised word.
class LandingUi {
  static const canvas = Color(0xFFF5F6F8);
  static const card = Colors.white;
  static const border = Color(0xFFEDEFF3);
  static const ink = Color(0xFF0D1830);
  static const inkSoft = Color(0xFF667385);
  static const accent = Color(0xFF2F4BFF);

  static const radius = 22.0;

  static BoxDecoration softCard({Color? color, double? r}) => BoxDecoration(
        color: color ?? card,
        borderRadius: BorderRadius.circular(r ?? radius),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: ink.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      );
}

/// Centred section heading: optional eyebrow, a title whose final phrase can be
/// circled by hand, and an optional supporting line.
class SectionHeading extends StatelessWidget {
  final String? eyebrow;
  final String title;

  /// Trailing phrase drawn with the circle flourish (kept out of [title]).
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
    final titleStyle = TextStyle(
      fontSize: titleSize,
      fontWeight: FontWeight.w800,
      color: LandingUi.ink,
      letterSpacing: -1.1,
      height: 1.15,
    );

    return Column(
      children: [
        if (eyebrow != null) ...[
          Text(
            eyebrow!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.6,
              color: accent,
            ),
          ),
          const SizedBox(height: 12),
        ],
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(title, textAlign: TextAlign.center, style: titleStyle),
            if (circled != null)
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: _CircledWord(
                  text: circled!,
                  style: titleStyle,
                  color: accent,
                ),
              ),
          ],
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
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
        child: Text(text, style: style),
      ),
    );
  }
}

/// A single slightly-imperfect ellipse, the way it looks drawn by hand.
class _HandCirclePainter extends CustomPainter {
  final Color color;
  const _HandCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final rx = size.width / 2 + 2;
    final ry = size.height / 2 + 1;

    final path = Path();
    // Sweep a little past a full turn so the ends overlap, like a pen stroke.
    const start = -0.35;
    const sweep = math.pi * 2 + 0.5;
    const steps = 60;

    for (var i = 0; i <= steps; i++) {
      final t = start + sweep * (i / steps);
      // Gentle wobble so the ring is not mechanically perfect.
      final wobble = 1 + 0.012 * math.sin(t * 3);
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
  bool shouldRepaint(_HandCirclePainter oldDelegate) => oldDelegate.color != color;
}
