import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class GlowingBackground extends StatelessWidget {
  final Widget child;

  const GlowingBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _GlowingBackgroundPainter(glowColor: context.colors.bluePrimary),
          ),
        ),
        child,
      ],
    );
  }
}

class _GlowingBackgroundPainter extends CustomPainter {
  final Color glowColor;
  _GlowingBackgroundPainter({required this.glowColor});

  @override
  void paint(Canvas canvas, Size size) {
    // Top Left soft blue glow
    final paintBlue = Paint()
      ..shader = RadialGradient(
        colors: [
          glowColor.withValues(alpha: 0.05),
          glowColor.withValues(alpha: 0.0),
        ],
        center: const Alignment(-0.8, -0.9),
        radius: 1.2,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    // Middle Right soft pink glow
    final paintPink = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFF007F).withValues(alpha: 0.03),
          const Color(0xFFFF007F).withValues(alpha: 0.0),
        ],
        center: const Alignment(0.9, -0.3),
        radius: 1.4,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Bottom Left soft amber glow
    final paintAmber = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFD60A).withValues(alpha: 0.03),
          const Color(0xFFFFD60A).withValues(alpha: 0.0),
        ],
        center: const Alignment(-0.7, 0.8),
        radius: 1.2,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paintBlue);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paintPink);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paintAmber);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
